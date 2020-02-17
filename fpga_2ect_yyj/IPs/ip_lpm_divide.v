// megafunction wizard: %LPM_DIVIDE%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: LPM_DIVIDE 

// ============================================================
// File Name: ip_lpm_divide.v
// Megafunction Name(s):
// 			LPM_DIVIDE
//
// Simulation Library Files(s):
// 			lpm
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 13.1.0 Build 162 10/23/2013 SJ Full Version
// ************************************************************


//Copyright (C) 1991-2013 Altera Corporation
//Your use of Altera Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Altera Program License 
//Subscription Agreement, Altera MegaCore Function License 
//Agreement, or other applicable license agreement, including, 
//without limitation, that your use is for the sole purpose of 
//programming logic devices manufactured by Altera and sold by 
//Altera or its authorized distributors.  Please refer to the 
//applicable agreement for further details.


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module ip_lpm_divide (
	aclr,
	clken,
	clock,
	denom,
	numer,
	quotient,
	remain);

	input	  aclr;
	input	  clken;
	input	  clock;
	input	[31:0]  denom;
	input	[31:0]  numer;
	output	[31:0]  quotient;
	output	[31:0]  remain;

	wire [31:0] sub_wire0;
	wire [31:0] sub_wire1;
	wire [31:0] remain = sub_wire0[31:0];
	wire [31:0] quotient = sub_wire1[31:0];

	lpm_divide	LPM_DIVIDE_component (
				.aclr (aclr),
				.clock (clock),
				.clken (clken),
				.denom (denom),
				.numer (numer),
				.remain (sub_wire0),
				.quotient (sub_wire1));
	defparam
		LPM_DIVIDE_component.lpm_drepresentation = "SIGNED",
		LPM_DIVIDE_component.lpm_hint = "LPM_REMAINDERPOSITIVE=TRUE",
		LPM_DIVIDE_component.lpm_nrepresentation = "SIGNED",
		LPM_DIVIDE_component.lpm_pipeline = 1,
		LPM_DIVIDE_component.lpm_type = "LPM_DIVIDE",
		LPM_DIVIDE_component.lpm_widthd = 32,
		LPM_DIVIDE_component.lpm_widthn = 32;


endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone III"
// Retrieval info: PRIVATE: PRIVATE_LPM_REMAINDERPOSITIVE STRING "TRUE"
// Retrieval info: PRIVATE: PRIVATE_MAXIMIZE_SPEED NUMERIC "-1"
// Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "0"
// Retrieval info: PRIVATE: USING_PIPELINE NUMERIC "1"
// Retrieval info: PRIVATE: VERSION_NUMBER NUMERIC "2"
// Retrieval info: PRIVATE: new_diagram STRING "1"
// Retrieval info: LIBRARY: lpm lpm.lpm_components.all
// Retrieval info: CONSTANT: LPM_DREPRESENTATION STRING "SIGNED"
// Retrieval info: CONSTANT: LPM_HINT STRING "LPM_REMAINDERPOSITIVE=TRUE"
// Retrieval info: CONSTANT: LPM_NREPRESENTATION STRING "SIGNED"
// Retrieval info: CONSTANT: LPM_PIPELINE NUMERIC "1"
// Retrieval info: CONSTANT: LPM_TYPE STRING "LPM_DIVIDE"
// Retrieval info: CONSTANT: LPM_WIDTHD NUMERIC "32"
// Retrieval info: CONSTANT: LPM_WIDTHN NUMERIC "32"
// Retrieval info: USED_PORT: aclr 0 0 0 0 INPUT NODEFVAL "aclr"
// Retrieval info: USED_PORT: clken 0 0 0 0 INPUT NODEFVAL "clken"
// Retrieval info: USED_PORT: clock 0 0 0 0 INPUT NODEFVAL "clock"
// Retrieval info: USED_PORT: denom 0 0 32 0 INPUT NODEFVAL "denom[31..0]"
// Retrieval info: USED_PORT: numer 0 0 32 0 INPUT NODEFVAL "numer[31..0]"
// Retrieval info: USED_PORT: quotient 0 0 32 0 OUTPUT NODEFVAL "quotient[31..0]"
// Retrieval info: USED_PORT: remain 0 0 32 0 OUTPUT NODEFVAL "remain[31..0]"
// Retrieval info: CONNECT: @aclr 0 0 0 0 aclr 0 0 0 0
// Retrieval info: CONNECT: @clken 0 0 0 0 clken 0 0 0 0
// Retrieval info: CONNECT: @clock 0 0 0 0 clock 0 0 0 0
// Retrieval info: CONNECT: @denom 0 0 32 0 denom 0 0 32 0
// Retrieval info: CONNECT: @numer 0 0 32 0 numer 0 0 32 0
// Retrieval info: CONNECT: quotient 0 0 32 0 @quotient 0 0 32 0
// Retrieval info: CONNECT: remain 0 0 32 0 @remain 0 0 32 0
// Retrieval info: GEN_FILE: TYPE_NORMAL ip_lpm_divide.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL ip_lpm_divide.inc FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL ip_lpm_divide.cmp FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL ip_lpm_divide.bsf FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL ip_lpm_divide_inst.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL ip_lpm_divide_bb.v TRUE
// Retrieval info: LIB_FILE: lpm
