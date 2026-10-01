`timescale 1ns / 1ps

module CLA4_tb;
    reg [3:0] A, B;
    reg Ci;
    wire [3:0] S;
    wire Co, PG, GG;
    integer i, errors;

    CLA4 uut (.A(A), .B(B), .Ci(Ci), .S(S), .Co(Co), .PG(PG), .GG(GG));

    // Apply one case and compare against hand-computed expected values.
    task check(input [3:0] a, input [3:0] b, input ci,
               input [4:0] exp_sum, input exp_pg, input exp_gg);
        begin
            A = a; B = b; Ci = ci;
            #10;
            if ({Co, S} !== exp_sum || PG !== exp_pg || GG !== exp_gg) begin
                $display("FAIL: %0d + %0d + %0d -> Co,S=%b PG=%b GG=%b, expected %b PG=%b GG=%b",
                         a, b, ci, {Co, S}, PG, GG, exp_sum, exp_pg, exp_gg);
                errors = errors + 1;
            end else
                $display("PASS: %0d + %0d + %0d = %0d (Co=%b S=%b PG=%b GG=%b)",
                         a, b, ci, {Co, S}, Co, S, PG, GG);
        end
    endtask

    reg [4:0] ref_sum;
    reg [3:0] ref_p, ref_g;
    reg ref_gg;

    initial begin
        errors = 0;

        // Two required additions (hand-worked, independent of the design).
        // 11 + 6: reference guide example -> 10001, PG=0, GG=1.
        check(4'd11, 4'd6,  1'b0, 5'b10001, 1'b0, 1'b1);
        // 9 + 5 + 1 = 15: A=1001 B=0101 -> P=1100 (PG=0), G=0001 (GG=0), no carry out.
        check(4'd9,  4'd5,  1'b1, 5'b01111, 1'b0, 1'b0);

        // Extra directed corner cases.
        check(4'd0,  4'd0,  1'b0, 5'b00000, 1'b0, 1'b0);
        check(4'd15, 4'd15, 1'b1, 5'b11111, 1'b0, 1'b1);
        // A=1010 B=0101: P=1111 so PG=1, G=0000, GG=0; Ci=1 ripples to Co.
        check(4'd10, 4'd5,  1'b1, 5'b10000, 1'b1, 1'b0);

        // Exhaustive sweep of all 512 inputs against a behavioural reference.
        for (i = 0; i < 512; i = i + 1) begin
            {Ci, B, A} = i[8:0];
            #10;
            ref_sum = A + B + Ci;
            ref_p = A ^ B;
            ref_g = A & B;
            // Group generate = carry out when Ci = 0.
            ref_gg = ({1'b0, A} + {1'b0, B}) >> 4;
            if ({Co, S} !== ref_sum || PG !== (&ref_p) || GG !== ref_gg) begin
                $display("FAIL: A=%b B=%b Ci=%b -> Co,S=%b PG=%b GG=%b", A, B, Ci, {Co, S}, PG, GG);
                errors = errors + 1;
            end
        end

        if (errors == 0) $display("PASS: all directed and 512 exhaustive cases verified.");
        else $display("FAIL: %0d errors", errors);
        $finish;
    end
endmodule
