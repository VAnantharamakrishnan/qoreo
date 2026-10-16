
From Stdlib Require Import String List.
From Qoreo.Base Require Import Config Var Actor.
From Qoreo.Expr Require Import Expr.
From Qoreo.Choreography Require Import Choreography.
From Qoreo.Network Require Import Network.
From QoreoExamples Require Import Notation.
Import ExampleExtraction.
From Stdlib Require Import extraction.ExtrOcamlNativeString.
From Qoreo Require Import NetQasm.

Open Scope string_scope.
Open Scope example_scope.
Import Unitary.
Import ListNotations.

Module DistributedGrover.

  (* Local CZ using H(target), CNOT, H(target). *)
  Definition local_cz
      (P : Actor.t) (control target : Var.t)
      : Qoreo (Var.t * Var.t) :=
    do target ← P [- Unitary H target -] ;;
    do (control, target) ←
      P [-- Unitary CNOT (Pair control target) -] ;;
    do target ← P [- Unitary H target -] ;;
    ret (control, target).

  (* Remote CZ on Alice's and Bob's data qubits.

     EPR resource: Phi+
     Convert to Psi+ by applying X to Bob's EPR half.

     Alice measures her EPR half in X basis.
     Bob measures his EPR half in Y basis.

     Feed-forward:
       Alice: S Z^(mA xor mB)
       Bob:   Sdag Z^(mA xor mB)

     Applying Z for each measured bit separately
     implements the XOR parity, since Z^2 = I.
  *)
  Definition remote_cz
      (Alice Bob : Actor.t)
      (qA qB : Var.t)
      : Qoreo (Var.t * Var.t) :=

    (* One shared EPR pair *)
    do (a, b) ← get_entangled_pair Alice Bob ;;

    (* Phi+ -> Psi+ *)
    do b ← Bob [- Unitary X b -] ;;

    (* Local CZ between data and network qubits *)
    do (qA, a) ← local_cz Alice qA a ;;
    do (qB, b) ← local_cz Bob qB b ;;

    (* Alice: X-basis measurement *)
    do a ← Alice [- Unitary H a -] ;;
    do mA ← Alice [- Meas a -] ;;

    (* Bob: Y-basis measurement *)
    do b ← Bob [- Unitary Sdag b -] ;;
    do b ← Bob [- Unitary H b -] ;;
    do mB ← Bob [- Meas b -] ;;

    (* Exchange measurement outcomes *)
    do mA_bob ← send Alice mA Bob ;;
    do mB_alice ← send Bob mB Alice ;;

    (* Alice: S Z^(mA xor mB) *)
    do qA ← Alice [- Unitary SGATE qA -] ;;
    do qA ← Alice [- Expr.If mA
                        (Unitary Z qA)
                        qA -] ;;
    do qA ← Alice [- Expr.If mB_alice
                        (Unitary Z qA)
                        qA -] ;;

    (* Bob: Sdag Z^(mA xor mB) *)
    do qB ← Bob [- Unitary Sdag qB -] ;;
    do qB ← Bob [- Expr.If mA_bob
                      (Unitary Z qB)
                      qB -] ;;
    do qB ← Bob [- Expr.If mB
                      (Unitary Z qB)
                      qB -] ;;

    ret (qA, qB).

  (* Two-qubit distributed Grover: marked state |11>. *)
  Definition grover_11
      (Alice Bob : Actor.t)
      : Qoreo (Var.t * Var.t) :=

    (* Initialize |00> *)
    do qA ← Alice [- New (Bit false) -] ;;
    do qB ← Bob [- New (Bit false) -] ;;

    (* Prepare uniform superposition *)
    do qA ← Alice [- Unitary H qA -] ;;
    do qB ← Bob [- Unitary H qB -] ;;

    (* Oracle: phase flip of |11> *)
    do (qA, qB) ← remote_cz Alice Bob qA qB ;;

    (* Diffusion operator *)
    do qA ← Alice [- Unitary H qA -] ;;
    do qB ← Bob [- Unitary H qB -] ;;

    do qA ← Alice [- Unitary X qA -] ;;
    do qB ← Bob [- Unitary X qB -] ;;

    (* Second remote CZ *)
    do (qA, qB) ← remote_cz Alice Bob qA qB ;;

    do qA ← Alice [- Unitary X qA -] ;;
    do qB ← Bob [- Unitary X qB -] ;;

    do qA ← Alice [- Unitary H qA -] ;;
    do qB ← Bob [- Unitary H qB -] ;;

    (* Measure final result *)
    do resultA ← Alice [- Meas qA -] ;;
    do resultB ← Bob [- Meas qB -] ;;

    (* Return both measurement bits *)
    ret (resultA, resultB).

  Definition choreo : Choreography.t :=
    mk (
      do result ← grover_11 "alice" "bob" ;;
      ret result
    ).

  Definition parties : list Actor.t :=
    ["alice"; "bob"].

  Definition apps : option (list AppFile.t) :=
    ExampleExtraction.render_parties choreo parties.

End DistributedGrover.

Extraction Language OCaml.
Set Extraction Output Directory "extracted".
Extraction "distributed_grover_netqasm.ml"
  DistributedGrover.apps.
