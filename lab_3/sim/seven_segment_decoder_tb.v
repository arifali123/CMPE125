`timescale 1ns / 1ps
module seven_segment_decoder_tb;
    reg [3:0] SW;
    wire [6:0] HEX0;
    wire [3:0] AN;
    wire DP;
    reg [6:0] lit_segments [0:15];
    reg [6:0] expected;
    integer i;
    seven_segment_decoder dut (.SW(SW), .HEX0(HEX0), .AN(AN), .DP(DP));
    initial begin
        // Independent oracle: 1 means a segment is illuminated, g through a.
        lit_segments[0] = 7'b0111111; // 0: abcdef
        lit_segments[1] = 7'b0000110; // 1: bc
        lit_segments[2] = 7'b1011011; // 2: abdeg
        lit_segments[3] = 7'b1001111; // 3: abcdg
        lit_segments[4] = 7'b1100110; // 4: bcfg
        lit_segments[5] = 7'b1101101; // 5: acdfg
        lit_segments[6] = 7'b1111101; // 6: acdefg
        lit_segments[7] = 7'b0000111; // 7: abc
        lit_segments[8] = 7'b1111111; // 8: abcdefg
        lit_segments[9] = 7'b1101111; // 9: abcdfg
        lit_segments[10] = 7'b1110111; // A: abcefg
        lit_segments[11] = 7'b1111100; // B: cdefg
        lit_segments[12] = 7'b0111001; // C: adef
        lit_segments[13] = 7'b1011110; // D: bcdeg
        lit_segments[14] = 7'b1111001; // E: adefg
        lit_segments[15] = 7'b1110001; // F: aefg
        for (i = 0; i < 16; i = i + 1) begin
            SW = i[3:0];
            expected = ~lit_segments[i];
            #1;
            if (AN !== 4'b1110 || DP !== 1'b1)
                $fatal(1, "FAIL: digit enable or decimal point output");
            if (HEX0 !== expected)
                $fatal(1, "FAIL SW=%h expected=%h HEX0=%h",
                       SW, expected, HEX0);
            $display("PASS SW=%h HEX0=%h", SW, expected);
            #99;
        end
        $display("PASS: All 16 states match the truth table.");
        $finish;
    end
endmodule
