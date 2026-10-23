# Lab 6 — vending machine demo

Open the project from the repository root:

```sh
./lab open lab_6
```

The design is the button-driven FSM from the supplied PDF:
[Verilog](../rtl/vending_machine.v), design top `vending_machine`.
It uses the PDF's five credit states, `button_prev`, and one clocked block.
The initialization and clocked logic are copied from the PDF. `state` is
internal because the PDF's XDC does not assign pins to that debug output.
There is one design file and one testbench for both simulation and the board.

## Show the testbench first

Choose **Run Simulation > Run Behavioral Simulation**. The default simulation
top is `vending_machine_tb`, so it demonstrates the same code you will
program onto the board. The waveform opens at 0–220 ns to show the two PDF
examples. Outputs are registered: inspect them after the accepting rising
clock edge. They remain asserted after the coin and button are released.

The [testbench](../sim/vending_machine_tb.v) checks the PDF's nickel +
quarter and dime + dime + nickel examples, then checks all 15 single-coin
transitions using an arithmetic reference. It also checks holding a button,
held LED results, asynchronous reset, switches without a press, empty coin
selection, and the PDF's nickel/dime/quarter priority when several switches
are selected. Failed checks stop with `$fatal`.

## Program the Basys 3

1. Close the simulation and choose **Generate Bitstream**. The design top is
   `vending_machine`, and the device is `xc7a35tcpg236-1`.
2. Connect and power the board through its programming USB connection.
   Open **Hardware Manager > Open Target > Auto Connect > Program Device**.
3. Select the newly generated file:
   `lab_6/build/lab6/lab6.runs/impl_1/vending_machine.bit`.
   Connecting USB or running simulation does not program the FPGA.
4. Put SW0–SW2 down, then flip **SW3 up and down** to reset.
5. Select **one** coin switch and press/release the **center button (BTNC)**
   once per coin. Turn the previous coin switch off before selecting another.

The [constraints](../constraints/basys3.xdc) use the PDF's active pin mapping,
which agrees with the
[Digilent Basys 3 Master XDC](https://github.com/Digilent/digilent-xdc/blob/master/Basys-3-Master.xdc).
The project loads the constraints automatically.

- **SW0 / V17:** nickel; rightmost switch.
- **SW1 / V16:** dime; second from right.
- **SW2 / W16:** quarter; third from right.
- **SW3 / W17:** active-high reset; fourth from right.
- **BTNC / U18:** insert the selected coin.
- **LD3 / V19:** dispense.
- **LD2 / U19:** return a nickel.
- **LD1 / E19:** return a dime.
- **LD0 / U16:** return two dimes.

The clock is 100 MHz on W5. The four result LEDs are immediately above the
four rightmost switches. The seven-segment display is not used.

For a quick check, select only SW2 and press BTNC: **LD3 should light**.
Reset, then insert a nickel followed by a quarter: **LD3 and LD2 should light**.
Other examples are D,Q (LD3+LD1), N,D,Q (LD3+LD2+LD1), and D,D,Q (LD3+LD0).
A nickel alone does not light anything: credit has not reached 25 cents.
Results stay lit until reset or the next button press. A press without a coin
clears the previous result and holds credit. Like the PDF, multiple switches
select nickel first, then dime, then quarter.

The PDF directly samples the physical controls. It has **no synchronization
or button debounce**, so contact bounce can register extra coins on a real
board. Simulation verifies clean input signals; it does not prove that a
physical button will produce only one edge. Select the coin before pressing.

## Batch checks and build

Run the testbench:

```sh
mkdir -p lab_6/build
(cd lab_6/build && vivado -mode batch -source ../scripts/verify.tcl)
```

Build a bitstream with internal 100 MHz setup/hold checks and DRC reports:

```sh
(cd lab_6/build && vivado -mode batch -source ../scripts/bitstream.tcl)
```

Reports are `build/board_timing.txt`, `build/board_utilization.txt`, and
`build/board_drc.txt`. Asynchronous control inputs and static LED outputs are
excluded from synchronous I/O timing; internal logic remains timed. These
constraints do not add synchronization or debounce. Generated files under
`build/`, including bitstreams, stay out of Git. Rebuild after pulling sources
on another computer.

## Report

The [report](report.md) and [printable report](report.pdf) describe this same
PDF implementation and include its Verilog, testbench, and pin constraints.
To rebuild the PDF after editing the report or sources:

```sh
uv run --with markdown --with weasyprint python lab_6/scripts/report.py
```
