`timescale 1ns/1ps
// Shared simulation top. Enable one testbench file at a time.
module lab8_tb;
    parameter integer CLOCK2_HALF_PERIOD = 7;
    parameter integer CLOCK2_PHASE = 0;
    reg clk1=0, clk2=0, we1=0, we2=0, request2=0;
    reg [7:0] a1=0, a2=0, d1=0, d2=0;
    wire [7:0] q1, q2;
    wire ready2, valid2, collision2;
    integer address_index;

    always #5 clk1=~clk1;
    initial begin
        #(CLOCK2_PHASE);
        forever #(CLOCK2_HALF_PERIOD) clk2=~clk2;
    end
    ram_dual_two_clocks dut (
        .clk1(clk1), .clk2(clk2), .we1(we1), .we2(we2),
        .a1(a1), .a2(a2), .d1(d1), .d2(d2), .q1(q1), .q2(q2),
        .request2(request2), .ready2(ready2), .valid2(valid2),
        .collision2(collision2)
    );

    initial begin
        #1000000;
        $fatal(1, "Timed out waiting for the two-clock handshake.");
    end

    task check_a;
        input [7:0] expected;
        begin
            @(posedge clk1); #1;
            if (q1 !== expected)
                $fatal(1, "Port A got %h expected %h.", q1, expected);
        end
    endtask

    task transaction_b;
        input write_enable;
        input [7:0] address, data, expected;
        input expected_collision;
        begin
            @(negedge clk2);
            while (!ready2) @(negedge clk2);
            a2 = address;
            d2 = data;
            we2 = write_enable;
            request2 = 1;
            @(posedge clk2); #1;
            if (ready2 !== 0) $fatal(1, "Port B did not become busy.");
            @(negedge clk2);
            request2 = 0;
            // The accepted request fields must be held internally.
            a2 = ~address;
            d2 = ~data;
            we2 = 0;
            while (!valid2) begin
                @(posedge clk2); #1;
            end
            if (q2 !== expected || collision2 !== expected_collision)
                $fatal(1, "Port B got %h collision=%b expected %h collision=%b.",
                       q2, collision2, expected, expected_collision);
        end
    endtask

    initial begin
        // Fill all locations via A, then verify them via independent-clock B.
        for (address_index=0; address_index<256; address_index=address_index+1) begin
            @(negedge clk1);
            a1=address_index[7:0]; d1=address_index[7:0] ^ 8'hA5; we1=1;
            @(posedge clk1); #1; we1=0;
        end
        for (address_index=0; address_index<256; address_index=address_index+1)
            transaction_b(0, address_index[7:0], 0, address_index[7:0] ^ 8'hA5, 0);

        // B overwrites all locations, then A verifies each byte.
        for (address_index=0; address_index<256; address_index=address_index+1)
            transaction_b(1, address_index[7:0], address_index[7:0] ^ 8'h5A,
                          address_index[7:0] ^ 8'hA5, 0);
        for (address_index=0; address_index<256; address_index=address_index+1) begin
            @(negedge clk1); a1=address_index[7:0];
            check_a(address_index[7:0] ^ 8'h5A);
        end

        // A has priority when both writes are serviced at the same address.
        @(negedge clk1); a1=255; d1=8'h12; we1=1;
        transaction_b(1, 255, 8'h34, 8'h12, 1);
        @(negedge clk1); we1=0;
        transaction_b(0, 255, 0, 8'h12, 0);

        // Change A's data only on the B service edge. B must see the old
        // byte even though A writes a different byte on that very edge.
        fork
            transaction_b(0, 255, 0, 8'h12, 0);
            begin
                wait (dut.service_b);
                @(negedge clk1); we1=1; d1=8'h56;
                check_a(8'h12);
                @(negedge clk1); we1=0;
            end
        join
        transaction_b(0, 255, 0, 8'h56, 0);

        // B writes while A reads: A sees the update on a later edge.
        fork
            transaction_b(1, 255, 8'h78, 8'h56, 0);
            begin
                wait (dut.service_b);
                check_a(8'h56);
            end
        join
        check_a(8'h78);

        // Concurrent writes to different addresses both succeed.
        @(negedge clk1); a1=0; d1=8'h9A; we1=1;
        transaction_b(1, 255, 8'hBC, 8'h78, 0);
        @(negedge clk1); we1=0;
        check_a(8'h9A);
        transaction_b(0, 255, 0, 8'hBC, 0);

        $display("ALL TWO-CLOCK DUAL-PORT TESTS PASSED");
        $finish;
    end
endmodule
