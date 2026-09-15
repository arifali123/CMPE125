`timescale 1ns / 1ps

module full_adder_tb;
    reg A;
    reg B;
    reg Cin;
    wire Cout;
    wire S;
    integer i;
    reg [1:0] expected;

    full_adder uut (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Cout(Cout),
        .S(S)
    );

    initial begin
        // Match the classroom order: A toggles fastest, then B, then Cin.
        // Each of the eight input combinations is held for 10 ns.
        for (i = 0; i < 8; i = i + 1) begin
            {Cin, B, A} = i[2:0];
            expected = {1'b0, A} + {1'b0, B} + {1'b0, Cin};
            #1; // Let the combinational outputs settle before checking.
            if ({Cout, S} !== expected) begin
                $fatal(1, "FAIL: A=%b B=%b Cin=%b expected Cout,S=%b, got %b%b",
                       A, B, Cin, expected, Cout, S);
            end
            $display("PASS: A=%b B=%b Cin=%b -> Cout=%b S=%b",
                     A, B, Cin, Cout, S);
            #9;
        end
        $display("PASS: All eight full-adder states verified.");
        $finish;
    end
endmodule
