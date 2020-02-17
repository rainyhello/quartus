`timescale 1ns/1ps
//**************************************************************//
//**************************************************************//
//Project Name: Novel ECT Hardware Design
//
//Author: Yunjie Yang
//Create  Date: 16:16 2014-11-15
//Design  Name: ECTNew
//Module  Name: CtrlProc
//Target Devices: EP3C25F324C8
//Tool versions: 13.1
//Descriptions: This module.
//Revision:
//**************************************************************//
//**************************************************************//

module CtrlProc
(
    Clk, Rst, PhaseInc, PhaseMod, FreqMod,
	 UARTDatReady, UARTReceive,//
	 UARTAvl, UARTDatLock, UARTSend,
	 LED,
	 DemodEn, DemodReady, DemodResult,
	 ADSampleEn
);
    //Parameters
	 parameter Freq100KHz = 42949673;  //100 KHz FreWord
	 parameter Freq200KHz = 85899346;  //200 KHz FreWord
	 parameter Freq500KHz = 214748365; //500 KHz FreWord
	 parameter Freq1MKHz = 429496730; //1 MHz FreWord
	 
	 parameter FrMod = 32'd0;   //Frequency increasement
	 parameter PhMod = 16'd0;   //Phase increasement
	 
	 //Define
	 
	 
	 //Interface
	 input Clk, Rst;
    output [31:0] PhaseInc;        //Frequency Ctrl Word
	 output [31:0] FreqMod;         //Frequency Modification
    output [15:0] PhaseMod;        //Phase Modification
	 
	 input UARTDatReady;
	 input [7:0] UARTReceive;
	 
	 input UARTAvl;
	 output reg [7:0] UARTSend;
	 output reg UARTDatLock;
	 output reg LED;
	 
	 output reg ADSampleEn;	 
	 	 
	 input DemodReady;
	 input [31:0] DemodResult;
	 output reg DemodEn;	 
	 
	 reg [7:0] Stat;
	 reg [3:0] Stat1;
	 reg preDatReady;
	 reg [7:0] tempUARTDat;
	 reg [31:0] tempDemod;
	 reg [3:0] Cnt; 
	 
			
	 assign PhaseInc = Freq200KHz;
	 assign FreqMod = FrMod;
	 assign PhaseMod = PhMod;
	 
	 
	 always @ (posedge Clk or negedge Rst)
		if (Rst==0) begin
			LED <= 0;
			UARTSend <= 0;
			UARTDatLock <= 0;
			preDatReady <= 0;
			tempUARTDat <= 0;
			DemodEn <= 0;
			tempDemod <= 0;
			Cnt <= 0;
			ADSampleEn <= 0;
			
			Stat <= 0;
			Stat1 <= 0;
		end
		else begin
			preDatReady <= UARTDatReady;
			case (Stat)
			0: //Waiting a data/command from UART
			begin
				if (preDatReady == 0 && UARTDatReady == 1) begin //Received a data
					tempUARTDat <= UARTReceive;
								UARTDatLock <= 0;
								UARTSend <= UARTReceive;
								Stat <= Stat + 8'd1;
							end
					else begin
								Stat <= 0;
							end
				end
				1://Send the received data back to UI
				begin
					if (UARTAvl == 1) begin
							UARTDatLock <= 1;
							Stat <= 2;
						end
				   else begin
							Stat <= 1;
						end				
				end
				2://Command Mapping
				begin
					case (tempUARTDat)
					8'h01://Test the Com
							begin
								LED <= ~LED;
								Stat <= 0;
							end
					8'h02://Start Demod one time
							begin
							case (Stat1)
							0: begin					
								DemodEn <= 1;
								tempDemod <= 0;
								Stat1 <= 1;
								end
							1: begin
								if (DemodReady) begin
									tempDemod <= DemodResult;
									DemodEn <= 0;
									Cnt <= 0;
									Stat1 <= 2;
								end
								else begin
									Stat1 <= 1;
								end
								end
							2: begin
								if (Cnt == 4) begin
									Stat1 <= 0;
									Stat <= 0;
									Cnt <= 0;
								end
								else begin
									UARTDatLock <= 0;
									UARTSend <= tempDemod [31:24];
									tempDemod <= (tempDemod << 8);
									Cnt <= Cnt + 4'd1;
									Stat1 <= 3;
								end
								end
							3: begin
									if (UARTAvl) begin
										UARTDatLock <= 1;
										Stat1 <= 2;
									end
									else begin
										Stat1 <= 3;
									end
								end
							default: Stat1 <= 0;
							endcase									
							end
				   8'h03://Start Taking data from AD
							begin										
								ADSampleEn <= 1;
								Stat <= 0;
							end
					8'h04://Stop Sampling
							begin
								ADSampleEn <= 0;
								Stat <= 0;
							end
					default: Stat <= 0;
					endcase
				end
			default: Stat <= 0;
			endcase
		end		
		
	 
endmodule
	 