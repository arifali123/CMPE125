`timescale 1ns / 1ps

// Question 2: structural implementation of the supplied 16-bit prefix tree.
// {Cout, S} = A + B + Cin. No clock or reset is needed.
module prefix16 (
    input [15:0] A,
    input [15:0] B,
    input Cin,
    output [15:0] S,
    output Cout
);
    wire [15:0] bit_p, bit_g;
    wire [15:0] p [0:4];
    wire [15:0] g [0:4];
    wire [15:0] carry;
    wire carry_through_msb;

    genvar bit_index, stage, column;
    generate
        for (bit_index = 0; bit_index < 16; bit_index = bit_index + 1) begin : inputs_and_sums
            // The figure uses OR propagate, but XOR for the final sum.
            or  (bit_p[bit_index], A[bit_index], B[bit_index]);
            and (bit_g[bit_index], A[bit_index], B[bit_index]);
            xor (S[bit_index], A[bit_index], B[bit_index], carry[bit_index]);
        end
    endgenerate

    // Array column n represents the figure's column n-1. Thus column 0
    // is the virtual bit -1; columns 1..15 are operand bits 0..14.
    // Setting P(-1)=0 and G(-1)=Cin incorporates carry-in into the tree.
    assign p[0] = {bit_p[14:0], 1'b0};
    assign g[0] = {bit_g[14:0], Cin};

    generate
        for (stage = 0; stage < 4; stage = stage + 1) begin : prefix_stage
            for (column = 0; column < 16; column = column + 1) begin : node
                // In each group of 2*DIST columns, the upper half joins
                // the last prefix of the lower half. Eight cells per row.
                if ((column % (2 << stage)) >= (1 << stage)) begin : combine
                    localparam integer LOWER = (column / (2 << stage)) *
                                                (2 << stage) + (1 << stage) - 1;
                    prefix_black black (
                        .P_hi(p[stage][column]), .G_hi(g[stage][column]),
                        .P_lo(p[stage][LOWER]), .G_lo(g[stage][LOWER]),
                        .P_out(p[stage+1][column]), .G_out(g[stage+1][column])
                    );
                end else begin : pass_through
                    assign p[stage+1][column] = p[stage][column];
                    assign g[stage+1][column] = g[stage][column];
                end
            end
        end
    endgenerate

    // g[4][i] = G(i-1:-1), the carry INTO sum bit i, not out of it.
    assign carry = g[4];

    // Bit 15 bypasses the pictured carry tree. Expose its carry-out too.
    and (carry_through_msb, bit_p[15], carry[15]);
    or  (Cout, bit_g[15], carry_through_msb);
endmodule
