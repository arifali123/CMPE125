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

    initial begin
        sw = 0;
        errors = 0;
        tests = 0;

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
                        2'b11: expected_y = (result < 0) ? 4'd1 : 4'd0;
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
