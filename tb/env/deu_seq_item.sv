// =============================================================================
// Class  : deu_seq_item
// Description: UVM sequence item — one pipeline transaction (one valid cycle)
// =============================================================================

`ifndef DEU_SEQ_ITEM_SV
`define DEU_SEQ_ITEM_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class deu_seq_item extends uvm_sequence_item;
    `uvm_object_utils_begin(deu_seq_item)
        `uvm_field_int(sliv,        UVM_ALL_ON)
        `uvm_field_sarray_int(cmp_data, UVM_ALL_ON)
    `uvm_object_utils_end

    // ---- Stimulus fields ----------------------------------------------------
    rand logic [6:0]  sliv;              // 7-bit SLIV
    rand logic [19:0] cmp_data [16];     // compressed data, one per channel

    // ---- Response fields (filled by monitor) --------------------------------
    logic [15:0] o_out_vld;
    logic [63:0] o_dout  [16];
    logic [3:0]  o_idx   [16];

    // ---- Constraints --------------------------------------------------------
    constraint c_sliv_range {
        sliv inside {[7'h00 : 7'h7F]};
    }

    constraint c_cmp_data_range {
        foreach (cmp_data[i]) {
            cmp_data[i][19:16] inside {[4'h0 : 4'hF]};  // exp 0-15
            // sign = cmp_data[i][15] : unconstrained
            cmp_data[i][14:0] inside {[15'h0 : 15'h7FFF]};
        }
    }

    function new(string name = "deu_seq_item");
        super.new(name);
    endfunction

    function string convert2string();
        string s;
        s = $sformatf("SLIV=0x%02h", sliv);
        foreach (cmp_data[i])
            s = {s, $sformatf(" d%0d=0x%05h", i, cmp_data[i])};
        return s;
    endfunction

endclass : deu_seq_item

`endif // DEU_SEQ_ITEM_SV
