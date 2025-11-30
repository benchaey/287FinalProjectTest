module vga_driver(
    input clk,
    input rst,
    
    output vga_clk,
    output reg hsync,
    output reg vsync,
    output reg active_pixels,
    output reg [9:0]xPixel,
    output reg [9:0]yPixel,
    output reg VGA_BLANK_N,
    output reg VGA_SYNC_N
);

// Horizontal timings (640x480 @ 60Hz)
parameter HA_END = 10'd639;
parameter HS_STA = 10'd656;
parameter HS_END = 10'd752;
parameter WIDTH  = 10'd799;

// Vertical timings
parameter VA_END = 10'd479;
parameter VS_STA = 10'd490;
parameter VS_END = 10'd492;
parameter HEIGHT = 10'd524;

// Clock divider - create 25MHz from 50MHz
reg pix_clk;

always @(posedge clk or negedge rst) begin
    if (rst == 1'b0)																
        pix_clk <= 1'b0;
    else
        pix_clk <= ~pix_clk;													// divides 50MHzz --> 25MHz
end

assign vga_clk = pix_clk;

// Pixel counters - use SYNCHRONOUS reset
always @(posedge pix_clk) begin
    if (rst == 1'b0) begin														
        xPixel <= 10'd0;
        yPixel <= 10'd0;
    end
    else begin
        if (xPixel == WIDTH) begin
            xPixel <= 10'd0;
            if (yPixel == HEIGHT)
                yPixel <= 10'd0;
            else
                yPixel <= yPixel + 1'b1;
        end
        else begin
            xPixel <= xPixel + 1'b1;
        end
    end
end

// Sync and blanking signals
always @(*) begin
    hsync = ~((xPixel >= HS_STA) && (xPixel < HS_END));
    vsync = ~((yPixel >= VS_STA) && (yPixel < VS_END));
    active_pixels = (xPixel <= HA_END) && (yPixel <= VA_END);
    VGA_BLANK_N = active_pixels;
    VGA_SYNC_N = 1'b1;
end

endmodule