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
// CREATED		"Thu Jan 16 22:07:53 2020"

module ECTNew(
	inclk0,
	RstBtn,
	OTR1,
	OTR2,
	FIFOEmp,
	FIFOFull,
	FIFOPf,
	USBFlagD,
	AD9240In1,
	AD9240In2,
	DDSClk,
	LED1,
	LED2,
	LED3,
	LED4,
	CS,
	WR,
	ADCLK2,
	ADCLK1,
	IFClk,
	USBInt0,
	USBSloe,
	USBSlrd,
	USBSlwr,
	PKTEND,
	Sync,
	AD7524Out,
	FIFOAdr,
	PGA1,
	PGA2,
	SineOut,
	SwitchCtrl,
	USBDat
);


input wire	inclk0;
input wire	RstBtn;
input wire	OTR1;
input wire	OTR2;
input wire	FIFOEmp;
input wire	FIFOFull;
input wire	FIFOPf;
input wire	USBFlagD;
input wire	[13:0] AD9240In1;
input wire	[13:0] AD9240In2;
output wire	DDSClk;
output wire	LED1;
output wire	LED2;
output wire	LED3;
output wire	LED4;
output wire	CS;
output wire	WR;
output wire	ADCLK2;
output wire	ADCLK1;
output wire	IFClk;
output wire	USBInt0;
output wire	USBSloe;
output wire	USBSlrd;
output wire	USBSlwr;
output wire	PKTEND;
output wire	Sync;
output wire	[7:0] AD7524Out;
output wire	[1:0] FIFOAdr;
output wire	[2:0] PGA1;
output wire	[2:0] PGA2;
output wire	[13:0] SineOut;
output wire	[63:0] SwitchCtrl;
inout wire	[15:0] USBDat;


wire	Busy;
wire	Ch1En;
wire	Ch2En;
wire	CLK_10M;
wire	CLK_1M;
wire	CLK_30M;
wire	CLK_30M_180;
wire	CLK_50M;
wire	[15:0] Cmd;
wire	[13:0] CosRef;
wire	DDSValid;
wire	[31:0] Demod1Result;
wire	[31:0] Demod2Result;
wire	[31:0] Demod3Result;
wire	[31:0] Demod4Result;
wire	EnExcit;
wire	FrameEnd;
wire	[31:0] FreqMod;
wire	OverFlow1;
wire	OverFlow2;
wire	[7:0] periodCnt;
wire	[31:0] PhaseInc;
wire	[15:0] PhaseMod;
wire	SetGainTrig;
wire	[13:0] SinRef;
wire	Sync_ALTERA_SYNTHESIZED;
wire	SysRst;
wire	[1:0] SysStat;
wire	USBEmpty;
wire	[11:0] USBFIFONum;
wire	USBFull;
wire	[12:0] USBNum;
wire	[15:0] USBRcv;
wire	USBRReady;
wire	USBRreq;
wire	[15:0] USBSend;
wire	[63:0] USBWrite;
wire	USBWRreq;
wire	SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_1;
wire	SYNTHESIZED_WIRE_2;
wire	SYNTHESIZED_WIRE_3;
wire	SYNTHESIZED_WIRE_4;
wire	SYNTHESIZED_WIRE_5;
wire	SYNTHESIZED_WIRE_6;
wire	[13:0] SYNTHESIZED_WIRE_7;
wire	SYNTHESIZED_WIRE_8;
wire	SYNTHESIZED_WIRE_9;
wire	SYNTHESIZED_WIRE_10;
wire	SYNTHESIZED_WIRE_11;
wire	SYNTHESIZED_WIRE_12;






SysIndicators	b2v_inst(
	.CLK1M(CLK_1M),
	.RST(SysRst),
	.SysStat(SysStat),
	.LED1(LED1),
	.LED2(LED2),
	.LED3(LED3));
	defparam	b2v_inst.Check = 2'b01;
	defparam	b2v_inst.FlashCnt = 20'b11110100001001000000;
	defparam	b2v_inst.Idle = 2'b00;
	defparam	b2v_inst.Work = 2'b10;


assign	SYNTHESIZED_WIRE_5 = SYNTHESIZED_WIRE_0 | SYNTHESIZED_WIRE_1;

assign	EnExcit = SYNTHESIZED_WIRE_2 | SYNTHESIZED_WIRE_3 | 0 | SYNTHESIZED_WIRE_4;


