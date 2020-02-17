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

module HoldZeroCtrl
(   
	 Sync,
	 Rst,
	 DDSIn,
	 EnExcit,
	 DDSOut,
	 periodCnt
);
    //Parameters
	 parameter SamplePeriod = 8'd9;  //1 zero, 1 idle, 4 sample, 1 finish (idle) 50us    -9
	 parameter Zero = 14'b10000000000000;
	 
	 //Define

	 
	 //Interface
	 input Sync;                    //Sync Signal for Holding Zero Strategy
	 input Rst;
	 input EnExcit;
	 input [13:0] DDSIn;
	 
	 output [13:0] DDSOut;    
	 output reg [7:0] periodCnt;
	 
	 reg SinOutSel;                 //Original code
	 
	 //Below is the code for holding zero strategy
	 /*
	 assign DDSOut = SinOutSel? DDSIn : Zero;
	 always @ (posedge Sync)
		if (EnExcit) begin
			if (periodCnt == 8'd0) begin
				SinOutSel <= 0;
			end
			else begin
				SinOutSel <= 1;
			end
			
			//One switch data finished
			if (periodCnt == SamplePeriod) begin
				periodCnt <= 8'd0;
			end
			else begin
				periodCnt <= periodCnt + 8'd1;
			end
		end
		else begin
			SinOutSel <= 0;
			periodCnt <= 8'd0;
		end
	 */
		
	 assign DDSOut = DDSIn;
	
	 always @ (posedge Sync or negedge Rst)
		if (!Rst) begin
			periodCnt <= 8'd0;
		end
		else if (EnExcit) begin
			//One switch data finished
			if (periodCnt == SamplePeriod) begin
				periodCnt <= 8'd0;
			end
			else begin
				periodCnt <= periodCnt + 8'd1;
			end
		end
		else if (EnExcit == 0)begin
			periodCnt <= 8'd0;
		end

endmodule
