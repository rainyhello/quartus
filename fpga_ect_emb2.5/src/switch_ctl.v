//==========================================================================
//Filename  :switch_ctl.v
//modulename:switch_ctl
//Author    :Xiaoqing.Huang
//Date	   :2118-11-02
//Function  :This is a top module, when give a rst signal, all module reset 
//Uesedfor  :Altera cyclon EP3C25F324C8, made by Huangxiaoqing.
//==========================================================================

//==========================================================================
//Input and output declaration
//==========================================================================

module switch_ctl	(
						//system input
						sys_clk,
						sys_rst,
						//input from pc spi
						sw_chn,
						//output to 8 switchs
						sw_data
					);
//-----------------------------input or output------------------------------
input  				sys_rst;
input  				sys_clk;
input		[7:0]		sw_chn;

output	[15:0]	sw_data;
//----------------------------wire  or  reg---------------------------------
wire					sys_clk;
wire					sys_rst;
wire		[1:0]		dev;
wire		[7:0]		sw_chn;

reg		[15:0]	sw_data;
//==========================================================================
/*
开关说明
每个开关对应两位，高位对应高编号开关，低位对应低编号开关
CB2CB1-->对应第一个开关8个开关就是CB16CB15_CB14CB13_CB12CB01 ... CB4CB3_CB2CB1

00		10		11		01
M		A		A		G
测量	激励	激励	地

*/
//下降沿的时候读取数据
always@(negedge sys_clk or negedge sys_rst)
begin
	if(!sys_rst)
		begin
			sw_data <= 16'h0000;
		end
	else// if(dev == 11)
		begin
			case(sw_chn)
				8'h00 : begin
						//开关序号	8	7	6	5	4	3	2	1
					sw_data <= 16'b01_01_01_01_01_01_00_11;		//1激励 2测量
				end
				8'h01 : begin
					sw_data <= 16'b01_01_01_01_01_00_01_11;		//1激励 3测量
				end
				8'h02 : begin
					sw_data <= 16'b01_01_01_01_00_01_01_11;		//1激励 4测量
				end
				8'h03 : begin
					sw_data <= 16'b01_01_01_00_01_01_01_11;		//1激励 5测量
				end
				8'h04 : begin
					sw_data <= 16'b01_01_00_01_01_01_01_11;		//1激励 6测量
				end
				8'h05 : begin
					sw_data <= 16'b01_00_01_01_01_01_01_11;		//1激励 7测量
				end
				8'h06 : begin
					sw_data <= 16'b00_01_01_01_01_01_01_11;		//1激励 8测量
				end
				8'h07 : begin
					sw_data <= 16'b01_01_01_01_01_00_11_01;		//2激励 3测量
				end
				8'h08 : begin
					sw_data <= 16'b01_01_01_01_00_01_11_01;		//2激励 4测量
				end
				8'h09 : begin
					sw_data <= 16'b01_01_01_00_01_01_11_01;		//2激励 5测量
				end
				8'h0a : begin
					sw_data <= 16'b01_01_00_01_01_01_11_01;		//2激励 6测量
				end
				8'h0b : begin
					sw_data <= 16'b01_00_01_01_01_01_11_01;		//2激励 7测量
				end
				8'h0c : begin
					sw_data <= 16'b00_01_01_01_01_01_11_01;		//2激励 8测量
				end
				8'h0d : begin
					sw_data <= 16'b01_01_01_01_00_11_01_01;		//3激励 4测量
				end
				8'h0e : begin
					sw_data <= 16'b01_01_01_00_01_11_01_01;		//3激励 5测量
				end
				8'h0f : begin
					sw_data <= 16'b01_01_00_01_01_11_01_01;		//3激励 6测量
				end
				8'h10 : begin
					sw_data <= 16'b01_00_01_01_01_11_01_01;		//3激励 7测量
				end
				8'h11 : begin
					sw_data <= 16'b00_01_01_01_01_11_01_01;		//3激励 8测量
				end
				8'h12 : begin
					sw_data <= 16'b01_01_01_00_11_01_01_01;		//4激励 5测量
				end
				8'h13 : begin
					sw_data <= 16'b01_01_00_01_11_01_01_01;		//4激励 6测量
				end
				8'h14 : begin
					sw_data <= 16'b01_00_01_01_11_01_01_01;		//4激励 7测量
				end
				8'h15 : begin
					sw_data <= 16'b00_01_01_01_11_01_01_01;		//4激励 8测量
				end
				8'h16 : begin
					sw_data <= 16'b01_01_00_11_01_01_01_01;		//5激励 6测量
				end
				8'h17 : begin
					sw_data <= 16'b01_00_01_11_01_01_01_01;		//5激励 7测量
				end
				8'h18 : begin
					sw_data <= 16'b00_01_01_11_01_01_01_01;		//5激励 8测量
				end
				8'h19 : begin
					sw_data <= 16'b01_00_11_01_01_01_01_01;		//6激励 7测量
				end
				8'h1a : begin
					sw_data <= 16'b00_01_11_01_01_01_01_01;		//6激励 8测量
				end
				8'h1b : begin
					sw_data <= 16'b00_11_01_01_01_01_01_01;		//7激励 8测量
				end
				
				default : begin
					sw_data <= 16'b00_01_01_01_01_01_01_11;
					
				end
			endcase
		end
end
//data_out_n <= (adc_data - 12'h800)<<2;
//12'h0-->12'h800是负数，12'800是0,12’h800-->12'hfff是整数
endmodule 

//==========================================================================
//module end
//v1.0
//2118.11.02-16:39