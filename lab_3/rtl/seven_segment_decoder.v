`timescale 1ns / 1ps

// Active-low output order: HEX0[6:0] = {g,f,e,d,c,b,a}.
module seven_segment_decoder (
    input [3:0] SW,
    output [6:0] HEX0,
    output [3:0] AN,
    output DP
);
    // Basys 3: enable only the rightmost digit and turn off its decimal point.
    assign AN = 4'b1110;
    assign DP = 1'b1;

    wire nD3, nD2, nD1, nD0;
    not inv_D0(nD0, SW[0]);
    not inv_D1(nD1, SW[1]);
    not inv_D2(nD2, SW[2]);
    not inv_D3(nD3, SW[3]);

    // Sa: sum of products for the segment OFF states.
    wire a0, a1, a2, a3;
    and a_term0(a0, nD3, nD2, nD1, SW[0]);
    and a_term1(a1, nD3, SW[2], nD1, nD0);
    and a_term2(a2, SW[3], nD2, SW[1], SW[0]);
    and a_term3(a3, SW[3], SW[2], nD1, SW[0]);
    or a_output(HEX0[0], a0, a1, a2, a3);

    // Sb: sum of products for the segment OFF states.
    wire b0, b1, b2, b3;
    and b_term0(b0, nD3, SW[2], nD1, SW[0]);
    and b_term1(b1, SW[3], SW[2], nD0);
    and b_term2(b2, SW[3], SW[1], SW[0]);
    and b_term3(b3, SW[2], SW[1], nD0);
    or b_output(HEX0[1], b0, b1, b2, b3);

    // Sc: sum of products for the segment OFF states.
    wire c0, c1, c2;
    and c_term0(c0, nD3, nD2, SW[1], nD0);
    and c_term1(c1, SW[3], SW[2], SW[1]);
    and c_term2(c2, SW[3], SW[2], nD0);
    or c_output(HEX0[2], c0, c1, c2);

    // Sd: sum of products for the segment OFF states.
    wire d0, d1, d2, d3;
    and d_term0(d0, nD3, nD2, nD1, SW[0]);
    and d_term1(d1, nD3, SW[2], nD1, nD0);
    and d_term2(d2, SW[3], nD2, SW[1], nD0);
    and d_term3(d3, SW[2], SW[1], SW[0]);
    or d_output(HEX0[3], d0, d1, d2, d3);

    // Se: sum of products for the segment OFF states.
    wire e0, e1, e2;
    and e_term0(e0, nD3, SW[2], nD1);
    and e_term1(e1, nD3, SW[0]);
    and e_term2(e2, nD2, nD1, SW[0]);
    or e_output(HEX0[4], e0, e1, e2);

    // Sf: sum of products for the segment OFF states.
    wire f0, f1, f2, f3;
    and f_term0(f0, SW[3], SW[2], nD1, SW[0]);
    and f_term1(f1, nD3, nD2, SW[1]);
    and f_term2(f2, nD3, nD2, SW[0]);
    and f_term3(f3, nD3, SW[1], SW[0]);
    or f_output(HEX0[5], f0, f1, f2, f3);

    // Sg: sum of products for the segment OFF states.
    wire g0, g1, g2;
    and g_term0(g0, nD3, SW[2], SW[1], SW[0]);
    and g_term1(g1, SW[3], SW[2], nD1, nD0);
    and g_term2(g2, nD3, nD2, nD1);
    or g_output(HEX0[6], g0, g1, g2);
endmodule
