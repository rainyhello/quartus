`timescale 1ns/1ps
//**************************************************************//
//**************************************************************//
//Project Name: Novel ECT Hardware Design
//
//Author: Yunjie Yang
//Create  Date: 16:16 2014-11-15
//Design  Name: ECTNew
//Module  Name: DemodCtrl
//Target Devices: EP3C25F324C8
//Tool versions: 13.1
//Descriptions: Digital Demodulation Control.
//Revision:
//**************************************************************//
//**************************************************************//

module DemodCtrl
(
    CLK, RST, 
	 Sync, periodCnt, ChEn,
	 SamplePNum,
	 OTR, DataIn, DataOut, OverFlow, DemodRdy,
	 Aclr, ClkMultEn
);
    //Parameters
	 parameter SampNum = 200;       //Sampling numbers for digital demodulation, refer to Cnt to check the upper bound
	 parameter SampleStart = 8'd6;  //Start point for sampling (4 periods)  6
	 
	 //Define
	 
	 
	 //Interface
	 input CLK, RST;
	 input Sync;
	 input [7:0] periodCnt;
	 input ChEn;
	 input [15:0] SamplePNum;     //Reserved, for computer control
	 
	 input OTR;                   //AD9240 overflow flag
	 input [13:0] DataIn;         //AD9240 sampling data
    output reg [13:0] DataOut;   //Data for digital demodulation
	 output reg OverFlow;         //Indicator for PGA module
	 output reg DemodRdy;         //1 data demodulation done, effective high

	 output reg Aclr;             //Asychronous clear for MAC and Mult ADD
	 output reg ClkMultEn;        //Clock enable
	 
	 	 
	 //Internal variables
	 reg [3:0] Stat;              //State machine state
	 reg [10:0] Cnt;              //Counting for sampling, support maximum sampling number for one demod: 2047
	 reg [7:0] Cnt1;              //Counting for idle cycles waiting for the result
	 reg DemodEn;
    
	 
	 //Sampling Enable
	 always @ (posedge Sync or negedge RST)
		if (!RST) begin
			DemodEn <= 0;
		end
		else if (periodCnt == SampleStart) begin  //Ctrls the start point
			//Channel
			if (ChEn) begin
				DemodEn <= 1;
			end
			else begin
				DemodEn <= 0;
			end
		end
		else if (periodCnt == 1) begin
			DemodEn <= 0;
		end
	 
	 //Sampling
	 always @ (posedge CLK or negedge RST)
		if (!RST) begin
			DataOut <= 0;
			OverFlow <= 0;
			DemodRdy <= 0;
			Aclr <= 1;
			ClkMultEn <= 0;
			
			Cnt <= 11'd0;
			Cnt1 <= 8'd0;
			Stat <= 4'd0;
			end
		else if (DemodEn) begin
			case (Stat)
			0: begin                     //Prepare to do MAC
					DataOut <= 0;
					OverFlow <= 0;
					Aclr <= 0;             //Disable the clear for all the internal modules
					ClkMultEn <= 1;
					DemodRdy <= 0;         //Clear the ready signal
					
					Cnt <= 11'd0;
					Cnt1 <= 8'd0;
					Stat <= 4'd1;      
				end
			1: begin
					if (Cnt == SampNum) begin
						DataOut <= 0;
						OverFlow <= 0;
						Cnt <= 11'd0;
						
						Stat <= 4'd2;
					end
					else begin
						Cnt <= Cnt + 11'd1;
						DataOut <= DataIn;
						OverFlow <= OTR;
						
						Stat <= 4'd1;
					end
				end
			2: begin
					if (Cnt1 == 8'd4) begin   //Waiting for 4 clock cycles to get the final result
						DemodRdy <= 1;
						Stat <= 4'd2;
					end
					else begin
						Cnt1 <= Cnt1 + 8'd1;
					end
				end
				
			default: Stat <= 4'd0;
			endcase
		end
		else if (!DemodEn) begin
			DemodRdy <= 0;
			DataOut <= 0;
			OverFlow <= 0;
			Aclr <= 1;
			ClkMultEn <= 0;
			Cnt <= 11'd0;
			Cnt1 <= 8'd0;
			Stat <= 4'd0;
		end
			
endmodule
	 