`timescale 1ns/1ps
//**************************************************************//
//**************************************************************//
//Project Name: Novel ECT Hardware Design
//
//Author: Yunjie Yang
//Create  Date: 16:16 2014-11-15
//Design  Name: ECTNew
//Module  Name: USBCtrl
//Target Devices: EP3C25F324C8
//Tool versions: 13.1
//Descriptions: This module realizes the Slave FIFO methods of USB2.0.
//Revision:
//**************************************************************//
//**************************************************************//

module USBTest
(
    CLK, RST, 
	 //Internal ctrl signal
	 WEnable, WDone, Send, WCnt,           //Number to write
	 REnable, RReady, Receive, RcvOut, RCnt        //Number to readt	 
);
    //Parameters
	 
	 
	 //Define

	 
	 
	 //FIFO Interface
	 input CLK, RST;
	 input WDone, RReady;
	 input [15:0] Receive;
	 output reg WEnable, REnable;
	 output reg [15:0] Send;
	 output reg [15:0] RcvOut;
	 
	 output reg [9:0] WCnt;               //Write numbers for external logic, max 1023 numbers. Number to Write!!!
	 output reg [9:0] RCnt;                    //Read numbers for external logic, max 1023 numbers. Number to Read!!!
	 
	 
	 //Internal Variables
	 reg [3:0] StatW;
	 reg [3:0] StatR;            
	 
	 //Write Test
	 always @ (posedge CLK or negedge RST)
	 
		if (!RST) begin
			WEnable <= 0;
			Send <= 0;
			WCnt <= 0;
			StatW <= 4'd0;
		end
		else begin
			case (StatW)
			0: begin
					WEnable <= 0;
					Send <= 0;
					WCnt <= 10;
					StatW <= 1;
				end
//			1: begin
//			      WEnable <= 1;
//					Send <= 16'h12FA;
//					StatW <= 4'd2;
//				end
//			2: begin
//					if (WDone) begin
//						StatW <= 4'd3;
//					end
//					else begin
//						StatW <= StatW;
//					end
//				end
//			3: begin
//					WEnable <= 0;
//					Send <= 0;
//					WCnt <= 0;
//					StatW <= 4'd3;
//				end
				
			 default: StatW <= 0;
			 endcase
		end
		
	 //Read Test
	 always @ (posedge CLK or negedge RST)
	 
		if (!RST) begin
			REnable <= 0;
			RCnt <= 0;
			RcvOut <= 0;
			StatR <= 4'd0;
		end
		else begin
			/*case (StatR)
			0: begin
					REnable <= 0;
					RCnt <= 1;
					StatR <= 1;
				end
			1: begin
			      REnable <= 1;
					StatR <= 4'd2;
				end
			2: begin
					if (RReady) begin
				      RcvOut <= Receive;
						StatR <= 4'd3;
					end
					else begin
						StatR <= StatR;
					end
				end
			3: begin
					REnable <= 0;
					RCnt <= 0;
					StatR <= 4'd3;
				end
				
			 default: StatR <= 0;
			 endcase*/
		end
		
						
endmodule
