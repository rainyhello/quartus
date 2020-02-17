//==========================================================================
//Filename  :FPGA_ECT_ERT.v
//modulename:FPGA_ECT_ERT
//Author    :Xiaoqing.Huang
//Date	   :2017-12-11
//Function  :This is a top module, when give a rst signal, all module reset 
//Uesedfor  :Altera cyclon EP3C25F324C8, made by Huangxiaoqing.
//==========================================================================
//Input and output declaration
//==========================================================================
module	ect_ert
					(
						clk_in,
						rst_in,
						
						led,
						
						spi_cs,				//SPI
						spi_sck,				//...
						spi_miso,			//...
						spi_mosi,			//SPI
//-------------------------------------------------
						ect_adc_data,		//ect adc
						ect_adc_otr,
						ect_adc_clk,
						
						ect_dac_data,		//ect dac
						ect_dac_clk,
						
						ect_switch,			//ect switch
						
						ect_gain				//ect gain
					);
//
//===================================================
//input and output declaration
//===================================================
//
//clk,rst,led
input 				clk_in;
input 				rst_in;
output	[3:0] 	led;
//spi
input        		spi_cs;
input        		spi_sck;
input       		spi_mosi;
output				spi_miso;

//------------ect-------------------
//ect adc
input		[11:0]	ect_adc_data;
input					ect_adc_otr;
output				ect_adc_clk;
//ect dac
output	[13:0]	ect_dac_data;
output				ect_dac_clk;
//ect switch
output	[15:0]	ect_switch;
//ect gain
output	[2:0]		ect_gain;
//==================================
//Wire and reg declaration,
//==================================

//spi
wire					spi_cs;
wire					spi_sck;
wire					spi_mosi;
wire					spi_miso;
//system clock,led and reset--------
wire					clk_in;
wire					rst_in;
wire		[3:0]		led;

wire					sys_clk_10m;
wire					sys_clk_25m;
wire					sys_clk_50m;
wire					sys_clk_100m;
wire					sys_clk_150m;

wire					sys_rst;
reg					sys_clk;
//-------ect------------------------
wire unsigned 	[11:0]	ect_adc_data;
wire							ect_adc_ota;
wire							ect_adc_clk;

reg				[13:0]	ect_dac_data;
wire							ect_dac_clk;

wire				[15:0]	ect_switch;
reg				[2:0]		ect_gain;
//-------ip core--------------------
wire signed 	[13:0]	sin_data;
wire signed 	[13:0]	cos_data;
//acc,add,div control
wire							acc_clr,acc_en,add_en;
//wire							div_clr,div_en;

wire signed 	[46:0] 	acc_out1,acc_out2;
wire unsigned	[95:0]	add_out;
wire unsigned	[47:0]	sqrt_q;
wire unsigned	[48:0]	sqrt_r;

reg  signed		[13:0]	ect_data;	//有符号数
wire							ect_otr;		//

wire				[7:0]		ect_chn;
wire				[3:0]		ect_pga;
wire				[13:0]	dds_data;
wire				[6:0]		dds_addr;
reg							demod_clk;	//寄存器数据统一为无符号数
reg 				[11:0]	adc_data;
wire							sf_rst;
wire				[3:0]		dds_sw;

//wire				[47:0]	div_data;
//wire				[47:0]	lpm_div_data,lpm_div_remain;
//wire							div_zero,div_nan,div_by_zero,div_over,div_under;

//---------------------------------------------------
always@(*)
begin
	if(!sys_rst)
		sys_clk = 0;
	else
		begin
			case(dds_sw)
				0 : begin
					sys_clk = sys_clk_10m;
				end
				
				1 : begin
					sys_clk = sys_clk_25m;
				end
				
				2 : begin
					sys_clk = sys_clk_50m;
				end
				
				3 : begin
					sys_clk = sys_clk_100m;
				end
				
				4 : begin
					sys_clk = sys_clk_150m;
				end
				
				default : begin
					sys_clk = sys_clk_10m;
				end
			endcase
		end
end
//---------------------------------------------------
always@(posedge sys_clk or negedge sys_rst)
begin
	if(!sys_rst)
		demod_clk <= 1'b0;
	else
		begin
			demod_clk <= ~demod_clk;
		end
