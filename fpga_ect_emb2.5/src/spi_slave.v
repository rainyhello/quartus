/***************************************************************************
**----------------------------File information--------------------------
** File name  	:SPI_slave.v  
** CreateDate 	:2018.04
** Funtions   	:SPI的通信实验，FPGA作为从机，接收主机数据以及向主机发送数据
** Operate on 	:HuangXQ
** Copyright  	:All rights reserved. 
** Version    	:V1.3
**---------------------------Modify the file information----------------
** Modified by   	:Huangxiaoqing
** Modified data 	:2018-05-31
** Modify Content	:增加数据发送部分
** Module Name 	:spi_slave
***************************************************************************/
//========================module begin===========
module  spi_slave (
							sys_clk,
							sys_rst,
							
							spi_cs,
							spi_sck,		//4MHz时钟
							spi_miso,
							spi_mosi,
							
							led,
							
							spi_data,
							
							fifo_data,
							fifo_rd_req,
							fifo_empty
						);

//===============================================
//input and output declaration
//-----------------------------------------------
input          		sys_clk;
input         			sys_rst;

input         			spi_cs;
input         			spi_sck;
input         			spi_mosi;
output   reg 			spi_miso;

output	reg 	[1:0]	led;

output	reg	[25:0]spi_data;

input						fifo_empty;
input		[15:0]		fifo_data;
output	reg			fifo_rd_req;

//spi_mosi---------------------------------------
reg 	[7:0]		i,j;		//上升沿和下降沿计数器
reg 	[127:0]	data_in;
reg	[127:0]	data_out;	//8个字节
//============================================================


always@(posedge spi_sck or negedge sys_rst)
begin
	if(!sys_rst)
		begin
			i <= 8'h00;
			data_in <= 128'h0;
		end
	else if(!spi_cs)
		begin
			i <= i + 1'b1;
			data_in[127-i] <= spi_mosi;
		end
	else
		begin
			i <= 8'h00;
		end
end

//--------------------------data-----------------------------
/*对比接收数据*/
always@(posedge sys_clk or negedge sys_rst)
begin
	if(!sys_rst)
		begin
//			led[1:0] <= 2'b00;
			spi_data <= 26'h3ff_ffff;
		end
	//进行数据解读---
	else if(spi_cs)
		begin
			if(data_in[127:120]== 8'h53)
				begin
//					led[1:0] <= 2'b11;
					
					//设备码
					case(data_in[119:112])
						8'h10 : spi_data[25:24] <= 2'b01;				//ect
						8'h20 : spi_data[25:24] <= 2'b10;				//ert
						8'h30 : spi_data[25:24] <= 2'b00;				//ect+ert
					endcase
					//命令码
					case(data_in[111:104])
						8'h20  : spi_data[23:20] <= 4'h1;			//读取数据
						8'h30  : spi_data[23:20] <= 4'h2;			//硬件版本号
						8'h31  : spi_data[23:20] <= 4'h3;			//软件版本号
						8'h35  : spi_data[23:20] <= 4'h4;			//仪器复位
						8'ha0  : spi_data[23:20] <= 4'h5;			//控制命令
						8'hb0  : spi_data[23:20] <= 4'h6;			//解调命令
						default: spi_data[23:20] <= 4'hf;			//空
					endcase
						
					//控制参数
					if(spi_data[23:20] == 4'h5)						//控制命令下才有意义
						begin
							spi_data[19:16]	<= data_in[99:96];	//只有三种模式，取低四位
							spi_data[15:8]		<= data_in[95:88];	//ECT有0-27个通道，ERT有0-19通道
							spi_data[7:4]		<= data_in[83:80];	//ECT的增益1有8种情况，ERT有4种情况
							
							if(spi_data[25:24] == 2'b10)
								spi_data[3:0]	<= data_in[75:72];//ECT没有这个参数，ERT有8种情况，两个运放，四位
							else
								spi_data[3:0]	<= 4'hf;				//空
						end
					else
						begin
							spi_data[19:16]	<= 4'hf;
							spi_data[15:8]		<= 8'hff;
							spi_data[7:4]	<= 4'hf;
							spi_data[3:0]	<= 4'hf;
						end
				end
				
			else
				begin
//					led[1:0] <= 2'b00;
				end
		end
	else
		begin
		end
end


//----------------spi_miso--------------------------------------------------
//发送模块
//读取FIFO，要在时钟上升沿使能读请求。在下降沿使能读请求会出错

//always@(negedge spi_sck or negedge sys_rst)
//begin
//	if(!sys_rst)
//		begin
//			spi_miso <= 1'b1;
//			j <= 8'h00;
//		end
//	else if((!spi_cs)&&(!fifo_empty))
//		begin
//			case(j)
//				default : begin
//					spi_miso <= data_out[15-j];
//					j <= j + 1'b1;
//					
//				end
//				8'h0f : begin 
//					spi_miso <= data_out[0];		//数据乱序
//					j <= 8'h00;
//				end
//			endcase
//		end
//			
//	else
//		begin
//			spi_miso <= 1'b1;
//		end
//end
//--------------------------------------------------------------------------
//always@(negedge spi_sck or negedge sys_rst)
//begin
//	if(!sys_rst)
//		begin
//			data_out <= 16'hffff;
//			fifo_rd_req <= 1'b0;
//		end
//	else if(!spi_cs)
//		begin
//			if(j == 8'h00)					//必须按照这个时间点来接收数据
//				begin
//					data_out <= fifo_data;		//数据更新
//					fifo_rd_req <= 1'b1;			//读取FIFO数据请求使能
//				end
//			else
//				begin
//					fifo_rd_req <= 1'b0;
//				end
//		end
//	else
//		begin
//			data_out <= 16'hffff;
//			fifo_rd_req <= 1'b0;
//		end
//end


//========================调试使用-非常重要==================================
always@(negedge spi_sck or negedge sys_rst)
begin
	if(!sys_rst)
		begin
			j <= 8'h00;
		end
	else if(!spi_cs)
		begin
			if(j == 127)
				begin
					j <= 8'h00;
					spi_miso <= data_out[127];
				end
			else
				begin
					j <= j + 1'b1;
					spi_miso <= data_out[126-j];
				end
		end
	else
		begin
			j <= 8'h00;
		end
end
//-------------------------------------------------------------------
always@(negedge spi_sck or negedge sys_rst)
begin
	if(!sys_rst)
		begin
			led[1]  <= 1'b1;
			//前导符|设备码|命令码|通道号|增益|保留|最大值|最小值|幅值|命令序号|校验和
			data_out <= 128'h53_10_b0_00_01_55_6677_8899_aabbccdd_01_ff;
		end
	else if(!spi_cs)
		begin
			if(data_in[127:120] == 8'h53)		//表示接收了16字节数据
				begin
					led[1] <= 1'b0;
					//data_out[]
				end
			else if(data_in[119:112])
				begin
					led[0] <= 1'b0;
					data_out[119:112] <= 8'h10;
				end
			led[1] <= 1'b0;
			
		end
	else
		begin
			led[1] <= 1'b1;
			data_out <= 128'h00112233445566778899aabbccddeeff;
		end
end
//===================================================================

endmodule 

//=========endmodule========================================================


/*************************下面是调试相关代码*********************************/


