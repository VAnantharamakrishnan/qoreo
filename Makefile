PYTHON_GENERATION_EXAMPLES := \
	measure_send \
	b92 \
	dqft \
	unitary_test \
	teleportation \
	conditional_test \
	distributed_grover

.PHONY: all clean $(PYTHON_GENERATION_EXAMPLES) examples

all: CoqMakefile
	$(MAKE) -f CoqMakefile

examples: $(PYTHON_GENERATION_EXAMPLES)

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

$(PYTHON_GENERATION_EXAMPLES): %: \
	src/Examples/%.vo \
	ocaml/write_apps.ml \
	ocaml/generate_%.ml \
	python/qoreo_netqasm_runtime.py \
	python/qoreo_netsquid_runtime.py
	mkdir -p extracted generated
	ocamlc -I extracted -c extracted/$*.mli
	ocamlc -I extracted -c extracted/$*.ml
	ocamlc -I extracted -I ocaml -c ocaml/write_apps.ml
	ocamlc -I extracted -I ocaml -c ocaml/generate_$*.ml
	ocamlc -I extracted -I ocaml -o extracted/generate_$* unix.cma extracted/$*.cmo ocaml/write_apps.cmo ocaml/generate_$*.cmo
	./extracted/generate_$* generated/$*
