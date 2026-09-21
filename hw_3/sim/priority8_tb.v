`timescale 1ns / 1ps

// Independent simulation top: every binary input, held for 100 ns.
module priority8_tb;
    reg [7:0] a;
    wire [7:0] y;
    reg [7:0] expected;
    integer bit_index;
    integer i;

    priority8 uut (.a(a), .y(y));

    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            a = i;
            expected = 0;
            for (bit_index = 0; bit_index < 8; bit_index = bit_index + 1)
                if ((i >> bit_index) & 1) expected = 2 ** bit_index;
            #1;
            if (y !== expected)
                $fatal(1, "FAIL priority8: input=%0d expected=%b actual=%b", i, expected, y);
            #99;
        end
        $display("PASS: priority8, all 256 input combinations verified.");
        $finish;
    end
endmodule
