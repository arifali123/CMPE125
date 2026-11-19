# Lab 8 — Dual-Port Memory Design

Open the project from the repo root.

```sh
./lab open lab_8
```

The project contains the three RAM designs and their testbenches required by
the Lab 8 handout. Each RAM stores 128 words of eight bits, or 128 bytes.

The project starts with `tb_ram_single.v` enabled. To switch, close the
running simulation, then right-click the current file in **Simulation Sources**
and choose **Disable File**. Right-click the next testbench, choose
**Enable File**, and run **Behavioral Simulation**. Keep one testbench
enabled at a time. The project remembers which file is enabled.
All three testbench files use the simulation top `lab8_tb`.

| Design | Testbench file | What it checks |
|---|---|---|
| `ram_single` | `tb_ram_single.v` | Asynchronous reads, rising-edge writes, addresses 5 and 127, and disabled writes |
| `ram_dual_two_clocks` | `tb_ram_dual_two_clocks.v` | Each port writes, and the other port reads the same location, using independent 10 ns and 14 ns clocks |
| `ram_true_dual_port` | `tb_ram_true_dual_port.v` | Both ports write different addresses on the same edge, then read each other's data, with clocked output hold and read-first checks |

The given single-port RAM combines asynchronous reads with synchronous writes.
Both dual-port implementations use synchronous reads and writes. Each dual-port
design has two read/write ports sharing one memory array. The two-clock design
uses a separate clock per port, while the true dual-port design shares one clock.

A same-port write edge reads the previous value in the dual-port designs.
Avoid concurrent access to a location while another port writes it.
Simultaneous writes by both ports to the same address have undefined results.
Unwritten locations have unspecified contents.

Use **Zoom Fit** in the waveform window and check the Tcl Console for the
`ALL ... TESTS PASSED` message. Expand the design instance to inspect the
memory. Capture compilation output and simulation waveforms for each design.

Submit the three implementations, their testbenches, and screenshots in a
report following the Canvas report guideline. See [the report guide](REPORT_GUIDE.md).
