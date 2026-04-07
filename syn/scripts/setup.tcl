# =============================================================================
# setup.tcl  —  PDK / design environment setup for DC synthesis
# Sourced at the top of run_syn.tcl
# =============================================================================

# -------------------------------------------------------------------
# Tool paths
# -------------------------------------------------------------------
set SYNOPSYS_ROOT  "/data/synopsys/syn_vW-2024.09-SP1"
set PDK_DIR        "/data/project/pdk/asap7"
set DESIGN_DIR     "/data/project/DEU"
set SYN_DIR        "${DESIGN_DIR}/syn"

# -------------------------------------------------------------------
# ASAP7 RVT library (NLDM, 3 corners)
#   TT : typical-typical  → used as target_library for synthesis
#   SS : slow-slow        → max (setup) timing corner
#   FF : fast-fast        → min (hold)  timing corner
# -------------------------------------------------------------------
set DB_DIR "${PDK_DIR}/DB"

# All 5 cell groups × 3 corners
set TT_DB_FILES [list \
    ${DB_DIR}/asap7sc7p5t_AO_RVT_TT_nldm_211120.db    \
    ${DB_DIR}/asap7sc7p5t_OA_RVT_TT_nldm_211120.db    \
    ${DB_DIR}/asap7sc7p5t_INVBUF_RVT_TT_nldm_220122.db \
    ${DB_DIR}/asap7sc7p5t_SEQ_RVT_TT_nldm_220123.db   \
    ${DB_DIR}/asap7sc7p5t_SIMPLE_RVT_TT_nldm_211120.db \
]

set SS_DB_FILES [list \
    ${DB_DIR}/asap7sc7p5t_AO_RVT_SS_nldm_211120.db    \
    ${DB_DIR}/asap7sc7p5t_OA_RVT_SS_nldm_211120.db    \
    ${DB_DIR}/asap7sc7p5t_INVBUF_RVT_SS_nldm_220122.db \
    ${DB_DIR}/asap7sc7p5t_SEQ_RVT_SS_nldm_220123.db   \
    ${DB_DIR}/asap7sc7p5t_SIMPLE_RVT_SS_nldm_211120.db \
]

set FF_DB_FILES [list \
    ${DB_DIR}/asap7sc7p5t_AO_RVT_FF_nldm_211120.db    \
    ${DB_DIR}/asap7sc7p5t_OA_RVT_FF_nldm_211120.db    \
    ${DB_DIR}/asap7sc7p5t_INVBUF_RVT_FF_nldm_220122.db \
    ${DB_DIR}/asap7sc7p5t_SEQ_RVT_FF_nldm_220123.db   \
    ${DB_DIR}/asap7sc7p5t_SIMPLE_RVT_FF_nldm_211120.db \
]

# -------------------------------------------------------------------
# DC library variables  (use TT for synthesis target)
# -------------------------------------------------------------------
set target_library  $TT_DB_FILES
set link_library    [concat "*" $TT_DB_FILES]

# -------------------------------------------------------------------
# .alib cache — store in PDK DB dir so it is built once and shared
# across projects.  The OPT-1311 "placeholder alib" warning is benign
# for ASAP7 (DC falls back to direct .db analysis); suppress it.
# -------------------------------------------------------------------
set alib_library_analysis_path "${DB_DIR}/alib"
sh mkdir -p ${DB_DIR}/alib
suppress_message OPT-1311

# -------------------------------------------------------------------
# Design Compiler search path
# -------------------------------------------------------------------
set search_path [concat \
    $search_path          \
    "${DESIGN_DIR}/rtl"   \
    "${DB_DIR}"           \
    "${SYNOPSYS_ROOT}/libraries/syn" \
    "${SYNOPSYS_ROOT}/dw/syn_ver"    \
]

# -------------------------------------------------------------------
# DesignWare  (optional, enables DW components like multipliers)
# -------------------------------------------------------------------
set synthetic_library [list dw_foundation.sldb]
set link_library      [concat $link_library dw_foundation.sldb]

# -------------------------------------------------------------------
# RTL source file list
# -------------------------------------------------------------------
set RTL_FILES [list \
    "${DESIGN_DIR}/rtl/sliv_decoder.v"   \
    "${DESIGN_DIR}/rtl/decomp_square.v"  \
    "${DESIGN_DIR}/rtl/compare_swap.v"   \
    "${DESIGN_DIR}/rtl/bitonic_sort.v"   \
    "${DESIGN_DIR}/rtl/deu_design.v"     \
]

set TOP_MODULE "deu_design"

# -------------------------------------------------------------------
# Output directories
# -------------------------------------------------------------------
set RPT_DIR     "${SYN_DIR}/rpt"
set NETLIST_DIR "${SYN_DIR}/netlist"
set WORK_DIR    "${SYN_DIR}/work"
