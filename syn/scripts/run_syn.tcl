#!/usr/bin/env dc_shell-t
# =============================================================================
# run_syn.tcl  —  DC Synthesis Flow for deu_design (ASAP7 7nm RVT)
#
# Usage:
#   dc_shell -f run_syn.tcl |& tee syn.log
#   dc_shell -f run_syn.tcl -output_log_file syn.log
#
# Or use the Makefile: make syn
# =============================================================================

# ---------------------------------------------------------------------------
# 0. Load environment / PDK setup
# ---------------------------------------------------------------------------
source [file join [file dirname [info script]] setup.tcl]

# Work directory for intermediate DC files
sh mkdir -p $WORK_DIR $RPT_DIR $NETLIST_DIR
define_design_lib WORK -path $WORK_DIR

# ---------------------------------------------------------------------------
# 1. Read & analyze RTL
# ---------------------------------------------------------------------------
echo "### Step 1: Analyzing RTL files ###"
foreach f $RTL_FILES {
    echo "  Analyzing: $f"
    analyze -library WORK -format verilog $f
}

# ---------------------------------------------------------------------------
# 2. Elaborate (resolve hierarchy, parameters)
# ---------------------------------------------------------------------------
echo "### Step 2: Elaborate ###"
elaborate $TOP_MODULE -library WORK
current_design $TOP_MODULE
link

# DRC check before synthesis
check_design > ${RPT_DIR}/check_design_pre.rpt

# ---------------------------------------------------------------------------
# 3. Apply constraints
# ---------------------------------------------------------------------------
echo "### Step 3: Applying SDC constraints ###"
source [file join [file dirname [info script]] deu_design.sdc]

# ---------------------------------------------------------------------------
# 4. Compile options
# ---------------------------------------------------------------------------
echo "### Step 4: Compile ###"

# Multi-core parallelism
set_app_var compile_ultra_ungroup_small_hierarchies true
set_host_options -max_cores 4

# Pre-compile settings
set_app_var compile_seqmap_propagate_constants    true
set_app_var compile_seqmap_propagate_high_effort  true

# Ungroup small hierarchies to improve optimization quality
# (comment out if you want to preserve module hierarchy)
# ungroup -all -flatten

# Main compile (high effort)
compile_ultra -no_autoungroup

# Incremental compile for further timing closure (optional second pass)
# compile_ultra -incremental

# ---------------------------------------------------------------------------
# 5. Post-compile DRC & timing reports
# ---------------------------------------------------------------------------
echo "### Step 5: Generating reports ###"

check_design > ${RPT_DIR}/check_design_post.rpt

report_timing -delay_type max \
              -max_paths 20 \
              -sort_by slack \
              -input_pins \
              -capacitance \
              > ${RPT_DIR}/timing_setup.rpt

report_timing -delay_type min \
              -max_paths 20 \
              -sort_by slack \
              > ${RPT_DIR}/timing_hold.rpt

report_area   -hierarchy > ${RPT_DIR}/area.rpt

report_power  -hierarchy > ${RPT_DIR}/power.rpt

report_qor    > ${RPT_DIR}/qor.rpt

report_constraint -all_violators > ${RPT_DIR}/violations.rpt

# Cell usage
report_cell > ${RPT_DIR}/cell_usage.rpt

# Net fanout
report_net   > ${RPT_DIR}/net.rpt

# ---------------------------------------------------------------------------
# 6. Write outputs
# ---------------------------------------------------------------------------
echo "### Step 6: Writing outputs ###"

# Gate-level netlist (Verilog)
write_file -format verilog \
           -hierarchy \
           -output ${NETLIST_DIR}/${TOP_MODULE}_netlist.v

# DDC (Design Compiler binary — for reloading later)
write_file -format ddc \
           -hierarchy \
           -output ${NETLIST_DIR}/${TOP_MODULE}.ddc

# SDC (back-annotated constraints — for P&R)
write_sdc ${NETLIST_DIR}/${TOP_MODULE}.sdc

# SDF (Standard Delay Format — for gate-level simulation)
write_sdf -version 2.1 ${NETLIST_DIR}/${TOP_MODULE}.sdf

echo ""
echo "============================================================"
echo "  Synthesis complete!"
echo "  Netlist : ${NETLIST_DIR}/${TOP_MODULE}_netlist.v"
echo "  Reports : ${RPT_DIR}/"
echo "============================================================"

# Print QoR summary to screen
report_qor

exit
