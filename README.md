# RISC-V-BASED-MYTH

The **“RISC-V based MYTH (Microprocessor for You in Thirty Hours)”** workshop provides a structured introduction to RISC-V architecture, covering software-to-hardware concepts through hands-on labs. Participants begin with C programming, GCC compilation, and Spike simulation before progressing to number systems and assembly programming. The workshop delves into combinational and sequential logic, pipeline implementation, and microarchitecture of a single-cycle RISC-V CPU. Labs include instruction decoding, register file operations, ALU implementation, and control flow hazards. The final stages focus on load-store instructions, memory management, and CPU testbench development, offering comprehensive learning experience in microprocessor design and verification.

**About RISC-V:**
RISC-V is a free and open standard instruction set architecture (ISA) based on reduced instruction set computer (RISC) principles. Unlike proprietary ISAs such as x86 and ARM, RISC-V is described as "free and open" because its specifications are released under permissive open-source licenses and can be implemented without paying royalties. It is not a specific processor or chip, but rather a blueprint for designing processors.


# Summary of workshop
**Day 1: Introduction to RISC-V ISA and GNU compiler toolchain**
Learned the basics of the RISC-V ISA, binary number systems, and signed/unsigned representations.
Got familiar with the GNU RISC-V toolchain, including riscv64-unknown-elf-gcc and the Spike simulator.
Wrote a simple C program (1ton.c) to calculate the sum from 1 to n.
Compiled and executed the program: Natively using gcc and RISC-V target using riscv64-unknown-elf-gcc + spike.
Verified both outputs matched, confirming successful cross-compilation and simulation.

**Day 2: Introduction to ABI and Basic Verification Flow**
Explored the Application Binary Interface (ABI) and its role in function calls and binary compatibility.
Understood RISC-V register usage and how 5-bit binary codes map to 32 general-purpose registers.
Wrote a C program (1to9_custom.c) and paired it with assembly logic (load.S) to sum numbers from 1 to 9.
Compiled both files using riscv64-unknown-elf-gcc and verified correct output through the Spike simulator.

**Day 3: Digital Logic with TL-Verilog and Makerchip** 
Got introduced to logic gates, combinational and sequential circuits.
Learned about flip-flops and how they store bits using clock signals.
Explored pipelining for better performance and validity for optimizing power and logic.
Used Makerchip to build digital circuits with TL-Verilog.

Labs:
Built a combinational calculator (add, sub, mul, div).
Extended it to a sequential calculator with memory.
Created circuits for Fibonacci generation and Pythagorean theorem using pipelines.
Added validity checks and memory operations for efficiency.

**Day 4:  Basic RISC-V CPU Microarchitecture**
Started building the core components of a RISC-V CPU using TL-Verilog.
Learned how the Program Counter (PC) picks the next instruction.
Used IMEM to fetch instructions.
Built a Decoder to translate opcodes.
Connected a Register File and ALU to process instructions.

Labs:
Implemented Fetch + Decode logic for all RISC-V instruction types.
Built a half-done CPU that adds numbers 1 to 9 using registers, ALU, and basic branching.

**Day 5: Complete Pipelined RISC-V CPU Microarchitecture**
Finalized a 5-stage pipelined RISC-V CPU with full functionality.
Pipelining: Broke the CPU into stages — fetch, decode, execute, memory, write-back — to run instructions in parallel (think CPU multitasking).
Branch & Jump Logic: Handled control-flow instructions like BEQ, BNE, JAL, and JALR like a pro.
Memory Operations: Enabled reading/writing to data memory using load/store instructions.
Verification: Ran a program to add numbers 1 to 9 and checked if x10 = 45. Spoiler: it worked. 

Labs:
Built the complete pipelined RISC-V CPU using TL-Verilog on Makerchip.
Ran tests to confirm correct execution across pipeline stages and memory interactions.


# Tools and Platforms Used

Linux Terminal: Used to write, compile, and run C and assembly programs.
Spike Simulator: Helped test and verify RISC-V programs by simulating them.
Makerchip IDE: A web-based tool for writing, simulating, and visualizing TL-Verilog designs.
RISC-V GCC Toolchain: Used to compile C and assembly code for the RISC-V processor.

# What We Learned

This workshop gave us a strong understanding of how the RISC-V processor works and how to design one. Some key takeaways include:
Writing and simulating both C and assembly programs for the RISC-V architecture.
Hands-on experience with TL-Verilog to design digital circuits—both combinational and sequential.
Successfully building a pipelined RISC-V CPU that can handle arithmetic, logical, branching, jumping, and memory operations.
Boosted problem-solving skills by doing practical labs and debugging real code.

# Acknowledgements

A big thanks to **Kunal Ghosh** for teaching us during the first two days, and to **Steve Hoover** for guiding us through the last three.
Grateful to **VSD** and **Redwood EDA** for organizing this amazing learning experience and making advanced topics easier to understand—especially for young learners.

# Final Thoughts

The **MYTH (Microprocessor for You in Thirty Hours)** workshop is a great way to dive into microprocessor design—from the basics all the way to building your own CPU. With step-by-step lessons and hands-on practice, this workshop helps learners gain real skills in RISC-V programming, digital logic, and CPU architecture.
Highly recommended for students and anyone curious about how computers really work at the hardware level!

