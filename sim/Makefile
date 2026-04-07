# =============================================================================
# Makefile — DEU UVM simulation (VCS)
#
# Usage examples:
#   make sanity                          # P0 smoke test
#   make directed CFG=cfg/directed_dt01.cfg
#   make random   CFG=cfg/random_full.cfg
#   make TESTNAME=deu_random_test CFG=cfg/random_vld_toggle.cfg
#   make clean
#
# Supported simulators: VCS (default), Xcelium (set SIM=xcelium)
# =============================================================================

# ---- Paths ------------------------------------------------------------------
PROJ_ROOT  := $(shell cd .. && pwd)
RTL_DIR    := $(PROJ_ROOT)/rtl
TB_DIR     := $(PROJ_ROOT)/tb
SIM_DIR    := $(PROJ_ROOT)/sim

# ---- Tool -------------------------------------------------------------------
SIM        ?= vcs

# ---- Defaults ---------------------------------------------------------------
TESTNAME   ?= deu_sanity_test
CFG        ?= $(TB_DIR)/cfg/sanity.cfg
SEED       ?= 1
WAVES      ?= 0
FSDB       ?= 0         # 1 = dump to FSDB, 0 = dump to VPD

# ---- File lists -------------------------------------------------------------
RTL_FILES  := $(RTL_DIR)/sliv_decoder.v  \
              $(RTL_DIR)/decomp_square.v  \
              $(RTL_DIR)/compare_swap.v   \
              $(RTL_DIR)/bitonic_sort.v   \
              $(RTL_DIR)/deu_design.v

TB_TOPS    := $(TB_DIR)/top/deu_if.sv    \
              $(TB_DIR)/top/deu_pkg.sv   \
              $(TB_DIR)/top/deu_tb_top.sv

# ---- Coverage settings -------------------------------------------------------
COV        ?= 0               # 1 = enable line+cond coverage collection
COV_CM_DIR := $(SIM_DIR)/coverage_db
COV_TYPES  := line+cond

# ---- VCS compile flags -------------------------------------------------------
VCS_COMP_FLAGS := \
    -full64 \
    -sverilog \
    -ntb_opts uvm-1.2 \
    -timescale=1ns/1ps \
    -debug_access+all \
    +incdir+$(TB_DIR)/cfg \
    +incdir+$(TB_DIR)/env \
    +incdir+$(TB_DIR)/ref \
    +incdir+$(TB_DIR)/seq \
    +incdir+$(TB_DIR)/test \
    +incdir+$(TB_DIR)/top \
    -l $(SIM_DIR)/compile.log

ifeq ($(COV),1)
VCS_COMP_FLAGS += -cm $(COV_TYPES) -cm_dir $(COV_CM_DIR)
endif

# ---- VCS simulation flags ---------------------------------------------------
VCS_SIM_FLAGS := \
    +UVM_TESTNAME=$(TESTNAME) \
    +UVM_VERBOSITY=UVM_MEDIUM \
    +ntb_random_seed=$(SEED) \
    +cfg=$(CFG)

ifeq ($(COV),1)
VCS_SIM_FLAGS += -cm $(COV_TYPES) -cm_dir $(COV_CM_DIR) -cm_name $(TESTNAME)
endif

ifeq ($(WAVES),1)
VCS_SIM_FLAGS += -gui
endif

ifeq ($(FSDB),1)
VCS_SIM_FLAGS += +fsdbfile=$(SIM_DIR)/waves.fsdb
else
VCS_SIM_FLAGS += +vpdfile=$(SIM_DIR)/waves.vpd
endif

# ---- Xcelium compile flags --------------------------------------------------
XRUN_FLAGS := \
    -sv \
    -uvm \
    -uvmhome CDNS-1.2 \
    -timescale 1ns/1ps \
    +incdir+$(TB_DIR)/cfg \
    +incdir+$(TB_DIR)/env \
    +incdir+$(TB_DIR)/ref \
    +incdir+$(TB_DIR)/seq \
    +incdir+$(TB_DIR)/test \
    +incdir+$(TB_DIR)/top \
    -log $(SIM_DIR)/compile.log

XRUN_SIM_FLAGS := \
    -input "run" \
    +UVM_TESTNAME=$(TESTNAME) \
    +UVM_VERBOSITY=UVM_MEDIUM \
    +cfg=$(CFG)

# =============================================================================
# Targets
# =============================================================================


