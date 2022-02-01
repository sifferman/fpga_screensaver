
module image (
    input               clk,
    input         [9:0] position_x, position_x_NEXT,
    input         [8:0] position_y, position_y_NEXT,
    input        [31:0] frame,
    output reg    [3:0] r, g, b
);

wire color_next = position_x_NEXT[2] ^ position_y_NEXT[2];

always @ (posedge clk) begin
    r <= {4{color_next&frame[1]}};
    g <= {4{color_next&frame[0]}};
    b <= {4{color_next&frame[2]}};
end

endmodule
