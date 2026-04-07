// =============================================================================
// Package : deu_pkg
// Description: Collects all testbench classes into one compilation unit.
//              Include order respects class dependencies.
// =============================================================================

`ifndef DEU_PKG_SV
`define DEU_PKG_SV

`include "uvm_macros.svh"

package deu_pkg;
    import uvm_pkg::*;

    // ---- Configuration ------------------------------------------------------
    `include "deu_test_cfg.sv"

    // ---- Transaction ---------------------------------------------------------
    `include "deu_seq_item.sv"

    // ---- Reference model -----------------------------------------------------
    `include "deu_ref_model.sv"

    // ---- Env components ------------------------------------------------------
    `include "deu_scoreboard_imp.sv"
    `include "deu_driver.sv"
    `include "deu_monitor.sv"
    `include "deu_scoreboard.sv"
    `include "deu_agent.sv"
    `include "deu_env.sv"

    // ---- Sequences -----------------------------------------------------------
    `include "deu_base_seq.sv"

    // ---- Tests ---------------------------------------------------------------
    `include "deu_base_test.sv"

endpackage : deu_pkg

`endif // DEU_PKG_SV
