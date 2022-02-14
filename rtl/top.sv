
module top #(
    parameter IMAGE_SELECT = 0
) (
    input               clk, rst,
    output wire         hsync, vsync,
    output wire   [3:0] r, g, b
);

wire visible;
wire [9:0] position_x, position_x_NEXT;
wire [8:0] position_y, position_y_NEXT;
wire [3:0] im_r, im_g, im_b;
wire [31:0] frame;

assign r = visible ? im_r : 0;
assign g = visible ? im_g : 0;
assign b = visible ? im_b : 0;

video_timer #(
    .H_FRONT(16),
    .H_VISIBLE(640),
    .H_SYNC(96),
    .H_BACK(48),
    .V_FRONT(10),
    .V_VISIBLE(480),
    .V_SYNC(2),
    .V_BACK(33)
) vt (
    clk, rst,
    hsync, vsync,
    visible,
    position_x, position_x_NEXT,
    position_y, position_y_NEXT,
    frame
);

image #(IMAGE_SELECT) im (
    clk,
    position_x, position_x_NEXT,
    position_y, position_y_NEXT,
    frame,
    im_r, im_g, im_b
);

`ifdef SIM

integer f = $fopen("image.txt");
always @ (negedge clk)      $fwrite(f, "%h%h0%h0%h0 ", (visible?8'hff:8'h00), b, g, r);
always @ (posedge hsync)    $fwrite(f, "\n");

`endif

endmodule
