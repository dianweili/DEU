// =============================================================================
// Class  : deu_base_seq
// Description: Base sequence. Reads cfg and drives the appropriate stimulus.
//              All test-case differentiation is achieved by the cfg object —
//              no new sequence class is needed for most directed cases.
//
//  Derived sequences (for complex patterns) are also in this file:
//    deu_directed_seq  — replays items from a cfg-specified list
//    deu_random_seq    — fully random for cfg.num_transactions cycles
// =============================================================================

`ifndef DEU_BASE_SEQ_SV
`define DEU_BASE_SEQ_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

// ---------------------------------------------------------------------------
// deu_base_seq — drives one item built from cfg
// ---------------------------------------------------------------------------
class deu_base_seq extends uvm_sequence #(deu_seq_item);
    `uvm_object_utils(deu_base_seq)

    deu_test_cfg cfg;

    function new(string name = "deu_base_seq");
        super.new(name);
    endfunction

    task body();
        deu_seq_item item;
        int n_txns;

        if (cfg == null) begin
            `uvm_fatal("SEQ", "cfg not set on deu_base_seq")
        end

        n_txns = (cfg.num_transactions > 0) ? cfg.num_transactions : 1;

        repeat (n_txns) begin
            item = deu_seq_item::type_id::create("item");
            start_item(item);

            // SLIV: either fixed (from cfg) or randomised
            if (cfg.sliv_fixed >= 0 && cfg.sliv_fixed <= 127) begin
                item.sliv = cfg.sliv_fixed[6:0];
                // disable constraint so we can set directly
                item.c_sliv_range.constraint_mode(0);
            end

            // Data: either fixed or randomised
            if (cfg.use_fixed_cmp_data) begin
                foreach (item.cmp_data[i])
                    item.cmp_data[i] = cfg.fixed_cmp_data[i];
                item.c_cmp_data_range.constraint_mode(0);
            end

            if (!item.randomize())
                `uvm_fatal("SEQ", "Randomization failed")

            // Re-apply fixed values after randomize (in case constraint was off)
            if (cfg.sliv_fixed >= 0 && cfg.sliv_fixed <= 127)
                item.sliv = cfg.sliv_fixed[6:0];
            if (cfg.use_fixed_cmp_data)
                foreach (item.cmp_data[i])
                    item.cmp_data[i] = cfg.fixed_cmp_data[i];

            finish_item(item);

            // For VLD_TOGGLE and VLD_RANDOM patterns, insert idle cycles
            if (cfg.vld_pattern == VLD_TOGGLE) begin
                repeat (1) begin
                    item = deu_seq_item::type_id::create("idle");
                    // driver will assert vld=0 for this item via pattern logic
                    start_item(item);
                    void'(item.randomize());
                    finish_item(item);
                end
            end
        end

        // Drain pipeline: 6 extra idle cycles so last output exits
        repeat (6) begin
            item = deu_seq_item::type_id::create("drain");
            start_item(item);
            void'(item.randomize());
            // Force vld=0: handled by driver seeing no pending scoreboard items
            // (scoreboard only enqueues when monitor sees i_data_vld=1)
            finish_item(item);
        end
    endtask

endclass : deu_base_seq

`endif // DEU_BASE_SEQ_SV
