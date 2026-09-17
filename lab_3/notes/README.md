# Lab 3 — Seven-segment display decoder

Author: Arif Ali

## Objective and interface

Implement a seven-segment decoder using gates derived from seven K-maps.
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

## Implementation

The decoder uses NOT, AND, and OR gate primitives implementing the simplified
K-map SOP equations below. Four shared inverters feed named product-term gates;
one OR gate per segment drives HEX0. AN = 1110 selects the rightmost digit.

The testbench cycles through 0–F for 100 ns each, checks the full segment output
against the truth table and verifies AN, then stops for waveform inspection.

## Verified K-maps and SOP equations

A = D3 = SW[3], B = D2 = SW[2], C = D1 = SW[1], D = D0 = SW[0].
Rows are AB and columns are CD, both in Gray-code order 00, 01, 11, 10.
Each map gives the actual active-low segment output: group the 1s (segment OFF).
All hexadecimal inputs 0–F are valid, so there are no don't-cares.
A prime means NOT, adjacent letters mean AND, and + means OR.

Each listed group contains only 1s, and the groups cover every 1 in its map.
Groups are labeled by hexadecimal input values. The covers were also checked
against all valid Boolean cubes for minimum term count, then minimum literals.

### Sa — HEX0[0]

| AB \ CD | 00 | 01 | 11 | 10 |
|---|---|---|---|---|
| 00 | 0 | 1 | 0 | 0 |
| 01 | 1 | 0 | 0 | 0 |
| 11 | 0 | 1 | 0 | 0 |
| 10 | 0 | 0 | 1 | 0 |

Groups: {1}, {4}, {B}, {D}.

```text
Sa = A'B'C'D + A'BC'D' + AB'CD + ABC'D
```

### Sb — HEX0[1]

| AB \ CD | 00 | 01 | 11 | 10 |
|---|---|---|---|---|
| 00 | 0 | 0 | 0 | 0 |
| 01 | 0 | 1 | 0 | 1 |
| 11 | 1 | 0 | 1 | 1 |
| 10 | 0 | 0 | 1 | 0 |

Groups: {5}, {C, E}, {B, F}, {6, E}.

```text
Sb = A'BC'D + ABD' + ACD + BCD'
```

### Sc — HEX0[2]

| AB \ CD | 00 | 01 | 11 | 10 |
|---|---|---|---|---|
| 00 | 0 | 0 | 0 | 1 |
| 01 | 0 | 0 | 0 | 0 |
| 11 | 1 | 0 | 1 | 1 |
| 10 | 0 | 0 | 0 | 0 |

Groups: {2}, {E, F}, {C, E}.

```text
Sc = A'B'CD' + ABC + ABD'
```

### Sd — HEX0[3]

| AB \ CD | 00 | 01 | 11 | 10 |
|---|---|---|---|---|
| 00 | 0 | 1 | 0 | 0 |
| 01 | 1 | 0 | 1 | 0 |
| 11 | 0 | 0 | 1 | 0 |
| 10 | 0 | 0 | 0 | 1 |

Groups: {1}, {4}, {A}, {7, F}.

```text
Sd = A'B'C'D + A'BC'D' + AB'CD' + BCD
```

### Se — HEX0[4]

| AB \ CD | 00 | 01 | 11 | 10 |
|---|---|---|---|---|
| 00 | 0 | 1 | 1 | 0 |
| 01 | 1 | 1 | 1 | 0 |
| 11 | 0 | 0 | 0 | 0 |
| 10 | 0 | 1 | 0 | 0 |

Groups: {4, 5}, {1, 3, 5, 7}, {1, 9}.

```text
Se = A'BC' + A'D + B'C'D
```

### Sf — HEX0[5]

| AB \ CD | 00 | 01 | 11 | 10 |
|---|---|---|---|---|
| 00 | 0 | 1 | 1 | 1 |
| 01 | 0 | 0 | 1 | 0 |
| 11 | 0 | 1 | 0 | 0 |
| 10 | 0 | 0 | 0 | 0 |

Groups: {D}, {2, 3}, {1, 3}, {3, 7}.

```text
Sf = ABC'D + A'B'C + A'B'D + A'CD
```

### Sg — HEX0[6]

| AB \ CD | 00 | 01 | 11 | 10 |
|---|---|---|---|---|
| 00 | 1 | 1 | 0 | 0 |
| 01 | 0 | 0 | 1 | 0 |
| 11 | 1 | 0 | 0 | 0 |
| 10 | 0 | 0 | 0 | 0 |

Groups: {7}, {C}, {0, 1}.

```text
Sg = A'BCD + ABC'D' + A'B'C'
```

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
6. Run Behavioral Simulation for 1600 ns. The testbench checks all 16 input
   combinations automatically and reports PASS or stops on a mismatch.
7. Select Generate Bitstream, allowing synthesis and implementation to run.
8. Connect and power the Basys 3 through its USB programming port. In Hardware
   Manager, select Open Target → Auto Connect → Program Device and choose the
   generated `seven_segment_decoder.bit`.
9. Toggle SW0–SW3 through 0000–1111. The rightmost digit should display 0–F;
   the other three digits stay off.

`AN = 1110` enables the rightmost digit. The module does not expose a decimal-point
output, so this project has no DP constraint. No clock is needed for a single
continuously enabled digit. Pins follow the
[Digilent Basys 3 master constraints](https://github.com/Digilent/digilent-xdc/blob/master/Basys-3-Master.xdc).

Programming the FPGA with the `.bit` file is sufficient for a powered lab demo;
the configuration is lost when power is removed.

## Notes and evidence

Keep waveform screenshots and any instructor-required report material here.
Generated projects and bitstreams stay in ignored `build/`, just like the other labs.
Verified in Vivado 2025.2: all 16 inputs and digit enables passed simulation;
synthesis, implementation, and bitstream generation completed successfully.
Physical board operation must be checked on the lab board.
