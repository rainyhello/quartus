/***************************************************************************
Input and output declaration
unit		:Tsinghua University
version	:v1.01
author	:HuangXiaoqing
date		:2018.04
function :control data demodulation
input		:pcb or pc data,scan mode,gain data,pc cmd
output	:demodulate data,control IP core
***************************************************************************/
module demod_ctl	(
							sys_clk,
							sys_rst,
							dds_clk,
							
							led,
							sf_rst,
							dds_sw,
							
							dds_addr,
							lut_addr,
							ect_data,
							adc_data,
							
							spi_cs,
							spi_sck,
							spi_miso,
							spi_mosi,
							
							ect_pga,
							ect_sw,
							
							sqrt_q,
							
							acc_clr,
							acc_en,
							add_en
							);
//=============================input or output==============================
input  					sys_rst;
input  					sys_clk;
input						dds_clk;

output	reg[2:0]		led;
output	reg			sf_rst;
output	reg[3:0]		dds_sw;

output	reg[6:0]		dds_addr;
input			[6:0]		lut_addr;
input	signed[13:0]	ect_data;
input			[11:0]	adc_data;
//spi
input						spi_cs,spi_sck,spi_mosi;
output	reg			spi_miso;

output	reg[7:0]		ect_pga;
output	reg[7:0]		ect_sw;

input			[47:0]	sqrt_q;



output	reg			acc_clr,acc_en,add_en;

//--------------------------------------------------
reg			[7:0]		wr_cnt,wr_cnt_n;
reg			[7:0]		switch_sel,switch_sel_n;
reg 			[11:0]	adc_min,adc_max,adc_mean;
reg			[11:0]	i;

reg			[7:0]		scan_chn,ect_chn;
reg			[3:0]		scan_mode,gain_data1,gain_data2;
reg			[3:0]		pc_cmd;
reg			[1:0]		dev;
reg						pc_rst;

reg 	[7:0]		m,k,j;		//上升沿和下降沿计数器
reg 	[127:0]	data_in;

reg	[7:0]		crc_data;
reg	[7:0]		frm_data;
reg	[7:0]		crc_pc;
reg				dds_en;

reg	[127:0]	data_out;	//16个字节,一共28个
reg	[127:0]	spi_data[0:27];	//16个字节,一共28个
//--------------------------------------------------
localparam frm_head	= 8'h53;
localparam dev_ect	= 8'h10;
localparam dev_ert	= 8'h20;
localparam samp_num	= 10'd500;

//spi_cs的上升沿和下降沿的捕捉
reg		spi_cs_0,spi_cs_1;
wire		spi_cs_neg,spi_cs_pos;
wire		spi_cs_flag;

reg		spi_sck_0,spi_sck_1;
wire		spi_sck_neg,spi_sck_pos;
wire		spi_sck_flag;

reg		sf_rst_0,sf_rst_1;
wire		sf_rst_neg,sf_rst_pos;

always @(posedge sys_clk or negedge sys_rst)
	begin
		if(!sys_rst)
			begin
				{spi_cs_1,spi_cs_0} <= 2'b11;
				{spi_sck_1,spi_sck_0} <= 2'b11;
			end
		else	
			begin
				{spi_cs_1,spi_cs_0} <=  {spi_cs_0,spi_cs};
				{spi_sck_1,spi_sck_0} <=  {spi_sck_0,spi_sck};
			end
	end

assign spi_cs_flag	=	spi_cs_1;
assign spi_cs_neg		=	spi_cs_1&~spi_cs_0;//为1表示下降沿，表示SPI通信开始
assign spi_cs_pos		=	~spi_cs_1&spi_cs_0;//为1表示上升沿，表示通信结束

