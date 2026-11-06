`timescale 1ns / 1ps

module basys_alu_tb;
    reg [10:0] sw;
    wire [10:0] led;
    reg [3:0] expected_y;
    reg expected_c, expected_overflow, expected_zero;
    reg [10:0] expected_led;
    integer a, b, f, sum;
    integer errors, tests;

    basys_alu uut (.sw(sw), .led(led));

    // Literal unsigned SLT for both F[2] values, plus arithmetic examples.
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

        check_example(4'h3, 4'h5, 3'b111, 4'h1, 0, 1); // 3 < 5: true
        check_example(4'h5, 4'h3, 3'b111, 4'h0, 1, 0); // 5 < 3: false
        check_example(4'h7, 4'h8, 3'b111, 4'h1, 0, 1); // 7 < 8: true
        check_example(4'h8, 4'h7, 3'b111, 4'h0, 1, 0); // 8 < 7: false
        check_example(4'h7, 4'h1, 3'b011, 4'h0, 0, 0); // 7 < 1: false
        check_example(4'h8, 4'h8, 3'b011, 4'h0, 1, 1); // Equal operands: false
        check_example(4'h3, 4'h5, 3'b011, 4'h1, 0, 0); // 3 < 5: true
        check_example(4'h5, 4'h3, 3'b011, 4'h0, 0, 0); // 5 < 3: false
        check_example(4'h0, 4'hf, 3'b011, 4'h1, 0, 0); // 0 < 15: true
        check_example(4'hf, 4'h0, 3'b011, 4'h0, 0, 0); // 15 < 0: false
        check_example(4'h5, 4'h2, 3'b110, 4'h3, 1, 0); // Subtraction unchanged
        check_example(4'h7, 4'h1, 3'b010, 4'h8, 0, 0); // Addition unchanged

        check_example(4'hf, 4'h1, 3'b010, 4'h0, 1, 1); // 15 + 1 wraps to 0
        check_example(4'h2, 4'h5, 3'b110, 4'hd, 0, 1); // 2 - 5 wraps to 13
        check_example(4'h0, 4'hf, 3'b111, 4'h1, 0, 1); // 0 < 15, despite S[3]=0
        check_example(4'hf, 4'h0, 3'b111, 4'h0, 1, 0); // 15 is not < 0, despite S[3]=1
        check_example(4'h5, 4'h5, 3'b111, 4'h0, 1, 0); // Equal operands: false

        // Exhaustive check of the actual board top, including all LED wiring.
        for (f = 0; f < 8; f = f + 1) begin
            for (a = 0; a < 16; a = a + 1) begin
                for (b = 0; b < 16; b = b + 1) begin
                    sw = {f[2:0], b[3:0], a[3:0]};
                    if (f[2]) begin
                        sum = a + (15 - b) + 1;
                    end else begin
                        sum = a + b;
                    end
                    expected_c = (sum >= 16);
                    expected_overflow = f[2] ? (a < b) : (sum > 15);
                    case (f[1:0])
                        2'b00: expected_y = f[2] ? (a & ~b) : (a & b);
                        2'b01: expected_y = f[2] ? (a | ~b) : (a | b);
                        2'b10: expected_y = sum[3:0];
                        // Both F=011 and F=111 compare the original operands.
                        2'b11: expected_y = (a < b) ? 4'd1 : 4'd0;
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
