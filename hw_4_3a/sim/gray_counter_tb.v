`timescale 1ns / 1ps
module gray_counter_tb;
    reg clk = 0;
    reg reset = 0;
    always #5 clk = ~clk;
    wire [2:0] Q;
    reg [2:0] sequence [0:7];
    reg [2:0] previous, changed;
    integer i;
    gray_counter uut (.clk(clk), .reset(reset), .Q(Q));
    initial begin
        sequence[0]=3'b000; sequence[1]=3'b001;
        sequence[2]=3'b011; sequence[3]=3'b010;
        sequence[4]=3'b110; sequence[5]=3'b111;
        sequence[6]=3'b101; sequence[7]=3'b100;
        #1 reset=1; #1;
        if (Q !== 3'b000) $fatal(1, "Reset failed");
        @(posedge clk); #1;
        if (Q !== 3'b000) $fatal(1, "Reset hold failed");
        @(negedge clk); reset=0; previous=Q;
        for (i=1; i<=24; i=i+1) begin
            @(posedge clk); #1;
            if (Q !== sequence[i%8]) $fatal(1, "Gray sequence failed at step %0d: %b", i, Q);
            changed=Q ^ previous;
            if (changed !== 3'b001 && changed !== 3'b010 && changed !== 3'b100)
                $fatal(1, "Transition changed more than one bit");
            $display("Step %0d: %b -> %b", i, previous, Q);
            previous=Q;
            @(negedge clk); #1;
            if (Q !== previous) $fatal(1, "Falling edge changed Q");
        end
        repeat (3) @(posedge clk);
        #1 reset=1; #1;
        if (Q !== 0) $fatal(1, "Mid-run reset failed");
        @(negedge clk); reset=0;
        @(posedge clk); #1;
        if (Q !== 3'b001) $fatal(1, "Restart failed");
        $display("PASS: Gray three full periods, one-bit transitions, hold and reset/restart");
        $finish;
    end
endmodule
