# Lab 4 — 4-bit carry-lookahead adder

Author: Ryan Rigor

## Design

Structural Verilog in `../rtl/lab4_arif.v`, three modules per the handout:

| Module | Ports |
|---|---|
| `GPFullAdder` | `Ai, Bi, Cin, G, P, Sum` — `G = A&B`, `P = A^B`, `Sum = P^Cin` |
| `CLALogic` | `G[3:0], P[3:0], Ci, C[3:0], Co, PG, GG` — expanded carries C1–C3, `PG`, `GG`, `Co = GG + PG·Ci` |
| `CLA4` (top) | `A[3:0], B[3:0], Ci, S[3:0], Co, PG, GG` |

## Simulation

`../sim/CLA4_tb.v` is self-checking. It runs the two required additions first,
then corner cases, then all 512 input combinations against a reference model:

| A | B | Ci | Result | PG | GG |
|---|---|---|---|---|---|
| 11 (1011) | 6 (0110) | 0 | 17 (Co=1, S=0001) | 0 | 1 |
| 9 (1001) | 5 (0101) | 1 | 15 (Co=0, S=1111) | 0 | 0 |

Run Behavioral Simulation in Vivado. The transcript ends with
`PASS: all directed and 512 exhaustive cases verified.` The run takes about 5.2 µs.
For the report: Zoom Fit the waveform, and open Synthesis > Schematic for the
design schematic.

## Board (optional)

Constraints are in `../constraints/basys3.xdc`.

| Signal | Basys 3 |
|---|---|
| `A[3:0]` | SW3–SW0 |
| `B[3:0]` | SW7–SW4 |
| `Ci` | SW8 |
| `S[3:0]` | LED3–LED0 |
| `Co` | LED4 |
| `PG` | LED5 |
| `GG` | LED6 |
