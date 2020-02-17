`timescale 1ns/1ps
//**************************************************************//
//**************************************************************//
//Project Name: Novel ECT Hardware Design
//
//Author: Yunjie Yang
//Create  Date: 16:16 2014-11-15
//Design  Name: ECTNew
//Module  Name: PGACtrl
//Target Devices: EP3C25F324C8
//Tool versions: 13.1
//Descriptions: This module realize the PGA control based on measurement index AND OTRs
//Revision:


//G2 G1 G0      Gain
//0  0  0       0.08
//0  0  1       0.16
//0  1  0       0.32
//0  1  1       0.63
//1  0  0       1.26
//1  0  1       2.52
//1  1  0       5.01
//1  1  0       10.0

//Command format
//Ch1        Ch2      
//0 1 1 1    0 1 1 1 [05]


//**************************************************************//
//**************************************************************//

module PGACtrl
(
    CLK, RST, 
	 SetTrig,                         //Set trig, 1 CLK
	 Cmd,
	 ADOtr1, ADOtr2,                  //Overflow flag of ADC
	 SwitchAddr,
	 PGA1, PGA2                       //PGA control bus
);
    //Parameters
	 
	 
	 //Macro Defination
	 
	 
	 //Interface for FIFO Rd
	 input CLK, RST;
	 input SetTrig;           //Set gain trig
	 input ADOtr1, ADOtr2;    //Overflow Flag
	 input [8:0] SwitchAddr;
	 input [15:0] Cmd;
	 
    output reg [2:0] PGA1;   //PGA1
	 output reg [2:0] PGA2;   //PGA2

	 //Internal Registers
	 //reg [3:0] Stat;        //State machine state
//	 reg [3:0] PGAL1;
//	 reg [3:0] PGAS1;
//	 reg [3:0] PGAL2;
//	 reg [3:0] PGAS2;
		

	 always @ (posedge CLK or negedge RST)
	 
		if (!RST) begin
			PGA1 <= 3'b011;
			PGA2 <= 3'b011;
			
//			PGAL1 <= 3'b011;
//			PGAS1 <= 3'b100;
//			PGAL2 <= 3'b011;
//			PGAS2 <= 3'b100;

		end

		else if (SetTrig) begin      //Set Gain
			PGA1 <= Cmd[14:12];       //Channel 1 
			PGA2 <= Cmd[10:8];        //Channel 2
		end
		/*
		else if (SetTrig) begin       //Set Gain
			PGAL1 <= Cmd[14:12];       //Channel 1
			PGAS1 <= Cmd[14:12]+3'b001;//Channel 1
			
			PGAL2 <= Cmd[10:8];        //Channel 2
			PGAS2 <= Cmd[10:8]+3'b001; //Channel 1 
		end
		/*
		//8-electrode
		else if (Cmd[11:8] == 4'b1000) begin
			// Adj
			if (SwitchAddr == 1 || SwitchAddr == 7 || SwitchAddr == 8 || SwitchAddr == 14 || SwitchAddr == 19 || SwitchAddr == 23 || SwitchAddr == 26 || SwitchAddr == 28) begin
				PGA1 <= PGAL1;        //Channel 1
			   PGA2 <= PGAL2;        //Channel 2		
			end
			else begin
				PGA1 <= PGAS1;        //Channel 1
			   PGA2 <= PGAS2;        //Channel 2			
			end
		end

		//12-electrode
		else begin
			if (SwitchAddr == 1 || SwitchAddr == 11 || SwitchAddr == 12 || SwitchAddr == 22 || SwitchAddr == 31 || SwitchAddr == 39 || SwitchAddr == 46 || SwitchAddr == 52 || SwitchAddr == 57 || SwitchAddr == 61 || SwitchAddr == 64 || SwitchAddr == 66) begin
				PGA1 <= PGAL1;        //Channel 1
			   PGA2 <= PGAL2;        //Channel 2			
			end
			else begin
				PGA1 <= PGAS1;        //Channel 1 
				PGA2 <= PGAS2;        //Channel 2
			end		
		end
	   */
			
endmodule
	 