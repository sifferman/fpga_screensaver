
// http://tinyvga.com/vga-timing
module video_timer #(
    parameter H_FRONT   = 16,
    parameter H_VISIBLE = 640,
    parameter H_SYNC    = 96,
    parameter H_BACK    = 48,
    parameter V_FRONT   = 10,
    parameter V_VISIBLE = 480,
    parameter V_SYNC    = 2,
    parameter V_BACK    = 33
) (
    input                               clk, rst,
    output wire                         hsync, vsync,
    output wire                         visible,
    output wire [$clog2(H_VISIBLE)-1:0] position_x, position_x_NEXT,
    output wire [$clog2(V_VISIBLE)-1:0] position_y, position_y_NEXT,
    output reg                   [31:0] frame
);

    localparam WHOLE_LINE   = (H_VISIBLE + H_FRONT + H_SYNC + H_BACK);
    localparam WHOLE_FRAME  = (V_VISIBLE + V_FRONT + V_SYNC + V_BACK);

    reg [$clog2(WHOLE_LINE)-1:0] x_counter, x_counter_NEXT;
    reg [$clog2(WHOLE_FRAME)-1:0] y_counter, y_counter_NEXT;

    reg hstate_front, hstate_front_NEXT;
    reg hstate_visible, hstate_visible_NEXT;
    reg hstate_sync, hstate_sync_NEXT;
    reg hstate_back, hstate_back_NEXT;

    reg vstate_front, vstate_front_NEXT;
    reg vstate_visible, vstate_visible_NEXT;
    reg vstate_sync, vstate_sync_NEXT;
    reg vstate_back, vstate_back_NEXT;

    reg [31:0] frame_NEXT;

    assign hsync = ~hstate_sync;
    assign vsync = ~vstate_sync;

    assign visible = (hstate_visible && vstate_visible);
    wire visible_NEXT = (hstate_visible_NEXT && vstate_visible_NEXT);

    assign position_x = visible ? x_counter : {$clog2(H_VISIBLE){1'bx}};
    assign position_y = visible ? y_counter : {$clog2(V_VISIBLE){1'bx}};
    assign position_x_NEXT = visible_NEXT ? x_counter_NEXT : {$clog2(H_VISIBLE){1'bx}};
    assign position_y_NEXT = visible_NEXT ? y_counter_NEXT : {$clog2(V_VISIBLE){1'bx}};

    initial begin
        x_counter       = 0;
        y_counter       = 0;

        hstate_front    = 1;
        hstate_visible  = 0;
        hstate_sync     = 0;
        hstate_back     = 0;

        vstate_front    = 1;
        vstate_visible  = 0;
        vstate_sync     = 0;
        vstate_back     = 0;

        frame           = 0;
    end

    generate if (
           !H_FRONT
        || !H_VISIBLE
        || !H_SYNC
        || !H_BACK
        || !V_FRONT
        || !V_VISIBLE
        || !V_SYNC
        || !V_BACK
    ) initial begin
        $error("Parameters not supported.");
    end endgenerate

    always_comb begin
        if (rst) begin
            x_counter_NEXT      = 0;
            hstate_front_NEXT   = 1;
            hstate_visible_NEXT = 0;
            hstate_sync_NEXT    = 0;
            hstate_back_NEXT    = 0;
        end else if ((hstate_front) && (x_counter == (H_FRONT-1))) begin
            x_counter_NEXT      = 0;
            hstate_front_NEXT   = 0;
            hstate_visible_NEXT = 1;
            hstate_sync_NEXT    = 0;
            hstate_back_NEXT    = 0;
        end else if ((hstate_visible) && (x_counter == (H_VISIBLE-1))) begin
            x_counter_NEXT      = 0;
            hstate_front_NEXT   = 0;
            hstate_visible_NEXT = 0;
            hstate_sync_NEXT    = 1;
            hstate_back_NEXT    = 0;
        end else if ((hstate_sync) && (x_counter == (H_SYNC-1))) begin
            x_counter_NEXT      = 0;
            hstate_front_NEXT   = 0;
            hstate_visible_NEXT = 0;
            hstate_sync_NEXT    = 0;
            hstate_back_NEXT    = 1;
        end else if ((hstate_back) && (x_counter == (H_BACK-1))) begin
            x_counter_NEXT      = 0;
            hstate_front_NEXT   = 1;
            hstate_visible_NEXT = 0;
            hstate_sync_NEXT    = 0;
            hstate_back_NEXT    = 0;
        end else begin
            x_counter_NEXT      = x_counter+1;
            hstate_front_NEXT   = hstate_front;
            hstate_visible_NEXT = hstate_visible;
            hstate_sync_NEXT    = hstate_sync;
            hstate_back_NEXT    = hstate_back;
        end
    end

    always_comb begin
        if (rst) begin
            y_counter_NEXT      = 0;
            vstate_front_NEXT   = 1;
            vstate_visible_NEXT = 0;
            vstate_sync_NEXT    = 0;
            vstate_back_NEXT    = 0;
            frame_NEXT          = 0;
        end else if ((x_counter_NEXT!=0) || (!hstate_front_NEXT)) begin
            y_counter_NEXT      = y_counter;
            vstate_front_NEXT   = vstate_front;
            vstate_visible_NEXT = vstate_visible;
            vstate_sync_NEXT    = vstate_sync;
            vstate_back_NEXT    = vstate_back;
            frame_NEXT          = frame;
        end else if ((vstate_front) && (y_counter == (V_FRONT-1))) begin
            y_counter_NEXT      = 0;
            vstate_front_NEXT   = 0;
            vstate_visible_NEXT = 1;
            vstate_sync_NEXT    = 0;
            vstate_back_NEXT    = 0;
            frame_NEXT          = frame;
        end else if ((vstate_visible) && (y_counter == (V_VISIBLE-1))) begin
            y_counter_NEXT      = 0;
            vstate_front_NEXT   = 0;
            vstate_visible_NEXT = 0;
            vstate_sync_NEXT    = 1;
            vstate_back_NEXT    = 0;
            frame_NEXT          = frame;
        end else if ((vstate_sync) && (y_counter == (V_SYNC-1))) begin
            y_counter_NEXT      = 0;
            vstate_front_NEXT   = 0;
            vstate_visible_NEXT = 0;
            vstate_sync_NEXT    = 0;
            vstate_back_NEXT    = 1;
            frame_NEXT          = frame;
        end else if ((vstate_back) && (y_counter == (V_BACK-1))) begin
            y_counter_NEXT      = 0;
            vstate_front_NEXT   = 1;
            vstate_visible_NEXT = 0;
            vstate_sync_NEXT    = 0;
            vstate_back_NEXT    = 0;
            frame_NEXT          = frame+1;
        end else begin
            y_counter_NEXT      = y_counter+1;
            vstate_front_NEXT   = vstate_front;
            vstate_visible_NEXT = vstate_visible;
            vstate_sync_NEXT    = vstate_sync;
            vstate_back_NEXT    = vstate_back;
            frame_NEXT          = frame;
        end
    end

    always @ (posedge clk) begin
        x_counter <= x_counter_NEXT;
        hstate_front <= hstate_front_NEXT;
        hstate_visible <= hstate_visible_NEXT;
        hstate_sync <= hstate_sync_NEXT;
        hstate_back <= hstate_back_NEXT;

        y_counter <= y_counter_NEXT;
        vstate_front <= vstate_front_NEXT;
        vstate_visible <= vstate_visible_NEXT;
        vstate_sync <= vstate_sync_NEXT;
        vstate_back <= vstate_back_NEXT;

        frame <= frame_NEXT;
    end

endmodule
