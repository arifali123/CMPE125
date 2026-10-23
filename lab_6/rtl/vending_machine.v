`timescale 1ns / 1ps

// Copied from the supplied PDF.
// State is internal because the PDF has no pin assignments for a state output.
module vending_machine (
    input wire clk,
    input wire reset,
    input wire button,
    input wire Nickel,
    input wire Dime,
    input wire Quarter,
    output reg Dispense,
    output reg ReturnNickel,
    output reg ReturnDime,
    output reg ReturnTwoDimes
);

    // Five states
    parameter S0 = 3'b000,
              S1 = 3'b001,
              S2 = 3'b010,
              S3 = 3'b011,
              S4 = 3'b100;

    reg [2:0] state;
    reg button_prev;

    initial begin
        state = S0;
        button_prev = 0;
        Dispense = 0;
        ReturnNickel = 0;
        ReturnDime = 0;
        ReturnTwoDimes = 0;
    end
    always @(posedge clk or posedge reset) begin

        if (reset) begin
            state <= S0;
            button_prev <= 0;
            Dispense <= 0;
            ReturnNickel <= 0;
            ReturnDime <= 0;
            ReturnTwoDimes <= 0;
        end

        else begin
            button_prev <= button;

            // Check if the button was just pressed
            if (button && !button_prev) begin

                Dispense <= 0;
                ReturnNickel <= 0;
                ReturnDime <= 0;
                ReturnTwoDimes <= 0;

                case (state)

                    S0: begin
                        if (Nickel)
                            state <= S1;
                        else if (Dime)
                            state <= S2;
                        else if (Quarter) begin
                            state <= S0;
                            Dispense <= 1;
                        end
                    end

                    S1: begin
                        if (Nickel)
                            state <= S2;
                        else if (Dime)
                            state <= S3;
                        else if (Quarter) begin
                            state <= S0;
                            Dispense <= 1;
                            ReturnNickel <= 1;
                        end
                    end

                    S2: begin
                        if (Nickel)
                            state <= S3;
                        else if (Dime)
                            state <= S4;
                        else if (Quarter) begin
                            state <= S0;
                            Dispense <= 1;
                            ReturnDime <= 1;
                        end
                    end

                    S3: begin
                        if (Nickel)
                            state <= S4;
                        else if (Dime) begin
                            state <= S0;
                            Dispense <= 1;
                        end
                        else if (Quarter) begin
                            state <= S0;
                            Dispense <= 1;
                            ReturnNickel <= 1;
                            ReturnDime <= 1;
                        end
                    end

                    S4: begin
                        if (Nickel) begin
                            state <= S0;
                            Dispense <= 1;
                        end
                        else if (Dime) begin
                            state <= S0;
                            Dispense <= 1;
                            ReturnNickel <= 1;
                        end
                        else if (Quarter) begin
                            state <= S0;
                            Dispense <= 1;
                            ReturnTwoDimes <= 1;
                        end
                    end

                    default: state <= S0;

                endcase
            end
        end
    end

endmodule
