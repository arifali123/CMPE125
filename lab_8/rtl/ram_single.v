// Lab 8 - 128 x 8 single-port RAM
// Reads are asynchronous; writes occur on a rising clock edge.
module ram_single (
    input  wire       clk,
    input  wire       we,
    input  wire [6:0] a,
    input  wire [7:0] d,
    output wire [7:0] q
);
    reg [7:0] mem [0:127];

    assign q = mem[a];             // Read selected address immediately.

    always @(posedge clk) begin    // Write only at the clock's rising edge.
        if (we)
            mem[a] <= d;
    end
endmodule
