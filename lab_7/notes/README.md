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
`Unsigned` port absent from its design. The latest BB-based comparison
interpretation is unsigned A<BB, where BB is B for F[2]=0 and ~B for
F[2]=1. Both SLT codes use the original CLA to subtract BB and use its
inverted carry as borrow. This supersedes the earlier interpretation that
both SLT codes compared original A and B. There is no separate comparison
adder/subtractor and no less-than or shift operator in the design RTL.
Complements are taken at the operand width: four bits on the board and
32 bits in the simulation core. No extra `Unsigned` input is needed.

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
| SLT F2=0: 3 < 5 | 0011 | 0101 | 011 | 0001 | 0 | 1 | 0 |
| SLT F2=0: 5 < 3 (false) | 0101 | 0011 | 011 | 0000 | 1 | 0 | 1 |
| SLT: 3 < ~5 (10) | 0011 | 0101 | 111 | 0001 | 0 | 1 | 0 |
| SLT: 7 < ~8 (7) | 0111 | 1000 | 111 | 0000 | 1 | 0 | 1 |
| SLT: 8 < ~7 (8) | 1000 | 0111 | 111 | 0000 | 1 | 0 | 1 |
| SLT: 0 < ~15 (0) | 0000 | 1111 | 111 | 0000 | 1 | 0 | 1 |
| SLT: 15 < ~0 (15) | 1111 | 0000 | 111 | 0000 | 1 | 0 | 1 |
| SLT: 5 < ~5 (10) | 0101 | 0101 | 111 | 0001 | 0 | 1 | 0 |
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

## Reported board case: 1000 minus 1011

For four-bit unsigned subtraction, A=1000 (8), B=1011 (11), F=110:

```text
  1000
+ 0100    (~B)
+ 0001    (carry in)
------
0 1101
```

The result wraps to 1101 (13); carry=0, borrow/Overflow=1, Zero=0.
Turn on only SW3, SW4, SW5, SW7, SW9, and SW10. SW8 must be down.
LED0, LED2, LED3, and LED9 should light. No button press is required.
With A=1000 and B=1011, F=011 compares 8<11 and gives Y=0001;
LED0 and LED9 light. Turn SW10 on for F=111: BB becomes 0100 (4),
so 8<4 is false and Y=0000; LED8 and LED10 light. The comparison is
against BB, not invariably original B. This intentionally differs from
the previously reported expectation of Y=1 for both modes.
The board testbench checks both results first.

## Controls and outputs

F[2] alone selects BB: `BB = F[2] ? ~B : B`. The low two control bits
select logic, arithmetic, or comparison. For SLT, the adder input is ~BB
and carry-in is 1, making the original CLA calculate A-BB.

| F | Y |
|---|---|
| 000 | A AND B |
| 001 | A OR B |
| 010 | A + B |
| 011 | Unsigned A < B: 1 if true, otherwise 0 |
| 100 | A AND ~B |
| 101 | A OR ~B |
| 110 | A - B |
| 111 | Unsigned A < ~B: 1 if true, otherwise 0 |

The implementation keeps the selected operand distinct from the CLA input:

```verilog
assign BB = F[2] ? ~B : B;
assign SLT = F[1] & F[0];
assign adder_B = SLT ? ~BB : BB;
assign Subtract = F[2] | SLT;
// CLA inputs: A, adder_B, carry-in=Subtract.
assign Less = ~C_out;
```

For arithmetic and logic modes, adder_B is BB and the original operations
are unchanged. During SLT, A + ~BB + 1 subtracts BB. Carry=0 means borrow,
so Less=1. Carry=1 means no borrow, so Less=0. The CLA is shared; no
separate subtraction expression or built-in comparison is needed.
The 32-bit core uses adder_B in all eight four-bit CLA blocks and obtains
the final carry from C[8].

Y zero-extends Less as `{3'b000, Less}` on the board or `{31'b0, Less}`
in the 32-bit core. Equal A and the selected BB give 0. A and original B
being equal does not imply false for F=111, since that code compares with ~B.
For example, four-bit A=5, B=5, F=111 compares 5<10 and gives 1.

`C_out` is the actual CLA carry. Unsigned `Overflow` is
`Subtract ? ~C_out : C_out`: addition carry for addition, borrow for
subtraction and comparison. In SLT modes it describes A-BB, so it equals
Less. Zero tests the selected Y. With A=8 and B=11, changing F=011 to
F=111 changes both the selected operand and the comparison result.
Note that ~B is width-dependent: four-bit ~11 is 4, while 32-bit ~11 is
4,294,967,284. Do not expect the same F=111 result at different widths
when a small B is complemented.

## Batch verification

From the repository root, with Vivado on PATH:

```sh
mkdir -p lab_7/build
(cd lab_7/build && vivado -mode batch -source ../scripts/verify.tcl)
(cd lab_7/build && vivado -mode batch -source ../scripts/synthesize.tcl)
(cd lab_7/build && vivado -mode batch -source ../scripts/bitstream.tcl)
```

The 32-bit testbench checks 17,632 cases: 32 hand-calculated examples, all eight
control codes for 144 boundary operand pairs, 64 carry/borrow cases, and
all eight controls for 2,048 random pairs. It checks Y, carry, overflow,
and zero on every case. Its unsigned reference model checks
addition against the width's maximum and subtraction against A<B. The
testbench intentionally retains a direct less-than comparison as an
independent reference against B for F=011 and width-limited ~B for F=111.

The board testbench first shows twenty-three literal examples in the waveform,
including unsigned carry/borrow and comparison with either F[2] value, then checks all 2,048 combinations of two four-bit operands and
three control bits (2,071 tests total), including every output LED. `verify.tcl`
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
