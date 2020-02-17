`timescale 1ns/1ps
//**************************************************************//
//**************************************************************//
//Project Name: Novel ECT Hardware Design
//
//Author: Yunjie Yang
//Create  Date: 16:16 2014-11-15
//Design  Name: ECTNew
//Module  Name: AD9240Ctrl
//Target Devices: EP3C25F324C8
//Tool versions: 13.1
//Descriptions: This module is the AD9240 control module.
//Revision:
//**************************************************************//
//**************************************************************//

module AD9240Ctrl
(
    CLK, RST, Enable, OTR, DataIn, DataOut, OverFlow
);
    //Parameters
	 parameter SampNum = 200;  //Sampling numbers for digital demodulation
	 
	 //Define
	 
	 
	 //Interface
	 input CLK, RST, Enable;
	 input OTR;               //Overflow flag
	 input [13:0] DataIn;     //AD9240 sampling data
    output [13:0] DataOut;   //Data for digital demodulation
	 output OverFlow;         //Indicator for PGA module
	 
    reg [13:0] DataOut;
	 reg OverFlow;
	 reg [3:0] Stat;           //State machine state
    
	 always @ (posedge CLK or negedge RST)
	 
		if (!RST) begin
			DataOut <= 0;
			OverFlow <= 0;
			Stat <= 0;
			end
		else if (Enable) begin
			case (Stat)
			0: begin
				DataOut <= 0;
				OverFlow <= 0;
				Stat <= Stat + 1;
				end
			4: begin
				DataOut <= DataIn ^ 14'b10000000000000;
				OverFlow <= OTR;
				Stat <= 4;
				end
								
			default: Stat <= Stat + 1;
			endcase
		end
		else begin
			DataOut <= DataOut;
			Stat <= 0;
		end
			
endmodule
	 