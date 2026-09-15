.DEFAULT_GOAL := help
LAB ?= lab_1
VIVADO ?= vivado
JOBS ?= 2
export JOBS

.PHONY: help project gui sim synth bitstream clean
help:
	@echo 'make project   - create/update the local Vivado project'
	@echo 'make gui       - create/update the project and open Vivado'
	@echo 'make sim       - verify all four XOR input combinations'
	@echo 'make synth     - synthesize and write utilization report'
	@echo 'make bitstream - synthesize, implement, and generate .bit'
	@echo 'make clean     - delete generated build files (close Vivado first)'
	@echo 'Options: LAB=lab_1 VIVADO=/path/to/vivado JOBS=2'

project gui sim synth bitstream:
	@test -f "$(LAB)/scripts/project.tcl" || { echo 'Missing lab scripts'; exit 1; }
	@mkdir -p "$(LAB)/build"
	cd "$(LAB)/build" && "$(VIVADO)" -mode $(if $(filter gui,$@),gui,batch) -source ../scripts/$(if $(filter sim,$@),sim,$(if $(filter synth bitstream,$@),build,project)).tcl $(if $(filter synth bitstream,$@),-tclargs $(if $(filter synth,$@),synth,bitstream))

clean:
	@test "$(LAB)" = "$(notdir $(LAB))" && test "$(LAB)" != "." && test "$(LAB)" != ".." && test -f "$(LAB)/scripts/project.tcl" || { echo 'LAB must name a lab folder directly under this repository'; exit 1; }
	rm -rf -- "$(LAB)/build"
