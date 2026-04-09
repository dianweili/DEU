// =============================================================================
// Module  : bitonic_sort
// Description : 16路双调排序网络，3级流水
//
// 流水线结构（3级）：
//   s1+s2+s3 → reg_p1
//   s4+s5+s6+s7 → reg_p2
//   s8+s9+s10 → output
// =============================================================================


module bitonic_sort (

    input  wire         clk,
    input  wire         rst_n,

    input  wire         i_vld,
    input  wire [15:0]  i_bitmap,
    input  wire [19:0]  i_key0,
    input  wire [19:0]  i_key1,
    input  wire [19:0]  i_key2,
    input  wire [19:0]  i_key3,
    input  wire [19:0]  i_key4,
    input  wire [19:0]  i_key5,
    input  wire [19:0]  i_key6,
    input  wire [19:0]  i_key7,
    input  wire [19:0]  i_key8,
    input  wire [19:0]  i_key9,
    input  wire [19:0]  i_key10,
    input  wire [19:0]  i_key11,
    input  wire [19:0]  i_key12,
    input  wire [19:0]  i_key13,
    input  wire [19:0]  i_key14,
    input  wire [19:0]  i_key15,
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

    output reg  [15:0]  o_dout_vld,
    output reg  [19:0]  o_key0,
    output reg  [19:0]  o_key1,
    output reg  [19:0]  o_key2,
    output reg  [19:0]  o_key3,
    output reg  [19:0]  o_key4,
    output reg  [19:0]  o_key5,
    output reg  [19:0]  o_key6,
    output reg  [19:0]  o_key7,
    output reg  [19:0]  o_key8,
    output reg  [19:0]  o_key9,
    output reg  [19:0]  o_key10,
    output reg  [19:0]  o_key11,
    output reg  [19:0]  o_key12,
    output reg  [19:0]  o_key13,
    output reg  [19:0]  o_key14,
    output reg  [19:0]  o_key15,
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

    // Step 1
    wire [19:0] s1_d0,  s1_d1,  s1_d2,  s1_d3,  s1_d4,  s1_d5,  s1_d6,  s1_d7;
    wire [19:0] s1_d8,  s1_d9,  s1_d10, s1_d11, s1_d12, s1_d13, s1_d14, s1_d15;
    wire [ 3:0] s1_i0,  s1_i1,  s1_i2,  s1_i3,  s1_i4,  s1_i5,  s1_i6,  s1_i7;
    wire [ 3:0] s1_i8,  s1_i9,  s1_i10, s1_i11, s1_i12, s1_i13, s1_i14, s1_i15;

    compare_swap u_cs_s1_0_1   (.din_a(i_key0), .idx_a(i_idx0), .din_b(i_key1), .idx_b(i_idx1), .dir(1'b0), .dout_lo(s1_d0), .idx_lo(s1_i0), .dout_hi(s1_d1), .idx_hi(s1_i1));
    compare_swap u_cs_s1_2_3   (.din_a(i_key2), .idx_a(i_idx2), .din_b(i_key3), .idx_b(i_idx3), .dir(1'b1), .dout_lo(s1_d2), .idx_lo(s1_i2), .dout_hi(s1_d3), .idx_hi(s1_i3));
    compare_swap u_cs_s1_4_5   (.din_a(i_key4), .idx_a(i_idx4), .din_b(i_key5), .idx_b(i_idx5), .dir(1'b0), .dout_lo(s1_d4), .idx_lo(s1_i4), .dout_hi(s1_d5), .idx_hi(s1_i5));
    compare_swap u_cs_s1_6_7   (.din_a(i_key6), .idx_a(i_idx6), .din_b(i_key7), .idx_b(i_idx7), .dir(1'b1), .dout_lo(s1_d6), .idx_lo(s1_i6), .dout_hi(s1_d7), .idx_hi(s1_i7));
    compare_swap u_cs_s1_8_9   (.din_a(i_key8), .idx_a(i_idx8), .din_b(i_key9), .idx_b(i_idx9), .dir(1'b0), .dout_lo(s1_d8), .idx_lo(s1_i8), .dout_hi(s1_d9), .idx_hi(s1_i9));
    compare_swap u_cs_s1_10_11   (.din_a(i_key10), .idx_a(i_idx10), .din_b(i_key11), .idx_b(i_idx11), .dir(1'b1), .dout_lo(s1_d10), .idx_lo(s1_i10), .dout_hi(s1_d11), .idx_hi(s1_i11));
    compare_swap u_cs_s1_12_13   (.din_a(i_key12), .idx_a(i_idx12), .din_b(i_key13), .idx_b(i_idx13), .dir(1'b0), .dout_lo(s1_d12), .idx_lo(s1_i12), .dout_hi(s1_d13), .idx_hi(s1_i13));
    compare_swap u_cs_s1_14_15   (.din_a(i_key14), .idx_a(i_idx14), .din_b(i_key15), .idx_b(i_idx15), .dir(1'b1), .dout_lo(s1_d14), .idx_lo(s1_i14), .dout_hi(s1_d15), .idx_hi(s1_i15));

    // Step 2
    wire [19:0] s2_d0,  s2_d1,  s2_d2,  s2_d3,  s2_d4,  s2_d5,  s2_d6,  s2_d7;
    wire [19:0] s2_d8,  s2_d9,  s2_d10, s2_d11, s2_d12, s2_d13, s2_d14, s2_d15;
    wire [ 3:0] s2_i0,  s2_i1,  s2_i2,  s2_i3,  s2_i4,  s2_i5,  s2_i6,  s2_i7;
    wire [ 3:0] s2_i8,  s2_i9,  s2_i10, s2_i11, s2_i12, s2_i13, s2_i14, s2_i15;

    compare_swap u_cs_s2_0_2   (.din_a(s1_d0), .idx_a(s1_i0), .din_b(s1_d2), .idx_b(s1_i2), .dir(1'b0), .dout_lo(s2_d0), .idx_lo(s2_i0), .dout_hi(s2_d2), .idx_hi(s2_i2));
    compare_swap u_cs_s2_1_3   (.din_a(s1_d1), .idx_a(s1_i1), .din_b(s1_d3), .idx_b(s1_i3), .dir(1'b0), .dout_lo(s2_d1), .idx_lo(s2_i1), .dout_hi(s2_d3), .idx_hi(s2_i3));
    compare_swap u_cs_s2_4_6   (.din_a(s1_d4), .idx_a(s1_i4), .din_b(s1_d6), .idx_b(s1_i6), .dir(1'b1), .dout_lo(s2_d4), .idx_lo(s2_i4), .dout_hi(s2_d6), .idx_hi(s2_i6));
    compare_swap u_cs_s2_5_7   (.din_a(s1_d5), .idx_a(s1_i5), .din_b(s1_d7), .idx_b(s1_i7), .dir(1'b1), .dout_lo(s2_d5), .idx_lo(s2_i5), .dout_hi(s2_d7), .idx_hi(s2_i7));
    compare_swap u_cs_s2_8_10   (.din_a(s1_d8), .idx_a(s1_i8), .din_b(s1_d10), .idx_b(s1_i10), .dir(1'b0), .dout_lo(s2_d8), .idx_lo(s2_i8), .dout_hi(s2_d10), .idx_hi(s2_i10));
    compare_swap u_cs_s2_9_11   (.din_a(s1_d9), .idx_a(s1_i9), .din_b(s1_d11), .idx_b(s1_i11), .dir(1'b0), .dout_lo(s2_d9), .idx_lo(s2_i9), .dout_hi(s2_d11), .idx_hi(s2_i11));
    compare_swap u_cs_s2_12_14   (.din_a(s1_d12), .idx_a(s1_i12), .din_b(s1_d14), .idx_b(s1_i14), .dir(1'b1), .dout_lo(s2_d12), .idx_lo(s2_i12), .dout_hi(s2_d14), .idx_hi(s2_i14));
    compare_swap u_cs_s2_13_15   (.din_a(s1_d13), .idx_a(s1_i13), .din_b(s1_d15), .idx_b(s1_i15), .dir(1'b1), .dout_lo(s2_d13), .idx_lo(s2_i13), .dout_hi(s2_d15), .idx_hi(s2_i15));

    // Step 3
    wire [19:0] s3_d0,  s3_d1,  s3_d2,  s3_d3,  s3_d4,  s3_d5,  s3_d6,  s3_d7;
    wire [19:0] s3_d8,  s3_d9,  s3_d10, s3_d11, s3_d12, s3_d13, s3_d14, s3_d15;
    wire [ 3:0] s3_i0,  s3_i1,  s3_i2,  s3_i3,  s3_i4,  s3_i5,  s3_i6,  s3_i7;
    wire [ 3:0] s3_i8,  s3_i9,  s3_i10, s3_i11, s3_i12, s3_i13, s3_i14, s3_i15;

    compare_swap u_cs_s3_0_1   (.din_a(s2_d0), .idx_a(s2_i0), .din_b(s2_d1), .idx_b(s2_i1), .dir(1'b0), .dout_lo(s3_d0), .idx_lo(s3_i0), .dout_hi(s3_d1), .idx_hi(s3_i1));
    compare_swap u_cs_s3_2_3   (.din_a(s2_d2), .idx_a(s2_i2), .din_b(s2_d3), .idx_b(s2_i3), .dir(1'b0), .dout_lo(s3_d2), .idx_lo(s3_i2), .dout_hi(s3_d3), .idx_hi(s3_i3));
    compare_swap u_cs_s3_4_5   (.din_a(s2_d4), .idx_a(s2_i4), .din_b(s2_d5), .idx_b(s2_i5), .dir(1'b1), .dout_lo(s3_d4), .idx_lo(s3_i4), .dout_hi(s3_d5), .idx_hi(s3_i5));
    compare_swap u_cs_s3_6_7   (.din_a(s2_d6), .idx_a(s2_i6), .din_b(s2_d7), .idx_b(s2_i7), .dir(1'b1), .dout_lo(s3_d6), .idx_lo(s3_i6), .dout_hi(s3_d7), .idx_hi(s3_i7));
    compare_swap u_cs_s3_8_9   (.din_a(s2_d8), .idx_a(s2_i8), .din_b(s2_d9), .idx_b(s2_i9), .dir(1'b0), .dout_lo(s3_d8), .idx_lo(s3_i8), .dout_hi(s3_d9), .idx_hi(s3_i9));
    compare_swap u_cs_s3_10_11   (.din_a(s2_d10), .idx_a(s2_i10), .din_b(s2_d11), .idx_b(s2_i11), .dir(1'b0), .dout_lo(s3_d10), .idx_lo(s3_i10), .dout_hi(s3_d11), .idx_hi(s3_i11));
    compare_swap u_cs_s3_12_13   (.din_a(s2_d12), .idx_a(s2_i12), .din_b(s2_d13), .idx_b(s2_i13), .dir(1'b1), .dout_lo(s3_d12), .idx_lo(s3_i12), .dout_hi(s3_d13), .idx_hi(s3_i13));
    compare_swap u_cs_s3_14_15   (.din_a(s2_d14), .idx_a(s2_i14), .din_b(s2_d15), .idx_b(s2_i15), .dir(1'b1), .dout_lo(s3_d14), .idx_lo(s3_i14), .dout_hi(s3_d15), .idx_hi(s3_i15));

    // Pipeline Register P1 (after steps 1+2+3)
    reg         p1_vld;
    reg [15:0]  p1_bitmap;
    reg [19:0]  p1_d0,  p1_d1,  p1_d2,  p1_d3,  p1_d4,  p1_d5,  p1_d6,  p1_d7;
    reg [19:0]  p1_d8,  p1_d9,  p1_d10, p1_d11, p1_d12, p1_d13, p1_d14, p1_d15;
    reg [ 3:0]  p1_i0,  p1_i1,  p1_i2,  p1_i3,  p1_i4,  p1_i5,  p1_i6,  p1_i7;
    reg [ 3:0]  p1_i8,  p1_i9,  p1_i10, p1_i11, p1_i12, p1_i13, p1_i14, p1_i15;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) p1_vld <= 1'b0;
        else        p1_vld <= i_vld;
    end

    always @(posedge clk) begin
        if (i_vld) begin
            p1_bitmap <= i_bitmap;
            p1_d0 <= s3_d0; p1_i0 <= s3_i0;
            p1_d1 <= s3_d1; p1_i1 <= s3_i1;
            p1_d2 <= s3_d2; p1_i2 <= s3_i2;
            p1_d3 <= s3_d3; p1_i3 <= s3_i3;
            p1_d4 <= s3_d4; p1_i4 <= s3_i4;
            p1_d5 <= s3_d5; p1_i5 <= s3_i5;
            p1_d6 <= s3_d6; p1_i6 <= s3_i6;
            p1_d7 <= s3_d7; p1_i7 <= s3_i7;
            p1_d8 <= s3_d8; p1_i8 <= s3_i8;
            p1_d9 <= s3_d9; p1_i9 <= s3_i9;
            p1_d10 <= s3_d10; p1_i10 <= s3_i10;
            p1_d11 <= s3_d11; p1_i11 <= s3_i11;
            p1_d12 <= s3_d12; p1_i12 <= s3_i12;
            p1_d13 <= s3_d13; p1_i13 <= s3_i13;
            p1_d14 <= s3_d14; p1_i14 <= s3_i14;
            p1_d15 <= s3_d15; p1_i15 <= s3_i15;
        end
    end

    // Step 4
    wire [19:0] s4_d0,  s4_d1,  s4_d2,  s4_d3,  s4_d4,  s4_d5,  s4_d6,  s4_d7;
    wire [19:0] s4_d8,  s4_d9,  s4_d10, s4_d11, s4_d12, s4_d13, s4_d14, s4_d15;
    wire [ 3:0] s4_i0,  s4_i1,  s4_i2,  s4_i3,  s4_i4,  s4_i5,  s4_i6,  s4_i7;
    wire [ 3:0] s4_i8,  s4_i9,  s4_i10, s4_i11, s4_i12, s4_i13, s4_i14, s4_i15;

    compare_swap u_cs_s4_0_4   (.din_a(p1_d0), .idx_a(p1_i0), .din_b(p1_d4), .idx_b(p1_i4), .dir(1'b0), .dout_lo(s4_d0), .idx_lo(s4_i0), .dout_hi(s4_d4), .idx_hi(s4_i4));
    compare_swap u_cs_s4_1_5   (.din_a(p1_d1), .idx_a(p1_i1), .din_b(p1_d5), .idx_b(p1_i5), .dir(1'b0), .dout_lo(s4_d1), .idx_lo(s4_i1), .dout_hi(s4_d5), .idx_hi(s4_i5));
    compare_swap u_cs_s4_2_6   (.din_a(p1_d2), .idx_a(p1_i2), .din_b(p1_d6), .idx_b(p1_i6), .dir(1'b0), .dout_lo(s4_d2), .idx_lo(s4_i2), .dout_hi(s4_d6), .idx_hi(s4_i6));
    compare_swap u_cs_s4_3_7   (.din_a(p1_d3), .idx_a(p1_i3), .din_b(p1_d7), .idx_b(p1_i7), .dir(1'b0), .dout_lo(s4_d3), .idx_lo(s4_i3), .dout_hi(s4_d7), .idx_hi(s4_i7));
    compare_swap u_cs_s4_8_12   (.din_a(p1_d8), .idx_a(p1_i8), .din_b(p1_d12), .idx_b(p1_i12), .dir(1'b1), .dout_lo(s4_d8), .idx_lo(s4_i8), .dout_hi(s4_d12), .idx_hi(s4_i12));
    compare_swap u_cs_s4_9_13   (.din_a(p1_d9), .idx_a(p1_i9), .din_b(p1_d13), .idx_b(p1_i13), .dir(1'b1), .dout_lo(s4_d9), .idx_lo(s4_i9), .dout_hi(s4_d13), .idx_hi(s4_i13));
    compare_swap u_cs_s4_10_14   (.din_a(p1_d10), .idx_a(p1_i10), .din_b(p1_d14), .idx_b(p1_i14), .dir(1'b1), .dout_lo(s4_d10), .idx_lo(s4_i10), .dout_hi(s4_d14), .idx_hi(s4_i14));
    compare_swap u_cs_s4_11_15   (.din_a(p1_d11), .idx_a(p1_i11), .din_b(p1_d15), .idx_b(p1_i15), .dir(1'b1), .dout_lo(s4_d11), .idx_lo(s4_i11), .dout_hi(s4_d15), .idx_hi(s4_i15));

    // Step 5
    wire [19:0] s5_d0,  s5_d1,  s5_d2,  s5_d3,  s5_d4,  s5_d5,  s5_d6,  s5_d7;
    wire [19:0] s5_d8,  s5_d9,  s5_d10, s5_d11, s5_d12, s5_d13, s5_d14, s5_d15;
    wire [ 3:0] s5_i0,  s5_i1,  s5_i2,  s5_i3,  s5_i4,  s5_i5,  s5_i6,  s5_i7;
    wire [ 3:0] s5_i8,  s5_i9,  s5_i10, s5_i11, s5_i12, s5_i13, s5_i14, s5_i15;

    compare_swap u_cs_s5_0_2   (.din_a(s4_d0), .idx_a(s4_i0), .din_b(s4_d2), .idx_b(s4_i2), .dir(1'b0), .dout_lo(s5_d0), .idx_lo(s5_i0), .dout_hi(s5_d2), .idx_hi(s5_i2));
    compare_swap u_cs_s5_1_3   (.din_a(s4_d1), .idx_a(s4_i1), .din_b(s4_d3), .idx_b(s4_i3), .dir(1'b0), .dout_lo(s5_d1), .idx_lo(s5_i1), .dout_hi(s5_d3), .idx_hi(s5_i3));
    compare_swap u_cs_s5_4_6   (.din_a(s4_d4), .idx_a(s4_i4), .din_b(s4_d6), .idx_b(s4_i6), .dir(1'b0), .dout_lo(s5_d4), .idx_lo(s5_i4), .dout_hi(s5_d6), .idx_hi(s5_i6));
    compare_swap u_cs_s5_5_7   (.din_a(s4_d5), .idx_a(s4_i5), .din_b(s4_d7), .idx_b(s4_i7), .dir(1'b0), .dout_lo(s5_d5), .idx_lo(s5_i5), .dout_hi(s5_d7), .idx_hi(s5_i7));
    compare_swap u_cs_s5_8_10   (.din_a(s4_d8), .idx_a(s4_i8), .din_b(s4_d10), .idx_b(s4_i10), .dir(1'b1), .dout_lo(s5_d8), .idx_lo(s5_i8), .dout_hi(s5_d10), .idx_hi(s5_i10));
    compare_swap u_cs_s5_9_11   (.din_a(s4_d9), .idx_a(s4_i9), .din_b(s4_d11), .idx_b(s4_i11), .dir(1'b1), .dout_lo(s5_d9), .idx_lo(s5_i9), .dout_hi(s5_d11), .idx_hi(s5_i11));
    compare_swap u_cs_s5_12_14   (.din_a(s4_d12), .idx_a(s4_i12), .din_b(s4_d14), .idx_b(s4_i14), .dir(1'b1), .dout_lo(s5_d12), .idx_lo(s5_i12), .dout_hi(s5_d14), .idx_hi(s5_i14));
    compare_swap u_cs_s5_13_15   (.din_a(s4_d13), .idx_a(s4_i13), .din_b(s4_d15), .idx_b(s4_i15), .dir(1'b1), .dout_lo(s5_d13), .idx_lo(s5_i13), .dout_hi(s5_d15), .idx_hi(s5_i15));

    // Step 6
    wire [19:0] s6_d0,  s6_d1,  s6_d2,  s6_d3,  s6_d4,  s6_d5,  s6_d6,  s6_d7;
    wire [19:0] s6_d8,  s6_d9,  s6_d10, s6_d11, s6_d12, s6_d13, s6_d14, s6_d15;
    wire [ 3:0] s6_i0,  s6_i1,  s6_i2,  s6_i3,  s6_i4,  s6_i5,  s6_i6,  s6_i7;
    wire [ 3:0] s6_i8,  s6_i9,  s6_i10, s6_i11, s6_i12, s6_i13, s6_i14, s6_i15;

    compare_swap u_cs_s6_0_1   (.din_a(s5_d0), .idx_a(s5_i0), .din_b(s5_d1), .idx_b(s5_i1), .dir(1'b0), .dout_lo(s6_d0), .idx_lo(s6_i0), .dout_hi(s6_d1), .idx_hi(s6_i1));
    compare_swap u_cs_s6_2_3   (.din_a(s5_d2), .idx_a(s5_i2), .din_b(s5_d3), .idx_b(s5_i3), .dir(1'b0), .dout_lo(s6_d2), .idx_lo(s6_i2), .dout_hi(s6_d3), .idx_hi(s6_i3));
    compare_swap u_cs_s6_4_5   (.din_a(s5_d4), .idx_a(s5_i4), .din_b(s5_d5), .idx_b(s5_i5), .dir(1'b0), .dout_lo(s6_d4), .idx_lo(s6_i4), .dout_hi(s6_d5), .idx_hi(s6_i5));
    compare_swap u_cs_s6_6_7   (.din_a(s5_d6), .idx_a(s5_i6), .din_b(s5_d7), .idx_b(s5_i7), .dir(1'b0), .dout_lo(s6_d6), .idx_lo(s6_i6), .dout_hi(s6_d7), .idx_hi(s6_i7));
    compare_swap u_cs_s6_8_9   (.din_a(s5_d8), .idx_a(s5_i8), .din_b(s5_d9), .idx_b(s5_i9), .dir(1'b1), .dout_lo(s6_d8), .idx_lo(s6_i8), .dout_hi(s6_d9), .idx_hi(s6_i9));
    compare_swap u_cs_s6_10_11   (.din_a(s5_d10), .idx_a(s5_i10), .din_b(s5_d11), .idx_b(s5_i11), .dir(1'b1), .dout_lo(s6_d10), .idx_lo(s6_i10), .dout_hi(s6_d11), .idx_hi(s6_i11));
    compare_swap u_cs_s6_12_13   (.din_a(s5_d12), .idx_a(s5_i12), .din_b(s5_d13), .idx_b(s5_i13), .dir(1'b1), .dout_lo(s6_d12), .idx_lo(s6_i12), .dout_hi(s6_d13), .idx_hi(s6_i13));
    compare_swap u_cs_s6_14_15   (.din_a(s5_d14), .idx_a(s5_i14), .din_b(s5_d15), .idx_b(s5_i15), .dir(1'b1), .dout_lo(s6_d14), .idx_lo(s6_i14), .dout_hi(s6_d15), .idx_hi(s6_i15));

    // Step 7
    wire [19:0] s7_d0,  s7_d1,  s7_d2,  s7_d3,  s7_d4,  s7_d5,  s7_d6,  s7_d7;
    wire [19:0] s7_d8,  s7_d9,  s7_d10, s7_d11, s7_d12, s7_d13, s7_d14, s7_d15;
    wire [ 3:0] s7_i0,  s7_i1,  s7_i2,  s7_i3,  s7_i4,  s7_i5,  s7_i6,  s7_i7;
    wire [ 3:0] s7_i8,  s7_i9,  s7_i10, s7_i11, s7_i12, s7_i13, s7_i14, s7_i15;

    compare_swap u_cs_s7_0_8   (.din_a(s6_d0), .idx_a(s6_i0), .din_b(s6_d8), .idx_b(s6_i8), .dir(1'b0), .dout_lo(s7_d0), .idx_lo(s7_i0), .dout_hi(s7_d8), .idx_hi(s7_i8));
    compare_swap u_cs_s7_1_9   (.din_a(s6_d1), .idx_a(s6_i1), .din_b(s6_d9), .idx_b(s6_i9), .dir(1'b0), .dout_lo(s7_d1), .idx_lo(s7_i1), .dout_hi(s7_d9), .idx_hi(s7_i9));
    compare_swap u_cs_s7_2_10   (.din_a(s6_d2), .idx_a(s6_i2), .din_b(s6_d10), .idx_b(s6_i10), .dir(1'b0), .dout_lo(s7_d2), .idx_lo(s7_i2), .dout_hi(s7_d10), .idx_hi(s7_i10));
    compare_swap u_cs_s7_3_11   (.din_a(s6_d3), .idx_a(s6_i3), .din_b(s6_d11), .idx_b(s6_i11), .dir(1'b0), .dout_lo(s7_d3), .idx_lo(s7_i3), .dout_hi(s7_d11), .idx_hi(s7_i11));
    compare_swap u_cs_s7_4_12   (.din_a(s6_d4), .idx_a(s6_i4), .din_b(s6_d12), .idx_b(s6_i12), .dir(1'b0), .dout_lo(s7_d4), .idx_lo(s7_i4), .dout_hi(s7_d12), .idx_hi(s7_i12));
    compare_swap u_cs_s7_5_13   (.din_a(s6_d5), .idx_a(s6_i5), .din_b(s6_d13), .idx_b(s6_i13), .dir(1'b0), .dout_lo(s7_d5), .idx_lo(s7_i5), .dout_hi(s7_d13), .idx_hi(s7_i13));
    compare_swap u_cs_s7_6_14   (.din_a(s6_d6), .idx_a(s6_i6), .din_b(s6_d14), .idx_b(s6_i14), .dir(1'b0), .dout_lo(s7_d6), .idx_lo(s7_i6), .dout_hi(s7_d14), .idx_hi(s7_i14));
    compare_swap u_cs_s7_7_15   (.din_a(s6_d7), .idx_a(s6_i7), .din_b(s6_d15), .idx_b(s6_i15), .dir(1'b0), .dout_lo(s7_d7), .idx_lo(s7_i7), .dout_hi(s7_d15), .idx_hi(s7_i15));

    // Pipeline Register P2 (after steps 4+5+6+7)
    reg         p2_vld;
    reg [15:0]  p2_bitmap;
    reg [19:0]  p2_d0,  p2_d1,  p2_d2,  p2_d3,  p2_d4,  p2_d5,  p2_d6,  p2_d7;
    reg [19:0]  p2_d8,  p2_d9,  p2_d10, p2_d11, p2_d12, p2_d13, p2_d14, p2_d15;
    reg [ 3:0]  p2_i0,  p2_i1,  p2_i2,  p2_i3,  p2_i4,  p2_i5,  p2_i6,  p2_i7;
    reg [ 3:0]  p2_i8,  p2_i9,  p2_i10, p2_i11, p2_i12, p2_i13, p2_i14, p2_i15;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) p2_vld <= 1'b0;
        else        p2_vld <= p1_vld;
    end

    always @(posedge clk) begin
        if (p1_vld) begin
            p2_bitmap <= p1_bitmap;
            p2_d0 <= s7_d0; p2_i0 <= s7_i0;
            p2_d1 <= s7_d1; p2_i1 <= s7_i1;
            p2_d2 <= s7_d2; p2_i2 <= s7_i2;
            p2_d3 <= s7_d3; p2_i3 <= s7_i3;
            p2_d4 <= s7_d4; p2_i4 <= s7_i4;
            p2_d5 <= s7_d5; p2_i5 <= s7_i5;
            p2_d6 <= s7_d6; p2_i6 <= s7_i6;
            p2_d7 <= s7_d7; p2_i7 <= s7_i7;
            p2_d8 <= s7_d8; p2_i8 <= s7_i8;
            p2_d9 <= s7_d9; p2_i9 <= s7_i9;
            p2_d10 <= s7_d10; p2_i10 <= s7_i10;
            p2_d11 <= s7_d11; p2_i11 <= s7_i11;
            p2_d12 <= s7_d12; p2_i12 <= s7_i12;
            p2_d13 <= s7_d13; p2_i13 <= s7_i13;
            p2_d14 <= s7_d14; p2_i14 <= s7_i14;
            p2_d15 <= s7_d15; p2_i15 <= s7_i15;
        end
    end

    // Step 8
    wire [19:0] s8_d0,  s8_d1,  s8_d2,  s8_d3,  s8_d4,  s8_d5,  s8_d6,  s8_d7;
    wire [19:0] s8_d8,  s8_d9,  s8_d10, s8_d11, s8_d12, s8_d13, s8_d14, s8_d15;
    wire [ 3:0] s8_i0,  s8_i1,  s8_i2,  s8_i3,  s8_i4,  s8_i5,  s8_i6,  s8_i7;
    wire [ 3:0] s8_i8,  s8_i9,  s8_i10, s8_i11, s8_i12, s8_i13, s8_i14, s8_i15;

    compare_swap u_cs_s8_0_4   (.din_a(p2_d0), .idx_a(p2_i0), .din_b(p2_d4), .idx_b(p2_i4), .dir(1'b0), .dout_lo(s8_d0), .idx_lo(s8_i0), .dout_hi(s8_d4), .idx_hi(s8_i4));
    compare_swap u_cs_s8_1_5   (.din_a(p2_d1), .idx_a(p2_i1), .din_b(p2_d5), .idx_b(p2_i5), .dir(1'b0), .dout_lo(s8_d1), .idx_lo(s8_i1), .dout_hi(s8_d5), .idx_hi(s8_i5));
    compare_swap u_cs_s8_2_6   (.din_a(p2_d2), .idx_a(p2_i2), .din_b(p2_d6), .idx_b(p2_i6), .dir(1'b0), .dout_lo(s8_d2), .idx_lo(s8_i2), .dout_hi(s8_d6), .idx_hi(s8_i6));
    compare_swap u_cs_s8_3_7   (.din_a(p2_d3), .idx_a(p2_i3), .din_b(p2_d7), .idx_b(p2_i7), .dir(1'b0), .dout_lo(s8_d3), .idx_lo(s8_i3), .dout_hi(s8_d7), .idx_hi(s8_i7));
    compare_swap u_cs_s8_8_12   (.din_a(p2_d8), .idx_a(p2_i8), .din_b(p2_d12), .idx_b(p2_i12), .dir(1'b0), .dout_lo(s8_d8), .idx_lo(s8_i8), .dout_hi(s8_d12), .idx_hi(s8_i12));
    compare_swap u_cs_s8_9_13   (.din_a(p2_d9), .idx_a(p2_i9), .din_b(p2_d13), .idx_b(p2_i13), .dir(1'b0), .dout_lo(s8_d9), .idx_lo(s8_i9), .dout_hi(s8_d13), .idx_hi(s8_i13));
    compare_swap u_cs_s8_10_14   (.din_a(p2_d10), .idx_a(p2_i10), .din_b(p2_d14), .idx_b(p2_i14), .dir(1'b0), .dout_lo(s8_d10), .idx_lo(s8_i10), .dout_hi(s8_d14), .idx_hi(s8_i14));
    compare_swap u_cs_s8_11_15   (.din_a(p2_d11), .idx_a(p2_i11), .din_b(p2_d15), .idx_b(p2_i15), .dir(1'b0), .dout_lo(s8_d11), .idx_lo(s8_i11), .dout_hi(s8_d15), .idx_hi(s8_i15));

    // Step 9
    wire [19:0] s9_d0,  s9_d1,  s9_d2,  s9_d3,  s9_d4,  s9_d5,  s9_d6,  s9_d7;
    wire [19:0] s9_d8,  s9_d9,  s9_d10, s9_d11, s9_d12, s9_d13, s9_d14, s9_d15;
    wire [ 3:0] s9_i0,  s9_i1,  s9_i2,  s9_i3,  s9_i4,  s9_i5,  s9_i6,  s9_i7;
    wire [ 3:0] s9_i8,  s9_i9,  s9_i10, s9_i11, s9_i12, s9_i13, s9_i14, s9_i15;

    compare_swap u_cs_s9_0_2   (.din_a(s8_d0), .idx_a(s8_i0), .din_b(s8_d2), .idx_b(s8_i2), .dir(1'b0), .dout_lo(s9_d0), .idx_lo(s9_i0), .dout_hi(s9_d2), .idx_hi(s9_i2));
    compare_swap u_cs_s9_1_3   (.din_a(s8_d1), .idx_a(s8_i1), .din_b(s8_d3), .idx_b(s8_i3), .dir(1'b0), .dout_lo(s9_d1), .idx_lo(s9_i1), .dout_hi(s9_d3), .idx_hi(s9_i3));
    compare_swap u_cs_s9_4_6   (.din_a(s8_d4), .idx_a(s8_i4), .din_b(s8_d6), .idx_b(s8_i6), .dir(1'b0), .dout_lo(s9_d4), .idx_lo(s9_i4), .dout_hi(s9_d6), .idx_hi(s9_i6));
    compare_swap u_cs_s9_5_7   (.din_a(s8_d5), .idx_a(s8_i5), .din_b(s8_d7), .idx_b(s8_i7), .dir(1'b0), .dout_lo(s9_d5), .idx_lo(s9_i5), .dout_hi(s9_d7), .idx_hi(s9_i7));
    compare_swap u_cs_s9_8_10   (.din_a(s8_d8), .idx_a(s8_i8), .din_b(s8_d10), .idx_b(s8_i10), .dir(1'b0), .dout_lo(s9_d8), .idx_lo(s9_i8), .dout_hi(s9_d10), .idx_hi(s9_i10));
    compare_swap u_cs_s9_9_11   (.din_a(s8_d9), .idx_a(s8_i9), .din_b(s8_d11), .idx_b(s8_i11), .dir(1'b0), .dout_lo(s9_d9), .idx_lo(s9_i9), .dout_hi(s9_d11), .idx_hi(s9_i11));
    compare_swap u_cs_s9_12_14   (.din_a(s8_d12), .idx_a(s8_i12), .din_b(s8_d14), .idx_b(s8_i14), .dir(1'b0), .dout_lo(s9_d12), .idx_lo(s9_i12), .dout_hi(s9_d14), .idx_hi(s9_i14));
    compare_swap u_cs_s9_13_15   (.din_a(s8_d13), .idx_a(s8_i13), .din_b(s8_d15), .idx_b(s8_i15), .dir(1'b0), .dout_lo(s9_d13), .idx_lo(s9_i13), .dout_hi(s9_d15), .idx_hi(s9_i15));

    // Step 10
    wire [19:0] s10_d0,  s10_d1,  s10_d2,  s10_d3,  s10_d4,  s10_d5,  s10_d6,  s10_d7;
    wire [19:0] s10_d8,  s10_d9,  s10_d10, s10_d11, s10_d12, s10_d13, s10_d14, s10_d15;
    wire [ 3:0] s10_i0,  s10_i1,  s10_i2,  s10_i3,  s10_i4,  s10_i5,  s10_i6,  s10_i7;
    wire [ 3:0] s10_i8,  s10_i9,  s10_i10, s10_i11, s10_i12, s10_i13, s10_i14, s10_i15;

    compare_swap u_cs_s10_0_1   (.din_a(s9_d0), .idx_a(s9_i0), .din_b(s9_d1), .idx_b(s9_i1), .dir(1'b0), .dout_lo(s10_d0), .idx_lo(s10_i0), .dout_hi(s10_d1), .idx_hi(s10_i1));
    compare_swap u_cs_s10_2_3   (.din_a(s9_d2), .idx_a(s9_i2), .din_b(s9_d3), .idx_b(s9_i3), .dir(1'b0), .dout_lo(s10_d2), .idx_lo(s10_i2), .dout_hi(s10_d3), .idx_hi(s10_i3));
    compare_swap u_cs_s10_4_5   (.din_a(s9_d4), .idx_a(s9_i4), .din_b(s9_d5), .idx_b(s9_i5), .dir(1'b0), .dout_lo(s10_d4), .idx_lo(s10_i4), .dout_hi(s10_d5), .idx_hi(s10_i5));
    compare_swap u_cs_s10_6_7   (.din_a(s9_d6), .idx_a(s9_i6), .din_b(s9_d7), .idx_b(s9_i7), .dir(1'b0), .dout_lo(s10_d6), .idx_lo(s10_i6), .dout_hi(s10_d7), .idx_hi(s10_i7));
    compare_swap u_cs_s10_8_9   (.din_a(s9_d8), .idx_a(s9_i8), .din_b(s9_d9), .idx_b(s9_i9), .dir(1'b0), .dout_lo(s10_d8), .idx_lo(s10_i8), .dout_hi(s10_d9), .idx_hi(s10_i9));
    compare_swap u_cs_s10_10_11   (.din_a(s9_d10), .idx_a(s9_i10), .din_b(s9_d11), .idx_b(s9_i11), .dir(1'b0), .dout_lo(s10_d10), .idx_lo(s10_i10), .dout_hi(s10_d11), .idx_hi(s10_i11));
    compare_swap u_cs_s10_12_13   (.din_a(s9_d12), .idx_a(s9_i12), .din_b(s9_d13), .idx_b(s9_i13), .dir(1'b0), .dout_lo(s10_d12), .idx_lo(s10_i12), .dout_hi(s10_d13), .idx_hi(s10_i13));
    compare_swap u_cs_s10_14_15   (.din_a(s9_d14), .idx_a(s9_i14), .din_b(s9_d15), .idx_b(s9_i15), .dir(1'b0), .dout_lo(s10_d14), .idx_lo(s10_i14), .dout_hi(s10_d15), .idx_hi(s10_i15));

    // Output Register (after steps 8+9+10)
    // popcount of p2_bitmap
    always @(*) begin
        cnt = p2_bitmap[0]  + p2_bitmap[1]  + p2_bitmap[2]  + p2_bitmap[3]  +
              p2_bitmap[4]  + p2_bitmap[5]  + p2_bitmap[6]  + p2_bitmap[7]  +
              p2_bitmap[8]  + p2_bitmap[9]  + p2_bitmap[10] + p2_bitmap[11] +
              p2_bitmap[12] + p2_bitmap[13] + p2_bitmap[14] + p2_bitmap[15];
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_dout_vld <= 16'h0;
        end else begin
            if (!p2_vld)
                o_dout_vld <= 16'h0;
            else if (cnt == 5'd16)
                o_dout_vld <= 16'hFFFF;
            else
                o_dout_vld <= (16'h1 << cnt) - 16'h1;
        end
    end

    always @(posedge clk) begin
        if (p2_vld) begin
            o_key0 <= s10_d0; o_idx0 <= s10_i0;
            o_key1 <= s10_d1; o_idx1 <= s10_i1;
            o_key2 <= s10_d2; o_idx2 <= s10_i2;
            o_key3 <= s10_d3; o_idx3 <= s10_i3;
            o_key4 <= s10_d4; o_idx4 <= s10_i4;
            o_key5 <= s10_d5; o_idx5 <= s10_i5;
            o_key6 <= s10_d6; o_idx6 <= s10_i6;
            o_key7 <= s10_d7; o_idx7 <= s10_i7;
            o_key8 <= s10_d8; o_idx8 <= s10_i8;
            o_key9 <= s10_d9; o_idx9 <= s10_i9;
            o_key10 <= s10_d10; o_idx10 <= s10_i10;
            o_key11 <= s10_d11; o_idx11 <= s10_i11;
            o_key12 <= s10_d12; o_idx12 <= s10_i12;
            o_key13 <= s10_d13; o_idx13 <= s10_i13;
            o_key14 <= s10_d14; o_idx14 <= s10_i14;
            o_key15 <= s10_d15; o_idx15 <= s10_i15;
        end
    end

endmodule