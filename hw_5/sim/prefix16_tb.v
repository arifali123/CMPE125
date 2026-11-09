`timescale 1ns / 1ps

module prefix16_tb;
    reg [15:0] A, B;
    reg Cin;
    wire [15:0] S;
    wire Cout;
    reg ph, gh, pl, gl;
    wire po, go;
    integer tests, cells, i, j, c, first_bit, last_bit, seed;
    reg [15:0] mask, random_a, random_b;
    reg random_c;

    prefix16 uut (.A(A), .B(B), .Cin(Cin), .S(S), .Cout(Cout));
    prefix_black cell_uut (.P_hi(ph), .G_hi(gh), .P_lo(pl), .G_lo(gl),
                           .P_out(po), .G_out(go));

    task check;
        input [15:0] a, b;
        input ci;
        reg [16:0] expected;
        begin
            A = a;
            B = b;
            Cin = ci;
            expected = {1'b0, a} + {1'b0, b} + {16'b0, ci};
            #10;
            tests = tests + 1;
            if ({Cout, S} !== expected)
                $fatal(1, "FAIL A=%h B=%h Cin=%b: got %h expected %h",
                       A, B, Cin, {Cout, S}, expected);
        end
    endtask

    // Check every intermediate group, including bypass wires, against a
    // serial reference fold over that group's ORIGINAL input columns.
    // This checks the pictured tree's P outputs as well as arithmetic G.
    task check_tree;
        integer row, col, low, k;
        reg expected_p, expected_g, leaf_p, leaf_g;
        begin
            for (row = 0; row <= 4; row = row + 1)
                for (col = 0; col < 16; col = col + 1) begin
                    low = (col / (1 << row)) * (1 << row);
                    expected_p = 1'b1;
                    expected_g = 1'b0;
                    for (k = low; k <= col; k = k + 1) begin
                        if (k == 0) begin
                            leaf_p = 0;
                            leaf_g = Cin;
                        end else begin
                            leaf_p = A[k-1] | B[k-1];
                            leaf_g = A[k-1] & B[k-1];
                        end
                        expected_g = leaf_g | (leaf_p & expected_g);
                        expected_p = leaf_p & expected_p;
                    end
                    if (uut.p[row][col] !== expected_p ||
                        uut.g[row][col] !== expected_g)
                        $fatal(1, "FAIL prefix row=%0d column=%0d", row, col);
                end
        end
    endtask

    initial begin
        tests = 0;
        cells = 0;
        seed = 125;
        A = 0;
        B = 0;
        Cin = 0;
        // Optional compact waveform: only the illustrative vectors below.
        if ($test$plusargs("vcd")) begin
            $dumpfile("prefix16.vcd");
            $dumpvars(0, prefix16_tb);
        end

        // All black-block inputs, even P/G combinations impossible at a leaf.
        for (i = 0; i < 16; i = i + 1) begin
            {ph, gh, pl, gl} = i[3:0];
            #10;
            if (po !== (ph & pl) || go !== (gh | (ph & gl)))
                $fatal(1, "FAIL black block input=%b", {ph, gh, pl, gl});
            cells = cells + 1;
        end

        check(16'h0000, 16'h0000, 0);
        check(16'h0000, 16'h0000, 1);
        check(16'hffff, 16'h0001, 0);
        check(16'hffff, 16'h0000, 1);
        check(16'hffff, 16'hffff, 1);
        check(16'h7fff, 16'h0001, 0);
        check(16'h8000, 16'h8000, 0);
        check(16'haaaa, 16'h5555, 0);
        check(16'haaaa, 16'h5555, 1);
        check(16'h1234, 16'h4321, 0);
        check_tree;
        if ($test$plusargs("vcd")) $dumpoff;

        // Generate a carry at every possible bit and propagate it through
        // every contiguous range, with both carry-ins and operand orders.
        for (first_bit = 0; first_bit < 16; first_bit = first_bit + 1)
            for (last_bit = first_bit; last_bit < 16; last_bit = last_bit + 1) begin
                mask = ((17'h1 << (last_bit+1)) - 1) ^
                       ((17'h1 << first_bit) - 1);
                for (c = 0; c < 2; c = c + 1) begin
                    check(mask, 16'h1 << first_bit, c[0]);
                    check_tree;
                    check(16'h1 << first_bit, mask, c[0]);
                    check_tree;
                    // Clearing the first bit kills carry propagation there.
                    check(mask & ~(16'h1 << first_bit), 0, c[0]);
                    check_tree;
                end
            end

        // Exhaustive 8-bit operands, including carry into bit 8.
        for (i = 0; i < 256; i = i + 1)
            for (j = 0; j < 256; j = j + 1)
                for (c = 0; c < 2; c = c + 1)
                    check(i[15:0], j[15:0], c[0]);

        // Every 16-bit A: increment/carry chains and full-width propagation.
        for (i = 0; i < 65536; i = i + 1)
            for (c = 0; c < 2; c = c + 1) begin
                check(i[15:0], 16'h0001, c[0]);
                check(i[15:0], ~i[15:0], c[0]);
            end

        // Repeatable random full-width operands and carry-in.
        for (i = 0; i < 10000; i = i + 1) begin
            random_a = $random(seed);
            random_b = $random(seed);
            random_c = $random(seed);
            check(random_a, random_b, random_c);
            check_tree;
        end

        $display("PASS: prefix_black %0d/16 combinations; prefix16 %0d additions; intermediate prefix checks passed.",
                 cells, tests);
        $finish;
    end
endmodule
