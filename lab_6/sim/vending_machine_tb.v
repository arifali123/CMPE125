`timescale 1ns / 1ps

// Lab 5 Type 3 style, extended to check stateful transactions.
module vending_machine_tb;
    parameter NUM_VECTORS = 228;
    reg clk = 0;
    reg reset = 0;
    reg Nickel = 0, Dime = 0, Quarter = 0;
    wire Dispense, ReturnNickel, ReturnDime, ReturnTwoDimes;
    reg [10:0] testvectors [0:NUM_VECTORS-1];
    reg [3:0] expected_outputs;
    reg [2:0] expected_state;
    reg [7:0] coverage [0:4];
    integer vectornum, errors, i;
    integer credit, coin_value, total, change, reference_state;
    integer vends, returned;
    reg [3:0] reference_outputs;
    reg [3:0] change_coverage;

    vending_machine uut (
        .clk(clk), .reset(reset),
        .Nickel(Nickel), .Dime(Dime), .Quarter(Quarter),
        .Dispense(Dispense), .ReturnNickel(ReturnNickel),
        .ReturnDime(ReturnDime), .ReturnTwoDimes(ReturnTwoDimes)
    );
    always #5 clk = ~clk;

    initial begin
        $dumpfile("vending_machine.vcd");
        $dumpvars(0, vending_machine_tb);
        $readmemb("test_vector.tv", testvectors);
        errors = 0; credit = 0; vends = 0; returned = 0;
        change_coverage = 0;
        for (i = 0; i < 5; i = i + 1) coverage[i] = 0;

        for (vectornum = 0; vectornum < NUM_VECTORS; vectornum = vectornum + 1) begin
            // Drive halfway between sampling edges. Mealy outputs must be
            // checked BEFORE the edge that updates the credit register.
            @(negedge clk);
            {reset, Nickel, Dime, Quarter, expected_outputs, expected_state}
                = testvectors[vectornum];
            if ((^testvectors[vectornum]) === 1'bx)
                $fatal(1, "Missing/unknown vector %0d", vectornum);

            // Independent arithmetic model checks the vector file as well.
            reference_outputs = 0;
            reference_state = credit / 5;
            coin_value = 0;
            change = 0;
            if (reset) reference_state = 0;
            else begin
                coverage[credit / 5][{Nickel, Dime, Quarter}] = 1'b1;
                case ({Nickel, Dime, Quarter})
                    3'b100: coin_value = 5;
                    3'b010: coin_value = 10;
                    3'b001: coin_value = 25;
                    default: coin_value = 0;
                endcase
                total = credit + coin_value;
                if (total >= 25) begin
                    change = total - 25;
                    reference_outputs = {1'b1, (change % 10 == 5),
                                         (change == 10 || change == 15),
                                         (change == 20)};
                    reference_state = 0;
                    vends = vends + 1;
                    returned = returned + change;
                    if (change != 0) change_coverage[change / 5 - 1] = 1'b1;
                end else reference_state = total / 5;
            end
            if (expected_outputs !== reference_outputs || expected_state !== reference_state[2:0])
                $fatal(1, "Incorrect expectations in vector %0d", vectornum);
            #1;
            if ({Dispense, ReturnNickel, ReturnDime, ReturnTwoDimes} !== expected_outputs) begin
                $display("ERROR vector %0d: credit=%0d NDQ=%b%b%b outputs=%b expected=%b",
                    vectornum, credit, Nickel, Dime, Quarter,
                    {Dispense, ReturnNickel, ReturnDime, ReturnTwoDimes}, expected_outputs);
                errors = errors + 1;
            end
            if (reset && uut.state !== 3'b000)
                $fatal(1, "Asynchronous reset failed before clock at vector %0d", vectornum);
            $display("vector=%0d reset=%b credit=%0d NDQ=%b%b%b outputs=%b next=%b",
                vectornum, reset, credit, Nickel, Dime, Quarter, expected_outputs, expected_state);
            @(posedge clk); #1;
            if (uut.state !== expected_state) begin
                $display("ERROR vector %0d: state=%b expected=%b", vectornum, uut.state, expected_state);
                errors = errors + 1;
            end
            credit = reference_state * 5;
            // Deassert the sampled coin; an idle input must produce no output.
            {Nickel, Dime, Quarter} = 3'b000;
            #1;
            if ({Dispense, ReturnNickel, ReturnDime, ReturnTwoDimes} !== 4'b0000)
                $fatal(1, "Output stuck after coin removal at vector %0d", vectornum);
        end
        for (i = 0; i < 5; i = i + 1)
            if (coverage[i] !== 8'hff)
                $fatal(1, "Missing state/input coverage: state=%0d mask=%b", i, coverage[i]);
        if (change_coverage !== 4'b1111)
            $fatal(1, "Missing change amounts: %b", change_coverage);
        // Exercise the unused encodings without adding nonphysical coin inputs.
        for (i = 5; i < 8; i = i + 1) begin
            @(negedge clk);
            Quarter = 1'b1;
            case (i)
                5: force uut.state = 3'b101;
                6: force uut.state = 3'b110;
                7: force uut.state = 3'b111;
            endcase
            #1;
            if (uut.next_state !== 3'b000 ||
                {Dispense, ReturnNickel, ReturnDime, ReturnTwoDimes} !== 4'b0000)
                $fatal(1, "Unsafe unused state %0d", i);
            release uut.state;
            @(posedge clk); #1;
            if (uut.state !== 3'b000) $fatal(1, "Unused state did not recover");
            Quarter = 1'b0;
        end
        #1;
        if (errors != 0) $fatal(1, "FAIL: %0d errors", errors);
        $display("PASS: %0d vectors, all 40 state/input combinations, all 4 change amounts, asynchronous reset.", NUM_VECTORS);
        $display("PASS: %0d sodas dispensed; %0d cents returned.", vends, returned);
        $display("PASS: all 3 unused state encodings recover to S0 without dispensing.");
        $finish;
    end
    initial begin
        #100000;
        $fatal(1, "Simulation timeout");
    end
endmodule
