
module tangnano #(
    parameter IMAGE_SELECT = 0
) (
    input               clk_24,
    input               An, Bn,
    output logic        hsync, vsync,
    output logic  [3:0] r, g, b
);


wire rst = ~An;
logic clk_25_175;

// PLL to convert 24MHz to 25.175MHz
Gowin_rPLL pll ( .clkoutd(clk_25_175), .clkin(clk_24) );
top #(IMAGE_SELECT) t (.*);

endmodule
