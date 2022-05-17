
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
// ==== Bouncing Box ====
if (SELECT == 2) begin : box
//

`define SIGNED_CLAMP(MIN,T,MAX)     (($signed(MIN) > $signed(T)) ? (MIN) : ($signed(MAX) < $signed(T)) ? (MAX) : (T))

localparam BOX_HEIGHT   = 100;
localparam BOX_WIDTH    = 100;

logic  [$clog2(SCREEN_WIDTH):0] box_x, box_xv, box_x_next, box_xv_next, box_x_trajectory;
logic [$clog2(SCREEN_HEIGHT):0] box_y, box_yv, box_y_next, box_yv_next, box_y_trajectory;

/* verilator lint_off WIDTH */

wire hit_v_edge = ($signed(box_x_trajectory) < 0) || ($signed(box_x_trajectory) >= (SCREEN_WIDTH-BOX_WIDTH));
wire hit_h_edge = ($signed(box_y_trajectory) < 0) || ($signed(box_y_trajectory) >= (SCREEN_HEIGHT-BOX_HEIGHT));

assign box_x_trajectory = box_x + box_xv;
assign box_y_trajectory = box_y + box_yv;
assign box_x_next = `SIGNED_CLAMP(0, box_x_trajectory, (SCREEN_WIDTH-BOX_WIDTH));
assign box_y_next = `SIGNED_CLAMP(0, box_y_trajectory, (SCREEN_HEIGHT-BOX_HEIGHT));
assign box_xv_next = hit_v_edge ? ((~box_xv)+1) : box_xv;
assign box_yv_next = hit_h_edge ? ((~box_yv)+1) : box_yv;

wire in_box =
    ($signed(box_x) <= $unsigned(position_x) && $unsigned(position_x) < ($signed(box_x)+BOX_WIDTH))
    && ($signed(box_y) <= $unsigned(position_y) && $unsigned(position_y) < ($signed(box_y)+BOX_HEIGHT));

/* verilator lint_on WIDTH */


wire [3:0] lightness = {{3{in_box}}, 1'b1};
logic [2:0] color, color_next;
assign color_next =
    !(hit_v_edge||hit_h_edge)   ?   color   :
    (color==3'b111)             ?   3'b001  :
    (color + 1);

assign r = lightness & {4{color[0]}};
assign g = lightness & {4{color[1]}};
assign b = lightness & {4{color[2]}};

logic [31:0] frame_prev;

always_ff @ (posedge clk) begin
    if (rst) begin
        box_x <= 50;
        box_y <= 50;
        box_xv <= 2;
        box_yv <= 1;
        frame_prev <= 0;
        color <= 3'b111;
    end else if (frame_prev != frame) begin
        box_x <= box_x_next;
        box_y <= box_y_next;
        box_xv <= box_xv_next;
        box_yv <= box_yv_next;
        frame_prev <= frame;
        color <= color_next;
    end
end

`undef SIGNED_CLAMP

//
end
//
endgenerate

endmodule
