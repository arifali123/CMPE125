`timescale 1ns / 1ps
module and_or_fsm_tb;
    reg clk = 0;
    reg reset = 0;
    always #5 clk = ~clk;
    reg A=0, B=0;
    wire Z;
    integer state, inputs;
    reg expected;
    and_or_fsm uut (.clk(clk), .reset(reset), .A(A), .B(B), .Z(Z));
    initial begin
        #1 reset=1; #1;
        if (Z !== 0) $fatal(1, "Initial output failed");
        @(negedge clk); reset=0;
        for (state=0; state<2; state=state+1) begin
            for (inputs=0; inputs<4; inputs=inputs+1) begin
                @(negedge clk); A=state; B=0;
                @(posedge clk); #1;
                @(negedge clk); {A,B}=inputs[1:0];
                // Explicit truth table indexed by {previous_A, A, B}.
                case (state*4+inputs)
                    0,1,2,4: expected=0;
                    3,5,6,7: expected=1;
                endcase
                #1;
                if (Z !== expected) $fatal(1, "Mealy failed: previous_A=%b A=%b B=%b Z=%b", state[0], A, B, Z);
                $display("previous_A=%b A=%b B=%b -> Z=%b", state[0], A, B, Z);
                @(posedge clk); #1;
                // After capture, current and stored A match, so AND/OR both equal A.
                if (Z !== A) $fatal(1, "History update failed");
            end
        end
        // Stored A=1, current A=0, OR mode: Z=1 before asynchronous reset.
        @(negedge clk); A=0; B=1; #1;
        if (Z !== 1) $fatal(1, "History not retained");
        reset=1; #1;
        if (Z !== 0) $fatal(1, "History reset failed");
        $display("PASS: Mealy all 8 state/input combinations, history update and reset");
        $finish;
    end
endmodule
