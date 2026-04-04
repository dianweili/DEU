# DEU 设计方案

## 1. 功能理解

### 1.1 处理链

DEU 模块是一个全流水数据处理单元，每拍接收 16 路 20-bit 压缩数据 + 7-bit SLIV，完成以下处理链：

```
输入 → reg_in → SLIV解析(bitmap) → 解压缩 → 求模方(平方) → 挤气泡+排序 → reg_out → 输出
```

### 1.2 SLIV 解析

1. 位域提取：`m = SLIV[6:4]`，`n = SLIV[3:0]`（即 SLIV >> 4 和 SLIV & 0xF）
2. 计算 S/L：
   - 若 `(m + n) <= 15`：`S = n`，`L = m + 1`
   - 否则：`S = 15 - n`，`L = 17 - m`
3. 生成 16-bit position mask：pos[S] ~ pos[S+L-1] 为 1，其余为 0
4. 通过 4x4 行入列出交织器生成 bitmap

**交织器本质是矩阵转置：**

```
bitmap[i] = pos_mask[(i % 4) * 4 + (i / 4)]
```

验证（S=2, L=8）：
- 有效位置：pos2~pos9
- 交织后：`16'b0011_0011_0110_0110`
- 有效数据索引：1/2/5/6/8/9/12/13 ✓

### 1.3 解压缩

压缩数据格式：`cmp_data[19:0] = {exp[3:0], sign, data[14:0]}`

```
if (exp > 0):
    decp_data_tmp = {1'b1, data[14:0]} << (exp - 1)   // 等价于原始公式
else:
    decp_data_tmp = data[14:0]

if (sign == 0): decp_data = decp_data_tmp
else:           decp_data = -decp_data_tmp
```

数据位宽分析：
- `exp=0` 时：最大 15 bit
- `exp=15` 时：`{1, data} << 14`，最大约 2^30，需 30 bit

### 1.4 求模方（平方）的关键优化

平方运算与符号无关，可忽略符号位直接对 `decp_data_tmp` 求平方。

**分解为 16×16 乘法 + 桶形移位：**

```
val16 = (exp > 0) ? {1'b1, data[14:0]} : {1'b0, data[14:0]}
shift_amt = (exp > 0) ? 2 * (exp - 1) : 0
square = val16 * val16 << shift_amt
```

- `val16` 为 16 bit，`val16²` 为 32 bit（最大约 2^32）
- 左移最多 28 位（exp=15 时）→ 结果最大约 60 bit
- 输出 64 bit，完全容纳

> 优势：只需 16×16 乘法器（远比 30×30 轻量），大幅节省面积和时序压力。

---

## 2. 总体方案

### 2.1 核心策略：调整步骤顺序

题目允许"只要结果等价"即可调整步骤顺序。

**方案：先对全部 16 路做解压+求模方，再结合 bitmap 把无效数据标记为最大值，最后统一排序。**

- "抽取"步骤融入排序：无效数据的 square 赋值为 `64'hFFFF_FFFF_FFFF_FFFF`，排序后自然沉到高位
- 无效输出端（vld=0）对应结果为 don't care，验证不检查

### 2.2 流水线划分（预估约 12 拍，远小于 40 拍限制）

| 阶段 | 拍数 | 操作 |
|------|------|------|
| Stage 1  | 1 | **reg_in**：寄存所有输入信号（i_data_vld 除外） |
| Stage 2  | 1 | **SLIV 解码**：提取 m/n → 计算 S/L → 生成 position mask → 交织得 bitmap |
| Stage 3  | 1 | **解压缩准备**：提取各通道 exp/data，构造 val16 |
| Stage 4  | 2 | **16×16 乘法**：val16² → 32-bit 乘积（1GHz 下拆为 2 拍保证时序） |
| Stage 5  | 1 | **桶形移位 + mask 注入**：乘积左移 2*(exp-1) 得 64-bit square；无效通道赋 MAX |
| Stage 6  | 1 | **排序 Phase 1+2**（Steps 1-3，3 级 CAS 组合逻辑）：形成有序 4 元组 |
| Stage 7  | 1 | **排序 Phase 3**（Steps 4-6，3 级 CAS 组合逻辑）：形成有序 8 元组 |
| Stage 8  | 1 | **排序 Phase 4**（Steps 7-10，4 级 CAS 组合逻辑）：完成全排序 |
| Stage 9  | 1 | **输出整理**：popcount(bitmap) 得有效数 K，生成 o_out_vld = (1<<K)-1 |
| Stage 10 | 1 | **reg_out**：寄存器输出所有信号 |

**总计：约 12 拍，满足 40 拍要求，留有充足余量。**

### 2.3 排序算法：Bitonic Sort（双调排序，3 级流水）

选用双调排序网络的理由：
- 16 元素双调排序需 **10 步** compare-swap（步骤分布：1+2+3+4）
- 结构确定，无数据依赖，天然适合全流水

**关键决策：将 10 步合并为 3 个流水级，每级内部为纯组合逻辑：**

```
Sort Stage 1 (Step 1-3, 3 级 CAS 串联):
  Step 1: distance-1  → 形成有序对
  Step 2: distance-2  → Phase 2 开始
  Step 3: distance-1  → 形成有序 4 元组

Sort Stage 2 (Step 4-6, 3 级 CAS 串联):
  Step 4: distance-4  → Phase 3 开始
  Step 5: distance-2
  Step 6: distance-1  → 形成有序 8 元组

Sort Stage 3 (Step 7-10, 4 级 CAS 串联):
  Step 7:  distance-8 → Phase 4 开始（最终归并）
  Step 8:  distance-4
  Step 9:  distance-2
  Step 10: distance-1 → 完整升序排列
```

