 // movement module for sprites... will get instatiated in cross_road.v and sprite 1 & 2's initial position will be stated in tp module 
// parameterized module header !!!
module movement #(
							parameter START_X = 4, 
							parameter START_Y = 4)
		(input clk, 
			input rst, 
			input move_up, 
			input move_down, 
			input move_left, 
			input move_right, 
			output reg[3:0] player_x,
			output reg[3:0] player_y); 

// vga_driver_memory instamtiation??? 


always @ (posedge clk or negedge rst)
	begin 
	if(rst == 1'b0)													// active high because assigned in top module 
		begin 
		player_x <= START_X; 							// initial x position of sprite(s) TBD in top module
		player_y <= START_Y; 						// inital y position of sprite(s) TBD in top module  
		end 
		
	else begin 
		//sprite moving up 
		if(move_up == 1 && player_y > 0)
			player_y <= player_y - 1; 
		//sprite moving down 
		if(move_down == 1 && player_y < 11)
			player_y <= player_y + 1; 
		//sprite moving left 
		if(move_left == 1 && player_x > 0)
			player_x <= player_x - 1; 
		//sprite moving right 
		if(move_right == 1 && player_x < 15)
			player_x <= player_x + 1; 
	end 
end 



endmodule 