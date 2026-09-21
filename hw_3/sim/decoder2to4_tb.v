`timescale 1ns / 1ps

// Independent simulation top: every binary input, held for 100 ns.
module decoder2to4_tb;
    reg [1:0] a;
    wire [3:0] y;
    reg [3:0] expected;
    integer i;

    decoder2to4 uut (.a(a), .y(y));

    initial begin
        for (i = 0; i < 4; i = i + 1) begin
            a = i;
            case (i)
                0: expected = 4'b0001;
                1: expected = 4'b0010;
                2: expected = 4'b0100;
                3: expected = 4'b1000;
            endcase
            #1;
            if (y !== expected)
                $fatal(1, "FAIL decoder2to4: input=%0d expected=%b actual=%b", i, expected, y);
            #99;
        end
        $display("PASS: decoder2to4, all 4 input combinations verified.");
        $finish;
    end
endmodule
