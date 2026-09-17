# Lab 3 — Seven-segment display decoder

Author: Arif Ali

## Objective and interface

Implement a seven-segment decoder using the case statement in the supplied example.
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

The decoder follows the supplied PDF: `always @(*)`, a case for each input
from 0 through F, and `AN = 4'b1110`. The module names remain descriptive:
`seven_segment_decoder` and `seven_segment_decoder_tb`.

The testbench matches the example's simple loop: drive 0–F for 100 ns each,
then `$stop` to inspect the waveform. Compare HEX0 against the table above.

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
6. Run Behavioral Simulation for 1600 ns. The testbench displays all 16 input
   combinations; compare the waveform against the truth table above.
7. Select Generate Bitstream, allowing synthesis and implementation to run.
8. Connect and power the Basys 3 through its USB programming port. In Hardware
   Manager, select Open Target → Auto Connect → Program Device and choose the
   generated `seven_segment_decoder.bit`.
9. Toggle SW0–SW3 through 0000–1111. The rightmost digit should display 0–F;
   the other three digits stay off.

`AN = 1110` enables the rightmost digit. The example does not expose a decimal-point
output, so this project has no DP constraint. No clock is needed for a single
continuously enabled digit. Pins follow the
[Digilent Basys 3 master constraints](https://github.com/Digilent/digilent-xdc/blob/master/Basys-3-Master.xdc).

Programming the FPGA with the `.bit` file is sufficient for a powered lab demo;
the configuration is lost when power is removed.

## Notes and evidence

Keep waveform screenshots and any instructor-required report material here.
Generated projects and bitstreams stay in ignored `build/`, just like the other labs.
Verified with Vivado 2025.2 on 2026-09-17: all 16 simulated outputs matched the
truth table, and synthesis, implementation, and bitstream generation passed.
Physical board operation must be checked on the lab board.
