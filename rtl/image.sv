
module image #(
    parameter SELECT        = 0,
    parameter SCREEN_WIDTH  = 640,
    parameter SCREEN_HEIGHT = 480
) (
    input                               clk, rst,
    input    [$clog2(SCREEN_WIDTH)-1:0] position_x, position_x_next,
    input   [$clog2(SCREEN_HEIGHT)-1:0] position_y, position_y_next,
    input                        [31:0] frame,
    output logic                  [3:0] r, g, b
);

generate
// ==== Checkerboard ====
if (SELECT == 0) begin : checkerboard
//

wire color_next = position_x_next[6] ^ position_y_next[6];

always_ff @ (posedge clk) begin
    r <= {4{color_next&frame[1]}};
    g <= {4{color_next&frame[0]}};
    b <= {4{color_next&frame[2]}};
end

//
end
// ==== Fractal ====
if (SELECT == 1) begin : fractal
//

wire valid_next = (10'd64 <= position_x_next) && (position_x_next < 10'd576);

wire [8:0] shifted_x_next = valid_next ? 9'(position_x_next - 10'd64) : {9{1'bx}};
wire [8:0] shifted_y_next = valid_next ? 9'(position_y_next +  9'd16) : {9{1'bx}};

logic color_next;
logic [3:0] r_next, g_next, b_next;
integer i;
always_comb begin
    color_next = 1'b1;
    for (i = 8; i >= 1; i=i-2) begin
        color_next = color_next & ((shifted_x_next[i]!=shifted_x_next[i-1]) || (shifted_y_next[i]!=shifted_y_next[i-1]));
    end
    r_next = valid_next?{4{color_next}}:4'b0;
    g_next = valid_next?{4{color_next}}:4'b0;
    b_next = valid_next?{4{color_next}}:4'b0;
end

always_ff @ (posedge clk) begin
    r <= r_next;
    g <= g_next;
    b <= b_next;
end

//
end
//
endgenerate

endmodule
