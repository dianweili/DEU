// Gate-Level Simulation filelist
// Replaces RTL sources with: synthesized netlist + ASAP7 RVT cell models

// ---- UVM ---------------------------------------------------------------
+incdir+/data/synopsys/vcs_all_vW-2024.09-SP1/vcs/W-2024.09-SP1/etc/uvm-ieee
/data/synopsys/vcs_all_vW-2024.09-SP1/vcs/W-2024.09-SP1/etc/uvm-ieee/uvm_pkg.sv

// ---- ASAP7 RVT Verilog cell models (behavioral + specify timing) --------
/data/project/pdk/asap7/Verilog/asap7sc7p5t_INVBUF_RVT_TT_201020.v
/data/project/pdk/asap7/Verilog/asap7sc7p5t_SIMPLE_RVT_TT_201020.v
/data/project/pdk/asap7/Verilog/asap7sc7p5t_AO_RVT_TT_201020.v
/data/project/pdk/asap7/Verilog/asap7sc7p5t_OA_RVT_TT_201020.v
/data/project/pdk/asap7/Verilog/asap7sc7p5t_SEQ_RVT_TT_220101.v

// ---- Synthesized gate-level netlist ------------------------------------
/data/project/DEU/syn/netlist/deu_design_netlist.v

// ---- Testbench (same as RTL sim, DUT interface unchanged) --------------
+incdir+/data/project/DEU/netlist_sim/scripts
+incdir+/data/project/DEU/tb/top
+incdir+/data/project/DEU/tb/cfg
+incdir+/data/project/DEU/tb/env
+incdir+/data/project/DEU/tb/seq
+incdir+/data/project/DEU/tb/test
+incdir+/data/project/DEU/tb/ref

/data/project/DEU/tb/top/deu_if.sv
/data/project/DEU/netlist_sim/scripts/gls_tb_top.sv
