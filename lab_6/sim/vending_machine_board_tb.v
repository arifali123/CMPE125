`timescale 1ns / 1ps

module vending_machine_board_tb;
    localparam integer DEBOUNCE_CYCLES = 8;
    localparam integer SETTLE = DEBOUNCE_CYCLES + 6;
    reg clk = 0, reset = 0, button = 0;
    reg Nickel = 0, Dime = 0, Quarter = 0;
    wire Dispense, ReturnNickel, ReturnDime, ReturnTwoDimes;
    wire [3:0] leds = {Dispense, ReturnNickel, ReturnDime, ReturnTwoDimes};
    integer accepted_presses = 0;
    integer before_bounce;

    // Shorten only the debounce interval; use the real board logic.
    vending_machine_board #(.DEBOUNCE_CYCLES(DEBOUNCE_CYCLES)) uut (
        .clk(clk), .reset(reset), .button(button),
        .Nickel(Nickel), .Dime(Dime), .Quarter(Quarter),
        .Dispense(Dispense), .ReturnNickel(ReturnNickel),
        .ReturnDime(ReturnDime), .ReturnTwoDimes(ReturnTwoDimes)
    );
    always #5 clk = ~clk;
    always @(posedge clk)
        if (!uut.board_reset && uut.insert_coin)
            accepted_presses = accepted_presses + 1;

    task tick;
        input integer cycles;
        begin
            repeat (cycles) begin @(posedge clk); #1; end
        end
    endtask

    task expect_result;
        input [2:0] state;
        input [3:0] result;
        begin
            if (uut.controller.state !== state || leds !== result)
                $fatal(1, "Board mismatch: state=%b LEDs=%b; expected state=%b LEDs=%b",
                       uut.controller.state, leds, state, result);
        end
    endtask

    task select_coin;
        input [2:0] coin;
        begin
            @(negedge clk); #1;
            {Nickel, Dime, Quarter} = coin;
            tick(4);
        end
    endtask

    task drive_button;
        input level;
        begin @(negedge clk); #1; button = level; end
    endtask

    task insert;
        input [2:0] coin;
        input [2:0] state;
        input [3:0] result;
        integer before_press;
        begin
            select_coin(coin);
            before_press = accepted_presses;
            drive_button(1);
            tick(SETTLE);
            expect_result(state, result);
            if (accepted_presses != before_press + 1)
                $fatal(1, "A press must accept exactly one coin");
            tick(3 * SETTLE);
            expect_result(state, result);
            if (accepted_presses != before_press + 1)
                $fatal(1, "Held button accepted additional coins");
            drive_button(0);
            tick(SETTLE);
            expect_result(state, result);
            if (accepted_presses != before_press + 1)
                $fatal(1, "Button release accepted a coin");
        end
    endtask

    task clear_machine;
        begin
            @(negedge clk); #1;
            reset = 1;
            button = 0;
            {Nickel, Dime, Quarter} = 0;
            #1;
            // Check BEFORE a rising edge: reset must immediately clear LEDs/credit.
            expect_result(0, 0);
            tick(3);
            @(negedge clk); #1; reset = 0;
            tick(SETTLE);
            expect_result(0, 0);
        end
    endtask

    initial begin
        // Configuration initializes the reset synchronizer; no manual reset needed.
        tick(SETTLE);
        expect_result(0, 0);
        select_coin(3'b100);
        tick(3 * SETTLE);
        expect_result(0, 0); // A coin switch alone must not insert a coin.

        before_bounce = accepted_presses;
        repeat (3) begin
            drive_button(1); tick(2);
            drive_button(0); tick(2);
        end
        tick(SETTLE);
        expect_result(0, 0);
        if (accepted_presses != before_bounce) $fatal(1, "Press bounce inserted a coin");

        drive_button(1); tick(SETTLE);
        expect_result(1, 0); // One nickel.
        select_coin(3'b001); // Changing switches while held must not insert a quarter.
        tick(3 * SETTLE);
        expect_result(1, 0);
        repeat (3) begin
            drive_button(0); tick(2);
            drive_button(1); tick(2);
        end
        tick(SETTLE);
        expect_result(1, 0);
        if (accepted_presses != before_bounce + 1) $fatal(1, "Held/release bounce inserted a coin");
        drive_button(0); tick(SETTLE);

        insert(3'b001, 0, 4'b1100); // N + Q: 5 cents change.
        select_coin(3'b010);
        tick(3 * SETTLE);
        expect_result(0, 4'b1100); // Result persists after release and switch changes.
        insert(3'b010, 2, 4'b0000); // Next insertion clears the old LEDs.
        insert(3'b001, 0, 4'b1010); // D + Q: 10 cents change.
        insert(3'b100, 1, 4'b0000);
        insert(3'b010, 3, 4'b0000);
        insert(3'b001, 0, 4'b1110); // N + D + Q: 15 cents change.
        insert(3'b010, 2, 4'b0000);
        insert(3'b010, 4, 4'b0000);
        insert(3'b001, 0, 4'b1001); // D + D + Q: 20 cents change.
        insert(3'b001, 0, 4'b1000); // Exact price.
        insert(3'b000, 0, 4'b0000); // No coin: clear LEDs, keep credit.
        insert(3'b100, 1, 4'b0000);
        insert(3'b110, 1, 4'b0000); // Multiple coin switches: ignored.
        clear_machine(); // Reset accumulated credit.
        insert(3'b001, 0, 4'b1000);
        clear_machine(); // Reset a displayed result.

        // Reset during a partially debounced press cancels that pending insertion.
        select_coin(3'b001);
        drive_button(1); tick(3);
        clear_machine();
        if (leds !== 0 || uut.controller.state !== 0) $fatal(1, "Reset left a pending coin");
        insert(3'b010, 2, 4'b0000);
        insert(3'b010, 4, 4'b0000);
        insert(3'b100, 0, 4'b1000); // D + D + N: exact price, repeated switch selection.

        $display("PASS: board startup/reset, switch isolation, press/release bounce, held button, all change LEDs, invalid coins, and repeated purchases.");
        $finish;
    end
    initial begin
        #100000;
        $fatal(1, "Board simulation timeout");
    end
endmodule
