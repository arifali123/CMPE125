`timescale 1ns / 1ps

// Lab 4: 4-bit carry-lookahead adder, structural design.
// Equations follow the Lab 4 reference guide (Formulas 2-5).

// Partial full adder: no carry out, it only produces G, P and the sum.
module GPFullAdder (
    input Ai,
    input Bi,
    input Cin,
    output G,
    output P,
    output Sum
);
    assign G = Ai & Bi;
    assign P = Ai ^ Bi;
    assign Sum = P ^ Cin;
endmodule

// Carry-lookahead logic: every carry is computed directly from G, P and Ci.
// C[0] is the block carry in; C[3:1] feed the adders for bits 3:1.
module CLALogic (
    input [3:0] G,
    input [3:0] P,
    input Ci,
    output [3:0] C,
    output Co,
    output PG,
    output GG
);
    assign C[0] = Ci;
    assign C[1] = G[0] | (P[0] & Ci);
    assign C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & Ci);
    assign C[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0])
                | (P[2] & P[1] & P[0] & Ci);

    assign PG = P[3] & P[2] & P[1] & P[0];
    assign GG = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1])
              | (P[3] & P[2] & P[1] & G[0]);
    assign Co = GG | (PG & Ci);
endmodule

// Top level: S = A + B + Ci, Co = carry out, PG/GG = group propagate/generate.
module CLA4 (
    input [3:0] A,
    input [3:0] B,
    input Ci,
    output [3:0] S,
    output Co,
    output PG,
    output GG
);
    wire [3:0] G, P, C;

    GPFullAdder fa0 (.Ai(A[0]), .Bi(B[0]), .Cin(C[0]), .G(G[0]), .P(P[0]), .Sum(S[0]));
    GPFullAdder fa1 (.Ai(A[1]), .Bi(B[1]), .Cin(C[1]), .G(G[1]), .P(P[1]), .Sum(S[1]));
    GPFullAdder fa2 (.Ai(A[2]), .Bi(B[2]), .Cin(C[2]), .G(G[2]), .P(P[2]), .Sum(S[2]));
    GPFullAdder fa3 (.Ai(A[3]), .Bi(B[3]), .Cin(C[3]), .G(G[3]), .P(P[3]), .Sum(S[3]));

    CLALogic cla (.G(G), .P(P), .Ci(Ci), .C(C), .Co(Co), .PG(PG), .GG(GG));
endmodule
