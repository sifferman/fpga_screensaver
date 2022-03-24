
`timescale 1s/1ms

module top_tb #(
    parameter IMAGE_SELECT = 0
) ();

logic clk = 1;
always #(0.5) clk <= ~clk;

logic rst = 0;

logic hsync;
logic vsync;
logic visible;
logic [3:0] r, g, b;

top #(IMAGE_SELECT) t (
    .clk_25_175(clk),
    .rst(rst),
    .hsync(hsync),
    .vsync(vsync),
    .r(r), .g(g), .b(b)
);

initial begin : sim
$timeformat( 0, 0, "", 0);
$dumpfile( "dump.fst" );
$dumpvars;
$display( "Begin simulation.");
//\\ =========================== \\//

rst = 1;
#4
rst = 0;

// ==== Checkerboard ====
if (IMAGE_SELECT == 0) begin
//

for (integer i = 0; i < 8; i=i+1)
    @(negedge vsync);

//
end
// ==== Fractal ====
if (IMAGE_SELECT == 1) begin
//

@(negedge vsync);

//
end

//\\ =========================== \\//
$display( "End simulation.");
$finish;
end

endmodule
