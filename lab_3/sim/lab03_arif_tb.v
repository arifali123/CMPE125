`timescale 1ns / 1ps
module lab03_arif_tb;
    reg [3:0] SW;
    wire [6:0] gate_hex, direct_hex;
    reg [6:0] lit_segments [0:15];
    reg [6:0] expected;
    integer i;
    lab03_arif gate_dut (.SW(SW), .HEX0(gate_hex));
    lab03_arif_direct direct_dut (.SW(SW), .HEX0(direct_hex));
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
            if (gate_hex !== expected || direct_hex !== expected)
                $fatal(1, "FAIL SW=%h expected=%h gate=%h direct=%h",
                       SW, expected, gate_hex, direct_hex);
            $display("PASS SW=%h HEX0=%h (gate and direct)", SW, expected);
            #99;
        end
        $display("PASS: All 16 states match the truth table in both implementations.");
        $finish;
    end
endmodule
