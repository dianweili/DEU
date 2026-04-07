# DEU设计

## 1 题目介绍

### 1.1 功能描述

![](.\DEU1.svg)

DEU（Data Extract Unit）模块完成对输入数据抽取、解压缩、求模方（求平方）、挤气泡、排序输出功能。内部功能示意图如下图所示：

![image-20260402201811462](.\DEU2.svg)

功能详细描述如下：

1. 验证环境每拍输入16个压缩数据cmp_data及SLIV（Start and Length Indicator Value）信息。cmp_data索引为0~15。格式详见接口信号描述。
2. 根据SLIV信息，按照SLIV解析规则可以解析出16个压缩数据的有效性指示，即16bit的data_vld_bitmap，其中bit域为1的cmp_data称为有效压缩数据。
3. 根据data_vld_bitmap结果，抽取相应的有效压缩数据。
4. 将有效压缩数据进行解压缩运算及求模方（平方）运算。
5. 将模方运算结果从小到大进行排序输出，同时输出相应的索引。如果数据模方结果相同，按索引从小到大顺序排序。

### 1.2 接口信号

| 信号               | 位宽 | 方向 | 含义                                                         |
| ------------------ | ---- | ---- | ------------------------------------------------------------ |
| **全局信号**       |      |      |                                                              |
| clk                | 1    | I    | 时钟信号                                                     |
| rst_n              | 1    | I    | 复位信号，低有效，clk时钟域异步复位、同步撤离                |
| **Input接口信号**  |      |      |                                                              |
| i_data_vld         | 1    | I    | 输入数据有效指示，高电平有效。                               |
| i_data_sliv        | 7    | I    | 输入数据SLIV值。仅当i_data_vld为1时有效。                    |
| i_data0_in         | 20   | I    | 输入data0数据，包括4bit指数，1bit符号，15bit底数。解压方式详见解压缩说明小节。Bit[19:16]：指数位（4u，范围0~15）。Bit[15]：符号位。Bit[14:0]：底数位（15u，范围0~(2^15-1)）。 |
| i_data1_in         | 20   | I    | 输入data1数据，格式同上。                                    |
| ......             |      |      |                                                              |
| i_data15_in        | 20   | I    | 输入data15数据，格式同上。                                   |
| **Output接口信号** |      |      |                                                              |
| o_dout_vld         | 16   | O    | 输出数据有效性指示，高电平有效。Bit[15:0]：对应o_dout15 ~ o_dout0。o_dout_vld为0的bit域对应的输出数据及索引可以为任意值，不做比对验证。 |
| o_dout0            | 64   | O    | 输出数据0对应排序后模方值最小的数据。                        |
| o_dout1            | 64   | O    | 输出数据1对应排序后模方值次小的数据。                        |
| ......             |      |      |                                                              |
| o_dout15           | 64   | O    | 输出数据15对应排序后模方值最大的数据。                       |
| o_dout0_idx        | 4    | O    | 输出数据0对应的输入数据索引。                                |
| o_dout1_idx        | 4    | O    | 输出数据1对应的输入数据索引。                                |
| ......             |      |      |                                                              |
| o_dout15_idx       | 4    | O    | 输出数据15对应的输入数据索引。                               |

### 1.3 接口信号时序

