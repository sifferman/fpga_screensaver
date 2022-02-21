
module tangnano #(
    parameter IMAGE_SELECT = 0
) (
    input               clk_24,
    input               An, Bn,
    output logic        hsync, vsync,
    output logic  [3:0] r, g, b
);


logic rst = ~An;
logic clk_25_175;


// Waiting for PLLs to be supported by Apicula
// Gowin_rPLL pll ( .clkoutd(clk_25_175), .clkin(clk_24) );
assign clk_25_175 = clk_24; // close


top #(IMAGE_SELECT) t (.*);


endmodule
