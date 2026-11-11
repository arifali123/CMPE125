`timescale 1ns / 1ps

module alu4 (
    input [3:0] A,
    input [3:0] B,
    input [2:0] F,
    output [3:0] Y,
    output C_out,
    output Overflow,
    output Zero
);
    wire [3:0] BB, adder_B, S;
    wire Less, Subtract, SLT;
    wire PG, GG;

    // F[2] selects the operand BB for logic and unsigned comparison.
    assign BB = F[2] ? ~B : B;
    assign SLT = F[1] & F[0];
    // For SLT, the same CLA subtracts BB: A + ~BB + 1.
    assign adder_B = SLT ? ~BB : BB;
    assign Subtract = F[2] | SLT;

    CLA4 adder (.A(A), .B(adder_B), .Ci(Subtract), .S(S),
                .Co(C_out), .PG(PG), .GG(GG));

    // Unsigned addition: carry. Unsigned subtraction: borrow.
    assign Overflow = Subtract ? ~C_out : C_out;

    // During SLT, no carry means A is less than the selected operand BB.
    assign Less = ~C_out;

    assign Y = (F[1:0] == 2'b00) ? (A & BB) :
               (F[1:0] == 2'b01) ? (A | BB) :
               (F[1:0] == 2'b10) ? S :
               {3'b000, Less}; // Unsigned SLT for both F=011 and F=111.

    assign Zero = (Y == 4'b0000);
endmodule
