##############################################################################
# Makefile  —  DEU Synthesis with Design Compiler + ASAP7 PDK
##############################################################################

SYNOPSYS  := /data/synopsys/syn_vW-2024.09-SP1
DC_SHELL  := $(SYNOPSYS)/bin/dc_shell
PDK_LC    := $(SYNOPSYS)/linux64/lc/bin/prf2n
PDK_DIR   := /data/project/pdk/asap7
SYN_DIR   := $(shell pwd)
LOG_DIR   := $(SYN_DIR)/work

.PHONY: all syn pdk_compile clean cleanall help

all: syn

## Run DC synthesis
syn:
	@mkdir -p $(LOG_DIR)
	@echo "[SYN] Starting Design Compiler synthesis..."
	SNPSLMD_LICENSE_FILE=27000@localhost.localdomain \
	$(DC_SHELL) -f $(SYN_DIR)/scripts/run_syn.tcl \
	            -output_log_file $(LOG_DIR)/syn.log
	@echo "[SYN] Done. Log: $(LOG_DIR)/syn.log"

## (Re-)compile ASAP7 Liberty → .db  (only needed once)
pdk_compile:
	@echo "[PDK] Compiling ASAP7 .lib → .db ..."
	SNPSLMD_LICENSE_FILE=27000@localhost.localdomain \
	$(PDK_LC) -r $(SYNOPSYS) -f $(PDK_DIR)/compile_lib2db.tcl \
	          2>&1 | tee $(LOG_DIR)/pdk_compile.log
	@echo "[PDK] DB files: $(PDK_DIR)/DB/"

## Clean synthesis outputs (keep PDK .db files)
clean:
	rm -rf $(SYN_DIR)/work/* $(SYN_DIR)/rpt/* $(SYN_DIR)/netlist/*
	rm -f *.log *.pvl *.syn *.mr default.svf

## Clean everything including PDK .db files
cleanall: clean
	rm -f $(PDK_DIR)/DB/*.db

help:
	@echo "Targets:"
	@echo "  syn          - Run DC synthesis (default)"
	@echo "  pdk_compile  - Compile ASAP7 .lib → .db (once)"
	@echo "  clean        - Remove synthesis outputs"
	@echo "  cleanall     - Remove synthesis outputs + PDK .db files"
