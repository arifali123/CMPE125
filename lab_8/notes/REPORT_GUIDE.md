# Lab 8 Report Guide (fill with your own genuine Vivado results)

## Title and Objective
Lab 8 — Dual-Port Memory Design. The goal is to build and test a 128x8 single-port RAM, a dual-port RAM with two separate clocks, and a true dual-port RAM with one shared clock.

## Design 1: Single-Port RAM
- Explain that `assign q = mem[a]` is asynchronous reading (output responds to address changes without waiting for a clock).
- Explain that `always @(posedge clk)` means writing only occurs on the rising edge: synchronous write.
- Include relevant source code and simulation screenshot for writes/reads at addresses 5 and 127, and the disabled-write test.

## Design 2: Two-Clock Dual-Port RAM
- Each port has its own clock, address, data input/output, and write enable.
- Port A and Port B access the same storage array.
- Both reads and writes are synchronous in this FPGA-oriented version.
- Testbench drives independent 10 ns and 14 ns clock periods, checks data written by each port can be read by the other.
- Include source code and actual waveform screenshot.

## Design 3: True Dual-Port RAM (One Clock)
- Both ports have separate address, data, and write enable but share one clock.
- Both ports can write to different addresses on the same clock edge.
- The testbench confirms ports can exchange information through shared memory.
- Include source code and actual waveform screenshot.

## Vivado Basys 3 demonstration
- Top level: `basys3_ram_demo`, part: `xc7a35tcpg236-1`.
- Describe switch/button/LED mapping from README.
- Include genuine synthesis/implementation/bitstream screenshots and a photo of the board if instructor requests.
- Note that the two-clock design is proven with independent clocks in simulation; both clock inputs use the board clock only in the board demo.

## Results and Conclusion — TO FILL AFTER YOU RUN THE TOOLS
- Compilation result: [insert screenshot/notes]
- Single-port simulation result: [insert screenshot/notes]
- Two-clock simulation result: [insert screenshot/notes]
- True dual-port simulation result: [insert screenshot/notes]
- Board programming result: [insert photo/notes]
- Conclusion: Summarize what passed and any limitations honestly.
