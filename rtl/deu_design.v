// =============================================================================
// Module  : deu_design
// Description : DEU顶层模块，完整流水线（共8拍延迟：前3拍预处理 + sort 5拍）
//
// 优化：排序阶段直接使用 19-bit 压缩键 {exp[3:0], data[14:0]} 排序，
//       等价于 64-bit square 排序，无需在 sort 前计算 square。
//       排序完成后，在输出端用 16 个 decomp_square 计算最终平方值。
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

    output wire [15:0]  o_dout_vld,
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
    // Stage 3: 构造 19-bit 排序键 + MAX mask + reg
    //
    // 压缩键 key = {exp[3:0], data[14:0]}（去掉 sign，平方与符号无关）
    // 无效通道 key 置为最大值 19'h7FFFF，保证排在末尾
    // =========================================================

    // key 提取：{exp[3:0]=cmp_data[19:16], data[14:0]=cmp_data[14:0]}
    wire [18:0] key_comb0  = {r2_data0[19:16],  r2_data0[14:0]};
    wire [18:0] key_comb1  = {r2_data1[19:16],  r2_data1[14:0]};
    wire [18:0] key_comb2  = {r2_data2[19:16],  r2_data2[14:0]};
    wire [18:0] key_comb3  = {r2_data3[19:16],  r2_data3[14:0]};
    wire [18:0] key_comb4  = {r2_data4[19:16],  r2_data4[14:0]};
    wire [18:0] key_comb5  = {r2_data5[19:16],  r2_data5[14:0]};
    wire [18:0] key_comb6  = {r2_data6[19:16],  r2_data6[14:0]};
    wire [18:0] key_comb7  = {r2_data7[19:16],  r2_data7[14:0]};
    wire [18:0] key_comb8  = {r2_data8[19:16],  r2_data8[14:0]};
    wire [18:0] key_comb9  = {r2_data9[19:16],  r2_data9[14:0]};
    wire [18:0] key_comb10 = {r2_data10[19:16], r2_data10[14:0]};
    wire [18:0] key_comb11 = {r2_data11[19:16], r2_data11[14:0]};
    wire [18:0] key_comb12 = {r2_data12[19:16], r2_data12[14:0]};
    wire [18:0] key_comb13 = {r2_data13[19:16], r2_data13[14:0]};
    wire [18:0] key_comb14 = {r2_data14[19:16], r2_data14[14:0]};
    wire [18:0] key_comb15 = {r2_data15[19:16], r2_data15[14:0]};

    // 无效通道置 MAX，确保排序到末尾
    wire [18:0] key_masked0  = r2_bitmap[0]  ? key_comb0  : 19'h7FFFF;
    wire [18:0] key_masked1  = r2_bitmap[1]  ? key_comb1  : 19'h7FFFF;
    wire [18:0] key_masked2  = r2_bitmap[2]  ? key_comb2  : 19'h7FFFF;
    wire [18:0] key_masked3  = r2_bitmap[3]  ? key_comb3  : 19'h7FFFF;
    wire [18:0] key_masked4  = r2_bitmap[4]  ? key_comb4  : 19'h7FFFF;
    wire [18:0] key_masked5  = r2_bitmap[5]  ? key_comb5  : 19'h7FFFF;
    wire [18:0] key_masked6  = r2_bitmap[6]  ? key_comb6  : 19'h7FFFF;
    wire [18:0] key_masked7  = r2_bitmap[7]  ? key_comb7  : 19'h7FFFF;
    wire [18:0] key_masked8  = r2_bitmap[8]  ? key_comb8  : 19'h7FFFF;
    wire [18:0] key_masked9  = r2_bitmap[9]  ? key_comb9  : 19'h7FFFF;
    wire [18:0] key_masked10 = r2_bitmap[10] ? key_comb10 : 19'h7FFFF;
    wire [18:0] key_masked11 = r2_bitmap[11] ? key_comb11 : 19'h7FFFF;
    wire [18:0] key_masked12 = r2_bitmap[12] ? key_comb12 : 19'h7FFFF;
    wire [18:0] key_masked13 = r2_bitmap[13] ? key_comb13 : 19'h7FFFF;
    wire [18:0] key_masked14 = r2_bitmap[14] ? key_comb14 : 19'h7FFFF;
    wire [18:0] key_masked15 = r2_bitmap[15] ? key_comb15 : 19'h7FFFF;

    reg         r3_vld;
    reg [15:0]  r3_bitmap;
    reg [18:0]  r3_key0;
    reg [18:0]  r3_key1;
    reg [18:0]  r3_key2;
    reg [18:0]  r3_key3;
    reg [18:0]  r3_key4;
    reg [18:0]  r3_key5;
    reg [18:0]  r3_key6;
    reg [18:0]  r3_key7;
    reg [18:0]  r3_key8;
    reg [18:0]  r3_key9;
    reg [18:0]  r3_key10;
    reg [18:0]  r3_key11;
    reg [18:0]  r3_key12;
    reg [18:0]  r3_key13;
    reg [18:0]  r3_key14;
    reg [18:0]  r3_key15;

    // 带复位：vld
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) r3_vld <= 1'b0;
        else        r3_vld <= r2_vld;
    end

    // 无复位：数据，仅 r2_vld=1 时锁存
    always @(posedge clk) begin
        if (r2_vld) begin
            r3_bitmap <= r2_bitmap;
            r3_key0  <= key_masked0;
            r3_key1  <= key_masked1;
            r3_key2  <= key_masked2;
            r3_key3  <= key_masked3;
            r3_key4  <= key_masked4;
            r3_key5  <= key_masked5;
            r3_key6  <= key_masked6;
            r3_key7  <= key_masked7;
            r3_key8  <= key_masked8;
            r3_key9  <= key_masked9;
            r3_key10 <= key_masked10;
            r3_key11 <= key_masked11;
            r3_key12 <= key_masked12;
            r3_key13 <= key_masked13;
            r3_key14 <= key_masked14;
            r3_key15 <= key_masked15;
        end
    end

    // =========================================================
    // Stage 4~8: Bitonic Sort（5拍流水，每2个compare层打一拍）
    // 输入/输出均为 19-bit 压缩键
    // =========================================================
    wire [15:0]  sort_dout_vld;
    wire [18:0]  sort_key0,  sort_key1,  sort_key2,  sort_key3;
    wire [18:0]  sort_key4,  sort_key5,  sort_key6,  sort_key7;
    wire [18:0]  sort_key8,  sort_key9,  sort_key10, sort_key11;
    wire [18:0]  sort_key12, sort_key13, sort_key14, sort_key15;
    wire [ 3:0]  sort_idx0,  sort_idx1,  sort_idx2,  sort_idx3;
    wire [ 3:0]  sort_idx4,  sort_idx5,  sort_idx6,  sort_idx7;
    wire [ 3:0]  sort_idx8,  sort_idx9,  sort_idx10, sort_idx11;
    wire [ 3:0]  sort_idx12, sort_idx13, sort_idx14, sort_idx15;

    bitonic_sort u_sort (
        .clk      (clk),
        .rst_n    (rst_n),
        .i_vld    (r3_vld),
        .i_bitmap (r3_bitmap),
        .i_key0   (r3_key0),
        .i_key1   (r3_key1),
        .i_key2   (r3_key2),
        .i_key3   (r3_key3),
        .i_key4   (r3_key4),
        .i_key5   (r3_key5),
        .i_key6   (r3_key6),
        .i_key7   (r3_key7),
        .i_key8   (r3_key8),
        .i_key9   (r3_key9),
        .i_key10  (r3_key10),
        .i_key11  (r3_key11),
        .i_key12  (r3_key12),
        .i_key13  (r3_key13),
        .i_key14  (r3_key14),
        .i_key15  (r3_key15),
        .i_idx0   (4'd0),
        .i_idx1   (4'd1),
        .i_idx2   (4'd2),
        .i_idx3   (4'd3),
        .i_idx4   (4'd4),
        .i_idx5   (4'd5),
        .i_idx6   (4'd6),
        .i_idx7   (4'd7),
        .i_idx8   (4'd8),
        .i_idx9   (4'd9),
        .i_idx10  (4'd10),
        .i_idx11  (4'd11),
        .i_idx12  (4'd12),
        .i_idx13  (4'd13),
        .i_idx14  (4'd14),
        .i_idx15  (4'd15),
        .o_dout_vld (sort_dout_vld),
        .o_key0   (sort_key0),
        .o_key1   (sort_key1),
        .o_key2   (sort_key2),
        .o_key3   (sort_key3),
        .o_key4   (sort_key4),
        .o_key5   (sort_key5),
        .o_key6   (sort_key6),
        .o_key7   (sort_key7),
        .o_key8   (sort_key8),
        .o_key9   (sort_key9),
        .o_key10  (sort_key10),
        .o_key11  (sort_key11),
        .o_key12  (sort_key12),
        .o_key13  (sort_key13),
        .o_key14  (sort_key14),
        .o_key15  (sort_key15),
        .o_idx0   (sort_idx0),
        .o_idx1   (sort_idx1),
        .o_idx2   (sort_idx2),
        .o_idx3   (sort_idx3),
        .o_idx4   (sort_idx4),
        .o_idx5   (sort_idx5),
        .o_idx6   (sort_idx6),
        .o_idx7   (sort_idx7),
        .o_idx8   (sort_idx8),
        .o_idx9   (sort_idx9),
        .o_idx10  (sort_idx10),
        .o_idx11  (sort_idx11),
        .o_idx12  (sort_idx12),
        .o_idx13  (sort_idx13),
        .o_idx14  (sort_idx14),
        .o_idx15  (sort_idx15)
    );

    // =========================================================
    // 输出：排序后用 decomp_square 计算 64-bit 平方值（纯组合逻辑）
    // key[18:15]=exp[3:0], key[14:0]=data[14:0]
    // 重组为 cmp_data[19:0]={exp[3:0], sign=0, data[14:0]}（sign 不影响平方）
    // =========================================================
    wire [19:0] out_cmp0  = {sort_key0[18:15],  1'b0, sort_key0[14:0]};
    wire [19:0] out_cmp1  = {sort_key1[18:15],  1'b0, sort_key1[14:0]};
    wire [19:0] out_cmp2  = {sort_key2[18:15],  1'b0, sort_key2[14:0]};
    wire [19:0] out_cmp3  = {sort_key3[18:15],  1'b0, sort_key3[14:0]};
    wire [19:0] out_cmp4  = {sort_key4[18:15],  1'b0, sort_key4[14:0]};
    wire [19:0] out_cmp5  = {sort_key5[18:15],  1'b0, sort_key5[14:0]};
    wire [19:0] out_cmp6  = {sort_key6[18:15],  1'b0, sort_key6[14:0]};
    wire [19:0] out_cmp7  = {sort_key7[18:15],  1'b0, sort_key7[14:0]};
    wire [19:0] out_cmp8  = {sort_key8[18:15],  1'b0, sort_key8[14:0]};
    wire [19:0] out_cmp9  = {sort_key9[18:15],  1'b0, sort_key9[14:0]};
    wire [19:0] out_cmp10 = {sort_key10[18:15], 1'b0, sort_key10[14:0]};
    wire [19:0] out_cmp11 = {sort_key11[18:15], 1'b0, sort_key11[14:0]};
    wire [19:0] out_cmp12 = {sort_key12[18:15], 1'b0, sort_key12[14:0]};
    wire [19:0] out_cmp13 = {sort_key13[18:15], 1'b0, sort_key13[14:0]};
    wire [19:0] out_cmp14 = {sort_key14[18:15], 1'b0, sort_key14[14:0]};
    wire [19:0] out_cmp15 = {sort_key15[18:15], 1'b0, sort_key15[14:0]};

    decomp_square u_ds0  (.cmp_data(out_cmp0),  .square(o_dout0));
    decomp_square u_ds1  (.cmp_data(out_cmp1),  .square(o_dout1));
    decomp_square u_ds2  (.cmp_data(out_cmp2),  .square(o_dout2));
    decomp_square u_ds3  (.cmp_data(out_cmp3),  .square(o_dout3));
    decomp_square u_ds4  (.cmp_data(out_cmp4),  .square(o_dout4));
    decomp_square u_ds5  (.cmp_data(out_cmp5),  .square(o_dout5));
    decomp_square u_ds6  (.cmp_data(out_cmp6),  .square(o_dout6));
    decomp_square u_ds7  (.cmp_data(out_cmp7),  .square(o_dout7));
    decomp_square u_ds8  (.cmp_data(out_cmp8),  .square(o_dout8));
    decomp_square u_ds9  (.cmp_data(out_cmp9),  .square(o_dout9));
    decomp_square u_ds10 (.cmp_data(out_cmp10), .square(o_dout10));
    decomp_square u_ds11 (.cmp_data(out_cmp11), .square(o_dout11));
    decomp_square u_ds12 (.cmp_data(out_cmp12), .square(o_dout12));
    decomp_square u_ds13 (.cmp_data(out_cmp13), .square(o_dout13));
    decomp_square u_ds14 (.cmp_data(out_cmp14), .square(o_dout14));
    decomp_square u_ds15 (.cmp_data(out_cmp15), .square(o_dout15));

    assign o_dout_vld  = sort_dout_vld;
    assign o_dout0_idx = sort_idx0;
    assign o_dout1_idx = sort_idx1;
    assign o_dout2_idx = sort_idx2;
    assign o_dout3_idx = sort_idx3;
    assign o_dout4_idx = sort_idx4;
    assign o_dout5_idx = sort_idx5;
    assign o_dout6_idx = sort_idx6;
    assign o_dout7_idx = sort_idx7;
    assign o_dout8_idx = sort_idx8;
    assign o_dout9_idx = sort_idx9;
    assign o_dout10_idx = sort_idx10;
    assign o_dout11_idx = sort_idx11;
    assign o_dout12_idx = sort_idx12;
    assign o_dout13_idx = sort_idx13;
    assign o_dout14_idx = sort_idx14;
    assign o_dout15_idx = sort_idx15;

endmodule
