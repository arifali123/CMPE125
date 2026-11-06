`timescale 1ns / 1ps

module basys_alu (
    input [10:0] sw,
    output [10:0] led
);
    wire [3:0] Y;
    wire C_out, Overflow, Zero;

    alu4 uut (.A(sw[3:0]), .B(sw[7:4]), .F(sw[10:8]),
              .Y(Y), .C_out(C_out), .Overflow(Overflow), .Zero(Zero));

    assign led[3:0] = Y;
    assign led[7:4] = 4'b0000;
    assign led[8] = Zero;
    assign led[9] = Overflow;
    assign led[10] = C_out;
endmodule
