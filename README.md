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
./lab                 # List available labs
./lab open <folder>   # Open a lab in Vivado
```

Run simulation, synthesis, and programming from the Vivado UI.

| Lab | Circuit module | Testbench |
|---|---|---|
| 1 | `light_controller` | `light_controller_tb` |
| 2 | `full_adder` | `full_adder_tb` |
| 3 | `seven_segment_decoder` | `seven_segment_decoder_tb` |

### Lab 3: seven-segment decoder

```sh
./lab open lab_3          # Seven-segment decoder
```

Lab 3 uses SW0–SW3 to display 0–F on the rightmost Basys 3 digit.
Run Behavioral Simulation, then Generate Bitstream and Program Device in Vivado.
See [Lab 3 notes](lab_3/notes/README.md) for manual project setup and the truth table.

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
