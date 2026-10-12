`timescale 1ns / 1ps
module jk_from_d_tb;
    reg clk = 0;
    reg reset = 0;
    always #5 clk = ~clk;
    reg J = 0, K = 0;
    wire Q;
    integer state, inputs;
    reg expected;
    jk_from_d uut (.clk(clk), .reset(reset), .J(J), .K(K), .Q(Q));
    initial begin
        #1 reset = 1;
        #1;
        if (Q !== 0) $fatal(1, "Reset failed");
        @(negedge clk); reset = 0;
        for (state = 0; state < 2; state = state + 1) begin
            for (inputs = 0; inputs < 4; inputs = inputs + 1) begin
                // Establish each old state independently before each JK case.
                @(negedge clk); J = state; K = !state;
                @(posedge clk); #1;
                if (Q !== state[0]) $fatal(1, "State setup failed");
                @(negedge clk); {J,K} = inputs[1:0];
                #1;
                if (Q !== state[0]) $fatal(1, "Q changed without rising clock");
                case (inputs)
                    0: expected = state;
                    1: expected = 0;
                    2: expected = 1;
                    3: expected = !state;
                endcase
                @(posedge clk); #1;
                if (Q !== expected) $fatal(1, "JK failed: old=%b J=%b K=%b Q=%b", state[0], J, K, Q);
                $display("old=%b J=%b K=%b -> Q=%b", state[0], J, K, Q);
            end
        end
        // Reset from Q=1 between edges.
        @(negedge clk); J=1; K=0;
        @(posedge clk); #1; reset=1; #1;
        if (Q !== 0) $fatal(1, "Mid-run reset failed");
        $display("PASS: JK all 8 state/input combinations, edge behavior and reset");
        $finish;
    end
endmodule
