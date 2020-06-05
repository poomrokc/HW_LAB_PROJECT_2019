module vgaSystem
	(
		input wire clk,
		input wire [11:0] color,
		input wire [9:0] cypos,
		input wire [9:0] cxpos,
		output wire Hsync, Vsync,
		output wire [3:0] vgaRed,vgaGreen,vgaBlue
	);
	
	// register for Basys 2 8-bit RGB DAC 
	reg [11:0] rgb_reg;
	wire [9:0] x,y;
	wire reset;
	reg[31:0] calx,caly;
	assign reset=0;
	initial
	begin
	   rgb_reg=0;
	   calx=0;
	   caly=0;
	end
	// video status output from vga_sync to tell when to route out rgb signal to DAC
	wire video_on;

        // instantiate vga_sync
        vga_sync vga_sync_unit (.clk(clk), .reset(reset), .hsync(Hsync), .vsync(Vsync),
                             .video_on(video_on), .p_tick(), .x(x), .y(y));
   
        // rgb buffer
        always @(posedge clk, posedge reset)
        begin
        if (reset)
           rgb_reg <= 0;
        else
        begin
            calx=x-47+1;
            caly=y-31+1;
            if((calx-cxpos)*(calx-cxpos) + (caly-cypos)*(caly-cypos)<=100*100)
                rgb_reg = color;
            else
                rgb_reg = 12'b000000000000;
        end
        end
        
        // output
        assign vgaRed = (video_on) ? rgb_reg[11:8] : 4'b0000;
        assign vgaGreen = (video_on) ? rgb_reg[7:4] : 4'b0000;
        assign vgaBlue = (video_on) ? rgb_reg[3:0] : 4'b0000;
endmodule