PGACtrl	b2v_inst12(
	.CLK(CLK_50M),
	.RST(SysRst),
	.SetTrig(SetGainTrig),
	
	
	.Cmd(Cmd),
	
	.PGA1(PGA1),
	.PGA2(PGA2));


SamplingCtrl	b2v_inst13(
	.Clk(CLK_50M),
	.Rst(SysRst),
	.Sync(Sync_ALTERA_SYNTHESIZED),
	.FrameEnd(FrameEnd),
	.DemodReady(SYNTHESIZED_WIRE_5),
	.USBFull(USBFull),
	.Demod1Result(Demod1Result),
	.Demod2Result(Demod2Result),
	.Demod3Result(Demod3Result),
	.Demod4Result(Demod4Result),
	.NumFIFO(USBFIFONum),
	.periodCnt(periodCnt),
	.USBWRreq(USBWRreq),
	.Busy(Busy),
	
	.USBWrite(USBWrite));


SwitchCtrl	b2v_inst14(
	.CLK(CLK_50M),
	.Rst(SysRst),
	.Sync(Sync_ALTERA_SYNTHESIZED),
	.EnExcit(EnExcit),
	.Command(Cmd),
	.periodCnt(periodCnt),
	.Ch1En(Ch1En),
	.FrameEnd(FrameEnd),
	.Ch2En(Ch2En),
	.SwitchCtrl(SwitchCtrl));


USBCtrl	b2v_inst15(
	.IFCLK(CLK_30M),
	.RST(SysRst),
	.FIFOEmp(FIFOEmp),
	.FIFOFull(FIFOFull),
	.FIFOPf(FIFOPf),
	.USBFlagD(USBFlagD),
	.USBEmpty(USBEmpty),
	.Send(USBSend),
	.USBDat(USBDat),
	.USBNum(USBNum),
	.RReady(USBRReady),
	.USBInt0(USBInt0),
	.USBSloe(USBSloe),
	.USBSlrd(USBSlrd),
	.USBSlwr(USBSlwr),
	.PKTEND(PKTEND),
	
	.USBRreq(USBRreq),
	.FIFOAddr(FIFOAdr),
	.Receive(USBRcv)
	
	
	);
	defparam	b2v_inst15.EP2 = 2'b00;
	defparam	b2v_inst15.EP4 = 2'b01;
	defparam	b2v_inst15.EP6 = 2'b10;
	defparam	b2v_inst15.EP8 = 2'b11;
	defparam	b2v_inst15.IDLE = 4'b0000;
	defparam	b2v_inst15.RDONE = 4'b0011;
	defparam	b2v_inst15.READ = 4'b0010;
	defparam	b2v_inst15.WDONE = 4'b0101;
	defparam	b2v_inst15.WRITE = 4'b0100;


altpll0	b2v_inst16(
	.inclk0(inclk0),
	.areset(0),
	.c0(CLK_30M),
	.c1(CLK_50M),
	.c2(CLK_10M),
	.c3(CLK_1M),
	.c4(CLK_30M_180)
	);


DDSCtrl	b2v_inst17(
	.FreqMod(FreqMod),
	.PhaseInc(PhaseInc),
	.PhaseMod(PhaseMod));
	defparam	b2v_inst17.Freq100KHz = 42949673;
	defparam	b2v_inst17.Freq1MKHz = 429496730;
	defparam	b2v_inst17.Freq200KHz = 85899346;
	defparam	b2v_inst17.Freq500KHz = 214748365;
	defparam	b2v_inst17.FrMod = 32'b00000000000000000000000000000000;
	defparam	b2v_inst17.PhMod = 16'b0000000000000000;

assign	SYNTHESIZED_WIRE_12 = SYNTHESIZED_WIRE_6 & Ch1En;

assign	SYNTHESIZED_WIRE_6 =  ~Busy;



HoldZeroCtrl	b2v_inst20(
	.Sync(Sync_ALTERA_SYNTHESIZED),
	.Rst(SysRst),
	.EnExcit(EnExcit),
	.DDSIn(SYNTHESIZED_WIRE_7),
	.DDSOut(SineOut),
	.periodCnt(periodCnt));
	defparam	b2v_inst20.SamplePeriod = 9;
	defparam	b2v_inst20.Zero = 14'b10000000000000;