**时序评估：**
- 每个 CAS（64-bit 比较 + 2:1 mux）：约 200-280ps（28nm 工艺估算）
- Stage 6/7（3 级串联）：约 600-840ps，满足 1GHz
- Stage 8（4 级串联）：约 800-1120ps，时序较紧；若综合后不满足，可将 Steps 7-10 拆分为 2+2 两拍（总排序变 4 拍，总流水仍 ≤13 拍，余量充足）

寄存器数量对比：
- 原方案（每级一拍）：10 级 × 16 路 × (64+4) bit = 10,880 bit
- 新方案（3 拍）：3 级 × 16 路 × 68 bit = **3,264 bit**，减少约 **70%**

**compare-swap 比较规则：**
1. 先比 square 值（64 bit 无符号比较）
2. 值相同时，按原始索引（4 bit）升序排列（tie-breaker）

---

## 3. 模块划分

每个文件只包含一个 module，封装为可复用小 IP。

| 文件 | 模块名 | 功能 | 实例化数量 |
|------|--------|------|-----------|
| `deu_design.v` | `deu_design` | 顶层模块，流水线连接 | 1 |
| `sliv_decoder.v` | `sliv_decoder` | SLIV → S/L → position mask → bitmap | 1 |
| `decomp_square.v` | `decomp_square` | 单通道：解压缩 + 求平方（val16² << shift） | 16 |
| `compare_swap.v` | `compare_swap` | 比较交换单元（排序基本单元，纯组合逻辑） | 80（10步×8个，无寄存器） |
| `bitonic_sort.v` | `bitonic_sort` | 16 路 **3 级流水**双调排序网络（含索引） | 1 |

### 3.1 各模块接口概要

#### `sliv_decoder`
```
输入：sliv[6:0]
输出：bitmap[15:0]
```

#### `decomp_square`
```
输入：cmp_data[19:0]
输出：square[63:0]   // val16² << 2*(exp-1)，已忽略符号
```

#### `compare_swap`
```
输入：
  din_a[63:0], idx_a[3:0], vld_a
  din_b[63:0], idx_b[3:0], vld_b
  dir（排序方向：升序/降序）
输出：
  dout_lo[63:0], idx_lo[3:0]   // 较小值
  dout_hi[63:0], idx_hi[3:0]   // 较大值
```

#### `bitonic_sort`
```
输入：
  clk, rst_n
  i_vld_bitmap[15:0]
  i_data[15:0][63:0]   // 16路 square 值（无效通道已填 MAX）
  i_idx[15:0][3:0]     // 16路原始索引 0~15
输出：
  o_sorted_data[15:0][63:0]
  o_sorted_idx[15:0][3:0]
  o_out_vld[15:0]
```

---

## 4. 关键设计注意事项

### 4.1 流水线对齐
- bitmap 从 Stage 2 输出，需要打拍对齐到 Stage 5（square + mask 注入阶段）
- 原始索引 `idx = 0~15` 需随数据全程跟随流水线

### 4.2 时序关键路径
- **16×16 乘法器**：1GHz 下拆为 2 拍，方案中已固定为 Stage 4 占 2 个时钟
- **排序 Stage 8（4 级 CAS 串联）**：是全设计关键路径，约 800-1120ps，综合时需重点关注；若不满足，将 Steps 7-10 拆为 2+2 两拍（Stage 8a / Stage 8b），总流水 ≤13 拍，仍满足要求

### 4.3 相同模方值的排序
- compare_swap 中，当 `a_square == b_square` 时，比较 `a_idx` 和 `b_idx`，索引小的排前面

### 4.4 无效数据处理
- `bitmap[i] == 0` 的通道，在进入排序前将 square 值设为 `64'hFFFF_FFFF_FFFF_FFFF`
- 排序后这些数据自然排到高位（o_dout14, o_dout15...），对应 o_out_vld 为 0
- o_out_vld 由 `popcount(bitmap)` 决定：有效数量 K，则 `o_out_vld = (1 << K) - 1`

### 4.5 寄存器要求
- **reg_in**：除 `i_data_vld` 外，所有输入信号在 Stage 1 寄存
- **reg_out**：所有输出信号在 Stage 17 寄存输出
- 所有缓存用 reg 实现，禁止使用 memory 和 latch

---

## 5. 文件列表（filelist）

```
// filelist.f（使用绝对路径）
/project/DEU/rtl/sliv_decoder.v
/project/DEU/rtl/decomp_square.v
/project/DEU/rtl/compare_swap.v
/project/DEU/rtl/bitonic_sort.v
/project/DEU/rtl/deu_design.v
```

---

## 6. 后续实现步骤

1. 实现 `sliv_decoder.v`：纯组合逻辑，验证 S=2/L=8 的交织示例
2. 实现 `decomp_square.v`：解压缩 + val16² + 桶形移位，验证边界值
3. 实现 `compare_swap.v`：带 tie-breaker 的 64-bit 比较交换
4. 实现 `bitonic_sort.v`：10 级流水双调排序网络
5. 实现顶层 `deu_design.v`：拼接所有模块，管理流水线寄存和对齐
6. 输出 filelist.f
