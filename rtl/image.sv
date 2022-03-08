
module image #(
    parameter SELECT = 0
) (
    input               clk,
    input logic   [9:0] position_x, position_x_NEXT,
    input logic   [8:0] position_y, position_y_NEXT,
    input        [31:0] frame,
    output logic  [3:0] r, g, b
);

generate
// ==== Checkerboard ====
if (SELECT == 0) begin : checkerboard
//

wire color_next = position_x_NEXT[2] ^ position_y_NEXT[2];

always @ (posedge clk) begin
    r <= {4{color_next&frame[1]}};
    g <= {4{color_next&frame[0]}};
    b <= {4{color_next&frame[2]}};
end

//
end
// ==== Fractal ====
if (SELECT == 1) begin : fractal
//

wire valid_NEXT = (10'd64 <= position_x_NEXT) && (position_x_NEXT < 10'd576);

wire [8:0] shifted_x_NEXT = valid_NEXT ? 9'(position_x_NEXT - 10'd64) : {9{1'bx}};
wire [8:0] shifted_y_NEXT = valid_NEXT ? 9'(position_y_NEXT +  9'd16) : {9{1'bx}};

logic color_NEXT;
logic [3:0] r_NEXT, g_NEXT, b_NEXT;
integer i;
always_comb begin
    color_NEXT = 1'b1;
    for (i = 8; i >= 1; i=i-2) begin
        color_NEXT = color_NEXT & ((shifted_x_NEXT[i]!=shifted_x_NEXT[i-1]) || (shifted_y_NEXT[i]!=shifted_y_NEXT[i-1]));
    end
    r_NEXT = valid_NEXT?{4{color_NEXT}}:4'b0;
    g_NEXT = valid_NEXT?{4{color_NEXT}}:4'b0;
    b_NEXT = valid_NEXT?{4{color_NEXT}}:4'b0;
end

always_ff @ (posedge clk) begin
    r <= r_NEXT;
    g <= g_NEXT;
    b <= b_NEXT;
end
end

//
end
//
endgenerate

endmodule
