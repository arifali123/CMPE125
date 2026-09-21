`timescale 1ns / 1ps

// Problem 3: one-hot priority circuit; a[7] has highest priority.
// No asserted inputs produces y = 0.
module priority8 (
    input [7:0] a,
    output reg [7:0] y
);
    always @* begin
        y = 8'b00000000;
        if      (a[7]) y = 8'b10000000;
        else if (a[6]) y = 8'b01000000;
        else if (a[5]) y = 8'b00100000;
        else if (a[4]) y = 8'b00010000;
        else if (a[3]) y = 8'b00001000;
        else if (a[2]) y = 8'b00000100;
        else if (a[1]) y = 8'b00000010;
        else if (a[0]) y = 8'b00000001;
    end
endmodule
