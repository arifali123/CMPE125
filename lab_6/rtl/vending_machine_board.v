`timescale 1ns / 1ps

// Basys 3 controls around the unchanged Mealy controller.
// Select one coin switch, then press/release the center button to insert it.
module vending_machine_board #(
    parameter integer DEBOUNCE_CYCLES = 1_000_000 // 10 ms at 100 MHz
) (
    input clk,
    input reset,
    input button,
    input Nickel,
    input Dime,
    input Quarter,
    output reg Dispense,
    output reg ReturnNickel,
    output reg ReturnDime,
    output reg ReturnTwoDimes
);
    // Asynchronous assertion, two-clock synchronized reset release.
    // Start in reset after FPGA configuration, even with SW3 down.
    (* ASYNC_REG = "TRUE" *) reg [1:0] reset_sync = 2'b11;
    always @(posedge clk or posedge reset) begin
        if (reset) reset_sync <= 2'b11;
        else       reset_sync <= {reset_sync[0], 1'b0};
    end
    wire board_reset = reset_sync[1];

    (* ASYNC_REG = "TRUE" *) reg [1:0] button_sync;
    (* ASYNC_REG = "TRUE" *) reg [2:0] coin_meta, coin_sync;
    always @(posedge clk or posedge board_reset) begin
        if (board_reset) begin
            button_sync <= 2'b00;
            coin_meta <= 3'b000;
            coin_sync <= 3'b000;
        end else begin
            button_sync <= {button_sync[0], button};
            coin_meta <= {Nickel, Dime, Quarter};
            coin_sync <= coin_meta;
        end
    end

    localparam integer COUNT_WIDTH = (DEBOUNCE_CYCLES <= 1) ? 1 : $clog2(DEBOUNCE_CYCLES);
    localparam [COUNT_WIDTH-1:0] LAST_COUNT = DEBOUNCE_CYCLES - 1;
    reg [COUNT_WIDTH-1:0] debounce_count;
    reg button_stable, button_previous;

    // Require a stable level on BOTH press and release. A held or bouncing
    // button cannot repeatedly insert the selected coin.
    always @(posedge clk or posedge board_reset) begin
        if (board_reset) begin
            debounce_count <= 0;
            button_stable <= 1'b0;
            button_previous <= 1'b0;
        end else begin
            button_previous <= button_stable;
            if (button_sync[1] == button_stable) debounce_count <= 0;
            else if (debounce_count == LAST_COUNT) begin
                button_stable <= button_sync[1];
                debounce_count <= 0;
            end else debounce_count <= debounce_count + 1'b1;
        end
    end
    wire insert_coin = button_stable && !button_previous;
    wire [2:0] sampled_coin = insert_coin ? coin_sync : 3'b000;
    wire [3:0] result;

    vending_machine controller (
        .clk(clk), .reset(board_reset),
        .Nickel(sampled_coin[2]), .Dime(sampled_coin[1]), .Quarter(sampled_coin[0]),
        .Dispense(result[3]), .ReturnNickel(result[2]),
        .ReturnDime(result[1]), .ReturnTwoDimes(result[0])
    );

    // Capture the Mealy result at the SAME edge that accepts the coin.
    // LEDs keep that result until the next accepted press or reset.
    always @(posedge clk or posedge board_reset) begin
        if (board_reset)
            {Dispense, ReturnNickel, ReturnDime, ReturnTwoDimes} <= 4'b0000;
        else if (insert_coin)
            {Dispense, ReturnNickel, ReturnDime, ReturnTwoDimes} <= result;
    end
endmodule
