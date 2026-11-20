// Lab 8 - 256 x 8 RAM with access from two independent clock domains.
// Port A reads/writes each clk1 edge. Port B submits a transaction on a
// clk2 edge with request2 && ready2. Its response arrives with valid2.
// A toggle handshake transfers held address/data and response buses.
// Both memory accesses execute on clk1, making collision arbitration safe.
module ram_dual_two_clocks (
    input  wire       clk1,
    input  wire       clk2,
    input  wire       we1,
    input  wire       we2,
    input  wire [7:0] a1,
    input  wire [7:0] a2,
    input  wire [7:0] d1,
    input  wire [7:0] d2,
    input  wire       request2,
    output reg  [7:0] q1,
    output reg  [7:0] q2,
    output wire       ready2,
    output reg        valid2 = 0,
    output reg        collision2 = 0
);
    reg [7:0] mem [0:255];

    // These request fields stay unchanged until the response is acknowledged.
    reg [7:0] b_address = 0, b_data = 0;
    reg b_write = 0;
    reg request_toggle = 0;
    reg acknowledge_toggle = 0;
    (* ASYNC_REG = "TRUE" *) reg request_meta = 0, request_sync = 0;
    (* ASYNC_REG = "TRUE" *) reg acknowledge_meta = 0, acknowledge_sync = 0;
    reg response_seen = 0;
    reg [7:0] response_data = 0;
    reg response_collision = 0;

    assign ready2 = request_toggle == acknowledge_sync;
    wire service_b = request_sync != acknowledge_toggle;
    wire write_collision = we1 && b_write && (a1 == b_address);

    always @(posedge clk1) begin
        request_meta <= request_toggle;
        request_sync <= request_meta;

        q1 <= mem[a1];
        if (we1)
            mem[a1] <= d1;
    end

    always @(posedge clk1) begin
        if (service_b) begin
            // Nonblocking assignments give both ports the pre-write value.
            response_data <= mem[b_address];
            response_collision <= write_collision;
            if (b_write && !write_collision)
                mem[b_address] <= b_data;
            acknowledge_toggle <= request_sync;
        end
    end

    always @(posedge clk2) begin
        acknowledge_meta <= acknowledge_toggle;
        acknowledge_sync <= acknowledge_meta;
        valid2 <= 0;

        if (request2 && ready2) begin
            b_address <= a2;
            b_data <= d2;
            b_write <= we2;
            request_toggle <= ~request_toggle;
        end

        if (acknowledge_sync != response_seen) begin
            q2 <= response_data;
            collision2 <= response_collision;
            valid2 <= 1;
            response_seen <= acknowledge_sync;
        end
    end
endmodule
