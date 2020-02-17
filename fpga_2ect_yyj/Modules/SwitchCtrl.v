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
// CREATED		"Thu Jan 16 21:17:01 2020"

module SwitchCtrl(
	CLK,
	Sync,
	EnExcit,
	Rst,
	Command,
	periodCnt,
	Ch1En,
	Ch2En,
	FrameEnd,
	SwitchCtrl
);


input wire	CLK;
input wire	Sync;
input wire	EnExcit;
input wire	Rst;
input wire	[15:0] Command;
input wire	[7:0] periodCnt;
output wire	Ch1En;
output wire	Ch2En;
output wire	FrameEnd;
output wire	[63:0] SwitchCtrl;


wire	[63:0] allGND;
wire	[63:0] q1e;
wire	[63:0] q2e;
wire	[63:0] q3e;
wire	[63:0] q4e;
wire	[63:0] q5e;
wire	[63:0] q6e;
wire	[63:0] qDataS;
wire	[63:0] qDataT;
wire	[8:0] SwitchAddr;
wire	[3:0] switchSel;
wire	SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_1;





SwitchArray	b2v_inst(
	.Clk(CLK),
	.Rst(Rst),
	.Sync(Sync),
	.EnExcit(EnExcit),
	.Cmd(Command),
	.periodCnt(periodCnt),
	.Ch1En(SYNTHESIZED_WIRE_0),
	.Ch2En(SYNTHESIZED_WIRE_1),
	.FrameEnd(FrameEnd),
	.allGNDSwitch(allGND),
	.SDataSwitch(qDataS),
	.switchAddr(SwitchAddr),
	.switchSel(switchSel),
	.TDataSwitch(qDataT));
	defparam	b2v_inst.PCh12eCali = 16'b1110110000000010;
	defparam	b2v_inst.PCh12eImg = 16'b1111110000000010;
	defparam	b2v_inst.PCh8eCali = 16'b1110100000000010;
	defparam	b2v_inst.PCh8eImg = 16'b1111100000000010;
	defparam	b2v_inst.SCh12eCali = 16'b0001110000000010;
	defparam	b2v_inst.SCh12eImg = 16'b0010110000000010;
	defparam	b2v_inst.SCh8eCali = 16'b0001100000000010;
	defparam	b2v_inst.SCh8eImg = 16'b0010100000000010;
	defparam	b2v_inst.SData = 16'b0001000000000100;
	defparam	b2v_inst.Stop = 16'b0000000000000110;
	defparam	b2v_inst.TCh12eCali = 16'b0001110000000011;
	defparam	b2v_inst.TCh12eImg = 16'b0010110000000011;
	defparam	b2v_inst.TCh8eCali = 16'b0001100000000011;
	defparam	b2v_inst.TCh8eImg = 16'b0010100000000011;
	defparam	b2v_inst.TData = 16'b0001000100000100;

assign	Ch1En = SYNTHESIZED_WIRE_0 & EnExcit;


SwitchROM12eSemi	b2v_inst10(
	.clock(CLK),
	.clken(1),
	.address(SwitchAddr[5:0]),
	.q(q5e));


SwitchMux	b2v_inst14(
	.data0x(allGND),
	.data1x(q1e),
	.data2x(q2e),
	.data3x(q3e),
	.data4x(q4e),
	.data5x(q5e),
	.data6x(q6e),
	.data7x(qDataS),
	.data8x(qDataT),
	.data9x(allGND),
	.sel(switchSel),
	.result(SwitchCtrl));


SwitchROM	b2v_inst3(
	.clock(CLK),
	.clken(1),
	.address(SwitchAddr[4:0]),
	.q(q1e));

assign	Ch2En = SYNTHESIZED_WIRE_1 & EnExcit;


SwitchROM8eSemi	b2v_inst5(
	.clock(CLK),
	.clken(1),
	.address(SwitchAddr[4:0]),
	.q(q2e));


SwitchROM12eS	b2v_inst6(
	.clock(CLK),
	.clken(1),
	.address(SwitchAddr[6:0]),
	.q(q4e));


SwitchROM8eTwin	b2v_inst8(
	.clock(CLK),
	.clken(1),
	.address(SwitchAddr[4:0]),
	.q(q3e));


SwitchROM12eTwin	b2v_inst9(
	.clock(CLK),
	.clken(1),
	.address(SwitchAddr[6:0]),
	.q(q6e));


endmodule
