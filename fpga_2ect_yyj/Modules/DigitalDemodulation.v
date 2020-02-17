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
// CREATED		"Thu Jan 16 21:16:09 2020"

module DigitalDemodulation(
	CLK,
	RST,
	Enable,
	OTR,
	Sync,
	CosRef,
	DataIn,
	periodCnt,
	SamplePNum,
	SinRef,
	DemodReady,
	OverFlow,
	Demod1Result,
	Demod2Result
);


input wire	CLK;
input wire	RST;
input wire	Enable;
input wire	OTR;
input wire	Sync;
input wire	[13:0] CosRef;
input wire	[13:0] DataIn;
input wire	[7:0] periodCnt;
input wire	[15:0] SamplePNum;
input wire	[13:0] SinRef;
output wire	DemodReady;
output wire	OverFlow;
output wire	[31:0] Demod1Result;
output wire	[31:0] Demod2Result;


wire	Aclr;
wire	ClkMult;
wire	ClkMultEn;
wire	[13:0] SYNTHESIZED_WIRE_9;
wire	SYNTHESIZED_WIRE_1;
wire	SYNTHESIZED_WIRE_2;
wire	[31:0] SYNTHESIZED_WIRE_10;
wire	[31:0] SYNTHESIZED_WIRE_11;
wire	[63:0] SYNTHESIZED_WIRE_7;


//ip_convert2	ip_convert2_inst (
//	.aclr (  Aclr ),
//	.clk_en ( ClkMultEn ),
//	.clock ( ClkMult ),
//	.dataa ( atan_sig ),
//	.result ( result_sig )
//	);
//
//ip_atan	ip_atan_inst (
//	.aclr ( Aclr ),
//	.clk_en ( ClkMultEn ),
//	.clock ( ClkMult ),
//	.data ( convert_sig ),
//	.result ( atan_sig )
//	);
//
//
//ip_convert	ip_convert_inst (
//	.aclr ( Aclr ),
//	.clk_en ( ClkMultEn ),
//	.clock ( ClkMult ),
//	.dataa ( quotient_sig ),
//	.result ( convert_sig )
//	);
//
//ip_lpm_divide	ip_lpm_divide_inst (
//	.aclr ( Aclr ),
//	.clken ( ClkMultEn ),
//	.clock ( ClkMult ),
//	.denom ( SYNTHESIZED_WIRE_10 ),
//	.numer ( SYNTHESIZED_WIRE_11 ),
//	.quotient ( quotient_sig ),
//	.remain ( remain_sig )
//	);



Altmult_accum0	b2v_inst(
	.clock0(ClkMult),
	.aclr0(Aclr),
	.ena0(ClkMultEn),
	.dataa(SinRef),
	.datab(SYNTHESIZED_WIRE_9),
	.overflow(SYNTHESIZED_WIRE_2),
	.result(Demod1Result));


DemodCtrl	b2v_inst1(
	.CLK(CLK),
	.RST(RST),
	.Sync(Sync),
	.ChEn(Enable),
	.OTR(OTR),
	.DataIn(DataIn),
	.periodCnt(periodCnt),
	.SamplePNum(SamplePNum),
	
	.DemodRdy(DemodReady),
	.Aclr(Aclr),
	.ClkMultEn(ClkMultEn),
	.DataOut(SYNTHESIZED_WIRE_9));
	defparam	b2v_inst1.SampleStart = 8'b00000110;
	defparam	b2v_inst1.SampNum = 200;

assign	OverFlow = SYNTHESIZED_WIRE_1 | SYNTHESIZED_WIRE_2;


//Almult_Add0	b2v_inst11(
//	.clock0(ClkMult),
//	.aclr0(Aclr),
//	.ena0(ClkMultEn),
//	.dataa_0(SYNTHESIZED_WIRE_10),
//	.dataa_1(SYNTHESIZED_WIRE_11),
//	.datab_0(SYNTHESIZED_WIRE_10),
//	.datab_1(SYNTHESIZED_WIRE_11),
//	.result(SYNTHESIZED_WIRE_7));

assign	ClkMult =  ~CLK;


//altsqrt0	b2v_inst13(
//	.radical(SYNTHESIZED_WIRE_7),
//	.q(DemodResult),
//	.remainder(remainder));


Altmult_accum0	b2v_inst9(
	.clock0(ClkMult),
	.aclr0(Aclr),
	.ena0(ClkMultEn),
	.dataa(CosRef),
	.datab(SYNTHESIZED_WIRE_9),
	.overflow(SYNTHESIZED_WIRE_1),
	.result(Demod2Result));


endmodule
