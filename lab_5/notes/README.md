# Lab 5 - 4-bit CLA adder testbenches

This lab reuses the structural Verilog CLA from Lab 4 and supplies the two
testbench styles required by the Lab 5 handout.

## Files

- `../rtl/cla4.v`: structural 4-bit CLA design reused from Lab 4.
- `../sim/self_check_tb.v`: Type 2 self-checking testbench with four additions.
- `../sim/test_vector_tb.v`: Type 3 self-checking, vector-driven testbench.
- `../sim/test_vector.tv`: four binary input/expected-output vectors.
- `../scripts/project.tcl`: creates one demo project containing both testbenches.
- `../scripts/self_check_project.tcl`: creates the Type 2 Vivado project.
- `../scripts/test_vector_project.tcl`: creates the Type 3 Vivado project.

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
simulation top. Run Behavioral Simulation, close the simulation, then in
**Simulation Sources** right-click `test_vector_tb`, choose **Set as Top**, and
run Behavioral Simulation again. This demonstrates both required testbench
styles without closing or swapping projects.

If the submission must follow the handout's literal two-project organization,
the standalone variants remain available:

```sh
./lab open lab_5 self_check
./lab open lab_5 test_vector
```

Those two commands create separate `.xpr` projects under `lab_5/build/`.

The project scripts can also be run directly in Vivado batch mode:

```text
vivado -mode batch -source lab_5/scripts/self_check_project.tcl
vivado -mode batch -source lab_5/scripts/test_vector_project.tcl
```

Then open the corresponding project under `lab_5/build/`, select **Run
Simulation > Run Behavioral Simulation**, and run for 1 microsecond. Each
simulation should end with a `PASS` message reporting four additions and zero
errors.

The Type 3 project registers `test_vector.tv` as a Vivado memory-initialization
file. XSim therefore makes the file available to `$readmemb` by filename, and
the project remains portable after cloning or moving the repository.
