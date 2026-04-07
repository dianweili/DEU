// =============================================================================
// Class  : deu_agent
// Description: Active UVM agent — contains driver, monitor, sequencer
// =============================================================================

`ifndef DEU_AGENT_SV
`define DEU_AGENT_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class deu_agent extends uvm_agent;
    `uvm_component_utils(deu_agent)

    deu_driver                    drv;
    deu_monitor                   mon;
    uvm_sequencer #(deu_seq_item) seqr;

    uvm_analysis_port #(deu_seq_item) ap_stimulus;
    uvm_analysis_port #(deu_seq_item) ap_response;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv  = deu_driver::type_id::create("drv",  this);
        mon  = deu_monitor::type_id::create("mon",  this);
        seqr = uvm_sequencer #(deu_seq_item)::type_id::create("seqr", this);
        ap_stimulus = new("ap_stimulus", this);
        ap_response = new("ap_response", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        drv.seq_item_port.connect(seqr.seq_item_export);
        mon.ap_stimulus.connect(ap_stimulus);
        mon.ap_response.connect(ap_response);
    endfunction

endclass : deu_agent

`endif // DEU_AGENT_SV
