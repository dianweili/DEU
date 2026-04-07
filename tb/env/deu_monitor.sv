// =============================================================================
// Class  : deu_monitor
// Description: Observes both input stimulus and output responses from deu_if.
//              Publishes two analysis ports:
//                ap_stimulus  — input item (sliv + cmp_data) per valid cycle
//                ap_response  — output item (out_vld + dout/idx) per valid out
// =============================================================================

`ifndef DEU_MONITOR_SV
`define DEU_MONITOR_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class deu_monitor extends uvm_monitor;
    `uvm_component_utils(deu_monitor)

    virtual deu_if vif;
    uvm_analysis_port #(deu_seq_item) ap_stimulus;
    uvm_analysis_port #(deu_seq_item) ap_response;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap_stimulus = new("ap_stimulus", this);
        ap_response = new("ap_response", this);
        if (!uvm_config_db #(virtual deu_if)::get(this, "", "deu_vif", vif))
            `uvm_fatal("CFG", "deu_vif not found in config_db")
    endfunction

    task run_phase(uvm_phase phase);
        fork
            monitor_stimulus();
            monitor_response();
        join
    endtask

    // -------------------------------------------------------------------------
    // Capture every cycle where i_data_vld=1 (after clocking block sample)
    // -------------------------------------------------------------------------
    task monitor_stimulus();
        deu_seq_item item;
        forever begin
            @(vif.mon_cb);
            if (vif.mon_cb.rst_n && vif.mon_cb.i_data_vld) begin
                item = deu_seq_item::type_id::create("stim");
                item.sliv         = vif.mon_cb.i_data_sliv;
                item.cmp_data[0]  = vif.mon_cb.i_data0_in;
                item.cmp_data[1]  = vif.mon_cb.i_data1_in;
                item.cmp_data[2]  = vif.mon_cb.i_data2_in;
                item.cmp_data[3]  = vif.mon_cb.i_data3_in;
                item.cmp_data[4]  = vif.mon_cb.i_data4_in;
                item.cmp_data[5]  = vif.mon_cb.i_data5_in;
                item.cmp_data[6]  = vif.mon_cb.i_data6_in;
                item.cmp_data[7]  = vif.mon_cb.i_data7_in;
                item.cmp_data[8]  = vif.mon_cb.i_data8_in;
                item.cmp_data[9]  = vif.mon_cb.i_data9_in;
                item.cmp_data[10] = vif.mon_cb.i_data10_in;
                item.cmp_data[11] = vif.mon_cb.i_data11_in;
                item.cmp_data[12] = vif.mon_cb.i_data12_in;
                item.cmp_data[13] = vif.mon_cb.i_data13_in;
                item.cmp_data[14] = vif.mon_cb.i_data14_in;
                item.cmp_data[15] = vif.mon_cb.i_data15_in;
                ap_stimulus.write(item);
            end
        end
    endtask

    // -------------------------------------------------------------------------
    // Capture every cycle where o_out_vld != 0
    // -------------------------------------------------------------------------
    task monitor_response();
        deu_seq_item item;
        forever begin
            @(vif.mon_cb);
            if (vif.mon_cb.rst_n && (|vif.mon_cb.o_out_vld)) begin
                item = deu_seq_item::type_id::create("resp");
                item.o_out_vld  = vif.mon_cb.o_out_vld;
                item.o_dout[0]  = vif.mon_cb.o_dout0;
                item.o_dout[1]  = vif.mon_cb.o_dout1;
                item.o_dout[2]  = vif.mon_cb.o_dout2;
                item.o_dout[3]  = vif.mon_cb.o_dout3;
                item.o_dout[4]  = vif.mon_cb.o_dout4;
                item.o_dout[5]  = vif.mon_cb.o_dout5;
                item.o_dout[6]  = vif.mon_cb.o_dout6;
                item.o_dout[7]  = vif.mon_cb.o_dout7;
                item.o_dout[8]  = vif.mon_cb.o_dout8;
                item.o_dout[9]  = vif.mon_cb.o_dout9;
                item.o_dout[10] = vif.mon_cb.o_dout10;
                item.o_dout[11] = vif.mon_cb.o_dout11;
                item.o_dout[12] = vif.mon_cb.o_dout12;
                item.o_dout[13] = vif.mon_cb.o_dout13;
                item.o_dout[14] = vif.mon_cb.o_dout14;
                item.o_dout[15] = vif.mon_cb.o_dout15;
                item.o_idx[0]   = vif.mon_cb.o_dout0_idx;
                item.o_idx[1]   = vif.mon_cb.o_dout1_idx;
                item.o_idx[2]   = vif.mon_cb.o_dout2_idx;
                item.o_idx[3]   = vif.mon_cb.o_dout3_idx;
                item.o_idx[4]   = vif.mon_cb.o_dout4_idx;
                item.o_idx[5]   = vif.mon_cb.o_dout5_idx;
                item.o_idx[6]   = vif.mon_cb.o_dout6_idx;
                item.o_idx[7]   = vif.mon_cb.o_dout7_idx;
                item.o_idx[8]   = vif.mon_cb.o_dout8_idx;
                item.o_idx[9]   = vif.mon_cb.o_dout9_idx;
                item.o_idx[10]  = vif.mon_cb.o_dout10_idx;
                item.o_idx[11]  = vif.mon_cb.o_dout11_idx;
                item.o_idx[12]  = vif.mon_cb.o_dout12_idx;
                item.o_idx[13]  = vif.mon_cb.o_dout13_idx;
                item.o_idx[14]  = vif.mon_cb.o_dout14_idx;
                item.o_idx[15]  = vif.mon_cb.o_dout15_idx;
                ap_response.write(item);
            end
        end
    endtask

endclass : deu_monitor

`endif // DEU_MONITOR_SV
