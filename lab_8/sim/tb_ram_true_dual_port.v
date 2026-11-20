`timescale 1ns/1ps
// Shared simulation top. Enable one testbench file at a time.
module lab8_tb;
    reg clk=0, we1=0, we2=0;
    reg [7:0] a1=0, a2=0;
    reg [7:0] d1=0, d2=0;
    wire [7:0] q1, q2;
    wire collision;
    integer address_index;
    integer errors=0;
    always #5 clk=~clk;
    ram_true_dual_port dut (.clk(clk), .we1(we1), .we2(we2),
        .a1(a1),.a2(a2),.d1(d1),.d2(d2),.q1(q1),.q2(q2),.collision(collision));
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
        @(negedge clk); a1=8'd2; d1=8'h55; we1=1;
                        a2=8'd3; d2=8'hAA; we2=1;
        @(posedge clk); #1; we1=0; we2=0;
        @(posedge clk); #1; check_both(8'h55,8'hAA);
        // Swap read addresses: both ports see the SAME shared memory.
        a1=8'd3; a2=8'd2;
        check_both(8'h55,8'hAA); // Outputs hold until the clock edge.
        @(posedge clk); #1; check_both(8'hAA,8'h55);
        // Update address 3 from port B; read it back from A.
        @(negedge clk); a1=8'd2; a2=8'd3; d2=8'hF0; we2=1;
        @(posedge clk); #1; we2=0;
        check_both(8'h55,8'hAA); // Port B reads the old value on its write edge.
        a1=8'd3; @(posedge clk); #1; check_both(8'hF0,8'hF0);
        // Write the lower and upper halves simultaneously. Each pair of
        // addresses differs only in bit 7, so aliasing loses one pattern.
        for (address_index = 0; address_index < 128; address_index = address_index + 1) begin
            @(negedge clk);
            a1 = address_index[7:0];
            a2 = address_index[7:0] | 8'h80;
            d1 = address_index[7:0];
            d2 = address_index[7:0] ^ 8'hA5;
            we1 = 1;
            we2 = 1;
            @(posedge clk); #1; we1 = 0; we2 = 0;
        end
        // Read each half from the opposite port after the full memory fill.
        for (address_index = 0; address_index < 128; address_index = address_index + 1) begin
            @(negedge clk);
            a1 = address_index[7:0] | 8'h80;
            a2 = address_index[7:0];
            @(posedge clk);
            check_both(address_index[7:0] ^ 8'hA5, address_index[7:0]);
        end
        // Same-address writes: A wins, and both outputs read the old byte.
        @(negedge clk); a1=8'd255; a2=8'd255;
        d1=8'h12; d2=8'h34; we1=1; we2=1;
        #1;
        if (collision !== 1'b1) $fatal(1, "Missing write collision indication.");
        @(posedge clk);
        check_both(8'hDA, 8'hDA); // Previous upper-half pattern at 255.
        @(negedge clk); we1=0; we2=0;
        @(posedge clk); check_both(8'h12, 8'h12);
        if (collision !== 1'b0) $fatal(1, "Read/read flagged as a collision.");

        // B writes while A reads the same address.
        @(negedge clk); d2=8'h56; we2=1;
        @(posedge clk); check_both(8'h12, 8'h12);
        @(negedge clk); we2=0;
        @(posedge clk); check_both(8'h56, 8'h56);

        // A writes while B reads the same address.
        @(negedge clk); d1=8'h78; we1=1;
        @(posedge clk); check_both(8'h56, 8'h56);
        @(negedge clk); we1=0;
        @(posedge clk); check_both(8'h78, 8'h78);

        // Equal-data concurrent writes also resolve through A.
        @(negedge clk); d1=8'h9A; d2=8'h9A; we1=1; we2=1;
        @(posedge clk); check_both(8'h78, 8'h78);
        @(negedge clk); we1=0; we2=0;
        @(posedge clk); check_both(8'h9A, 8'h9A);
        if(errors == 0) $display("ALL TRUE DUAL-PORT TESTS PASSED");
        else $fatal(1, "TRUE DUAL-PORT ERRORS: %0d",errors);
        $finish;
    end
endmodule
