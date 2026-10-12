`timescale 1ns / 1ps

// Question 4c: Mealy FSM. State stores the previous sampled A.
// During a cycle, apply A_n/B_n and observe Z BEFORE the next rising edge;
// that edge stores A_n as the history for the following cycle.
module and_or_fsm(input clk, input reset, input A, input B, output Z);
    reg previous_A;
    always @(posedge clk or posedge reset)
        if (reset) previous_A <= 1'b0;
        else       previous_A <= A;

    assign Z = B ? (A | previous_A) : (A & previous_A);
endmodule
