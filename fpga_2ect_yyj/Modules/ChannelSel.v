`timescale 1ns/1ps
//**************************************************************//
//**************************************************************//
//Project Name: Novel ECT Hardware Design
//
//Author: Yunjie Yang
//Create  Date: 16:16 2014-11-15
//Design  Name: ECTNew
//Module  Name: ChannelSel
//Target Devices: EP3C25F324C8
//Tool versions: 13.1
//Descriptions: Channel Selection.
//Revision:
//**************************************************************//
//**************************************************************//

module ChannelSel
(
    Sel, Otr0, Otr1, AD0Dat, AD1Dat,
	 Otr, ADDat,
	 DemodRdy0, DemodRdy1,
	 DemodRdy,
	 Demod0Rslt, Demod1Rslt,
	 DemodRslt 
);
    //Parameters

	 
	 
	 //Define
	 
	 
	 //Interface
	 input Sel;
	 
	 input [13:0] AD0Dat, AD1Dat;
	 input Otr0, Otr1;
	 output [13:0] ADDat;
	 output Otr;
	             
	 input DemodRdy0, DemodRdy1;
	 input [31:0] Demod0Rslt, Demod1Rslt;
	 output [31:0] DemodRslt;
	 output DemodRdy;
	 
	 
	 
	 assign ADDat = Sel? AD1Dat : AD0Dat;
	 assign Otr =  Sel? Otr1 : Otr0;
	 
	 assign DemodRdy = Sel? DemodRdy1 : DemodRdy0;
	 assign DemodRslt = Sel? Demod1Rslt : Demod0Rslt;

endmodule

	 
	 
