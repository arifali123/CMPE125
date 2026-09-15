`timescale 1ns / 1ps

// Full adder from the Lab 2 classroom example.
module full_adder (
    input A,
    input B,
    input Cin,
    output Cout,
    output S
);
    wire AxorB = (~A & B) | (A & ~B);
    assign S = (~AxorB & Cin) | (AxorB & ~Cin);
    assign Cout = A & B | Cin & A | Cin & B;
endmodule
