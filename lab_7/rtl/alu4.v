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
    wire [4:0] difference;
    wire Less;
    wire PG, GG;

    assign BB = F[2] ? ~B : B;

    CLA4 adder (.A(A), .B(BB), .Ci(F[2]), .S(S),
                .Co(C_out), .PG(PG), .GG(GG));

    // Unsigned addition: carry. Unsigned subtraction: borrow.
    assign Overflow = F[2] ? ~C_out : C_out;

    // TA's comparison: A - ~BB. The extra bit is 1 when subtraction borrows.
    assign difference = {1'b0, A} - {1'b0, ~BB};
    assign Less = difference[4];

    assign Y = (F[1:0] == 2'b00) ? (A & BB) :
               (F[1:0] == 2'b01) ? (A | BB) :
               (F[1:0] == 2'b10) ? S :
               {3'b000, Less}; // Unsigned SLT for both F=011 and F=111.

    assign Zero = (Y == 4'b0000);
endmodule