USBFIFO	b2v_inst21(
	.wrreq(USBWRreq),
	.wrclk(CLK_50M),
	.rdreq(USBRreq),
	.rdclk(CLK_30M),
	.aclr(SYNTHESIZED_WIRE_8),
	.data(USBWrite),
	.wrfull(USBFull),
	.rdempty(USBEmpty),
	.q(USBSend),
	.rdusedw(USBNum),
	.wrusedw(USBFIFONum));

assign	SYNTHESIZED_WIRE_9 =  ~Busy;

assign	SYNTHESIZED_WIRE_11 = SYNTHESIZED_WIRE_9 & Ch2En;

assign	SYNTHESIZED_WIRE_10 = OverFlow2 | OverFlow1;

assign	LED4 =  ~SYNTHESIZED_WIRE_10;


SysInit	b2v_inst3(
	.CLK(CLK_50M),
	.RstBtn(RstBtn),
	.TrigOut(SysRst));
	defparam	b2v_inst3.TrigPrd = 5;


DDS	b2v_inst4(
	.CLK(CLK_10M),
	.RST(SysRst),
	.CLKEN(1),
	.FreqMod(FreqMod),
	.PhaseInc(PhaseInc),
	.PhaseMod(PhaseMod),
	.Sync(Sync_ALTERA_SYNTHESIZED),
	
	.DDSClk(DDSClk),
	.CosOut(CosRef),
	.DDS(SYNTHESIZED_WIRE_7),
	.SinOut(SinRef));

assign	SYNTHESIZED_WIRE_8 =  ~SysRst;


DDSRef	b2v_inst6(
	.CLK(CLK_50M),
	.RST(SysRst),
	.CS(CS),
	.WR(WR),
	.AD7524Out(AD7524Out));
	defparam	b2v_inst6.RefHigh = 8'b11111111;


DigitalDemodulation	b2v_inst7(
	.CLK(CLK_10M),
	.RST(SysRst),
	.Sync(Sync_ALTERA_SYNTHESIZED),
	.Enable(SYNTHESIZED_WIRE_11),
	.OTR(OverFlow2),
	.CosRef(CosRef),
	.DataIn(AD9240In2),
	.periodCnt(periodCnt),
	
	.SinRef(SinRef),
	.DemodReady(SYNTHESIZED_WIRE_0),
	
	.Demod1Result(Demod3Result),
	.Demod2Result(Demod4Result)
	);


MasterStateMachine	b2v_inst8(
	.Clk(CLK_50M),
	.Rst(SysRst),
	.USBRReady(USBRReady),
	.FrameEnd(FrameEnd),
	.USBRcv(USBRcv),
	
	.EnSingle(SYNTHESIZED_WIRE_2),
	.EnTwin(SYNTHESIZED_WIRE_4),
	.EnData(SYNTHESIZED_WIRE_3),
	.EnReserve(SetGainTrig),
	
	.Cmd(Cmd),
	.Stat(SysStat));
	defparam	b2v_inst8.Data = 16'b0000000000000100;
	defparam	b2v_inst8.Idle = 2'b00;
	defparam	b2v_inst8.Reserve = 16'b0000000000000101;
//	defparam	b2v_inst8.SData = 8'b00000100;
	defparam	b2v_inst8.Single = 16'b0000000000000010;
	defparam	b2v_inst8.Stop = 16'b0000000000000110;
//	defparam	b2v_inst8.StopOK = 10'b0000000001;
//	defparam	b2v_inst8.TData = 8'b00000101;
	defparam	b2v_inst8.Test = 16'b0000000000000001;
	defparam	b2v_inst8.Twin = 16'b0000000000000011;
	defparam	b2v_inst8.Work = 2'b01;


DigitalDemodulation	b2v_inst9(
	.CLK(CLK_10M),
	.RST(SysRst),
	.Sync(Sync_ALTERA_SYNTHESIZED),
	.Enable(SYNTHESIZED_WIRE_12),
	.OTR(OverFlow1),
	.CosRef(CosRef),
	.DataIn(AD9240In1),
	.periodCnt(periodCnt),
	
	.SinRef(SinRef),
	.DemodReady(SYNTHESIZED_WIRE_1),
	
	.Demod1Result(Demod1Result),
	.Demod2Result(Demod2Result)
	);

assign	OverFlow2 = OTR2;
assign	OverFlow1 = OTR1;
assign	ADCLK2 = CLK_10M;
assign	ADCLK1 = CLK_10M;
assign	IFClk = CLK_30M_180;
assign	Sync = Sync_ALTERA_SYNTHESIZED;


endmodule
