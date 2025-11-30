// Purpose: reads Ps/2 Keyboard scan codes
// must detect falling edges of ps2_clk, shift in 11 bits,track bit_count, extract only data bits, output scan code + scan ready


module ps2_controller (input clk, 									// internal 50MHz system clock
								input rst, 
								input ps2_clk, 							// Ps/2 clock line 
								input ps2_data, 							// PS/2 data line 
								output reg [7:0] scan_code, 
								output reg scan_ready); 
								 

// sync PS/2 clk into 50 MHz clk
	reg [2:0] ps2_clk_sync;  												// 3 F.F. synchronizer 

	always @ (posedge clk or negedge rst)
	begin 
		if(rst == 1'b0)																	// active high because assigned in top module 
			ps2_clk_sync <= 3'b111; 
		else
			ps2_clk_sync <= {ps2_clk_sync[1:0], ps2_clk}; 			// shifts new values through ps2_clk every cycle 
		
	end 
	
// detecting ps/2 clk's falling edge 								// 1 -> 0 transition. meaning, 
	wire ps2_clk_fall = (ps2_clk_sync[2:1] == 2'b10); 			// prev clk bit = 1 (falling edge) , current clk bit = 0 (not falling edge)
	

// bit capture registers 
	reg [3:0] bit_count = 0; 											// counts how many bits have been recieved. Since possible recieved = (1 - 10), 4 bits accounts for that... 2^(4) = 16. 
	reg [10:0] shift_reg = 0; 											// stores all 11 bits... start + 8 + odd parity + stop 
	
// main reciever 
	always @ (posedge clk or negedge rst) 
	begin 
		if(rst == 1'b0) 																// active high because changed in top module 
		begin 
			bit_count <= 0; 
			shift_reg <= 0; 
			scan_code <= 0; 
			scan_ready <= 0; 
		end
		else begin 
			scan_ready <= 0; 													// clk cycle default behavior: will pulse for 1 clk when data is ready 
			if(ps2_clk_fall == 1) 										// if a falling edge occurs, 
			begin 
				shift_reg <= {ps2_data, shift_reg[10:1]}; 		// shift a new bit in on every falling edge 
				bit_count <= bit_count + 1; 
			 
				if(bit_count == 10)										// if all 11 bits have been recieved, 
				begin 
					bit_count <= 0; 										// restart count at 0 for next frame 
					scan_code <= shift_reg[8:1];						// 8 data bits of data 
					scan_ready <= 1; 										// 1 cycle strobe says: "new scan code was recieved!!!"
		
				end
			end 
		end 
	end
endmodule 