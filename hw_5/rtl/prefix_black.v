`timescale 1ns / 1ps

// Combine the more-significant group i:k with the adjacent group k-1:j.
module prefix_black (
    input P_hi,
    input G_hi,
    input P_lo,
    input G_lo,
    output P_out,
    output G_out
);
    wire propagated_generate;
    and (P_out, P_hi, P_lo);
    and (propagated_generate, P_hi, G_lo);
    or  (G_out, G_hi, propagated_generate);
endmodule
