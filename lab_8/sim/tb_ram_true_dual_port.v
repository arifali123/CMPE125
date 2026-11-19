`timescale 1ns/1ps
// Shared simulation top. Enable one testbench file at a time.
module lab8_tb;
    reg clk=0, we1=0, we2=0;
    reg [6:0] a1=0, a2=0;
    reg [7:0] d1=0, d2=0;
    wire [7:0] q1, q2;
    integer errors=0;
    always #5 clk=~clk;
    ram_true_dual_port dut (.clk(clk), .we1(we1), .we2(we2),
        .a1(a1),.a2(a2),.d1(d1),.d2(d2),.q1(q1),.q2(q2));
    task check_both;
        input [7:0] expected1, expected2;
        begin
            #1;
            if (q1 !== expected1 || q2 !== expected2) begin
                $display("FAIL true dual: A=%h expected=%h B=%h expected=%h",q1,expected1,q2,expected2);
                errors=errors+1;
            end else $display("PASS true dual: A=%h B=%h",q1,q2);
        end
    endtask
    initial begin
        $display("Testing true dual-port RAM with shared clock...");
        // Both ports write DIFFERENT addresses on the same rising edge.
        @(negedge clk); a1=7'd2; d1=8'h55; we1=1;
                        a2=7'd3; d2=8'hAA; we2=1;
        @(posedge clk); #1; we1=0; we2=0;
        @(posedge clk); #1; check_both(8'h55,8'hAA);
        // Swap read addresses: both ports see the SAME shared memory.
        a1=7'd3; a2=7'd2;
        check_both(8'h55,8'hAA); // Outputs hold until the clock edge.
        @(posedge clk); #1; check_both(8'hAA,8'h55);
        // Update address 3 from port B; read it back from A.
        @(negedge clk); a1=7'd2; a2=7'd3; d2=8'hF0; we2=1;
        @(posedge clk); #1; we2=0;
        check_both(8'h55,8'hAA); // Port B reads the old value on its write edge.
        a1=7'd3; @(posedge clk); #1; check_both(8'hF0,8'hF0);
        if(errors == 0) $display("ALL TRUE DUAL-PORT TESTS PASSED");
        else $fatal(1, "TRUE DUAL-PORT ERRORS: %0d",errors);
        $finish;
    end
endmodule
