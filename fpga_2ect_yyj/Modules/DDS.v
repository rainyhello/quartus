// Copyright (C) 1991-2013 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.

// PROGRAM		"Quartus II 64-Bit"
// VERSION		"Version 13.1.0 Build 162 10/23/2013 SJ Full Version"
// CREATED		"Thu Jan 16 22:01:36 2020"

module DDS(
	CLK,
	RST,
	CLKEN,
	FreqMod,
	PhaseInc,
	PhaseMod,
	DDSValid,
	DDSClk,
	Sync,
	CosOut,
	DDS,
	SinOut
);


input wire	CLK;
input wire	RST;
input wire	CLKEN;
input wire	[31:0] FreqMod;
input wire	[31:0] PhaseInc;
input wire	[15:0] PhaseMod;
output wire	DDSValid;
output wire	DDSClk;
output wire	Sync;
output wire	[13:0] CosOut;
output wire	[13:0] DDS;
output wire	[13:0] SinOut;


wire	[31:0] SYNTHESIZED_WIRE_0;
wire	[13:0] SYNTHESIZED_WIRE_1;
wire	[31:0] SYNTHESIZED_WIRE_2;

assign	DDSClk = CLK;
assign	SinOut = SYNTHESIZED_WIRE_1;




NCO	b2v_inst(
	.clk(CLK),
	.reset_n(RST),
	.clken(CLKEN),
	.freq_mod_i(FreqMod),
	.phase_mod_i(PhaseMod),
	.phi_inc_i(SYNTHESIZED_WIRE_0),
	.out_valid(DDSValid),
	.fcos_o(CosOut),
	.fsin_o(SYNTHESIZED_WIRE_1));


TestDDS	b2v_inst1(
	
	.PhaseInc(SYNTHESIZED_WIRE_2)
	);
	defparam	b2v_inst1.Freq100KHz = 42949673;
	defparam	b2v_inst1.Freq1MKHz = 429496730;
	defparam	b2v_inst1.Freq200KHz = 85899346;
	defparam	b2v_inst1.Freq500KHz = 214748365;
	defparam	b2v_inst1.FrMod = 0;
	defparam	b2v_inst1.PhMod = 0;


HoldZero	b2v_inst2(
	.SinIn(SYNTHESIZED_WIRE_1),
	.Sync(Sync),
	.SinOut(DDS));


busmux_0	b2v_inst3(
	.sel(1),
	.dataa(SYNTHESIZED_WIRE_2),
	.datab(PhaseInc),
	.result(SYNTHESIZED_WIRE_0));



endmodule

module busmux_0(sel,dataa,datab,result);
/* synthesis black_box */

input sel;
input [31:0] dataa;
input [31:0] datab;
output [31:0] result;

endmodule
