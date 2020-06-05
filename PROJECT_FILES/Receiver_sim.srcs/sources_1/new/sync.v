module vga_sync

	(
		input wire clk, reset,
		output wire hsync, vsync, video_on, p_tick,
		output wire [9:0] x, y
	);
	
	// constant declarations for VGA sync parameters
	localparam H_DISPLAY       = 640; // horizontal display area
	localparam H_L_BORDER      =  48; // horizontal left border
	localparam H_R_BORDER      =  16; // horizontal right border
	localparam H_RETRACE       =  96; // horizontal retrace
	localparam H_MAX           = H_DISPLAY + H_L_BORDER + H_R_BORDER + H_RETRACE - 1;
	localparam START_H_RETRACE = H_L_BORDER + H_DISPLAY + H_R_BORDER;
	localparam END_H_RETRACE   = H_L_BORDER + H_DISPLAY + H_R_BORDER + H_RETRACE - 1;
	
	localparam V_DISPLAY       = 480; // vertical display area
	localparam V_T_BORDER      =  32; // vertical top border
	localparam V_B_BORDER      =  10; // vertical bottom border
	localparam V_RETRACE       =   2; // vertical retrace
	localparam V_MAX           = V_DISPLAY + V_T_BORDER + V_B_BORDER + V_RETRACE - 1;
    localparam START_V_RETRACE = V_T_BORDER + V_DISPLAY + V_B_BORDER;
	localparam END_V_RETRACE   = V_T_BORDER + V_DISPLAY + V_B_BORDER + V_RETRACE - 1;
	
	// mod-4 counter to generate 25 MHz pixel tick
	reg [1:0] pixel_reg;
	wire [1:0] pixel_next;
	wire pixel_tick;
	
	always @(posedge clk)
	begin
		pixel_reg <= pixel_next;
		//$display("%d,%d %d %d",pixel_reg,v_count_reg,h_count_reg,hsync_reg);
	end
	
	assign pixel_next = pixel_reg==3?0:pixel_reg+1; // next state is complement of current
	assign pixel_tick = (pixel_reg == 3); // assert tick half of the time
	
	// registers to keep track of current pixel location
	reg [9:0] h_count_reg, h_count_next, v_count_reg, v_count_next;
	// register to keep track of vsync and hsync signal states
	reg vsync_reg, hsync_reg;
	wire vsync_next, hsync_next;
	initial
    begin
                pixel_reg   <= 0;
                v_count_reg <= 0;
                h_count_reg <= 0;
                vsync_reg   <= 1;
                hsync_reg   <= 1;
	end
 
	// infer registers
	always @(posedge clk)
		    begin
                    v_count_reg <= v_count_next;
                    h_count_reg <= h_count_next;
                    vsync_reg   <= vsync_next;
                    hsync_reg   <= hsync_next;
	            end
			
	// next-state logic of horizontal vertical sync counters
	always @*
		begin
		h_count_next = pixel_tick ? 
		               h_count_reg == H_MAX ? 0 : h_count_reg + 1
			       : h_count_reg;
		
		v_count_next = pixel_tick && h_count_reg == H_MAX ? 
		               (v_count_reg == V_MAX ? 0 : v_count_reg + 1) 
			       : v_count_reg;
		end
		
        // hsync and vsync are active low signals
        // hsync signal asserted during horizontal retrace
        assign hsync_next = h_count_reg+1 >= START_H_RETRACE 
                            && h_count_reg+1 <= END_H_RETRACE;
   
        // vsync signal asserted during vertical retrace
        assign vsync_next = v_count_reg+1 >= START_V_RETRACE 
                            && v_count_reg+1 <= END_V_RETRACE;

        // video only on when pixels are in both horizontal and vertical display region
        assign video_on = (h_count_reg >= H_L_BORDER && h_count_reg < H_L_BORDER + H_DISPLAY) 
                           && (h_count_reg >= V_T_BORDER && v_count_reg < V_T_BORDER + V_DISPLAY);

        // output signals
        assign hsync  = ~hsync_reg;
        assign vsync  = ~vsync_reg;
        assign x      = h_count_reg;
        assign y      = v_count_reg;
        assign p_tick = pixel_tick;
endmodule