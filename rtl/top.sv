
module top #(
    parameter IMAGE_SELECT = 0
) (
    input               clk_25_175, rst,
    output logic        hsync, vsync,
    output logic  [3:0] r, g, b
);

logic visible;
logic [9:0] position_x, position_x_NEXT;
logic [8:0] position_y, position_y_NEXT;
logic [3:0] im_r, im_g, im_b;
logic [31:0] frame;

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
    clk_25_175, rst,
    hsync, vsync,
    visible,
    position_x, position_x_NEXT,
    position_y, position_y_NEXT,
    frame
);

image #(IMAGE_SELECT) im (
    clk_25_175, rst,
    position_x, position_x_NEXT,
    position_y, position_y_NEXT,
    frame,
    im_r, im_g, im_b
);


// vga png generation
`ifdef SIM

integer f;
initial f = $fopen("image.txt");
// at every clock pulse, print the color
always @ (negedge clk_25_175)   $fwrite(f, "%h%h0%h0%h0 ", (visible?8'hff:8'h00), b, g, r);
// at the end of every hsync, print a line break
always @ (posedge hsync)        $fwrite(f, "\n");

`endif

endmodule
