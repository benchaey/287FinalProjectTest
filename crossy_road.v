module crossy_road(input CLOCK_50, 
							input[9:0]SW,
							//input [3:0]KEY,
							input ps2_clk, 
							input ps2_data, 
							output [7:0]VGA_R, 
							output [7:0]VGA_G, 
							output [7:0]VGA_B, 
							output VGA_HS, 
							output VGA_VS, 
							output VGA_BLANK_N, 
							output VGA_SYNC_N,
							output VGA_CLK,									// added from KC 
							output [9:0]LEDR); 

	wire [7:0]scan_code; 
	wire scan_ready; 
	
	wire move_up; 
	wire move_down; 
	wire move_left;
	wire move_right; 
	
	wire [3:0]player_x;
	wire [3:0]player_y; 
	wire [3:0]player_2x; 
	wire [3:0]player_2y; 
	
	// Claude suggestion... 
	wire clk; 
	wire rst;
	assign clk = CLOCK_50; 
	assign rst = SW[0]; 													// clean reset signal... sets as active low!!! 
							

// vga driver memory module instantiation 
vga_driver_memory vga_mem(.CLOCK_50(CLOCK_50), 
									.rst(rst),
									.SW(SW), 
									//.KEY(KEY),
									.player_x(player_x), 
									.player_y(player_y), 
									.player_2x(player_2x), 
									.player_2y(player_2y), 
									.VGA_R(VGA_R), 
									.VGA_G(VGA_G), 
									.VGA_B(VGA_B), 
									.VGA_HS(VGA_HS), 
									.VGA_VS(VGA_VS),
									.VGA_BLANK_N(VGA_BLANK_N),
									.VGA_SYNC_N(VGA_SYNC_N),
									.VGA_CLK(VGA_CLK),					// added from KC
									.LEDR(LEDR));							// Claude added LEDR

//ps2 controller module instatiation 
ps2_controller signals(.clk(clk), 
								.rst(rst), 
								.ps2_clk(ps2_clk), 
								.ps2_data(ps2_data), 
								.scan_code(scan_code), 
								.scan_ready(scan_ready)); 

//keyboard module instantiation 
keyboard translation(.clk(clk), 
							.rst(rst), 
							.scan_code(scan_code), 
							.scan_ready(scan_ready), 
							.move_up(move_up), 
							.move_down(move_down), 
							.move_left(move_left), 
							.move_right(move_right)); 
							


// movement module instatiation ... sprite 1 
movement #(.START_X(4'd11), 
					.START_Y(4'd7))

sprite1_move(.clk(clk),
					.rst(rst), 
					.move_up(move_up),
					.move_down(move_down), 
					.move_left(move_left),
					.move_right(move_right),
					.player_x(player_x),
					.player_y(player_y));

// movement module instatiation ... sprite 2 
movement #(.START_X(4'd11), 
					.START_Y(4'd8)) 

sprite2_move(.clk(clk),
					.rst(rst), 
					.move_up(move_up),
					.move_down(move_down), 
					.move_left(move_left),
					.move_right(move_right),
					.player_x(player_2x),
					.player_y(player_2y));
					
					
endmodule 

