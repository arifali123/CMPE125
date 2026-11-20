# Lab 8 — Dual-Port Memory Design

Open the project from the repo root.

```sh
./lab open lab_8
```

The project contains the three RAM designs and their testbenches required by
the Lab 8 handout. Following the instructor's clarification, all addresses
are eight bits and each RAM stores 256 words of eight bits, or 256 bytes.
Addresses range from 0 to 255. The PDF's original example used 128 locations
with seven-bit addresses.

The project starts with `tb_ram_single.v` enabled. To switch, close the
running simulation, then right-click the current file in **Simulation Sources**
and choose **Disable File**. Right-click the next testbench, choose
**Enable File**, and run **Behavioral Simulation**. Keep one testbench
enabled at a time. The project remembers which file is enabled.
All three testbench files use the simulation top `lab8_tb`.

| Design | Testbench file | What it checks |
|---|---|---|
| `ram_single` | `tb_ram_single.v` | Asynchronous reads, rising-edge writes, disabled writes, and pattern readback at all 256 addresses |
| `ram_dual_two_clocks` | `tb_ram_dual_two_clocks.v` | Full-memory readback with independent clocks, request/response handshaking, write priority, and concurrent access |
| `ram_true_dual_port` | `tb_ram_true_dual_port.v` | Full-memory readback, simultaneous writes, A-priority collisions, and read-first access in both directions |

The given single-port RAM combines asynchronous reads with synchronous writes.
Both dual-port implementations have synchronous reads and writes with one
shared storage array per design.

## Collision policy

Port A has priority when both ports write the same location during the same
memory service cycle. Port B's conflicting write is rejected. Concurrent
writes to different addresses both succeed. All reads return the value held
before that service edge, including a read from an address being written by
either port. Two reads can access the same location.

In `ram_true_dual_port`, both ports execute on the shared clock. The
combinational output `collision` is high when both write enables are high
and the addresses match. Sample it at the write edge.

In `ram_dual_two_clocks`, port A executes on `clk1`. Port B submits an
operation on a `clk2` rising edge with `request2 && ready2`. Its address,
data, and write enable are captured. A toggle handshake carries the request
to the `clk1` memory engine, which arbitrates it alongside A. The response
returns to `clk2` several cycles later. A one-cycle `valid2` pulse marks
valid `q2` and `collision2`. A high `collision2` reports a rejected B
write. The caller can retry it after A stops writing that location.

Only one B transaction can be outstanding. Submit another when `ready2`
is high. Holding `request2` high submits another operation on each ready
edge. B reads also require a request. Arbitration compares A's access with
the captured B request when the engine services it, so the two input clock
edges need no timing relationship.

The handshake synchronizes control toggles through two flip-flops and holds
each transferred data bus stable until the receiving side acknowledges it.
Physical implementation requires CDC and timing review for these held-bus
paths. The lab verifies this protocol in XSim with independent clocks.

Unwritten locations have unspecified contents.
All three testbenches check the upper address bit and distinct storage across
the full address range, including addresses 0, 127, 128, and 255.

Use **Zoom Fit** in the waveform window and check the Tcl Console for the
`ALL ... TESTS PASSED` message. Expand the design instance to inspect the
memory. Capture compilation output and simulation waveforms for each design.

Submit the three implementations, their testbenches, and screenshots in a
report following the Canvas report guideline. See [the report guide](REPORT_GUIDE.md).
