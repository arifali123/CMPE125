# Homework 3

The attached PDF contains four combinational problems, despite its filename
mentioning sequential circuits. No clock or reset is required.

| Problem | Source (`rtl/`) | Testbench (`sim/`) | Cases | Duration |
|---|---|---|---|---|
| 1: four-input XOR | `xor4.v` | `xor4_tb.v` | 16 | 1600 ns |
| 2: three-input minority | `minority.v` | `minority_tb.v` | 8 | 800 ns |
| 3: eight-input priority | `priority8.v` | `priority8_tb.v` | 256 | 25600 ns |
| 4: 2-to-4 decoder | `decoder2to4.v` | `decoder2to4_tb.v` | 4 | 400 ns |

Each testbench checks every binary input against an expected result, fails on
mismatches (including X/Z outputs), and prints PASS when complete. Inputs stay
stable for 100 ns; outputs are checked after 1 ns of settling time.

## Open and get waveforms

From the repository root:

```sh
./lab open hw_3
```

Problem 1 is selected initially. Click **Run Simulation > Run Behavioral
Simulation**. The simulation runs to completion; zoom to fit to see all inputs.
The `uut` instance contains the circuit. Display `a` and `y` in binary; minority
also has separate `b` and `c` inputs. `expected` shows the reference output.

To switch problems, close simulation, right-click the unwanted testbench
files under **Simulation Sources** and choose **Disable File**. Enable the one
you want, right-click its module, and choose **Set as Top**. Use **Run All**
(the priority test needs 25.6 us, longer than the usual 1 us default).

Keep all four design sources enabled. Reopening through `./lab` selects XOR again.

These are simulation circuits; board pin constraints are not included.

## Interpretation of unspecified details

Problem 3 does not specify output format or priority order. `priority8` uses
an eight-bit one-hot output, with `a[7]` highest priority. For example,
`a = 00110101` produces `y = 00100000`; zero input produces zero output.
This is a priority circuit, with no encoded index output.

Problem 4 uses active-high outputs with no enable: inputs 00, 01, 10, 11
produce 0001, 0010, 0100, 1000 respectively.

## Batch verification

With Vivado on PATH, from the repository root:

```sh
mkdir -p hw_3/build
cd hw_3/build
vivado -mode batch -source ../scripts/verify.tcl
```

Look for four PASS summaries. Generated projects, logs and wave databases stay
under the Git-ignored `build/` directory.
