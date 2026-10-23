# Lab 6: Vending Machine FSM

CMPE 125 · Vivado 2025.2 · October 22, 2026

## Implementation

The design uses the button-driven controller in the supplied reference PDF.
There is one synthesizable module, `vending_machine`, and one testbench,
`vending_machine_tb`. Simulation and the Basys 3 board use that same module.
The PDF's state encodings, initialization, and entire clocked block are
preserved. The only interface change is keeping `state` internal because
the supplied constraints do not assign pins to a state output.

The soda costs 25 cents. Switches select a nickel, dime, or quarter, and a
sampled button press accepts the selected coin. `button_prev` stores the
previous sampled button value. The condition `button && !button_prev`
recognizes a rising edge. A continuously high button accepts only one coin
for clean input signals; releasing it permits another insertion.

The positive clock edge updates credit and the registered dispense/change
outputs. Outputs retain their values until the next accepted button edge or
reset. A new press first clears the previous outputs, then computes the
result for the selected coin and old credit. These are registered outputs;
the testbench checks them after the clock edge and after releasing the button.

`reset` is asynchronous and active high. It clears credit, `button_prev`,
and all four outputs. The PDF also initializes these registers to zero.
Without a button edge, coin switch changes have no effect. A button edge
with no selected coin clears outputs and holds credit. With several selected
coins, the PDF gives priority to nickel, then dime, then quarter.

## State encoding and transitions

The source declares five credit states using three bits:

| State | Credit | Encoding |
|---|---:|:---:|
| S0 | 0 cents | 000 |
| S1 | 5 cents | 001 |
| S2 | 10 cents | 010 |
| S3 | 15 cents | 011 |
| S4 | 20 cents | 100 |

Three bits can represent eight codes and are sufficient for five credit
states. `button_prev` and the four held outputs require additional storage.
Synthesis may optimize or recode the source state representation.

Each cell below gives **next state / output result** for an accepted press
with exactly one selected coin. Let
`Y = {Dispense, ReturnNickel, ReturnDime, ReturnTwoDimes}`.

| Credit state | Nickel | Dime | Quarter |
|---|---|---|---|
| S0 | S1 / 0000 | S2 / 0000 | S0 / 1000 |
| S1 | S2 / 0000 | S3 / 0000 | S0 / 1100 |
| S2 | S3 / 0000 | S4 / 0000 | S0 / 1010 |
| S3 | S4 / 0000 | S0 / 1000 | S0 / 1110 |
| S4 | S0 / 1000 | S0 / 1100 | S0 / 1001 |

A vending transition clears credit to S0 and records the appropriate result.
`1110` means dispense and return a nickel plus a dime (15 cents).
`1001` means dispense and return two dimes (20 cents). A subsequent coin
belongs to the next purchase. In the PDF's default case, an unused state
returns to S0 on an accepted button edge.

## Basys 3 connections and demo

The FPGA target is `xc7a35tcpg236-1` with a 100 MHz clock on W5.
All ten active pin assignments match the supplied PDF.

| Control/output | Board control | Pin |
|---|---|---|
| Nickel | SW0 | V17 |
| Dime | SW1 | V16 |
| Quarter | SW2 | W16 |
| reset | SW3 | W17 |
| button | BTNC | U18 |
| Dispense | LD3 | V19 |
| ReturnNickel | LD2 | U19 |
| ReturnDime | LD1 | E19 |
| ReturnTwoDimes | LD0 | U16 |

Open with `./lab open lab_6`. Run Behavioral Simulation first, then generate
the bitstream and program the board through Hardware Manager. The generated
file is `lab_6/build/lab6/lab6.runs/impl_1/vending_machine.bit`.
Reset by raising and lowering SW3. Select one coin with SW0, SW1, or SW2,
then press and release BTNC. A quarter alone lights LD3. A nickel followed
by a quarter lights LD3 and LD2. The seven-segment display is not used.

The reference PDF directly samples asynchronous controls and does not include
synchronization or button debounce. Physical contact bounce may count extra
coins. The timing constraints exclude asynchronous control input paths and
static LED output paths; these exceptions do not add synchronization or
debounce. Internal paths remain timed at 100 MHz. Physical board behavior
still requires testing after programming.

## Verification

The single testbench reproduces both PDF transactions and their timing:

- Nickel followed by quarter: soda plus 5 cents change (`1100`).
- Dime, dime, nickel: soda with no change (`1000`).

Additional checks visit all five credit states and try each coin, covering
all 15 single-coin transitions. An independent arithmetic reference computes
the next credit and change from cents. All change amounts (0, 5, 10, 15,
and 20 cents) are exercised. Tests also check held buttons, held outputs,
asynchronous reset, coin switches without a button press, empty selections,
and priority for multiple selected coins. Failures stop with `$fatal`.

Run the testbench from the repository root:

```sh
mkdir -p lab_6/build
(cd lab_6/build && vivado -mode batch -source ../scripts/verify.tcl)
```

The expected successful transcript is:

```text
Test 1 PASS: Soda and 5 cents change
Test 2 PASS: Soda and no change
PASS: PDF board FSM: both PDF examples, all 15 coin transitions, held outputs/button, reset, switch isolation, and input priority.
```

Build and check the implementation with:

```sh
(cd lab_6/build && vivado -mode batch -source ../scripts/bitstream.tcl)
```

The build writes internal timing, utilization, and DRC reports under `build/`.
The bitstream and generated reports are excluded from Git. The appendices
contain the exact design source, single testbench, and board constraints.