# ---- Vericom compile flags --------------------------------------------------
UVM_HOME       := /data/synopsys/vcs_all_vW-2024.09-SP1/vcs/W-2024.09-SP1/etc/uvm-1.2
VERICOM_LIB    ?= work
VERICOM_FLAGS  := \
    -sverilog \
    -timescale=1ns/1ps \
    -lib $(VERICOM_LIB) \
    +incdir+$(UVM_HOME) \
    +incdir+$(TB_DIR)/cfg \
    +incdir+$(TB_DIR)/env \
    +incdir+$(TB_DIR)/ref \
    +incdir+$(TB_DIR)/seq \
    +incdir+$(TB_DIR)/test \
    +incdir+$(TB_DIR)/top

.PHONY: all sanity directed random waves clean help test compile coverage cov_report vericom

all: sanity

# ---- P0 sanity test (default, used after RTL changes) -----------------------
sanity:
	$(MAKE) run TESTNAME=deu_sanity_test CFG=$(TB_DIR)/cfg/sanity.cfg

# ---- Generic directed run ---------------------------------------------------
directed:
	$(MAKE) run TESTNAME=deu_base_test CFG=$(CFG)

# ---- Random regression run --------------------------------------------------
random:
	$(MAKE) run TESTNAME=deu_random_test CFG=$(CFG)

# ---- Compile only (generate simv) ------------------------------------------
compile:
ifeq ($(SIM),xcelium)
	xrun $(XRUN_FLAGS) $(RTL_FILES) $(TB_TOPS) -elaborate -exit
else
	vcs $(VCS_COMP_FLAGS) $(RTL_FILES) $(TB_TOPS) -o $(SIM_DIR)/simv
endif

# ---- Vericom: compile RTL into Verdi design library -------------------------
vericom:
	rm -rf $(SIM_DIR)/$(VERICOM_LIB).lib++
	vericom $(VERICOM_FLAGS) \
	    $(UVM_HOME)/uvm_pkg.sv \
	    $(RTL_FILES) $(TB_TOPS) \
	    -top deu_tb_top

# ---- Core compile + simulate target -----------------------------------------
# Use "test" as an alias to "run" to avoid conflict with ./run directory
test: run

run:
ifeq ($(SIM),xcelium)
	xrun $(XRUN_FLAGS) $(RTL_FILES) $(TB_TOPS) $(XRUN_SIM_FLAGS) \
	    +UVM_TESTNAME=$(TESTNAME)
else
	vcs $(VCS_COMP_FLAGS) $(RTL_FILES) $(TB_TOPS) -o $(SIM_DIR)/simv && \
	$(SIM_DIR)/simv $(VCS_SIM_FLAGS)
endif

# ---- Waveform-enabled run ---------------------------------------------------
waves:
	$(MAKE) run WAVES=1

# Base sim flags without test-specific args (used by coverage target)
COV_SIM_BASE := +UVM_VERBOSITY=UVM_MEDIUM +ntb_random_seed=$(SEED) \
                +vpdfile=$(SIM_DIR)/waves.vpd

