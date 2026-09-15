// Two-way light controller from the Lab 1 handout.
module light (
    input wire x1,
    input wire x2,
    output wire f
);
    assign f = (x1 & ~x2) | (~x1 & x2);
endmodule
