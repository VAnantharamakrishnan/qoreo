module T = Unitary_test
module W = Write_apps.Make (T)

let () =
  W.run
    ~apps:T.UnitaryTest.apps
    ~default_out_dir:"generated/unitary_test"
