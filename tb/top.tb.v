
`timescale 1s/1ms

module tb ();

reg clk = 1;
always #(0.5) clk <= ~clk;

reg rst = 0;

wire hsync;
wire vsync;
wire visible;
wire [3:0] r, g, b;

top t(
    .clk(clk),
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

for (integer i = 0; i < 8; i=i+1)
    @(negedge vsync);

//\\ =========================== \\//
$display( "End simulation.");
$finish;
end

endmodule
