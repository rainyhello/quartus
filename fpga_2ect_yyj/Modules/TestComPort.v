//**************************************************************//
//**************************************************************//
//Project Name: Novel ECT Hardware Design
//
//Author: Yunjie Yang
//Create  Date: 16:16 2014-11-15
//Design  Name: ECTNew
//Module  Name: TestComPort
//Target Devices: EP3C25F324C8
//Tool versions: 13.1
//Descriptions: This module is a sub sm to test the communication port.
//Revision:
//**************************************************************//
//**************************************************************//

module TestComPort
(
    Clk, Rst,
	 SysState, //System state
	 Enable, Done, //Hand shaking signal
	 TestLED
);
    //Parameters: command word
	 parameter TestCom = 16'h0001; //State waiting for command
	 
	 //Define

	 
	 //Interface
	 input Clk, Rst;
	 
	 input [15:0] SysState;
	 input Enable;
	 
	 output reg Done;           //Finish
	 output reg TestLED;        //For com test	 
	 
	 always @ (posedge Clk or negedge Rst)
		if (!Rst) begin			
			TestLED <= 1;  //Turn off the test led
			Done <= 0;
		end
		else if (Enable == 1 && SysState == TestCom) begin
			TestLED <= ~TestLED;
			Done <= 1;
		end
		else if (Enable == 0) begin
			Done <= 0;
		end
		
endmodule
		
				
				
				
				
				
				
				
				