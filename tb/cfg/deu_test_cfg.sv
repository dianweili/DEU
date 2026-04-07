// =============================================================================
// Class  : deu_test_cfg
// Description: Central configuration object. Test cases load parameters
//              here (from a .cfg file or directly); the env/scoreboard/seq
//              consult it. The verification environment is NEVER modified
//              to add a test case — only this object and the sequence change.
//
// CFG file format (plain text, loaded via +cfg=<file>):
//   KEY = VALUE
//   Supported keys:
//     test_mode       : SANITY | DIRECTED | RANDOM
//     num_transactions: integer (for RANDOM mode)
//     rand_seed       : integer (0 = use UVM seed)
//     sliv_fixed      : integer 0-127 (DIRECTED; -1 = random each txn)
//     vld_pattern     : ALWAYS_HIGH | TOGGLE | RANDOM (i_data_vld pattern)
//     check_pipeline_delay : 0|1 (enable exact 8-cycle latency check)
//     check_power_hold     : 0|1 (enable data-register hold check)
//     max_cycles      : integer (simulation budget, 0 = unlimited)
// =============================================================================

`ifndef DEU_TEST_CFG_SV
`define DEU_TEST_CFG_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

typedef enum {VLD_ALWAYS_HIGH, VLD_TOGGLE, VLD_RANDOM} vld_pattern_t;
typedef enum {MODE_SANITY, MODE_DIRECTED, MODE_RANDOM} test_mode_t;

class deu_test_cfg extends uvm_object;
    `uvm_object_utils(deu_test_cfg)

    // ---- Test mode & traffic ------------------------------------------------
    rand test_mode_t    test_mode           = MODE_SANITY;
    rand int unsigned   num_transactions    = 1;
    rand int unsigned   rand_seed           = 0;

    // ---- SLIV stimulus -------------------------------------------------------
    // sliv_fixed = -1 → randomise per-transaction
    rand int            sliv_fixed          = -1;

    // ---- Validity pattern ----------------------------------------------------
    rand vld_pattern_t  vld_pattern         = VLD_ALWAYS_HIGH;

    // ---- Checker knobs -------------------------------------------------------
    rand bit            check_pipeline_delay = 1;
    rand bit            check_power_hold     = 0;

    // ---- Simulation budget ---------------------------------------------------
    rand int unsigned   max_cycles          = 0;   // 0 = unlimited

    // ---- Directed per-channel data override ----------------------------------
    // When set (non-zero), all 16 channels use this compressed word.
    // Format: {exp[3:0], sign, data[14:0]}
    rand bit            use_fixed_cmp_data   = 0;
    rand logic [19:0]   fixed_cmp_data [16];

    function new(string name = "deu_test_cfg");
        super.new(name);
    endfunction

    // -------------------------------------------------------------------------
    // Load from a plain-text file (passed via +cfg=<path>)
    // -------------------------------------------------------------------------
    function void load_from_file();
        string cfg_path;
        int    fd;
        string line, key, val;

        if (!$value$plusargs("cfg=%s", cfg_path)) return;

        fd = $fopen(cfg_path, "r");
        if (fd == 0) begin
            `uvm_warning("CFG", $sformatf("Cannot open cfg file: %s", cfg_path))
            return;
        end

        while (!$feof(fd)) begin
            void'($fgets(line, fd));
            // Strip comments (# to end of line)
            foreach (line[i]) begin
                if (line[i] == "#") begin
                    line = line.substr(0, i-1);
                    break;
                end
            end
            // Parse KEY = VALUE
            if ($sscanf(line, " %s = %s", key, val) == 2) begin
                case (key)
                    "test_mode": begin
                        case (val)
                            "SANITY"   : test_mode = MODE_SANITY;
                            "DIRECTED" : test_mode = MODE_DIRECTED;
                            "RANDOM"   : test_mode = MODE_RANDOM;
                            default    : `uvm_warning("CFG",
                                $sformatf("Unknown test_mode: %s", val))
                        endcase
                    end
                    "num_transactions":    num_transactions    = val.atoi();
                    "rand_seed":           rand_seed           = val.atoi();
                    "sliv_fixed":          sliv_fixed          = val.atoi();
                    "check_pipeline_delay":check_pipeline_delay= val.atoi();
                    "check_power_hold":    check_power_hold    = val.atoi();
                    "max_cycles":          max_cycles          = val.atoi();
                    "vld_pattern": begin
                        case (val)
                            "ALWAYS_HIGH": vld_pattern = VLD_ALWAYS_HIGH;
                            "TOGGLE"     : vld_pattern = VLD_TOGGLE;
                            "RANDOM"     : vld_pattern = VLD_RANDOM;
                            default      : `uvm_warning("CFG",
                                $sformatf("Unknown vld_pattern: %s", val))
                        endcase
                    end
                    default: `uvm_warning("CFG",
                        $sformatf("Unknown cfg key: %s", key))
                endcase
            end
        end
        $fclose(fd);
        `uvm_info("CFG", $sformatf(
            "Loaded cfg: mode=%s txns=%0d sliv_fixed=%0d",
            test_mode.name(), num_transactions, sliv_fixed), UVM_LOW)
    endfunction

    function string convert2string();
        return $sformatf(
            "mode=%s num_txns=%0d sliv_fixed=%0d vld=%s pipe_chk=%0b pwr_chk=%0b",
            test_mode.name(), num_transactions, sliv_fixed,
            vld_pattern.name(), check_pipeline_delay, check_power_hold);
    endfunction

endclass : deu_test_cfg

`endif // DEU_TEST_CFG_SV
