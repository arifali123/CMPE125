`timescale 1ns / 1ps

// Mealy controller: sample coin inputs and outputs at the rising clock edge.
// 000 holds credit; multiple asserted coin inputs are ignored.
module vending_machine (
    input clk,
    input reset,
    input Nickel,
    input Dime,
    input Quarter,
    output reg Dispense,
    output reg ReturnNickel,
    output reg ReturnDime,
    output reg ReturnTwoDimes
);
    localparam S0  = 3'b000,
               S5  = 3'b001,
               S10 = 3'b010,
               S15 = 3'b011,
               S20 = 3'b100;

    // Preserve the report's binary encoding during synthesis.
    (* fsm_encoding = "none" *) reg [2:0] state;
    reg [2:0] next_state;

    always @(posedge clk or posedge reset) begin
        if (reset) state <= S0;
        else       state <= next_state;
    end

    always @* begin
        next_state = state;
        {Dispense, ReturnNickel, ReturnDime, ReturnTwoDimes} = 4'b0000;
        case (state)
            S0: case ({Nickel, Dime, Quarter})
                3'b100: next_state = S5;
                3'b010: next_state = S10;
                3'b001: begin next_state = S0; Dispense = 1'b1; end
                default: ;
            endcase
            S5: case ({Nickel, Dime, Quarter})
                3'b100: next_state = S10;
                3'b010: next_state = S15;
                3'b001: begin
                    next_state = S0;
                    Dispense = 1'b1; ReturnNickel = 1'b1;
                end
                default: ;
            endcase
            S10: case ({Nickel, Dime, Quarter})
                3'b100: next_state = S15;
                3'b010: next_state = S20;
                3'b001: begin
                    next_state = S0;
                    Dispense = 1'b1; ReturnDime = 1'b1;
                end
                default: ;
            endcase
            S15: case ({Nickel, Dime, Quarter})
                3'b100: next_state = S20;
                3'b010: begin next_state = S0; Dispense = 1'b1; end
                3'b001: begin
                    next_state = S0;
                    Dispense = 1'b1; ReturnNickel = 1'b1; ReturnDime = 1'b1;
                end
                default: ;
            endcase
            S20: case ({Nickel, Dime, Quarter})
                3'b100: begin next_state = S0; Dispense = 1'b1; end
                3'b010: begin
                    next_state = S0;
                    Dispense = 1'b1; ReturnNickel = 1'b1;
                end
                3'b001: begin
                    next_state = S0;
                    Dispense = 1'b1; ReturnTwoDimes = 1'b1;
                end
                default: ;
            endcase
            default: next_state = S0;
        endcase
        if (reset) begin
            next_state = S0;
            {Dispense, ReturnNickel, ReturnDime, ReturnTwoDimes} = 4'b0000;
        end
    end
endmodule
