# Lab 8 — Dual-Port Memory Design

Open the project from the repo root.

```sh
./lab open lab_8
```

The design top is `basys3_ram_demo` for the Basys 3 (`xc7a35tcpg236-1`).
The board pin and configuration voltage settings follow
[Digilent's Basys 3 Master XDC](https://github.com/Digilent/digilent-xdc/blob/master/Basys-3-Master.xdc).
The project starts with `tb_ram_single.v` enabled. To switch, close the
running simulation, then right-click the current file in **Simulation Sources**
and choose **Disable File**. Right-click the next testbench, choose
**Enable File**, and run **Behavioral Simulation**. The project remembers
which file is enabled.

| Testbench file | What it checks |
|---|---|
| `tb_ram_single.v` | Asynchronous reads, rising-edge writes, addresses 5 and 127, and disabled writes |
| `tb_ram_dual_two_clocks.v` | Each port writes, and the other port reads the same location, using 10 ns and 14 ns clocks |
| `tb_ram_true_dual_port.v` | Both ports write different addresses on the same edge, then read each other's data |
| `tb_basys3_ram_demo.v` | Button bounce and holds, write enable, the mode and port controls, and data retention across modes and menu reset |

## Program the board

1. Connect and power the Basys 3 using its programming USB port.
2. In Vivado, choose **Open Hardware Manager → Open Target → Auto Connect**.
3. Choose **Program Device** and select
   `lab_8/build/lab_8/lab_8.runs/impl_1/basys3_ram_demo.bit`.
   If the file is missing, choose **Generate Bitstream** first.

| Control | Function |
|---|---|
| SW6:0 | Address from 0 to 127, with SW0 as the least significant bit |
| SW14:7 | Byte to write, with SW7 as the least significant bit |
| SW15 | Write enable, mirrored on LED15 |
| BTNC | Write once with SW15 enabled |
| BTNU | Cycle Single → Two-clock → True dual → Single |
| BTNL | Toggle A/B in either dual-port mode |
| BTND | Return to Single and port A while preserving all three RAMs |
| LED7:0 | Data at the selected address |
| LED9:8 | Mode, with `00` Single, `01` Two-clock, and `10` True dual |
| LED10 | Port, with off for A and on for B |
| LED14:11 | Off |

Set the switches before pressing BTNC. Each button is synchronized and
debounced. Unwritten locations have unspecified contents.

## Demo walkthrough

1. Press **BTND**. Set address 5 by turning on SW0 and SW2. For data
   `0x2A` (decimal 42), turn on SW8, SW10, and SW12. Set all other
   address and data switches off. Turn on **SW15** and press **BTNC**.
   **LED1, LED3, and LED5** show the byte.
2. Turn off **SW15**, change the data switches, and press **BTNC** again.
   The LEDs still show `0x2A`. Change the address and return to 5 to
   demonstrate readback.
3. Press **BTNU** once to enter Two-clock mode (**LED8**). At address 5,
   set `0x55` with SW7, SW9, SW11, and SW13 on and the other data
   switches off. Enable writes and press **BTNC** on port A. Press **BTNL**
   to select B (**LED10**). **LED0, LED2, LED4, and LED6** still show
   `0x55`. To demonstrate the reverse direction, write `0xAA` on B
   with SW8, SW10, SW12, and SW14 on and the other data switches off,
   then press **BTNL** to read it back on A.
4. Press **BTNU** again for True dual mode (**LED9**). Repeat the write
   on A and read on B with either byte. Press **BTND** to return to Single
   and read back the original `0x2A` at address 5.

All three RAMs store 128 bytes. The single-port RAM reads asynchronously
and writes on a rising edge. Each dual-port core has synchronous reads
and writes and returns the prior value on a same-port write edge.
Simultaneous writes to the same location are outside the design's
contract. The board routes the unused port to a different address during
a write. Both clock inputs of the two-clock RAM use the board's 100 MHz
clock in the demo. Use the dedicated simulation to show independent
clocks, and the true dual-port simulation to show simultaneous writes.

See the [report guide](REPORT_GUIDE.md) for screenshots to capture in Vivado.
