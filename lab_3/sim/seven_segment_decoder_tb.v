`timescale 1ns / 1ps

module seven_segment_decoder_tb;

reg [3:0] SW;
wire [6:0] HEX0;
wire [3:0] AN;
reg [6:0] expected [0:15];

seven_segment_decoder uut (
    .SW(SW),
    .HEX0(HEX0),
    .AN(AN)
);

integer i;

initial begin
    expected[0] = 7'h40; // 0
    expected[1] = 7'h79; // 1
    expected[2] = 7'h24; // 2
    expected[3] = 7'h30; // 3
    expected[4] = 7'h19; // 4
    expected[5] = 7'h12; // 5
    expected[6] = 7'h02; // 6
    expected[7] = 7'h78; // 7
    expected[8] = 7'h00; // 8
    expected[9] = 7'h10; // 9
    expected[10] = 7'h08; // A
    expected[11] = 7'h03; // B
    expected[12] = 7'h46; // C
    expected[13] = 7'h21; // D
    expected[14] = 7'h06; // E
    expected[15] = 7'h0E; // F
    SW = 4'b0000;

    for (i = 0; i < 16; i = i + 1) begin
        SW = i;
        #1;
        if (HEX0 !== expected[i] || AN !== 4'b1110)
            $fatal(1, "FAIL SW=%h expected=%h HEX0=%h AN=%b",
                   SW, expected[i], HEX0, AN);
        $display("PASS SW=%h HEX0=%h", SW, HEX0);
        #99;
    end

    $display("PASS: All 16 digits and digit enables verified.");
    $stop;
end

endmodule
