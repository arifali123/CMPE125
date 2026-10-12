`timescale 1ns / 1ps
module d_from_jk_tb;
    reg clk = 0;
    reg reset = 0;
    always #5 clk = ~clk;
    reg D = 0;
    wire Q;
    reg old_Q;
    integer i;
    reg [7:0] pattern = 8'b00110101;
    d_from_jk uut (.clk(clk), .reset(reset), .D(D), .Q(Q));
    initial begin
        #1 reset=1; #1;
        if (Q !== 0) $fatal(1, "Reset failed");
        @(negedge clk); reset=0;
        for (i=0; i<8; i=i+1) begin
            @(negedge clk); old_Q=Q; D=pattern[i];
            #1;
            if (Q !== old_Q) $fatal(1, "D changed Q without a rising edge");
            @(posedge clk); #1;
            if (Q !== D) $fatal(1, "D capture failed");
            $display("D=%b -> Q=%b", D, Q);
        end
        @(negedge clk); D=1;
        @(posedge clk); #1; reset=1; #1;
        if (Q !== 0) $fatal(1, "Mid-run reset failed");
        $display("PASS: D capture, hold between edges and reset");
        $finish;
    end
endmodule
