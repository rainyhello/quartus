//==========================================================================
//Filename  :led_ctl.v
//modulename:led_ctl
//Author    :Xiaoqing.Huang
//Date	   :2018-01-02
//Function  :This is a top module, when give a rst signal, all module reset 
//Uesedfor  :Altera cyclon EP3C25F324C8, made by Huangxiaoqing.
//==========================================================================

//==========================================================================
//Input and output declaration
//==========================================================================

module led_ctl
					(
						adc_data,
						sys_rst,
						sys_clk,
						led_out
					);

input		[11:0]	adc_data;
input  				sys_rst;
input  				sys_clk;
output	[2:0]		led_out;
//--------------------------------------------------------------------------
wire		[11:0]	adc_data;
wire					sys_clk;//系统时钟采用1M-50M，这次采用1MHz
wire					sys_rst;
reg		[2:0]		led_out;


//--------------------------------------------------------------------------
//led时间控制,主要是测试用
reg	[19:0]	time_ctl;
reg	[2:0]		led_out_n;
wire	[19:0]	time_ctl_n;

always@(posedge sys_clk or negedge sys_rst)
	if(!sys_rst)
		time_ctl <= 20'd0;
	else
		time_ctl <= time_ctl_n;

assign time_ctl_n = time_ctl + 1'b1;	//这个计数器不受控制，会增加FPGA功耗

always@(posedge sys_clk or negedge sys_rst)
	if(!sys_rst)
		led_out <= 3'b000;		//低电平灭，高电平亮
	else
		led_out <= led_out_n;

always@(*)
	if(time_ctl == 20'h0)
		led_out_n = adc_data[2:0];
	else
		led_out_n = led_out;
//assign	led_out_n = adc_data[2:0];

endmodule 

//==========================================================================
//module end
//v1.0
//2018.01.02-16:39