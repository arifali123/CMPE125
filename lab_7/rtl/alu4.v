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
    wire PG, GG;

    assign BB = F[2] ? ~B : B;

    CLA4 adder (.A(A), .B(BB), .Ci(F[2]), .S(S),
                .Co(C_out), .PG(PG), .GG(GG));

    assign Overflow = (~(A[3] ^ BB[3])) & (A[3] ^ S[3]);

    assign Y = (F[1:0] == 2'b00) ? (A & BB) :
               (F[1:0] == 2'b01) ? (A | BB) :
               (F[1:0] == 2'b10) ? S :
               {3'b000, S[3]}; // Mux input 3: zero-extend the sum's sign bit.

    assign Zero = (Y == 4'b0000);
endmodule
