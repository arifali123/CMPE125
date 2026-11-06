`timescale 1ns / 1ps

module basys_alu_tb;
    reg [10:0] sw;
    wire [10:0] led;
    reg [3:0] expected_y;
    reg expected_c, expected_overflow, expected_zero;
    reg [10:0] expected_led;
    integer a, b, f, signed_a, signed_b, result, sum;
    integer errors, tests;

    basys_alu uut (.sw(sw), .led(led));

    // Literal examples for the TA: mux input 3 uses S[3], not S[3] XOR OV.
    task check_example;
        input [3:0] test_a, test_b;
        input [2:0] test_f;
        input [3:0] test_y;
        input test_c, test_overflow;
        reg [10:0] test_led;
        begin
            sw = {test_f, test_b, test_a};
            test_led = {test_c, test_overflow, (test_y == 4'b0), 4'b0, test_y};
            #10;
            tests = tests + 1;
            if (led !== test_led) begin
                $display("FAIL: example A=%h B=%h F=%b LED=%b expected=%b",
                         test_a, test_b, test_f, led, test_led);
                errors = errors + 1;
            end else
                $display("PASS: example A=%h B=%h F=%b Y=%h C=%b OV=%b Z=%b",
                         test_a, test_b, test_f, led[3:0], led[10], led[9], led[8]);
        end
    endtask

    initial begin
        sw = 0;
        errors = 0;
        tests = 0;

        check_example(4'h3, 4'h5, 3'b111, 4'h1, 0, 0); // S = E: sign 1
        check_example(4'h5, 4'h3, 3'b111, 4'h0, 1, 0); // S = 2: sign 0
        check_example(4'h7, 4'h8, 3'b111, 4'h1, 0, 1); // S = F: sign 1
        check_example(4'h8, 4'h7, 3'b111, 4'h0, 1, 1); // S = 1: sign 0
        check_example(4'h7, 4'h1, 3'b011, 4'h1, 0, 1); // S = 8: sign 1
        check_example(4'h8, 4'h8, 3'b011, 4'h0, 1, 1); // S = 0: sign 0
        check_example(4'h5, 4'h2, 3'b110, 4'h3, 1, 0); // Subtraction unchanged
        check_example(4'h7, 4'h1, 3'b010, 4'h8, 0, 1); // Addition unchanged

        // Exhaustive check of the actual board top, including all LED wiring.
        for (f = 0; f < 8; f = f + 1) begin
            for (a = 0; a < 16; a = a + 1) begin
                for (b = 0; b < 16; b = b + 1) begin
                    sw = {f[2:0], b[3:0], a[3:0]};
                    signed_a = (a >= 8) ? a - 16 : a;
                    signed_b = (b >= 8) ? b - 16 : b;
                    if (f[2]) begin
                        result = signed_a - signed_b;
                        sum = a + (15 - b) + 1;
                    end else begin
                        result = signed_a + signed_b;
                        sum = a + b;
                    end
                    expected_c = (sum >= 16);
                    expected_overflow = (result > 7) || (result < -8);
                    case (f[1:0])
                        2'b00: expected_y = f[2] ? (a & ~b) : (a & b);
                        2'b01: expected_y = f[2] ? (a | ~b) : (a | b);
                        2'b10: expected_y = result[3:0];
                        // Zero-extend bit 3 of the four-bit result, as drawn.
                        2'b11: expected_y = {3'b000, result[3]};
                    endcase
                    expected_zero = (expected_y == 0);
                    expected_led = {expected_c, expected_overflow, expected_zero,
                                    4'b0000, expected_y};
                    #10;
                    tests = tests + 1;
                    if (led !== expected_led) begin
                        $display("FAIL: A=%h B=%h F=%b LED=%b expected=%b",
                                 a[3:0], b[3:0], f[2:0], led, expected_led);
                        errors = errors + 1;
                    end
                end
            end
        end

        if (errors == 0)
            $display("PASS: basys_alu all %0d tests passed.", tests);
        else
            $display("FAIL: basys_alu %0d errors in %0d tests.", errors, tests);
        $finish;
    end
endmodule
