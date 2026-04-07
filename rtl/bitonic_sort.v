// =============================================================================
// Module  : bitonic_sort
// Description : 16路双调排序网络，3级流水
//
// 寄存器分类：
//   带复位（async rst）: ra_vld, rb_vld, o_out_vld
//   无复位（no rst）   : 所有数据寄存器（bitmap/d*/i*/dout*/idx*），仅 vld=1 时锁存
// =============================================================================

module bitonic_sort (
    input  wire         clk,
    input  wire         rst_n,

    input  wire         i_vld,
    input  wire [15:0]  i_bitmap,
    input  wire [63:0]  i_sq0,
    input  wire [63:0]  i_sq1,
    input  wire [63:0]  i_sq2,
    input  wire [63:0]  i_sq3,
    input  wire [63:0]  i_sq4,
    input  wire [63:0]  i_sq5,
    input  wire [63:0]  i_sq6,
    input  wire [63:0]  i_sq7,
    input  wire [63:0]  i_sq8,
    input  wire [63:0]  i_sq9,
    input  wire [63:0]  i_sq10,
    input  wire [63:0]  i_sq11,
    input  wire [63:0]  i_sq12,
    input  wire [63:0]  i_sq13,
    input  wire [63:0]  i_sq14,
    input  wire [63:0]  i_sq15,
    input  wire [ 3:0]  i_idx0,
    input  wire [ 3:0]  i_idx1,
    input  wire [ 3:0]  i_idx2,
    input  wire [ 3:0]  i_idx3,
    input  wire [ 3:0]  i_idx4,
    input  wire [ 3:0]  i_idx5,
    input  wire [ 3:0]  i_idx6,
    input  wire [ 3:0]  i_idx7,
    input  wire [ 3:0]  i_idx8,
    input  wire [ 3:0]  i_idx9,
    input  wire [ 3:0]  i_idx10,
    input  wire [ 3:0]  i_idx11,
    input  wire [ 3:0]  i_idx12,
    input  wire [ 3:0]  i_idx13,
    input  wire [ 3:0]  i_idx14,
    input  wire [ 3:0]  i_idx15,

    output reg  [15:0]  o_out_vld,
    output reg  [63:0]  o_dout0,
    output reg  [63:0]  o_dout1,
    output reg  [63:0]  o_dout2,
    output reg  [63:0]  o_dout3,
    output reg  [63:0]  o_dout4,
    output reg  [63:0]  o_dout5,
    output reg  [63:0]  o_dout6,
    output reg  [63:0]  o_dout7,
    output reg  [63:0]  o_dout8,
    output reg  [63:0]  o_dout9,
    output reg  [63:0]  o_dout10,
    output reg  [63:0]  o_dout11,
    output reg  [63:0]  o_dout12,
    output reg  [63:0]  o_dout13,
    output reg  [63:0]  o_dout14,
    output reg  [63:0]  o_dout15,
    output reg  [ 3:0]  o_idx0,
    output reg  [ 3:0]  o_idx1,
    output reg  [ 3:0]  o_idx2,
    output reg  [ 3:0]  o_idx3,
    output reg  [ 3:0]  o_idx4,
    output reg  [ 3:0]  o_idx5,
    output reg  [ 3:0]  o_idx6,
    output reg  [ 3:0]  o_idx7,
    output reg  [ 3:0]  o_idx8,
    output reg  [ 3:0]  o_idx9,
    output reg  [ 3:0]  o_idx10,
    output reg  [ 3:0]  o_idx11,
    output reg  [ 3:0]  o_idx12,
    output reg  [ 3:0]  o_idx13,
    output reg  [ 3:0]  o_idx14,
    output reg  [ 3:0]  o_idx15
);

    reg  [4:0]  cnt;

    // =========================================================
    // Sort Stage 1 (Steps 1-3)
    // =========================================================
    wire [63:0] st1_in_d0;
    wire [ 3:0] st1_in_i0;
    wire [63:0] st1_in_d1;
    wire [ 3:0] st1_in_i1;
    wire [63:0] st1_in_d2;
    wire [ 3:0] st1_in_i2;
    wire [63:0] st1_in_d3;
    wire [ 3:0] st1_in_i3;
    wire [63:0] st1_in_d4;
    wire [ 3:0] st1_in_i4;
    wire [63:0] st1_in_d5;
    wire [ 3:0] st1_in_i5;
    wire [63:0] st1_in_d6;
    wire [ 3:0] st1_in_i6;
    wire [63:0] st1_in_d7;
    wire [ 3:0] st1_in_i7;
    wire [63:0] st1_in_d8;
    wire [ 3:0] st1_in_i8;
    wire [63:0] st1_in_d9;
    wire [ 3:0] st1_in_i9;
    wire [63:0] st1_in_d10;
    wire [ 3:0] st1_in_i10;
    wire [63:0] st1_in_d11;
    wire [ 3:0] st1_in_i11;
    wire [63:0] st1_in_d12;
    wire [ 3:0] st1_in_i12;
    wire [63:0] st1_in_d13;
    wire [ 3:0] st1_in_i13;
    wire [63:0] st1_in_d14;
    wire [ 3:0] st1_in_i14;
    wire [63:0] st1_in_d15;
    wire [ 3:0] st1_in_i15;

    assign st1_in_d0 = i_sq0;
    assign st1_in_i0 = i_idx0;
    assign st1_in_d1 = i_sq1;
    assign st1_in_i1 = i_idx1;
    assign st1_in_d2 = i_sq2;
    assign st1_in_i2 = i_idx2;
    assign st1_in_d3 = i_sq3;
    assign st1_in_i3 = i_idx3;
    assign st1_in_d4 = i_sq4;
    assign st1_in_i4 = i_idx4;
    assign st1_in_d5 = i_sq5;
    assign st1_in_i5 = i_idx5;
    assign st1_in_d6 = i_sq6;
    assign st1_in_i6 = i_idx6;
    assign st1_in_d7 = i_sq7;
    assign st1_in_i7 = i_idx7;
    assign st1_in_d8 = i_sq8;
    assign st1_in_i8 = i_idx8;
    assign st1_in_d9 = i_sq9;
    assign st1_in_i9 = i_idx9;
    assign st1_in_d10 = i_sq10;
    assign st1_in_i10 = i_idx10;
    assign st1_in_d11 = i_sq11;
    assign st1_in_i11 = i_idx11;
    assign st1_in_d12 = i_sq12;
    assign st1_in_i12 = i_idx12;
    assign st1_in_d13 = i_sq13;
    assign st1_in_i13 = i_idx13;
    assign st1_in_d14 = i_sq14;
    assign st1_in_i14 = i_idx14;
    assign st1_in_d15 = i_sq15;
    assign st1_in_i15 = i_idx15;

    wire [63:0] st1_out_d0;
    wire [ 3:0] st1_out_i0;
    wire [63:0] st1_out_d1;
    wire [ 3:0] st1_out_i1;
    wire [63:0] st1_out_d2;
    wire [ 3:0] st1_out_i2;
    wire [63:0] st1_out_d3;
    wire [ 3:0] st1_out_i3;
    wire [63:0] st1_out_d4;
    wire [ 3:0] st1_out_i4;
    wire [63:0] st1_out_d5;
    wire [ 3:0] st1_out_i5;
    wire [63:0] st1_out_d6;
    wire [ 3:0] st1_out_i6;
    wire [63:0] st1_out_d7;
    wire [ 3:0] st1_out_i7;
    wire [63:0] st1_out_d8;
    wire [ 3:0] st1_out_i8;
    wire [63:0] st1_out_d9;
    wire [ 3:0] st1_out_i9;
    wire [63:0] st1_out_d10;
    wire [ 3:0] st1_out_i10;
    wire [63:0] st1_out_d11;
    wire [ 3:0] st1_out_i11;
    wire [63:0] st1_out_d12;
    wire [ 3:0] st1_out_i12;
    wire [63:0] st1_out_d13;
    wire [ 3:0] st1_out_i13;
    wire [63:0] st1_out_d14;
    wire [ 3:0] st1_out_i14;
    wire [63:0] st1_out_d15;
    wire [ 3:0] st1_out_i15;

    wire [63:0] st1_s1_d0;
    wire [ 3:0] st1_s1_i0;
    wire [63:0] st1_s1_d1;
    wire [ 3:0] st1_s1_i1;
    wire [63:0] st1_s1_d2;
    wire [ 3:0] st1_s1_i2;
    wire [63:0] st1_s1_d3;
    wire [ 3:0] st1_s1_i3;
    wire [63:0] st1_s1_d4;
    wire [ 3:0] st1_s1_i4;
    wire [63:0] st1_s1_d5;
    wire [ 3:0] st1_s1_i5;
    wire [63:0] st1_s1_d6;
    wire [ 3:0] st1_s1_i6;
    wire [63:0] st1_s1_d7;
    wire [ 3:0] st1_s1_i7;
    wire [63:0] st1_s1_d8;
    wire [ 3:0] st1_s1_i8;
    wire [63:0] st1_s1_d9;
    wire [ 3:0] st1_s1_i9;
    wire [63:0] st1_s1_d10;
    wire [ 3:0] st1_s1_i10;
    wire [63:0] st1_s1_d11;
    wire [ 3:0] st1_s1_i11;
    wire [63:0] st1_s1_d12;
    wire [ 3:0] st1_s1_i12;
    wire [63:0] st1_s1_d13;
    wire [ 3:0] st1_s1_i13;
    wire [63:0] st1_s1_d14;
    wire [ 3:0] st1_s1_i14;
    wire [63:0] st1_s1_d15;
    wire [ 3:0] st1_s1_i15;

    compare_swap u_cs_st1_s1_0_1 (
        .din_a (st1_in_d0), .idx_a (st1_in_i0),
        .din_b (st1_in_d1), .idx_b (st1_in_i1),
        .dir   (1'b0),
        .dout_lo(st1_s1_d0), .idx_lo(st1_s1_i0),
        .dout_hi(st1_s1_d1), .idx_hi(st1_s1_i1)
    );
    compare_swap u_cs_st1_s1_2_3 (
        .din_a (st1_in_d2), .idx_a (st1_in_i2),
        .din_b (st1_in_d3), .idx_b (st1_in_i3),
        .dir   (1'b1),
        .dout_lo(st1_s1_d2), .idx_lo(st1_s1_i2),
        .dout_hi(st1_s1_d3), .idx_hi(st1_s1_i3)
    );
    compare_swap u_cs_st1_s1_4_5 (
        .din_a (st1_in_d4), .idx_a (st1_in_i4),
        .din_b (st1_in_d5), .idx_b (st1_in_i5),
        .dir   (1'b0),
        .dout_lo(st1_s1_d4), .idx_lo(st1_s1_i4),
        .dout_hi(st1_s1_d5), .idx_hi(st1_s1_i5)
    );
    compare_swap u_cs_st1_s1_6_7 (
        .din_a (st1_in_d6), .idx_a (st1_in_i6),
        .din_b (st1_in_d7), .idx_b (st1_in_i7),
        .dir   (1'b1),
        .dout_lo(st1_s1_d6), .idx_lo(st1_s1_i6),
        .dout_hi(st1_s1_d7), .idx_hi(st1_s1_i7)
    );
    compare_swap u_cs_st1_s1_8_9 (
        .din_a (st1_in_d8), .idx_a (st1_in_i8),
        .din_b (st1_in_d9), .idx_b (st1_in_i9),
        .dir   (1'b0),
        .dout_lo(st1_s1_d8), .idx_lo(st1_s1_i8),
        .dout_hi(st1_s1_d9), .idx_hi(st1_s1_i9)
    );
    compare_swap u_cs_st1_s1_10_11 (
        .din_a (st1_in_d10), .idx_a (st1_in_i10),
        .din_b (st1_in_d11), .idx_b (st1_in_i11),
        .dir   (1'b1),
        .dout_lo(st1_s1_d10), .idx_lo(st1_s1_i10),
        .dout_hi(st1_s1_d11), .idx_hi(st1_s1_i11)
    );
    compare_swap u_cs_st1_s1_12_13 (
        .din_a (st1_in_d12), .idx_a (st1_in_i12),
        .din_b (st1_in_d13), .idx_b (st1_in_i13),
        .dir   (1'b0),
        .dout_lo(st1_s1_d12), .idx_lo(st1_s1_i12),
        .dout_hi(st1_s1_d13), .idx_hi(st1_s1_i13)
    );
    compare_swap u_cs_st1_s1_14_15 (
        .din_a (st1_in_d14), .idx_a (st1_in_i14),
        .din_b (st1_in_d15), .idx_b (st1_in_i15),
        .dir   (1'b1),
        .dout_lo(st1_s1_d14), .idx_lo(st1_s1_i14),
        .dout_hi(st1_s1_d15), .idx_hi(st1_s1_i15)
    );

    wire [63:0] st1_s2_d0;
    wire [ 3:0] st1_s2_i0;
    wire [63:0] st1_s2_d1;
    wire [ 3:0] st1_s2_i1;
    wire [63:0] st1_s2_d2;
    wire [ 3:0] st1_s2_i2;
    wire [63:0] st1_s2_d3;
    wire [ 3:0] st1_s2_i3;
    wire [63:0] st1_s2_d4;
    wire [ 3:0] st1_s2_i4;
    wire [63:0] st1_s2_d5;
    wire [ 3:0] st1_s2_i5;
    wire [63:0] st1_s2_d6;
    wire [ 3:0] st1_s2_i6;
    wire [63:0] st1_s2_d7;
    wire [ 3:0] st1_s2_i7;
    wire [63:0] st1_s2_d8;
    wire [ 3:0] st1_s2_i8;
    wire [63:0] st1_s2_d9;
    wire [ 3:0] st1_s2_i9;
    wire [63:0] st1_s2_d10;
    wire [ 3:0] st1_s2_i10;
    wire [63:0] st1_s2_d11;
    wire [ 3:0] st1_s2_i11;
    wire [63:0] st1_s2_d12;
    wire [ 3:0] st1_s2_i12;
    wire [63:0] st1_s2_d13;
    wire [ 3:0] st1_s2_i13;
    wire [63:0] st1_s2_d14;
    wire [ 3:0] st1_s2_i14;
    wire [63:0] st1_s2_d15;
    wire [ 3:0] st1_s2_i15;

    compare_swap u_cs_st1_s2_0_2 (
        .din_a (st1_s1_d0), .idx_a (st1_s1_i0),
        .din_b (st1_s1_d2), .idx_b (st1_s1_i2),
        .dir   (1'b0),
        .dout_lo(st1_s2_d0), .idx_lo(st1_s2_i0),
        .dout_hi(st1_s2_d2), .idx_hi(st1_s2_i2)
    );
    compare_swap u_cs_st1_s2_1_3 (
        .din_a (st1_s1_d1), .idx_a (st1_s1_i1),
        .din_b (st1_s1_d3), .idx_b (st1_s1_i3),
        .dir   (1'b0),
        .dout_lo(st1_s2_d1), .idx_lo(st1_s2_i1),
        .dout_hi(st1_s2_d3), .idx_hi(st1_s2_i3)
    );
    compare_swap u_cs_st1_s2_4_6 (
        .din_a (st1_s1_d4), .idx_a (st1_s1_i4),
        .din_b (st1_s1_d6), .idx_b (st1_s1_i6),
        .dir   (1'b1),
        .dout_lo(st1_s2_d4), .idx_lo(st1_s2_i4),
        .dout_hi(st1_s2_d6), .idx_hi(st1_s2_i6)
    );
    compare_swap u_cs_st1_s2_5_7 (
        .din_a (st1_s1_d5), .idx_a (st1_s1_i5),
        .din_b (st1_s1_d7), .idx_b (st1_s1_i7),
        .dir   (1'b1),
        .dout_lo(st1_s2_d5), .idx_lo(st1_s2_i5),
        .dout_hi(st1_s2_d7), .idx_hi(st1_s2_i7)
    );
    compare_swap u_cs_st1_s2_8_10 (
        .din_a (st1_s1_d8), .idx_a (st1_s1_i8),
        .din_b (st1_s1_d10), .idx_b (st1_s1_i10),
        .dir   (1'b0),
        .dout_lo(st1_s2_d8), .idx_lo(st1_s2_i8),
        .dout_hi(st1_s2_d10), .idx_hi(st1_s2_i10)
    );
    compare_swap u_cs_st1_s2_9_11 (
        .din_a (st1_s1_d9), .idx_a (st1_s1_i9),
        .din_b (st1_s1_d11), .idx_b (st1_s1_i11),
        .dir   (1'b0),
        .dout_lo(st1_s2_d9), .idx_lo(st1_s2_i9),
        .dout_hi(st1_s2_d11), .idx_hi(st1_s2_i11)
    );
    compare_swap u_cs_st1_s2_12_14 (
        .din_a (st1_s1_d12), .idx_a (st1_s1_i12),
        .din_b (st1_s1_d14), .idx_b (st1_s1_i14),
        .dir   (1'b1),
        .dout_lo(st1_s2_d12), .idx_lo(st1_s2_i12),
        .dout_hi(st1_s2_d14), .idx_hi(st1_s2_i14)
    );
    compare_swap u_cs_st1_s2_13_15 (
        .din_a (st1_s1_d13), .idx_a (st1_s1_i13),
        .din_b (st1_s1_d15), .idx_b (st1_s1_i15),
        .dir   (1'b1),
        .dout_lo(st1_s2_d13), .idx_lo(st1_s2_i13),
        .dout_hi(st1_s2_d15), .idx_hi(st1_s2_i15)
    );

    compare_swap u_cs_st1_s3_0_1 (
        .din_a (st1_s2_d0), .idx_a (st1_s2_i0),
        .din_b (st1_s2_d1), .idx_b (st1_s2_i1),
        .dir   (1'b0),
        .dout_lo(st1_out_d0), .idx_lo(st1_out_i0),
        .dout_hi(st1_out_d1), .idx_hi(st1_out_i1)
    );
    compare_swap u_cs_st1_s3_2_3 (
        .din_a (st1_s2_d2), .idx_a (st1_s2_i2),
        .din_b (st1_s2_d3), .idx_b (st1_s2_i3),
        .dir   (1'b0),
        .dout_lo(st1_out_d2), .idx_lo(st1_out_i2),
        .dout_hi(st1_out_d3), .idx_hi(st1_out_i3)
    );
    compare_swap u_cs_st1_s3_4_5 (
        .din_a (st1_s2_d4), .idx_a (st1_s2_i4),
        .din_b (st1_s2_d5), .idx_b (st1_s2_i5),
        .dir   (1'b1),
        .dout_lo(st1_out_d4), .idx_lo(st1_out_i4),
        .dout_hi(st1_out_d5), .idx_hi(st1_out_i5)
    );
    compare_swap u_cs_st1_s3_6_7 (
        .din_a (st1_s2_d6), .idx_a (st1_s2_i6),
        .din_b (st1_s2_d7), .idx_b (st1_s2_i7),
        .dir   (1'b1),
        .dout_lo(st1_out_d6), .idx_lo(st1_out_i6),
        .dout_hi(st1_out_d7), .idx_hi(st1_out_i7)
    );
    compare_swap u_cs_st1_s3_8_9 (
        .din_a (st1_s2_d8), .idx_a (st1_s2_i8),
        .din_b (st1_s2_d9), .idx_b (st1_s2_i9),
        .dir   (1'b0),
        .dout_lo(st1_out_d8), .idx_lo(st1_out_i8),
        .dout_hi(st1_out_d9), .idx_hi(st1_out_i9)
    );
    compare_swap u_cs_st1_s3_10_11 (
        .din_a (st1_s2_d10), .idx_a (st1_s2_i10),
        .din_b (st1_s2_d11), .idx_b (st1_s2_i11),
        .dir   (1'b0),
        .dout_lo(st1_out_d10), .idx_lo(st1_out_i10),
        .dout_hi(st1_out_d11), .idx_hi(st1_out_i11)
    );
    compare_swap u_cs_st1_s3_12_13 (
        .din_a (st1_s2_d12), .idx_a (st1_s2_i12),
        .din_b (st1_s2_d13), .idx_b (st1_s2_i13),
        .dir   (1'b1),
        .dout_lo(st1_out_d12), .idx_lo(st1_out_i12),
        .dout_hi(st1_out_d13), .idx_hi(st1_out_i13)
    );
    compare_swap u_cs_st1_s3_14_15 (
        .din_a (st1_s2_d14), .idx_a (st1_s2_i14),
        .din_b (st1_s2_d15), .idx_b (st1_s2_i15),
        .dir   (1'b1),
        .dout_lo(st1_out_d14), .idx_lo(st1_out_i14),
        .dout_hi(st1_out_d15), .idx_hi(st1_out_i15)
    );

    // =========================================================
    // Pipeline Register A
    // =========================================================
    reg         ra_vld;
    reg [15:0]  ra_bitmap;
    reg [63:0]  ra_d0;
    reg [ 3:0]  ra_i0;
    reg [63:0]  ra_d1;
    reg [ 3:0]  ra_i1;
    reg [63:0]  ra_d2;
    reg [ 3:0]  ra_i2;
    reg [63:0]  ra_d3;
    reg [ 3:0]  ra_i3;
    reg [63:0]  ra_d4;
    reg [ 3:0]  ra_i4;
    reg [63:0]  ra_d5;
    reg [ 3:0]  ra_i5;
    reg [63:0]  ra_d6;
    reg [ 3:0]  ra_i6;
    reg [63:0]  ra_d7;
    reg [ 3:0]  ra_i7;
    reg [63:0]  ra_d8;
    reg [ 3:0]  ra_i8;
    reg [63:0]  ra_d9;
    reg [ 3:0]  ra_i9;
    reg [63:0]  ra_d10;
    reg [ 3:0]  ra_i10;
    reg [63:0]  ra_d11;
    reg [ 3:0]  ra_i11;
    reg [63:0]  ra_d12;
    reg [ 3:0]  ra_i12;
    reg [63:0]  ra_d13;
    reg [ 3:0]  ra_i13;
    reg [63:0]  ra_d14;
    reg [ 3:0]  ra_i14;
    reg [63:0]  ra_d15;
    reg [ 3:0]  ra_i15;

    // 带复位：vld
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) ra_vld <= 1'b0;
        else        ra_vld <= i_vld;
    end

    // 无复位：数据，仅 i_vld=1 时锁存
    always @(posedge clk) begin
        if (i_vld) begin
            ra_bitmap <= i_bitmap;
            ra_d0 <= st1_out_d0;
            ra_i0 <= st1_out_i0;
            ra_d1 <= st1_out_d1;
            ra_i1 <= st1_out_i1;
            ra_d2 <= st1_out_d2;
            ra_i2 <= st1_out_i2;
            ra_d3 <= st1_out_d3;
            ra_i3 <= st1_out_i3;
            ra_d4 <= st1_out_d4;
            ra_i4 <= st1_out_i4;
            ra_d5 <= st1_out_d5;
            ra_i5 <= st1_out_i5;
            ra_d6 <= st1_out_d6;
            ra_i6 <= st1_out_i6;
            ra_d7 <= st1_out_d7;
            ra_i7 <= st1_out_i7;
            ra_d8 <= st1_out_d8;
            ra_i8 <= st1_out_i8;
            ra_d9 <= st1_out_d9;
            ra_i9 <= st1_out_i9;
            ra_d10 <= st1_out_d10;
            ra_i10 <= st1_out_i10;
            ra_d11 <= st1_out_d11;
            ra_i11 <= st1_out_i11;
            ra_d12 <= st1_out_d12;
            ra_i12 <= st1_out_i12;
            ra_d13 <= st1_out_d13;
            ra_i13 <= st1_out_i13;
            ra_d14 <= st1_out_d14;
            ra_i14 <= st1_out_i14;
            ra_d15 <= st1_out_d15;
            ra_i15 <= st1_out_i15;
        end
    end

    // =========================================================
    // Sort Stage 2 (Steps 4-6)
    // =========================================================
    wire [63:0] st2_in_d0;
    wire [ 3:0] st2_in_i0;
    wire [63:0] st2_in_d1;
    wire [ 3:0] st2_in_i1;
    wire [63:0] st2_in_d2;
    wire [ 3:0] st2_in_i2;
    wire [63:0] st2_in_d3;
    wire [ 3:0] st2_in_i3;
    wire [63:0] st2_in_d4;
    wire [ 3:0] st2_in_i4;
    wire [63:0] st2_in_d5;
    wire [ 3:0] st2_in_i5;
    wire [63:0] st2_in_d6;
    wire [ 3:0] st2_in_i6;
    wire [63:0] st2_in_d7;
    wire [ 3:0] st2_in_i7;
    wire [63:0] st2_in_d8;
    wire [ 3:0] st2_in_i8;
    wire [63:0] st2_in_d9;
    wire [ 3:0] st2_in_i9;
    wire [63:0] st2_in_d10;
    wire [ 3:0] st2_in_i10;
    wire [63:0] st2_in_d11;
    wire [ 3:0] st2_in_i11;
    wire [63:0] st2_in_d12;
    wire [ 3:0] st2_in_i12;
    wire [63:0] st2_in_d13;
    wire [ 3:0] st2_in_i13;
    wire [63:0] st2_in_d14;
    wire [ 3:0] st2_in_i14;
    wire [63:0] st2_in_d15;
    wire [ 3:0] st2_in_i15;

    assign st2_in_d0 = ra_d0;
    assign st2_in_i0 = ra_i0;
    assign st2_in_d1 = ra_d1;
    assign st2_in_i1 = ra_i1;
    assign st2_in_d2 = ra_d2;
    assign st2_in_i2 = ra_i2;
    assign st2_in_d3 = ra_d3;
    assign st2_in_i3 = ra_i3;
    assign st2_in_d4 = ra_d4;
    assign st2_in_i4 = ra_i4;
    assign st2_in_d5 = ra_d5;
    assign st2_in_i5 = ra_i5;
    assign st2_in_d6 = ra_d6;
    assign st2_in_i6 = ra_i6;
    assign st2_in_d7 = ra_d7;
    assign st2_in_i7 = ra_i7;
    assign st2_in_d8 = ra_d8;
    assign st2_in_i8 = ra_i8;
    assign st2_in_d9 = ra_d9;
    assign st2_in_i9 = ra_i9;
    assign st2_in_d10 = ra_d10;
    assign st2_in_i10 = ra_i10;
    assign st2_in_d11 = ra_d11;
    assign st2_in_i11 = ra_i11;
    assign st2_in_d12 = ra_d12;
    assign st2_in_i12 = ra_i12;
    assign st2_in_d13 = ra_d13;
    assign st2_in_i13 = ra_i13;
    assign st2_in_d14 = ra_d14;
    assign st2_in_i14 = ra_i14;
    assign st2_in_d15 = ra_d15;
    assign st2_in_i15 = ra_i15;

    wire [63:0] st2_out_d0;
    wire [ 3:0] st2_out_i0;
    wire [63:0] st2_out_d1;
    wire [ 3:0] st2_out_i1;
    wire [63:0] st2_out_d2;
    wire [ 3:0] st2_out_i2;
    wire [63:0] st2_out_d3;
    wire [ 3:0] st2_out_i3;
    wire [63:0] st2_out_d4;
    wire [ 3:0] st2_out_i4;
    wire [63:0] st2_out_d5;
    wire [ 3:0] st2_out_i5;
    wire [63:0] st2_out_d6;
    wire [ 3:0] st2_out_i6;
    wire [63:0] st2_out_d7;
    wire [ 3:0] st2_out_i7;
    wire [63:0] st2_out_d8;
    wire [ 3:0] st2_out_i8;
    wire [63:0] st2_out_d9;
    wire [ 3:0] st2_out_i9;
    wire [63:0] st2_out_d10;
    wire [ 3:0] st2_out_i10;
    wire [63:0] st2_out_d11;
    wire [ 3:0] st2_out_i11;
    wire [63:0] st2_out_d12;
    wire [ 3:0] st2_out_i12;
    wire [63:0] st2_out_d13;
    wire [ 3:0] st2_out_i13;
    wire [63:0] st2_out_d14;
    wire [ 3:0] st2_out_i14;
    wire [63:0] st2_out_d15;
    wire [ 3:0] st2_out_i15;

    wire [63:0] st2_s1_d0;
    wire [ 3:0] st2_s1_i0;
    wire [63:0] st2_s1_d1;
    wire [ 3:0] st2_s1_i1;
    wire [63:0] st2_s1_d2;
    wire [ 3:0] st2_s1_i2;
    wire [63:0] st2_s1_d3;
    wire [ 3:0] st2_s1_i3;
    wire [63:0] st2_s1_d4;
    wire [ 3:0] st2_s1_i4;
    wire [63:0] st2_s1_d5;
    wire [ 3:0] st2_s1_i5;
    wire [63:0] st2_s1_d6;
    wire [ 3:0] st2_s1_i6;
    wire [63:0] st2_s1_d7;
    wire [ 3:0] st2_s1_i7;
    wire [63:0] st2_s1_d8;
    wire [ 3:0] st2_s1_i8;
    wire [63:0] st2_s1_d9;
    wire [ 3:0] st2_s1_i9;
    wire [63:0] st2_s1_d10;
    wire [ 3:0] st2_s1_i10;
    wire [63:0] st2_s1_d11;
    wire [ 3:0] st2_s1_i11;
    wire [63:0] st2_s1_d12;
    wire [ 3:0] st2_s1_i12;
    wire [63:0] st2_s1_d13;
    wire [ 3:0] st2_s1_i13;
    wire [63:0] st2_s1_d14;
    wire [ 3:0] st2_s1_i14;
    wire [63:0] st2_s1_d15;
    wire [ 3:0] st2_s1_i15;

    compare_swap u_cs_st2_s1_0_4 (
        .din_a (st2_in_d0), .idx_a (st2_in_i0),
        .din_b (st2_in_d4), .idx_b (st2_in_i4),
        .dir   (1'b0),
        .dout_lo(st2_s1_d0), .idx_lo(st2_s1_i0),
        .dout_hi(st2_s1_d4), .idx_hi(st2_s1_i4)
    );
    compare_swap u_cs_st2_s1_1_5 (
        .din_a (st2_in_d1), .idx_a (st2_in_i1),
        .din_b (st2_in_d5), .idx_b (st2_in_i5),
        .dir   (1'b0),
        .dout_lo(st2_s1_d1), .idx_lo(st2_s1_i1),
        .dout_hi(st2_s1_d5), .idx_hi(st2_s1_i5)
    );
    compare_swap u_cs_st2_s1_2_6 (
        .din_a (st2_in_d2), .idx_a (st2_in_i2),
        .din_b (st2_in_d6), .idx_b (st2_in_i6),
        .dir   (1'b0),
        .dout_lo(st2_s1_d2), .idx_lo(st2_s1_i2),
        .dout_hi(st2_s1_d6), .idx_hi(st2_s1_i6)
    );
    compare_swap u_cs_st2_s1_3_7 (
        .din_a (st2_in_d3), .idx_a (st2_in_i3),
        .din_b (st2_in_d7), .idx_b (st2_in_i7),
        .dir   (1'b0),
        .dout_lo(st2_s1_d3), .idx_lo(st2_s1_i3),
        .dout_hi(st2_s1_d7), .idx_hi(st2_s1_i7)
    );
    compare_swap u_cs_st2_s1_8_12 (
        .din_a (st2_in_d8), .idx_a (st2_in_i8),
        .din_b (st2_in_d12), .idx_b (st2_in_i12),
        .dir   (1'b1),
        .dout_lo(st2_s1_d8), .idx_lo(st2_s1_i8),
        .dout_hi(st2_s1_d12), .idx_hi(st2_s1_i12)
    );
    compare_swap u_cs_st2_s1_9_13 (
        .din_a (st2_in_d9), .idx_a (st2_in_i9),
        .din_b (st2_in_d13), .idx_b (st2_in_i13),
        .dir   (1'b1),
        .dout_lo(st2_s1_d9), .idx_lo(st2_s1_i9),
        .dout_hi(st2_s1_d13), .idx_hi(st2_s1_i13)
    );
    compare_swap u_cs_st2_s1_10_14 (
        .din_a (st2_in_d10), .idx_a (st2_in_i10),
        .din_b (st2_in_d14), .idx_b (st2_in_i14),
        .dir   (1'b1),
        .dout_lo(st2_s1_d10), .idx_lo(st2_s1_i10),
        .dout_hi(st2_s1_d14), .idx_hi(st2_s1_i14)
    );
    compare_swap u_cs_st2_s1_11_15 (
        .din_a (st2_in_d11), .idx_a (st2_in_i11),
        .din_b (st2_in_d15), .idx_b (st2_in_i15),
        .dir   (1'b1),
        .dout_lo(st2_s1_d11), .idx_lo(st2_s1_i11),
        .dout_hi(st2_s1_d15), .idx_hi(st2_s1_i15)
    );

    wire [63:0] st2_s2_d0;
    wire [ 3:0] st2_s2_i0;
    wire [63:0] st2_s2_d1;
    wire [ 3:0] st2_s2_i1;
    wire [63:0] st2_s2_d2;
    wire [ 3:0] st2_s2_i2;
    wire [63:0] st2_s2_d3;
    wire [ 3:0] st2_s2_i3;
    wire [63:0] st2_s2_d4;
    wire [ 3:0] st2_s2_i4;
    wire [63:0] st2_s2_d5;
    wire [ 3:0] st2_s2_i5;
    wire [63:0] st2_s2_d6;
    wire [ 3:0] st2_s2_i6;
    wire [63:0] st2_s2_d7;
    wire [ 3:0] st2_s2_i7;
    wire [63:0] st2_s2_d8;
    wire [ 3:0] st2_s2_i8;
    wire [63:0] st2_s2_d9;
    wire [ 3:0] st2_s2_i9;
    wire [63:0] st2_s2_d10;
    wire [ 3:0] st2_s2_i10;
    wire [63:0] st2_s2_d11;
    wire [ 3:0] st2_s2_i11;
    wire [63:0] st2_s2_d12;
    wire [ 3:0] st2_s2_i12;
    wire [63:0] st2_s2_d13;
    wire [ 3:0] st2_s2_i13;
    wire [63:0] st2_s2_d14;
    wire [ 3:0] st2_s2_i14;
    wire [63:0] st2_s2_d15;
    wire [ 3:0] st2_s2_i15;

    compare_swap u_cs_st2_s2_0_2 (
        .din_a (st2_s1_d0), .idx_a (st2_s1_i0),
        .din_b (st2_s1_d2), .idx_b (st2_s1_i2),
        .dir   (1'b0),
        .dout_lo(st2_s2_d0), .idx_lo(st2_s2_i0),
        .dout_hi(st2_s2_d2), .idx_hi(st2_s2_i2)
    );
    compare_swap u_cs_st2_s2_1_3 (
        .din_a (st2_s1_d1), .idx_a (st2_s1_i1),
        .din_b (st2_s1_d3), .idx_b (st2_s1_i3),
        .dir   (1'b0),
        .dout_lo(st2_s2_d1), .idx_lo(st2_s2_i1),
        .dout_hi(st2_s2_d3), .idx_hi(st2_s2_i3)
    );
    compare_swap u_cs_st2_s2_4_6 (
        .din_a (st2_s1_d4), .idx_a (st2_s1_i4),
        .din_b (st2_s1_d6), .idx_b (st2_s1_i6),
        .dir   (1'b0),
        .dout_lo(st2_s2_d4), .idx_lo(st2_s2_i4),
        .dout_hi(st2_s2_d6), .idx_hi(st2_s2_i6)
    );
    compare_swap u_cs_st2_s2_5_7 (
        .din_a (st2_s1_d5), .idx_a (st2_s1_i5),
        .din_b (st2_s1_d7), .idx_b (st2_s1_i7),
        .dir   (1'b0),
        .dout_lo(st2_s2_d5), .idx_lo(st2_s2_i5),
        .dout_hi(st2_s2_d7), .idx_hi(st2_s2_i7)
    );
    compare_swap u_cs_st2_s2_8_10 (
        .din_a (st2_s1_d8), .idx_a (st2_s1_i8),
        .din_b (st2_s1_d10), .idx_b (st2_s1_i10),
        .dir   (1'b1),
        .dout_lo(st2_s2_d8), .idx_lo(st2_s2_i8),
        .dout_hi(st2_s2_d10), .idx_hi(st2_s2_i10)
    );
    compare_swap u_cs_st2_s2_9_11 (
        .din_a (st2_s1_d9), .idx_a (st2_s1_i9),
        .din_b (st2_s1_d11), .idx_b (st2_s1_i11),
        .dir   (1'b1),
        .dout_lo(st2_s2_d9), .idx_lo(st2_s2_i9),
        .dout_hi(st2_s2_d11), .idx_hi(st2_s2_i11)
    );
    compare_swap u_cs_st2_s2_12_14 (
        .din_a (st2_s1_d12), .idx_a (st2_s1_i12),
        .din_b (st2_s1_d14), .idx_b (st2_s1_i14),
        .dir   (1'b1),
        .dout_lo(st2_s2_d12), .idx_lo(st2_s2_i12),
        .dout_hi(st2_s2_d14), .idx_hi(st2_s2_i14)
    );
    compare_swap u_cs_st2_s2_13_15 (
        .din_a (st2_s1_d13), .idx_a (st2_s1_i13),
        .din_b (st2_s1_d15), .idx_b (st2_s1_i15),
        .dir   (1'b1),
        .dout_lo(st2_s2_d13), .idx_lo(st2_s2_i13),
        .dout_hi(st2_s2_d15), .idx_hi(st2_s2_i15)
    );

    compare_swap u_cs_st2_s3_0_1 (
        .din_a (st2_s2_d0), .idx_a (st2_s2_i0),
        .din_b (st2_s2_d1), .idx_b (st2_s2_i1),
        .dir   (1'b0),
        .dout_lo(st2_out_d0), .idx_lo(st2_out_i0),
        .dout_hi(st2_out_d1), .idx_hi(st2_out_i1)
    );
    compare_swap u_cs_st2_s3_2_3 (
        .din_a (st2_s2_d2), .idx_a (st2_s2_i2),
        .din_b (st2_s2_d3), .idx_b (st2_s2_i3),
        .dir   (1'b0),
        .dout_lo(st2_out_d2), .idx_lo(st2_out_i2),
        .dout_hi(st2_out_d3), .idx_hi(st2_out_i3)
    );
    compare_swap u_cs_st2_s3_4_5 (
        .din_a (st2_s2_d4), .idx_a (st2_s2_i4),
        .din_b (st2_s2_d5), .idx_b (st2_s2_i5),
        .dir   (1'b0),
        .dout_lo(st2_out_d4), .idx_lo(st2_out_i4),
        .dout_hi(st2_out_d5), .idx_hi(st2_out_i5)
    );
    compare_swap u_cs_st2_s3_6_7 (
        .din_a (st2_s2_d6), .idx_a (st2_s2_i6),
        .din_b (st2_s2_d7), .idx_b (st2_s2_i7),
        .dir   (1'b0),
        .dout_lo(st2_out_d6), .idx_lo(st2_out_i6),
        .dout_hi(st2_out_d7), .idx_hi(st2_out_i7)
    );
    compare_swap u_cs_st2_s3_8_9 (
        .din_a (st2_s2_d8), .idx_a (st2_s2_i8),
        .din_b (st2_s2_d9), .idx_b (st2_s2_i9),
        .dir   (1'b1),
        .dout_lo(st2_out_d8), .idx_lo(st2_out_i8),
        .dout_hi(st2_out_d9), .idx_hi(st2_out_i9)
    );
    compare_swap u_cs_st2_s3_10_11 (
        .din_a (st2_s2_d10), .idx_a (st2_s2_i10),
        .din_b (st2_s2_d11), .idx_b (st2_s2_i11),
        .dir   (1'b1),
        .dout_lo(st2_out_d10), .idx_lo(st2_out_i10),
        .dout_hi(st2_out_d11), .idx_hi(st2_out_i11)
    );
    compare_swap u_cs_st2_s3_12_13 (
        .din_a (st2_s2_d12), .idx_a (st2_s2_i12),
        .din_b (st2_s2_d13), .idx_b (st2_s2_i13),
        .dir   (1'b1),
        .dout_lo(st2_out_d12), .idx_lo(st2_out_i12),
        .dout_hi(st2_out_d13), .idx_hi(st2_out_i13)
    );
    compare_swap u_cs_st2_s3_14_15 (
        .din_a (st2_s2_d14), .idx_a (st2_s2_i14),
        .din_b (st2_s2_d15), .idx_b (st2_s2_i15),
        .dir   (1'b1),
        .dout_lo(st2_out_d14), .idx_lo(st2_out_i14),
        .dout_hi(st2_out_d15), .idx_hi(st2_out_i15)
    );

    // =========================================================
    // Pipeline Register B
    // =========================================================
    reg         rb_vld;
    reg [15:0]  rb_bitmap;
    reg [63:0]  rb_d0;
    reg [ 3:0]  rb_i0;
    reg [63:0]  rb_d1;
    reg [ 3:0]  rb_i1;
    reg [63:0]  rb_d2;
    reg [ 3:0]  rb_i2;
    reg [63:0]  rb_d3;
    reg [ 3:0]  rb_i3;
    reg [63:0]  rb_d4;
    reg [ 3:0]  rb_i4;
    reg [63:0]  rb_d5;
    reg [ 3:0]  rb_i5;
    reg [63:0]  rb_d6;
    reg [ 3:0]  rb_i6;
    reg [63:0]  rb_d7;
    reg [ 3:0]  rb_i7;
    reg [63:0]  rb_d8;
    reg [ 3:0]  rb_i8;
    reg [63:0]  rb_d9;
    reg [ 3:0]  rb_i9;
    reg [63:0]  rb_d10;
    reg [ 3:0]  rb_i10;
    reg [63:0]  rb_d11;
    reg [ 3:0]  rb_i11;
    reg [63:0]  rb_d12;
    reg [ 3:0]  rb_i12;
    reg [63:0]  rb_d13;
    reg [ 3:0]  rb_i13;
    reg [63:0]  rb_d14;
    reg [ 3:0]  rb_i14;
    reg [63:0]  rb_d15;
    reg [ 3:0]  rb_i15;

    // 带复位：vld
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) rb_vld <= 1'b0;
        else        rb_vld <= ra_vld;
    end

    // 无复位：数据，仅 ra_vld=1 时锁存
    always @(posedge clk) begin
        if (ra_vld) begin
            rb_bitmap <= ra_bitmap;
            rb_d0 <= st2_out_d0;
            rb_i0 <= st2_out_i0;
            rb_d1 <= st2_out_d1;
            rb_i1 <= st2_out_i1;
            rb_d2 <= st2_out_d2;
            rb_i2 <= st2_out_i2;
            rb_d3 <= st2_out_d3;
            rb_i3 <= st2_out_i3;
            rb_d4 <= st2_out_d4;
            rb_i4 <= st2_out_i4;
            rb_d5 <= st2_out_d5;
            rb_i5 <= st2_out_i5;
            rb_d6 <= st2_out_d6;
            rb_i6 <= st2_out_i6;
            rb_d7 <= st2_out_d7;
            rb_i7 <= st2_out_i7;
            rb_d8 <= st2_out_d8;
            rb_i8 <= st2_out_i8;
            rb_d9 <= st2_out_d9;
            rb_i9 <= st2_out_i9;
            rb_d10 <= st2_out_d10;
            rb_i10 <= st2_out_i10;
            rb_d11 <= st2_out_d11;
            rb_i11 <= st2_out_i11;
            rb_d12 <= st2_out_d12;
            rb_i12 <= st2_out_i12;
            rb_d13 <= st2_out_d13;
            rb_i13 <= st2_out_i13;
            rb_d14 <= st2_out_d14;
            rb_i14 <= st2_out_i14;
            rb_d15 <= st2_out_d15;
            rb_i15 <= st2_out_i15;
        end
    end

    // =========================================================
    // Sort Stage 3 (Steps 7-10)
    // =========================================================
    wire [63:0] st3_in_d0;
    wire [ 3:0] st3_in_i0;
    wire [63:0] st3_in_d1;
    wire [ 3:0] st3_in_i1;
    wire [63:0] st3_in_d2;
    wire [ 3:0] st3_in_i2;
    wire [63:0] st3_in_d3;
    wire [ 3:0] st3_in_i3;
    wire [63:0] st3_in_d4;
    wire [ 3:0] st3_in_i4;
    wire [63:0] st3_in_d5;
    wire [ 3:0] st3_in_i5;
    wire [63:0] st3_in_d6;
    wire [ 3:0] st3_in_i6;
    wire [63:0] st3_in_d7;
    wire [ 3:0] st3_in_i7;
    wire [63:0] st3_in_d8;
    wire [ 3:0] st3_in_i8;
    wire [63:0] st3_in_d9;
    wire [ 3:0] st3_in_i9;
    wire [63:0] st3_in_d10;
    wire [ 3:0] st3_in_i10;
    wire [63:0] st3_in_d11;
    wire [ 3:0] st3_in_i11;
    wire [63:0] st3_in_d12;
    wire [ 3:0] st3_in_i12;
    wire [63:0] st3_in_d13;
    wire [ 3:0] st3_in_i13;
    wire [63:0] st3_in_d14;
    wire [ 3:0] st3_in_i14;
    wire [63:0] st3_in_d15;
    wire [ 3:0] st3_in_i15;

    assign st3_in_d0 = rb_d0;
    assign st3_in_i0 = rb_i0;
    assign st3_in_d1 = rb_d1;
    assign st3_in_i1 = rb_i1;
    assign st3_in_d2 = rb_d2;
    assign st3_in_i2 = rb_i2;
    assign st3_in_d3 = rb_d3;
    assign st3_in_i3 = rb_i3;
    assign st3_in_d4 = rb_d4;
    assign st3_in_i4 = rb_i4;
    assign st3_in_d5 = rb_d5;
    assign st3_in_i5 = rb_i5;
    assign st3_in_d6 = rb_d6;
    assign st3_in_i6 = rb_i6;
    assign st3_in_d7 = rb_d7;
    assign st3_in_i7 = rb_i7;
    assign st3_in_d8 = rb_d8;
    assign st3_in_i8 = rb_i8;
    assign st3_in_d9 = rb_d9;
    assign st3_in_i9 = rb_i9;
    assign st3_in_d10 = rb_d10;
    assign st3_in_i10 = rb_i10;
    assign st3_in_d11 = rb_d11;
    assign st3_in_i11 = rb_i11;
    assign st3_in_d12 = rb_d12;
    assign st3_in_i12 = rb_i12;
    assign st3_in_d13 = rb_d13;
    assign st3_in_i13 = rb_i13;
    assign st3_in_d14 = rb_d14;
    assign st3_in_i14 = rb_i14;
    assign st3_in_d15 = rb_d15;
    assign st3_in_i15 = rb_i15;

    wire [63:0] st3_out_d0;
    wire [ 3:0] st3_out_i0;
    wire [63:0] st3_out_d1;
    wire [ 3:0] st3_out_i1;
    wire [63:0] st3_out_d2;
    wire [ 3:0] st3_out_i2;
    wire [63:0] st3_out_d3;
    wire [ 3:0] st3_out_i3;
    wire [63:0] st3_out_d4;
    wire [ 3:0] st3_out_i4;
    wire [63:0] st3_out_d5;
    wire [ 3:0] st3_out_i5;
    wire [63:0] st3_out_d6;
    wire [ 3:0] st3_out_i6;
    wire [63:0] st3_out_d7;
    wire [ 3:0] st3_out_i7;
    wire [63:0] st3_out_d8;
    wire [ 3:0] st3_out_i8;
    wire [63:0] st3_out_d9;
    wire [ 3:0] st3_out_i9;
    wire [63:0] st3_out_d10;
    wire [ 3:0] st3_out_i10;
    wire [63:0] st3_out_d11;
    wire [ 3:0] st3_out_i11;
    wire [63:0] st3_out_d12;
    wire [ 3:0] st3_out_i12;
    wire [63:0] st3_out_d13;
    wire [ 3:0] st3_out_i13;
    wire [63:0] st3_out_d14;
    wire [ 3:0] st3_out_i14;
    wire [63:0] st3_out_d15;
    wire [ 3:0] st3_out_i15;

    wire [63:0] st3_s1_d0;
    wire [ 3:0] st3_s1_i0;
    wire [63:0] st3_s1_d1;
    wire [ 3:0] st3_s1_i1;
    wire [63:0] st3_s1_d2;
    wire [ 3:0] st3_s1_i2;
    wire [63:0] st3_s1_d3;
    wire [ 3:0] st3_s1_i3;
    wire [63:0] st3_s1_d4;
    wire [ 3:0] st3_s1_i4;
    wire [63:0] st3_s1_d5;
    wire [ 3:0] st3_s1_i5;
    wire [63:0] st3_s1_d6;
    wire [ 3:0] st3_s1_i6;
    wire [63:0] st3_s1_d7;
    wire [ 3:0] st3_s1_i7;
    wire [63:0] st3_s1_d8;
    wire [ 3:0] st3_s1_i8;
    wire [63:0] st3_s1_d9;
    wire [ 3:0] st3_s1_i9;
    wire [63:0] st3_s1_d10;
    wire [ 3:0] st3_s1_i10;
    wire [63:0] st3_s1_d11;
    wire [ 3:0] st3_s1_i11;
    wire [63:0] st3_s1_d12;
    wire [ 3:0] st3_s1_i12;
    wire [63:0] st3_s1_d13;
    wire [ 3:0] st3_s1_i13;
    wire [63:0] st3_s1_d14;
    wire [ 3:0] st3_s1_i14;
    wire [63:0] st3_s1_d15;
    wire [ 3:0] st3_s1_i15;

    compare_swap u_cs_st3_s1_0_8 (
        .din_a (st3_in_d0), .idx_a (st3_in_i0),
        .din_b (st3_in_d8), .idx_b (st3_in_i8),
        .dir   (1'b0),
        .dout_lo(st3_s1_d0), .idx_lo(st3_s1_i0),
        .dout_hi(st3_s1_d8), .idx_hi(st3_s1_i8)
    );
    compare_swap u_cs_st3_s1_1_9 (
        .din_a (st3_in_d1), .idx_a (st3_in_i1),
        .din_b (st3_in_d9), .idx_b (st3_in_i9),
        .dir   (1'b0),
        .dout_lo(st3_s1_d1), .idx_lo(st3_s1_i1),
        .dout_hi(st3_s1_d9), .idx_hi(st3_s1_i9)
    );
    compare_swap u_cs_st3_s1_2_10 (
        .din_a (st3_in_d2), .idx_a (st3_in_i2),
        .din_b (st3_in_d10), .idx_b (st3_in_i10),
        .dir   (1'b0),
        .dout_lo(st3_s1_d2), .idx_lo(st3_s1_i2),
        .dout_hi(st3_s1_d10), .idx_hi(st3_s1_i10)
    );
    compare_swap u_cs_st3_s1_3_11 (
        .din_a (st3_in_d3), .idx_a (st3_in_i3),
        .din_b (st3_in_d11), .idx_b (st3_in_i11),
        .dir   (1'b0),
        .dout_lo(st3_s1_d3), .idx_lo(st3_s1_i3),
        .dout_hi(st3_s1_d11), .idx_hi(st3_s1_i11)
    );
    compare_swap u_cs_st3_s1_4_12 (
        .din_a (st3_in_d4), .idx_a (st3_in_i4),
        .din_b (st3_in_d12), .idx_b (st3_in_i12),
        .dir   (1'b0),
        .dout_lo(st3_s1_d4), .idx_lo(st3_s1_i4),
        .dout_hi(st3_s1_d12), .idx_hi(st3_s1_i12)
    );
    compare_swap u_cs_st3_s1_5_13 (
        .din_a (st3_in_d5), .idx_a (st3_in_i5),
        .din_b (st3_in_d13), .idx_b (st3_in_i13),
        .dir   (1'b0),
        .dout_lo(st3_s1_d5), .idx_lo(st3_s1_i5),
        .dout_hi(st3_s1_d13), .idx_hi(st3_s1_i13)
    );
    compare_swap u_cs_st3_s1_6_14 (
        .din_a (st3_in_d6), .idx_a (st3_in_i6),
        .din_b (st3_in_d14), .idx_b (st3_in_i14),
        .dir   (1'b0),
        .dout_lo(st3_s1_d6), .idx_lo(st3_s1_i6),
        .dout_hi(st3_s1_d14), .idx_hi(st3_s1_i14)
    );
    compare_swap u_cs_st3_s1_7_15 (
        .din_a (st3_in_d7), .idx_a (st3_in_i7),
        .din_b (st3_in_d15), .idx_b (st3_in_i15),
        .dir   (1'b0),
        .dout_lo(st3_s1_d7), .idx_lo(st3_s1_i7),
        .dout_hi(st3_s1_d15), .idx_hi(st3_s1_i15)
    );

    wire [63:0] st3_s2_d0;
    wire [ 3:0] st3_s2_i0;
    wire [63:0] st3_s2_d1;
    wire [ 3:0] st3_s2_i1;
    wire [63:0] st3_s2_d2;
    wire [ 3:0] st3_s2_i2;
    wire [63:0] st3_s2_d3;
    wire [ 3:0] st3_s2_i3;
    wire [63:0] st3_s2_d4;
    wire [ 3:0] st3_s2_i4;
    wire [63:0] st3_s2_d5;
    wire [ 3:0] st3_s2_i5;
    wire [63:0] st3_s2_d6;
    wire [ 3:0] st3_s2_i6;
    wire [63:0] st3_s2_d7;
    wire [ 3:0] st3_s2_i7;
    wire [63:0] st3_s2_d8;
    wire [ 3:0] st3_s2_i8;
    wire [63:0] st3_s2_d9;
    wire [ 3:0] st3_s2_i9;
    wire [63:0] st3_s2_d10;
    wire [ 3:0] st3_s2_i10;
    wire [63:0] st3_s2_d11;
    wire [ 3:0] st3_s2_i11;
    wire [63:0] st3_s2_d12;
    wire [ 3:0] st3_s2_i12;
    wire [63:0] st3_s2_d13;
    wire [ 3:0] st3_s2_i13;
    wire [63:0] st3_s2_d14;
    wire [ 3:0] st3_s2_i14;
    wire [63:0] st3_s2_d15;
    wire [ 3:0] st3_s2_i15;

    compare_swap u_cs_st3_s2_0_4 (
        .din_a (st3_s1_d0), .idx_a (st3_s1_i0),
        .din_b (st3_s1_d4), .idx_b (st3_s1_i4),
        .dir   (1'b0),
        .dout_lo(st3_s2_d0), .idx_lo(st3_s2_i0),
        .dout_hi(st3_s2_d4), .idx_hi(st3_s2_i4)
    );
    compare_swap u_cs_st3_s2_1_5 (
        .din_a (st3_s1_d1), .idx_a (st3_s1_i1),
        .din_b (st3_s1_d5), .idx_b (st3_s1_i5),
        .dir   (1'b0),
        .dout_lo(st3_s2_d1), .idx_lo(st3_s2_i1),
        .dout_hi(st3_s2_d5), .idx_hi(st3_s2_i5)
    );
    compare_swap u_cs_st3_s2_2_6 (
        .din_a (st3_s1_d2), .idx_a (st3_s1_i2),
        .din_b (st3_s1_d6), .idx_b (st3_s1_i6),
        .dir   (1'b0),
        .dout_lo(st3_s2_d2), .idx_lo(st3_s2_i2),
        .dout_hi(st3_s2_d6), .idx_hi(st3_s2_i6)
    );
    compare_swap u_cs_st3_s2_3_7 (
        .din_a (st3_s1_d3), .idx_a (st3_s1_i3),
        .din_b (st3_s1_d7), .idx_b (st3_s1_i7),
        .dir   (1'b0),
        .dout_lo(st3_s2_d3), .idx_lo(st3_s2_i3),
        .dout_hi(st3_s2_d7), .idx_hi(st3_s2_i7)
    );
    compare_swap u_cs_st3_s2_8_12 (
        .din_a (st3_s1_d8), .idx_a (st3_s1_i8),
        .din_b (st3_s1_d12), .idx_b (st3_s1_i12),
        .dir   (1'b0),
        .dout_lo(st3_s2_d8), .idx_lo(st3_s2_i8),
        .dout_hi(st3_s2_d12), .idx_hi(st3_s2_i12)
    );
    compare_swap u_cs_st3_s2_9_13 (
        .din_a (st3_s1_d9), .idx_a (st3_s1_i9),
        .din_b (st3_s1_d13), .idx_b (st3_s1_i13),
        .dir   (1'b0),
        .dout_lo(st3_s2_d9), .idx_lo(st3_s2_i9),
        .dout_hi(st3_s2_d13), .idx_hi(st3_s2_i13)
    );
    compare_swap u_cs_st3_s2_10_14 (
        .din_a (st3_s1_d10), .idx_a (st3_s1_i10),
        .din_b (st3_s1_d14), .idx_b (st3_s1_i14),
        .dir   (1'b0),
        .dout_lo(st3_s2_d10), .idx_lo(st3_s2_i10),
        .dout_hi(st3_s2_d14), .idx_hi(st3_s2_i14)
    );
    compare_swap u_cs_st3_s2_11_15 (
        .din_a (st3_s1_d11), .idx_a (st3_s1_i11),
        .din_b (st3_s1_d15), .idx_b (st3_s1_i15),
        .dir   (1'b0),
        .dout_lo(st3_s2_d11), .idx_lo(st3_s2_i11),
        .dout_hi(st3_s2_d15), .idx_hi(st3_s2_i15)
    );

    wire [63:0] st3_s3_d0;
    wire [ 3:0] st3_s3_i0;
    wire [63:0] st3_s3_d1;
    wire [ 3:0] st3_s3_i1;
    wire [63:0] st3_s3_d2;
    wire [ 3:0] st3_s3_i2;
    wire [63:0] st3_s3_d3;
    wire [ 3:0] st3_s3_i3;
    wire [63:0] st3_s3_d4;
    wire [ 3:0] st3_s3_i4;
    wire [63:0] st3_s3_d5;
    wire [ 3:0] st3_s3_i5;
    wire [63:0] st3_s3_d6;
    wire [ 3:0] st3_s3_i6;
    wire [63:0] st3_s3_d7;
    wire [ 3:0] st3_s3_i7;
    wire [63:0] st3_s3_d8;
    wire [ 3:0] st3_s3_i8;
    wire [63:0] st3_s3_d9;
    wire [ 3:0] st3_s3_i9;
    wire [63:0] st3_s3_d10;
    wire [ 3:0] st3_s3_i10;
    wire [63:0] st3_s3_d11;
    wire [ 3:0] st3_s3_i11;
    wire [63:0] st3_s3_d12;
    wire [ 3:0] st3_s3_i12;
    wire [63:0] st3_s3_d13;
    wire [ 3:0] st3_s3_i13;
    wire [63:0] st3_s3_d14;
    wire [ 3:0] st3_s3_i14;
    wire [63:0] st3_s3_d15;
    wire [ 3:0] st3_s3_i15;

    compare_swap u_cs_st3_s3_0_2 (
        .din_a (st3_s2_d0), .idx_a (st3_s2_i0),
        .din_b (st3_s2_d2), .idx_b (st3_s2_i2),
        .dir   (1'b0),
        .dout_lo(st3_s3_d0), .idx_lo(st3_s3_i0),
        .dout_hi(st3_s3_d2), .idx_hi(st3_s3_i2)
    );
    compare_swap u_cs_st3_s3_1_3 (
        .din_a (st3_s2_d1), .idx_a (st3_s2_i1),
        .din_b (st3_s2_d3), .idx_b (st3_s2_i3),
        .dir   (1'b0),
        .dout_lo(st3_s3_d1), .idx_lo(st3_s3_i1),
        .dout_hi(st3_s3_d3), .idx_hi(st3_s3_i3)
    );
    compare_swap u_cs_st3_s3_4_6 (
        .din_a (st3_s2_d4), .idx_a (st3_s2_i4),
        .din_b (st3_s2_d6), .idx_b (st3_s2_i6),
        .dir   (1'b0),
        .dout_lo(st3_s3_d4), .idx_lo(st3_s3_i4),
        .dout_hi(st3_s3_d6), .idx_hi(st3_s3_i6)
    );
    compare_swap u_cs_st3_s3_5_7 (
        .din_a (st3_s2_d5), .idx_a (st3_s2_i5),
        .din_b (st3_s2_d7), .idx_b (st3_s2_i7),
        .dir   (1'b0),
        .dout_lo(st3_s3_d5), .idx_lo(st3_s3_i5),
        .dout_hi(st3_s3_d7), .idx_hi(st3_s3_i7)
    );
    compare_swap u_cs_st3_s3_8_10 (
        .din_a (st3_s2_d8), .idx_a (st3_s2_i8),
        .din_b (st3_s2_d10), .idx_b (st3_s2_i10),
        .dir   (1'b0),
        .dout_lo(st3_s3_d8), .idx_lo(st3_s3_i8),
        .dout_hi(st3_s3_d10), .idx_hi(st3_s3_i10)
    );
    compare_swap u_cs_st3_s3_9_11 (
        .din_a (st3_s2_d9), .idx_a (st3_s2_i9),
        .din_b (st3_s2_d11), .idx_b (st3_s2_i11),
        .dir   (1'b0),
        .dout_lo(st3_s3_d9), .idx_lo(st3_s3_i9),
        .dout_hi(st3_s3_d11), .idx_hi(st3_s3_i11)
    );
    compare_swap u_cs_st3_s3_12_14 (
        .din_a (st3_s2_d12), .idx_a (st3_s2_i12),
        .din_b (st3_s2_d14), .idx_b (st3_s2_i14),
        .dir   (1'b0),
        .dout_lo(st3_s3_d12), .idx_lo(st3_s3_i12),
        .dout_hi(st3_s3_d14), .idx_hi(st3_s3_i14)
    );
    compare_swap u_cs_st3_s3_13_15 (
        .din_a (st3_s2_d13), .idx_a (st3_s2_i13),
        .din_b (st3_s2_d15), .idx_b (st3_s2_i15),
        .dir   (1'b0),
        .dout_lo(st3_s3_d13), .idx_lo(st3_s3_i13),
        .dout_hi(st3_s3_d15), .idx_hi(st3_s3_i15)
    );

    compare_swap u_cs_st3_s4_0_1 (
        .din_a (st3_s3_d0), .idx_a (st3_s3_i0),
        .din_b (st3_s3_d1), .idx_b (st3_s3_i1),
        .dir   (1'b0),
        .dout_lo(st3_out_d0), .idx_lo(st3_out_i0),
        .dout_hi(st3_out_d1), .idx_hi(st3_out_i1)
    );
    compare_swap u_cs_st3_s4_2_3 (
        .din_a (st3_s3_d2), .idx_a (st3_s3_i2),
        .din_b (st3_s3_d3), .idx_b (st3_s3_i3),
        .dir   (1'b0),
        .dout_lo(st3_out_d2), .idx_lo(st3_out_i2),
        .dout_hi(st3_out_d3), .idx_hi(st3_out_i3)
    );
    compare_swap u_cs_st3_s4_4_5 (
        .din_a (st3_s3_d4), .idx_a (st3_s3_i4),
        .din_b (st3_s3_d5), .idx_b (st3_s3_i5),
        .dir   (1'b0),
        .dout_lo(st3_out_d4), .idx_lo(st3_out_i4),
        .dout_hi(st3_out_d5), .idx_hi(st3_out_i5)
    );
    compare_swap u_cs_st3_s4_6_7 (
        .din_a (st3_s3_d6), .idx_a (st3_s3_i6),
        .din_b (st3_s3_d7), .idx_b (st3_s3_i7),
        .dir   (1'b0),
        .dout_lo(st3_out_d6), .idx_lo(st3_out_i6),
        .dout_hi(st3_out_d7), .idx_hi(st3_out_i7)
    );
    compare_swap u_cs_st3_s4_8_9 (
        .din_a (st3_s3_d8), .idx_a (st3_s3_i8),
        .din_b (st3_s3_d9), .idx_b (st3_s3_i9),
        .dir   (1'b0),
        .dout_lo(st3_out_d8), .idx_lo(st3_out_i8),
        .dout_hi(st3_out_d9), .idx_hi(st3_out_i9)
    );
    compare_swap u_cs_st3_s4_10_11 (
        .din_a (st3_s3_d10), .idx_a (st3_s3_i10),
        .din_b (st3_s3_d11), .idx_b (st3_s3_i11),
        .dir   (1'b0),
        .dout_lo(st3_out_d10), .idx_lo(st3_out_i10),
        .dout_hi(st3_out_d11), .idx_hi(st3_out_i11)
    );
    compare_swap u_cs_st3_s4_12_13 (
        .din_a (st3_s3_d12), .idx_a (st3_s3_i12),
        .din_b (st3_s3_d13), .idx_b (st3_s3_i13),
        .dir   (1'b0),
        .dout_lo(st3_out_d12), .idx_lo(st3_out_i12),
        .dout_hi(st3_out_d13), .idx_hi(st3_out_i13)
    );
    compare_swap u_cs_st3_s4_14_15 (
        .din_a (st3_s3_d14), .idx_a (st3_s3_i14),
        .din_b (st3_s3_d15), .idx_b (st3_s3_i15),
        .dir   (1'b0),
        .dout_lo(st3_out_d14), .idx_lo(st3_out_i14),
        .dout_hi(st3_out_d15), .idx_hi(st3_out_i15)
    );

    // =========================================================
    // Pipeline Register C / Output
    //   o_out_vld: 带复位，每拍更新
    //   数据输出:  无复位，仅 rb_vld=1 时锁存
    // =========================================================

    // 组合逻辑：popcount of rb_bitmap
    always @(*) begin
        cnt = rb_bitmap[0]  + rb_bitmap[1]  + rb_bitmap[2]  + rb_bitmap[3]  +
              rb_bitmap[4]  + rb_bitmap[5]  + rb_bitmap[6]  + rb_bitmap[7]  +
              rb_bitmap[8]  + rb_bitmap[9]  + rb_bitmap[10] + rb_bitmap[11] +
              rb_bitmap[12] + rb_bitmap[13] + rb_bitmap[14] + rb_bitmap[15];
    end

    // 带复位：o_out_vld
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_out_vld <= 16'h0;
        end else begin
            if (!rb_vld)
                o_out_vld <= 16'h0;
            else if (cnt == 5'd16)
                o_out_vld <= 16'hFFFF;
            else
                o_out_vld <= (16'h1 << cnt) - 16'h1;
        end
    end

    // 无复位：数据输出，仅 rb_vld=1 时锁存
    always @(posedge clk) begin
        if (rb_vld) begin
            o_dout0 <= st3_out_d0;
            o_idx0  <= st3_out_i0;
            o_dout1 <= st3_out_d1;
            o_idx1  <= st3_out_i1;
            o_dout2 <= st3_out_d2;
            o_idx2  <= st3_out_i2;
            o_dout3 <= st3_out_d3;
            o_idx3  <= st3_out_i3;
            o_dout4 <= st3_out_d4;
            o_idx4  <= st3_out_i4;
            o_dout5 <= st3_out_d5;
            o_idx5  <= st3_out_i5;
            o_dout6 <= st3_out_d6;
            o_idx6  <= st3_out_i6;
            o_dout7 <= st3_out_d7;
            o_idx7  <= st3_out_i7;
            o_dout8 <= st3_out_d8;
            o_idx8  <= st3_out_i8;
            o_dout9 <= st3_out_d9;
            o_idx9  <= st3_out_i9;
            o_dout10 <= st3_out_d10;
            o_idx10  <= st3_out_i10;
            o_dout11 <= st3_out_d11;
            o_idx11  <= st3_out_i11;
            o_dout12 <= st3_out_d12;
            o_idx12  <= st3_out_i12;
            o_dout13 <= st3_out_d13;
            o_idx13  <= st3_out_i13;
            o_dout14 <= st3_out_d14;
            o_idx14  <= st3_out_i14;
            o_dout15 <= st3_out_d15;
            o_idx15  <= st3_out_i15;
        end
    end

endmodule
