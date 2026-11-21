# Lab 6 report screenshots

Actual Vivado 2025.2 editor and XSim behavioral-simulation captures of the existing Lab 6 files. Use the cropped PNGs in the report; matching full PNGs preserve the Vivado window. Code captures overlap to keep every line readable.

## Waveforms

State values 0–4 represent 0¢, 5¢, 10¢, 15¢, and 20¢ credit. The Value column shows the yellow cursor time. Coin acceptance occurs on a clock rising edge when `button` rises relative to `button_prev`; outputs remain asserted until reset or another accepted press.

| Report image | Full Vivado image | Suggested caption |
| --- | --- | --- |
| [01_reference_transactions_crop.png](01_reference_transactions_crop.png) | [Full](01_reference_transactions_full.png) | Nickel + quarter: dispense with 5¢ change at 45 ns (cursor 48 ns). Two dimes + nickel: exact payment and dispense at 125 ns. Reset separates the transactions. |
| [02_return_dime_crop.png](02_return_dime_crop.png) | [Full](02_return_dime_full.png) | Two nickels + quarter: 35¢ total; Dispense and ReturnDime assert at 1175 ns (cursor 1180 ns). |
| [03_return_fifteen_crop.png](03_return_fifteen_crop.png) | [Full](03_return_fifteen_full.png) | Three nickels + quarter: 40¢ total; Dispense, ReturnNickel, and ReturnDime assert at 1835 ns (cursor 1840 ns). |
| [04_return_two_dimes_crop.png](04_return_two_dimes_crop.png) | [Full](04_return_two_dimes_full.png) | Four nickels + quarter: 45¢ total; Dispense and ReturnTwoDimes assert at 2645 ns (cursor 2650 ns). The preceding four-nickel + dime case returns 5¢ at 2375 ns. |

## Source code

| Report image | Full Vivado image | Suggested caption |
| --- | --- | --- |
| [rtl_01_crop.png](rtl_01_crop.png) | [Full](rtl_01_full.png) | vending_machine.v, lines 1–38: Ports, state encoding, and initialization. |
| [rtl_02_crop.png](rtl_02_crop.png) | [Full](rtl_02_full.png) | vending_machine.v, lines 31–68: Reset, button-edge detection, and S0 transitions. |
| [rtl_03_crop.png](rtl_03_crop.png) | [Full](rtl_03_full.png) | vending_machine.v, lines 61–98: S0–S2 coin transitions and change outputs. |
| [rtl_04_crop.png](rtl_04_crop.png) | [Full](rtl_04_full.png) | vending_machine.v, lines 91–128: S3–S4 vending and change logic. |
| [rtl_05_crop.png](rtl_05_crop.png) | [Full](rtl_05_full.png) | vending_machine.v, lines 99–134: Remaining S3–S4 logic, default state, and module ending. |
| [tb_01_crop.png](tb_01_crop.png) | [Full](tb_01_full.png) | vending_machine_tb.v, lines 1–38: Testbench signals, expected-result matrix declarations, DUT, and clock. |
| [tb_02_crop.png](tb_02_crop.png) | [Full](tb_02_full.png) | vending_machine_tb.v, lines 31–68: Result checking, asynchronous reset, and coin-insertion tasks. |
| [tb_03_crop.png](tb_03_crop.png) | [Full](tb_03_full.png) | vending_machine_tb.v, lines 61–98: Coin priority and expected transition matrix. |
| [tb_04_crop.png](tb_04_crop.png) | [Full](tb_04_full.png) | vending_machine_tb.v, lines 91–128: Matrix completion and opening transactions. |
| [tb_05_crop.png](tb_05_crop.png) | [Full](tb_05_full.png) | vending_machine_tb.v, lines 121–158: Exact-payment completion and transition-matrix test loop. |
| [tb_06_crop.png](tb_06_crop.png) | [Full](tb_06_full.png) | vending_machine_tb.v, lines 151–188: State/input combinations and button/switch behavior tests. |
| [tb_07_crop.png](tb_07_crop.png) | [Full](tb_07_full.png) | vending_machine_tb.v, lines 173–208: Remaining behavior checks, coverage checks, summary code, and timeout. |
| [constraints_crop.png](constraints_crop.png) | [Full](constraints_full.png) | basys3.xdc, lines 1–31: board pins and timing constraints. |

The attached lab PDF supplies the vending-machine requirements. Captions describe the existing implementation and stimulus; comments in the source referring to a PDF are reproduced unchanged.