# ---- Coverage: compile once with -cm, then run each test --------------------
coverage:
	rm -rf $(COV_CM_DIR)
	VCS_HOME=$(VCS_HOME) \
	vcs $(VCS_COMP_FLAGS) -cm $(COV_TYPES) -cm_dir $(COV_CM_DIR) \
	    $(RTL_FILES) $(TB_TOPS) -o $(SIM_DIR)/simv
	VCS_HOME=$(VCS_HOME) \
	$(SIM_DIR)/simv $(COV_SIM_BASE) -cm $(COV_TYPES) -cm_dir $(COV_CM_DIR) \
	    -cm_name deu_sanity_test \
	    +UVM_TESTNAME=deu_sanity_test +cfg=$(TB_DIR)/cfg/sanity.cfg
	VCS_HOME=$(VCS_HOME) \
	$(SIM_DIR)/simv $(COV_SIM_BASE) -cm $(COV_TYPES) -cm_dir $(COV_CM_DIR) \
	    -cm_name directed_dt01 \
	    +UVM_TESTNAME=deu_base_test +cfg=$(TB_DIR)/cfg/directed_dt01.cfg
	VCS_HOME=$(VCS_HOME) \
	$(SIM_DIR)/simv $(COV_SIM_BASE) -cm $(COV_TYPES) -cm_dir $(COV_CM_DIR) \
	    -cm_name directed_full_valid \
	    +UVM_TESTNAME=deu_base_test +cfg=$(TB_DIR)/cfg/directed_full_valid.cfg
	VCS_HOME=$(VCS_HOME) \
	$(SIM_DIR)/simv $(COV_SIM_BASE) -cm $(COV_TYPES) -cm_dir $(COV_CM_DIR) \
	    -cm_name pipeline_timing \
	    +UVM_TESTNAME=deu_base_test +cfg=$(TB_DIR)/cfg/pipeline_timing.cfg
	VCS_HOME=$(VCS_HOME) \
	$(SIM_DIR)/simv $(COV_SIM_BASE) -cm $(COV_TYPES) -cm_dir $(COV_CM_DIR) \
	    -cm_name cov_sliv0 \
	    +UVM_TESTNAME=deu_base_test +cfg=$(TB_DIR)/cfg/cov_sliv0.cfg
	VCS_HOME=$(VCS_HOME) \
	$(SIM_DIR)/simv $(COV_SIM_BASE) -cm $(COV_TYPES) -cm_dir $(COV_CM_DIR) \
	    -cm_name cov_sliv13 \
	    +UVM_TESTNAME=deu_base_test +cfg=$(TB_DIR)/cfg/cov_sliv13.cfg
	VCS_HOME=$(VCS_HOME) \
	$(SIM_DIR)/simv $(COV_SIM_BASE) -cm $(COV_TYPES) -cm_dir $(COV_CM_DIR) \
	    -cm_name cov_sliv14 \
	    +UVM_TESTNAME=deu_base_test +cfg=$(TB_DIR)/cfg/cov_sliv14.cfg
	VCS_HOME=$(VCS_HOME) \
	$(SIM_DIR)/simv $(COV_SIM_BASE) -cm $(COV_TYPES) -cm_dir $(COV_CM_DIR) \
	    -cm_name cov_sliv15 \
	    +UVM_TESTNAME=deu_base_test +cfg=$(TB_DIR)/cfg/cov_sliv15.cfg
	$(MAKE) cov_report

# ---- Merge coverage DBs and generate URG HTML report ------------------------
cov_report:
	VCS_HOME=$(VCS_HOME) \
	urg -dir $(COV_CM_DIR) \
	    -format both \
	    -report $(SIM_DIR)/cov_report \
	    -log $(SIM_DIR)/urg.log
	@echo ""
	@echo "Coverage report written to: $(SIM_DIR)/cov_report/dashboard.html"
	@echo ""

# ---- Clean ------------------------------------------------------------------
clean:
	rm -rf $(SIM_DIR)/simv $(SIM_DIR)/simv.daidir \
	       $(SIM_DIR)/csrc $(SIM_DIR)/*.log \
	       $(SIM_DIR)/ucli.key $(SIM_DIR)/vc_hdrs.h \
	       $(SIM_DIR)/novas.* $(SIM_DIR)/*.vpd $(SIM_DIR)/*.fsdb \
	       $(SIM_DIR)/waves.vpd $(SIM_DIR)/waves.fsdb

# ---- Help -------------------------------------------------------------------
help:
	@echo ""
	@echo "  make sanity                      # P0 smoke test (deu_sanity_test)"
	@echo "  make directed CFG=<cfg_file>     # directed test with custom cfg"
	@echo "  make random   CFG=<cfg_file>     # random test with custom cfg"
	@echo "  make run TESTNAME=<t> CFG=<c>   # any test + cfg combination"
	@echo "  make compile                     # compile only (generate vericom lib)"
	@echo "  make waves TESTNAME=<t> CFG=<c> # open waveform viewer (vpd)"
	@echo "  make SIM=xcelium ...             # use Xcelium instead of VCS"
	@echo "  make clean                       # remove build artifacts"
	@echo ""
	@echo "  Waveform format (dump flags):"
	@echo "    FSDB=0                       # default: VPD format (dumps to sim/waves.vpd)"
	@echo "    FSDB=1                       # FSDB format (dumps to sim/waves.fsdb)"
	@echo ""
	@echo "  Examples:"
	@echo "    make sanity FSDB=1           # smoke test with FSDB output"
	@echo "    make waves FSDB=1            # open FSDB waveform (if supported)"
	@echo ""
	@echo "  CFG presets in tb/cfg/:"
	@echo "    sanity.cfg              P0 smoke"
	@echo "    directed_dt01.cfg       DT-01"
	@echo "    directed_full_valid.cfg DT-02"
	@echo "    pipeline_timing.cfg     DT-T01/T02"
	@echo "    random_full.cfg         DT-R01 (100k txns)"
	@echo "    random_vld_toggle.cfg   DT-R02 (200k txns, toggle vld)"
	@echo ""
