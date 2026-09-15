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
