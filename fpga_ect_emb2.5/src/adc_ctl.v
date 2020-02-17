//==========================================================================
//Filename  :adc_ctl.v
//modulename:adc_ctl
//Author    :Xiaoqing.Huang
//Date	   :2018-01-02
//Function  :This is a top module, when give a rst signal, all module reset 
//Uesedfor  :Altera cyclon EP3C25F324C8, made by Huangxiaoqing.
//==========================================================================

//==========================================================================
//Input and output declaration
//==========================================================================

module adc_ctl	(
						//system input
						sys_clk,
						sys_rst,
						
						dev,
						//ad9224 input
						adc_otr,
						adc_data,
						
						//output from FPGA
						clk_out,
						otr_out,
						data_out
					);
//-----------------------------input or output------------------------------
input  				sys_rst;
input  				sys_clk;
input		[1:0]		dev;
input					adc_otr;
input		[11:0]	adc_data;

output				otr_out;
output	[13:0]	data_out;
output				clk_out;
//----------------------------wire  or  reg---------------------------------
wire					sys_clk;

wire					sys_rst;
wire					adc_otr;
wire		[11:0]	adc_data;

reg		[13:0]	data_out;
wire					otr_out;
wire					clk_out;//系统时钟采用1M-50M，这次采用1MHz
//--------------------------------------------------------------------------
//主要是用5M时钟输出ADC_CLK给到AD9224，然后从总线上读取数据读取数据
//ota主要是用于调整ADC输入信号的放大倍数，确保信号总是在测量电压范围内
//ota信号是溢出标志位
assign clk_out = (sys_rst) ? sys_clk : 1'b0;	//20M时钟
assign otr_out = (sys_rst) ? adc_otr : 1'b0;	//
//溢出标志位
//标志位可以上传至上位机，以便于调节放大倍数
//--------------------------------------------------------------------------
//下降沿的时候读取数据
always@(negedge sys_clk or negedge sys_rst)
begin
	if(!sys_rst)
		data_out <= 14'h0;
	else
		data_out <= (adc_data - 12'h800)<<2;
end
//data_out_n <= (adc_data - 12'h800)<<2;
//12'h0-->12'h800是负数，12'800是0,12’h800-->12'hfff是整数
endmodule

//adc采样时钟为1-20MHz
//DDS_CLK = 20MHz/128 = 156KHz
//每个周期的采样点数为 = 10M/(20M/128) = 64个点
//===============================================================================
//==========================================================================
//module end
//v1.0
//2018.01.02-16:39