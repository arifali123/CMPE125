`timescale 1ns / 1ps

// Problem 2: true when at least two inputs are false.
module minority (
    input a,
    input b,
    input c,
    output y
);
    assign y = (~a & ~b) | (~a & ~c) | (~b & ~c);
endmodule
