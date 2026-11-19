`timescale 1ns/1ps
// Shared simulation top. Enable one testbench file at a time.
module lab8_tb;
    reg clk = 0;
    reg we = 0;
    reg [6:0] a = 0;
    reg [7:0] d = 0;
    wire [7:0] q;
    integer errors = 0;
    always #5 clk = ~clk;  // 10 ns period
    ram_single dut (.clk(clk), .we(we), .a(a), .d(d), .q(q));

    task check;
        input [7:0] expected;
        begin
            #1;
            if (q !== expected) begin
                $display("FAIL single: addr=%0d got=%h expected=%h",a,q,expected);
                errors = errors + 1;
            end else $display("PASS single: addr=%0d data=%h",a,q);
        end
    endtask
    initial begin
        $display("Testing single-port RAM...");
        @(negedge clk); a=7'd5; d=8'h2A; we=1;
        @(posedge clk); #1; we=0; check(8'h2A);
        @(negedge clk); a=7'd127; d=8'hA5; we=1;
        @(posedge clk); #1; we=0; check(8'hA5);
        a=7'd5; check(8'h2A);
        // A write disabled by WE must not change the stored value.
        @(negedge clk); a=7'd5; d=8'hFF; we=0;
        @(posedge clk); #1; check(8'h2A);
        @(negedge clk); d=8'hD2; we=1;
        check(8'h2A); // The new byte is not visible before the write edge.
        @(posedge clk); #1; we=0; check(8'hD2);
        if (errors == 0) $display("ALL SINGLE-PORT TESTS PASSED");
        else $fatal(1, "SINGLE-PORT ERRORS: %0d",errors);
        $finish;
    end
endmodule
