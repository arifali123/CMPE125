.DEFAULT_GOAL := gui
LAB ?= lab_1
VIVADO ?= vivado

.PHONY: gui
gui:
	@test -f "$(LAB)/scripts/project.tcl" || { echo 'Missing lab scripts'; exit 1; }
	@mkdir -p "$(LAB)/build"
	cd "$(LAB)/build" && "$(VIVADO)" -mode gui -source ../scripts/project.tcl
