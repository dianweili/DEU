##############################################################################
# Makefile  —  DEU Gate-Level Simulation
#
# Output layout:
#   run/
#   ├── logs/
#   │   ├── compile_func.log
#   │   ├── compile_timing.log
#   │   ├── sim_func_<TEST>.log      ← simulation result
#   │   ├── sim_timing_<TEST>.log
#   │   └── sdf_<TEST>.log           ← SDF annotation messages
#   ├── waves/
#   │   └── <TEST>.fsdb              ← waveform (wave_func / wave_timing)
#   ├── simv                         ← functional binary
#   ├── simv_timing                  ← timing (SDF) binary
#   └── simv_wave                    ← binary with FSDB support
#
# Usage:
#   make func            Functional GLS, sanity test (default)
#   make func TEST=random_full
#   make timing TEST=sanity        Timing GLS with SDF
#   make wave_func TEST=sanity     Functional GLS + FSDB waveform
#   make wave_timing TEST=sanity   Timing GLS + FSDB waveform
#   make wave                      Open last FSDB in Verdi
#   make clean
##############################################################################

VCS       := /data/synopsys/vcs_all_vW-2024.09-SP1/vcs/W-2024.09-SP1/bin/vcs
VERDI     := /data/synopsys/verdi_vW-2024.09-SP1/verdi/W-2024.09-SP1/bin/verdi
VERDI_HOME := /data/synopsys/verdi_vW-2024.09-SP1/verdi/W-2024.09-SP1

SNPSLMD_LICENSE_FILE := 27000@localhost.localdomain
export SNPSLMD_LICENSE_FILE
export LD_LIBRARY_PATH := $(VERDI_HOME)/share/PLI/VCS/linux64:$(LD_LIBRARY_PATH)

TEST       ?= sanity
CFG_DIR    := /data/project/DEU/tb/cfg
TB_TOP     := gls_tb_top

SCRIPT_DIR := $(shell pwd)
RUN_DIR    := $(SCRIPT_DIR)/../run
LOG_DIR    := $(RUN_DIR)/logs
WAVE_DIR   := $(RUN_DIR)/waves

# ---- VCS base flags -------------------------------------------------------
VCS_BASE := \
    -full64 \
    -sverilog \
    -ntb_opts uvm-ieee \
    -timescale=1ps/1ps \
    +define+GLS \
    -f $(SCRIPT_DIR)/filelist.f \
    -top $(TB_TOP) \
    +warn=noSDFCOM_UHICD \
    +warn=noSDFCOM_ANICD \
    +warn=noSDFCOM_IWSBA \
    +warn=noIWNF \
    -suppress=LCA_FEATURES_ENABLED

# ---- SDF flags (timing binary only) --------------------------------------
SDF_FLAGS := \
    +neg_tchk \
    +define+TSDB_ENABLE_SAME_EDGE_HOLD_CHECK

# ---- FSDB/PLI flags (wave binaries only) ---------------------------------
# Verdi W-2024: use -debug_access+all (novas.tab/pli.a flow deprecated)
FSDB_FLAGS := \
    -debug_access+all

# ---- Common sim flags -----------------------------------------------------
SIM_BASE := \
    +UVM_TESTNAME=deu_base_test \
    +UVM_VERBOSITY=UVM_MEDIUM

.PHONY: all func timing wave_func wave_timing wave clean help \
        compile_func compile_timing compile_wave_func compile_wave_timing

all: func

# ===========================================================================
# Functional GLS  (200 MHz, no SDF)
# ===========================================================================
func: compile_func
	@mkdir -p $(LOG_DIR)
	@echo "[GLS-FUNC] Running: TEST=$(TEST)"
	cd $(RUN_DIR) && ./simv \
	    $(SIM_BASE) \
	    +cfg=$(CFG_DIR)/$(TEST).cfg \
	    +FAST_CLK \
	    -l $(LOG_DIR)/sim_func_$(TEST).log \
	    2>&1 | tee $(LOG_DIR)/sim_func_$(TEST).log
	@echo ""
	@echo "[GLS-FUNC] Result log : $(LOG_DIR)/sim_func_$(TEST).log"
	@grep -E "PASSED|FAILED|UVM_ERROR|UVM_FATAL" $(LOG_DIR)/sim_func_$(TEST).log | tail -5

