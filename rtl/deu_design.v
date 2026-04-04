// =============================================================================
// Module  : deu_design
// Description : DEU顶层模块，完整流水线（共6拍延迟）
//
// 寄存器分类：
//   带复位（async rst）: 各级 vld 控制信号
//   无复位（no rst）   : 所有数据寄存器，仅 vld=1 时锁存
// =============================================================================

module deu_design (
    input  wire         clk,
    input  wire         rst_n,

    input  wire         i_data_vld,
    input  wire [6:0]   i_data_sliv,
    input  wire [19:0]  i_data0_in,
    input  wire [19:0]  i_data1_in,
    input  wire [19:0]  i_data2_in,
    input  wire [19:0]  i_data3_in,
    input  wire [19:0]  i_data4_in,
    input  wire [19:0]  i_data5_in,
    input  wire [19:0]  i_data6_in,
    input  wire [19:0]  i_data7_in,
    input  wire [19:0]  i_data8_in,
    input  wire [19:0]  i_data9_in,
    input  wire [19:0]  i_data10_in,
    input  wire [19:0]  i_data11_in,
    input  wire [19:0]  i_data12_in,
    input  wire [19:0]  i_data13_in,
    input  wire [19:0]  i_data14_in,
    input  wire [19:0]  i_data15_in,

    output wire [15:0]  o_out_vld,
    output wire [63:0]  o_dout0,
    output wire [63:0]  o_dout1,
    output wire [63:0]  o_dout2,
    output wire [63:0]  o_dout3,
    output wire [63:0]  o_dout4,
    output wire [63:0]  o_dout5,
    output wire [63:0]  o_dout6,
    output wire [63:0]  o_dout7,
    output wire [63:0]  o_dout8,
    output wire [63:0]  o_dout9,
    output wire [63:0]  o_dout10,
    output wire [63:0]  o_dout11,
    output wire [63:0]  o_dout12,
    output wire [63:0]  o_dout13,
    output wire [63:0]  o_dout14,
    output wire [63:0]  o_dout15,
    output wire [ 3:0]  o_dout0_idx,
    output wire [ 3:0]  o_dout1_idx,
    output wire [ 3:0]  o_dout2_idx,
    output wire [ 3:0]  o_dout3_idx,
    output wire [ 3:0]  o_dout4_idx,
    output wire [ 3:0]  o_dout5_idx,
    output wire [ 3:0]  o_dout6_idx,
    output wire [ 3:0]  o_dout7_idx,
    output wire [ 3:0]  o_dout8_idx,
    output wire [ 3:0]  o_dout9_idx,
    output wire [ 3:0]  o_dout10_idx,
    output wire [ 3:0]  o_dout11_idx,
    output wire [ 3:0]  o_dout12_idx,
    output wire [ 3:0]  o_dout13_idx,
    output wire [ 3:0]  o_dout14_idx,
    output wire [ 3:0]  o_dout15_idx
);

    // =========================================================
    // Stage 1: reg_in
    // =========================================================
    reg         r1_vld;
    reg [6:0]   r1_sliv;
    reg [19:0]  r1_data0;
    reg [19:0]  r1_data1;
    reg [19:0]  r1_data2;
    reg [19:0]  r1_data3;
    reg [19:0]  r1_data4;
    reg [19:0]  r1_data5;
    reg [19:0]  r1_data6;
    reg [19:0]  r1_data7;
    reg [19:0]  r1_data8;
    reg [19:0]  r1_data9;
    reg [19:0]  r1_data10;
    reg [19:0]  r1_data11;
    reg [19:0]  r1_data12;
    reg [19:0]  r1_data13;
    reg [19:0]  r1_data14;
    reg [19:0]  r1_data15;

    // 带复位：vld
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) r1_vld <= 1'b0;
        else        r1_vld <= i_data_vld;
    end

    // 无复位：数据，仅 i_data_vld=1 时锁存
    always @(posedge clk) begin
        if (i_data_vld) begin
            r1_sliv <= i_data_sliv;
            r1_data0 <= i_data0_in;
            r1_data1 <= i_data1_in;
            r1_data2 <= i_data2_in;
            r1_data3 <= i_data3_in;
            r1_data4 <= i_data4_in;
            r1_data5 <= i_data5_in;
            r1_data6 <= i_data6_in;
            r1_data7 <= i_data7_in;
            r1_data8 <= i_data8_in;
            r1_data9 <= i_data9_in;
            r1_data10 <= i_data10_in;
            r1_data11 <= i_data11_in;
            r1_data12 <= i_data12_in;
            r1_data13 <= i_data13_in;
            r1_data14 <= i_data14_in;
            r1_data15 <= i_data15_in;
        end
    end

    // =========================================================
    // Stage 2: SLIV decode + reg
    // =========================================================
    wire [15:0] bitmap_comb;

    sliv_decoder u_sliv_dec (
        .sliv   (r1_sliv),
        .bitmap (bitmap_comb)
    );

    reg         r2_vld;
    reg [15:0]  r2_bitmap;
    reg [19:0]  r2_data0;
    reg [19:0]  r2_data1;
    reg [19:0]  r2_data2;
    reg [19:0]  r2_data3;
    reg [19:0]  r2_data4;
    reg [19:0]  r2_data5;
    reg [19:0]  r2_data6;
    reg [19:0]  r2_data7;
    reg [19:0]  r2_data8;
    reg [19:0]  r2_data9;
    reg [19:0]  r2_data10;
    reg [19:0]  r2_data11;
    reg [19:0]  r2_data12;
    reg [19:0]  r2_data13;
    reg [19:0]  r2_data14;
    reg [19:0]  r2_data15;

    // 带复位：vld
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) r2_vld <= 1'b0;
        else        r2_vld <= r1_vld;
    end

    // 无复位：数据，仅 r1_vld=1 时锁存
    always @(posedge clk) begin
        if (r1_vld) begin
            r2_bitmap <= bitmap_comb;
            r2_data0 <= r1_data0;
            r2_data1 <= r1_data1;
            r2_data2 <= r1_data2;
            r2_data3 <= r1_data3;
            r2_data4 <= r1_data4;
            r2_data5 <= r1_data5;
            r2_data6 <= r1_data6;
            r2_data7 <= r1_data7;
            r2_data8 <= r1_data8;
            r2_data9 <= r1_data9;
            r2_data10 <= r1_data10;
            r2_data11 <= r1_data11;
            r2_data12 <= r1_data12;
            r2_data13 <= r1_data13;
            r2_data14 <= r1_data14;
            r2_data15 <= r1_data15;
        end
    end

    // =========================================================
    // Stage 3: decomp + square + MAX mask + reg
    // =========================================================
    wire [63:0] sq_comb0;
    wire [63:0] sq_comb1;
    wire [63:0] sq_comb2;
    wire [63:0] sq_comb3;
    wire [63:0] sq_comb4;
    wire [63:0] sq_comb5;
    wire [63:0] sq_comb6;
    wire [63:0] sq_comb7;
    wire [63:0] sq_comb8;
    wire [63:0] sq_comb9;
    wire [63:0] sq_comb10;
    wire [63:0] sq_comb11;
    wire [63:0] sq_comb12;
    wire [63:0] sq_comb13;
    wire [63:0] sq_comb14;
    wire [63:0] sq_comb15;

    decomp_square u_ds0 (
        .cmp_data (r2_data0),
        .square   (sq_comb0)
    );
    decomp_square u_ds1 (
        .cmp_data (r2_data1),
        .square   (sq_comb1)
    );
    decomp_square u_ds2 (
        .cmp_data (r2_data2),
        .square   (sq_comb2)
    );
    decomp_square u_ds3 (
        .cmp_data (r2_data3),
        .square   (sq_comb3)
    );
    decomp_square u_ds4 (
        .cmp_data (r2_data4),
        .square   (sq_comb4)
    );
    decomp_square u_ds5 (
        .cmp_data (r2_data5),
        .square   (sq_comb5)
    );
    decomp_square u_ds6 (
        .cmp_data (r2_data6),
        .square   (sq_comb6)
    );
    decomp_square u_ds7 (
        .cmp_data (r2_data7),
        .square   (sq_comb7)
    );
    decomp_square u_ds8 (
        .cmp_data (r2_data8),
        .square   (sq_comb8)
    );
    decomp_square u_ds9 (
        .cmp_data (r2_data9),
        .square   (sq_comb9)
    );
    decomp_square u_ds10 (
        .cmp_data (r2_data10),
        .square   (sq_comb10)
    );
    decomp_square u_ds11 (
        .cmp_data (r2_data11),
        .square   (sq_comb11)
    );
    decomp_square u_ds12 (
        .cmp_data (r2_data12),
        .square   (sq_comb12)
    );
    decomp_square u_ds13 (
        .cmp_data (r2_data13),
        .square   (sq_comb13)
    );
    decomp_square u_ds14 (
        .cmp_data (r2_data14),
        .square   (sq_comb14)
    );
    decomp_square u_ds15 (
        .cmp_data (r2_data15),
        .square   (sq_comb15)
    );

    wire [63:0] sq_masked0;
    wire [63:0] sq_masked1;
    wire [63:0] sq_masked2;
    wire [63:0] sq_masked3;
    wire [63:0] sq_masked4;
    wire [63:0] sq_masked5;
    wire [63:0] sq_masked6;
    wire [63:0] sq_masked7;
    wire [63:0] sq_masked8;
    wire [63:0] sq_masked9;
    wire [63:0] sq_masked10;
    wire [63:0] sq_masked11;
    wire [63:0] sq_masked12;
    wire [63:0] sq_masked13;
    wire [63:0] sq_masked14;
    wire [63:0] sq_masked15;

    assign sq_masked0 = r2_bitmap[0] ? sq_comb0 : 64'hFFFF_FFFF_FFFF_FFFF;
    assign sq_masked1 = r2_bitmap[1] ? sq_comb1 : 64'hFFFF_FFFF_FFFF_FFFF;
    assign sq_masked2 = r2_bitmap[2] ? sq_comb2 : 64'hFFFF_FFFF_FFFF_FFFF;
    assign sq_masked3 = r2_bitmap[3] ? sq_comb3 : 64'hFFFF_FFFF_FFFF_FFFF;
    assign sq_masked4 = r2_bitmap[4] ? sq_comb4 : 64'hFFFF_FFFF_FFFF_FFFF;
    assign sq_masked5 = r2_bitmap[5] ? sq_comb5 : 64'hFFFF_FFFF_FFFF_FFFF;
    assign sq_masked6 = r2_bitmap[6] ? sq_comb6 : 64'hFFFF_FFFF_FFFF_FFFF;
    assign sq_masked7 = r2_bitmap[7] ? sq_comb7 : 64'hFFFF_FFFF_FFFF_FFFF;
    assign sq_masked8 = r2_bitmap[8] ? sq_comb8 : 64'hFFFF_FFFF_FFFF_FFFF;
    assign sq_masked9 = r2_bitmap[9] ? sq_comb9 : 64'hFFFF_FFFF_FFFF_FFFF;
    assign sq_masked10 = r2_bitmap[10] ? sq_comb10 : 64'hFFFF_FFFF_FFFF_FFFF;
    assign sq_masked11 = r2_bitmap[11] ? sq_comb11 : 64'hFFFF_FFFF_FFFF_FFFF;
    assign sq_masked12 = r2_bitmap[12] ? sq_comb12 : 64'hFFFF_FFFF_FFFF_FFFF;
    assign sq_masked13 = r2_bitmap[13] ? sq_comb13 : 64'hFFFF_FFFF_FFFF_FFFF;
    assign sq_masked14 = r2_bitmap[14] ? sq_comb14 : 64'hFFFF_FFFF_FFFF_FFFF;
    assign sq_masked15 = r2_bitmap[15] ? sq_comb15 : 64'hFFFF_FFFF_FFFF_FFFF;

    reg         r3_vld;
    reg [15:0]  r3_bitmap;
    reg [63:0]  r3_sq0;
    reg [63:0]  r3_sq1;
    reg [63:0]  r3_sq2;
    reg [63:0]  r3_sq3;
    reg [63:0]  r3_sq4;
    reg [63:0]  r3_sq5;
    reg [63:0]  r3_sq6;
    reg [63:0]  r3_sq7;
    reg [63:0]  r3_sq8;
    reg [63:0]  r3_sq9;
    reg [63:0]  r3_sq10;
    reg [63:0]  r3_sq11;
    reg [63:0]  r3_sq12;
    reg [63:0]  r3_sq13;
    reg [63:0]  r3_sq14;
    reg [63:0]  r3_sq15;

    // 带复位：vld
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) r3_vld <= 1'b0;
        else        r3_vld <= r2_vld;
    end

    // 无复位：数据，仅 r2_vld=1 时锁存
    always @(posedge clk) begin
        if (r2_vld) begin
            r3_bitmap <= r2_bitmap;
            r3_sq0 <= sq_masked0;
            r3_sq1 <= sq_masked1;
            r3_sq2 <= sq_masked2;
            r3_sq3 <= sq_masked3;
            r3_sq4 <= sq_masked4;
            r3_sq5 <= sq_masked5;
            r3_sq6 <= sq_masked6;
            r3_sq7 <= sq_masked7;
            r3_sq8 <= sq_masked8;
            r3_sq9 <= sq_masked9;
            r3_sq10 <= sq_masked10;
            r3_sq11 <= sq_masked11;
            r3_sq12 <= sq_masked12;
            r3_sq13 <= sq_masked13;
            r3_sq14 <= sq_masked14;
            r3_sq15 <= sq_masked15;
        end
    end

    // =========================================================
    // Stage 4~6: Bitonic Sort
    // =========================================================
    bitonic_sort u_sort (
        .clk      (clk),
        .rst_n    (rst_n),
        .i_vld    (r3_vld),
        .i_bitmap (r3_bitmap),
        .i_sq0     (r3_sq0),
        .i_sq1     (r3_sq1),
        .i_sq2     (r3_sq2),
        .i_sq3     (r3_sq3),
        .i_sq4     (r3_sq4),
        .i_sq5     (r3_sq5),
        .i_sq6     (r3_sq6),
        .i_sq7     (r3_sq7),
        .i_sq8     (r3_sq8),
        .i_sq9     (r3_sq9),
        .i_sq10    (r3_sq10),
        .i_sq11    (r3_sq11),
        .i_sq12    (r3_sq12),
        .i_sq13    (r3_sq13),
        .i_sq14    (r3_sq14),
        .i_sq15    (r3_sq15),
        .i_idx0    (4'd0),
        .i_idx1    (4'd1),
        .i_idx2    (4'd2),
        .i_idx3    (4'd3),
        .i_idx4    (4'd4),
        .i_idx5    (4'd5),
        .i_idx6    (4'd6),
        .i_idx7    (4'd7),
        .i_idx8    (4'd8),
        .i_idx9    (4'd9),
        .i_idx10   (4'd10),
        .i_idx11   (4'd11),
        .i_idx12   (4'd12),
        .i_idx13   (4'd13),
        .i_idx14   (4'd14),
        .i_idx15   (4'd15),
        .o_out_vld (o_out_vld),
        .o_dout0   (o_dout0),
        .o_dout1   (o_dout1),
        .o_dout2   (o_dout2),
        .o_dout3   (o_dout3),
        .o_dout4   (o_dout4),
        .o_dout5   (o_dout5),
        .o_dout6   (o_dout6),
        .o_dout7   (o_dout7),
        .o_dout8   (o_dout8),
        .o_dout9   (o_dout9),
        .o_dout10  (o_dout10),
        .o_dout11  (o_dout11),
        .o_dout12  (o_dout12),
        .o_dout13  (o_dout13),
        .o_dout14  (o_dout14),
        .o_dout15  (o_dout15),
        .o_idx0     (o_dout0_idx),
        .o_idx1     (o_dout1_idx),
        .o_idx2     (o_dout2_idx),
        .o_idx3     (o_dout3_idx),
        .o_idx4     (o_dout4_idx),
        .o_idx5     (o_dout5_idx),
        .o_idx6     (o_dout6_idx),
        .o_idx7     (o_dout7_idx),
        .o_idx8     (o_dout8_idx),
        .o_idx9     (o_dout9_idx),
        .o_idx10    (o_dout10_idx),
        .o_idx11    (o_dout11_idx),
        .o_idx12    (o_dout12_idx),
        .o_idx13    (o_dout13_idx),
        .o_idx14    (o_dout14_idx),
        .o_idx15   (o_dout15_idx)
    );

endmodule
