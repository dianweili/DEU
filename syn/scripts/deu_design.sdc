###############################################################################
# deu_design.sdc  —  Synthesis Design Constraints for deu_design (ASAP7 7nm)
#
# Target: ASAP7 RVT, typical corner
# NOTE: ASAP7 liberty time_unit = 1ps, so ALL timing values here are in ps.
# Clock: clk, 1 GHz → period = 1000 ps
# ASAP7 7nm predictive PDK, realistic range: 500 MHz – 2 GHz
###############################################################################

# ---------------------------------------------------------------------------
# Clock definition  (all values in ps to match library time_unit = 1ps)
# ---------------------------------------------------------------------------
set CLK_PERIOD  1000    ;# ps  → 1 GHz target
set CLK_SKEW      50    ;# ps  assumed clock network skew
set CLK_JITTER    50    ;# ps  clock source jitter

create_clock -name clk -period $CLK_PERIOD [get_ports clk]

set_clock_uncertainty -setup [expr $CLK_SKEW + $CLK_JITTER] [get_clocks clk]
set_clock_uncertainty -hold  $CLK_SKEW                       [get_clocks clk]

# Transition on clock
set_clock_transition 20 [get_clocks clk]   ;# 20 ps (ASAP7 7nm)

# ---------------------------------------------------------------------------
# Input / Output timing  (relative to clock, in ps)
# ---------------------------------------------------------------------------
set INPUT_DELAY  [expr $CLK_PERIOD * 0.30]   ;# 300 ps
set OUTPUT_DELAY [expr $CLK_PERIOD * 0.30]   ;# 300 ps

# All input ports except clk and rst_n
set_input_delay  $INPUT_DELAY  -clock clk [remove_from_collection [all_inputs] [get_ports {clk rst_n}]]
set_output_delay $OUTPUT_DELAY -clock clk [all_outputs]

# ---------------------------------------------------------------------------
# Reset: asynchronous, treated as ideal for synthesis
# ---------------------------------------------------------------------------
set_false_path -from [get_ports rst_n]

# ---------------------------------------------------------------------------
# Driving cell & output load
# ---------------------------------------------------------------------------
set_driving_cell -lib_cell BUFx2_ASAP7_75t_R -library asap7sc7p5t_INVBUF_RVT_TT_nldm_211120 [all_inputs]

# External load: ~15 fF (capacitive_load_unit = 1ff, so 15 = 15 fF)
set_load -pin_load 15 [all_outputs]

# ---------------------------------------------------------------------------
# Design rule constraints  (in ps)
# ---------------------------------------------------------------------------
set_max_fanout  20  [current_design]
set_max_transition 100 [current_design]  ;# 100 ps max transition for 7nm

# ---------------------------------------------------------------------------
# Don't use (optional)
# ---------------------------------------------------------------------------
# Avoid using SRAM-Vt cells for logic synthesis
# set_dont_use [get_lib_cells */SRAM*]
