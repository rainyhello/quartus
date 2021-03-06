`timescale 1ns/1ps
//**************************************************************//
//**************************************************************//
//Project Name: Novel ECT Hardware Design
//
//Author: Yunjie Yang
//Create  Date: 16:16 2014-11-15
//Design  Name: ECTNew
//Module  Name: LEDIndicators
//Target Devices: EP3C25F324C8
//Tool versions: 13.1
//Descriptions: This module.
//Revision:
//**************************************************************//
//**************************************************************//

module LEDIndicators
(
    CLK, TrigOut,RstBtn
);
    //Parameters
	 parameter TrigPrd = 5; //Reset pulse lasting time
	 
	 //Define
	 
	 
	 //Interface
	 input CLK, RstBtn;
    output TrigOut;        //Global reset pulse
    
	 reg TrigOut;
    reg[15:0] Cnt0, Cnt1;  //Counter reg
    reg[4:0] Stat;         //States
    
    
    always @( posedge CLK or negedge RstBtn)    // Asynchronous operation
    begin
        if( RstBtn==0 )       // One delta t ready
        begin
            Cnt0 <= 0;
            Cnt1 <= 0;
            Stat <= 0;
        end
        
        else
        begin
            case( Stat )
            0:
            begin
                if( Cnt1 >= TrigOut)    // Count 40000 X trig_prd X 25 ns (50 MHz) = 0.5 s (default)
                begin
                    Stat <= 5;
                end
					 
                else
                begin
                    TrigOut <= 1;
                    if( Cnt0 >= 400 )  
                    begin
                        Cnt0 <= 0;
                        Cnt1 <= Cnt1 + 1;
                    end
                    else    
								Cnt0 <= Cnt0 + 1;
                end
            end
            3:
            begin
                Cnt0 <= 0;
                Cnt1 <= 0;
                Stat <= 0;
            end
            5:
            begin
            TrigOut <= 0;
            Stat <= 6;
            end
            9:
            begin
            TrigOut <= 1;
            Stat <= 9;       // Stay here and never trig again, except restart!
            end
            
            default:    Stat <= Stat + 1;
            endcase
        end
    end
	 
endmodule
