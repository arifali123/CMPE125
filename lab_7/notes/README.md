# Lab 7: ALU simulation and Basys 3 demonstration

Open from the repository root:

```sh
./lab open lab_7
```

The default design top is `basys_alu`, the required four-bit hardware demo.
Run **Behavioral Simulation** with default simulation top `basys_alu_tb`
to check every four-bit input and control combination (about 21 us).
The original 32-bit design and `alu32_tb` remain in the project. To repeat
that simulation, right-click `alu32_tb` and select **Set as Top**, then run
Behavioral Simulation (about 177 us). Both testbenches print PASS or FAIL.
There is no clock or reset: the ALUs use plain Verilog continuous assignments.

## Files

- `rtl/alu4.v`: unsigned four-bit ALU using one Lab 4 CLA.
- `rtl/basys_alu.v`: connects switches to the four-bit ALU and outputs to LEDs.
- `constraints/basys3.xdc`: Basys 3 switch and LED pins.
- `sim/basys_alu_tb.v`: exhaustive test of all 2,048 switch settings and LED outputs.
- `rtl/alu32.v`: 32-bit ALU, built from eight four-bit CLA blocks.
- `rtl/cla4.v`: exact copy of `lab_4/rtl/lab4_arif.v`, including its three modules.
- `sim/alu32_tb.v`: self-checking testbench with literal examples, boundary
  cases, carry/borrow checks, and repeatable random inputs.

Only add this folder's RTL to the project. Adding Lab 4's original as well
would define the same CLA modules twice.

The written handout requires a 32-bit ALU simulation, and the instructor also
requires a four-bit Basys 3 demonstration. Both are included. The accompanying
`Alu32.pdf` provides the four-bit ALU and board wrapper. Its testbench has an
`Unsigned` port absent from its design. Per the clarified lab requirement,
both F=011 and F=111 implement unsigned A<B, independently of F[2]. The
comparison performs a separate widened subtraction A + ~B + 1 and uses its
borrow. The synthesizable ALUs use neither the less-than nor shift operator.
Operands are unsigned: 0 through 15 on the board and 0 through 4,294,967,295
in the 32-bit core. The example PDF's signed overflow equation and corrected
signed comparison are not used. No extra `Unsigned` input is needed.

## Program and demonstrate the Basys 3

1. Open with `./lab open lab_7`. If Vivado was already open before the board
   files were added, close that project and run the command again to load them.
2. Choose **Generate Bitstream** with design top `basys_alu`.
3. Connect and power the board using its programming USB connection.
4. Open **Hardware Manager > Open Target > Auto Connect > Program Device**.
5. Select `lab_7/build/lab_7/lab_7.runs/impl_1/basys_alu.bit`.

| Switches / LEDs | Meaning |
|---|---|
| SW3, SW2, SW1, SW0 | A, from most to least significant bit |
| SW7, SW6, SW5, SW4 | B, from most to least significant bit |
| SW10, SW9, SW8 | F, from most to least significant bit |
| LED3, LED2, LED1, LED0 | Y, from most to least significant bit |
| LED8 | Zero |
| LED9 | Unsigned overflow (addition carry or subtraction borrow) |
| LED10 | Carry out (no borrow for subtraction) |
| LED7:4 | Always off |

