// =============================================================================
// Class  : deu_driver
// Description: Drives deu_seq_item stimulus onto deu_if
// =============================================================================

`ifndef DEU_DRIVER_SV
`define DEU_DRIVER_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class deu_driver extends uvm_driver #(deu_seq_item);
    `uvm_component_utils(deu_driver)

    virtual deu_if vif;
    deu_test_cfg   cfg;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual deu_if)::get(this, "", "deu_vif", vif))
            `uvm_fatal("CFG", "deu_vif not found in config_db")
        if (!uvm_config_db #(deu_test_cfg)::get(this, "", "deu_cfg", cfg))
            `uvm_fatal("CFG", "deu_cfg not found in config_db")
    endfunction

    task run_phase(uvm_phase phase);
        deu_seq_item item;
        // Idle
        vif.drv_cb.i_data_vld  <= 1'b0;
        vif.drv_cb.i_data_sliv <= 7'h0;
        drive_data_zero();
        forever begin
            seq_item_port.get_next_item(item);
            drive_item(item);
            seq_item_port.item_done();
        end
    endtask

    // Drive one transaction, respecting vld_pattern
    task drive_item(deu_seq_item item);
        // Determine whether to assert valid this cycle
        bit assert_vld;
        case (cfg.vld_pattern)
            VLD_ALWAYS_HIGH: assert_vld = 1'b1;
            VLD_TOGGLE:      assert_vld = 1'b1;  // sequence handles gaps
            VLD_RANDOM:      assert_vld = $urandom_range(0,1);
            default:         assert_vld = 1'b1;
        endcase

        @(vif.drv_cb);
        vif.drv_cb.i_data_vld   <= assert_vld;
        vif.drv_cb.i_data_sliv  <= item.sliv;
        vif.drv_cb.i_data0_in   <= item.cmp_data[0];
        vif.drv_cb.i_data1_in   <= item.cmp_data[1];
        vif.drv_cb.i_data2_in   <= item.cmp_data[2];
        vif.drv_cb.i_data3_in   <= item.cmp_data[3];
        vif.drv_cb.i_data4_in   <= item.cmp_data[4];
        vif.drv_cb.i_data5_in   <= item.cmp_data[5];
        vif.drv_cb.i_data6_in   <= item.cmp_data[6];
        vif.drv_cb.i_data7_in   <= item.cmp_data[7];
        vif.drv_cb.i_data8_in   <= item.cmp_data[8];
        vif.drv_cb.i_data9_in   <= item.cmp_data[9];
        vif.drv_cb.i_data10_in  <= item.cmp_data[10];
        vif.drv_cb.i_data11_in  <= item.cmp_data[11];
        vif.drv_cb.i_data12_in  <= item.cmp_data[12];
        vif.drv_cb.i_data13_in  <= item.cmp_data[13];
        vif.drv_cb.i_data14_in  <= item.cmp_data[14];
        vif.drv_cb.i_data15_in  <= item.cmp_data[15];
    endtask

    task drive_data_zero();
        vif.drv_cb.i_data0_in  <= '0;
        vif.drv_cb.i_data1_in  <= '0;
        vif.drv_cb.i_data2_in  <= '0;
        vif.drv_cb.i_data3_in  <= '0;
        vif.drv_cb.i_data4_in  <= '0;
        vif.drv_cb.i_data5_in  <= '0;
        vif.drv_cb.i_data6_in  <= '0;
        vif.drv_cb.i_data7_in  <= '0;
        vif.drv_cb.i_data8_in  <= '0;
        vif.drv_cb.i_data9_in  <= '0;
        vif.drv_cb.i_data10_in <= '0;
        vif.drv_cb.i_data11_in <= '0;
        vif.drv_cb.i_data12_in <= '0;
        vif.drv_cb.i_data13_in <= '0;
        vif.drv_cb.i_data14_in <= '0;
        vif.drv_cb.i_data15_in <= '0;
    endtask

endclass : deu_driver

`endif // DEU_DRIVER_SV
