# CMPE 125

Course labs using Vivado 2025.2 on Linux.

## Get started

```sh
git clone https://github.com/arifali123/CMPE125.git
cd CMPE125
```

Make sure `vivado` is on your PATH. If needed, source your installation's
`settings64.sh` first.

## Open a lab

```sh
./lab                           # List available labs and project variants
./lab open <folder>             # Open a lab's default Vivado project
./lab open <folder> <project>   # Open a named project variant
```

Run simulation, synthesis, and programming from the Vivado UI.

Board pin reference: [Digilent Basys 3 Master XDC](https://github.com/Digilent/digilent-xdc/blob/master/Basys-3-Master.xdc).

| Lab | Circuit module | Testbench |
|---|---|---|
| 1 | `light_controller` | `light_controller_tb` |
| 2 | `full_adder` | `full_adder_tb` |
| 3 | `seven_segment_decoder` | `seven_segment_decoder_tb` |
| 4 | `CLA4` | `CLA4_tb` |
| 5 | `CLA4` | `self_check_tb`, `test_vector_tb` |

### Lab 3: seven-segment decoder

```sh
./lab open lab_3          # Seven-segment decoder
```

Lab 3 uses SW0–SW3 to display 0–F on the rightmost Basys 3 digit.
Run Behavioral Simulation, then Generate Bitstream and Program Device in Vivado.
See [Lab 3 notes](lab_3/notes/README.md) for manual project setup and the truth table.

### Lab 4: 4-bit CLA adder

```sh
./lab open lab_4          # 4-bit carry-lookahead adder
```

Structural design (`GPFullAdder`, `CLALogic`, `CLA4`) with a self-checking testbench.
Run Behavioral Simulation; the Basys 3 constraints are already in the project.
See [Lab 4 notes](lab_4/notes/README.md) for the pin map and the two verification additions.

### Lab 5: 4-bit CLA testbenches

Lab 5 reuses the structural `CLA4` design from Lab 4 and provides the two
separate testbench projects required by the assignment:

```sh
./lab open lab_5                # Type 2 self-checking project (default)
./lab open lab_5 self_check     # Type 2 self-checking project (explicit)
./lab open lab_5 test_vector    # Type 3 vector-file project
```

Each testbench runs four additions and prints `PASS` when all expected results
match. The Type 3 project registers `lab_5/sim/test_vector.tv` as a Vivado
memory-initialization file, so no machine-specific path changes are needed.
See [Lab 5 notes](lab_5/notes/README.md) for the vectors and simulation details.

## Homework 4: sequential logic and FSMs

Each question has its own Vivado project and self-checking testbench:

| Folder | Design | Simulation checks |
|---|---|---|
| `hw_4_2a` | JK built from a D flip-flop: `D = J & ~Q \| ~K & Q` | All eight old-state/J/K combinations |
| `hw_4_2b` | D built from JK: `J = D`, `K = ~D` | Capture and hold for repeated/changing inputs |
| `hw_4_2c` | T built from JK: `J = K = 1` | Toggle on each rising edge |
| `hw_4_3a` | Three-bit modulo-8 Gray counter | Three complete periods and one-bit transitions |
| `hw_4_4c` | AND/OR Mealy FSM with previous A as its state | All eight previous-A/A/B combinations |

```sh
./lab open hw_4_2a
./lab open hw_4_2b
./lab open hw_4_2c
./lab open hw_4_3a
./lab open hw_4_4c
```

Open one project at a time. Choose **Run Simulation > Run Behavioral Simulation**;
the testbench runs to completion and prints `PASS` or fails with `$fatal`.
Use Zoom Fit to see the waveforms; expand `uut` for internal state and hierarchy.
The question 2b/2c projects reference `hw_4_2a/rtl/jk_from_d.v`, so keep those
folders together. Question 2d's code/testbench requirement is covered by all three
question 2 projects. These projects have no board pin constraints.

All circuits use rising-edge clocks and an active-high asynchronous `reset`.
Reset sets Q (or the stored previous A) to zero. Reset was added to questions 2
and 4 for deterministic startup; question 3 requires reset but does not specify
polarity or timing. The T flip-flop has no enable input: it toggles every rising
edge while reset is low, matching the definition in question 1.

The Gray sequence is `000, 001, 011, 010, 110, 111, 101, 100`, then `000`.
For question 4, `B=0` selects AND and `B=1` selects OR. The state equation is
`previous_A_next = A`, and the combinational output is
`Z = B ? (A | previous_A) : (A & previous_A)`. Apply each cycle's A/B and observe
Z before the rising edge that stores A for the next cycle. Because this is a
Mealy machine, Z can also change between edges; it is not a registered output.
The testbench checks Z before capture and checks the updated history afterward.

To verify any project in batch mode (replace the folder as needed):

```sh
mkdir -p hw_4_2a/build
(cd hw_4_2a/build && vivado -mode batch -source ../scripts/verify.tcl)
```

Simulation logs and waveform databases are generated under each ignored `build/`
directory. Sources are in `rtl/`; testbenches are in `sim/`.

## Save and sync

Save your files in Vivado, then review and push your changes:

```sh
git status
git diff
git add <folder>
git commit -m "Save lab progress"
git push
```

On the other computer, close Vivado and update before opening a lab:

```sh
git pull --ff-only
./lab open <folder>
```

Keep your work outside `build/`; generated project files are ignored by Git.
