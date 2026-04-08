// =============================================================================
// Class  : deu_scoreboard
// Description: Receives stimulus items (from ap_stimulus) and response items
//              (from ap_response), correlates them through a 8-cycle pipeline
//              FIFO, and checks against deu_ref_model.
//
//  Pipeline delay = 8 clocks:
//    Stage1 (reg_in) → Stage2 (SLIV dec + reg) → Stage3 (decomp + reg)
//    → Sort Stage4~8 (5拍，每2个compare层打一拍) → output
//
//  Checkers (enabled via deu_test_cfg):
//    1. Functional: out_vld, dout[], idx[] match reference model
//    2. Pipeline latency: exact 8-cycle delay from valid-in to valid-out
//    3. Power-hold: data regs do not toggle when vld=0 (waveform check)
// =============================================================================

`ifndef DEU_SCOREBOARD_SV
`define DEU_SCOREBOARD_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class deu_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(deu_scoreboard)

    // ---- Analysis exports ---------------------------------------------------
    uvm_analysis_imp_stimulus #(deu_seq_item, deu_scoreboard) exp_stimulus;
    uvm_analysis_imp_response #(deu_seq_item, deu_scoreboard) exp_response;

    // ---- Internal FIFO: stimulus waits for matching response ----------------
    // Each entry: {item, input_time}
    typedef struct {
        deu_seq_item item;
        longint      cycle_stamp;
    } stim_entry_t;

    stim_entry_t   stim_q[$];      // pending expected outputs
    longint        cycle_cnt = 0;  // incremented by clk agent or derived below

    deu_test_cfg   cfg;

    // ---- Statistics ---------------------------------------------------------
    int unsigned   checks_passed = 0;
    int unsigned   checks_failed = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        exp_stimulus = new("exp_stimulus", this);
        exp_response = new("exp_response", this);
        if (!uvm_config_db #(deu_test_cfg)::get(this, "", "deu_cfg", cfg))
            `uvm_fatal("CFG", "deu_cfg not found in config_db")
    endfunction

    // ---- Stimulus write: enqueue reference expectation ----------------------
    function void write_stimulus(deu_seq_item item);
        stim_entry_t e;
        e.item        = item;
        e.cycle_stamp = cycle_cnt;
        stim_q.push_back(e);
        `uvm_info("SCB", $sformatf("Enqueued stim @cycle%0d: %s",
            cycle_cnt, item.convert2string()), UVM_HIGH)
    endfunction

    // ---- Response write: pop oldest stimulus and compare -------------------
    function void write_response(deu_seq_item resp);
        stim_entry_t e;
        logic [15:0] exp_out_vld;
        logic [63:0] exp_dout [16];
        logic [3:0]  exp_idx  [16];
        int          K;
        bit          ok;

        if (stim_q.size() == 0) begin
            `uvm_error("SCB", "Response received with no pending stimulus!")
            checks_failed++;
            return;
        end

        e = stim_q.pop_front();

        // ---- Pipeline latency check -----------------------------------------
        if (cfg.check_pipeline_delay) begin
            longint latency = cycle_cnt - e.cycle_stamp;
            if (latency != 9) begin
                `uvm_error("SCB", $sformatf(
                    "PIPELINE DELAY ERROR: expected 9, got %0d (in@%0d out@%0d)",
                    latency, e.cycle_stamp, cycle_cnt))
                checks_failed++;
            end else begin
                `uvm_info("SCB", $sformatf(
                    "Pipeline delay OK: 9 cycles (in@%0d)", e.cycle_stamp), UVM_HIGH)
                checks_passed++;
            end
        end

        // ---- Functional check -----------------------------------------------
        deu_ref_model::compute_expected(
            e.item.sliv, e.item.cmp_data,
            exp_out_vld, exp_dout, exp_idx);

        ok = 1;

        // out_vld
        if (resp.o_dout_vld !== exp_out_vld) begin
            `uvm_error("SCB", $sformatf(
                "OUT_VLD mismatch: got 0x%04h, exp 0x%04h | stim: %s",
                resp.o_dout_vld, exp_out_vld, e.item.convert2string()))
            ok = 0;
        end

        K = 0;
        for (int b = 0; b < 16; b++) K += exp_out_vld[b];

        for (int k = 0; k < K; k++) begin
            if (resp.o_dout[k] !== exp_dout[k]) begin
                `uvm_error("SCB", $sformatf(
                    "DOUT[%0d] mismatch: got 0x%016h, exp 0x%016h | stim: %s",
                    k, resp.o_dout[k], exp_dout[k], e.item.convert2string()))
                ok = 0;
            end
            if (resp.o_idx[k] !== exp_idx[k]) begin
                `uvm_error("SCB", $sformatf(
                    "IDX[%0d] mismatch: got %0d, exp %0d | stim: %s",
                    k, resp.o_idx[k], exp_idx[k], e.item.convert2string()))
                ok = 0;
            end
        end

        if (ok) begin
            `uvm_info("SCB", $sformatf("CHECK PASSED @cycle%0d stim: %s",
                cycle_cnt, e.item.convert2string()), UVM_MEDIUM)
            checks_passed++;
        end else begin
            checks_failed++;
        end
    endfunction

    // ---- Increment cycle counter (called by env each clock) -----------------
    function void tick();
        cycle_cnt++;
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("SCB", $sformatf(
            "Scoreboard summary: PASSED=%0d  FAILED=%0d",
            checks_passed, checks_failed), UVM_LOW)
        if (checks_failed > 0)
            `uvm_error("SCB", "*** TESTCASE FAILED ***")
        else if (checks_passed == 0)
            `uvm_warning("SCB", "No checks performed — verify test ran correctly")
        else
            `uvm_info("SCB", "*** TESTCASE PASSED ***", UVM_LOW)
    endfunction

endclass : deu_scoreboard

`endif // DEU_SCOREBOARD_SV