```wavedrom
{
  signal: [
    {
      name: "clk",
      wave: "p.............|..............."
    },
    {
      name: "rst_n",
      wave: "0.1...........|..............."
    },
    ["Input",
      {
        name: "i_data_vld",
        wave: "0.....1.01....|..01....0......",
        node: "......a................c......",
      },
      {
        name: "i_data_sliv[6:0]",
        wave: "x.....34x34342|34x34343x......",
        data: "sliv sliv sliv sliv sliv sliv sliv sliv sliv sliv sliv sliv sliv sliv"
      },
      {
        name: "i_data0_in[19:0]",
        wave: "x.....34x34342|34x34343x......",
        data: "d0 d0 d0 d0 d0 d0 d0 d0 d0 d0 d0 d0 d0 d0"
      },
      {
        name: "i_data1_in[19:0]",
        wave: "x.....34x34342|34x34343x......",
        data: "d1 d1 d1 d1 d1 d1 d1 d1 d1 d1 d1 d1 d1 d1"
      },
      {
        name: "......",
        wave: "x.....34x34342|34x34343x......",
        data: "dx dx dx dx dx dx dx dx dx dx dx dx dx dx"
      },
      {
        name: "i_data15_in[19:0]",
        wave: "x.....34x34342|34x34343x......",
        data: "d15 d15 d15 d15 d15 d15 d15 d15 d15 d15 d15 d15 d15 d15",
        node: "......e................f......",
      },
    ],
     {},
     ["output",
      {
        name: "o_dout_vld",
        wave: "x........34x34342|34x34343x...",
        data: "vld vld vld vld vld vld vld vld vld vld vld vld vld vld ",
        node: ".........b................d...",
      },
      {
        name: "o_dout0[63:0]",
        wave: "x........34x34342|34x34343x...",
        data: "o0 o0 o0 o0 o0 o0 o0 o0 o0 o0 o0 o0 o0 o0"
      },
      {
        name: "o_dout1[63:0]",
        wave: "x........34x34342|34x34343x...",
        data: "o1 o1 o1 o1 o1 o1 o1 o1 o1 o1 o1 o1 o1 o1"
      },
      {
        name: "......",
        wave: "x........34x34342|34x34343x...",
        data: "ox ox ox ox ox ox ox ox ox ox ox ox ox ox"
      },
      {
        name: "o_dout15[63:0]",
        wave: "x........34x34342|34x34343x...",
        data: "o15 o15 o15 o15 o15 o15 o15 o15 o15 o15 o15 o15 o15 o15"
      },
      {
        name: "o_dout0_idx[3:0]",
        wave: "x........34x34342|34x34343x...",
        data: "idx0 idx0 idx0 idx0 idx0 idx0 idx0 idx0 idx0 idx0 idx0 idx0 idx0 idx0 "
      },
      {
        name: "o_dout1_idx[3:0]",
        wave: "x........34x34342|34x34343x...",
        data: "idx1 idx1 idx1 idx1 idx1 idx1 idx1 idx1 idx1 idx1 idx1 idx1 idx1 idx1"
      },
      {
        name: "......",
        wave: "x........34x34342|34x34343x...",
        data: "idxx idxx idxx idxx idxx idxx idxx idxx idxx idxx idxx idxx idxx idxx"
      },
      {
        name: "o_dout15_idx[3:0]",
        wave: "x........34x34342|34x34343x...",
        data: "idx15 idx15 idx15 idx15 idx15 idx15 idx15 idx15 idx15 idx15 idx15 idx15 idx15 idx15"
      },
     ]
  ],
  config: { hscale: 0.5 },
  edge: [
     'a~b',
     'e~b 0-40 cycle',
     'c~d',
     'f~d 0-40 cycle',
    ]
}
```

### 1.4 相关算法说明

#### 1 SLIV解析规则说明

SLIV解析data_vld_bitmap步骤：

1）根据SLIV值计算S（Start）及L（Length）信息。

2）对S及L值进行行列交织，得到data_vld_bitmap。

求解S/L伪代码：

```
m = floor[SLIV/16]; 
n = SLIV % 16;
if ((m+n) <= 15) {
	S = n;
	L = m + 1;
} 
else{
	S = 15 - n;
	L = 17 - m;
}
```

行列交织器（4X4行入列出）：S和L按行顺序输入，data_vld_bitmap以列顺序输出。

例如：S=2，L=8，S/L按行输入，占用交织器位置pos2~9。data_vld_bitmap输出对应的交织器位置为：pos15 / pos11 / pos7 / pos3 / ... / pos12 / pos8 / pos4 / pos0。即data_vld_bitmap = 16'b0011_0011_0110_0110，所以输入的有效压缩数据索引为1/2/5/6/8/9/12/13。

![image-20260403105401464](.\DEU3.svg)

#### 2 解压缩算法说明

##### 1）压缩数据格式

