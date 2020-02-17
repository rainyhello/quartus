`timescale 1ns/1ps
//**************************************************************//
//**************************************************************//
//Project Name: Novel ECT Hardware Design
//
//Author: Yunjie Yang
//Create  Date: 16:16 2014-11-15
//Design  Name: ECTNew
//Module  Name: ADSample
//Target Devices: EP3C25F324C8
//Tool versions: 13.1
//Descriptions: Direct AD Waveform sample.
//Revision:
//**************************************************************//
//**************************************************************//

module ADSample
(
    CLK, RST, Enable, OTR, DataIn, Done, SinRef, CosRef
);
    //Parameters
	 parameter SampNum = 500;  //Sampling numbers for One time, refer to Cnt to check the upper bound
	 
	 //Define
	 
	 
	 //Interface
	 input CLK, RST, Enable;      //10 MHz Clk
	 input OTR;                   //Overflow flag
	 input [13:0] DataIn;         //AD9240 sampling data
	 
	 input [13:0] SinRef;         //If want to sample the dds signal, change the signal source to this
	 input [13:0] CosRef;
	 
	 output reg Done;             //Finish the sample
	 reg [13:0] TempDat [SampNum-1:0]; //Internal memory to store the waveform
	 	 
	 //Internal variables
	 reg [3:0] Stat;              //State machine state
	 reg [10:0] Cnt;              //Counting for sampling, support maximum sampling number for one demod: 2047
	
	 //Sampling block
	 always @ (posedge CLK)
		if (Enable) begin
			case (Stat)
			0: begin                     //Prepare to do Get the data
					Cnt <= 11'd0;
					Done <= 0;
					Stat <= 4'd1;      
				end
			1: begin // Get SampNum data
					if (Cnt == SampNum) begin
						Done <= 1;
						Cnt <= 11'd0;
						Stat <= 4'd2;
					end
					else begin
						TempDat[Cnt] <= DataIn;
						Cnt <= Cnt + 11'd1;
						Stat <= 4'd1;
					end
				end
			2: begin
					Stat <= 2;                      //Wait for clear the enable signal
				end
	
			default: Stat <= 0;
			endcase
		end
		else if (~Enable) begin
			Cnt <= 0;
			Done <= 0;
			Stat <= 0;
		end
			
endmodule
	 