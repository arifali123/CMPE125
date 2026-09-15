# CMPE 125 labs

Portable Vivado projects for the Digilent Basys 3. Git stores Verilog, pin
constraints, Tcl setup, and notes. Each computer recreates its own project and
build outputs. This preserves design progress; synthesis results, open GUI tabs,
and unsaved edits do not travel through Git.

## Quick start — Linux, Vivado 2025.2

Install Vivado with **Artix-7** support, and put `vivado` on PATH (usually by
sourcing your installation's `settings64.sh`). GNU Make is optional.

```sh
git clone https://github.com/arifali123/CMPE125.git
cd CMPE125
make gui
```

The repository is private: authenticate to GitHub using your own account before
cloning/pushing. On an existing checkout, save and close Vivado, then run
`git pull --ff-only` and `make gui`.

| Command | Result |
| --- | --- |
| `make project` | Create or reopen and refresh `lab_1/build/light/light.xpr` |
| `make gui` | Open the refreshed project in Vivado |
| `make sim` | Check all four XOR truth-table rows with XSim |
| `make synth` | Synthesis and `lab_1/build/reports/utilization.rpt` |
| `make bitstream` | Implementation and `lab_1/build/light/light.runs/impl_1/light.bit` |
| `make clean` | Delete this lab's generated files; close Vivado first |

Use `make gui VIVADO=/path/to/vivado` if Vivado is not on PATH. Build concurrency
defaults to two jobs; for example, `make bitstream JOBS=4`.
Do not run multiple commands against the same project at once. Close the GUI
before running batch simulation/builds; close simulation before refreshing sources.

## Lab computer setup

Both home and lab use **Linux and Vivado 2025.2**. On each machine, check:

```sh
vivado -version
git --version
make --version
```

If Vivado is missing from PATH, source that machine's installation settings:

```sh
source /path/to/AMD/2025.2/Vivado/settings64.sh
```

Use the actual installation path supplied by the lab; it need not match home.
Clone into a local folder you can write, preferably without spaces and outside
cloud-synced storage. If the lab clears local storage between sessions, push before
logging out and clone again next time.

Without Make, from the repository root:

```sh
mkdir -p lab_1/build
cd lab_1/build
vivado -mode gui -source ../scripts/project.tcl
# Or, with the GUI closed:
vivado -mode batch -source ../scripts/sim.tcl
vivado -mode batch -source ../scripts/build.tcl -tclargs synth
vivado -mode batch -source ../scripts/build.tcl -tclargs bitstream
```

If Vivado is already open, close any other project and source the setup from the
Tcl Console, replacing this example path with your clone location:

```tcl
source /path/to/CMPE125/lab_1/scripts/project.tcl
```

Paths are resolved from the scripts, so different Linux usernames and clone
locations work. Use braces around a Tcl path if it contains spaces.

## Save work and resume elsewhere

1. Edit `lab_1/rtl/*.v` or `lab_1/constraints/*.xdc`, in Vivado or your editor.
   The project references these tracked originals. Save all changes.
2. Put screenshots and progress notes in `lab_1/notes/`.
3. Review and push from the repository root:

   ```sh
   git status
   git diff
   git add lab_1 README.md Makefile .gitignore
   git commit -m "Record Lab 1 progress"
   git push
   ```

4. On the next computer, clone (first time) or `git pull --ff-only`, then run
   `make gui` or source `project.tcl` in Vivado.

**New sources:** save Verilog directly in `rtl/` and constraints in `constraints/`.
The setup scans those directories (not nested directories) each time. When using
Add Sources, leave “Copy sources into project” unchecked. Files created only
inside `build/` are ignored by Git and will be lost on cleanup. Move them to a
tracked source directory first.

**Project settings:** persistent changes to device, top module, simulation, or
filesets belong in `scripts/project.tcl`. GUI-only project settings are local.
For future IP/block designs, also track their source definitions and regeneration
Tcl; this small RTL starter does not automate those yet.

## Lab 1

```text
lab_1/
  rtl/light.v             Handout's XOR starter circuit
  constraints/basys3.xdc  SW0/SW1 inputs, LED0 output
  scripts/project.tcl    Portable project creation and source refresh
  scripts/sim.tcl        Automated truth-table simulation
  scripts/waves.tcl      Handout's interactive 200 ns waveform
  scripts/build.tcl      Synthesis / optional bitstream generation
  notes/                 Your notes, screenshots, and report material
  build/                 Generated locally; ignored by Git
```

The handout uses project/top module `light` and part `xc7a35tcpg236-1`.
Installed Basys 3 board files are used when available; explicit device selection
and XDC pin assignments also work without board files, as permitted by the handout.
There is no clock in this combinational circuit, so no clock timing constraint is
invented. Timing reports cannot establish a clocked timing guarantee for it.

For the handout's interactive simulation:

1. Run **Run Simulation → Run Behavioral Simulation** (top is `light`).
2. In the Tcl Console, source the waveform script using your clone's full path:
   `source /path/to/CMPE125/lab_1/scripts/waves.tcl`.
3. Click **Zoom Fit**, capture a screenshot, and save it in `lab_1/notes/`.
4. Close Simulation when done.

Simulation starts at 0 ns so the script can apply the handout's forces. It drives
`x1` every 50 ns and `x2` every 100 ns across all four input combinations.
The automated `make sim` checks the same cases and closes the simulator afterward.
For hardware use, open Hardware Manager and select the generated `light.bit`;
programming is manual and requires a connected Basys 3 and working cable drivers.

## Versions and adding labs

Both computers use **Vivado 2025.2 on Linux**, as confirmed for this workflow.
The handout's 2025.1 examples do not change that choice. Use `vivado -version` to
verify the executable selected by PATH on each machine. To discard local generated
state, close Vivado, run `make clean`, and recreate with `make gui`.

For another small RTL lab, copy the tracked `lab_1` structure to `lab_2` **without
build/**, change its module, project settings, constraints, and scripts, then use
`make gui LAB=lab_2`. The simulation script is specific to Lab 1 and must be replaced.

## Verification

Verified on Linux with Vivado 2025.2 on 2026-09-14:

- Project creation and reopening with source refresh.
- XSim: all four XOR truth-table rows pass; batch command exits successfully.
- Synthesis: one LUT2 and three bonded IOBs, matching the handout.
- Implementation and bitstream generation complete successfully.
- A separate local Git clone under `/tmp` recreates and simulates successfully,
  verifying that source paths do not depend on the original checkout.

The lab machine and physical board have not yet been tested. Generated logs,
reports, and bitstreams stay in `lab_1/build/` on each machine.

## References

- [AMD: creating projects using Tcl](https://docs.amd.com/r/2023.1-English/ug893-vivado-ide/Creating-Projects-Using-Tcl-Commands)
- [AMD: add_files references source files](https://docs.amd.com/r/2025.1-English/ug835-vivado-tcl-commands/add_files)
- [Digilent: Basys 3 master pin constraints](https://github.com/Digilent/digilent-xdc/blob/master/Basys-3-Master.xdc)
- Course handout: `Lab1_SoftwareInstallation_and_XOR_Implementation.pdf` (provided separately).
