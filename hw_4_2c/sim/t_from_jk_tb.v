`timescale 1ns / 1ps
module t_from_jk_tb;
    reg clk = 0;
    reg reset = 0;
    always #5 clk = ~clk;
    wire Q;
    reg expected = 0;
    integer i;
    t_from_jk uut (.clk(clk), .reset(reset), .Q(Q));
    initial begin
        #1 reset=1; #1;
        if (Q !== 0) $fatal(1, "Reset failed");
        @(negedge clk); reset=0;
        for (i=0; i<9; i=i+1) begin
            @(posedge clk); expected=~expected; #1;
            if (Q !== expected) $fatal(1, "Toggle failed");
            $display("Rising edge %0d: Q=%b", i+1, Q);
            @(negedge clk); #1;
            if (Q !== expected) $fatal(1, "Falling edge changed Q");
        end
        reset=1; #1;
        if (Q !== 0) $fatal(1, "Mid-run reset failed");
        @(posedge clk); #1;
        if (Q !== 0) $fatal(1, "Reset must override toggle");
        @(negedge clk); reset=0;
        @(posedge clk); #1;
        if (Q !== 1) $fatal(1, "Toggle after reset failed");
        $display("PASS: T toggle, falling-edge hold and reset/restart");
        $finish;
    end
endmodule
