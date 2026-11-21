# Lab 7 report screenshots

Captured from the actual Vivado 2025.2 editor and XSim waveform viewer on
November 20, 2026, using the existing Lab 7 RTL and testbenches.
Use the cropped PNGs below in the report. Each waveform also has a matching
`_vivado_full.png` preserving the entire application window.

## Waveforms and suggested captions

| Image | Suggested caption |
|---|---|
| [32-bit arithmetic](01_alu32_arithmetic_waveforms.png) | 32-bit ALU directed examples, approximately 0–160 ns: subtraction with and without borrow, logic, addition, zero, and full-width carry. For example, at 70–80 ns, 5−2=3; at 80–90 ns, 2−5 wraps to FFFFFFFD with borrow; at 130–140 ns, FFFFFFFF+1 wraps to zero with carry. |
| [32-bit comparison with complement](02_alu32_slt_complement_waveforms.png) | Unsigned comparison with F=111, including true, false, and equality cases against the 32-bit complement of B. At 160–170 ns, A=3 and B=5 produce Y=1; at 180–190 ns, A=80000000 and B=7FFFFFFF produce Y=0 because A equals ~B. |
| [32-bit logic and comparison](03_alu32_comparisons_waveforms.png) | Complemented logic and unsigned comparison with F=011. At 230–240 ns, 5 AND ~3=4; at 240–250 ns, 5 OR ~3=FFFFFFFD. At 280–290 ns, 3<5 gives Y=1, while at 290–300 ns, 5<3 gives Y=0. |
| [Four-bit board examples](04_board_examples_waveforms.png) | Simulation of the Basys 3 ALU through its board wrapper. At 0–10 ns, 8−11 wraps to D with borrow. With A=8 and B=B, F=111 gives Y=0 (8<~B is false), while F=011 gives Y=1 (8<B is true). BB shows the selected, width-limited operand. |
| [Four-bit carry and comparison](05_board_carry_comparisons_waveforms.png) | Four-bit unsigned flags and comparison: at 180–190 ns, F+1 wraps to zero with carry; at 190–200 ns, 2−5 wraps to D with borrow. At 220–230 ns, F=111 compares 5 with ~5=A and returns Y=1. |

A, B, BB, and Y are hexadecimal; F and the one-bit flags are binary.
The value column corresponds to the yellow time cursor. Overflow is the
existing design's **unsigned** carry/borrow flag. The 10 ns intervals are
testbench stimulus spacing, not measured propagation delays. Board images
are simulation evidence; a physical board demonstration requires its own photos.

## Source code

The screenshots preserve the repository code, syntax highlighting, filenames,
and line numbers. The testbenches span multiple overlapping images.

- [32-bit ALU](10_source_alu32.png)
- [Four-bit ALU](11_source_alu4.png)
- [Basys 3 wrapper](12_source_basys_alu.png)
- [CLA building blocks](13_source_cla4.png)
- 32-bit testbench: [beginning](14_source_alu32_tb_part1.png),
  [ending](15_source_alu32_tb_part2.png)
- Board testbench: [beginning](17_source_basys_alu_tb_part1.png),
  [ending](18_source_basys_alu_tb_part2.png)

The supplied attachment was a Lab 5 report; these images document Lab 7.

To repeat verification from the repository root:

```sh
mkdir -p lab_7/build
(cd lab_7/build && vivado -mode batch -source ../scripts/verify.tcl)
```
