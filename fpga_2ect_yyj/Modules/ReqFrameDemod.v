//**************************************************************//
//**************************************************************//
//Project Name: Novel ECT Hardware Design
//
//Author: Yunjie Yang
//Create  Date: 16:16 2014-11-15
//Design  Name: ECTNew
//Module  Name: ReqFrameDemod
//Target Devices: EP3C25F324C8
//Tool versions: 13.1
//Descriptions: This module request one frame demodulation from two channels.
//Revision:
//**************************************************************//
//**************************************************************//

module ReqFrameDemod
(
    Clk, Rst,
	 SysState,     //System state
	 Enable, Done, //Hand shaking signal
	 Sync,
	 
	 SwitchAddr, SwitchCLKEn, SwitchCLR, MeasIndex, SwitchData,
	 
	 USBFIFOFul,USBWrite,USBWreq,NumFIFO,ApplyUSB,
	 
	 DemodEn1Ch, DemodReady1Ch, DemodResult1Ch, //Channel 1
	 DemodEn2Ch, DemodReady2Ch, DemodResult2Ch, //Channel 2
	 
	 TestLED   //For debug purpose
);
    //Parameters: command word
	 parameter ReqFrameDmd = 16'h0004; //State request one frame demodulation
	 parameter OnlyCh1 = 2'd1;      //Only using ch1
	 parameter OnlyCh2 = 2'd2;      //Only using ch2
	 parameter BothChs = 2'd3;      //Both Channels, for twin plane sensor
	 
	 
	 //Define

	 
	 //Interface
	 input Clk, Rst;
	 input Sync;
	 
	 input [15:0] SysState;
	 input Enable;
	 
	 input USBFIFOFul;
	 input [9:0] NumFIFO;
	 output reg [31:0] USBWrite;
	 output reg USBWreq;
	 output reg ApplyUSB;
	 
	 input [63:0] SwitchData;
	 input [1:0] MeasIndex;
	 output reg [8:0] SwitchAddr;
	 output reg SwitchCLKEn;
	 output reg SwitchCLR;
	 
	 input DemodReady1Ch;
	 input DemodReady2Ch;
	 input [31:0] DemodResult1Ch;
	 input [31:0] DemodResult2Ch;
	 output reg DemodEn1Ch;
	 output reg DemodEn2Ch;
	 
	 output reg Done;                  //Finish
	 output reg TestLED;               //For debug purpose
	 
	 //Interal regs
	 reg [15:0] CntW;
	 reg [7:0] Stat;
	 
	 
	 //This is the code for both channels
	 always @ (posedge Clk or negedge Rst)
		if (!Rst) begin
			USBWrite <= 32'd0;
			USBWreq <= 0;
	      ApplyUSB <= 0;
			
			SwitchAddr <= 0;
			SwitchCLKEn <= 0;
			SwitchCLR <= 1;
			
			DemodEn1Ch <= 0;
			DemodEn2Ch <= 0;
			Done <= 0;
			
			TestLED <= 1;

		   CntW <= 16'd0;
			Stat <= 8'd0;
		end
		///////////////////////////////////////////////////////////////Channel 1 and Channel 2
		else if (Enable == 1 && SysState == ReqFrameDmd) begin
			case (Stat)
			0: //Clear all the SwitchArray: GND,
			begin
				USBWreq <= 0;
				
				SwitchCLKEn <= 0;    
				SwitchCLR   <= 0;    //Clr all electrodes to GND
				SwitchAddr <= 0;
				
				DemodEn1Ch <= 0;
				DemodEn2Ch <= 0;
				
				Done <= 0;
				
				CntW <=0;            //Counter for settling time
				
				Stat <= 1;
			end
			1: 
			begin
				SwitchCLKEn <= 1;    //Set the SwitchArray, ADG1433 trans time == 200ns
				SwitchCLR <= 1;
				ApplyUSB <= 1;
				
				Stat <= Stat + 1;
			end
			12:                     //Waiting for the signal settling to stable
			begin
				if (CntW	== 16'd3000) begin    //Signal settling time 2us
					CntW <= 16'd0;
					
					//Select meas channel
					if (MeasIndex == OnlyCh1) begin
						DemodEn1Ch <= 1;
					end
					else if (MeasIndex == OnlyCh2) begin
						DemodEn2Ch <= 1;
					end

					Stat <= 8'd13;
				end
				else begin
					CntW <= CntW + 16'd1;
					Stat <= 8'd12;
				end
			end
			13: //Recieve demod data
			begin
				if (SwitchAddr == 28) begin
					USBWrite <= 32'hABCDFAFA;
					Stat <= 8'd14;
				end
				else begin
					if (MeasIndex == OnlyCh1) begin
						if (DemodReady1Ch==1) begin
							DemodEn1Ch <= 0;
							USBWrite <= DemodResult1Ch;
							SwitchCLR <= 0;               //GND

							Stat <= 8'd14;
						end
						else begin
							Stat <= 8'd13;
						end
					end
					else if (MeasIndex == OnlyCh2) begin
						if (DemodReady2Ch==1) begin
							DemodEn2Ch <= 0;
							USBWrite <= DemodResult2Ch;
							SwitchCLR <= 0;               //GND
							
							Stat <= 8'd14;
						end
						else begin
							Stat <= 8'd13;
						end
					end
				end
			end
			14: //Send to FIFO
			begin
				if (!USBFIFOFul && NumFIFO < 1023) begin
					USBWreq <= 1;
					Stat <= 8'd15;
				end
				else begin
					Stat <= 8'd14;
				end
		   end
			15:
			begin
				USBWreq <= 0;
				Stat <= Stat + 8'd1;
			end
			23: 
			begin
				if (SwitchAddr == 28) begin             //Finished one frame!
					ApplyUSB <= 0;
					USBWrite <= 0;
					
					SwitchCLKEn <= 0;
					SwitchCLR   <= 0;
					SwitchAddr <= 0;
					TestLED <= 0;	
					Done <= 1;
						
					Stat <= 8'd24;
				end
				else begin
				   SwitchCLR <= 1;
					SwitchAddr <= SwitchAddr + 9'd1;
					Stat <= 8'd1;
				end
			end
			24: //Finished!
			begin		
				Stat <= 8'd24;
			end
			
			default: Stat <= Stat + 8'd1;
			endcase
		end
		else if (Enable == 0) begin
			Done <= 0;
			Stat <= 8'd0;
		end
		
endmodule
		
						