`timescale 1ns / 1ps

module vending_machine_board_tb;
    reg clk = 0, reset = 0, button = 0;
    reg Nickel = 0, Dime = 0, Quarter = 0;
    wire Dispense, ReturnNickel, ReturnDime, ReturnTwoDimes;
    wire [3:0] leds = {Dispense, ReturnNickel, ReturnDime, ReturnTwoDimes};
    integer credit_state, coin_index, total, change, next_state;
    reg [3:0] expected;

    vending_machine_board uut (
        .clk(clk), .reset(reset), .button(button),
        .Nickel(Nickel), .Dime(Dime), .Quarter(Quarter),
        .Dispense(Dispense), .ReturnNickel(ReturnNickel),
        .ReturnDime(ReturnDime), .ReturnTwoDimes(ReturnTwoDimes)
    );
    always #5 clk = ~clk;

    task check;
        input [2:0] state;
        input [3:0] result;
        begin
            if (uut.state !== state || leds !== result)
                $fatal(1, "state=%b LEDs=%b; expected state=%b LEDs=%b",
                       uut.state, leds, state, result);
        end
    endtask

    task clear_machine;
        begin
            @(negedge clk); reset = 1; button = 0;
            {Nickel, Dime, Quarter} = 0;
            #1; check(0, 0); // Asynchronous reset, before the next clock edge.
            @(negedge clk); reset = 0;
        end
    endtask

    task insert;
        input [2:0] coin;
        begin
            @(negedge clk); {Nickel, Dime, Quarter} = coin; button = 1;
            repeat (4) @(posedge clk); // Holding the button must count only once.
            @(negedge clk); {Nickel, Dime, Quarter} = 0; button = 0;
            @(posedge clk); #1; // Check the held result after button release.
        end
    endtask

    initial begin
        #1; check(0, 0);
        // The two transactions and input timing from the PDF's testbench.
        reset = 1;
        #11 reset = 0;
        #10 Nickel = 1; button = 1;
        #10 Nickel = 0; button = 0;
        #10 Quarter = 1; button = 1;
        #10 Quarter = 0; button = 0;
        check(0, 4'b1100);
        $display("Test 1 PASS: Soda and 5 cents change");

        #10 reset = 1;
        #10 reset = 0;
        #10 Dime = 1; button = 1;
        #10 Dime = 0; button = 0;
        #10 Dime = 1; button = 1;
        #10 Dime = 0; button = 0;
        #10 Nickel = 1; button = 1;
        #10 Nickel = 0; button = 0;
        check(0, 4'b1000);
        $display("Test 2 PASS: Soda and no change");

        // Independently check every credit/coin pair using cents arithmetic.
        for (credit_state = 0; credit_state < 5; credit_state = credit_state + 1) begin
            for (coin_index = 0; coin_index < 3; coin_index = coin_index + 1) begin
                clear_machine();
                repeat (credit_state) insert(3'b100);
                check(credit_state, 0);
                total = credit_state * 5;
                case (coin_index)
                    0: begin total = total + 5;  insert(3'b100); end
                    1: begin total = total + 10; insert(3'b010); end
                    2: begin total = total + 25; insert(3'b001); end
                endcase
                expected = 0;
                next_state = total / 5;
                if (total >= 25) begin
                    change = total - 25;
                    next_state = 0;
                    expected = {1'b1, (change % 10 == 5),
                                (change == 10 || change == 15), (change == 20)};
                end
                check(next_state, expected);
            end
        end
        clear_machine();
        @(negedge clk); Quarter = 1;
        repeat (4) @(posedge clk);
        #1; check(0, 0); // A switch alone does not insert a coin.
        insert(3'b000); check(0, 0);
        // Match the PDF's priority: nickel first, then dime, then quarter.
        insert(3'b111); check(1, 0);
        insert(3'b011); check(3, 0);
        insert(3'b001); check(0, 4'b1110);
        insert(3'b000); check(0, 0); // A new press clears the previous result.
        insert(3'b001); check(0, 4'b1000);
        clear_machine();

        $display("PASS: PDF board FSM: both PDF examples, all 15 coin transitions, held outputs/button, reset, switch isolation, and input priority.");
        $finish;
    end
    initial begin
        #100000;
        $fatal(1, "Board simulation timeout");
    end
endmodule
