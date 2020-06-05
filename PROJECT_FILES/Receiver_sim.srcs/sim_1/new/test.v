`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: Computer Engineering Department, Chulalongkorn University
// Engineer: tan14007
// 
// Create Date: 04/05/2020 01:07:20 PM
// Design Name: 
// Module Name: VGA, UART, and Keyboard USB tester
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: After clicked 'Run Simulation', 
//                      open Tcl Console and enter `set_property unifast true [current_fileset -simset]` 
//                      to make simulation faster
// 
//////////////////////////////////////////////////////////////////////////////////


module tester(
    
    );
    

reg clk=0;
reg reset=0;
reg rxd=0;
reg [1:0] sw;
wire [7:0] RxData;
wire TxD;
wire Hsync, Vsync;
wire [3:0] vgaRed,vgaGreen,vgaBlue;
wire ground;
wire [3:0] en;
wire [6:0] seven;

receiver r1(clk,reset,rxd,sw,RxData,TxD,Hsync,Vsync,vgaRed,vgaGreen,vgaBlue,ground,en,seven);

initial
begin
    #1000 $finish;
end

endmodule
