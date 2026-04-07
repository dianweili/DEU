// =============================================================================
// Class  : deu_base_test
// Description: Base UVM test. Creates env + cfg, loads cfg from file
//              (+cfg=<path>) or leaves defaults, then runs deu_base_seq.
//              Derived tests override cfg values for specific scenarios.
//
// Usage:
//   +UVM_TESTNAME=deu_base_test  +cfg=cfg/sanity.cfg
//   +UVM_TESTNAME=deu_sanity_test
//   +UVM_TESTNAME=deu_random_test  +cfg=cfg/random_full.cfg
// =============================================================================

`ifndef DEU_BASE_TEST_SV
`define DEU_BASE_TEST_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class deu_base_test extends uvm_test;
    `uvm_component_utils(deu_base_test)

    deu_env      env;
    deu_test_cfg cfg;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Create cfg, load from file (no-op if +cfg not given)
        cfg = deu_test_cfg::type_id::create("cfg");
        cfg.load_from_file();

        // Allow sub-class to override before env sees it
        configure_test();

        // Publish cfg so env and sub-components can retrieve it
        uvm_config_db #(deu_test_cfg)::set(this, "*", "deu_cfg", cfg);

        // Propagate vif from parent scope → agent
        begin
            virtual deu_if vif;
            if (!uvm_config_db #(virtual deu_if)::get(this, "", "deu_vif", vif))
                `uvm_fatal("CFG", "deu_vif not found")
            uvm_config_db #(virtual deu_if)::set(this, "*", "deu_vif", vif);
        end

        env = deu_env::type_id::create("env", this);
    endfunction

    // Sub-classes override this to set cfg fields programmatically
    virtual function void configure_test();
    endfunction

    task run_phase(uvm_phase phase);
        deu_base_seq seq;
        virtual deu_if vif;

        phase.raise_objection(this);

        if (!uvm_config_db #(virtual deu_if)::get(this, "", "deu_vif", vif))
            `uvm_fatal("RUN", "deu_vif not found in run_phase")

        // ---- Reset sequence -------------------------------------------------
        vif.drv_cb.rst_n       <= 1'b0;
        vif.drv_cb.i_data_vld  <= 1'b0;
        repeat (5) @(vif.drv_cb);
        vif.drv_cb.rst_n <= 1'b1;
        repeat (2) @(vif.drv_cb);

        // ---- Clock-tick loop for scoreboard ---------------------------------
        fork
            forever begin
                @(vif.mon_cb);
                env.tick();
            end
        join_none

        // ---- Main stimulus --------------------------------------------------
        seq     = deu_base_seq::type_id::create("seq");
        seq.cfg = cfg;
        seq.start(env.seqr);

        // Let outputs drain
        repeat (10) @(vif.drv_cb);

        phase.drop_objection(this);
    endtask

endclass : deu_base_test

// =============================================================================
// deu_sanity_test
// Description: P0 sanity case — README standard example (SLIV=114, S=2,L=8).
//              Passes fixed data that produces known sorted output.
//              Used to quickly smoke-check RTL after any modification.
//
// Expected (from test_plan.md DT-01):
//   bitmap = 16'h3366, 8 valid channels, 8-cycle latency, o_out_vld=8'hFF
// =============================================================================
class deu_sanity_test extends deu_base_test;
    `uvm_component_utils(deu_sanity_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void configure_test();
        cfg.test_mode            = MODE_DIRECTED;
        cfg.num_transactions     = 1;
        cfg.sliv_fixed           = 114;      // S=2, L=8 → bitmap=16'h3366
        cfg.vld_pattern          = VLD_ALWAYS_HIGH;
        cfg.check_pipeline_delay = 1;
        cfg.check_power_hold     = 0;
        // Use fixed deterministic data (ascending, so sort output = input order)
        cfg.use_fixed_cmp_data   = 1;
        // 8 active channels (data1,2,5,6,8,9,12,13 from bitmap 16'h3366)
        // Give them increasing square values: exp=0, data=k+1
        foreach (cfg.fixed_cmp_data[i])
            cfg.fixed_cmp_data[i] = {4'h0, 1'b0, 15'(i + 1)};
        `uvm_info("TEST", "Sanity test configured: SLIV=114 fixed ascending data", UVM_LOW)
    endfunction

endclass : deu_sanity_test

// =============================================================================
// deu_random_test
// Description: Fully random regression test.  All parameters come from cfg
//              file — defaults to 1000 transactions if no +cfg given.
// =============================================================================
class deu_random_test extends deu_base_test;
    `uvm_component_utils(deu_random_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void configure_test();
        // Only set defaults — file overrides if present
        if (cfg.test_mode != MODE_RANDOM) begin
            cfg.test_mode        = MODE_RANDOM;
            cfg.num_transactions = 1000;
        end
        cfg.check_pipeline_delay = 1;
        `uvm_info("TEST", $sformatf(
            "Random test: %0d transactions", cfg.num_transactions), UVM_LOW)
    endfunction

endclass : deu_random_test

`endif // DEU_BASE_TEST_SV
