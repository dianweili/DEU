// =============================================================================
// Class  : deu_env
// Description: Top-level UVM environment. Fixed structure — never modified
//              for individual test cases. All variation flows through cfg.
// =============================================================================

`ifndef DEU_ENV_SV
`define DEU_ENV_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class deu_env extends uvm_env;
    `uvm_component_utils(deu_env)

    deu_agent      agent;
    deu_scoreboard scoreboard;
    deu_test_cfg   cfg;

    // Provide access to the sequencer for tests
    uvm_sequencer #(deu_seq_item) seqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Retrieve cfg (test must set it before build)
        if (!uvm_config_db #(deu_test_cfg)::get(this, "", "deu_cfg", cfg))
            `uvm_fatal("CFG", "deu_cfg not found")

        // Propagate cfg down to sub-components
        uvm_config_db #(deu_test_cfg)::set(this, "agent.drv",  "deu_cfg", cfg);
        uvm_config_db #(deu_test_cfg)::set(this, "scoreboard", "deu_cfg", cfg);

        agent      = deu_agent::type_id::create("agent",      this);
        scoreboard = deu_scoreboard::type_id::create("scoreboard", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        agent.ap_stimulus.connect(scoreboard.exp_stimulus);
        agent.ap_response.connect(scoreboard.exp_response);
        seqr = agent.seqr;
    endfunction

    // Called by a clocking process or test to advance scoreboard cycle counter
    function void tick();
        scoreboard.tick();
    endfunction

endclass : deu_env

`endif // DEU_ENV_SV
