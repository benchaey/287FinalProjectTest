// this file is meant to recieve and process what the keys pressed mean, and then send to movement.v to move the sprite(s). 
// this is the next step after ps2_controller. 
// Flow State: ps2_controller --> keyboard --> movement 

module keyboard(input clk,
						input rst, 
						input [7:0]scan_code, 					// from ps2_controller
						input scan_ready, 						// from ps2_controller 
						output reg move_up, 						// outputs get sent to movement 
						output reg move_down, 
						output reg move_left, 
						output reg move_right); 
						
// PS2 Break Code. 												// note everything here is 8 bits because we are RECEIVING 8 bits
// Why hexidecimal? because its easily readable and prevents typos in bits 
	localparam BREAK_CODE = 8'hF0; 
	
// PS2 Scan Codes for WASD & [arrows] 
	localparam SCAN_W = 8'h1D; 
	localparam SCAN_A = 8'h1C; 
	localparam SCAN_S = 8'h1B; 
	localparam SCAN_D = 8'h23; 
	
	localparam SCAN_UP = 8'h75;
	localparam SCAN_DOWN = 8'h72;
	localparam SCAN_LEFT = 8'h6B;
	localparam SCAN_RIGHT = 8'h74; 		
	
	reg break_active = 0; 										// remembers if prev code scan was BREAK_CODE
	
	
	always @ (posedge clk or negedge rst)
		begin 
		if(rst == 1'b0)														// changed to active high in top module 
		begin 
			break_active <= 0; 
			move_up <= 0; 
			move_down <= 0; 
			move_left <= 0; 
			move_right <= 0; 
		end 
		else begin 
			move_up <= 0; 
			move_down <= 0; 
			move_left <= 0; 
			move_right <= 0; 
			
			if(scan_ready == 1)
			begin 
				if(scan_code == BREAK_CODE)
				begin 
					break_active <= 1; 								// flags that prev code was BREAK_CODE
				end 														// else, if scan_code is NOT BREAK_CODE, 
				else begin 
					if(break_active  == 1'b0)
					begin 
						case(scan_code)
							 SCAN_W: 
									move_up <= 1;  
							 SCAN_A:
									move_left <= 1;  
							 SCAN_S:
									move_down <= 1;  
							 SCAN_D:
									move_right <= 1;  
							 SCAN_UP:
									move_up <= 1; 
							 SCAN_DOWN:
									move_down <= 1; 
							 SCAN_LEFT:
									move_left <= 1; 
							 SCAN_RIGHT:
									move_right <= 1; 
						endcase
					end
					break_active <= 0; 								// reset flag no matter what 
				end 	
			end 
		end 
	end 
endmodule 

	
