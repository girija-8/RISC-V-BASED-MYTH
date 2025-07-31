\m4_TLV_version 1d: tl-x.org
\SV
   // https://github.com/stevehoover/RISC-V_MYTH_Workshop
   
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/RISC-V_MYTH_Workshop/ecba3769fff373ef6b8f66b3347e8940c859792d/tlv_lib/calculator_shell_lib.tlv'])

\SV
   m4_makerchip_module   // (Expanded in Nav-TLV pane.)

\TLV
   |calc
      @0
         $reset = *reset;
      @1
         $val1[31:0] = >>2$out[31:0];
         $val2[31:0] = $rand2[3:0];
         
         $valid = $reset ? 1'b0 : >>1$valid + 1'b1;
         $valid_or_reset = $valid || $reset;
         
      ?$valid_or_reset
         @1
            $sum = $val1 + $val2 ;
            $diff = $val1 - $val2 ;
            $prod = $val1 * $val2 ;
            $qout = $val1 / $val2 ;

         @2
            $out1[31:0] = ($op[2:0] == 3'b000) ? $sum : ($op[2:0] = 3'b001) ? $diff : ($op[2:0] = 3'b010) ?  $prod : ($op[2:0] = 3'b011) ?  $qout : ($op[2:0] = 3'b100) ?  >>2$mem : >>2$out ;
            $out[31:0] = $valid_or_reset ? 32'b0 : $out1[31:0];
            $mem[31:0] = $reset ? 32'b0 : ($op[2:0] == 3'b101) ? $val1[31:0] : >>2$mem[31:0];
            
      //  o $rand1[3:0]
      //  o $rand2[3:0]
      //  o $op[x:0]
      
   //m4+cal_viz(@3) // Arg: Pipeline stage represented by viz, should be atleast equal to last stage of CALCULATOR logic.

   
   // Assert these to end simulation (before Makerchip cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
   

\SV
   endmodule
