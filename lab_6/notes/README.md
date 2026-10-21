# Lab 6 — vending machine FSM

Open the project from the repository root:

```sh
./lab open lab_6
```

Choose **Run Simulation > Run Behavioral Simulation**. The project uses
`vending_machine` as the design top and `vending_machine_tb` as the simulation
top. `test_vector.tv` is a simulation memory-initialization file, so XSim copies
it into its working directory automatically. No absolute path is needed.

The testbench reads 228 vectors, verifies all 40 state/input combinations,
checks all four nonzero change amounts, checks asynchronous reset, and tests
recovery from all three unused state encodings. Failures stop with `$fatal`.
The successful transcript reports 20 sodas and 110 cents returned during the
vector tests. Forced illegal-state checks do not count as purchases.

The included waveform configuration selects `clk`, `reset`, `Nickel`, `Dime`,
`Quarter`, `uut/state`, `Dispense`, `ReturnNickel`, `ReturnDime`, and
`ReturnTwoDimes`, zoomed to approximately **0–214 ns** to show each change amount.

This is a Mealy FSM. Inputs and combinational outputs are sampled at each
rising edge. The testbench drives coins at falling edges, checks outputs
1 ns later, checks the new state 1 ns after the rising edge, and then clears
the coin. Outputs can change as soon as an input or state changes. They are
not registered full-cycle pulses. Consecutive cycles may each insert a coin;
no extra dispense state or dead cycle is needed.

`reset` is active high and asynchronous. With `reset=1`, the credit is cleared
and all outputs are zero. Idle (`NDQ=000`) and multiple coins (`011`, `101`,
`110`, `111`) hold credit and produce no output. The handout assumes one coin
per cycle; these extra cases define deterministic behavior outside that
assumption. Unused state encodings recover to zero credit on the next edge.

Batch verification:

```sh
mkdir -p lab_6/build
(cd lab_6/build && vivado -mode batch -source ../scripts/verify.tcl)
```

The [report](report.md) includes the full design and verification discussion;
[report.pdf](report.pdf) is the printable copy. Diagrams and actual Vivado
screenshots are in `figures/`. The report includes source listings, and the
editable originals are `../rtl/vending_machine.v`,
`../sim/vending_machine_tb.v`, and `../sim/test_vector.tv`.

To rebuild the PDF after editing the report or sources, run from the repository
root (requires `uv`):

```sh
uv run --with markdown --with weasyprint python lab_6/scripts/report.py
```

The Canvas report-format guideline was not included with the handout. Check
its cover-page, naming, and submission requirements before uploading.
