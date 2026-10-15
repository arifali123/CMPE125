`timescale 1ns / 1ps

// Type 2 testbench: expected results are stored in this Verilog source.
module self_check_tb;
    reg [3:0] A;
    reg [3:0] B;
    reg Ci;
    wire [3:0] S;
    wire Co;
    wire PG;
    wire GG;
    integer errors;

    CLA4 dut (
        .A(A), .B(B), .Ci(Ci), .S(S),
        .Co(Co), .PG(PG), .GG(GG)
    );

    initial begin
        errors = 0;

        // Case 1: 11 + 6 + 0 = 17.
        A = 4'b1011; B = 4'b0110; Ci = 1'b0; #10;
        if ({Co, S} !== 5'b10001) begin
            $display("ERROR: 1011 + 0110 + 0 = %b; expected 10001", {Co, S});
            errors = errors + 1;
        end

        // Case 2: 9 + 5 + 1 = 15.
        A = 4'b1001; B = 4'b0101; Ci = 1'b1; #10;
        if ({Co, S} !== 5'b01111) begin
            $display("ERROR: 1001 + 0101 + 1 = %b; expected 01111", {Co, S});
            errors = errors + 1;
        end

        // Case 3: 0 + 0 + 0 = 0.
        A = 4'b0000; B = 4'b0000; Ci = 1'b0; #10;
        if ({Co, S} !== 5'b00000) begin
            $display("ERROR: 0000 + 0000 + 0 = %b; expected 00000", {Co, S});
            errors = errors + 1;
        end

        // Case 4: 10 + 5 + 1 = 16 (carry-in propagates through all bits).
        A = 4'b1010; B = 4'b0101; Ci = 1'b1; #10;
        if ({Co, S} !== 5'b10000) begin
            $display("ERROR: 1010 + 0101 + 1 = %b; expected 10000", {Co, S});
            errors = errors + 1;
        end

        if (errors == 0)
            $display("PASS: 4 self-checking additions completed with 0 errors.");
        else
            $display("FAIL: 4 self-checking additions completed with %0d errors.", errors);

        $finish;
    end
endmodule
