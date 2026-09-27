From Stdlib Require Import String.
From Qoreo Require Import Base Expr Choreography.
From QoreoExamples Require Import Notation.
Import ExampleExtraction.
From Stdlib Require Import extraction.ExtrOcamlNativeString.
From Qoreo Require Import NetQasm.

Open Scope string_scope.
Open Scope example_scope.

Module DQFT.
  (* TO DO: Update the text here *)
  (* Returns ((alice_bit, alice_recv), (bob_basis, bob_result)).
     When bob_result = 1 the round is conclusive: alice_bit = NOT bob_basis. *)
  (*Definition dqft (Alice Bob : Actor.t) : Qoreo (Var.t * (Var.t * Var.t)) := *)
  Definition dqft (Alice Bob : Actor.t) : Qoreo unit :=
  (* I used 101 as the input here. TO DO: Automate this? *)
  do q0 ← Alice [- New (Bit true) -] ;;
  do q1 ← Bob   [- New (Bit false) -] ;;
  do q2 ← Bob   [- New (Bit true) -] ;;
  (*do coin_a ← Alice [- Unitary H (New (Bit false)) -] ;;
  *do a      ← Alice [- Meas coin_a -] ;;
*)
  do q0 ← Alice [- Unitary H q0 -] ;;
  (* Alice prepares her transmission qubit: |0⟩ if a=0, |+⟩ if a=1. *)
  (*do q      ← Alice [- New (Bit false) -] ;;
  *do q      ← Alice [- If a (Unitary H q) q -] ;;
*)
  (* This implementation only requires ONE EPR pair since we're using ancillas *)
  do (a0, a1) ← get_entangled_pair Alice Bob ;;
  (* Start Process*)
  do (q0, a0) ←
    Alice [-- Unitary CNOT (Pair q0 a0) -] ;;
  do m0 ← Alice [- Meas a0 -] ;;
  do m0_bob ← send Alice m0 Bob ;;
  do a1 ←
      Bob [- If m0_bob
                 (Unitary X a1)
                 a1 -] ;;
 
  (*This is the earlier implementation using T and CNOT for CS(a1,q1) : REWRITE THIS LATER WHEN CP is added *)
  (*do a1 ← Bob [- Unitary T a1 -] ;;
  do q1 ← Bob [- Unitary T q1 -] ;;

  do (a1, q1) ←
    Bob [-- Unitary CNOT (Pair a1 q1) -] ;;

  do q1 ← Bob [- Unitary Tdag q1 -] ;;

  do (a1, q1) ←
    Bob [-- Unitary CNOT (Pair a1 q1) -] ;;*)
  (*NEW CS GATE ADDED HERE*)
  do (a1, q1) ←
    Bob [-- Unitary CS (Pair a1 q1) -] ;;
   (*This isn't correct. I just wrote another CS here when it should be CT. TO DO: Find an approximate representation for CT*)
  (*do a1 ← Bob [- Unitary T a1 -] ;;
  do q2 ← Bob [- Unitary T q2 -] ;;

  do (a1, q2) ←
    Bob [-- Unitary CNOT (Pair a1 q2) -] ;;

  do q2 ← Bob [- Unitary Tdag q2 -] ;;

  do (a1, q2) ←
    Bob [-- Unitary CNOT (Pair a1 q2) -] ;;*)
  do (a1, q2) ←
    Bob [-- Unitary CS (Pair a1 q2) -] ;;
  (*H on a1*)
  do a1 ← Bob [- Unitary H a1 -] ;;
  (*Measure a1, send measurement result, apply correction*)
  do m1 ← Bob [- Meas a1 -] ;;
  do m1_alice ← send Bob m1 Alice ;;
  do q0 ←
      Alice [- If m1_alice
                 (Unitary Z q0)
                 q0 -] ;;
  (* H on q1 *)
  do q1 ← Bob [- Unitary H q1 -] ;;
  (*CS on q1, q2*)
  do (q1, q2) ←
    Bob [-- Unitary CS (Pair q1 q2) -] ;;
  (*H on q2*)
  do q2 ← Bob [- Unitary H q2 -] ;;

  (* TO DO: I'm unsure if ret expects a classical or quantum result. I suspect that the result needs 
  * to be classical
  *)
  do q0 ← Alice [- Meas q0 -] ;;
  do q1 ← Bob [- Meas q1 -] ;;
  do q2 ← Bob [- Meas q2 -] ;;
  ret tt.
  (*ret (q0, (q1, q2)). *)

  (* Instead of returning 3 variables, we could just return Unit *)
  (*If you're using Qoreo Unit, ret tt *)
  
 


  (* Not sure if correct, but I modified the b92 case to just run DQFT once *)
  Definition choreo : Choreography.t :=
  mk (
    do result ← dqft "alice" "bob" ;;
    ret result
  ).


  Definition parties : list Actor.t :=
    ["alice"; "bob"].


  Definition apps : option (list AppFile.t) :=
    ExampleExtraction.render_parties choreo parties.
End DQFT.

Extraction Language OCaml.
Set Extraction Output Directory "extracted".
Extraction "dqft_netqasm.ml" DQFT.apps.
