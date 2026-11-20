`timescale 1ns/1ps
// Shared simulation top. Enable one testbench file at a time.
module lab8_tb;
    reg clk1=0, clk2=0, we1=0, we2=0;
    reg [7:0] a1=0, a2=0;
    reg [7:0] d1=0, d2=0;
    wire [7:0] q1, q2;
    integer address_index;
    integer errors=0;
    always #5 clk1=~clk1; // period 10 ns
    always #7 clk2=~clk2; // period 14 ns (independent clock)
    ram_dual_two_clocks dut (.clk1(clk1),.clk2(clk2),.we1(we1),.we2(we2),
         .a1(a1),.a2(a2),.d1(d1),.d2(d2),.q1(q1),.q2(q2));
    task check_a;
        input [7:0] expected;
        begin
            #1;
            if (q1 !== expected) begin
                $display("FAIL clock2 RAM A: got %h expected %h",q1,expected);
                errors=errors+1;
            end else $display("PASS two-clock port A data=%h",q1);
        end
    endtask
    task check_b;
        input [7:0] expected;
        begin
            #1;
            if (q2 !== expected) begin
                $display("FAIL clock2 RAM B: got %h expected %h",q2,expected);
                errors=errors+1;
            end else $display("PASS two-clock port B data=%h",q2);
        end
    endtask
    initial begin
        $display("Testing dual-port RAM with two independent clocks...");
        @(negedge clk1); a1=8'd8; d1=8'h3C; we1=1;
        @(posedge clk1); #1; we1=0; @(posedge clk1); #1; check_a(8'h3C);
        a2=8'd8; @(posedge clk2); #1; check_b(8'h3C); // port B sees what A wrote
        @(negedge clk2); a2=8'd9; d2=8'hD2; we2=1;
        @(posedge clk2); #1; we2=0; @(posedge clk2); #1; check_b(8'hD2);
        a1=8'd9; @(posedge clk1); #1; check_a(8'hD2); // port A sees what B wrote
        @(negedge clk1); a1=8'd8; we1=0;
        @(posedge clk1); #1; check_a(8'h3C);
        // Fill all 256 locations through A, then read them through B.
        for (address_index = 0; address_index < 256; address_index = address_index + 1) begin
            @(negedge clk1);
            a1 = address_index[7:0];
            a2 = ~address_index[7:0];
            d1 = address_index[7:0] ^ 8'hA5;
            we1 = 1;
            @(posedge clk1); #1; we1 = 0;
        end
        for (address_index = 0; address_index < 256; address_index = address_index + 1) begin
            @(negedge clk2);
            a2 = address_index[7:0];
            @(posedge clk2);
            check_b(address_index[7:0] ^ 8'hA5);
        end
        // Reverse direction and use a different pattern to verify overwrites.
        for (address_index = 0; address_index < 256; address_index = address_index + 1) begin
            @(negedge clk2);
            a2 = address_index[7:0];
            a1 = ~address_index[7:0];
            d2 = address_index[7:0] ^ 8'h5A;
            we2 = 1;
            @(posedge clk2); #1; we2 = 0;
        end
        for (address_index = 0; address_index < 256; address_index = address_index + 1) begin
            @(negedge clk1);
            a1 = address_index[7:0];
            @(posedge clk1);
            check_a(address_index[7:0] ^ 8'h5A);
        end
        if(errors == 0) $display("ALL TWO-CLOCK DUAL-PORT TESTS PASSED");
        else $fatal(1, "TWO-CLOCK ERRORS: %0d",errors);
        $finish;
    end
endmodule
