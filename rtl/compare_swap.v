// =============================================================================
// Module  : compare_swap
// Description : 双调排序基本单元，纯组合逻辑（无寄存器）
//
// 功能：根据 dir 决定升序或降序，比较 (din_a, din_b)，
//       将较小值输出到 dout_lo，较大值输出到 dout_hi。
//
// 输入 din_a/din_b 格式：{valid_n[0], exp[3:0], data[14:0]}（20-bit 压缩键）
//   valid_n=0：有效通道；valid_n=1：无效通道（sentinel 0xFFFFF）
//
// 等价性证明：
//   各 exp 值域完全不重叠且单调递增，因此直接比较 20-bit 无符号整数
//   与比较 64-bit square 值完全等价，无需实际计算平方。
//
// 比较规则（稳定排序）：
//   1. 先比 19-bit 压缩键（等价于比较 square 值）
//   2. 压缩键相同时，按 idx 升序（idx 小的视为"更小"）
//
// dir=0：升序模式 —— dout_lo <= dout_hi（dout0 方向为小）
// dir=1：降序模式 —— dout_lo >= dout_hi（dout0 方向为大）
// =============================================================================

module compare_swap (
    input  wire [19:0] din_a,
    input  wire [ 3:0] idx_a,
    input  wire [19:0] din_b,
    input  wire [ 3:0] idx_b,
    input  wire        dir,     // 0=升序（小在dout_lo），1=降序（大在dout_lo）

    output wire [19:0] dout_lo,
    output wire [ 3:0] idx_lo,
    output wire [19:0] dout_hi,
    output wire [ 3:0] idx_hi
);

    // -------------------------------------------------------------------------
    // 判断 a 是否"大于" b（包含 tie-breaker）
    //   a_gt_b = 1 表示 a 应该被交换到高位（升序模式下）
    // -------------------------------------------------------------------------
    wire a_gt_b;
    assign a_gt_b = (din_a > din_b) || ((din_a == din_b) && (idx_a > idx_b));

    // -------------------------------------------------------------------------
    // 是否需要交换：
    //   升序(dir=0)：a > b 时交换，使小值在 lo 端
    //   降序(dir=1)：a < b 时交换，使大值在 lo 端，即 a_gt_b=0 时交换
    // -------------------------------------------------------------------------
    wire do_swap;
    assign do_swap = a_gt_b ^ dir;

    // -------------------------------------------------------------------------
    // 输出选择
    // -------------------------------------------------------------------------
    assign dout_lo = do_swap ? din_b  : din_a;
    assign idx_lo  = do_swap ? idx_b  : idx_a;
    assign dout_hi = do_swap ? din_a  : din_b;
    assign idx_hi  = do_swap ? idx_a  : idx_b;

endmodule
