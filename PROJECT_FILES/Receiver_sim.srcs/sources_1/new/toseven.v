`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2020 12:06:01 PM
// Design Name: 
// Module Name: toseven
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module toseven(
    input [3:0] numIn,
    output [6:0] numOut        
);
reg [6:0] numOut;
always @(numIn)
      case (numIn)
          4'b0001 : numOut = 7'b1111001;   // 1
          4'b0010 : numOut = 7'b0100100;   // 2
          4'b0011 : numOut = 7'b0110000;   // 3
          4'b0100 : numOut = 7'b0011001;   // 4
          4'b0101 : numOut = 7'b0010010;   // 5
          4'b0110 : numOut = 7'b0000010;   // 6
          4'b0111 : numOut = 7'b1111000;   // 7
          4'b1000 : numOut = 7'b0000000;   // 8
          4'b1001 : numOut = 7'b0010000;   // 9
          4'b1010 : numOut = 7'b0001000;   // A
          4'b1011 : numOut = 7'b0000011;   // b
          4'b1100 : numOut = 7'b1000110;   // C
          4'b1101 : numOut = 7'b0100001;   // d
          4'b1110 : numOut = 7'b0000110;   // E
          4'b1111 : numOut = 7'b0001110;   // F
          default : numOut = 7'b1000000;   // 0
      endcase
endmodule
