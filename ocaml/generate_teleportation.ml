module T = Teleportation
module W = Write_apps.Make (T)

let () =
  W.run
    ~apps:T.apps
    ~default_out_dir:"generated/teleportation"
