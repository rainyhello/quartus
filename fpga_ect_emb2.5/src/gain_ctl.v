//==========================================================================
//Filename  :gain_ctl.v
//modulename:gain_ctl
//Author    :Xiaoqing.Huang
//Date	   :2018-01-02
//Function  :This is a top module, when give a rst signal, all module reset 
//Uesedfor  :Altera cyclon EP3C25F324C8, made by Huangxiaoqing.
//==========================================================================

//==========================================================================
//Input and output declaration
//==========================================================================

module gain_ctl	(
						//system input
						sys_clk,
						sys_rst,
						
						gain_data1,
						gain1_out
					);
//-----------------------------input or output------------------------------
input  				sys_rst;
input  				sys_clk;

input		[3:0]		gain_data1;

output	[2:0]		gain1_out;
//----------------------------wire  or  reg---------------------------------
wire					sys_clk;
wire					sys_rst;
reg		[2:0]		gain1_out;
//--------------------------------------------------------------------------
always@(posedge sys_clk or negedge sys_rst)
begin
	if(!sys_rst)
		begin
			gain1_out <= 3'h0;
		end
	else
		begin
			gain1_out <= gain_data1[2:0];
		end
end


endmodule 

//==========================================================================
//module end
//v1.0
//2018.01.02-16:39