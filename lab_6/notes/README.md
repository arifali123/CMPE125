# Lab 6 — vending machine FSM

Open the project from the repository root:

```sh
./lab open lab_6
```

Choose **Run Simulation > Run Behavioral Simulation**. The project uses
`vending_machine_tb` as the simulation top. It tests the original
`vending_machine` Mealy controller directly. The synthesis/design top is
`vending_machine_board`, which adds the physical controls described below.
`test_vector.tv` is a simulation memory-initialization file, so XSim copies
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

Batch verification runs both the original FSM testbench and the board-control
testbench, then restores `vending_machine_tb` and its waveform configuration:

```sh
mkdir -p lab_6/build
(cd lab_6/build && vivado -mode batch -source ../scripts/verify.tcl)
```

## Basys 3 demo after the simulation

The included [constraints](../constraints/basys3.xdc) use the same active pins
as the reference PDF, checked against the
[Digilent Basys 3 Master XDC](https://github.com/Digilent/digilent-xdc/blob/master/Basys-3-Master.xdc).
The project loads them automatically, including when reopening an existing
Lab 6 project through `./lab open lab_6`.

1. Show **Run Behavioral Simulation** first. Look for the three `PASS` messages
   and show the core's credit and Mealy outputs before the rising clock edge.
2. Close the simulation. Confirm `vending_machine_board` is the design top,
   then choose **Generate Bitstream**. The project targets `xc7a35tcpg236-1`.
3. Connect and power the Basys 3 through its programming USB connection.
   Open **Hardware Manager > Open Target > Auto Connect**, choose **Program
   Device**, and select
   `lab_6/build/lab6/lab6.runs/impl_1/vending_machine_board.bit`.
4. Start with SW0–SW2 down. Flip **SW3 up, then down** to reset. All four
   result LEDs should be off.
5. Select exactly one coin switch: **SW0 = nickel**, **SW1 = dime**, or
   **SW2 = quarter**. Press and release the **center button** once per coin.
   Turn the previous coin switch off before selecting a different one.

The board's 100 MHz clock is W5. SW0/SW1/SW2/SW3 use V17/V16/W16/W17,
and the center button uses U18. The four LEDs follow the PDF:

- **LD3 / V19:** dispense.
- **LD2 / U19:** return one nickel.
- **LD1 / E19:** return one dime.
- **LD0 / U16:** return two dimes.

For a quick demonstration, insert a nickel, then a quarter. LD3 and LD2
should light: one soda plus 5 cents change. For the other amounts, reset
between sequences and try D,Q (LD3+LD1), N,D,Q (LD3+LD2+LD1), and D,D,Q
(LD3+LD0). A quarter alone lights only LD3. Leave SW1 selected and press
twice to insert two separate dimes; changing a switch alone never inserts a coin.

The [board wrapper](../rtl/vending_machine_board.v) synchronizes the switch
and button inputs and requires 10 ms of stable button level on both press and
release. Holding the button accepts only one coin. The wrapper gates the coin
into the unchanged core for one clock cycle and captures its Mealy output on
the same edge that updates credit. The LEDs hold that result until the next
accepted press or reset. A press with no coin or several coin switches on
holds credit and clears the previous LED result. Select the coin before pressing.
Reset asserts asynchronously and releases through two clocked stages.
Only the controller's credit uses the original three state flip-flops;
the board controls and LED storage use additional flip-flops.

The [board testbench](../sim/vending_machine_board_tb.v) shortens the debounce
interval for simulation and checks startup, reset, switch changes without a
press, button bounce on press/release, long holds, all change indications,
invalid selections, and repeated purchases. The simulation cannot verify
physical contacts, USB programming, or the connected board itself.

To build a bitstream in batch mode with pin, DRC, and timing reports:

```sh
(cd lab_6/build && vivado -mode batch -source ../scripts/bitstream.tcl)
```

The build writes `board_timing.txt`, `board_utilization.txt`, and
`board_drc.txt` under `build/`. It checks internal setup and hold timing at
100 MHz. The XDC excludes asynchronous human-control input paths and static
LED output paths from synchronous timing; paths between synchronizer stages
and the remaining internal logic stay timed. Bitstreams and reports are
generated files; regenerate them on another computer after pulling the sources.

The [report](report.md) covers the Mealy controller's design and verification;
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
