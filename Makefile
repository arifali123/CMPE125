.DEFAULT_GOAL := help
VIVADO ?= vivado
LAB ?= lab_1
LABS := $(patsubst %/scripts/project.tcl,%,$(wildcard */scripts/project.tcl))

# Make treats positional arguments as targets; consume the lab folder explicitly.
ifneq ($(filter open,$(MAKECMDGOALS)),)
ifneq ($(words $(MAKECMDGOALS)),2)
$(error Usage: make open <lab-folder>. Available labs: $(LABS))
endif
ifneq ($(firstword $(MAKECMDGOALS)),open)
$(error Usage: make open <lab-folder>)
endif
override LAB := $(word 2,$(MAKECMDGOALS))
ifeq ($(filter $(LAB),$(LABS)),)
$(error No project setup for '$(LAB)'. Available labs: $(LABS))
endif
.PHONY: $(LAB)
$(LAB):
	@:
endif

.PHONY: help open gui
help:
	@echo 'Usage: make open <lab-folder>'
	@echo 'Available labs: $(LABS)'
	@echo 'Example: make open lab_1'

# Keep the previous command working as an alias.
open gui:
	@test -f "$(LAB)/scripts/project.tcl" || { echo "Missing $(LAB)/scripts/project.tcl"; exit 1; }
	@mkdir -p "$(LAB)/build"
	@echo "Opening $(LAB) in Vivado..."
	@cd "$(LAB)/build" && "$(VIVADO)" -mode gui -source ../scripts/project.tcl
