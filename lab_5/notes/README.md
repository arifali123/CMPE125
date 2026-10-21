# Lab 5 - 4-bit CLA adder testbenches

This lab reuses the structural Verilog CLA from Lab 4 and supplies the two
testbench styles required by the Lab 5 handout.

## Files

- `../rtl/cla4.v`: structural 4-bit CLA design reused from Lab 4.
- `../sim/self_check_tb.v`: Type 2 self-checking testbench with four additions.
- `../sim/test_vector_tb.v`: Type 3 self-checking, vector-driven testbench.
- `../sim/test_vector.tv`: four binary input/expected-output vectors.
- `../scripts/project.tcl`: creates one project containing both testbenches.

## Test cases

| A | B | Ci | Expected `{Co,S}` |
|---:|---:|:--:|:-----------------:|
| 1011 (11) | 0110 (6) | 0 | 10001 (17) |
| 1001 (9) | 0101 (5) | 1 | 01111 (15) |
| 0000 (0) | 0000 (0) | 0 | 00000 (0) |
| 1010 (10) | 0101 (5) | 1 | 10000 (16) |

The last test exercises group propagation: `A ^ B` is `1111`, so the carry-in
propagates through the entire 4-bit adder to `Co`.

## Vivado simulation

From the repository root, use the same launcher as the other course projects:

```sh
./lab open lab_5                # One demo project containing both testbenches
```

The launcher creates the ignored `lab_5/build/` directory and immediately opens
the combined project in Vivado. `self_check_tb` is selected as the default
simulation top. Enable the testbench you want in **Simulation Sources**, disable
the other testbench, and **Set as Top** on the enabled testbench. Run **Run
Simulation > Run Behavioral Simulation**. Close the simulation before switching
to the other testbench. Keep `cla4.v` and `test_vector.tv` enabled.

Run for 1 microsecond. Each
simulation should end with a `PASS` message reporting four additions and zero
errors.

The Type 3 project registers `test_vector.tv` as a Vivado memory-initialization
file. XSim therefore makes the file available to `$readmemb` by filename, and
the project remains portable after cloning or moving the repository.
