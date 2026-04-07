// =============================================================================
// Module  : deu_tb_top
// Description: UVM testbench top — instantiates DUT, interface, clock gen,
//              and kicks off the UVM test selected via +UVM_TESTNAME
// =============================================================================

`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;

// Note: deu_if.sv is included in deu_pkg.sv, so no need to include again
`include "deu_pkg.sv"

module deu_tb_top;

    // -------------------------------------------------------------------------
    // Clock generation
    // -------------------------------------------------------------------------
    logic clk;
    initial clk = 0;
    always #5 clk = ~clk;   // 100 MHz

    // -------------------------------------------------------------------------
    // Interface instance
    // -------------------------------------------------------------------------
    deu_if dut_if (.clk(clk));

    // -------------------------------------------------------------------------
    // DUT instance
    // -------------------------------------------------------------------------
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
    // Wave dumping — FSDB (Verdi) or VPD fallback
    // -------------------------------------------------------------------------
    initial begin
        string fsdb_file;
        string vpd_file;
        if ($value$plusargs("fsdbfile=%s", fsdb_file)) begin
            $fsdbDumpfile(fsdb_file);
            $fsdbDumpvars(0, deu_tb_top);
            $fsdbDumpMDA();
        end else if ($value$plusargs("vpdfile=%s", vpd_file)) begin
            $vcdplusfile(vpd_file);
            $vcdpluson(0, deu_tb_top);
        end
    end

    // -------------------------------------------------------------------------
    // Pass interface to UVM config DB and start test
    // -------------------------------------------------------------------------
    initial begin
        uvm_config_db #(virtual deu_if)::set(null, "uvm_test_top", "deu_vif", dut_if);
        run_test();
    end

    // -------------------------------------------------------------------------
    // Timeout watchdog
    // -------------------------------------------------------------------------
    initial begin
        #10_000_000;
        `uvm_fatal("TIMEOUT", "Simulation timeout at 10ms")
    end

endmodule : deu_tb_top
