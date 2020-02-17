//==========================================================================
//Filename  :dac_ctl.v
//modulename:adc_ctl
//Author    :Xiaoqing.Huang
//Date	   :2018-06-08
//Function  :This is a top module, when give a rst signal, all module reset 
//Uesedfor  :Altera cyclon EP3C25F324C8, made by Huangxiaoqing.
//==========================================================================

//==========================================================================
//Input and output declaration
//==========================================================================

module dac_ctl	(
						//system input
						sys_clk,
						sys_rst,
						
						dds_data,
						
						dac_clk,
						dac_data
					);
//-----------------------------input or output------------------------------
input  				sys_rst;
input  				sys_clk;

input		[13:0]	dds_data;

output	[13:0]	dac_data;
output				dac_clk;
//----------------------------wire  or  reg---------------------------------
wire					sys_clk;
wire					sys_rst;

wire		[13:0]	dds_data;

reg		[13:0]	dac_data;

wire					dac_clk;//系统时钟采用1M-50M，这次采用1MHz
//--------------------------------------------------------------------------
//主要是用50M时钟输出DAC_CLK给到AD9754，然后从总线上读取数据读取数据
assign dac_clk = (sys_rst) ? sys_clk : 1'b0;	//50M/128=390KHz
//--------------------------------------------------------------------------
//下降沿的时候把数据写到DAC中
always@(negedge sys_clk or negedge sys_rst)
begin
	if(!sys_rst)
		dac_data <= 14'h0;
	else
		dac_data <= dds_data;
end

endmodule 

//==========================================================================
//module end
//v1.0
//2018.01.02-16:39