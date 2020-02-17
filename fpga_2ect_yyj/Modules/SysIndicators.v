//**************************************************************//
//**************************************************************//
//Project Name: Novel ECT Hardware Design
//
//Author: Yunjie Yang
//Create  Date: 16:16 2014-11-15
//Design  Name: ECTNew
//Module  Name: SysIndicators
//Target Devices: EP3C25F324C8
//Tool versions: 13.1
//Descriptions: This module controls the indicator LEDs according to system states.
//Revision:
//**************************************************************//
//**************************************************************//

module SysIndicators
(
	 CLK1M,                         //LED Flash CLK
	 RST,
	 SysStat,                       //System Working State
	 LED1, LED2, LED3               //LED Interfaces
);
    //Parameters: working state
	 parameter Idle = 2'b00;    //State waiting for command
	 parameter Check = 2'b01;   //State waiting for command
	 parameter Work = 2'b10;    //State received command
	 
	 parameter FlashCnt = 20'd1000000; //Flash freq 1Hz
	 //Define

	 
	 //Interface
	 input CLK1M;
	 input RST;
	 
	 input [1:0] SysStat;
	 
	 output reg LED1;
	 output reg LED2;
	 output reg LED3;
	 
	 //Internal regs
	 reg [19:0] Cnt;
	 reg [3:0] Stat;
	 reg Trig;
	 
	 //Flash Ctrl
	 always @ (posedge CLK1M or negedge RST)
		if (!RST) begin
			Stat <= 0;
			Cnt <= 0;
			Trig <= 0;
		end
		else begin
			case (Stat)
			0: begin
					Cnt <= 0;
					Trig <= 0;
					Stat <= 1;
				end
			1: begin
					if (Cnt == FlashCnt) begin
							Cnt <= 0;
							Trig  <= 1;
							Stat <= 0;
					end
					else begin
							Cnt <= Cnt + 20'd1;
							Stat <= 1;
					end
				end
			default: Stat <= 0;
			endcase
		end

	 //Indicators
	 always @ (posedge CLK1M or negedge RST)
		if (!RST) begin
			LED1 <= 1;
			LED2 <= 1;
			LED3 <= 1;
		end
		else if (Trig) begin
			case (SysStat)
			Idle: begin
					LED1 <= ~LED1;
					end
			Check: begin
					LED2 <= ~LED2;
					 end
			Work: begin
					LED3 <= ~LED3;
					end
			default: begin
						LED1 <= 1;
						LED2 <= 1;
						LED3 <= 1;
						end
			endcase
		end
			
		
endmodule
		
				
				
				
				
				
				
				
				