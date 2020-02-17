//**************************************************************//
//**************************************************************//
//Project Name: Novel ECT Hardware Design
//
//Author: Yunjie Yang
//Create  Date: 16:16 2014-11-15
//Design  Name: ECTNew
//Module  Name: MasterStateMachine
//Target Devices: EP3C25F324C8
//Tool versions: 13.1
//Descriptions: This module is the master control part of the whole system.
//Revision:
//**************************************************************//
//**************************************************************//

module MasterStateMachine
(
    Clk, Rst,
	 //USB Interface
	 USBRReady, USBRcv,   //Read data from USB
	 //External module enable
	 EnTest, EnSingle, EnTwin, EnData, EnReserve,
	 //Frame complete flag for stop
	 FrameEnd, Cmd,
	 //Debug
	 Stat, TestLED
);
    //Parameters 
	 parameter Idle = 2'b00;    //State waiting for command
	 parameter Work = 2'b01;    //State working
	 
	 parameter Test = 8'h01;
	 parameter Single = 8'h02;
	 parameter Twin = 8'h03;
	 parameter Data = 8'h04;
	 parameter Reserve = 8'h05;
	 parameter Stop = 8'h06;
	
    //Define

	 
	 //Interface
	 input Clk, Rst;
	 
	 input USBRReady;
	 input [15:0] USBRcv;
	 
	 input FrameEnd;            //Support maximum 1023 measurement data in a single frame
	 
	 output reg EnTest;
	 output reg EnSingle;
	 output reg EnTwin;
	 output reg EnData;
	 output reg EnReserve;

	 output reg [1:0] Stat;	 
	 output reg TestLED;
	 output [15:0] Cmd;
	 
	 assign Cmd = tempUSBDat;
	 	 
	 //Internal Regs	 
	 reg preDatReady;
	 reg [15:0] tempUSBDat;
	 
	 always @ (posedge Clk or negedge Rst)
		if (!Rst) begin			
			EnTest <= 0;
			EnSingle <= 0;
			EnTwin <= 0;
			EnData <= 0;
			EnReserve <= 0;
			
			preDatReady <= 0;
			tempUSBDat <= 16'd0;
			TestLED <= 1;                   //Off the testLED
			
			Stat <= 2'b00;                  //Idle
		end
		else begin
			preDatReady <= USBRReady;
			case (Stat)
			Idle: //Idle state, waiting a data/command from USB
				begin
				//Calibration Part, if calibration done
				if ((tempUSBDat[15:12] == 4'h1 || tempUSBDat[15:12] == 4'hE) && (FrameEnd == 1)) begin
						EnTest <= 0;
						EnSingle <= 0;
						EnTwin <= 0;
						EnData <= 0;
						EnReserve <= 0;
						tempUSBDat <= 16'd0;
						TestLED <= ~TestLED;
						
						Stat <= Idle;
					end
				//Detect a data
				else if (preDatReady == 0 && USBRReady == 1)       //Received a data
					begin                                      
							tempUSBDat <= USBRcv;
							
							if (USBRcv[7:0] == 8'h01 || USBRcv[7:0] == 8'h02 || USBRcv[7:0] == 8'h03 || USBRcv[7:0] == 8'h04 || USBRcv[7:0] == 8'h05 || USBRcv[7:0] == 8'h06) begin //Effective order							
								Stat <= Work;
							end
							else begin
								Stat <= Idle; //Ignore the invalid command
							end
					end
				//Nothing happened	
				else 
					begin
							EnReserve <= 0; //Generate the trig
							
							Stat <= Idle;
					end
				end
			Work: //Decoding the command from computer
				begin
					case (tempUSBDat[7:0])
					Test:
						begin
							EnTest <= 1;
							EnSingle <= 0;
							EnTwin <= 0;
							EnData <= 0;
							EnReserve <= 0;
							TestLED <= ~TestLED;
							
							Stat <= Idle;
						end
					Single:
						begin
							EnTest <= 0;
							EnSingle <= 1;
							EnTwin <= 0;
							EnData <= 0;
							EnReserve <= 0;
							
							Stat <= Idle;
						end
					Twin:
						begin
							EnTest <= 0;
							EnSingle <= 0;
							EnTwin <= 1;
							EnData <= 0;
							EnReserve <= 0;
							
							Stat <= Idle;
						end
					Data:
						begin
							EnTest <= 0;
							EnSingle <= 0;
							EnTwin <= 0;
							EnData <= 1;
							EnReserve <= 0;
							
							Stat <= Idle;
						end
				   //Now used as parameter adjust, e.g. PGA gain
					Reserve:
						begin
							EnTest <= 0;
							EnSingle <= 0;
							EnTwin <= 0;
							EnData <= 0;
							EnReserve <= 1;
							
							Stat <= Idle;
						end
					Stop:
						begin
							if (FrameEnd) begin               //Whole frame ends
								EnTest <= 0;
								EnSingle <= 0;
								EnTwin <= 0;
								EnData <= 0;
								EnReserve <= 0;
								
								Stat <= Idle;
							end
							else begin                        //Wait for a frame ends
								tempUSBDat[7:0] <= Stop;
								Stat <= Work;
							end							
						end
					
					default: tempUSBDat <= 16'd0;
					endcase		
				end
			
			default: Stat <= Idle;
			endcase
		
		end
		
endmodule			
				
				
				
				