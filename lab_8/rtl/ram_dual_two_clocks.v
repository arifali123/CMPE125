// Lab 8 - 256 x 8 dual-port RAM with TWO independent input clocks.
// Both ports read and write on their own rising clock edges.
// Synchronous reads allow Vivado to infer FPGA block RAM.
// Simultaneous writes to the SAME address are intentionally NOT defined.
module ram_dual_two_clocks (
    input  wire       clk1,
    input  wire       clk2,
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

    always @(posedge clk1) begin
        q1 <= mem[a1];               // Synchronous read, port A.
        if (we1) mem[a1] <= d1;      // Synchronous write, port A.
    end

    always @(posedge clk2) begin
        q2 <= mem[a2];               // Synchronous read, port B.
        if (we2) mem[a2] <= d2;      // Synchronous write, port B.
    end
endmodule
