`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2020 12:13:07 PM
// Design Name: 
// Module Name: sevenselect
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


module sevenselect(
    input [3:0] n0,
    input [3:0] n1,
    input [3:0] n2,
    input [3:0] n3,
    input clk,
    output [3:0] en,
    output [6:0] seven
);
reg [3:0] en;
reg [1:0] counter;
reg [3:0] number;
wire [6:0] seven;
toseven ts(number,seven);

initial
begin
    counter = 0;
    en=0;
    number = 0;
end
always @(posedge clk)
begin
    counter = counter + 1;
    case (counter)
        0 : begin
                number = n0;
                en = 4'b1110;
            end
        1 : begin
                number = n1;
                en = 4'b1101;
            end
        2 : begin
                number = n2;
                en = 4'b1011;
            end
        3 : begin
                number = n3;
                en = 4'b0111;
            end
    endcase
    counter = counter % 4;
end
endmodule
