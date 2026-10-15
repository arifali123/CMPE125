`timescale 1ns / 1ps

// Type 3 testbench: inputs and expected results come from test_vector.tv.
module test_vector_tb;
    parameter NUM_VECTORS = 4;

    reg clk;
    reg reset;
    reg [3:0] A;
    reg [3:0] B;
    reg Ci;
    reg [4:0] expected_sum;
    wire [3:0] S;
    wire Co;
    wire PG;
    wire GG;
    reg [31:0] vectornum;
    reg [31:0] errors;

    // Each vector is {A[3:0], B[3:0], Ci, expected Co/S[3:0]}.
    reg [13:0] testvectors [0:NUM_VECTORS-1];

    CLA4 dut (
        .A(A), .B(B), .Ci(Ci), .S(S),
        .Co(Co), .PG(PG), .GG(GG)
    );

    // One complete clock period is 10 ns.
    always begin
        clk = 1'b1; #5;
        clk = 1'b0; #5;
    end

    initial begin
        // The Vivado project registers this as a memory-initialization file,
        // so XSim makes it available without a machine-specific absolute path.
        $readmemb("test_vector.tv", testvectors);
        vectornum = 0;
        errors = 0;
        reset = 1'b1;
        #27;
        reset = 1'b0;
    end

    // Apply a vector just after a rising clock edge.
    always @(posedge clk) begin
        #1;
        {A, B, Ci, expected_sum} = testvectors[vectornum];
    end

    // Check the result on the falling edge after propagation time.
    always @(negedge clk) begin
        if (!reset) begin
            if ({Co, S} !== expected_sum) begin
                $display("ERROR: A=%b B=%b Ci=%b", A, B, Ci);
                $display("       result=%b expected=%b", {Co, S}, expected_sum);
                errors = errors + 1;
            end

            if (vectornum == NUM_VECTORS - 1) begin
                if (errors == 0)
                    $display("PASS: %0d vector additions completed with 0 errors.", NUM_VECTORS);
                else
                    $display("FAIL: %0d vector additions completed with %0d errors.", NUM_VECTORS, errors);
                $finish;
            end else
                vectornum = vectornum + 1;
        end
    end
endmodule
