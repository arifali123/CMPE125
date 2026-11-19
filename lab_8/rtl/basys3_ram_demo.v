// Board controls and LED assignments are documented in notes/README.md.
module basys3_ram_demo #(
    parameter integer DEBOUNCE_CYCLES = 1_000_000  // 10 ms at 100 MHz
) (
    input  wire        clk,
    input  wire [15:0] sw,
    input  wire        btnC,
    input  wire        btnU,
    input  wire        btnL,
    input  wire        btnD,
    output wire [15:0] led
);
    wire [3:0] buttons = {btnD, btnL, btnU, btnC};
    (* ASYNC_REG = "TRUE" *) reg [3:0] button_meta = 0, button_sync = 0;
    (* ASYNC_REG = "TRUE" *) reg [15:0] switch_meta = 0, switch_sync = 0;
    always @(posedge clk) begin
        button_meta <= buttons;
        button_sync <= button_meta;
        switch_meta <= sw;
        switch_sync <= switch_meta;
    end

    // Require a stable input on both press and release. Each accepted
    // press produces one clock of enable even if the button stays held.
    localparam integer COUNT_WIDTH = (DEBOUNCE_CYCLES < 2) ? 1 : $clog2(DEBOUNCE_CYCLES);
    localparam [COUNT_WIDTH-1:0] TERMINAL_COUNT = DEBOUNCE_CYCLES - 1;
    wire [3:0] pressed, held;
    genvar button;
    generate
        for (button = 0; button < 4; button = button + 1) begin : debounce
            reg stable = 0;
            reg [COUNT_WIDTH-1:0] count = 0;
            wire accept_change = count == TERMINAL_COUNT && button_sync[button] != stable;

            always @(posedge clk) begin
                if (button_sync[button] == stable || accept_change)
                    count <= 0;
                else
                    count <= count + 1'b1;

                if (accept_change)
                    stable <= button_sync[button];
            end

            assign held[button] = stable;
            assign pressed[button] = accept_change && button_sync[button];
        end
    endgenerate

    localparam [1:0] SINGLE = 0, TWO_CLOCK = 1, TRUE_DUAL = 2;
    reg [1:0] mode = SINGLE;
    reg port_b = 0;
    wire reset_selection = pressed[3] | held[3];

    always @(posedge clk) begin
        if (reset_selection) begin
            mode <= SINGLE;
            port_b <= 0;
        end else if (pressed[1]) begin
            if (mode == TRUE_DUAL) begin
                mode <= SINGLE;
                port_b <= 0;
            end else begin
                mode <= mode + 1'b1;
            end
        end else if (pressed[2] && mode != SINGLE) begin
            port_b <= ~port_b;
        end
    end

    wire [6:0] address = switch_sync[6:0];
    wire [7:0] write_data = switch_sync[14:7];
    wire write_request = switch_sync[15] && pressed[0] &&
                         !(reset_selection || pressed[1] || pressed[2]);
    wire write_single = write_request && mode == SINGLE;
    wire write_two_a  = write_request && mode == TWO_CLOCK && !port_b;
    wire write_two_b  = write_request && mode == TWO_CLOCK && port_b;
    wire write_true_a = write_request && mode == TRUE_DUAL && !port_b;
    wire write_true_b = write_request && mode == TRUE_DUAL && port_b;

    // Send the other port to a different address during a write to
    // avoid a mixed-port read/write collision in the inferred block RAM.
    wire [6:0] other_address = address ^ 7'b1000000;
    wire [7:0] q_single, q_two_a, q_two_b, q_true_a, q_true_b;
    ram_single single_ram (
        .clk(clk), .we(write_single), .a(address), .d(write_data), .q(q_single)
    );
    // The board demo uses one system clock. The dedicated testbench
    // exercises clk1 and clk2 independently.
    ram_dual_two_clocks two_clock_ram (
        .clk1(clk), .clk2(clk),
        .we1(write_two_a), .we2(write_two_b),
        .a1(write_two_b ? other_address : address),
        .a2(write_two_a ? other_address : address),
        .d1(write_data), .d2(write_data),
        .q1(q_two_a), .q2(q_two_b)
    );
    ram_true_dual_port true_dual_ram (
        .clk(clk), .we1(write_true_a), .we2(write_true_b),
        .a1(write_true_b ? other_address : address),
        .a2(write_true_a ? other_address : address),
        .d1(write_data), .d2(write_data),
        .q1(q_true_a), .q2(q_true_b)
    );

    assign led[7:0] = (mode == SINGLE) ? q_single :
                      (mode == TWO_CLOCK) ? (port_b ? q_two_b : q_two_a) :
                                            (port_b ? q_true_b : q_true_a);
    assign led[9:8] = mode;
    assign led[10] = port_b;
    assign led[14:11] = 4'b0000;
    assign led[15] = switch_sync[15];
endmodule
