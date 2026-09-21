`timescale 1ns / 1ps

// Problem 1: odd parity of four inputs.
module xor4 (
    input [3:0] a,
    output y
);
    assign y = ^a;
endmodule
