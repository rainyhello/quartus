`timescale 1ns/1ps
//**************************************************************//
//**************************************************************//
//Project Name: Novel ECT Hardware Design
//
//Author: Yunjie Yang
//Create  Date: 16:16 2014-11-15
//Design  Name: ECTNew
//Module  Name: DDSRef
//Target Devices: EP3C25F324C8
//Tool versions: 13.1
//Descriptions: This module.
//Revision:
//**************************************************************//
//**************************************************************//

module DDSRef
(
    CLK, RST, CS, WR, AD7524Out
);
    //Parameters
	 parameter RefHigh = 8'b11111111;  //Highest Reference
	 
	 //Define
	 
	 
	 //Interface
	 input CLK, RST;
    output CS;                //Chip Strobe effective low
	 output WR;                //Write enable, effective low
    output [7:0] AD7524Out;   //AD7524 data pins
	 
	 reg CS;
    reg WR;
    reg [7:0] AD7524Out;
	 
	 reg [4:0] Stat;           //State machine state
    
	 always @ (posedge CLK or negedge RST)
	 
		if (!RST) begin
			CS <= 1;
			WR <= 1;
			AD7524Out <= 0;
			
			Stat <= 0;
			end
		else begin
			case (Stat)
			0: begin
				CS <= 0;
				WR <= 1;
				AD7524Out <= RefHigh;
				Stat <= 1;
				end
			1: begin
				WR <= 0;
				Stat <= Stat + 5'd1;
				end
			12: begin          //WR should keep low at least 180ns
				WR <= 1;
				CS <= 1;
				Stat <= 10;
				end
			default: Stat <= Stat + 5'd1;
			endcase
		end
			
endmodule
	 