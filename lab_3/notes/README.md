# Lab 3 — Seven-segment display decoder

Author: Arif Ali

## Objective and interface

Implement a seven-segment decoder using Verilog gate primitives.
`SW[3:0] = D3 D2 D1 D0`; `HEX0[6:0] = Sg Sf Se Sd Sc Sb Sa`.
Outputs are active low: 0 illuminates a segment. B and D use lowercase b and d
as shown in the handout. All 16 inputs are defined; there are no don't-care digits.

## Completed truth table

| Digit | D3 D2 D1 D0 | Sg Sf Se Sd Sc Sb Sa | Hex |
|---|---|---|---|
| 0 | 0000 | 1000000 | 40 |
| 1 | 0001 | 1111001 | 79 |
| 2 | 0010 | 0100100 | 24 |
| 3 | 0011 | 0110000 | 30 |
| 4 | 0100 | 0011001 | 19 |
| 5 | 0101 | 0010010 | 12 |
| 6 | 0110 | 0000010 | 02 |
| 7 | 0111 | 1111000 | 78 |
| 8 | 1000 | 0000000 | 00 |
| 9 | 1001 | 0010000 | 10 |
| A | 1010 | 0001000 | 08 |
| B | 1011 | 0000011 | 03 |
| C | 1100 | 1000110 | 46 |
| D | 1101 | 0100001 | 21 |
| E | 1110 | 0000110 | 06 |
| F | 1111 | 0001110 | 0E |

## Derivation and simplified equations

For each segment, collect the truth-table rows whose output is 1 (segment off).
Each row is a four-literal minterm; combine terms differing in one input, remove
absorbed terms, and select a minimum sum-of-products cover. The resulting covers
minimize product count and then literal count independently for each output.
A prime denotes NOT, adjacent literals denote AND, and + denotes OR.

```text
Sa = Σm(1, 4, 11, 13)
Sb = Σm(5, 6, 11, 12, 14, 15)
Sc = Σm(2, 12, 14, 15)
Sd = Σm(1, 4, 7, 10, 15)
Se = Σm(1, 3, 4, 5, 7, 9)
Sf = Σm(1, 2, 3, 7, 13)
Sg = Σm(0, 1, 7, 12)
```

```text
Sa = D3' D2' D1' D0 + D3' D2 D1' D0' + D3 D2' D1 D0 + D3 D2 D1' D0
Sb = D3' D2 D1' D0 + D3 D2 D0' + D3 D1 D0 + D2 D1 D0'
Sc = D3' D2' D1 D0' + D3 D2 D1 + D3 D2 D0'
Sd = D3' D2' D1' D0 + D3' D2 D1' D0' + D3 D2' D1 D0' + D2 D1 D0
Se = D3' D2 D1' + D3' D0 + D2' D1' D0
Sf = D3 D2 D1' D0 + D3' D2' D1 + D3' D2' D0 + D3' D1 D0
Sg = D3' D2 D1 D0 + D3 D2 D1' D0' + D3' D2' D1'
```

## Design choice and gate sketch

I chose a simplified sum-of-products implementation to reduce the number of gates
while keeping each segment easy to trace back to its equation. Four shared NOT
gates provide the complemented inputs. Each product term has a named AND gate,
and each segment has an OR gate combining its terms. Verilog primitives accept
all required fan-ins, so no extra gate trees are necessary.

```text
                         for each segment s = a ... g
SW[3:0] ───────┬────────► AND(term s0) ──┐
              │         AND(term s1) ──┼──► OR ──► Ss = HEX0[s index]
              │              ...      │
              └► 4 NOT ► AND(term sn) ──┘
                 gates
```

The equations label every AND input; the structural source labels every gate and
intermediate wire. This is a logic sketch; inspect Vivado's elaborated schematic
for the actual design view.

## Reproduce in Vivado

From the repository root:

```sh
./lab open lab_3          # Seven-segment decoder
vivado -mode batch -source lab_3/scripts/verify.tcl
```

The synthesis top is `lab03_arif`; the simulation top is `lab03_arif_tb`.

The project uses the existing repository's Artix-7 part `xc7a35tcpg236-1`.
The handout requires decoder synthesis and simulation, so this project exposes
only SW and HEX0 and has no board pin constraints. Physical display operation
also requires board pin assignments and digit-enable/decimal-point signals.

### Testbench verification

The testbench instantiates the decoder, drives all 16 values for 100 ns each,
and checks its outputs against independently listed illuminated segments using case
inequality so X/Z outputs fail. Every valid hexadecimal state is checked.
Run Behavioral Simulation and Zoom Fit for the full 1600 ns waveform.

### add_force verification

The batch script also runs the decoder as the simulation top and sources
`../scripts/force_inputs.tcl`. This uses `add_force` for every digit, waits 100 ns,
and compares HEX0 to the truth table. It first runs 1 ns to initialize procedural
blocks before forcing inputs, producing a 1601 ns sweep. For manual use, set the simulation top to
`lab03_arif`, start Behavioral Simulation, and source
`lab_3/scripts/force_inputs.tcl` using its absolute path in the Tcl Console.
Restore `lab03_arif_tb` as simulation top afterward.

### Synthesis and schematics

The verification script elaborates and synthesizes the decoder, checks
for latches, and saves checkpoints and utilization reports under `lab_3/build/verification`.
Select RTL Analysis → Open Elaborated Design → Schematic.
Run Synthesis and inspect the synthesized schematic as well.

## Results and submission evidence

See `verification.txt` for the decoder’s simulation and synthesis results. Generated Vivado logs,
waveform databases, checkpoints, and utilization reports stay in ignored `build/`.

Before submitting on Canvas, capture actual XSim waveform screenshots and Vivado
schematic screenshots, and format this report according to the Canvas report
guideline (not provided with the handout). Hardware demonstration is not claimed.

Attach these source files to the report:

- `../rtl/lab03_arif.v` — structural gate-level implementation.
- `../sim/lab03_arif_tb.v` — exhaustive self-checking testbench.
- `../scripts/force_inputs.tcl` — all 16 add_force checks.
