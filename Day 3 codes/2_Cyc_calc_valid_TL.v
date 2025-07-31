\m5_TLV_version 1d: tl-x.org
\m5
   
   // ============================================
   // Welcome, new visitors! Try the "Learn" menu.
   // ============================================
   
   //use(m5-1.0)   /// uncomment to use M5 macro library.
\SV
   // Macro providing required top-level module definition, random
   // stimulus support, and Verilator config.
   m5_makerchip_module   // (Expanded in Nav-TLV pane.)
\TLV
   $reset = *reset;
   |calc
      @1  
         $val1[31:0] = >>2$out1;
         $val2[31:0] = $rand2[3:0];
   
         $sum = $val1 + $val2 ;
         $diff = $val1 - $val2 ;
         $prod = $val1 * $val2 ;
         $qout = $val1 / $val2 ;
         $cnt[31:0] = $reset ? 0 : (1 + >>1$cnt);
       
      @2
         $valid = $cnt ;
       
   
         $out1 = $op[1] ? ($op[0]?  $qout :$prod) : ($op[0]? $diff: $sum);
         $out = ($reset | ~$valid)  ? 32'b0 : $out1;
 
 
   // Assert these to end simulation (before the cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule
