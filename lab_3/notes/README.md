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

## Open and demonstrate on the Basys 3

Use `./lab open lab_3`, just like Labs 1 and 2. The single `scripts/project.tcl`
sets up the project for that launcher; no extra verification scripts are needed.

To create the project manually on a lab computer:

1. Create a Vivado RTL project for Basys 3 / `xc7a35tcpg236-1`.
2. Add `rtl/seven_segment_decoder.v` as a design source.
3. Add `sim/seven_segment_decoder_tb.v` as a simulation source.
4. Add `constraints/basys3.xdc` as a constraints file.
5. Set `seven_segment_decoder` as design top and `seven_segment_decoder_tb`
   as simulation top.
6. Run Behavioral Simulation for 1600 ns. The testbench checks all 16 digits,
   the digit enables, and the decimal point; it stops on a mismatch.
7. Select Generate Bitstream, allowing synthesis and implementation to run.
8. Connect and power the Basys 3 through its USB programming port. In Hardware
   Manager, select Open Target → Auto Connect → Program Device and choose the
   generated `seven_segment_decoder.bit`.
9. Toggle SW0–SW3 through 0000–1111. The rightmost digit should display 0–F;
   the other digits and decimal point stay off.

`AN = 1110` enables the rightmost digit; `DP = 1` turns the decimal point off.
These fixed board outputs are included in the same decoder module. No clock is
needed for a single continuously enabled digit. Pins follow the
[Digilent Basys 3 master constraints](https://github.com/Digilent/digilent-xdc/blob/master/Basys-3-Master.xdc).

Programming the FPGA with the `.bit` file is sufficient for a powered lab demo;
the configuration is lost when power is removed.

## Notes and evidence

Keep waveform screenshots and any instructor-required report material here.
Generated projects and bitstreams stay in ignored `build/`, just like the other labs.
Verified in Vivado 2025.2: all 16 testbench cases passed, including digit enables
and decimal point; synthesis, implementation, and bitstream generation completed.
Physical board operation must be checked on the lab board.
