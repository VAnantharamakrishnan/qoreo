.PHONY: all clean generate-teleportation-py generate-measure-send-py

all: CoqMakefile
	$(MAKE) -f CoqMakefile

proofs: CoqMakefile
	$(MAKE) -f CoqMakefile

CoqMakefile: _CoqProject
	rocq makefile -f _CoqProject -o CoqMakefile

clean: CoqMakefile
	$(MAKE) -f CoqMakefile clean
	rm -f CoqMakefile CoqMakefile.conf
	rm -rf extracted generated

%: CoqMakefile
	$(MAKE) -f CoqMakefile $@

generate-teleportation-py: examples/Teleportation.vo ocaml/write_apps.ml ocaml/generate_teleportation.ml python/qoreo_netqasm_runtime.py
	mkdir -p extracted generated
	ocamlc -I extracted -c extracted/teleportation_netqasm.mli
	ocamlc -I extracted -c extracted/teleportation_netqasm.ml
	ocamlc -I extracted -I ocaml -c ocaml/write_apps.ml
	ocamlc -I extracted -I ocaml -c ocaml/generate_teleportation.ml
	ocamlc -I extracted -I ocaml -o extracted/generate_teleportation unix.cma extracted/teleportation_netqasm.cmo ocaml/write_apps.cmo ocaml/generate_teleportation.cmo
	./extracted/generate_teleportation generated/teleportation

generate-measure-send-py: examples/MeasureSend.vo ocaml/write_apps.ml ocaml/generate_measure_send.ml python/qoreo_netqasm_runtime.py
	mkdir -p extracted generated
	ocamlc -I extracted -c extracted/measure_send_netqasm.mli
	ocamlc -I extracted -c extracted/measure_send_netqasm.ml
	ocamlc -I extracted -I ocaml -c ocaml/write_apps.ml
	ocamlc -I extracted -I ocaml -c ocaml/generate_measure_send.ml
	ocamlc -I extracted -I ocaml -o extracted/generate_measure_send unix.cma extracted/measure_send_netqasm.cmo ocaml/write_apps.cmo ocaml/generate_measure_send.cmo
	./extracted/generate_measure_send generated/measure_send

generate-b92-py: examples/b92.vo ocaml/write_apps.ml ocaml/generate_b92.ml python/qoreo_netqasm_runtime.py python/qoreo_netsquid_runtime.py
	mkdir -p extracted generated
	ocamlc -I extracted -c extracted/b92_netqasm.mli
	ocamlc -I extracted -c extracted/b92_netqasm.ml
	ocamlc -I extracted -I ocaml -c ocaml/write_apps.ml
	ocamlc -I extracted -I ocaml -c ocaml/generate_b92.ml
	ocamlc -I extracted -I ocaml -o extracted/generate_b92 unix.cma extracted/b92_netqasm.cmo ocaml/write_apps.cmo ocaml/generate_b92.cmo
	./extracted/generate_b92 generated/b92

generate-dqft-py: examples/dis_qft.vo ocaml/write_apps.ml ocaml/generate_dqft.ml python/qoreo_netsquid_runtime.py
	mkdir -p extracted generated
	ocamlc -I extracted -c extracted/dqft_netqasm.mli
	ocamlc -I extracted -c extracted/dqft_netqasm.ml
	ocamlc -I extracted -I ocaml -c ocaml/write_apps.ml
	ocamlc -I extracted -I ocaml -c ocaml/generate_dqft.ml
	ocamlc -I extracted -I ocaml -o extracted/generate_dqft unix.cma extracted/dqft_netqasm.cmo ocaml/write_apps.cmo ocaml/generate_dqft.cmo
	./extracted/generate_dqft generated/dqft

generate-unitary-py: examples/unitary_test.vo ocaml/write_apps.ml ocaml/generate_unitary.ml python/qoreo_netsquid_runtime.py
	mkdir -p extracted generated
	ocamlc -I extracted -c extracted/unitary_test_netqasm.mli
	ocamlc -I extracted -c extracted/unitary_test_netqasm.ml
	ocamlc -I extracted -I ocaml -c ocaml/write_apps.ml
	ocamlc -I extracted -I ocaml -c ocaml/generate_unitary.ml
	ocamlc -I extracted -I ocaml -o extracted/generate_unitary unix.cma extracted/unitary_test_netqasm.cmo ocaml/write_apps.cmo ocaml/generate_unitary.cmo
	./extracted/generate_unitary generated/unitary_test

generate-conditional-test-py: examples/conditional_test.vo ocaml/write_apps.ml ocaml/generate_conditional_test.ml python/qoreo_netsquid_runtime.py
	mkdir -p extracted generated
	ocamlc -I extracted -c extracted/conditional_test_netqasm.mli
	ocamlc -I extracted -c extracted/conditional_test_netqasm.ml
	ocamlc -I extracted -I ocaml -c ocaml/write_apps.ml
	ocamlc -I extracted -I ocaml -c ocaml/generate_conditional_test.ml
	ocamlc -I extracted -I ocaml -o extracted/generate_conditional_test unix.cma extracted/conditional_test_netqasm.cmo ocaml/write_apps.cmo ocaml/generate_conditional_test.cmo
	./extracted/generate_conditional_test generated/conditional_test

generate-grover-py: examples/distributed_grover.vo ocaml/write_apps.ml ocaml/generated_dgro.ml python/qoreo_netsquid_runtime.py
	mkdir -p extracted generated
	ocamlc -I extracted -c extracted/distributed_grover_netqasm.mli
	ocamlc -I extracted -c extracted/distributed_grover_netqasm.ml
	ocamlc -I extracted -I ocaml -c ocaml/write_apps.ml
	ocamlc -I extracted -I ocaml -c ocaml/generated_dgro.ml
	ocamlc -I extracted -I ocaml -o extracted/generate_dgro unix.cma extracted/distributed_grover_netqasm.cmo ocaml/write_apps.cmo ocaml/generated_dgro.cmo
	./extracted/generate_dgro generated/grover