compile_func:
	@mkdir -p $(LOG_DIR)
	@echo "[GLS-FUNC] Compiling..."
	cd $(RUN_DIR) && $(VCS) $(VCS_BASE) \
	    -l $(LOG_DIR)/compile_func.log \
	    -o simv \
	    2>&1 | tee $(LOG_DIR)/compile_func.log
	@if grep -q "^Error" $(LOG_DIR)/compile_func.log; then \
	    echo "[COMPILE] FAILED — see $(LOG_DIR)/compile_func.log"; exit 1; \
	else echo "[COMPILE] OK"; fi

# ===========================================================================
# Timing GLS  (1 GHz, SDF back-annotated)
# ===========================================================================
timing: compile_timing
	@mkdir -p $(LOG_DIR)
	@echo "[GLS-TIMING] Running: TEST=$(TEST)"
	cd $(RUN_DIR) && ./simv_timing \
	    $(SIM_BASE) \
	    +cfg=$(CFG_DIR)/$(TEST).cfg \
	    +sdf \
	    -l $(LOG_DIR)/sim_timing_$(TEST).log \
	    2>&1 | tee $(LOG_DIR)/sim_timing_$(TEST).log
	@echo ""
	@echo "[GLS-TIMING] Result log : $(LOG_DIR)/sim_timing_$(TEST).log"
	@echo "[GLS-TIMING] SDF log    : $(LOG_DIR)/sdf_$(TEST).log"
	@grep -E "PASSED|FAILED|UVM_ERROR|UVM_FATAL" $(LOG_DIR)/sim_timing_$(TEST).log | tail -5
	@-mv -f $(RUN_DIR)/sdf.log $(LOG_DIR)/sdf_$(TEST).log 2>/dev/null; true

compile_timing:
	@mkdir -p $(LOG_DIR)
	@echo "[GLS-TIMING] Compiling..."
	cd $(RUN_DIR) && $(VCS) $(VCS_BASE) $(SDF_FLAGS) \
	    -l $(LOG_DIR)/compile_timing.log \
	    -o simv_timing \
	    2>&1 | tee $(LOG_DIR)/compile_timing.log
	@if grep -q "^Error" $(LOG_DIR)/compile_timing.log; then \
	    echo "[COMPILE] FAILED — see $(LOG_DIR)/compile_timing.log"; exit 1; \
	else echo "[COMPILE] OK"; fi

# ===========================================================================
# Functional GLS + FSDB waveform  (200 MHz)
# ===========================================================================
wave_func: compile_wave_func
	@mkdir -p $(LOG_DIR) $(WAVE_DIR)
	@echo "[GLS-WAVE-FUNC] Running: TEST=$(TEST)"
	cd $(RUN_DIR) && ./simv_wave \
	    $(SIM_BASE) \
	    +cfg=$(CFG_DIR)/$(TEST).cfg \
	    +FAST_CLK \
	    +fsdbfile=$(WAVE_DIR)/$(TEST)_func.fsdb \
	    -l $(LOG_DIR)/sim_wave_func_$(TEST).log \
	    2>&1 | tee $(LOG_DIR)/sim_wave_func_$(TEST).log
	@echo ""
	@echo "[GLS-WAVE-FUNC] Result log : $(LOG_DIR)/sim_wave_func_$(TEST).log"
	@echo "[GLS-WAVE-FUNC] Waveform   : $(WAVE_DIR)/$(TEST)_func.fsdb"
	@grep -E "PASSED|FAILED|UVM_ERROR|UVM_FATAL" $(LOG_DIR)/sim_wave_func_$(TEST).log | tail -5

compile_wave_func:
	@mkdir -p $(LOG_DIR)
	@echo "[GLS-WAVE-FUNC] Compiling with FSDB..."
	cd $(RUN_DIR) && $(VCS) $(VCS_BASE) $(FSDB_FLAGS) \
	    -l $(LOG_DIR)/compile_wave_func.log \
	    -o simv_wave \
	    2>&1 | tee $(LOG_DIR)/compile_wave_func.log
	@if grep -q "^Error" $(LOG_DIR)/compile_wave_func.log; then \
	    echo "[COMPILE] FAILED — see $(LOG_DIR)/compile_wave_func.log"; exit 1; \
	else echo "[COMPILE] OK"; fi

