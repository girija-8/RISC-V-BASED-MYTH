\m5_TLV_version 1d: tl-x.org
\m5

\SV
    m5_makerchip_module
\TLV

    |calc               // Start of pipeline
        @1             // Define stage 1 of pipeline

            $reset = *reset;

            // Counter logic
            $cnt[31:0] = $reset ? 0 : $cnt + 1;

            // Input operands and opcode (assumed to be driven externally)
            $val1[31:0];
            $val2[31:0];
            $op[1:0];

            // Calculator logic
            $out[31:0] = 
                ($op == 2'b00) ? $val1 + $val2 :
                ($op == 2'b01) ? $val1 - $val2 :
                ($op == 2'b10) ? $val1 * $val2 :
                ($op == 2'b11) ? ($val2 != 0 ? $val1 / $val2 : 32'b0) :
                32'b0;

    // End condition
    *passed = *cyc_cnt > 40;
    *failed = 1'b0;

\SV
    endmodule
