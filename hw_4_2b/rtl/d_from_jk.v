`timescale 1ns / 1ps

// Question 2b: J = D and K = ~D; reuse the structural JK from 2a.
module d_from_jk(input clk, input reset, input D, output Q);
    jk_from_d storage (.clk(clk), .reset(reset), .J(D), .K(~D), .Q(Q));
endmodule
