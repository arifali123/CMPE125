`timescale 1ns / 1ps

// All four states, held for 50 ns each (matching the handout's waveform).
module light_tb;
    reg x1;
    reg x2;
    wire f;

    light dut (
        .x1(x1),
        .x2(x2),
        .f(f)
    );

    task check_state;
        input a;
        input b;
        input expected;
        begin
            x1 = a;
            x2 = b;
            #1; // Allow combinational logic to settle before checking.
            if (f !== expected) begin
                $fatal(1, "FAIL: x1=%b x2=%b expected f=%b, got %b",
                       x1, x2, expected, f);
            end
            $display("PASS: x1=%b x2=%b f=%b", x1, x2, f);
            #49;
        end
    endtask

    initial begin
        check_state(0, 0, 0); //   0-50 ns
        check_state(1, 0, 1); //  50-100 ns
        check_state(0, 1, 1); // 100-150 ns
        check_state(1, 1, 0); // 150-200 ns
        $display("PASS: All four XOR states verified.");
        $finish;
    end
endmodule
