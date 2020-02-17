//**************************************************************//
//**************************************************************//
//Project Name: Novel ECT Hardware Design
//
//Author: Yunjie Yang
//Create  Date: 16:16 2014-11-15
//Design  Name: ECTNew
//Module  Name: HoldZeroStrategy
//Target Devices: EP3C25F324C8
//Tool versions: 13.1
//Descriptions: This module realizes the holding zero strategy
//Revision:
//**************************************************************//
//**************************************************************//

module SwitchArray
(   
	 Clk, Rst, 
	 Sync, EnExcit, periodCnt, Cmd,
	 switchAddr,
	 switchSel,
	 Ch1En, Ch2En,
	 FrameEnd,
	 
	 SDataSwitch,
	 TDataSwitch,
	 allGNDSwitch
);
    //Parameters
	 parameter SCh8eCali = 16'h1802;
	 parameter SCh8eImg = 16'h2802;
	 parameter SCh12eCali = 16'h1C02;
	 parameter SCh12eImg = 16'h2C02;
	 parameter PCh8eCali = 16'hE802;
	 parameter PCh8eImg = 16'hF802;
	 parameter PCh12eCali = 16'hEC02;
	 parameter PCh12eImg = 16'hFC02;
	 parameter TCh8eCali = 16'h1803;
	 parameter TCh8eImg = 16'h2803;
	 parameter TCh12eCali = 16'h1C03;
	 parameter TCh12eImg = 16'h2C03;
	 parameter SData = 16'h1004;
	 parameter TData = 16'h1104;
	 parameter Stop = 16'h0006;
	 //Define

	 
	 //Interface
	 input Clk, Rst;
	 input Sync;                    //Sync Signal for Holding Zero Strategy
	 input EnExcit;
	 input [7:0] periodCnt;         //Indicators of one data sampling
	 input [15:0] Cmd;
	 
	 output reg [8:0] switchAddr;
	 output reg [3:0] switchSel;
	 output reg FrameEnd;             //Oneframe end flag
	 
	 output reg Ch1En, Ch2En;
	 
	 output [63:0] SDataSwitch;
	 output [63:0] TDataSwitch;
	 output [63:0] allGNDSwitch;
	 
	 assign SDataSwitch = 64'hAAAAAAAAAAAAAAA3;   //1-2
	 assign TDataSwitch = 64'hAAAAAAAAAAAAA3A3;   //1-2  5-6
	 
	 reg [8:0] tempIndex;
	 reg [7:0] measNum;             //Measurement number in one frame
	 
	 //Switch ROM Selection
	 always @(posedge Clk or negedge Rst)
		if (!Rst) begin
			switchSel <= 4'd0;
			measNum = 8'd0;
			Ch1En <= 0;
			Ch2En <= 0;
		end
		else if (EnExcit) begin
			case (Cmd)
			0: begin
					switchSel <= 4'd0;  //All GND
					measNum = 8'd0;
					Ch1En <= 0;
					Ch2En <= 0;
				end
			SCh8eCali: 					  //8e single channel calibration
				begin
					switchSel <= 4'd1;	
					measNum <= 8'd28;
					Ch1En <= 1;
					Ch2En <= 0;
				end
			SCh8eImg:                 //8e single channel image
				begin
					switchSel <= 4'd1;			
					measNum <= 8'd28;
					Ch1En <= 1;
					Ch2En <= 0;
				end	
			PCh8eCali: 					  //8e semi parallel calibration
				begin
					switchSel <= 4'd2;			
					measNum <= 8'd16;
					Ch1En <= 1;
					Ch2En <= 1;
				end		
			PCh8eImg:                 //8e semi parallel image
				begin
					switchSel <= 4'd2;			
					measNum <= 8'd16;
					Ch1En <= 1;
					Ch2En <= 1;
				end
			TCh8eCali: 					  //8e twin image calibration
				begin
					switchSel <= 4'd3;			
					measNum <= 8'd28;
					Ch1En <= 1;
					Ch2En <= 1;
				end
			TCh8eImg:                 //8e twin image
				begin
					switchSel <= 4'd3;			
					measNum <= 8'd28;
					Ch1En <= 1;
					Ch2En <= 1;
				end
			SCh12eCali: 				  //12e single channel calibration
				begin
					switchSel <= 4'd4;	
					measNum <= 8'd66;
					Ch1En <= 1;
					Ch2En <= 0;
				end
			SCh12eImg:                //12e single channel image
				begin
					switchSel <= 4'd4;			
					measNum <= 8'd66;
					Ch1En <= 1;
					Ch2En <= 0;
				end	
			PCh12eCali: 				  //8e semi parallel calibration
				begin
					switchSel <= 4'd5;			
					measNum <= 8'd44;
					Ch1En <= 1;
					Ch2En <= 1;
				end		
			PCh12eImg:                //12e semi parallel image
				begin
					switchSel <= 4'd5;			
					measNum <= 8'd44;
					Ch1En <= 1;
					Ch2En <= 1;
				end
			TCh12eCali: 				  //12e twin image calibration
				begin
					switchSel <= 4'd6;			
					measNum <= 8'd66;
					Ch1En <= 1;
					Ch2En <= 1;
				end
			TCh12eImg:                //12e twin image
				begin
					switchSel <= 4'd6;			
					measNum <= 8'd66;
					Ch1En <= 1;
					Ch2En <= 1;
				end
			SData: //single data
				begin
					switchSel <= 4'd7;			
					Ch1En <= 1;
					Ch2En <= 0;
				end
			TData: //twin data
				begin
					switchSel <= 4'd8;			
					Ch1En <= 1;
					Ch2En <= 1;
				end
			Stop: //Stop
				begin
					switchSel <= 4'd0;			
					Ch1En <= 0;
					Ch2En <= 0;
				end
		
		default: switchSel <= 4'd0;
		endcase
	end
	else if (EnExcit == 0) begin
		switchSel <= 4'd0;			
		Ch1En <= 0;
		Ch2En <= 0;
	end
		
	//Switch happens here	
	always @ (posedge Sync or negedge Rst)
		if (!Rst) begin
			switchAddr <= 9'd0;
		end
		else if (EnExcit == 1) begin
			if (periodCnt == 8'd0) begin
					if (switchAddr == measNum) begin             //Finished one frame
						switchAddr <= 9'd1;
					end
					else begin
						switchAddr <= switchAddr + 1;
					end
			end
		end
		else if (EnExcit == 0) begin
			switchAddr <= 9'd0;
		end
		
	//FrameEnd Signal
	always @ (posedge Sync or negedge Rst)
		if (!Rst) begin
			FrameEnd <= 0;
			tempIndex <= 9'd0;
		end
		else if (EnExcit == 1) begin
			if (periodCnt == 8'd1) begin
					if (tempIndex == measNum) begin              //Finished one frame Signal delay one cycle for signal setup
						tempIndex <= 9'd1;
						FrameEnd <= 1;
					end
					else begin
						tempIndex <= tempIndex + 9'd1;
						FrameEnd <= 0;
					end
			end
			else begin
				FrameEnd <= 0;
			end
		end
		else if (EnExcit == 0) begin
			tempIndex <= 9'd0;
			FrameEnd <= 0;
		end

endmodule
