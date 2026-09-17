`timescale 1ns / 1ps

module seven_segment_decoder_tb;

reg [3:0] SW;
wire [6:0] HEX0;

seven_segment_decoder uut (
    .SW(SW),
    .HEX0(HEX0)
);

integer i;

initial begin
    SW = 4'b0000;

    for (i = 0; i < 16; i = i + 1) begin
        SW = i;
        #100;
    end

    $stop;
end

endmodule
