`timescale 1ns / 1ps

module alu32_tb;
    reg [31:0] A, B;
    reg [2:0] F;
    wire [31:0] Y;
    wire C_out, Overflow, Zero;
    integer tests, errors, i, j, op, seed;
    reg [31:0] corners [0:11];
    reg [31:0] test_a, test_b;

    alu32 uut (.A(A), .B(B), .F(F), .Y(Y),
               .C_out(C_out), .Overflow(Overflow), .Zero(Zero));

    task check;
        input [31:0] a, b;
        input [2:0] f;
        input [31:0] expected_y;
        input expected_c, expected_overflow;
        begin
            A = a;
            B = b;
            F = f;
            #10;
            tests = tests + 1;
            if (Y !== expected_y || C_out !== expected_c ||
                Overflow !== expected_overflow || Zero !== (expected_y == 32'b0)) begin
                $display("FAIL: A=%h B=%h F=%b Y=%h C=%b OV=%b Z=%b; expected Y=%h C=%b OV=%b Z=%b",
                         A, B, F, Y, C_out, Overflow, Zero,
                         expected_y, expected_c, expected_overflow, (expected_y == 32'b0));
                errors = errors + 1;
            end
        end
    endtask

    // Unsigned model: widened addition; subtraction underflows when a < b.
    task check_model;
        input [31:0] a, b;
        input [2:0] f;
        reg [32:0] unsigned_sum;
        reg [31:0] expected_y;
        reg expected_overflow;
        begin
            if (f[2]) begin
                unsigned_sum = {1'b0, a} + {1'b0, ~b} + 33'd1;
            end else begin
                unsigned_sum = {1'b0, a} + {1'b0, b};
            end
            expected_overflow = f[2] ? (a < b) : (unsigned_sum > 33'h0ffffffff);
            case (f[1:0])
                2'b00: expected_y = f[2] ? (a & ~b) : (a & b);
                2'b01: expected_y = f[2] ? (a | ~b) : (a | b);
                2'b10: expected_y = unsigned_sum[31:0];
                // The schematic selects the top bit of the wrapped sum.
                2'b11: expected_y = {31'b0, unsigned_sum[31]};
            endcase
            check(a, b, f, expected_y, unsigned_sum[32], expected_overflow);
        end
    endtask

    initial begin
        tests = 0;
        errors = 0;
        seed = 125;
        A = 0;
        B = 0;
        F = 0;

        // Literal results, including unsigned carry and borrow.
        check(32'h00000005, 32'h00000003, 3'b000, 32'h00000001, 0, 0);
        check(32'h00000005, 32'h00000003, 3'b001, 32'h00000007, 0, 0);
        check(32'h00000003, 32'h00000004, 3'b010, 32'h00000007, 0, 0);
        check(32'h00000005, 32'h00000002, 3'b110, 32'h00000003, 1, 0);
        check(32'h00000002, 32'h00000005, 3'b110, 32'hfffffffd, 0, 1);
        check(32'h00000005, 32'h00000005, 3'b110, 32'h00000000, 1, 0);
        check(32'h7fffffff, 32'h00000001, 3'b010, 32'h80000000, 0, 0);
        check(32'h80000000, 32'h80000000, 3'b010, 32'h00000000, 1, 1);
        check(32'hffffffff, 32'h00000001, 3'b010, 32'h00000000, 1, 1);
        check(32'h80000000, 32'h00000001, 3'b110, 32'h7fffffff, 1, 0);
        check(32'h7fffffff, 32'hffffffff, 3'b110, 32'h80000000, 0, 1);
        check(32'h00000003, 32'h00000005, 3'b111, 32'h00000001, 0, 1);
        check(32'h00000005, 32'h00000003, 3'b111, 32'h00000000, 1, 0);
        // Mux input 3 is the raw S[31], independently of carry/borrow.
        check(32'h80000000, 32'h7fffffff, 3'b111, 32'h00000000, 1, 0);
        check(32'h7fffffff, 32'h80000000, 3'b111, 32'h00000001, 0, 1);
        check(32'h00000005, 32'h00000003, 3'b100, 32'h00000004, 1, 0);
        check(32'h00000005, 32'h00000003, 3'b101, 32'hfffffffd, 1, 0);
        check(32'h80000000, 32'h00000000, 3'b011, 32'h00000001, 0, 0);
        check(32'h7fffffff, 32'h00000001, 3'b011, 32'h00000001, 0, 0);
        check(32'h80000000, 32'h80000000, 3'b011, 32'h00000000, 1, 1);

        corners[0] = 32'h00000000;
        corners[1] = 32'h00000001;
        corners[2] = 32'hffffffff;
        corners[3] = 32'h7fffffff;
        corners[4] = 32'h80000000;
        corners[5] = 32'h80000001;
        corners[6] = 32'h0000000f;
        corners[7] = 32'h000000ff;
        corners[8] = 32'h0000ffff;
        corners[9] = 32'h0fffffff;
        corners[10] = 32'haaaaaaaa;
        corners[11] = 32'h55555555;

        // Every control code with each pair of boundary values.
        for (i = 0; i < 12; i = i + 1)
            for (j = 0; j < 12; j = j + 1)
                for (op = 0; op < 8; op = op + 1)
                    check_model(corners[i], corners[j], op[2:0]);

        // Carry/borrow through every bit and every four-bit CLA boundary.
        for (i = 0; i < 32; i = i + 1) begin
            test_a = (32'h00000001 << i) - 1;
            check_model(test_a, 32'h00000001, 3'b010);
            test_a = 32'h00000001 << i;
            check_model(test_a, 32'h00000001, 3'b110);
        end

        // Repeatable random operands with all eight control codes.
        for (i = 0; i < 2048; i = i + 1) begin
            test_a = $random(seed);
            test_b = $random(seed);
            for (op = 0; op < 8; op = op + 1)
                check_model(test_a, test_b, op[2:0]);
        end

        if (errors == 0)
            $display("PASS: alu32 all %0d tests passed.", tests);
        else
            $display("FAIL: alu32 %0d errors in %0d tests.", errors, tests);
        $finish;
    end
endmodule
