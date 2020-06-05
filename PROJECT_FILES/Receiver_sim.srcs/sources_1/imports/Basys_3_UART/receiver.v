`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/04/2015 12:03:40 PM
// Design Name: 
// Module Name: receiver
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


module receiver(

input clk, //input clock
input reset, //input reset 
input RxD, //input receving data line
input [1:0] sw,
output [7:0]RxData, // output for 8 bits data
output TxD,
output wire Hsync, Vsync,
output wire [3:0] vgaRed,vgaGreen,vgaBlue,
output wire ground,
output wire [3:0] en,
output wire [6:0] seven
    );

assign ground=1;

//graphic
reg [0:215] MONSTER_2 [0:112];
reg [0:362] TEXT_2 [0:36];
reg [0:213] SPACE_2 [0:19];
reg [0:234] ATK_3 [0:19];
reg [0:303] WIN [0:142];
reg [0:273] LOSE [0:138];
reg [0:435] NAME [0:109];
//graphic
//GAME VARIABLE
reg [3:0] GAME_STATE;//0=home 1=map 2=load_fight_screen 3=fight_menu 4=running_cursor 5=dodge 6=win 7=lose
reg GAME_FLASH;


//map
reg [0:239] MAP [0:59];
reg [7:0] CHAR_X;
reg [7:0] CHAR_Y;
reg [7:0] OFFSET_X;

//fight
reg [9:0] CHAR_HP;
reg [9:0] MONSTER_HP;

//running
reg [9:0] CURSOR_POS;
reg CURSOR_DIRECTION;

//dodge
reg [9:0] HEART_X;
reg [9:0] HEART_Y;
reg [3:0] ACTIVE_PIECE;
//END GAME VARIABLE
//TEMPVAR
reg [3:0] GST;
reg [7:0] TCYY;
reg [7:0] TCXX;
reg [7:0] TCHP;
reg [7:0] TMHP;
reg [7:0] THYY;
reg [7:0] THXX;
reg [7:0] TCP;
reg [7:0] COUNTER;
reg [7:0] TCOUNTER;
reg [7:0] FIXED_COUNTER;

reg [9:0] curr_block_x;
reg [9:0] curr_block_y;
//TEMPVAR


//internal variables
reg shift; // shift signal to trigger shifting data
reg state, nextstate; // initial state and next state variable
reg [3:0] bitcounter; // 4 bits counter to count up to 9 for UART receiving
reg [1:0] samplecounter; // 2 bits sample counter to count up to 4 for oversampling
reg [13:0] counter; // 14 bits counter to count the baud rate
reg [9:0] rxshiftreg; //bit shifting register
reg clear_bitcounter,inc_bitcounter,inc_samplecounter,clear_samplecounter; //clear or increment the counter
reg transmit;
reg [11:0] color;
reg [9:0] cypos;
reg [9:0] cxpos;
reg [9:0] tcy;
reg [9:0] tcx;
reg [3:0] n0;
reg [3:0] n1;
reg [3:0] n2;
reg [3:0] n3;

wire tellme;
reg [7:0] ooData;
// constants
parameter clk_freq = 100_000_000;  // system clock frequency
parameter baud_rate = 9_600; //baud rate
parameter div_sample = 4; //oversampling
parameter div_counter = clk_freq/(baud_rate*div_sample);  // this is the number we have to divide the system clock frequency to get a frequency (div_sample) time higher than (baud_rate)
parameter mid_sample = (div_sample/2);  // this is the middle point of a bit where you want to sample it
parameter div_bit = 10; // 1 start, 8 data, 1 stop

assign RxData = rxshiftreg [8:1]; // assign the RxData from the shiftregister
transmitter T1 (.clk(clk), .reset(reset),.transmit(transmit),.TxD(TxD),.data(ooData),.tellme(tellme));
initial
begin
    $readmemb("C:\\Users\\dell\\Downloads\\Compressed\\FAW2R9XIXGFN6HR\\Receiver_sim\\Receiver_sim.srcs\\sources_1\\new\\reg.mem", MAP);
    $readmemb("C:\\Users\\dell\\Downloads\\Compressed\\FAW2R9XIXGFN6HR\\Receiver_sim\\Receiver_sim.srcs\\sources_1\\new\\mon2.mem", MONSTER_2);
    $readmemb("C:\\Users\\dell\\Downloads\\Compressed\\FAW2R9XIXGFN6HR\\Receiver_sim\\Receiver_sim.srcs\\sources_1\\new\\text2.mem", TEXT_2);
    $readmemb("C:\\Users\\dell\\Downloads\\Compressed\\FAW2R9XIXGFN6HR\\Receiver_sim\\Receiver_sim.srcs\\sources_1\\new\\space2.mem", SPACE_2);
    $readmemb("C:\\Users\\dell\\Downloads\\Compressed\\FAW2R9XIXGFN6HR\\Receiver_sim\\Receiver_sim.srcs\\sources_1\\new\\atk3.mem", ATK_3);
    $readmemb("C:\\Users\\dell\\Downloads\\Compressed\\FAW2R9XIXGFN6HR\\Receiver_sim\\Receiver_sim.srcs\\sources_1\\new\\win.mem", WIN);
    $readmemb("C:\\Users\\dell\\Downloads\\Compressed\\FAW2R9XIXGFN6HR\\Receiver_sim\\Receiver_sim.srcs\\sources_1\\new\\lose.mem", LOSE);
    $readmemb("C:\\Users\\dell\\Downloads\\Compressed\\FAW2R9XIXGFN6HR\\Receiver_sim\\Receiver_sim.srcs\\sources_1\\new\\name.mem", NAME);
    transmit=0;
    GAME_STATE = 0;
    CURSOR_POS = 0;
    CURSOR_DIRECTION = 1;
    GAME_FLASH = 0;
    COUNTER = 0;
end
//OUT_MAPPER
always @(*)
begin
    case (RxData)
            8'b01110111:begin //w
                ooData=RxData-32;
            end
            8'b01110011:begin //s
                ooData=RxData-32;
            end
            8'b01100001:begin //a
                ooData=RxData-32;
            end
            8'b01100100:begin //d
                ooData=RxData-32;
            end
            8'b00100000:begin //space
                ooData=8'b01011010;
            end
            default:begin
                ooData=0;
            end
     endcase
end
//UART receiver logic
always @ (posedge clk)
    begin 
        if (reset)begin // if reset is asserted
            state <=0; // set state to idle 
            bitcounter <=0; // reset the bit counter
            counter <=0; // reset the counter
            samplecounter <=0; // reset the sample counter
        end else begin // if reset is not asserted
            counter <= counter +1; // start count in the counter
            if (counter >= div_counter-1) begin // if counter reach the baud rate with sampling 
                counter <=0; //reset the counter
                state <= nextstate; // assign the state to nextstate
                if (shift)rxshiftreg <= {RxD,rxshiftreg[9:1]}; //if shift asserted, load the receiving data
                if (clear_samplecounter) samplecounter <=0; // if clear sampl counter asserted, reset sample counter
                if (inc_samplecounter) samplecounter <= samplecounter +1; //if increment counter asserted, start sample count
                if (clear_bitcounter) bitcounter <=0; // if clear bit counter asserted, reset bit counter
                if (inc_bitcounter)bitcounter <= bitcounter +1; // if increment bit counter asserted, start count bit counter
            end
        end
    end
   
//state machine

always @ (posedge clk) //trigger by clock
begin 
    if (reset)
    begin
        GAME_STATE = 2;
    end
    shift <= 0; // set shift to 0 to avoid any shifting 
    clear_samplecounter <=0; // set clear sample counter to 0 to avoid reset
    inc_samplecounter <=0; // set increment sample counter to 0 to avoid any increment
    clear_bitcounter <=0; // set clear bit counter to 0 to avoid claring
    inc_bitcounter <=0; // set increment bit counter to avoid any count
    nextstate <=0; // set next state to be idle state
    case (state)
        0: begin // idle state
            if(transmit==1 && ~tellme)
            begin
                transmit=0;
                case (RxData)
                    8'b01110111:begin //w
                        if(GAME_STATE==1)
                        begin
                            if(CHAR_Y > 0 && MAP[CHAR_Y-1][CHAR_X] == 0)
                                TCYY = CHAR_Y - 1;
                        end
                        if(GAME_STATE==5)
                        begin
                            if(HEART_Y>1)
                                THYY = HEART_Y - 2;
                        end
                    end
                    8'b01110011:begin //s
                        if(GAME_STATE==1)
                        begin
                            if(CHAR_Y < 59 && MAP[CHAR_Y+1][CHAR_X] == 0)
                                TCYY = CHAR_Y + 1;
                        end
                        if(GAME_STATE==5)
                        begin
                            if(HEART_Y<98)
                                THYY = HEART_Y + 2;
                        end
                    end
                    8'b01100001:begin //a
                        if(GAME_STATE==1)
                        begin
                            if(CHAR_X > 0 && MAP[CHAR_Y][CHAR_X-1] == 0)
                                TCXX = CHAR_X - 1;
                        end
                        if(GAME_STATE==5)
                        begin
                            if(HEART_X>1)
                                THXX = HEART_X - 2;
                        end
                    end
                    8'b01100100:begin //d
                        if(GAME_STATE==1)
                        begin
                            if(CHAR_X < 239 && MAP[CHAR_Y][CHAR_X+1] == 0)
                                TCXX = CHAR_X + 1;
                        end
                        if(GAME_STATE==5)
                        begin
                            if(HEART_X<98)
                                THXX = HEART_X + 2;
                        end
                    end
                    8'b00100000:begin //space
                        if(GAME_STATE == 0)
                        begin
                            GST = 1;
                            TCXX = 0;
                            TCYY = 0;
                            OFFSET_X = 0;
                        end
                        if(GAME_STATE == 2)
                        begin
                            GST = 3;
                            TCHP = 100;
                            TMHP = 100;
                        end
                        if(GAME_STATE == 3)
                        begin
                            GST = 4;
                        end
                        if(GAME_STATE == 4)
                        begin
                            if(MONSTER_HP <= 30)
                                GST = 6;
                            else
                            begin
                                FIXED_COUNTER = (COUNTER+5)%10;
                                GST = 5;
                                ACTIVE_PIECE = 4'b1111;
                                TMHP = MONSTER_HP - 30;
                                THXX = 50;
                                THYY = 50;
                            end
                        end
                        if(GAME_STATE == 6)
                            GST = 0;
                        if(GAME_STATE == 7)
                            GST = 0;
                    end
                endcase
                if(GAME_STATE == 1 && CHAR_X < 40)
                    OFFSET_X = 0;
                if(GAME_STATE == 1 && CHAR_X >= 200)
                    OFFSET_X = 160;
                if(GAME_STATE == 1 && CHAR_X < 200 && CHAR_X >= 40)
                    OFFSET_X = CHAR_X - 40;
                if(GAME_STATE == 1 && TCXX == 239 && TCYY == 59)
                    GST = 2;
                GAME_STATE = GST;
                CHAR_X = TCXX;
                CHAR_Y = TCYY;
                HEART_X = THXX;
                HEART_Y = THYY;
                CHAR_HP = TCHP;
                MONSTER_HP = TMHP;
            end
            if (RxD) // if input RxD data line asserted
              begin
              nextstate <=0; // back to idle state because RxD needs to be low to start transmission    
              end
            else begin // if input RxD data line is not asserted
                nextstate <=1; //jump to receiving state 
                clear_bitcounter <=1; // trigger to clear bit counter
                clear_samplecounter <=1; // trigger to clear sample counter
            end
        end
        1: begin // receiving state
            nextstate <= 1; // DEFAULT 
            if (samplecounter== mid_sample - 1) shift <= 1; // if sample counter is 1, trigger shift 
                if (samplecounter== div_sample - 1) begin // if sample counter is 3 as the sample rate used is 3
                    if (bitcounter == div_bit - 1) begin // check if bit counter if 9 or not
                nextstate <= 0; // back to idle state if bit counter is 9 as receving is complete
                transmit=1;
                end 
                inc_bitcounter <=1; // trigger the increment bit counter if bit counter is not 9
                clear_samplecounter <=1; //trigger the sample counter to reset the sample counter
            end else inc_samplecounter <=1; // if sample is not equal to 3, keep counting
        end
       default: nextstate <=0; //default idle state
     endcase
     if(GAME_STATE == 5)
     begin
        if(ACTIVE_PIECE[0] && ((HEART_X * 2 - 33 * 2) * (HEART_X * 2 - 33 * 2) + (HEART_Y * 2 - CURSOR_POS * 2) * (HEART_Y * 2 - CURSOR_POS * 2) <= 225))
        begin
            if(CHAR_HP<=20)
                GAME_STATE = 7;
            else
                TCHP = CHAR_HP - 20;
            ACTIVE_PIECE[0] = 0;
        end
        else if(ACTIVE_PIECE[1] && ((HEART_X * 2 - 66 * 2) * (HEART_X * 2 - 66 * 2) + (HEART_Y * 2 - CURSOR_POS * 2) * (HEART_Y * 2 - CURSOR_POS * 2) <= 225))
        begin
            if(CHAR_HP<=20)
                GAME_STATE = 7;
            else
                TCHP = CHAR_HP - 20;
            ACTIVE_PIECE[1] = 0;
        end
        else if(ACTIVE_PIECE[2] && ((HEART_X * 2 - CURSOR_POS * 2) * (HEART_X * 2 - CURSOR_POS * 2) + (HEART_Y * 2 - 33 * 2) * (HEART_Y * 2 - 33 * 2) <= 225))
        begin
            if(CHAR_HP<=20)
                GAME_STATE = 7;
            else
                TCHP = CHAR_HP - 20;
            ACTIVE_PIECE[2] = 0;
        end
        else if(ACTIVE_PIECE[3] && ((HEART_X * 2 - CURSOR_POS * 2) * (HEART_X * 2 - CURSOR_POS * 2) + (HEART_Y * 2 - 66 * 2) * (HEART_Y * 2 - 66 * 2) <= 225))
        begin
            if(CHAR_HP<=20)
                GAME_STATE = 7;
            else
                TCHP = CHAR_HP - 20;
            ACTIVE_PIECE[3] = 0;
        end
        CHAR_HP = TCHP;
        if(COUNTER == FIXED_COUNTER)
            GAME_STATE = 3;
        GST = GAME_STATE;
    end
end         

wire [30:0] tdc;
assign tdc[0] = clk;
genvar i;

generate for(i=1;i<=30;i=i+1)
begin
    halfclock hclock(tdc[i-1],tdc[i]);
end endgenerate

//COUNTER
always @(posedge tdc[27])
begin
        TCOUNTER = (COUNTER + 1) % 10;
        COUNTER = TCOUNTER;
end


//bar & bullet move
always @(posedge tdc[20])
begin
    if(CURSOR_DIRECTION == 0)
    begin
        if(CURSOR_POS < 99)
            TCP = CURSOR_POS + 1;
        else
           CURSOR_DIRECTION = 1;
    end
    else
    begin
        if(CURSOR_POS > 0)
            TCP = CURSOR_POS - 1;
        else
            CURSOR_DIRECTION = 0;
    end
    CURSOR_POS = TCP;    
end

always @(posedge clk)
begin
    if(sw==0)
    begin
        n0=COUNTER[3:0];
        n1=FIXED_COUNTER[3:0];
        n2=CHAR_X[7:4];
        n3=CHAR_X[3:0];
    end
    if(sw==1)
    begin
        n0=0;
        n1=0;
        n2=CHAR_Y[7:4];
        n3=CHAR_Y[3:0];
    end
    if(sw==2)
    begin
        n0=CURSOR_POS[7:4];
        n1=CURSOR_POS[3:0];
        n2=0;
        n3=0;
    end
    if(sw==3)
    begin
        n0=GAME_STATE;
        n1=8;
        n2=8;
        n3=8;
    end
end

sevenselect ss(n3,n2,n1,n0,tdc[18],en,seven);


//VGA
reg [14:0] TITLE_ADDRESS;
wire TITLE_DATA;
title_rom t1(clk,TITLE_ADDRESS, TITLE_DATA);

reg [11:0] START_ADDRESS;
wire START_DATA;
start_rom s1(clk,START_ADDRESS, START_DATA);

reg [11:0] rgb_reg;
wire [9:0] x,y;
reg[31:0] calx,caly;
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
always @(posedge clk)
begin
    calx=x-47+1;
    caly=y-31+1;
    if(GAME_STATE == 0)
    begin
        if(calx < 503 && calx>=140 && caly < 121 && caly>=50)
        begin
            TITLE_ADDRESS = (caly-50) * 363 + (calx-140);
            if(TITLE_DATA)
                rgb_reg = 12'b111100000000;
            else
                rgb_reg = 12'b000000000000;
        end
        else if(calx < 417 && calx>=200 && caly < 419 && caly>=401)
        begin
            START_ADDRESS = (caly-401) * 217 + (calx-200);
            if(START_DATA && tdc[26])
                rgb_reg = 12'b111111111111;
            else
                rgb_reg = 12'b000000000000;
        end
        else if(calx < 537 && calx>=101 && caly < 291 && caly>=181)
        begin
            if(NAME[caly-181][calx-101])
                rgb_reg = 12'b111100001111;
            else
                rgb_reg = 12'b000000000000;
        end
        else
            rgb_reg = 12'b000000000000;
    end
    else if(GAME_STATE == 1)
    begin
        curr_block_x = OFFSET_X + calx / 8;
        curr_block_y = caly / 8;
        if(curr_block_x == CHAR_X && curr_block_y == CHAR_Y)
        begin
            if(tdc[25])
                rgb_reg = 12'b111100000000;
            else
                rgb_reg = 12'b111111111111;
        end
        else if(curr_block_x == 239 && curr_block_y ==59)
            rgb_reg = 12'b000000001111;
        else if(MAP[curr_block_y][curr_block_x] == 0)
            rgb_reg = 12'b111111111111;
        else
            rgb_reg = 12'b000000000000;
    end
    else if(GAME_STATE == 2)
    begin
        if(calx < 416 && calx>=200 && caly < 153 && caly>=40)
        begin
            if(MONSTER_2[caly-40][calx-200])
                rgb_reg = 12'b111111110000;
            else
                rgb_reg = 12'b000000000000;
        end
        else if(calx < 503 && calx>=140 && caly < 292 && caly>=255)
        begin
            if(TEXT_2[caly-255][calx-140])
                rgb_reg = 12'b111100000000;
            else
                rgb_reg = 12'b000000000000;
        end
        else if(calx < 414 && calx>=200 && caly < 418 && caly>=398)
        begin
            if(SPACE_2[caly-398][calx-200] && tdc[26])
                rgb_reg = 12'b111111111111;
            else
                rgb_reg = 12'b000000000000;
        end
        else
            rgb_reg = 12'b000000000000;
    end
    else if(GAME_STATE == 3)
    begin
        if(calx < 416 && calx>=200 && caly < 153 && caly>=40)
        begin
            if(MONSTER_2[caly-40][calx-200])
                rgb_reg = 12'b111111110000;
            else
                rgb_reg = 12'b000000000000;
        end
        else if(calx <= MONSTER_HP * 6 && caly < 175 && caly>=160)
                rgb_reg = 12'b111100000000;
        else if(calx <= CHAR_HP * 6 && caly < 465 && caly>=450)
                rgb_reg = 12'b000011110000;
        else if(calx < 435 && calx>=200 && caly < 250 && caly>=230)
        begin
            if(ATK_3[caly-230][calx-200] && tdc[26])
                rgb_reg = 12'b111111111111;
            else
                rgb_reg = 12'b000000000000;
        end
        else
            rgb_reg = 12'b000000000000;
    end
    else if(GAME_STATE == 4)
    begin
        if(calx < 416 && calx>=200 && caly < 153 && caly>=40)
        begin
            if(MONSTER_2[caly-40][calx-200])
                rgb_reg = 12'b111111110000;
            else
                rgb_reg = 12'b000000000000;
        end
        else if(calx <= MONSTER_HP * 6 && caly < 175 && caly>=160)
                rgb_reg = 12'b111100000000;
        else if(calx <= CHAR_HP * 6 && caly < 465 && caly>=450)
                rgb_reg = 12'b000011110000;
        else if(calx >= 319 && calx < 323  && caly < 240 && caly>=225)
                rgb_reg = 12'b111100001111;
        else if(calx >= CURSOR_POS * 5 + 67 && calx < CURSOR_POS * 5 + 73  && caly < 265 && caly>=245)
                rgb_reg = 12'b111111111111;
        else
            rgb_reg = 12'b000000000000;
    end
    else if(GAME_STATE == 5)
    begin
        if(calx < 416 && calx>=200 && caly < 153 && caly>=40)
        begin
            if(MONSTER_2[caly-40][calx-200])
                rgb_reg = 12'b111111110000;
            else
                rgb_reg = 12'b000000000000;
        end
        else if(calx <= MONSTER_HP * 6 && caly < 175 && caly>=160)
                rgb_reg = 12'b111100000000;
        else if(calx <= CHAR_HP * 6 && caly < 465 && caly>=450)
                rgb_reg = 12'b000011110000;
        else if(calx >= 217 && calx < 423  && caly < 200 && caly>=194) //top border
                rgb_reg = 12'b111111111111;
        else if(calx >= 217 && calx < 423  && caly < 406 && caly>=400) //bottom border
                rgb_reg = 12'b111111111111;
        else if(calx >= 214 && calx < 220  && caly < 400 && caly>=200) //left border
                rgb_reg = 12'b111111111111;
        else if(calx >= 420 && calx < 426  && caly < 400 && caly>=200) //right border
                rgb_reg = 12'b111111111111;
        else if(calx >= 220 && calx < 420  && caly < 400 && caly>=200) //box
        begin
                if((calx-220 - HEART_X * 2) * (calx-220 - HEART_X * 2) + (caly-200 - HEART_Y * 2) * (caly-200 - HEART_Y * 2) <= 100)
                    rgb_reg = 12'b111100000000;
                else if(ACTIVE_PIECE[0] && (calx-220 - 33 * 2) * (calx-220 - 33 * 2) + (caly-200 - CURSOR_POS * 2) * (caly-200 - CURSOR_POS * 2) <= 25)
                    rgb_reg = 12'b111111111111;
                else if(ACTIVE_PIECE[1] && (calx-220 - 66 * 2) * (calx-220 - 66 * 2) + (caly-200 - CURSOR_POS * 2) * (caly-200 - CURSOR_POS * 2) <= 25)
                    rgb_reg = 12'b111111111111;
                else if(ACTIVE_PIECE[2] && (calx-220 - CURSOR_POS * 2) * (calx-220 - CURSOR_POS * 2) + (caly-200 - 33 * 2) * (caly-200 - 33 * 2) <= 25)
                    rgb_reg = 12'b111111111111;
                else if(ACTIVE_PIECE[3] && (calx-220 - CURSOR_POS * 2) * (calx-220 - CURSOR_POS * 2) + (caly-200 - 66 * 2) * (caly-200 - 66 * 2) <= 25)
                    rgb_reg = 12'b111111111111;
                else
                    rgb_reg = 12'b000000000000;
        end
        else
            rgb_reg = 12'b000000000000;
    end
    else if(GAME_STATE == 6)
    begin
        if(calx < 474 && calx>=170 && caly < 313 && caly>=170)
        begin
            if(WIN[caly-170][calx-170])
                rgb_reg = 12'b000011110000;
            else
                rgb_reg = 12'b000000000000;
        end
        else
            rgb_reg = 12'b000000000000;
    end
    else if(GAME_STATE == 7)
    begin
        if(calx < 454 && calx>=180 && caly < 309 && caly>=170)
        begin
            if(LOSE[caly-170][calx-180])
                rgb_reg = 12'b111100000000;
            else
                rgb_reg = 12'b000000000000;
        end
        else
            rgb_reg = 12'b000000000000;
    end
end

// output
assign vgaRed = (video_on) ? rgb_reg[11:8] : 4'b0000;
assign vgaGreen = (video_on) ? rgb_reg[7:4] : 4'b0000;
assign vgaBlue = (video_on) ? rgb_reg[3:0] : 4'b0000;

//VGA



endmodule