assign spi_sck_flag	=	spi_sck_1;
assign spi_sck_neg	=	spi_sck_1&~spi_sck_0;//为1表示下降沿
assign spi_sck_pos	=	~spi_sck_1&spi_sck_0;//为1表示上升沿
//-------------------------------------------------------------------------
//软件复位，不能使用系统时钟，使用SPI的时钟进行处理
always@(negedge spi_sck)
begin
	if(data_in[127:104]==24'h531035)
		sf_rst <= 1'b0;
	else
		sf_rst <= 1'b1;
end
//--------------------------------------------------
//always@(negedge spi_sck)
//begin
//	if(data_in[127:104]==24'h5310a0)
//		dds_sw <= data_in[75:72];
//	else
//		dds_sw		<= 4'hf;
//end
//==========================================================================
always@(posedge sys_clk or negedge sys_rst)
begin
	if(!sys_rst)
		begin
			wr_cnt 	<= 8'h00;
			adc_max  <= 12'h000;
			adc_min	<= 12'hfff;
			i <= 12'd0;
			data_out <= 128'd0;
			led <= 3'b111;
			dev <= 2'b11;
			
   		ect_chn<= 8'd00;
			ect_sw <= 8'hff;	//否则一开始会拉高1通道的电平
			ect_pga<= 4'hf;	//放大倍数一开始设置在1左右
			frm_data <= 8'h00;
			
			crc_pc <= 8'h00;
			
			pc_cmd		<= 4'h6;
			
			scan_mode	<= 4'h0;
			scan_chn		<= 8'hff;
			gain_data1	<= 4'h4;
			gain_data2	<= 4'hf;
			dds_sw		<= 4'h2;
			
		
			acc_clr<= 1'b1;
			acc_en <= 1'b0;
			add_en <= 1'b0;
			adc_mean <= 12'b0;
			ect_pga	<= gain_data1;		//增益选择
			dds_en <= 1'b0;
//			div_en <= 1'b0;
//			div_clr<= 1'b0;
		end
		
	else if(spi_cs)	//spi_cs为高电平的时候做数据解调，只解调一次
	
		begin
			case (wr_cnt)
				8'h00 : begin
					wr_cnt <= wr_cnt + 1;
					
					if(data_in[127:120]== 8'h53)begin 	//接收到相应的字段，就先计算CRC
						crc_pc <=   data_in[119:112]+data_in[111:104]+data_in[103:96]+data_in[95:88]+
										data_in[87:80]  +data_in[79:72]  +data_in[71:64] +data_in[63:56]+
										data_in[55:48]	 +data_in[47:40]	+data_in[39:32] +data_in[31:24]+
										data_in[23:16]  +data_in[15:8];	//接收到的数据进行校验
						
					end
					
//					else begin
//						wr_cnt <= wr_cnt + 2;
//					end
				end
				8'h01 :begin
					wr_cnt <= wr_cnt + 1'b1;
					
					if(data_in[7:0]==crc_pc) begin		//校验正确
						
						led[0] <= ~led[0];				//接收到一次命令灯就亮/灭一次
						//设备码
						case(data_in[119:112])
							8'h10 : begin
								dev <= 2'b01;				//ect
								led[2:1] <= 2'b10;
							end
							
							8'h20 : begin
								dev <= 2'b10;				//ert
								led[2:1] <= 2'b01;
							end
							
							8'h30 : begin
								dev <= 2'b00;				//ect+ert
								led[2:1] <= 2'b00;
							end
							
							default:begin
								dev <= 2'b11;				//无设备
								led[2:1] <= 2'b11;
							end
						endcase
						//命令码
						case(data_in[111:104])
							8'h20  : pc_cmd <= 4'h1;			//读取数据，暂时不用
							8'h30  : pc_cmd <= 4'h2;			//硬件版本号
							8'h31  : pc_cmd <= 4'h3;			//软件版本号
							8'h35  : pc_cmd <= 4'h4;			//仪器复位
							8'ha0  : pc_cmd <= 4'h5;			//控制命令
							8'hb0  : pc_cmd <= 4'h6;			//解调命令
							8'h38  : pc_cmd <= 4'h7;			//
							default: pc_cmd <= 4'hf;			//空
						endcase
							
						//控制参数
						if(data_in[111:104] == 8'ha0)						//控制命令下才有意义
							begin
								scan_mode	<= data_in[99:96];	//只有三种模式，取低四位
								scan_chn		<= data_in[95:88];	//ECT有0-27个通道，ERT有0-19通道
								gain_data1	<= data_in[83:80];	//ECT的增益1有8种情况，ERT有4种情况
								dds_sw		<= data_in[75:72];	//DDS选择，只使用下低4 bits
							end
					end
					
					else begin
						pc_cmd <= 4'h6;
						dev <= 2'b01;
						led[2:1] <= 2'b10;
						//wr_cnt <= wr_cnt + 1'b1;
					end
				end
				
				8'h02 :
					begin
						wr_cnt <= wr_cnt + 1'b1;
						adc_max <= 12'h000;
						adc_min <= 12'hfff;
						//命令序号
//						if(ect_chn >= 8'h1b)
//							begin
//								ect_chn <= 8'h00;
//								//led[1] <= ~led[1];
//							end
//						else
//							ect_chn <= ect_chn + 1'b1;
//					
					end
				8'h03 :
					begin
						ect_sw <= ect_chn;
						ect_pga	<= gain_data1;		//增益选择
						dds_en <= 1'b1;
						frm_data <= frm_data + 1'b1;	
						wr_cnt <= wr_cnt + 1'b1;
					end
				
				8'h04 ://延时2个周期，每个周期64个点
					begin
						i <= i + 1'b1;
						if(i >= 128)
							begin
								wr_cnt <= wr_cnt + 1'b1;
								acc_clr<= 1'b1;				//乘累加器清零
//								div_clr<= 1'b1;				//除法器清零
								acc_en <= 1'b1;				//使能乘累加器
								i <= 12'h0;
							end
							
					end
				8'h05 :
					begin
						i <= i + 1'b1;
						acc_clr <= 1'b0;						//乘累加器清零关闭
						
						if(i >= 1560)
							begin
								add_en <= 1'b1;				//使能平方和
								wr_cnt <= wr_cnt + 1'b1;
								i <= 12'h0;
							end
						if(i >= 500)
						   begin
								if(adc_data > adc_max)				//记录极值
									adc_max <= adc_data;
									
								if(adc_data < adc_min)
									adc_min <= adc_data;
							end
							
					end
					//
				8'h06 :
					begin
						acc_en <= 1'b0;
						i <= i + 1'b1;
						
						if(i >= 128)		//延迟一段时间
							begin
								add_en <= 1'b0;
								
								i <= 12'h0;
								wr_cnt <= wr_cnt + 1'b1;
							end
					end
					
				8'h07 :
					begin
						wr_cnt <= wr_cnt + 1'b1;
						dds_en <= 1'b0;
						ect_sw <= 8'hff;
						//前导符|设备码|命令码|通道号|增益|保留|最大值|最小值|幅值|命令序号|校验和
						case(pc_cmd)
							4'h2 :	//硬件版本号
								begin
									data_out[127:112] <= 16'h5310;			//前导符|设备码
									data_out[111:96]	<= 16'h3033;			//命令码|填充字段
									data_out[95:80]	<= 16'h10ff;			//仪器型号：
									data_out[79:48]	<= 32'h02050900;		//版本号是2.5.01.10		//前两位2.5表示EMB_V2.5，后面两位表示FPGA硬件第几次更新
									data_out[47:24]	<= 24'h333333;			//填充字段
									data_out[15:0]		<= 16'h3355;
								end
								
							4'h3 :	//软件版本号
								begin
									data_out[127:112] <= 16'h5310;			//前导符|设备码
									data_out[111:96]	<= 16'h3133;			//命令码|填充字段
									data_out[95:64]	<= 32'h021e0900;		//版本号2.5.02.10
									data_out[63:24]	<= 40'h3333333333;	//填充字段
									data_out[15:0]		<= 16'h3355;
								end

							4'h4 :	//复位
								begin
									data_out[127:0]	<= 128'd0;
								end
							4'h7 :	//协议版本号
								begin
									data_out[127:112] <= 16'h5310;			//前导符|设备码
									data_out[111:96]	<= 16'h3233;			//命令码|填充字段
									data_out[95:64]	<= 32'h01000000;		//版本号1.0.00.00
									data_out[63:24]	<= 40'h3333333333;	//填充字段
									data_out[15:0]		<= 16'h3355;
								end
							default:
								begin
									data_out[127:104] <= 24'h5300b0;//前导符|设备码|命令码
									data_out[103:80]	<= {ect_chn,ect_pga,8'h00};//通道号|增益
									data_out[79:64]	<= {adc_max[7:0],4'h0,adc_max[11:8]};	//最大值
									data_out[63:48]	<= {adc_min[7:0],4'h0,adc_min[11:8]};	//最小值
									data_out[47:16]	<= {sqrt_q[23:16],sqrt_q[31:24],sqrt_q[39:32],sqrt_q[47:40]}; 	//幅值
									data_out[15:8]	<= frm_data;

								end
						endcase
					end
						
				8'h08 :
					begin		//接收到的数据进行校验	
						wr_cnt <= wr_cnt+1'b1;
						
						data_out[7:0] <= 	data_out[119:112]+data_out[111:104]+data_out[103:96]+data_out[95:88]+
													data_out[87:80]  +data_out[79:72]  +data_out[71:64] +data_out[63:56]+
													data_out[55:48]  +data_out[47:40]  +data_out[39:32] +data_out[31:24]+data_out[23:16]++data_out[15:8];
					end
				8'h09 :
					begin
					   if(ect_chn >= 8'h1b)		//完成一帧完整的循环
							begin
								wr_cnt <= wr_cnt;	//空循环,等待spi_cs拉高，解调周期结束
								ect_chn <= 8'h00; //ZJG
							end
						else
							begin
								wr_cnt <= 8'h00;	//继续解调
								ect_chn <= ect_chn + 1'b1;
								led[1] <= ~led[1];
							end
						wr_cnt <= wr_cnt + 1'b1;	
					end
					
				8'h0a :
					begin
              spi_data[ect_chn] <= data_out;//
				  wr_cnt <= wr_cnt + 1'b1;
					end
					
				default:
					begin
						wr_cnt <= 8'h00;
					end
			endcase
		end
	else	//(SPI_CS低电平的时候)
		begin
			wr_cnt <= 8'h00;
		//	
	  
		end
		
end


////////////////////////////////////////////////////////////////////////////
//==============下面是SPI数据接收和发送=======================================
//当前的spi模式是CPOL=0,CPHA=0(时钟空闲时为低电平，在第一个时钟边沿进行数据采样)
always@(negedge spi_sck or negedge sys_rst)
begin
	if(!sys_rst)
		begin
			m <= 8'h00;
			data_in <= 128'h0;
		end
	else if(!spi_cs)
		begin
			case(m)
				default:
					begin
						m <= m + 1'b1;
						data_in[127-m] <= spi_mosi;
					end
				127:
					begin
						m <= 8'h00;
						data_in[0] <= spi_mosi;
					end
			endcase
		end
	else
		begin
			m <= 8'h00;
		end
end
//======================================================

reg	[127:0]	txd_data;
always@(posedge spi_sck or negedge sys_rst)
begin
	if(!sys_rst)
		begin
			j <= 8'h00;
			k <= 8'h00;
			spi_miso <= 1'b0;
			txd_data <= 128'h0;
		end
	else if(spi_cs_neg)	//spi_cs的下降沿是SPI通信的开始
		begin
			j <= 8'h00;
			k <= 8'h00;
			txd_data <= spi_data[0];
		end
	else if(!spi_cs)
		begin
			case(j)
				127 :
					begin
						if(k >= 27)
							k <= 0;
						else
							k <= k + 1;

						j <= 8'h00;
						txd_data <= spi_data[k];
						spi_miso <= txd_data[0];

					end
				default :
					begin
						j <= j + 1'b1;
						spi_miso <= txd_data[127-j];
						
					end
			endcase
		end
end
//-------------------------------------------
always@(posedge dds_clk or negedge sys_rst)
begin
	if(!sys_rst)
		dds_addr <= 7'h20;
	else if(dds_en)		//dds使能
		begin
			if(dds_addr == 127)
				dds_addr <= 7'h00;
			else
				dds_addr <= dds_addr + 1'b1;
		end
	else
		dds_addr <= 7'h20;
end
//===================================================================
////////////////////////////////////////////////////
endmodule
//==================================================
/*
//脉冲计数器，在SPI_CS的上升沿或者下降沿进行计数
//-------------------------------------------
always@(posedge sys_clk or negedge sys_rst)
begin
	if(!sys_rst)
		begin
			frm <= 8'h00;
			ect_chn  <= 8'h00;
		end
	else if(spi_start)		//使用脉冲计数
		begin
			if(frm >= 255)
				frm <= 8'h00;
			else
				frm <= frm + 1;
			//进行通道对应，
		end
end

reg	[127:0]	txd_data;
always@(posedge spi_sck or negedge sys_rst)
begin
	if(!sys_rst) begin
		j <= 8'h00;
		k <= 8'h00;
		spi_miso <= 1'b0;
		txd_data <= 128'd0;
	end

	else if(!spi_cs) begin	
		case(j)
			127 : begin
				
				if(k < 8'd28) begin
					k <= k + 1'b1;
					j <= 8'h00;
					txd_data <= spi_data[k];
					spi_miso <= txd_data[0];
				end
				
				else begin
					k <= 8'h00;
					j <= 8'h00;
					txd_data <= 128'd0;
					spi_miso <= 1'b0;
				end
			end
			
			default : begin
				j <= j + 1'b1;
				spi_miso <= txd_data[127-j];
			end
		endcase
	end
		
	else begin
		j <= 8'h00;
		k <= 8'h00;
		spi_miso <= 1'b0;
		txd_data <= 128'd0;
	end

end
*/
//--------------------------------------------------
//==================================================