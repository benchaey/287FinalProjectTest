module vga_driver_memory (

    //////////// ADC //////////
    //output           ADC_CONVST,
    //output           ADC_DIN,
    //input            ADC_DOUT,
    //output           ADC_SCLK,

    //////////// Audio //////////
    //input            AUD_ADCDAT,
    //inout            AUD_ADCLRCK,
    //inout            AUD_BCLK,
    //output           AUD_DACDAT,
    //inout            AUD_DACLRCK,
    //output           AUD_XCK,

    //////////// CLOCK //////////
    input            CLOCK_50,

    //////////// SEG7 //////////
    output     [6:0] HEX0,
    output     [6:0] HEX1,
    output     [6:0] HEX2,
    output     [6:0] HEX3,

    //////////// KEY //////////
    //input      [3:0] KEY,

    //////////// LED //////////
    output     [9:0] LEDR,

    //////////// SW //////////
    input      [9:0] SW,

    //////////// VGA //////////
    output           VGA_BLANK_N,
    output reg [7:0] VGA_B,
    output           VGA_CLK,
    output reg [7:0] VGA_G,
    output           VGA_HS,
    output reg [7:0] VGA_R,
    output           VGA_SYNC_N,
    output           VGA_VS,

    //////////// SPRITE INPUTS //////////
    input [3:0] player_x,
    input [3:0] player_y,
    input [3:0] player_2x,
    input [3:0] player_2y,
	 input rst

);


/*

Ben's Color Guide:

Sprite(frog) : Green = 24'h00FF00
Car : Red =   24'hFF0000
.
RRGGBB = 24'hxxxxxx
.
background : Blue =  24'h0000FF
*/

// clock divider!!!!
reg clk_div; 

always @ (posedge CLOCK_50 or negedge rst) 
begin 
	if(rst == 1'b0)																	// active high because inverted Key
		clk_div <= 1'b0; 
	else 
		clk_div <= ~clk_div; 
end 

assign VGA_CLK = clk_div; 


  // Turn off all 7 seg displays.
assign HEX0 = 7'h00;
assign HEX1 = 7'h00;
assign HEX2 = 7'h00;
assign HEX3 = 7'h00;

wire active_pixels; // = 1 when in drawing space  | = 0 when not in drawing space meaning: active high

wire [9:0]x; // current x
wire [9:0]y; // current y - 10 bits = 1024 ... a little bit more than we need

wire clk;
//wire rst;

assign clk = CLOCK_50;
//assign rst = KEY[0];

assign LEDR[0] = active_pixels;     									// this means that LEDR[0] will be on if within screen display area / "drawing sspace"            


//grid computation
wire [3:0] grid_x = x / 40; // 16 columns
wire [3:0] grid_y = y / 40; // 12 rows



// car position
reg [3:0] car_x; // this is added from our moving_obstacles instatition (x axis)
reg [3:0] car_y; // this is added from our moving_obstacles instatition (y axis)

// more obstacles added here????

//this whole instantiation right here is correlated witht he vga_driver. This means that this module that wer are currently
//in only cares about the actualy visuals (rgb) rather than any of the sync pulses and porches.

vga_driver the_vga( // instantiation starts here
.clk(VGA_CLK),
.rst(rst),

.hsync(VGA_HS),
.vsync(VGA_VS),

.active_pixels(active_pixels),

.xPixel(x),
.yPixel(y),

.VGA_BLANK_N(VGA_BLANK_N),
.VGA_SYNC_N(VGA_SYNC_N)
); // instantiation ends here



//this is taking pixel color and sending it to VGA DAC pins
// Note: vga_color = our orginal color output so all vairbales are now accounted for here
	always @(*)
	begin
		{VGA_R, VGA_G, VGA_B} = vga_color; // concatenation: [23:16] = red, [15:8] = green, [7:0] = blue ...... 8 bits each
	end


reg [23:0] vga_color;



// this is game_display.
	always @ (*)
	begin
		vga_color = 24'hFFFFFF; 						// the deault is white when not in display area
		if(rst == 1'b0) begin															
			vga_color = 24'hAACCFF; 					// this sets the background = pastel blue  no matter what's showing up (obstacle wise)
	end
	else begin
		if(active_pixels == 1'b1) 						// if within visible area:
		begin
			vga_color = 24'hAACCFF; 					// pastel blue
			if(grid_x == player_x && grid_y == player_y)
			begin
				vga_color = 24'h00FF00; 				// sprite 1 = green
			end
			else
			if(grid_x == player_2x && grid_y == player_2y)
			begin
				vga_color = 24'hC0C0C0; 				// sprite 2 = light gray
			end
			else
			if(grid_x == car_x && grid_y == car_y)
			begin
				vga_color = 24'h800080;				 // car = magenta :)
			end
			end else begin 								// when not active pixels,
				vga_color = 24'hFFFFFF;					 //keep default (white)
		end
	end
end




endmodule