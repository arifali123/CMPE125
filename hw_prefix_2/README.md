# Digital Building Blocks, question 2: 16-bit prefix adder

`rtl/prefix16.v` structurally implements the attached figure. The separate
`rtl/prefix_black.v` module is instantiated 32 times: eight black blocks in
each of four stages. There is no behavioral addition in the design.

Ports: `A[15:0]`, `B[15:0]`, and `Cin` are inputs; `S[15:0]` and `Cout` are
outputs. The unsigned result is `{Cout, S} = A + B + Cin`. Tie `Cin` to zero
when adding only A and B. The circuit is combinational; no clock is needed.

## Matching the figure

The input legend uses `P_i = A_i | B_i` and `G_i = A_i & B_i`.
Each black block combines a high group with the adjacent low group:

```
P_out = P_hi & P_lo
G_out = G_hi | (P_hi & G_lo)
```

The virtual column -1 has `P = 0`, `G = Cin`. Internally array index `n`
represents diagram column `n-1`, so the tree covers columns -1 through 14.
Bit 15 goes directly to its sum cell, as drawn.

| Stage | Black-block groups in the diagram (high:low) |
|---|---|
| 1 | 0:-1, 2:1, 4:3, 6:5, 8:7, 10:9, 12:11, 14:13 |
| 2 | 1:-1, 2:-1, 5:3, 6:3, 9:7, 10:7, 13:11, 14:11 |
| 3 | 3:-1, 4:-1, 5:-1, 6:-1, 11:7, 12:7, 13:7, 14:7 |
| 4 | 7:-1, 8:-1, 9:-1, 10:-1, 11:-1, 12:-1, 13:-1, 14:-1 |

The final generate at column `i-1` supplies the carry into sum bit `i`:
`S_i = A_i ^ B_i ^ G_(i-1:-1)`. The propagate OR must not be substituted
for the sum XOR. `Cout` is an additional output, computed from bit 15 and
its incoming carry; it does not add another black block to the pictured tree.

## Run in Vivado

From the repository root:

```sh
./lab open hw_prefix_2
```

Choose **Run Simulation > Run Behavioral Simulation**, then **Run All** if
needed. Expand `uut` to inspect `prefix_stage`, `p`, `g`, and `carry`.
To run simulation and synthesis in batch mode:

```sh
mkdir -p hw_prefix_2/build
(cd hw_prefix_2/build && vivado -mode batch -source ../scripts/verify.tcl)
```

The testbench fails immediately on a mismatch and prints `PASS` only after:

- All 16 input combinations of the separate black block.
- 10 illustrative additions, including zero, carry-in, wraparound, and MSB carry.
- 816 directed tests generating, propagating, or killing carries across every
  contiguous bit range, including operand swaps and both carry-ins.
- All 131,072 combinations of two 8-bit operands and carry-in.
- 262,144 tests sweeping every 16-bit A with B=1 and B=~A, both carry-ins.
- 10,000 repeatable random full-width additions.
- Independent checks of every intermediate P/G group for directed carry tests
  and random vectors, including pass-through wires.

That is 404,042 adder tests, compared with explicitly widened 17-bit addition.
This is extensive functional simulation, not exhaustive coverage of all 2^33
input combinations or a physical propagation-delay measurement.

Verified with Vivado 2025.2 / XSim on November 8, 2026:

```text
PASS: prefix_black 16/16 combinations; prefix16 404042 additions; intermediate prefix checks passed.
PASS: simulation and combinational synthesis.
```

Synthesis for `xc7a35tcpg236-1` completed with zero synthesis warnings or errors,
using 40 LUTs and no latches or flip-flops. Vivado optimizes the structural
source into FPGA LUTs; inspect the RTL hierarchy to see the original tree.
The batch transcript is `build/vivado.log`, the simulation transcript is
`build/hw_prefix_2/hw_prefix_2.sim/sim_1/behav/xsim/simulate.log`, and resource
counts are in `build/utilization.rpt` (generated files are ignored by Git).

For Icarus Verilog, if installed:

```sh
mkdir -p hw_prefix_2/build
iverilog -g2005-sv -s prefix16_tb -o hw_prefix_2/build/prefix16_tb \
  hw_prefix_2/rtl/prefix_black.v hw_prefix_2/rtl/prefix16.v hw_prefix_2/sim/prefix16_tb.v
(cd hw_prefix_2/build && vvp prefix16_tb)
```

Add `+vcd` to `vvp prefix16_tb` to record only the introductory vectors in
`prefix16.vcd`. Vivado records a WDB under `build/` automatically. No board
constraints are included because this question asks for design and simulation.
