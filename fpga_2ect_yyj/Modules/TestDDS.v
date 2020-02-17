`timescale 1ns/1ps
//**************************************************************//
//**************************************************************//
//Project Name: Novel ECT Hardware Design
//
//Author: Yunjie Yang
//Create  Date: 16:16 2014-11-15
//Design  Name: ECTNew
//Module  Name: TestDDS
//Target Devices: EP3C25F324C8
//Tool versions: 13.1
//Descriptions: This module.
//Revision:
//**************************************************************//
//**************************************************************//

module TestDDS
(
    PhaseInc, PhaseMod, FreqMod
);
    //Parameters
	 parameter Freq100KHz = 42949673;  //100 KHz FreWord
	 parameter Freq200KHz = 85899346;  //200 KHz FreWord
	 parameter Freq500KHz = 214748365; //500 KHz FreWord
	 parameter Freq1MKHz = 429496730; //1 MHz FreWord
	 
	 parameter FrMod = 32'd0;   //Frequency increasement
	 parameter PhMod = 16'd0;   //Phase increasement
	 
	 //Define
	 
	 
	 //Interface
    output [31:0] PhaseInc;        //Frequency Ctrl Word
	 output [31:0] FreqMod;         //Frequency Modification
    output [15:0] PhaseMod;        //Phase Modification
    
	 assign PhaseInc = Freq200KHz;
	 assign FreqMod = FrMod;
	 assign PhaseMod = PhMod;
	 
endmodule
	 