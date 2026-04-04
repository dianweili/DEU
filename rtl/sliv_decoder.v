// =============================================================================
// Module  : sliv_decoder
// Description : 纯组合逻辑，将7-bit SLIV解析为16-bit有效性bitmap
//
// 处理步骤：
//   1. 提取 m = SLIV[6:4]，n = SLIV[3:0]
//   2. 计算 S（起始位置）和 L（长度）
//   3. 生成 position mask：pos[S] ~ pos[S+L-1] 为1
//   4. 4x4行入列出交织（等价于矩阵转置）→ bitmap
//
// 交织映射：bitmap[i] = pos_mask[(i%4)*4 + (i/4)]
//   4x4矩阵按行写入（pos0~pos15），按列读出（col从高到低，行从低到高）：
//     bitmap[15:12] = {pos15, pos11, pos7,  pos3 }  (col3, row3→0)
//     bitmap[11: 8] = {pos14, pos10, pos6,  pos2 }  (col2, row3→0)
//     bitmap[ 7: 4] = {pos13, pos9,  pos5,  pos1 }  (col1, row3→0)
//     bitmap[ 3: 0] = {pos12, pos8,  pos4,  pos0 }  (col0, row3→0)
//
// 验证（S=2, L=8）：pos2~pos9有效 → bitmap = 16'b0011_0011_0110_0110
//   有效数据索引：1/2/5/6/8/9/12/13 ✓
// =============================================================================

module sliv_decoder (
    input  wire [6:0]  sliv,    // 输入SLIV值
    output wire [15:0] bitmap   // 输出：bit[k]=1 表示第k路压缩数据有效
);

    // -------------------------------------------------------------------------
    // Step 1: 提取 m 和 n
    // -------------------------------------------------------------------------
    wire [2:0] m;
    wire [3:0] n;
    assign m = sliv[6:4];   // floor(SLIV/16)，范围 0~7
    assign n = sliv[3:0];   // SLIV % 16，范围 0~15

    // -------------------------------------------------------------------------
    // Step 2: 计算 S 和 L
    //   case1 (m+n <= 15): S = n,      L = m+1    (L范围 1~8 )
    //   case2 (m+n >  15): S = 15-n,   L = 17-m   (L范围 10~16，m>=1时)
    // -------------------------------------------------------------------------
    wire [4:0] m_plus_n;
    wire       case1;
    wire [3:0] S;
    wire [4:0] L;
    wire [4:0] S_ext;
    wire [4:0] S_end;

    assign m_plus_n = {2'b00, m} + {1'b0, n};  // 最大 7+15=22，需5bit
    assign case1    = (m_plus_n <= 5'd15);
    assign S     = case1 ? n                    : (4'd15 - n);
    assign L     = case1 ? ({2'b00, m} + 5'd1) : (5'd17 - {2'b00, m});
    assign S_ext = {1'b0, S};      // S扩展到5bit
    assign S_end = S_ext + L;      // S+L，最大16，恰好5bit可容纳

    // -------------------------------------------------------------------------
    // Step 3: 生成 position mask
    //   pos_mask[j] = 1  当且仅当  S <= j < S+L
    // -------------------------------------------------------------------------
    wire [15:0] pos_mask;

    genvar j;
    generate
        for (j = 0; j < 16; j = j + 1) begin : gen_pos_mask
            assign pos_mask[j] = (j >= S_ext) && (j < S_end);
        end
    endgenerate

    // -------------------------------------------------------------------------
    // Step 4: 4x4行入列出交织（矩阵转置）
    // -------------------------------------------------------------------------
    assign bitmap = {pos_mask[15], pos_mask[11], pos_mask[ 7], pos_mask[ 3],
                     pos_mask[14], pos_mask[10], pos_mask[ 6], pos_mask[ 2],
                     pos_mask[13], pos_mask[ 9], pos_mask[ 5], pos_mask[ 1],
                     pos_mask[12], pos_mask[ 8], pos_mask[ 4], pos_mask[ 0]};

endmodule
