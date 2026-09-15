# CMPE 125 labs

Open your lab in **Vivado 2025.2 on Linux**, at home or on the lab computer.
Tcl creates the project from tracked sources; you run simulation, synthesis,
implementation, and programming yourself in the Vivado UI.

## Open the project

From the repository folder:

```sh
make gui
```

`make` also opens the GUI. The first launch creates
`lab_1/build/light/light.xpr`; later launches reopen it and refresh the source list.
Close this project's existing Vivado window before launching again.

If `vivado` is not on PATH, source the installation's settings first:

```sh
source /path/to/AMD/2025.2/Vivado/settings64.sh
```

The installation path can differ between computers. Check `vivado -version` for
2025.2. Alternatively: `make gui VIVADO=/path/to/vivado`.

Without Make, open Vivado and enter this in its Tcl Console (adjust the path):

```tcl
source /path/to/CMPE125/lab_1/scripts/project.tcl
```

Close any other project first. Script paths follow the clone location automatically.

## Simulate all four states in the GUI

1. Launch with `make gui` so the testbench is added to **Simulation Sources**.
2. Click **Run Simulation → Run Behavioral Simulation**.
3. Click **Zoom Fit** in the waveform view to see the full 200 ns.

The simulation top is `light_tb`; the synthesis top remains `light`.
`lab_1/sim/light_tb.v` drives and checks every input combination automatically:

| Time | x1 | x2 | Expected f |
| --- | --- | --- | --- |
| 0–50 ns | 0 | 0 | 0 |
| 50–100 ns | 1 | 0 | 1 |
| 100–150 ns | 0 | 1 | 1 |
| 150–200 ns | 1 | 1 | 0 |

The Tcl Console prints `PASS: All four XOR states verified.` on success; a wrong
or unknown output triggers a fatal simulation error. Simulation finishes at 200 ns,
leaving the waveform available for inspection and screenshots. Save your screenshot
in `lab_1/notes/`, then close simulation when finished. No manual input forces are
needed with the testbench. The handout's manual-force example uses `light` as the
simulation top instead; this setup uses the testbench to produce the same states.

## Move between computers

The GitHub repository is private: `arifali123/CMPE125`. Authenticate with your
GitHub account and clone:

```sh
git clone https://github.com/arifali123/CMPE125.git
cd CMPE125
make gui
```

Before leaving a computer, save your files in Vivado, then:

```sh
git status
git diff
git add lab_1
git commit -m "Save Lab 1 progress"
git push
```

On the other computer, close Vivado, run `git pull --ff-only` in your existing
checkout, and run `make gui`. Use a local folder outside cloud-synced storage.
If the lab clears local files between sessions, push before logging out.

## What gets saved

```text
lab_1/
  rtl/light.v             XOR starter from the handout
  sim/light_tb.v         Testbench covering all four XOR states
  constraints/basys3.xdc  Basys 3: SW0/SW1 inputs, LED0 output
  scripts/project.tcl    Creates or opens the GUI project
  notes/                 Your notes and screenshots
  build/                 Local Vivado project and generated outputs (ignored)
```

Edit the files in `rtl/` and `constraints/` directly in Vivado; Git sees those edits.
Save design Verilog in `rtl/`, testbench Verilog in `sim/`, and XDC files in
`constraints/`. The setup scans those folders on launch. In Add Sources, leave **Copy sources into project**
unchecked. Files saved only inside `build/` do not travel with Git.

Git preserves sources, constraints, Tcl, and saved notes. GUI layout, generated
results, and unsaved edits stay on that computer. Put project settings that must
travel between computers in `scripts/project.tcl`; the script restores its own
settings on each launch. The starter selects the Basys 3 part `xc7a35tcpg236-1`
and uses installed board files when available.

For another lab with its own setup script, use `make gui LAB=lab_2`.

## References

- Course handout: `Lab1_SoftwareInstallation_and_XOR_Implementation.pdf` (provided separately).
- [AMD: creating projects using Tcl](https://docs.amd.com/r/2023.1-English/ug893-vivado-ide/Creating-Projects-Using-Tcl-Commands)
- [Digilent: Basys 3 pin assignments](https://github.com/Digilent/digilent-xdc/blob/master/Basys-3-Master.xdc)
