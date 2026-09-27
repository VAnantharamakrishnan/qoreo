import sys
import tempfile

sys.path.insert(0, "generated/unitary_test")

from app_alice import main as alice_main
from netqasm.runtime.application import Application, ApplicationInstance, Program
from netqasm.runtime.interface.config import default_network_config
from netqasm.sdk.config import LogConfig
from squidasm.run.multithread.runtime_mgr import SquidAsmRuntimeManager


NUM_RUNS = 10


def run_once():
    network_cfg = default_network_config(["alice"])

    mgr = SquidAsmRuntimeManager()
    mgr.set_network(network_cfg)
    mgr.start_backend()

    prog_alice = Program(
        party="alice",
        entry=alice_main,
        args=["app_config"],
        results=[],
    )

    app = Application(
        programs=[prog_alice],
        metadata=None,
    )

    with tempfile.TemporaryDirectory() as log_dir:
        log_cfg = LogConfig(
            track_lines=False,
            log_subroutines_dir=log_dir,
            comm_log_dir=log_dir,
        )

        app_instance = ApplicationInstance(
            app=app,
            program_inputs={"alice": {}},
            network=None,
            party_alloc={"alice": "alice"},
            logging_cfg=log_cfg,
        )

        results = mgr.run_app(app_instance)

    mgr.stop_backend()

    return results


def main():
    expected = ((0, 0), 1)

    for run_index in range(NUM_RUNS):
        results = run_once()

        actual = results["app_alice"]

       
        assert actual == expected

    print(f"\nAll {NUM_RUNS} runs passed.")
    print("Tdag: WORKS")
    print("Sdag: WORKS")
    print("CS:   WORKS")


if __name__ == "__main__":
    main()