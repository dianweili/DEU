// =============================================================================
// Module  : compare_swap
// Description : 双调排序基本单元，纯组合逻辑（无寄存器）
//
// 功能：根据 dir 决定升序或降序，比较 (din_a, din_b)，
//       将较小值输出到 dout_lo，较大值输出到 dout_hi。
//
// 比较规则（稳定排序）：
//   1. 先比 square 值（64-bit 无符号）
//   2. square 相同时，按 idx 升序（idx 小的视为"更小"）
//
// dir=0：升序模式 —— dout_lo <= dout_hi（dout0 方向为小）
// dir=1：降序模式 —— dout_lo >= dout_hi（dout0 方向为大）
//   注意：在标准双调排序网络中 dir 由网络结构决定，
//         本模块只需知道 a 是否应该保持在低位。
// =============================================================================

module compare_swap (
    input  wire [63:0] din_a,
    input  wire [ 3:0] idx_a,
    input  wire [63:0] din_b,
    input  wire [ 3:0] idx_b,
    input  wire        dir,     // 0=升序（小在dout_lo），1=降序（大在dout_lo）

    output wire [63:0] dout_lo,
    output wire [ 3:0] idx_lo,
    output wire [63:0] dout_hi,
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
