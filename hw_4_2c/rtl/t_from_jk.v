`timescale 1ns / 1ps

// Question 2c: the assignment's T flip-flop toggles on every rising edge.
// J = K = 1. Reset is only for establishing a known initial state.
module t_from_jk(input clk, input reset, output Q);
    jk_from_d storage (.clk(clk), .reset(reset), .J(1'b1), .K(1'b1), .Q(Q));
endmodule
