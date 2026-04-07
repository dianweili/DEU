# DEU UVM 验证平台指南

## 概述

这是针对 DEU（数据提取单元）设计的 UVM 1.2 验证平台，实现了 `test_plan.md` 中的验证计划。该验证平台采用**配置驱动**方式：所有测试行为均通过 `deu_test_cfg` 对象控制，永不修改验证环境代码。

---

## 运行测试

### 快速开始（P0 sanity）
```bash
make sanity
```

预期输出：
```
UVM_INFO @ 0 ns [root] : Sanity test configured: SLIV=114 fixed ascending data
UVM_INFO @ time_X [deu_env] : Scoreboard summary: PASSED=1  FAILED=0
UVM_INFO @ time_X [SCB] : *** TESTCASE PASSED ***
```

### 定向测试（例如 DT-01）
```bash
make directed CFG=../tb/cfg/directed_dt01.cfg
```

### 随机回归（100000 个事务）
```bash
make random CFG=../tb/cfg/random_full.cfg
```

输出示例：
- `Enqueued stim @cycle X` — 每个输入激励（每个有效周期 1 个）
- `CHECK PASSED @cycle Y stim: SLIV=... d0=... d1=...` — 检查命中
- `Pipeline delay OK: 6 cycles` — 延迟验证（启用时）
- `Scoreboard summary: PASSED=M  FAILED=N` — 最终统计

### 带波形输出（VPD 格式，默认）
```bash
make waves TESTNAME=deu_sanity_test
```

打开波形查看器（VCS GUI）。用于深层调试。波形保存到 `sim/waves.vpd`。

### 带 FSDB 波形输出
```bash
make waves FSDB=1 TESTNAME=deu_sanity_test
```

使用 FSDB 格式（更紧凑、更快）。波形保存到 `sim/waves.fsdb`。需要 VCS 编译时支持 `-fsdb` 标志。

### 使用 Xcelium 而不是 VCS
```bash
make SIM=xcelium sanity
```

---

## 测试配置文件

位置：`tb/cfg/`

| 文件 | 用途 | 事务数 | 检查项 |
|------|------|--------|--------|
| `sanity.cfg` | P0 烟雾测试（SLIV=114） | 1 | 流水线延迟 + 功能 |
| `directed_dt01.cfg` | 测试计划 DT-01 标准用例 | 1 | 流水线延迟 + 功能 |
| `directed_full_valid.cfg` | 全 16 通道（SLIV=31） | 1 | 流水线延迟 |
| `pipeline_timing.cfg` | 连续 20 拍流 | 20 | 延迟 + 无气泡 |
| `random_full.cfg` | 回归测试（100k） | 100,000 | 功能检查 |
| `random_vld_toggle.cfg` | 稀疏有效模式（200k，50% 占空比） | 200,000 | 功能 + 功耗寄存器保持 |

你也可以创建新的 `.cfg` 文件 — 只需按照 KEY=VALUE 格式编辑。支持的键：

```
test_mode              SANITY | DIRECTED | RANDOM
num_transactions       <整数>
sliv_fixed             <0-127 或 -1 表示随机>
vld_pattern            ALWAYS_HIGH | TOGGLE | RANDOM
check_pipeline_delay   0 或 1
check_power_hold       0 或 1（波形检查）
max_cycles             <整数，0 表示无限>
```

---

## 数据流与信息输出

### 1. 激励入队（驱动器 → 监测器）

当采样到 `i_data_vld=1` 时，监测器捕获：
```
UVM_INFO / HIGH: Enqueued stim @cycle42: SLIV=0x72 d0=0x12345 d1=0x54321 ...
```

### 2. 响应检查（监测器 → 记分板）

6 个时钟周期后，当 `o_dout_vld != 0` 出现时，记分板：
- 从 FIFO 弹出最旧的激励
- 调用 `deu_ref_model::compute_expected()` 获取标准输出
- 比较 RTL 输出 vs. 标准输出

```
UVM_INFO / HIGH: CHECK PASSED @cycle48 stim: SLIV=0x72 d0=0x12345 ...
```

如果不匹配：
```
UVM_ERROR: OUT_VLD mismatch: got 0x00FF, exp 0x0080 | stim: ...
UVM_ERROR: DOUT[0] mismatch: got 0x0000000000000123, exp 0x0000000000004567 | stim: ...
```

### 3. 流水线延迟检查

启用时（`check_pipeline_delay=1`），记分板验证输入→输出延迟：
```
UVM_INFO / HIGH: Pipeline delay OK: 6 cycles (in@42)
```

或报错：
```
UVM_ERROR: PIPELINE DELAY ERROR: expected 6, got 5 (in@42 out@47)
```

### 4. 最终报告

