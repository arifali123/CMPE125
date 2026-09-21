`timescale 1ns / 1ps

// Problem 4: active-high 2-to-4 decoder, no enable input.
module decoder2to4 (
    input [1:0] a,
    output [3:0] y
);
    assign y = 4'b0001 << a;
endmodule
