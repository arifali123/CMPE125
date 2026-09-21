`timescale 1ns / 1ps

// Independent simulation top: every binary input, held for 100 ns.
module xor4_tb;
    reg [3:0] a;
    wire y;
    reg expected;
    integer i;

    xor4 uut (.a(a), .y(y));

    initial begin
        for (i = 0; i < 16; i = i + 1) begin
            a = i;
            expected = ((i & 1) + ((i >> 1) & 1) + ((i >> 2) & 1) + ((i >> 3) & 1)) % 2;
            #1;
            if (y !== expected)
                $fatal(1, "FAIL xor4: input=%0d expected=%b actual=%b", i, expected, y);
            #99;
        end
        $display("PASS: xor4, all 16 input combinations verified.");
        $finish;
    end
endmodule
