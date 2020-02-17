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

module UARTArbitrate
(
    DataLockIn1, DataLockIn2, DataLock, 
	 SendA, SendB, Send,
	 Enable
);
    //Parameters
	 
	 //Define
	 
	 input Enable;
	 input DataLockIn1, DataLockIn2;
	 input [7:0] SendA;
	 input [7:0] SendB;
	 
	 output DataLock;
	 output [7:0] Send;
	 
	 assign DataLock = Enable? DataLockIn2 : DataLockIn1;
	 assign Send = Enable? SendB : SendA;
	 
endmodule