end
//dac-----------------------------------------------
assign ect_dac_clk = (!sys_rst)? 1'b0 : sys_clk;
always@(negedge sys_clk or negedge sys_rst)
begin
	if(!sys_rst)
		begin
			ect_dac_data <= 14'h0000;
		end
	else
		begin
			ect_dac_data <= dds_data;
		end
end 
//adc==============================================
//adc----------------------------------------------
assign ect_adc_clk = (!sys_rst) ? 1'b0:demod_clk;
assign ect_otr = (!sys_rst) ? 1'b0:ect_adc_otr;
//溢出标志位
//标志位可以上传至上位机，以便于调节放大倍数
//----------------------------------------
//下降沿的时候读取数据
reg	[11:0]	tmp;
always@(negedge demod_clk or negedge sys_rst)
begin
	if(!sys_rst)
		begin
			ect_data <= 0;
		end
	else
		begin
			ect_data <= $signed(ect_adc_data - 12'h800);
		end
		
end
always@(negedge demod_clk or negedge sys_rst)
begin
	if(!sys_rst)
		ect_gain <= 3'b000;
	else
		ect_gain <= ~ect_pga[2:0];
end
//=================================================
//下面全是例化
//系统时钟和复位
sys_ctl	all_sys_ctl(
						.clk_in		(clk_in),
						.rst_in		(rst_in),
						.sf_rst		(sf_rst),
						
						.sys_rst		(sys_rst),
						.led			(led[0]),
						.sys_clk_10m(sys_clk_10m),
						.sys_clk_25m(sys_clk_25m),
						.sys_clk_50m(sys_clk_50m),
						.sys_clk_100m(sys_clk_100m),
						.sys_clk_150m(sys_clk_150m)
						);

demod_ctl	ect_demod_ctl
						(
						.sys_clk		(demod_clk),
						.sys_rst		(sys_rst),
						.dds_clk		(sys_clk),
						
						.led			(led[3:1]),
						.sf_rst		(sf_rst),
						.dds_sw		(dds_sw),
						
						.dds_addr	(dds_addr),
						.lut_addr	(rom_addr),
						.ect_data	(ect_data),
						.adc_data	(ect_adc_data),
						
						.spi_cs		(spi_cs),
						.spi_sck		(spi_sck),
						.spi_miso	(spi_miso),
						.spi_mosi	(spi_mosi),
						
						.ect_pga		(ect_pga),
						.ect_sw		(ect_chn),
						
						.sqrt_q		(sqrt_q),	//低
						
						.acc_clr		(acc_clr),
						.acc_en		(acc_en),
						.add_en		(add_en)
						
						);
//
switch_ctl	ect_sw_ctl
						(
						.sys_clk		(demod_clk),
						.sys_rst		(sys_rst),
						
						.sw_chn		(ect_chn),
						.sw_data		(ect_switch)
						);
//	
dds_rom	dds_out
						(
						.address		(dds_addr),
						.clock		(sys_clk),
						.q				(dds_data)
						);

ip_mult_acc	ect_acc1
						(
						.aclr0		(acc_clr),
						.clock0		(demod_clk),
						.dataa		(ect_data),
						.datab		(cos_data),
						.ena0			(acc_en),
						.result		(acc_out1)
						);

//
ip_mult_acc ect_acc2
						(
						.aclr0		(acc_clr),
						.clock0		(demod_clk),
						.dataa		(ect_data),
						.datab		(sin_data),
						.ena0			(acc_en),
						.result		(acc_out2)
						);

//
ip_mult_add ect_add
						(
						.clock0		(demod_clk),
						.dataa_0		(acc_out1),
						.dataa_1		(acc_out2),
						.datab_0		(acc_out1),
						.datab_1		(acc_out2),
						.ena0			(add_en),
						.result		(add_out)
						);
//
ip_rom_sin	sin_out
						(
						.address		(dds_addr),
						.clock		(sys_clk),
						.q				(sin_data)
						);
//
ip_rom_cos	cos_out
						(
						.address		(dds_addr),
						.clock		(sys_clk),
						.q				(cos_data)
						);
//
ip_sqrt	ect_sqrt(
						.radical		(add_out),
						.q				(sqrt_q),
						.remainder	(sqrt_r)
						);
//
endmodule
//==========================================================================
//module end
//v1.0
//2018.01.02-16:39
//==========================================================================