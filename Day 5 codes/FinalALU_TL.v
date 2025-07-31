\m4_TLV_version 1d: tl-x.org
\SV
   // This code can be found in: https://github.com/stevehoover/RISC-V_MYTH_Workshop
   
   m4_include_lib(['https://raw.githubusercontent.com/BalaDhinesh/RISC-V_MYTH_Workshop/master/tlv_lib/risc-v_shell_lib.tlv'])

\SV
   m4_makerchip_module   // (Expanded in Nav-TLV pane.)
\TLV

   // /====================\
   // | Sum 1 to 9 Program |
   // \====================/
   // Program for MYTH Workshop to test RV32I
   // Add 1,2,3,...,9 (in that order).
   //
   // Regs:
   //  r10 (a0): In: 0, Out: final sum
   //  r12 (a2): 10
   //  r13 (a3): 1..10
   //  r14 (a4): Sum
   // 
   // External to function:
   m4_asm(ADD, r10, r0, r0)             // Initialize r10 (a0) to 0.
   // Function:
   m4_asm(ADD, r14, r10, r0)            // Initialize sum register a4 with 0x0
   m4_asm(ADDI, r12, r10, 1010)         // Store count of 10 in register a2.
   m4_asm(ADD, r13, r10, r0)            // Initialize intermediate sum register a3 with 0
   // Loop:
   m4_asm(ADD, r14, r13, r14)           // Incremental addition
   m4_asm(ADDI, r13, r13, 1)            // Increment intermediate register by 1
   m4_asm(BLT, r13, r12, 1111111111000) // If a3 is less than a2, branch to label named <loop>
   m4_asm(ADD, r10, r14, r0)            // Store final result to register a0 so that it can be read by main program
   
   //Data memory test
   m4_asm(SW, r0, r10, 100) //stores the result in memory
   m4_asm(LW, r15, r0, 100) //loads the final result to r15
   
   // Optional:
   //m4_asm(JAL, r7, 00000000000000000000) // Done. Jump to itself (infinite loop). (Up to 20-bit signed immediate plus implicit 0 bit (unlike JALR) provides byte address; last immediate bit should also be 0)
   
   m4_define_hier(['M4_IMEM'], M4_NUM_INSTRS)

   |cpu
      @0
         $reset = *reset;
         
         // PROGRAM COUNTER
         $pc[31:0] = >>1$reset                     ? 32'd0 :
                     >>3$valid_taken_br            ? >>3$br_tgt_pc :
                     >>3$valid_load                ? >>1$inc_pc :
                     (>>3$valid_jump && >>3$is_jal)  ? >>3$br_tgt_pc :
                     (>>3$valid_jump && >>3$is_jalr) ? >>3$jalr_tgt_pc :
                     >>1$inc_pc;
         
         // INSTRUCTION MEMORY
         $imem_rd_en = !$reset; //enable reads when not reset.
         $imem_rd_addr[M4_IMEM_INDEX_CNT-1:0] = $pc[M4_IMEM_INDEX_CNT+1:2]; //data out is PC+4. 
      
      @1
         $inc_pc[31:0] = $pc + 32'd4;
         $instr[31:0]  = $imem_rd_data;
         
         // DECODER         
         $is_i_instr = $instr[6:2] ==? 5'b0000x || //00000 and 00001 are i-type.
                       $instr[6:2] ==? 5'b001x0 || //00100 and 00110 are i-type.
                       $instr[6:2] ==? 5'b11001 || 
                       $instr[6:2] ==? 5'b11100;
         $is_r_instr = $instr[6:2] ==? 5'b011x0 || //01100 and 01110 are r-type.
                       $instr[6:2] ==? 5'b01011 || 
                       $instr[6:2] ==? 5'b10100;
         $is_s_instr = $instr[6:2] ==? 5'b0100x;   //01000 and 01001 are s-type.
         $is_b_instr = $instr[6:2] ==  5'b11000;
         $is_j_instr = $instr[6:2] ==  5'b11011;
         $is_u_instr = $instr[6:2] ==? 5'b0x101;   //00101 and 01101 are u-type.
         
         // OPCODE FIELD
         $opcode[6:0] = $instr[6:0];
         
         // IMMEDIATE FIELD
         $imm[31:0] = $is_i_instr ? { {21{$instr[31]}}, $instr[30:20] } : //21{$instr[31]} is basically a s-ext of bit 31.
                      $is_s_instr ? { {21{$instr[31]}}, $instr[30:25], $instr[11:7] } :
                      $is_b_instr ? { {20{$instr[31]}}, $instr[7], $instr[30:25], $instr[11:8], 1'b0 } :
                      $is_u_instr ? { $instr[31:12], 12'd0 } :
                      $is_j_instr ? { $instr[31:12], $instr[20], $instr[30:21], 1'b0 } :
                                    32'd0;
         
         // FUNCTION FIELDS
         $funct7_valid = $is_r_instr;
         $funct3_valid = $is_r_instr || $is_i_instr || $is_s_instr || $is_b_instr;
         
         ?$funct7_valid
            $funct7[6:0] = $instr[31:25]; //funct7 field.
         ?$funct3_valid
            $funct3[2:0] = $instr[14:12]; //funct3 field.
         
         // REGISTER FIELDS
         $rs1_valid = $is_r_instr || $is_i_instr || $is_s_instr || $is_b_instr;
         $rs2_valid = $is_r_instr || $is_s_instr || $is_b_instr;
         $rd_valid  = $is_r_instr || $is_i_instr || $is_u_instr || $is_j_instr;
         
         ?$rs1_valid
            $rs1[4:0]    = $instr[19:15]; //source register 1.
         ?$rs2_valid
            $rs2[4:0]    = $instr[24:20]; //source register 2.
         ?$rd_valid
            $rd[4:0]     = $instr[11:7];  //destination register.
         
         $dec_bits[10:0] = {$funct7[5], $funct3, $opcode};
         
         // INSTRUCTION SET (RV32I)      
         $is_lui    = $dec_bits ==? 11'bx_xxx_0110111; //load upper immediate
         $is_auipc  = $dec_bits ==? 11'bx_xxx_0010111; //add upper immediate to PC
         $is_jal    = $dec_bits ==? 11'bx_xxx_1101111; //jump and link
         $is_jalr   = $dec_bits ==? 11'bx_000_1100111; //jump and link register
         $is_jump   = $is_jal || $is_jalr;
         
         $is_beq    = $dec_bits ==? 11'bx_000_1100011; //branch equal 
         $is_bne    = $dec_bits ==? 11'bx_001_1100011; //branch not equal 
         $is_blt    = $dec_bits ==? 11'bx_100_1100011; //branch less than
         $is_bge    = $dec_bits ==? 11'bx_101_1100011; //branch greater than or equal to 
         $is_bltu   = $dec_bits ==? 11'bx_110_1100011; //branch less than (unsigned)
         $is_bgeu   = $dec_bits ==? 11'bx_111_1100011; //branch greater or equal (unsigned)
         
         $is_lb     = $dec_bits ==? 11'bx_000_0000011; //load byte
         $is_lh     = $dec_bits ==? 11'bx_001_0000011; //load half-word
         $is_lw     = $dec_bits ==? 11'bx_010_0000011; //load word
         $is_lbu    = $dec_bits ==? 11'bx_100_0000011; //load byte (unsigned)
         $is_lhu    = $dec_bits ==? 11'bx_101_0000011; //load half-word (unsigned)
         $is_load   = ($is_lb || $is_lh || $is_lw || $is_lbu || $is_lhu); //handle all loads indiscriminantly
         
         $is_sb     = $dec_bits ==? 11'bx_000_0100011; //store byte
         $is_sh     = $dec_bits ==? 11'bx_001_0100011; //store half-word
         $is_sw     = $dec_bits ==? 11'bx_010_0100011; //store word
         
         $is_addi   = $dec_bits ==? 11'bx_000_0010011; //add immediate
         $is_slti   = $dec_bits ==? 11'bx_010_0010011; //set less than immediate
         $is_sltiu  = $dec_bits ==? 11'bx_011_0010011; //set less than immediate (unsigned)
         $is_xori   = $dec_bits ==? 11'bx_100_0010011; //xor immediate
         $is_ori    = $dec_bits ==? 11'bx_110_0010011; //or immediate
         $is_andi   = $dec_bits ==? 11'bx_111_0010011; //and immediate
         $is_slli   = $dec_bits ==? 11'b0_001_0010011; //shift left logical immediate
         $is_srli   = $dec_bits ==? 11'b0_101_0010011; //shift right logical immediate
         $is_srai   = $dec_bits ==? 11'b1_101_0010011; //shift right arithmetic immediate
         
         $is_add    = $dec_bits ==? 11'b0_000_0110011; //addition
         $is_sub    = $dec_bits ==? 11'b1_000_0010011; //subtraction
         $is_sll    = $dec_bits ==? 11'b0_001_0010011; //shift left logical
         $is_slt    = $dec_bits ==? 11'b0_010_0010011; //set less than
         $is_sltu   = $dec_bits ==? 11'b0_011_0010011; //set less than (unsigned)
         $is_xor    = $dec_bits ==? 11'b0_100_0010011; //xor
         $is_srl    = $dec_bits ==? 11'b0_101_0010011; //shift right logical
         $is_sra    = $dec_bits ==? 11'b1_101_0010011; //shift right arithmetic
         $is_or     = $dec_bits ==? 11'b0_110_0010011; //or
         $is_and    = $dec_bits ==? 11'b0_111_0010011; //and

      @2
         // REGISTER FILE READ
         $rf_rd_en1 = $rs1_valid;
         $rf_rd_index1[4:0] = $rs1;

         $rf_rd_en2 = $rs2_valid;
         $rf_rd_index2[4:0] = $rs2;
         
         // COMPUTE TARGET BRANCH
         $br_tgt_pc[31:0] = $pc + $imm;
         $jalr_tgt_pc[31:0] = $src1_value + $imm; //compute jump target
         
         // ALU SOURCES (with RAW hazard handling)
         $src1_value[31:0] = (>>1$rf_wr_index == $rf_rd_index1) && >>1$rf_wr_en ?
                              >>1$rf_wr_data :
                                 $rf_rd_data1; //check if the previous reg write is reg read src 1.
         $src2_value[31:0] = (>>1$rf_wr_index == $rf_rd_index2) && >>1$rf_wr_en ?
                              >>1$rf_wr_data :
                                 $rf_rd_data2; //check if the previous reg write is reg read src 2.
      @3
         // ALU EXECUTE
         $result[31:0] = $is_lui     ? {$imm[31:12], 12'b0} :
                         $is_auipc   ? $pc + $imm :
                         $is_jal     ? $pc + 32'd4 :
                         $is_jalr    ? $pc + 32'd4 :
                         $is_load    ? $src1_value + $imm:
                         $is_s_instr ? $src1_value + $imm:
                         $is_addi    ? $src1_value + $imm:
                         $is_slti    ? (($src1_value[31] == $imm[31]) ? $sltiu_result : {31'b0, $src1_value[31]}) :
                         $is_sltiu   ? $sltiu_result:
                         $is_xori    ? $src1_value ^ $imm :
                         $is_ori     ? $src1_value | $imm :
                         $is_andi    ? $src1_value & $imm :
                         $is_slli    ? $src1_value << $imm[5:0] :
                         $is_srli    ? $src1_value >> $imm[5:0] :
                         $is_srai    ? {{32{$src1_value[31]}}, $src1_value} >> $imm[4:0] :
                         $is_add     ? $src1_value + $src2_value:
                         $is_sub     ? $src1_value - $src2_value :
                         $is_sll     ? $src1_value << $src2_value[4:0] :
                         $is_slt     ? (($src1_value[31] == $src2_value[31]) ? $sltu_result : {31'b0, $src1_value[31]}) :
                         $is_sltu    ? $sltu_result :
                         $is_xor     ? $src1_value ^ $src2_value :
                         $is_srl     ? $src1_value >> $src2_value[4:0] :
                         $is_sra     ? {{32{$src1_value[31]}}, $src1_value} >> $src2_value[4:0] :
                         $is_or      ? $src1_value | $src2_value :
                         $is_and     ? $src1_value & $src2_value :
                         32'bx;
         
         $sltu_result[31:0]  = $src1_value < $src2_value;
         $sltiu_result[31:0] = $src1_value < $imm;
         
         $taken_br = $is_beq  ? ($src1_value == $src2_value) :
                     $is_bne  ? ($src1_value != $src2_value) :
                     $is_blt  ? (($src1_value < $src2_value)  ^ ($src1_value[31] != $src2_value[31])) :
                     $is_bge  ? (($src1_value >= $src2_value) ^ ($src1_value[31] != $src2_value[31])) :
                     $is_bltu ? ($src1_value < $src2_value)  : //bitwise ops in verilog default to unsigned.
                     $is_bgeu ? ($src1_value >= $src2_value) :
                     1'b0;
         
         // PIPELINE VALIDITY
         $valid = !(>>1$valid_taken_br || >>2$valid_taken_br || >>1$is_load || >>2$is_load || >>1$valid_jump || >>2$valid_jump);
         $valid_taken_br = $valid && $taken_br; //branch CF hazard handling
         $valid_load = $valid && $is_load; //RAW DMem hazard handling
         $valid_jump = $valid && $is_jump;
         
         // REGISTER FILE WRITE
         $rf_wr_en = ($valid && $rd_valid && ($rd != 5'b0)) || >>2$valid_load; //ensure that writes have a destination and NOT x0.
         $rf_wr_index[4:0] = >>2$valid_load ? >>2$rd : $rd; //use the load destination on valid load
         $rf_wr_data[31:0] = >>2$valid_load ? >>2$ld_data : $result; //write loaded data on valid load
         
      @4
         // DATA MEMORY
         $dmem_rd_en = $is_load;              //enable for loads
         $dmem_wr_en = $valid && $is_s_instr; //enable for stores
         $dmem_addr[3:0]  = $result[5:2];     //word addressed and calculated from the instruction
         $dmem_wr_data[31:0] = $src2_value;
      
      @5
         $ld_data[31:0] = $dmem_rd_data; //wait a cycle for the data
         
   *passed = |cpu/xreg[15]>>6$value == (1+2+3+4+5+6+7+8+9);
   // Assert these to end simulation (before Makerchip cycle limit).
   //*passed = *cyc_cnt > 100;
   *failed = 1'b0;
  
   |cpu
      m4+imem(@1)    // Args: (read stage)
      m4+rf(@2, @3)  // Args: (read stage, write stage) - if equal, no register bypass is required
      m4+dmem(@4)    // Args: (read/write stage)

   m4+cpu_viz(@4)    // For visualisation, argument should be at least equal to the last stage of CPU logic. @4 would work for all labs.
\SV
   endmodule
