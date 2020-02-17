`timescale 1ns/1ps
//**************************************************************//
//**************************************************************//
//Project Name: Novel ECT Hardware Design
//
//Author: Yunjie Yang
//Create  Date: 16:16 2014-11-15
//Design  Name: ECTNew
//Module  Name: SystemInitial
//Target Devices: EP3C25F324C8
//Tool versions: 13.1
//Descriptions: This module generate a global reset pulse when power on, as well as interface a external reset button.
//The module will output a poweron RST signal after 20 cycles, which will last 5 cycles. Also, if RstBtn is pushed, the system will immediately rst. 

//Test Bench: SysInit_TB.v

//Revision: 11/12/14: Add TestBench, revised the function

//**************************************************************//
//**************************************************************//

module SysInit
(
    CLK, TrigOut,RstBtn
);
    //Parameters
	 parameter TrigPrd = 30; //Reset pulse lasting time
	 
	 //Define
	 
	 
	 //Interface
	 input CLK, RstBtn;
    output TrigOut;        //Global reset pulse
    
	 wire TrigOut;
	 reg AutoRst;           //Power on Rst
    reg[15:0] Cnt;         //Counter reg
    reg[4:0] Stat, Temp;   //States
    
    
    always @( posedge CLK or negedge RstBtn)    // Asynchronous operation
    begin
        if( RstBtn==0 )       // One delta t ready
        begin
            Cnt <= 0;
				Temp <= 0;
				AutoRst <= 1;
        end
        else begin
            case(Stat)
            0:
				begin
					 AutoRst <= 1;
					 Cnt <= 0;
					 Stat <= 1;
				end
				1:
            begin
					 if( Cnt >= 40)    // After 40 clk cycles, autoRst, which lasts 40 clk cycles
                begin
						  Stat <= 2;
						  Temp <= 0;
                end
					 else begin
						  Stat <= 1;
						  Cnt <= Cnt + 16'd1;
					 end
            end
            2:
            begin
					 AutoRst <= 0;
					 if (Temp == TrigPrd+1) begin
						Stat <= Temp;
					 end
					 else begin
						Temp <= Temp + 5'd1;
						Stat <= 2;
					 end
            end
            (TrigPrd+1):
            begin
					AutoRst <= 1;
					Stat <= Stat;
            end
            default:    Stat <= 0;
            endcase
        end
    end
	 
	 assign TrigOut = RstBtn && AutoRst; 
	 
endmodule
