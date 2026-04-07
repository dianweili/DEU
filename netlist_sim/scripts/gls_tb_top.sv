// =============================================================================
// Module  : gls_tb_top
// Description: Gate-level simulation top.
//   - Swaps RTL DUT for the synthesized netlist + ASAP7 cell models
//   - timescale 1ps/1ps matches the SDF (TIMESCALE 1ps) and ASAP7 liberty
//   - Clock: 1000 ps = 1 GHz (matches synthesis target)
//   - SDF back-annotation enabled when +sdf is passed (timing GLS)
//   - Reuses the full UVM TB environment unchanged
// =============================================================================

`timescale 1ps/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "deu_pkg.sv"

module gls_tb_top;

    // -------------------------------------------------------------------------
    // Clock: 1000 ps period = 1 GHz  (matches synthesis CLK_PERIOD)
    // For functional-only GLS (no SDF), use a relaxed 5000 ps = 200 MHz
    // to avoid X-propagation from uninitialized state — controlled by +FAST_CLK
    // -------------------------------------------------------------------------
    logic clk;
    real  clk_half;
    initial begin
        if ($test$plusargs("FAST_CLK"))
            clk_half = 2500.0;   // 200 MHz — functional check, no hold issues
        else
            clk_half = 500.0;    // 1 GHz   — timing GLS with SDF
        clk = 0;
    end
    always #(clk_half) clk = ~clk;

    // -------------------------------------------------------------------------
    // Interface & DUT
    // -------------------------------------------------------------------------
    deu_if dut_if (.clk(clk));

    deu_design u_dut (
        .clk            (clk),
        .rst_n          (dut_if.rst_n),
        .i_data_vld     (dut_if.i_data_vld),
        .i_data_sliv    (dut_if.i_data_sliv),
        .i_data0_in     (dut_if.i_data0_in),
        .i_data1_in     (dut_if.i_data1_in),
        .i_data2_in     (dut_if.i_data2_in),
        .i_data3_in     (dut_if.i_data3_in),
        .i_data4_in     (dut_if.i_data4_in),
        .i_data5_in     (dut_if.i_data5_in),
        .i_data6_in     (dut_if.i_data6_in),
        .i_data7_in     (dut_if.i_data7_in),
        .i_data8_in     (dut_if.i_data8_in),
        .i_data9_in     (dut_if.i_data9_in),
        .i_data10_in    (dut_if.i_data10_in),
        .i_data11_in    (dut_if.i_data11_in),
        .i_data12_in    (dut_if.i_data12_in),
        .i_data13_in    (dut_if.i_data13_in),
        .i_data14_in    (dut_if.i_data14_in),
        .i_data15_in    (dut_if.i_data15_in),
        .o_out_vld      (dut_if.o_out_vld),
        .o_dout0        (dut_if.o_dout0),
        .o_dout1        (dut_if.o_dout1),
        .o_dout2        (dut_if.o_dout2),
        .o_dout3        (dut_if.o_dout3),
        .o_dout4        (dut_if.o_dout4),
        .o_dout5        (dut_if.o_dout5),
        .o_dout6        (dut_if.o_dout6),
        .o_dout7        (dut_if.o_dout7),
        .o_dout8        (dut_if.o_dout8),
        .o_dout9        (dut_if.o_dout9),
        .o_dout10       (dut_if.o_dout10),
        .o_dout11       (dut_if.o_dout11),
        .o_dout12       (dut_if.o_dout12),
        .o_dout13       (dut_if.o_dout13),
        .o_dout14       (dut_if.o_dout14),
        .o_dout15       (dut_if.o_dout15),
        .o_dout0_idx    (dut_if.o_dout0_idx),
        .o_dout1_idx    (dut_if.o_dout1_idx),
        .o_dout2_idx    (dut_if.o_dout2_idx),
        .o_dout3_idx    (dut_if.o_dout3_idx),
        .o_dout4_idx    (dut_if.o_dout4_idx),
        .o_dout5_idx    (dut_if.o_dout5_idx),
        .o_dout6_idx    (dut_if.o_dout6_idx),
        .o_dout7_idx    (dut_if.o_dout7_idx),
        .o_dout8_idx    (dut_if.o_dout8_idx),
        .o_dout9_idx    (dut_if.o_dout9_idx),
        .o_dout10_idx   (dut_if.o_dout10_idx),
        .o_dout11_idx   (dut_if.o_dout11_idx),
        .o_dout12_idx   (dut_if.o_dout12_idx),
        .o_dout13_idx   (dut_if.o_dout13_idx),
        .o_dout14_idx   (dut_if.o_dout14_idx),
        .o_dout15_idx   (dut_if.o_dout15_idx)
    );

    // -------------------------------------------------------------------------
    // SDF back-annotation
    //   +sdf       → enable SDF annotation (timing GLS)
    //   +sdf_warn  → also print SDF annotation warnings (default: suppressed)
    // -------------------------------------------------------------------------
    initial begin
        if ($test$plusargs("sdf")) begin
            $sdf_annotate(
                "/data/project/DEU/syn/netlist/deu_design.sdf",
                u_dut,
                ,               // config_file (none)
                "sdf.log",      // log file
                "MAXIMUM",      // delay type: MINIMUM / TYPICAL / MAXIMUM
                ,               // scale factor
                "FROM_MAXIMUM"  // mtm spec
            );
            $display("[GLS] SDF annotated: MAXIMUM delays");
        end else begin
            $display("[GLS] Functional mode: no SDF annotation");
        end
    end

    // -------------------------------------------------------------------------
    // Waveform dumping  (compile with -debug_access+all to enable FSDB)
    // Pass +fsdbfile=<path> at runtime to activate.
    // -------------------------------------------------------------------------
    initial begin
        string fsdb_file;
        if ($value$plusargs("fsdbfile=%s", fsdb_file)) begin
            $fsdbDumpfile(fsdb_file);
            $fsdbDumpvars(0, gls_tb_top);
            $fsdbDumpMDA();
        end
    end

    // -------------------------------------------------------------------------
    // UVM kickoff
    // -------------------------------------------------------------------------
    initial begin
        uvm_config_db #(virtual deu_if)::set(null, "uvm_test_top", "deu_vif", dut_if);
        run_test();
    end

    // -------------------------------------------------------------------------
    // Timeout watchdog (longer for timing GLS — SDF annotated sim is slower)
    // -------------------------------------------------------------------------
    initial begin
        if ($test$plusargs("sdf"))
            #500_000_000;   // 500 us @ 1ps resolution
        else
            #50_000_000_000; // 50 ms @ 1ps resolution (200 MHz functional)
        `uvm_fatal("TIMEOUT", "GLS simulation timeout")
    end

endmodule : gls_tb_top
