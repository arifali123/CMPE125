# Lab 8 Report Guide (fill with your own genuine Vivado results)

## Title and Objective
Lab 8 — Dual-Port Memory Design. The goal is to build and test a 256x8 single-port RAM, a dual-port RAM with two separate clocks, and a true dual-port RAM with one shared clock.

The instructor requested eight-bit addresses, so each RAM has 256 locations.

## Design 1: Single-Port RAM
- Explain that `assign q = mem[a]` is asynchronous reading (output responds to address changes without waiting for a clock).
- Explain that `always @(posedge clk)` means writing only occurs on the rising edge: synchronous write.
- Include relevant source code and simulation screenshot for writes/reads at addresses 0, 127, 128, and 255, the full-memory pattern readback, and the disabled-write test.

## Design 2: Two-Clock Dual-Port RAM
- Each port has its own clock, address, data input/output, and write enable.
- Port A and Port B access the same storage array.
- Explain the request/ready/valid interface for port B and its additional latency.
- Both memory accesses execute on clk1 after synchronizing port B's captured request.
- Explain A-priority write rejection and the returned collision2 flag.
- Testbench drives independent 10 ns and 14 ns clock periods, checks data written by each port can be read by the other.
- Include source code and actual waveform screenshot.

## Design 3: True Dual-Port RAM (One Clock)
- Both ports have separate address, data, and write enable but share one clock.
- Both ports can write to different addresses on the same clock edge.
- Same-address writes give A priority and assert collision. Both outputs read the old value.
- Include both directions of read/write overlap and the rejected B write in the waveforms.
- The testbench confirms ports can exchange information through shared memory.
- Include source code and actual waveform screenshot.

## Results and Conclusion — TO FILL AFTER YOU RUN THE TOOLS
- Compilation result: [insert screenshot/notes]
- Single-port simulation result: [insert screenshot/notes]
- Two-clock simulation result: [insert screenshot/notes]
- True dual-port simulation result: [insert screenshot/notes]
- Conclusion: Summarize what passed and any limitations honestly.