SW0 is the rightmost switch; up is 1, down is 0. No button press is needed:
the LEDs respond when switches change. SW11 through SW15 are unused.
The seven-segment display is unused. The mapping follows the supplied wrapper
and [Digilent's master constraints](https://github.com/Digilent/digilent-xdc/blob/master/Basys-3-Master.xdc).

Try these demonstrations. Read the input and output groups in the bit order
shown above. A flag of 1 means that LED should light.

| Operation | A (SW3:0) | B (SW7:4) | F (SW10:8) | Y (LED3:0) | Zero | Overflow | Carry |
|---|---|---|---|---|---|---|---|
| AND: 5 & 3 | 0101 | 0011 | 000 | 0001 | 0 | 0 | 0 |
| OR: 5 OR 3 | 0101 | 0011 | 001 | 0111 | 0 | 0 | 0 |
| Add: 3 + 4 | 0011 | 0100 | 010 | 0111 | 0 | 0 | 0 |
| Subtract: 5 - 2 | 0101 | 0010 | 110 | 0011 | 0 | 0 | 1 |
| Zero: 5 - 5 | 0101 | 0101 | 110 | 0000 | 1 | 0 | 1 |
| SLT with F2=0: 3 < 5 | 0011 | 0101 | 011 | 0001 | 0 | 0 | 0 |
| SLT with F2=0: 5 < 3 (false) | 0101 | 0011 | 011 | 0000 | 1 | 0 | 0 |
| SLT: 3 < 5 | 0011 | 0101 | 111 | 0001 | 0 | 1 | 0 |
| SLT: 7 < 8 | 0111 | 1000 | 111 | 0001 | 0 | 1 | 0 |
| SLT: 8 < 7 (false) | 1000 | 0111 | 111 | 0000 | 1 | 0 | 1 |
| SLT: 0 < 15 | 0000 | 1111 | 111 | 0001 | 0 | 1 | 0 |
| SLT: 15 < 0 (false) | 1111 | 0000 | 111 | 0000 | 1 | 0 | 1 |
| SLT: 5 < 5 (false) | 0101 | 0101 | 111 | 0000 | 1 | 0 | 1 |
| Add: 7 + 1 | 0111 | 0001 | 010 | 1000 | 0 | 0 | 0 |
| Carry: 15 + 1 | 1111 | 0001 | 010 | 0000 | 1 | 1 | 1 |
| Borrow: 2 - 5 | 0010 | 0101 | 110 | 1101 | 0 | 1 | 0 |

For example, for 5 - 2 turn on SW0, SW2, SW5, SW9, and SW10; leave all
other used switches down. LED0, LED1, and LED10 should light.

Results wrap to the output width: four-bit 2 - 5 is 13 (`1101`), with
Overflow=1 to indicate borrow. Four-bit 7 + 1 is 8 (`1000`), with Overflow=0.
Four-bit 15 + 1 wraps to 0, with Overflow=1 for carry. The demo computes
four-bit carry/borrow directly rather than truncating the 32-bit core.
Hardware behavior still needs to be checked on the physical board.

## Controls and outputs

`F[2]` selects `BB = B` or `BB = ~B` and supplies the adder carry in.
The internal sum is `S = A + BB + F[2]`. `F[1:0]` selects the output:

| F | Y |
|---|---|
| 000 | A AND B |
| 001 | A OR B |
| 010 | A + B |
| 011 | Unsigned SLT: 1 if A < B, otherwise 0 |
| 100 | A AND ~B |
| 101 | A OR ~B |
| 110 | A - B |
| 111 | Unsigned SLT: 1 if A < B, otherwise 0 |

For F[1:0]=11, SLT uses two's-complement subtraction, A + ~B + 1.
The extra bit preserves carry; a carry of 0 means a borrow, so A is less
than B. Four-bit code:

```verilog
wire [4:0] difference;
wire Less;
assign difference = {1'b0, A} + {1'b0, ~B} + 5'd1;
assign Less = ~difference[4];
```

The 32-bit core uses a 33-bit difference and inverts bit 32. B is inverted
at its original width before it is extended with a zero. This preserves
the subtraction carry. The expression is A + ~B + 1, not A + ~B - 1.
There is no less-than or shift operator in the design RTL.

Y zero-extends Less as `{3'b000, Less}` on the board or `{31'b0, Less}`
in the 32-bit core. True gives 1 and false gives 0. Equal operands give 0.
This separate subtraction is always active, so both F=011 and F=111 compare
correctly. F[2] still controls the main CLA's arithmetic and logic inputs.
The main adder's carry is unsuitable for SLT when F[2]=0 because that
adder is adding rather than subtracting.

For example, with A=3 and B=5, the five-bit sum is 00011 + 01010 + 00001
= 01110. Carry is 0, so Less=1. With A=5 and B=3, it is 00101 + 01100
+ 00001 = 10010. Carry is 1, so Less=0. The low four result bits alone
cannot determine unsigned less-than; the extra carry bit is essential.

`C_out` is the adder carry out. During subtraction it is 1 for no borrow.
Unsigned `Overflow` reports carry during addition and borrow during
subtraction. These flags describe the internal arithmetic even when Y
selects logic or unsigned SLT. `Zero` tests the selected Y.

The overflow Boolean equation, at either width, is:

```text
Overflow = (NOT F[2] AND C_out) OR (F[2] AND NOT C_out)
         = F[2] XOR C_out
```

A single XOR gate with inputs F[2] and C_out implements this output.
The Verilog expresses the same function as `F[2] ? ~C_out : C_out`.
For F=111, unsigned Overflow and the SLT result are both equivalent to
subtraction borrow. For F=011, Overflow describes addition carry and may
differ from the comparison. Carry and Overflow can therefore differ between
the two comparison codes while Y stays the same. Zero always tests Y.

## Batch verification

From the repository root, with Vivado on PATH:

```sh
mkdir -p lab_7/build
(cd lab_7/build && vivado -mode batch -source ../scripts/verify.tcl)
(cd lab_7/build && vivado -mode batch -source ../scripts/synthesize.tcl)
(cd lab_7/build && vivado -mode batch -source ../scripts/bitstream.tcl)
```

The 32-bit testbench checks 17,627 cases: 27 hand-calculated examples, all eight
control codes for 144 boundary operand pairs, 64 carry/borrow cases, and
all eight controls for 2,048 random pairs. It checks Y, carry, overflow,
and zero on every case. Its unsigned reference model checks
addition against the width's maximum and subtraction against A<B. The
testbench intentionally retains a direct less-than comparison as an
independent reference for the subtract-and-borrow implementation.

The board testbench first shows seventeen literal examples in the waveform,
including unsigned carry/borrow and comparison with either F[2] value, then checks all 2,048 combinations of two four-bit operands and
three control bits (2,065 tests total), including every output LED. `verify.tcl`
runs both testbenches and saves their transcripts as `build/alu32_tb.log`
and `build/basys_alu_tb.log`.

Simulation logs and waveforms are under `build/lab_7/lab_7.sim/sim_1/behav/xsim/`.
The synthesis-only script checks the 32-bit core and produces
`build/utilization.txt` and `build/alu32.dcp`. The bitstream script builds the
four-bit board top and produces `build/board_utilization.txt` and
`build/board_drc.txt`. This switch-to-LED circuit has no clock or synchronous
timing requirement.
Generated files are ignored by Git. Capture compilation and waveform
screenshots in Vivado for the lab report required by the handout.
