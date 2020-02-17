`timescale 1ns/1ps
//**************************************************************//
//**************************************************************//
//Project Name: Novel ECT Hardware Design
//
//Author: Yunjie Yang
//Create  Date: 16:16 2014-11-15
//Design  Name: ECTNew
//Module  Name: SwitchDefault
//Target Devices: EP3C25F324C8
//Tool versions: 13.1
//Descriptions: This module reset the electrodes to GND D2D1: 10.
//Revision:
//**************************************************************//
//**************************************************************//

module SwitchDefault
(
	Clr, Cmd, q1e, q2e, q3e, q4e, q5e, q6e,
	SwitchData, measNum,
	Ch1En, Ch2En
);
	
	//Excitation: 11
	//Measure:    00
	//GND: 		  10
	
	parameter SwitchDefault = 64'hAAAAAAAAAAAAAAAA; //All GND
	parameter s8es = 16'h0102;
   parameter s12es = 16'h1102;
   parameter p8es = 16'h0202;
   parameter p12es = 16'h1202;
	parameter s8et = 16'h0103;
   parameter s12et = 16'h0203;
	parameter sData = 16'h0104;
	parameter tData = 16'h0204;
	
	input Clr;
	input [15:0] Cmd;
	input [63:0] q1e;  //8e single
	input [63:0] q2e;  //8e semi par
	input [63:0] q3e;  //8e twin
	input [63:0] q4e;  //12e single
	input [63:0] q5e;  //12e semi par
	input [63:0] q6e;  //12e twin
	
	output [63:0] SwitchData;
	output reg [7:0] measNum;
	output reg Ch1En;           //Demod ch1 en
	output reg Ch2En;           //Demod ch2 en
	
	assign SwitchData = Clr? SwitchDefault : switchData;
	
	initial begin
		measNum = 8'd2;
		Ch1En = 0;
		Ch2En = 0;
	end	
	
	reg [63:0] switchData;
	
	always @(Cmd)
		case (Cmd)
		s8es: //8e single
			begin
				switchData = q1e;
				measNum = 8'd28;
				Ch1En = 1;
				Ch2En = 0;
			end
		p8es: //8e semi par
			begin
				switchData = q2e;
				measNum = 8'd16;
				Ch1En = 1;
				Ch2En = 1;
			end	
		s8et: //8e twin
			begin
				switchData = q3e;
				measNum = 8'd28;
				Ch1En = 1;
				Ch2En = 1;
			end		
		s12es: //12e single
			begin
				switchData = q4e;
				measNum = 8'd66;
				Ch1En = 1;
				Ch2En = 0;
			end
		p12es: //12e semi par
			begin
				switchData = q5e;
				measNum = 8'd44;
				Ch1En = 1;
				Ch2En = 1;
			end
		s12et: //12e twin
			begin
				switchData = q6e;
				measNum = 8'd66;
				Ch1En = 1;
				Ch2En = 1;
			end
		sData: //single data
			begin
				switchData = 64'hAAAAAAAAAAAAAAA3;   //1-2
				measNum = 8'd1;
				Ch1En = 1;
				Ch2En = 0;
			end
		tData: //twin data
			begin
				switchData = 64'hAAAAAAAAAAAAA3A3;   //1-2  5-6
				measNum = 8'd1;
				Ch1En = 1;
				Ch2En = 1;
			end
		
		default: switchData = SwitchDefault;
		endcase
	
endmodule
	