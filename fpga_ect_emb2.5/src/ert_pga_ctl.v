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

module ert_pga_ctl	(
						sys_clk,
						sys_rst,
						
						dev,
						gain_data,
						gain_out
					);
//-----------------------------input or output------------------------------
input  				sys_rst;
input  				sys_clk;

input		[1:0]		dev;
input		[3:0]		gain_data;
output	[5:0]		gain_out;
//----------------------------wire  or  reg---------------------------------
wire					sys_clk;
wire					sys_rst;

//--------------------------------------------------------------------------

//--------------------------------------------------------------------------

endmodule 

//==========================================================================
//module end
//v1.0
//2018.01.02-16:39