```
cmp_data[19:0] = {exp[3:0], sign, data[14:0]};
```

##### 2）解压缩算法流程

```
if (exp > 0) {
	decp_data_tmp = (data << (exp - 1)) + 2^(14 + exp);
} 
else {
	decp_data_tmp = data;
}

if (sign == 0) {
	decp_data = decp_data_tmp;
}
else {
	decp_data = - decp_data_tmp;
}

decp_data;
```



### 1.5 题目要求

1. 输入不设置反压（数据包可能连续不断输入）；
2. 要求40拍内完成流水运算并输出结果；
3. 频点固定1GHz，不可修改；
4. 输入信号除i_data_vld外均需要先寄存器后使用（reg_in），输出信号需要寄存器输出（reg_out）；
5. 缓存使用reg搭建，不允许使用memory和latch；
6. 模块名为deu_design。

## 2 方案提示

1. 选好排序算法；
2. 注意几个步骤的顺序，只要是结果等价的就行，不一定非要按照题目中的原始顺序做；
3. 为了减少代码量，把重复的电路封装成小IP；
4. 一个文件中只包含一个module，最终输出一个可编译的filelist，使用绝对路径。



---

## 3 工程规划

### 3.1 目录结构

```
DEU/
├── rtl/                    # RTL源文件
│   ├── deu_design.v        # 顶层模块（6拍流水线）
│   ├── bitonic_sort.v      # 双调排序网络（3级流水）
│   ├── decomp_square.v     # 解压缩+求平方
│   ├── sliv_decoder.v      # SLIV解码（位图生成）
│   ├── compare_swap.v      # 比较交换单元（排序基本单元）
│   └── filelist.f          # 文件列表（绝对路径）
├── tb/
│   ├── top/                # Testbench顶层（RTL仿真用）
│   └── ref/                # Python参考模型（golden比对）
├── sim/                    # RTL仿真
│   ├── scripts/            # VCS run脚本、Makefile
│   ├── run/                # 仿真中间文件（csrc、simv等）
│   └── waves/              # 波形文件（.fsdb/.vcd）
├── spyglass/               # SpyGlass静态检查
│   ├── scripts/            # .prj工程文件、run脚本
│   ├── run/                # SpyGlass执行目录
│   └── reports/            # lint/CDC/RDC报告
├── syn/                    # 综合（DC/Genus）
│   ├── scripts/            # TCL综合脚本
│   ├── run/                # 综合执行目录
│   ├── reports/            # 时序/面积/功耗报告
│   └── netlist/            # 输出网表（.v/.sdf）
├── formal/
│   └── lec/                # 逻辑等价检查（Conformal/Formality）
│       ├── scripts/
│       ├── run/
│       └── reports/
├── netlist_sim/            # 网表仿真（后仿）
│   ├── scripts/
│   ├── run/
│   └── waves/
└── constraints/            # SDC时序约束（syn/formal共用）
```

### 3.2 工程推进计划

| 阶段 | 内容 | 目录 |
|------|------|------|
| **Step 1** | 编写Testbench及Python参考模型 | `tb/` |
| **Step 2** | 配置VCS编译仿真脚本，RTL功能仿真 | `sim/` |
| **Step 3** | 配置SpyGlass工程，完成lint/CDC静态检查 | `spyglass/` |
| **Step 4** | 编写SDC时序约束，运行DC/Genus综合 | `constraints/` + `syn/` |
| **Step 5** | 运行Conformal/Formality逻辑等价检查 | `formal/lec/` |
| **Step 6** | 基于综合网表运行后仿（带SDF反标） | `netlist_sim/` |

### 3.3 关键设计参数

| 参数 | 值 |
|------|----|
| 时钟频率 | 1 GHz（周期1ns） |
| 流水线延迟 | 6拍 |
| 输入数据路数 | 16路，每路20bit |
| 输出数据路数 | 最多16路，每路64bit（平方值）+ 4bit（原始索引） |
| 排序算法 | Bitonic Sort，10步CAS分3个流水级 |
| 最大允许延迟 | 40拍（余量充足） |