仿真结束时：
```
UVM_INFO: Scoreboard summary: PASSED=100000  FAILED=0
UVM_INFO: *** TESTCASE PASSED ***
```

或失败时：
```
UVM_ERROR: *** TESTCASE FAILED ***
```

---

## 测试清单

### P0（压倒性必过）
- **deu_sanity_test** — README 标准用例（SLIV=114，S=2，L=8，8 个通道）
  - 1 个事务，确定性递增数据
  - 快速烟雾测试（< 1秒），用于 RTL 编辑后的验证

### P1（高优先级）
- **DT-01** — 单拍，标准示例
- **DT-02** — 全 16 通道有效（SLIV=31）
- **DT-T01** — 精确 6 拍延迟  
- **DT-T02** — 连续 20 拍流（无输出气泡）
- **DT-D0X** — 数据边界用例（零、最大值、混合符号、exp 0–15）
- **DT-S0X** — SLIV 覆盖（0、114、31、120、127、47）

### P2（回归测试）
- **DT-R01** — 完全随机（100k 事务）
- **DT-R02** — 稀疏有效模式（200k 事务，TOGGLE 模式）

---

## 参考模型

记分板使用 `deu_ref_model`（位于 `tb/ref/deu_ref_model.sv`），这是 **test_plan.md §5** 中 Python 模型的 SystemVerilog 实现：

1. **`sliv_to_bitmap(sliv)`** — 将 7 位 SLIV 解码为 16 位有效掩码（匹配 `sliv_decoder.v`）
2. **`decomp_square(cmp_data)`** — 解压缩并平方一个通道（匹配 `decomp_square.v`）
3. **`compute_expected(sliv, cmp_data[], out_vld, dout[], idx[])`** — 完整流水线：
   - 填充平方值（无效通道 → 最大值）
   - 插入排序，按索引作为 tie-breaker
   - 返回升序排列的数组 + 有效掩码

记分板在每个 `o_dout_vld != 0` 周期将 RTL 输出与该参考实现进行比较。

---

## 架构

```
deu_tb_top
├── 接口（deu_if）
├── DUT（deu_design）
├── deu_env
│   ├── deu_agent
│   │   ├── deu_sequencer
│   │   ├── deu_driver → RTL 激励
│   │   └── deu_monitor → 捕获激励 & 响应
│   └── deu_scoreboard → 关联、比较、报告
└── deu_base_seq（由 cfg 驱动）
    └── deu_test（扩展 base，覆盖 cfg）
        ├── deu_sanity_test（P0）
        ├── deu_random_test
        └── 用户可通过扩展 deu_base_test 添加更多测试
```

---

## 典型调试工作流

1. **Sanity 意外失败？**
   ```bash
   make waves TESTNAME=deu_sanity_test
   # 打开波形，检查：
   # - 第 0-2 周期的 i_data_vld & i_data_sliv
   # - 6 个周期后的 o_dout_vld
   # - o_dout* 值是否匹配预期（从错误信息）
   ```

2. **随机测试发现 bug？**
   - 记分板打印失败的激励（SLIV + 全部 16 个 cmp_data）
   - 用定向测试 + 相同数据重现
   - 详细检查波形

3. **流水线延迟错误？**
   - 检查：RTL 是否恰好有 6 级流水线？
   - `deu_design` 级级：r1（输入） → r2（dec） → r3（decomp） → sort（3 级） → r_out
   - 若延迟改变，更新记分板检查或 RTL

---

## 高级：添加自定义测试

### 方式 1：新的配置文件
```bash
# tb/cfg/my_test.cfg
test_mode        = DIRECTED
num_transactions = 5
sliv_fixed       = 99
vld_pattern      = ALWAYS_HIGH
check_pipeline_delay = 1
```

然后运行：
```bash
make directed CFG=../tb/cfg/my_test.cfg
```

### 方式 2：新的测试类
编辑 `tb/test/deu_base_test.sv`，添加：
```systemverilog
class deu_my_test extends deu_base_test;
    `uvm_component_utils(deu_my_test)

    function void configure_test();
        cfg.test_mode = MODE_DIRECTED;
        cfg.num_transactions = 10;
        cfg.sliv_fixed = 99;
        // ... 设置其他 cfg 字段
    endfunction
