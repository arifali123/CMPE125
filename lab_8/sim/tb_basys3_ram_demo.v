`timescale 1ns/1ps
// Shared simulation top. Enable one testbench file at a time.
module lab8_tb;
    localparam integer DEBOUNCE_CYCLES = 4;
    localparam [3:0] CENTER = 4'b0001, UP = 4'b0010,
                     LEFT = 4'b0100, DOWN = 4'b1000;
    reg clk = 0;
    reg [15:0] sw = 0;
    reg [3:0] buttons = 0;
    wire [15:0] led;
    integer writes = 0;

    always #5 clk = ~clk;
    basys3_ram_demo #(.DEBOUNCE_CYCLES(DEBOUNCE_CYCLES)) dut (
        .clk(clk), .sw(sw), .btnC(buttons[0]), .btnU(buttons[1]),
        .btnL(buttons[2]), .btnD(buttons[3]), .led(led)
    );

    always @(posedge clk) begin
        if (dut.write_request) begin
            case ({dut.write_single, dut.write_two_a, dut.write_two_b,
                   dut.write_true_a, dut.write_true_b})
                5'b10000, 5'b01000, 5'b00100, 5'b00010, 5'b00001:
                    writes = writes + 1;
                default: $fatal(1, "Exactly one RAM port must write.");
            endcase
        end
    end

    // Drive away from the sampling edge and wait for the switch synchronizer.
    task set_switches;
        input enable;
        input [7:0] data;
        input [6:0] address;
        begin
            @(negedge clk);
            sw = {enable, data, address};
            repeat (4) @(negedge clk);
        end
    endtask

    // Closely spaced transitions at both ends of one long press.
    task press;
        input [3:0] mask;
        begin
            buttons = mask;
            @(negedge clk); buttons = 0;
            @(negedge clk); buttons = mask;
            repeat (3 * DEBOUNCE_CYCLES) @(negedge clk);
            buttons = 0;
            @(negedge clk); buttons = mask;
            @(negedge clk); buttons = 0;
            repeat (DEBOUNCE_CYCLES + 4) @(negedge clk);
        end
    endtask

    task check_controls;
        input [1:0] mode;
        input port_b;
        begin
            if (led[15:8] !== {sw[15], 4'b0, port_b, mode})
                $fatal(1, "Unexpected controls LED[15:8]=%h for WE=%b, mode=%d, port B=%b.",
                       led[15:8], sw[15], mode, port_b);
        end
    endtask

    task check_value;
        input [7:0] value;
        input integer expected_writes;
        begin
            if (led[7:0] !== value || writes != expected_writes)
                $fatal(1, "Data=%h (expected %h), writes=%d (expected %d).",
                       led[7:0], value, writes, expected_writes);
        end
    endtask

    initial begin
        set_switches(1, 8'h2A, 5);
        check_controls(0, 0);
        press(LEFT);
        check_controls(0, 0);
        // A short pulse is rejected and a bouncing press writes once.
        buttons = CENTER;
        @(negedge clk); buttons = 0;
        repeat (DEBOUNCE_CYCLES + 4) @(negedge clk);
        if (writes != 0)
            $fatal(1, "Center glitch caused a write.");
        press(CENTER);
        check_value(8'h2A, 1);
        set_switches(0, 8'hFF, 5);
        press(CENTER);
        check_controls(0, 0);
        check_value(8'h2A, 1);

        // Write A, then read and overwrite from B in the two-clock RAM.
        press(UP);
        check_controls(1, 0);
        set_switches(1, 8'h3C, 5);
        press(CENTER);
        check_value(8'h3C, 2);
        press(LEFT);
        check_controls(1, 1);
        check_value(8'h3C, 2);
        set_switches(1, 8'hD2, 5);
        press(CENTER);
        press(LEFT);
        check_controls(1, 0);
        check_value(8'hD2, 3);

        // Use two addresses and both ports of the shared-clock RAM.
        press(UP);
        check_controls(2, 0);
        set_switches(1, 8'h55, 5);
        press(CENTER);
        press(LEFT);
        check_controls(2, 1);
        check_value(8'h55, 4);
        set_switches(1, 8'hAA, 127);
        press(CENTER);
        press(LEFT);
        check_value(8'hAA, 5);
        set_switches(0, 8'h00, 5);
        check_value(8'h55, 5);

        press(LEFT);
        press(UP);
        check_controls(0, 0);
        check_value(8'h2A, 5);
        press(UP);
        check_value(8'hD2, 5);
        press(LEFT);
        press(DOWN);
        check_controls(0, 0);
        check_value(8'h2A, 5);

        $display("ALL BASYS 3 DEMO TESTS PASSED");
        $finish;
    end
endmodule
