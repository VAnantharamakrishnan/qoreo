module T = Distributed_grover
module W = Write_apps.Make (T)

let () =
  W.run
    ~apps:T.DistributedGrover.apps
    ~default_out_dir:"generated/distributed_grover"