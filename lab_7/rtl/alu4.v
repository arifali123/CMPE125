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
    wire [3:0] BB, S;
    wire Less, Subtract;
    wire PG, GG;

    // SLT needs A - B for either F[2] value; use the same CLA as arithmetic.
    assign Subtract = F[2] | (F[1] & F[0]);
    assign BB = Subtract ? ~B : B;

    CLA4 adder (.A(A), .B(BB), .Ci(Subtract), .S(S),
                .Co(C_out), .PG(PG), .GG(GG));

    // Unsigned addition: carry. Unsigned subtraction: borrow.
    assign Overflow = Subtract ? ~C_out : C_out;

    // SLT selects subtraction: no carry means a borrow, so A is less than B.
    assign Less = ~C_out;

    assign Y = (F[1:0] == 2'b00) ? (A & BB) :
               (F[1:0] == 2'b01) ? (A | BB) :
               (F[1:0] == 2'b10) ? S :
               {3'b000, Less}; // Unsigned SLT for both F=011 and F=111.

    assign Zero = (Y == 4'b0000);
endmodule
