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

- `rtl/alu4.v`: four-bit ALU using one Lab 4 CLA, matching the supplied example.
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
`Unsigned` port absent from its design. The TA's schematic is authoritative:
mux input 3 zero-extends the raw sum sign bit, with no overflow correction
and no extra `Unsigned` input. The code example in `Alu32.pdf` XORs the sign
with overflow; that differs from this schematic when overflow occurs.

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
| LED9 | Signed overflow |
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
| Sign of 3 - 5 | 0011 | 0101 | 111 | 0001 | 0 | 0 | 0 |
| Mux 3, overflow: 7 - (-8) | 0111 | 1000 | 111 | 0001 | 0 | 1 | 0 |
| Mux 3, overflow: -8 - 7 | 1000 | 0111 | 111 | 0000 | 1 | 1 | 1 |
| Signed overflow: 7 + 1 | 0111 | 0001 | 010 | 1000 | 0 | 1 | 0 |
| Carry: -1 + 1 | 1111 | 0001 | 010 | 0000 | 1 | 0 | 1 |

For example, for 5 - 2 turn on SW0, SW2, SW5, SW9, and SW10; leave all
other used switches down. LED0, LED1, and LED10 should light.

Four-bit signed numbers range from -8 to +7. Thus `1000` means -8 and
`1111` means -1 when interpreted as signed. The LEDs always show raw bits.
The four-bit demo computes its own four-bit overflow; it does not simply
truncate the 32-bit ALU's output. Hardware behavior still needs to be checked
on the physical board after programming.

## Controls and outputs

`F[2]` selects `BB = B` or `BB = ~B` and supplies the adder carry in.
The internal sum is `S = A + BB + F[2]`. `F[1:0]` selects the output:

| F | Y |
|---|---|
| 000 | A AND B |
| 001 | A OR B |
| 010 | A + B |
| 011 | Zero-extended S[N-1] from A + B |
| 100 | A AND ~B |
| 101 | A OR ~B |
| 110 | A - B |
| 111 | Zero-extended S[N-1] from A - B |

All eight controls follow the schematic's mux wiring. For F[1:0]=11,
Y is `{3'b000, S[3]}` on the board or `{31'b0, S[31]}` in the 32-bit core.
This is a sign test of the wrapped sum. With F=111 and no signed overflow,
it also gives signed A < B. When overflow occurs, the diagram still selects
the raw sign; it does not implement an overflow-corrected signed comparison.
For example, four-bit 7 - (-8) wraps to 1111, so F=111 gives Y=0001 and
Overflow=1 even though signed 7 is not less than -8. This is the required
schematic behavior. The overflow output reports the overflow independently.

`C_out` is the adder carry out. During subtraction it is 1 for no borrow.
It is distinct from signed overflow. Like the supplied example, carry and
overflow always describe the internal adder, even when Y selects logic or the zero-extended sign bit.
`Zero` is 1 exactly when the selected Y is zero, at either width.

The 32-bit overflow Boolean equation is (use bit 3 for the four-bit ALU):

```text
Overflow = NOT(A[31] XOR BB[31]) AND (A[31] XOR S[31])
Mux3     = {31 zeros, S[31]}
Zero     = NOT(Y[31] OR Y[30] OR ... OR Y[0])
```

For the overflow circuit, connect A[31] and BB[31] to an XNOR gate,
connect A[31] and S[31] to an XOR gate, then AND those two outputs.
The Overflow output does not feed mux input 3. That input is connected
directly to S[N-1] through a zero extender, exactly as drawn.

## Batch verification

From the repository root, with Vivado on PATH:

```sh
mkdir -p lab_7/build
(cd lab_7/build && vivado -mode batch -source ../scripts/verify.tcl)
(cd lab_7/build && vivado -mode batch -source ../scripts/synthesize.tcl)
(cd lab_7/build && vivado -mode batch -source ../scripts/bitstream.tcl)
```

The 32-bit testbench checks 17,620 cases: 20 hand-calculated examples, all eight
control codes for 144 boundary operand pairs, 64 carry/borrow cases, and
all eight controls for 2,048 random pairs. It checks Y, carry, overflow,
and zero on every case. Its arithmetic model uses widened signed math
instead of the design's overflow equation.

The board testbench first shows eight literal examples in the waveform,
including cases that distinguish the schematic from an overflow-corrected
comparison, then checks all 2,048 combinations of two four-bit operands and
three control bits (2,056 tests total), including every output LED. `verify.tcl`
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
