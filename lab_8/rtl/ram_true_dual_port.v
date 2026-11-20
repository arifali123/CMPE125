// Lab 8 - 256 x 8 shared-clock dual-port RAM.
// All reads are read-first. Port A wins same-address write collisions.
module ram_true_dual_port (
    input  wire       clk,
    input  wire       we1,
    input  wire       we2,
    input  wire [7:0] a1,
    input  wire [7:0] a2,
    input  wire [7:0] d1,
    input  wire [7:0] d2,
    output reg  [7:0] q1,
    output reg  [7:0] q2,
    output wire       collision
);
    reg [7:0] mem [0:255];

    assign collision = we1 && we2 && (a1 == a2);

    always @(posedge clk) begin
        q1 <= mem[a1];
        if (we1)
            mem[a1] <= d1;
    end

    always @(posedge clk) begin
        q2 <= mem[a2];
        if (we2 && !collision)
            mem[a2] <= d2;
    end
endmodule
