# Lab 7: 32-bit ALU

Open from the repository root:

```sh
./lab open lab7
```

Run **Behavioral Simulation** with simulation top `alu32_tb`. The design top
is `alu32`. Simulation runs for about 177 us and prints a final PASS or FAIL.
Use Zoom Fit to see the entire waveform, or zoom in on the first 180 ns for
the hand-calculated examples. There is no clock or reset: this is a
combinational ALU using plain Verilog continuous assignments.

## Files

- `rtl/alu32.v`: 32-bit ALU, built from eight four-bit CLA blocks.
- `rtl/cla4.v`: exact copy of `lab_4/rtl/lab4_arif.v`, including its three modules.
- `sim/alu32_tb.v`: self-checking testbench with literal examples, boundary
  cases, carry/borrow checks, and repeatable random inputs.

Only add this folder's RTL to the project. Adding Lab 4's original as well
would define the same CLA modules twice.

The lab handout requires a 32-bit ALU. The accompanying `Alu32.pdf` actually
contains a four-bit example and an `Unsigned` testbench port absent from
its design. This implementation uses the required 32-bit width and signed
set-less-than, with no extra `Unsigned` input or four-bit board wrapper.
The lab does not require board programming; this project has no pin constraints.

## Controls and outputs

`F[2]` selects `BB = B` or `BB = ~B` and supplies the adder carry in.
The internal sum is `S = A + BB + F[2]`. `F[1:0]` selects the output:

| F | Y |
|---|---|
| 000 | A AND B |
| 001 | A OR B |
| 010 | A + B |
| 011 | Zero-extended sign of A + B, corrected for overflow |
| 100 | A AND ~B |
| 101 | A OR ~B |
| 110 | A - B |
| 111 | Signed A < B: 1 if true, otherwise 0 |

Codes 011, 100, and 101 follow the schematic's mux wiring, even though they
are not the usual MIPS arithmetic controls.

`C_out` is the adder carry out. During subtraction it is 1 for no borrow.
It is distinct from signed overflow. Like the supplied example, carry and
overflow always describe the internal adder, even when Y selects logic or SLT.
`Zero` is 1 exactly when the selected 32-bit Y is zero.

The overflow Boolean equation is:

```text
Overflow = NOT(A[31] XOR BB[31]) AND (A[31] XOR S[31])
Less     = S[31] XOR Overflow
Zero     = NOT(Y[31] OR Y[30] OR ... OR Y[0])
```

For the overflow circuit, connect A[31] and BB[31] to an XNOR gate,
connect A[31] and S[31] to an XOR gate, then AND those two outputs.
Correcting the sign with overflow keeps signed SLT correct for operands
such as `80000000` and `7fffffff`.

## Batch verification

From the repository root, with Vivado on PATH:

```sh
mkdir -p lab7/build
(cd lab7/build && vivado -mode batch -source ../scripts/verify.tcl)
(cd lab7/build && vivado -mode batch -source ../scripts/synthesize.tcl)
```

The testbench checks 17,618 cases: 18 hand-calculated examples, all eight
control codes for 144 boundary operand pairs, 64 carry/borrow cases, and
all eight controls for 2,048 random pairs. It checks Y, carry, overflow,
and zero on every case. Its arithmetic model uses widened signed math
instead of the design's overflow equation.

Simulation logs and waveforms are under `build/lab7/lab7.sim/sim_1/behav/xsim/`.
Synthesis produces `build/utilization.txt` and `build/alu32.dcp`.
Generated files are ignored by Git. Capture compilation and waveform
screenshots in Vivado for the lab report required by the handout.
