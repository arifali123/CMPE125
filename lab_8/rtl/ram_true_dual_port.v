// Lab 8 - 256 x 8 true dual-port RAM, using ONE shared clock.
// Two independent read/write ports with synchronous reads and writes.
// This style allows Vivado to infer dual-port block RAM.
// Simultaneous writes to the SAME address are intentionally NOT defined.
module ram_true_dual_port (
    input  wire       clk,
    input  wire       we1,
    input  wire       we2,
    input  wire [7:0] a1,
    input  wire [7:0] a2,
    input  wire [7:0] d1,
    input  wire [7:0] d2,
    output reg  [7:0] q1,
    output reg  [7:0] q2
);
    reg [7:0] mem [0:255];

    always @(posedge clk) begin
        q1 <= mem[a1];
        if (we1) mem[a1] <= d1;
    end

    always @(posedge clk) begin
        q2 <= mem[a2];
        if (we2) mem[a2] <= d2;
    end
endmodule
