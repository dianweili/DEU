// =============================================================================
// Interface : deu_if
// Description: Clocking-based interface for deu_design DUT
// =============================================================================

interface deu_if (input logic clk);

    logic        rst_n;

    // Stimulus
    logic        i_data_vld;
    logic [6:0]  i_data_sliv;
    logic [19:0] i_data0_in,  i_data1_in,  i_data2_in,  i_data3_in;
    logic [19:0] i_data4_in,  i_data5_in,  i_data6_in,  i_data7_in;
    logic [19:0] i_data8_in,  i_data9_in,  i_data10_in, i_data11_in;
    logic [19:0] i_data12_in, i_data13_in, i_data14_in, i_data15_in;

    // Response
    logic [15:0] o_dout_vld;
    logic [63:0] o_dout0,  o_dout1,  o_dout2,  o_dout3;
    logic [63:0] o_dout4,  o_dout5,  o_dout6,  o_dout7;
    logic [63:0] o_dout8,  o_dout9,  o_dout10, o_dout11;
    logic [63:0] o_dout12, o_dout13, o_dout14, o_dout15;
    logic [3:0]  o_dout0_idx,  o_dout1_idx,  o_dout2_idx,  o_dout3_idx;
    logic [3:0]  o_dout4_idx,  o_dout5_idx,  o_dout6_idx,  o_dout7_idx;
    logic [3:0]  o_dout8_idx,  o_dout9_idx,  o_dout10_idx, o_dout11_idx;
    logic [3:0]  o_dout12_idx, o_dout13_idx, o_dout14_idx, o_dout15_idx;

    // Driver clocking block
    clocking drv_cb @(posedge clk);
        default input #1 output #1;
        output rst_n;
        output i_data_vld;
        output i_data_sliv;
        output i_data0_in,  i_data1_in,  i_data2_in,  i_data3_in;
        output i_data4_in,  i_data5_in,  i_data6_in,  i_data7_in;
        output i_data8_in,  i_data9_in,  i_data10_in, i_data11_in;
        output i_data12_in, i_data13_in, i_data14_in, i_data15_in;
    endclocking

    // Monitor clocking block
    clocking mon_cb @(posedge clk);
        default input #1;
        input rst_n;
        input i_data_vld;
        input i_data_sliv;
        input i_data0_in,  i_data1_in,  i_data2_in,  i_data3_in;
        input i_data4_in,  i_data5_in,  i_data6_in,  i_data7_in;
        input i_data8_in,  i_data9_in,  i_data10_in, i_data11_in;
        input i_data12_in, i_data13_in, i_data14_in, i_data15_in;
        input o_dout_vld;
        input o_dout0,  o_dout1,  o_dout2,  o_dout3;
        input o_dout4,  o_dout5,  o_dout6,  o_dout7;
        input o_dout8,  o_dout9,  o_dout10, o_dout11;
        input o_dout12, o_dout13, o_dout14, o_dout15;
        input o_dout0_idx,  o_dout1_idx,  o_dout2_idx,  o_dout3_idx;
        input o_dout4_idx,  o_dout5_idx,  o_dout6_idx,  o_dout7_idx;
        input o_dout8_idx,  o_dout9_idx,  o_dout10_idx, o_dout11_idx;
        input o_dout12_idx, o_dout13_idx, o_dout14_idx, o_dout15_idx;
    endclocking

    modport drv_mp  (clocking drv_cb, input clk);
    modport mon_mp  (clocking mon_cb, input clk);

endinterface : deu_if
