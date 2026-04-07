// =============================================================================
// Class  : deu_ref_model
// Description: Pure-SystemVerilog reference model matching the Python spec
//              in test_plan.md §5.  All arithmetic is integer (no float).
//
//   Step 1: SLIV → 16-bit bitmap
//   Step 2: decomp + square per channel
//   Step 3: sort with MAX-fill and tie-breaker (stable on idx)
//   Step 4: build expected out_vld and sorted arrays
// =============================================================================

`ifndef DEU_REF_MODEL_SV
`define DEU_REF_MODEL_SV

class deu_ref_model;

    // -------------------------------------------------------------------------
    // Step 1: SLIV → bitmap  (mirrors sliv_decoder.v)
    // -------------------------------------------------------------------------
    static function logic [15:0] sliv_to_bitmap(logic [6:0] sliv);
        logic [2:0] m;
        logic [3:0] n;
        logic [4:0] m_plus_n;
        logic [3:0] S;
        logic [4:0] L, S_ext, S_end;
        logic [15:0] pos_mask, bm;
        int j;

        m       = sliv[6:4];
        n       = sliv[3:0];
        m_plus_n = {2'b00, m} + {1'b0, n};

        if (m_plus_n <= 15) begin
            S = n;
            L = {2'b00, m} + 5'd1;
        end else begin
            S = 4'd15 - n;
            L = 5'd17  - {2'b00, m};
        end

        S_ext = {1'b0, S};
        S_end = S_ext + L;

        for (j = 0; j < 16; j++) begin
            pos_mask[j] = (j >= S_ext) && (j < S_end);
        end

        // 4×4 column-out interleave — matches RTL bitmap assignment
        bm = {pos_mask[15], pos_mask[11], pos_mask[ 7], pos_mask[ 3],
              pos_mask[14], pos_mask[10], pos_mask[ 6], pos_mask[ 2],
              pos_mask[13], pos_mask[ 9], pos_mask[ 5], pos_mask[ 1],
              pos_mask[12], pos_mask[ 8], pos_mask[ 4], pos_mask[ 0]};
        return bm;
    endfunction

    // -------------------------------------------------------------------------
    // Step 2: decomp_square  (mirrors decomp_square.v)
    // -------------------------------------------------------------------------
    static function logic [63:0] decomp_square(logic [19:0] cmp_data);
        logic [3:0]  exp;
        logic [14:0] data;
        logic [15:0] val16;
        logic [31:0] prod;
        logic [4:0]  shift_amt;

        exp  = cmp_data[19:16];
        data = cmp_data[14:0];

        val16     = (|exp) ? {1'b1, data} : {1'b0, data};
        prod      = val16 * val16;
        shift_amt = (|exp) ? (({1'b0, exp} - 5'd1) << 1) : 5'd0;
        return ({32'b0, prod} << shift_amt);
    endfunction

    // -------------------------------------------------------------------------
    // Step 3 + 4: Sort with MAX-fill, tie-breaker on idx
    //   Returns expected out_vld and sorted square/idx arrays.
    //   Sorting is ascending (lowest square first, tie → lowest idx first).
    // -------------------------------------------------------------------------
    static function void compute_expected(
        input  logic [6:0]  sliv,
        input  logic [19:0] cmp_data [16],
        output logic [15:0] exp_out_vld,
        output logic [63:0] exp_dout  [16],
        output logic [3:0]  exp_idx   [16]
    );
        logic [15:0] bitmap;
        logic [63:0] sq [16];
        logic [63:0] s_sq  [16];
        logic [3:0]  s_idx [16];
        logic [63:0] MAX64 = 64'hFFFF_FFFF_FFFF_FFFF;
        logic [63:0] key_sq;
        logic [3:0]  key_idx;
        int i, j, popcnt;

        // Populate squares; invalid channels get MAX
        bitmap = sliv_to_bitmap(sliv);
        for (i = 0; i < 16; i++) begin
            sq[i] = bitmap[i] ? decomp_square(cmp_data[i]) : MAX64;
        end

        // Insertion sort (N=16, fine for ref model)
        // Carry original indices alongside
        for (i = 0; i < 16; i++) begin
            s_sq[i]  = sq[i];
            s_idx[i] = i[3:0];
        end

        for (i = 1; i < 16; i++) begin
            key_sq  = s_sq[i];
            key_idx = s_idx[i];
            j = i - 1;
            while (j >= 0 &&
                   ((s_sq[j] > key_sq) ||
                    ((s_sq[j] == key_sq) && (s_idx[j] > key_idx)))) begin
                s_sq [j+1] = s_sq [j];
                s_idx[j+1] = s_idx[j];
                j--;
            end
            s_sq [j+1] = key_sq;
            s_idx[j+1] = key_idx;
        end

        // Build out_vld: popcount(bitmap) LSBs are 1
        popcnt = 0;
        for (i = 0; i < 16; i++) popcnt += bitmap[i];
        exp_out_vld = (popcnt == 16) ? 16'hFFFF : ((16'h1 << popcnt) - 1);

        for (i = 0; i < 16; i++) begin
            exp_dout[i] = s_sq [i];
            exp_idx [i] = s_idx[i];
        end
    endfunction

endclass : deu_ref_model

`endif // DEU_REF_MODEL_SV
