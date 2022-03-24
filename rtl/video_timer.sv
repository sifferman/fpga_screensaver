
// http://tinyvga.com/vga-timing
module video_timer #(
    parameter H_VISIBLE = 640,
    parameter H_FRONT   = 16,
    parameter H_SYNC    = 96,
    parameter H_BACK    = 48,
    parameter V_VISIBLE = 480,
    parameter V_FRONT   = 10,
    parameter V_SYNC    = 2,
    parameter V_BACK    = 33
) (
    input                                   clk, rst,
    output logic                            hsync, vsync,
    output logic                            visible,
    output logic    [$clog2(H_VISIBLE)-1:0] position_x, position_x_NEXT,
    output logic    [$clog2(V_VISIBLE)-1:0] position_y, position_y_NEXT,
    output logic                     [31:0] frame
);

    localparam WHOLE_LINE   = (H_VISIBLE + H_FRONT + H_SYNC + H_BACK);
    localparam WHOLE_FRAME  = (V_VISIBLE + V_FRONT + V_SYNC + V_BACK);

    logic [$clog2(WHOLE_LINE)-1:0] x_counter, x_counter_NEXT;
    logic [$clog2(WHOLE_FRAME)-1:0] y_counter, y_counter_NEXT;

    logic hvisible, vvisible;

    assign visible = hvisible & vvisible;

    assign hvisible = (x_counter < (H_VISIBLE)) && !rst;
    assign hsync = ~( ((H_VISIBLE+H_FRONT) <= x_counter) && (x_counter < (H_VISIBLE+H_FRONT+H_SYNC)) && !rst );

    assign vvisible = (y_counter < (V_VISIBLE)) && !rst;
    assign vsync = ~( ((V_VISIBLE+V_FRONT) <= y_counter) && (y_counter < (V_VISIBLE+V_FRONT+V_SYNC)) && !rst );

    assign position_x_NEXT = $clog2(H_VISIBLE)'(x_counter_NEXT);
    assign position_y_NEXT = $clog2(V_VISIBLE)'(y_counter_NEXT);

    assign x_counter_NEXT =
        ( x_counter == (H_VISIBLE+H_FRONT+H_SYNC+H_BACK-1) ) ? 0  :
        x_counter + 1;

    assign y_counter_NEXT =
        ( x_counter != (H_VISIBLE+H_FRONT+H_SYNC+H_BACK-1) ) ? y_counter    :
        ( y_counter == (V_VISIBLE+V_FRONT+V_SYNC+V_BACK-1) ) ? 0            :
        y_counter + 1;

    logic [31:0] frame_NEXT =
        ( y_counter != 0 && y_counter_NEXT == 0 ) ? frame+1 :
        frame;

    always_ff @ ( posedge clk ) begin
        if ( rst ) begin
            x_counter <= (H_VISIBLE+H_FRONT+H_SYNC);
            y_counter <= (V_VISIBLE+V_FRONT+V_SYNC);
            frame <= 0;
            position_x <= 0;
            position_y <= 0;
        end else begin
            x_counter <= x_counter_NEXT;
            y_counter <= y_counter_NEXT;
            frame <= frame_NEXT;
            position_x <= position_x_NEXT;
            position_y <= position_y_NEXT;
        end

        `ifdef SIM
        if (frame != frame_NEXT)
            $display( "Next frame: [Clk Pulse=%0t]", $realtime );
        `endif
    end

endmodule
