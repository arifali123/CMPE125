`timescale 1ns / 1ps

// Matrix-style testbench for the PDF vending machine.
//
// Phase 1 keeps the PDF's two reference transactions and their timing, so the
// opening waveform is unchanged. Phase 2 walks the transition matrix: every
// credit state (S0..S4) against every three-bit coin selection (000..111).
// The expected next state and LED result for a single coin are stored in one
// literal 5x3 matrix; a selection with several coins must resolve to the cell
// of the highest-priority coin (nickel, then dime, then quarter).
module vending_machine_tb;
    reg clk = 0, reset = 0, button = 0;
    reg Nickel = 0, Dime = 0, Quarter = 0;
    wire Dispense, ReturnNickel, ReturnDime, ReturnTwoDimes;
    wire [3:0] leds = {Dispense, ReturnNickel, ReturnDime, ReturnTwoDimes};

    // fsm_matrix[credit][coin] = {next_state, {Dispense, ReturnNickel,
    //                              ReturnDime, ReturnTwoDimes}}
    // Rows are S0..S4 (0, 5, 10, 15 and 20 cents of credit).
    // Columns are the single selected coin: N, D and Q.
    reg [6:0] fsm_matrix [0:4][0:2];

    integer row, col, code, checks, cells, combinations;
    reg [6:0] entry;
    reg [2:0] selection, want_state;
    reg [3:0] want_leds;

    vending_machine uut (
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
            checks = checks + 1;
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

    // Highest-priority selected coin: 0 nickel, 1 dime, 2 quarter, 3 none.
    function [1:0] coin_priority;
        input [2:0] selected;
        begin
            if (selected[2])      coin_priority = 2'd0;
            else if (selected[1]) coin_priority = 2'd1;
            else if (selected[0]) coin_priority = 2'd2;
            else                  coin_priority = 2'd3;
        end
    endfunction

    // The whole FSM as a literal matrix; see notes/report.md.
    task load_matrix;
        begin
            //                       next state, Dispense/ReturnNickel/ReturnDime/ReturnTwoDimes
            fsm_matrix[0][0] = {3'b001, 4'b0000}; // S0 + nickel
            fsm_matrix[0][1] = {3'b010, 4'b0000}; // S0 + dime
            fsm_matrix[0][2] = {3'b000, 4'b1000}; // S0 + quarter

            fsm_matrix[1][0] = {3'b010, 4'b0000}; // S1 + nickel
            fsm_matrix[1][1] = {3'b011, 4'b0000}; // S1 + dime
            fsm_matrix[1][2] = {3'b000, 4'b1100}; // S1 + quarter

            fsm_matrix[2][0] = {3'b011, 4'b0000}; // S2 + nickel
            fsm_matrix[2][1] = {3'b100, 4'b0000}; // S2 + dime
            fsm_matrix[2][2] = {3'b000, 4'b1010}; // S2 + quarter

            fsm_matrix[3][0] = {3'b100, 4'b0000}; // S3 + nickel
            fsm_matrix[3][1] = {3'b000, 4'b1000}; // S3 + dime
            fsm_matrix[3][2] = {3'b000, 4'b1110}; // S3 + quarter

            fsm_matrix[4][0] = {3'b000, 4'b1000}; // S4 + nickel
            fsm_matrix[4][1] = {3'b000, 4'b1100}; // S4 + dime
            fsm_matrix[4][2] = {3'b000, 4'b1001}; // S4 + quarter
        end
    endtask

    initial begin
        checks = 0; cells = 0; combinations = 0;
        load_matrix();

        #1; check(0, 0);
        // Phase 1: the two transactions and input timing from the PDF's testbench.
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

        // Phase 2: every cell of the 5x3 transition matrix.
        for (row = 0; row < 5; row = row + 1) begin
            for (col = 0; col < 3; col = col + 1) begin
                clear_machine();
                repeat (row) insert(3'b100); // Build this row's credit.
                check(row, 4'b0000);
                case (col)
                    0: insert(3'b100); // nickel
                    1: insert(3'b010); // dime
                    2: insert(3'b001); // quarter
                endcase
                entry = fsm_matrix[row][col];
                check(entry[6:4], entry[3:0]);
                cells = cells + 1;
                $display("matrix[%0d][%0d] PASS: next=S%0d outputs=%b",
                         row, col, entry[6:4], entry[3:0]);
            end
        end

        // Phase 3: all eight coin selections in every state. This covers the
        // PDF's nickel-before-dime-before-quarter priority and empty presses.
        for (row = 0; row < 5; row = row + 1) begin
            for (code = 0; code < 8; code = code + 1) begin
                clear_machine();
                repeat (row) insert(3'b100);
                selection = code;
                insert(selection);
                if (coin_priority(selection) == 2'd3) begin
                    want_state = row;
                    want_leds = 4'b0000; // No coin: hold credit, clear result.
                end else begin
                    entry = fsm_matrix[row][coin_priority(selection)];
                    want_state = entry[6:4];
                    want_leds = entry[3:0];
                end
                check(want_state, want_leds);
                combinations = combinations + 1;
            end
        end

        // Held result, switch isolation, empty press, repeated presses.
        clear_machine();
        @(negedge clk); Quarter = 1;
        repeat (4) @(posedge clk);
        @(negedge clk); Quarter = 0;
        #1; check(0, 4'b0000); // A switch alone does not insert a coin.

        insert(3'b000); check(0, 4'b0000); // A press with no coin clears the LEDs.
        insert(3'b111); check(1, 4'b0000); // Nickel wins over dime and quarter.
        insert(3'b011); check(3, 4'b0000); // Dime wins over quarter.
        insert(3'b001); check(0, 4'b1110); // Quarter at 15 cents.
        insert(3'b000); check(0, 4'b0000); // A new press clears the old result.
        insert(3'b001); check(0, 4'b1000);
        clear_machine();

        if (cells != 15) $fatal(1, "Matrix coverage: %0d/15 cells", cells);
        if (combinations != 40) $fatal(1, "Matrix coverage: %0d/40 combinations", combinations);

        $display("Transition matrix (rows S0..S4, columns N/D/Q):");
        for (row = 0; row < 5; row = row + 1) begin
            $write("  S%0d:", row);
            for (col = 0; col < 3; col = col + 1) begin
                entry = fsm_matrix[row][col];
                case (col)
                    0: $write("  N=%b/%b", entry[6:4], entry[3:0]);
                    1: $write("  D=%b/%b", entry[6:4], entry[3:0]);
                    2: $write("  Q=%b/%b", entry[6:4], entry[3:0]);
                endcase
            end
            $display("");
        end
        $display("PASS: matrix testbench: %0d checks, 15/15 matrix cells, 40/40 state/input combinations,", checks);
        $display("      PDF reference transactions, held button/result, asynchronous reset, and input priority.");
        $finish;
    end
    initial begin
        #100000;
        $fatal(1, "Board simulation timeout");
    end
endmodule
