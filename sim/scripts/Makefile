# =============================================================================
# Makefile for DEU VCS compilation & simulation
# Usage:
#   make compile        -- compile RTL only
#   make sim            -- compile + run simulation
#   make clean          -- remove run directory outputs
#   make veryclean      -- remove all generated files
# =============================================================================

# -----------------------------------------------------------------------
# Tool
# -----------------------------------------------------------------------
VCS     := /data/synopsys/vcs_all_vW-2024.09-SP1/vcs/W-2024.09-SP1/bin/vcs
VERICOM := /data/synopsys/verdi_vW-2024.09-SP1/verdi/W-2024.09-SP1/bin/vericom

# -----------------------------------------------------------------------
# Directories
# -----------------------------------------------------------------------
PROJ_ROOT := /data/project/DEU
RTL_DIR   := $(PROJ_ROOT)/rtl
TB_DIR    := $(PROJ_ROOT)/tb/top
RUN_DIR   := $(PROJ_ROOT)/sim/run
WAVE_DIR  := $(PROJ_ROOT)/sim/waves
KDB_DIR   := $(PROJ_ROOT)/sim/run/deu_lib

# -----------------------------------------------------------------------
# Source lists
# -----------------------------------------------------------------------
RTL_FLIST := $(RTL_DIR)/filelist.f
# TB filelist -- created later; guard with wildcard so compile-only works now
TB_FLIST  := $(TB_DIR)/filelist.f

# -----------------------------------------------------------------------
# Coverage options
# -----------------------------------------------------------------------
CM_OPTS  := -cm line+cond
CM_NAME  := $(RUN_DIR)/coverage

# -----------------------------------------------------------------------
# VCS compile options
# -----------------------------------------------------------------------
VCS_OPTS := \
    -full64              \
    -sverilog            \
    -timescale=1ns/1ps   \
    -notice              \
    $(CM_OPTS)           \
    -f $(RTL_FLIST)

# Include TB filelist only if it exists
ifneq ($(wildcard $(TB_FLIST)),)
    VCS_OPTS += -f $(TB_FLIST)
endif

# Top module: use deu_tb when TB exists, otherwise deu_design for syntax check
ifneq ($(wildcard $(TB_FLIST)),)
    TOP := deu_tb_top
else
    TOP := deu_design
endif

VCS_OPTS += -top $(TOP)

# Output binary
SIMV     := $(RUN_DIR)/simv

# -----------------------------------------------------------------------
# Simulation run options
# -----------------------------------------------------------------------
SIM_OPTS := $(CM_OPTS) -cm_name $(CM_NAME)

# -----------------------------------------------------------------------
# Targets
# -----------------------------------------------------------------------
# -----------------------------------------------------------------------
# vericom options (Verdi KDB)
# -----------------------------------------------------------------------
VERICOM_OPTS := \
    -sv                  \
    -lib $(KDB_DIR)      \
    -f $(RTL_FLIST)

ifneq ($(wildcard $(TB_FLIST)),)
    VERICOM_OPTS += -f $(TB_FLIST)
endif

# -----------------------------------------------------------------------
# Targets
# -----------------------------------------------------------------------
URG      := /data/synopsys/vcs_all_vW-2024.09-SP1/vcs/W-2024.09-SP1/bin/urg
COV_DIR  := $(PROJ_ROOT)/sim/cov
COV_RPT  := $(COV_DIR)/urgReport

.PHONY: all compile kdb sim cov clean veryclean

all: compile

compile: $(RUN_DIR)
	@echo "=========================================="
	@echo " VCS Compile"
	@echo "=========================================="
	cd $(RUN_DIR) && $(VCS) $(VCS_OPTS) -o $(SIMV) 2>&1 | tee compile.log
	@echo ""
	@if grep -qiE "^Error" $(RUN_DIR)/compile.log; then \
	    echo "[COMPILE] FAILED -- see $(RUN_DIR)/compile.log"; \
	    exit 1; \
	else \
	    echo "[COMPILE] PASSED"; \
	fi

sim: compile
	@echo "=========================================="
	@echo " VCS Simulation"
	@echo "=========================================="
	cd $(RUN_DIR) && $(SIMV) $(SIM_OPTS) 2>&1 | tee sim.log
	@echo "[SIM] Done -- see $(RUN_DIR)/sim.log"

kdb: $(RUN_DIR)
	@echo "=========================================="
	@echo " vericom: Build Verdi library"
	@echo "=========================================="
	cd $(RUN_DIR) && $(VERICOM) $(VERICOM_OPTS) 2>&1 | tee vericom.log
	@echo ""
	@if grep -qiE "^Error" $(RUN_DIR)/vericom.log; then \
	    echo "[KDB] FAILED -- see $(RUN_DIR)/vericom.log"; \
	    exit 1; \
	else \
	    echo "[KDB] PASSED -- open with: verdi -lib $(KDB_DIR)"; \
	fi

cov: $(COV_DIR)
	@echo "=========================================="
	@echo " urg: Merge coverage and generate report"
	@echo "=========================================="
	$(URG) -dir $(RUN_DIR)/coverage*.vdb -report $(COV_RPT) -format both \
	    -show tests 2>&1 | tee $(COV_DIR)/urg.log
	@echo "[COV] Report at $(COV_RPT)/dashboard.html"

$(RUN_DIR):
	mkdir -p $(RUN_DIR)
	mkdir -p $(WAVE_DIR)

$(COV_DIR):
	mkdir -p $(COV_DIR)

clean:
	@echo "[CLEAN] Removing run artifacts..."
	rm -rf $(RUN_DIR)/csrc \
	       $(RUN_DIR)/simv \
	       $(RUN_DIR)/simv.daidir \
	       $(RUN_DIR)/*.log \
	       $(RUN_DIR)/*.vpd \
	       $(RUN_DIR)/ucli.key \
	       $(RUN_DIR)/inter.vpd \
	       $(RUN_DIR)/*.vdb \
	       $(COV_DIR) \
	       $(KDB_DIR)
	@echo "[CLEAN] Done"

veryclean: clean
	@echo "[VERYCLEAN] Removing all generated files..."
	rm -rf $(RUN_DIR) $(WAVE_DIR)
	@echo "[VERYCLEAN] Done"