# ===========================================================================
# Timing GLS + FSDB waveform  (1 GHz, SDF)
# ===========================================================================
wave_timing: compile_wave_timing
	@mkdir -p $(LOG_DIR) $(WAVE_DIR)
	@echo "[GLS-WAVE-TIMING] Running: TEST=$(TEST)"
	cd $(RUN_DIR) && ./simv_wave_timing \
	    $(SIM_BASE) \
	    +cfg=$(CFG_DIR)/$(TEST).cfg \
	    +sdf \
	    +fsdbfile=$(WAVE_DIR)/$(TEST)_timing.fsdb \
	    -l $(LOG_DIR)/sim_wave_timing_$(TEST).log \
	    2>&1 | tee $(LOG_DIR)/sim_wave_timing_$(TEST).log
	@echo ""
	@echo "[GLS-WAVE-TIMING] Result log : $(LOG_DIR)/sim_wave_timing_$(TEST).log"
	@echo "[GLS-WAVE-TIMING] Waveform   : $(WAVE_DIR)/$(TEST)_timing.fsdb"
	@-mv -f $(RUN_DIR)/sdf.log $(LOG_DIR)/sdf_timing_$(TEST).log 2>/dev/null; true
	@grep -E "PASSED|FAILED|UVM_ERROR|UVM_FATAL" $(LOG_DIR)/sim_wave_timing_$(TEST).log | tail -5

compile_wave_timing:
	@mkdir -p $(LOG_DIR)
	@echo "[GLS-WAVE-TIMING] Compiling with FSDB + SDF..."
	cd $(RUN_DIR) && $(VCS) $(VCS_BASE) $(SDF_FLAGS) $(FSDB_FLAGS) \
	    -l $(LOG_DIR)/compile_wave_timing.log \
	    -o simv_wave_timing \
	    2>&1 | tee $(LOG_DIR)/compile_wave_timing.log
	@if grep -q "^Error" $(LOG_DIR)/compile_wave_timing.log; then \
	    echo "[COMPILE] FAILED — see $(LOG_DIR)/compile_wave_timing.log"; exit 1; \
	else echo "[COMPILE] OK"; fi

# ===========================================================================
# Open waveform in Verdi
# ===========================================================================
LAST_FSDB ?= $(shell ls -t $(WAVE_DIR)/*.fsdb 2>/dev/null | head -1)

wave:
	@if [ -z "$(LAST_FSDB)" ]; then \
	    echo "No FSDB found in $(WAVE_DIR). Run 'make wave_func' first."; exit 1; \
	fi
	@echo "[VERDI] Opening: $(LAST_FSDB)"
	$(VERDI) -sv \
	    -f $(SCRIPT_DIR)/filelist.f \
	    -ssf $(LAST_FSDB) &

# ===========================================================================
# Utilities
# ===========================================================================
clean:
	rm -rf $(RUN_DIR)
	@echo "Cleaned: $(RUN_DIR)"

help:
	@echo "============================================================"
	@echo " DEU Gate-Level Simulation"
	@echo "============================================================"
	@echo " Targets:"
	@echo "   func         [TEST=<x>]   Functional GLS (200 MHz, no SDF)"
	@echo "   timing       [TEST=<x>]   Timing GLS (1 GHz, SDF annotated)"
	@echo "   wave_func    [TEST=<x>]   Functional GLS + FSDB waveform"
	@echo "   wave_timing  [TEST=<x>]   Timing GLS + FSDB waveform"
	@echo "   wave                      Open latest FSDB in Verdi"
	@echo "   clean                     Remove all run artifacts"
	@echo ""
	@echo " Output:"
	@echo "   $(LOG_DIR)/sim_func_<TEST>.log"
	@echo "   $(LOG_DIR)/sim_timing_<TEST>.log"
	@echo "   $(WAVE_DIR)/<TEST>_func.fsdb"
	@echo "   $(WAVE_DIR)/<TEST>_timing.fsdb"
	@echo ""
	@echo " Available tests:"
	@echo "   sanity  directed_dt01  directed_full_valid"
	@echo "   pipeline_timing  random_full  random_vld_toggle"
	@echo "============================================================"
