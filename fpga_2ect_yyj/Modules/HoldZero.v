//**************************************************************//
//**************************************************************//
//Project Name: Novel ECT Hardware Design
//
//Author: Yunjie Yang
//Create  Date: 16:16 2014-11-15
//Design  Name: ECTNew
//Module  Name: HoldZero
//Target Devices: EP3C25F324C8
//Tool versions: 13.1
//Descriptions: This module realizes the holding zero strategy
//Revision:
//**************************************************************//
//**************************************************************//

module HoldZero
(
    SinIn, SinOut,
	 Sync
);
    //Parameters
	 
	 //Define

	 
	 //Interface
	 input [13:0] SinIn;    //Two's comple code
	 
	 output [13:0] SinOut;  //Original code
	 output Sync;           //Sync Signal for Holding Zero Strategy
	 
	 assign SinOut={~SinIn[13], SinIn[12:0]}; //Change from two's comple to original binary
	 assign Sync=SinIn[13];
		
endmodule
