`timescale 1ns / 1ps

// Independent simulation top: every binary input, held for 100 ns.
module minority_tb;
    reg a, b, c;
    wire y;
    reg expected;
    integer i;

    minority uut (.a(a), .b(b), .c(c), .y(y));

    initial begin
        for (i = 0; i < 8; i = i + 1) begin
            {a, b, c} = i;
            expected = ((i & 1) + ((i >> 1) & 1) + ((i >> 2) & 1)) <= 1;
            #1;
            if (y !== expected)
                $fatal(1, "FAIL minority: input=%0d expected=%b actual=%b", i, expected, y);
            #99;
        end
        $display("PASS: minority, all 8 input combinations verified.");
        $finish;
    end
endmodule
