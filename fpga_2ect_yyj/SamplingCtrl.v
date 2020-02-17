//**************************************************************//
//**************************************************************//
//Project Name: Novel ECT Hardware Design
//
//Author: Yunjie Yang
//Create  Date: 16:16 2014-11-15
//Design  Name: ECTNew
//Module  Name: SamplingCtrl
//Target Devices: EP3C25F324C8
//Tool versions: 13.1
//Descriptions: This module realizes the holding zero strategy
//Revision:
//**************************************************************//
//**************************************************************//

module SamplingCtrl
(   
	 Clk, Rst,
	 Sync, FrameEnd, periodCnt,
	 DemodReady,
	 Demod1Result,Demod2Result,Demod3Result,Demod4Result,
	 USBWrite, USBWRreq, USBFull, NumFIFO,
	 Busy,
	 TestLED
);
    //Parameters

	 
	 //Define

	 
	 //Interface
	 input Clk;
	 input Rst;
	 input Sync;
	 input FrameEnd;
	 input [7:0] periodCnt;
	 
	 //Sampling Channels Ctrl Signal
	 input DemodReady;
//	 input signed[31:0] Demod1Result,Demod2Result,Demod3Result,Demod4Result;
	 input [31:0] Demod1Result;
	 input [31:0] Demod2Result;
	 input [31:0] Demod3Result;
	 input [31:0] Demod4Result;
	 //USB Interface
	 input USBFull;
	 input [11:0] NumFIFO;
	 output reg USBWRreq;
	 output reg [31:0] USBWrite;
	 
	 output reg Busy;
	 output reg TestLED;              //For debug application
	 
	 //Internal varables
	 reg [3:0] Stat;
	 reg [3:0] Stat1;
	 reg [31:0] tempUSBData;
	 wire  [63:0] tmpdata1,tmpdata2;
	 wire  [15:0] data1,data2;
	 
	//Detecting frameEnd and submit the short pkt
	always @ (posedge Clk or negedge Rst)
		if (!Rst) begin
			USBWrite <= 32'd0;
			USBWRreq <= 0;
			tempUSBData <= 32'd0;
			Busy <= 0;
		   TestLED <= 1;
			
			Stat <= 4'd0;
			Stat1 <= 4'd0;
		end
		//DemodReady
		else if (DemodReady || Busy) begin   //Put the result into USB FIFO
			case (Stat)
			0: begin
					tempUSBData <= {data1,data2};  //Here only keep the highest two bytes and abandon the low bytes
					Stat <= 4'd1;
				end
			1: begin
					if (!USBFull) begin //USB FIFO not full
						USBWRreq <= 1;
						USBWrite <= tempUSBData;
						Stat <= 4'd2;
						Busy <= 0;
					end
					else begin
						Stat <= 4'd1;    //If full, wait
						Busy <= 1;
					end
				end
			2: begin
					USBWRreq <= 0;
					Stat <= 4'd2;       //Stay here until next round
					Stat1 <= 4'd0;
				end
			default: Stat <= 4'd0;
			endcase
		end
		else if (!DemodReady && !Busy) begin
				USBWRreq <= 0;
				tempUSBData <= 32'd0;
				Stat <= 4'd0;
				
				//One frame ends, put end packet and send the short pkt;
				if (FrameEnd == 1) begin                             
					case (Stat1)
					0: begin
							TestLED <= 0;
							if (!USBFull) begin
								USBWRreq <= 1;
								USBWrite <= 32'hFAFAE0E0;//每次的数据FAFA在最前面两个字节，E0E0在最后两个字节，中间的数据才是有效数据
								Stat1 <= 4'd1;
							end
							else begin
								Stat1 <= 4'd0;
							end
						end
					1: begin
							USBWRreq <= 0;
							Stat1 <= 4'd1;
						end
					 default: Stat1 <= 4'd0;
					 endcase
				end
		end					


//下面的操作是将32位的补码转为16位补码
assign tmpdata1 =  Demod1Result[31]?{Demod1Result[31],~Demod1Result[30:0]+1'b1}:{Demod1Result[31:0]};//正负数的补码转原码
assign tmpdata2 =  Demod2Result[31]?{Demod1Result[31],~Demod2Result[30:0]+1'b1}:{Demod2Result[31:0]};
	
//assign tmpdata1 =  $unsigned(Demod1Result);//有符号数转无符号数
//assign tmpdata2 =  $unsigned(Demod2Result);//没有正负之分
//
assign data1 = Demod1Result[31]?{1'b1,~tmpdata1[30:16]+1'b1}:{tmpdata1[31:16]};//再将原码转换为补码
assign data2 = Demod2Result[31]?{1'b1,~tmpdata1[30:16]+1'b1}:{tmpdata2[31:16]};

endmodule
