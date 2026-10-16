Qoreo is a choreographic programming language for quantum networks and distributed systems.

# Install

Qoreo is written in Rocq and is tested with Rocq 9.0 and 9.1. It may not be compatible with earlier versions e.g. Coq 8.x.

I recommend installing Rocq via opam: https://rocq-prover.org/docs/using-opam

Qoreo uses the QuantumLib library for formalizing quantum computing (https://github.com/inQWIRE/QuantumLib) but the version compatible with Rocq 9.x is currently in a fork here: https://github.com/jpaykin/QuantumLib/tree/jpaykin/v9.1. You can install it via:

```
opam pin coq-quantumlib https://github.com/jpaykin/QuantumLib.git#jpaykin/v9.1
```

Once dependencies have been installed, you can build the Rocq proofs using `make proofs`. The workflow uses CoqMakefile.


# Structure

The repository contains the Rocq formalization, extraction/generation tools, Python runtimes, and example simulations:

```text
.
├── src/
│   ├── Base/             # Shared structures: variables, actors, configs, maps
│   ├── Expr/             # Local quantum expression language and metatheory
│   ├── Choreography/     # Choreographies, semantics, proofs, and notation
│   ├── Network/          # Process/network semantics and endpoint projection
│   ├── Examples/         # Example choreographies
│   ├── NetQasm.v         # Rendering projected processes as Python applications
│   ├── NewChoreography.v # Experimental choreography representation
│   └── expr/             # Earlier expression-language sources
├── ocaml/                # Drivers that write generated party applications
├── python/               # NetQASM and NetSquid runtime implementations
├── test_examples/        # B92, DQFT, and unitary simulation tests
├── Makefile              # Proof and example-generation targets
└── _CoqProject           # Rocq logical paths and source-file list
```

The main Rocq components are:

* `src/Base/` defines common data types and finite maps, including `Var`, `Actor`, `Config`, and `ChorEnv`.
* `src/Expr/` defines the local quantum expression language, its typing and operational semantics, and related metatheory.
* `src/Choreography/` defines choreographic programs and proves their typing, operational, and safety properties.
* `src/Network/` defines projected processes and networks, endpoint projection, and its correctness properties.
* `src/Examples/` contains B92, measurement/send, teleportation, protocols, distributed QFT, and unitary-gate examples.
* `src/NetQasm.v` renders projected processes as Python source.

The code-generation pipeline is split between `ocaml/write_apps.ml`, the per-example drivers in `ocaml/`, and the runtime modules in `python/`.


# Contributing to the repository

To add a new Rocq `.v` file, place it in the appropriate `src/` subdirectory and add it to `_CoqProject`. Qoreo uses Rocq modules to organize data structures; for example, variables and their operations are defined under `Var` in `src/Base/Var.v`.

# Extracting to NetQASM

Qoreo can project example choreographies to per-party processes and render those processes as Python applications that use the NetQASM SDK.

## Dependencies

First install the Rocq dependencies described in the `Install` section above and make sure `rocq`, `ocamlc`, `make`, and `python` are available on your `PATH`. We have tested using Python 3.10. The extraction targets use Rocq extraction to produce OCaml code, compile that OCaml code with `ocamlc`, and then write Python applications.

The generated applications import the NetQASM SDK. Running the included simulation also requires SquidASM:

```
python -m pip install netqasm
python -m pip install squidasm --extra-index-url=https://pypi.netsquid.org
```

SquidASM depends on NetSquid, which requires special credentials to install. You can register and obtain credentials at the [NetSquid website](https://netsquid.org/).

## Extracting the examples

The `src/Examples/` directory contains the extractable examples:

* `MeasureSend.v` - Alice creates a qubit, applies `H`, measures it, and sends the resulting classical bit to Bob
* `Teleportation.v` - a teleportation choreography
* `B92.v` - a B92 quantum key distribution choreography
* `dis_qft.v` - a distributed quantum Fourier transform example
* `unitary_test.v` - a unitary-gate example

Generate applications with the corresponding Make targets:

```
make generate-measure-send-py
make generate-teleportation-py
make generate-b92-py
make generate-dqft-py
make generate-unitary-py
```

Each target builds the corresponding Rocq example, extracts rendered application data into `extracted/`, compiles the OCaml generator, and writes party applications under `generated/<example>/`. The generator also copies the runtime module it uses into that output directory.

The compilation pipeline uses:

* `src/NetQasm.v` - Renders a `Process` into a string in a NetQASM-like IR
* `ocaml/write_apps.ml` - An OCaml driver to run the renderer and save the results to .py files
* `python/qoreo_netqasm_runtime.py` and `python/qoreo_netsquid_runtime.py` - Python runtimes for the generated applications and NetSquid simulations

## Running the examples

The `test_examples/` directory contains simulation tests. B92 uses SquidASM; DQFT and unitary use the Qoreo NetSquid runtime. Generate the applications first:

```
make generate-b92-py
make generate-dqft-py
make generate-unitary-py
```

Run the B92 test with the Python environment containing NetSquid and SquidASM dependencies:

```
python test_examples/test_b92.py
```

The B92 test starts Alice and Bob through SquidASM, runs several protocol rounds, and checks that their conclusive key bits match. The DQFT and unitary tests execute the generated party programs against the Qoreo NetSquid runtime.

`MeasureSend` and `Teleportation` generate NetQASM SDK Python applications. Their generated applications can be run with the NetQASM tooling.
