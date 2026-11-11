`timescale 1ns / 1ps

module alu32 (
    input [31:0] A,
    input [31:0] B,
    input [2:0] F,
    output [31:0] Y,
    output C_out,
    output Overflow,
    output Zero
);
    wire [31:0] BB, adder_B, S;
    wire Less, Subtract, SLT;
    wire [8:0] C;
    wire [7:0] PG, GG;

    // F[2] selects the operand BB for logic and unsigned comparison.
    assign BB = F[2] ? ~B : B;
    assign SLT = F[1] & F[0];
    // For SLT, the same CLA chain subtracts BB: A + ~BB + 1.
    assign adder_B = SLT ? ~BB : BB;
    assign Subtract = F[2] | SLT;
    assign C[0] = Subtract;

    // Eight Lab 4 adders, connected from the low bits to the high bits.
    CLA4 adder0 (.A(A[3:0]),   .B(adder_B[3:0]),   .Ci(C[0]), .S(S[3:0]),   .Co(C[1]), .PG(PG[0]), .GG(GG[0]));
    CLA4 adder1 (.A(A[7:4]),   .B(adder_B[7:4]),   .Ci(C[1]), .S(S[7:4]),   .Co(C[2]), .PG(PG[1]), .GG(GG[1]));
    CLA4 adder2 (.A(A[11:8]),  .B(adder_B[11:8]),  .Ci(C[2]), .S(S[11:8]),  .Co(C[3]), .PG(PG[2]), .GG(GG[2]));
    CLA4 adder3 (.A(A[15:12]), .B(adder_B[15:12]), .Ci(C[3]), .S(S[15:12]), .Co(C[4]), .PG(PG[3]), .GG(GG[3]));
    CLA4 adder4 (.A(A[19:16]), .B(adder_B[19:16]), .Ci(C[4]), .S(S[19:16]), .Co(C[5]), .PG(PG[4]), .GG(GG[4]));
    CLA4 adder5 (.A(A[23:20]), .B(adder_B[23:20]), .Ci(C[5]), .S(S[23:20]), .Co(C[6]), .PG(PG[5]), .GG(GG[5]));
    CLA4 adder6 (.A(A[27:24]), .B(adder_B[27:24]), .Ci(C[6]), .S(S[27:24]), .Co(C[7]), .PG(PG[6]), .GG(GG[6]));
    CLA4 adder7 (.A(A[31:28]), .B(adder_B[31:28]), .Ci(C[7]), .S(S[31:28]), .Co(C[8]), .PG(PG[7]), .GG(GG[7]));

    assign C_out = C[8];
    // Unsigned addition: carry. Unsigned subtraction: borrow.
    assign Overflow = Subtract ? ~C_out : C_out;

    // During SLT, no carry means A is less than the selected operand BB.
    assign Less = ~C_out;

    assign Y = (F[1:0] == 2'b00) ? (A & BB) :
               (F[1:0] == 2'b01) ? (A | BB) :
               (F[1:0] == 2'b10) ? S :
               {31'b0, Less}; // Unsigned SLT for both F=011 and F=111.

    assign Zero = (Y == 32'b0);
endmodule
