`timescale 1ns / 1ps

// Question 2a: D = J*~Q + ~K*Q, with one D flip-flop.
module d_flip_flop(input clk, input reset, input D, output reg Q);
    always @(posedge clk or posedge reset)
        if (reset) Q <= 1'b0;
        else       Q <= D;
endmodule

module jk_from_d(input clk, input reset, input J, input K, output Q);
    wire D;
    assign D = (J & ~Q) | (~K & Q);
    d_flip_flop storage (.clk(clk), .reset(reset), .D(D), .Q(Q));
endmodule