endclass
```

运行：
```bash
+UVM_TESTNAME=deu_my_test make run
```

---

## Makefile 目标

```bash
make sanity                                    # P0（默认）
make directed CFG=<文件>                      # +cfg=<文件>
make random   CFG=<文件>                      # 随机测试
make run TESTNAME=<名称> CFG=<文件>           # 任意组合
make waves                                    # 打开 GUI（VPD 格式）
make waves FSDB=1                             # 打开 GUI（FSDB 格式）
make clean                                    # 清除编译产物
make help                                     # 显示所有目标
```

## 波形格式

**VPD**（默认）：
```bash
make sanity FSDB=0          # 输出到 sim/waves.vpd
```
- VCS 原生格式
- 文件较大
- 兼容性好

**FSDB**（可选）：
```bash
make sanity FSDB=1          # 输出到 sim/waves.fsdb
```
- 更紧凑的格式
- 加载和搜索更快
- 需要 VCS 编译时 `-fsdb` 支持（通常已提供）

示例：
```bash
make sanity FSDB=1                             # P0 smoke, FSDB output
make directed CFG=tb/cfg/directed_dt01.cfg FSDB=1  # 定向测试, FSDB
make waves FSDB=1 TESTNAME=deu_sanity_test    # 带 GUI 的 FSDB
```

---

## 预期通过标准

| 阶段 | 标准 |
|------|------|
| P0 | sanity 测试：1 次通过，0 次失败（< 1 秒） |
| P1 | 所有定向测试（DT-01、DT-02、DT-Txx、DT-Dxx、DT-Sxx）通过 |
| P2 | 随机回归（100k 事务、200k toggle）通过，所有检查 ≥ 1000 次通过 |

---

## 故障排除

### "deu_vif not found in config_db"
- 确保 `deu_tb_top.sv` 已编译，并在模块初始化时在 `uvm_config_db` 中设置 vif。

### "cfg not found in config_db"
- 测试必须在 `build_phase` 中调用 `uvm_config_db #(deu_test_cfg)::set(this, "*", "deu_cfg", cfg)`。

### 记分板显示意外的 "Enqueued stim"，但没有匹配的检查
- 检查：激励是否被驱动（i_data_vld=1）？
- 检查：响应是否在时钟周期内（6 个周期后 o_dout_vld != 0）？
- 可能需要驱动更多空闲周期或检查 rst_n 状态。

### 随机测试挂起
- 在 cfg 中设置 `max_cycles` 限制以防止无限循环：`max_cycles = 500000`

---

## 文件位置

```
DEU/
├── rtl/              RTL 模块（不变）
├── tb/
│   ├── cfg/          .cfg 文件（编辑这些以配置测试）
│   ├── env/          驱动器、监测器、记分板、agent、环境
│   ├── ref/          参考模型
│   ├── seq/          基础序列
│   ├── test/         测试类（扩展以添加新测试）
│   └── top/          接口、包、顶层模块
└── sim/
    ├── Makefile      编译与运行命令
    └── run/          仿真产物（生成）
```

---

## RTL 变更前快速检查清单

1. 运行 sanity：
   ```bash
   make sanity
   ```
   应在约 1 秒内显示 `PASSED=1 FAILED=0`。

2. 若 sanity 失败，检查 RTL：
   - 流水线延迟仍为 6？
   - decomp/compare_swap 有新的阻断式 bug 吗？

3. 运行定向测试套（如果有时间）：
   ```bash
   for cfg in tb/cfg/directed*.cfg; do
       make directed CFG=$cfg || exit 1
   done
   ```

4. 提交信心：运行整夜随机测试
   ```bash
   make random CFG=tb/cfg/random_full.cfg
   ```

---

## 典型输出示例

**单个事务通过时：**
```
UVM_INFO @ 100 ns [deu_tb_top] : Sanity test configured: SLIV=114 fixed ascending data
UVM_INFO @ 500 ns [SCB] : Enqueued stim @cycle50: SLIV=0x72 d0=0x00001 d1=0x00002 ...
UVM_INFO @ 1100 ns [SCB] : CHECK PASSED @cycle56 stim: SLIV=0x72 d0=0x00001 ...
UVM_INFO @ 1100 ns [SCB] : Pipeline delay OK: 6 cycles (in@50)
UVM_INFO @ 2000 ns [SCB] : Scoreboard summary: PASSED=1  FAILED=0
UVM_INFO @ 2000 ns [SCB] : *** TESTCASE PASSED ***
```

**多个事务随机测试：**
```
UVM_INFO [SCB] : Enqueued stim @cycle100: SLIV=0xAB d0=0x1A2B3 ...
UVM_INFO [SCB] : CHECK PASSED @cycle106 stim: SLIV=0xAB ...
UVM_INFO [SCB] : Pipeline delay OK: 6 cycles (in@100)
...（重复数千次）...
UVM_INFO [SCB] : Scoreboard summary: PASSED=100000  FAILED=0
UVM_INFO [SCB] : *** TESTCASE PASSED ***
```

**检查失败时：**
```
UVM_ERROR [SCB] : OUT_VLD mismatch: got 0x00FF, exp 0x00FE | stim: SLIV=0x5F ...
UVM_ERROR [SCB] : FAILED=1
UVM_ERROR [SCB] : *** TESTCASE FAILED ***
```

---
