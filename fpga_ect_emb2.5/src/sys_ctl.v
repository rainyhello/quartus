//==========================================================================
//Filename  :sys_ctl.v
//modulename:sys_ctl
//Author    :Xiaoqing.Huang
//Date	   :2018-01-02
//Function  :This is a top module, when give a rst signal, all module reset 
//Uesedfor  :Altera cyclon EP3C25F324C8, made by Huangxiaoqing.
//==========================================================================

//==========================================================================
//Input and output declaration
//==========================================================================

module sys_ctl(
//						led_sys,
						clk_in,
						rst_in,
						sf_rst,
						
						sys_rst,
						led,
						sys_clk_10m,
						sys_clk_25m,
						sys_clk_50m,
						sys_clk_100m,
						sys_clk_150m
					);

//output reg led_sys;
input  	clk_in;
input  	rst_in;
input  	sf_rst;

output 	sys_rst;
output 	led;
output 	sys_clk_10m,
			sys_clk_25m,
			sys_clk_50m,
			sys_clk_100m,
			sys_clk_150m;

wire		clk_in;
wire		rst_in;
reg		sys_rst;
reg		led;
wire 		sys_clk_10m,
			sys_clk_25m,
			sys_clk_50m,
			sys_clk_100m,
			sys_clk_150m;

//--------------------------------------------------------------------------
//PLL复位，高电平有效
wire	pll_rst;
wire	pll_lock;
wire	sys_rst_n;
//------------------------------------------
// Delay 5s for steady state，复位延迟5秒
reg    [36:0] cnt;
always@(posedge clk_in or negedge rst_in or negedge sf_rst)
begin
    if((!rst_in)||(!sf_rst))
		cnt <= 0;
    else
		begin
			if(cnt < 36'd250_000_000) //5s
				cnt <= cnt+1'b1;
			else if(cnt > 36'd250_000_000)//超出的部分自动回到0
				cnt <= 0;
			else
				cnt <= cnt;
		end
end

//------------------------------------------
//rst_n synchronism
reg    rst_nr0;
reg    rst_nr1;
always@(posedge clk_in or negedge rst_in or negedge sf_rst)
begin
    if((!rst_in)||(!sf_rst))
		begin
			rst_nr0 <= 0;
			rst_nr1 <= 0;
			led <= 0;		//复位亮
		end
    else if(cnt == 36'd250_000_000)	//自动复位，定时复位
		begin
			rst_nr0 <= 1;
			rst_nr1 <= rst_nr0;
			led <= 1;		//正常工作亮
		end
    else
		begin
			rst_nr0 <= 0;			//采用定时复位的时候为0
			rst_nr1 <= 0;
//			rst_nr0 <= 1;			//正常复位则为1
//			rst_nr1 <= rst_nr0;
		end
end

assign    sys_rst_n = rst_nr1;


ip_pll	ip_pll_ctrl(
								.areset	(!sys_rst_n	),
								.inclk0	(clk_in		),
								.c0		(sys_clk_10m),
								.c1		(sys_clk_25m),
								.c2		(sys_clk_50m),
								.c3		(sys_clk_100m),
								.c4		(sys_clk_150m),
								.locked	(pll_lock	)
							);
//--------------------------------------------------------------------------
//系统复位，低电平有效，异步复位同步释放
//pll复位，高电平复位，低电平工作
reg	sys_rst_nr;

always@(posedge sys_clk_150m)
	if(!pll_lock)
		begin
			sys_rst_nr <= 1'b0;
			
		end
	else
		begin
			sys_rst_nr <= 1'b1;
			
		end

always@(posedge sys_clk_150m or negedge sys_rst_nr)
	if(!sys_rst_nr)
		sys_rst <= 1'b0;
	else
		sys_rst <= sys_rst_nr;
//------------------------------------------------
endmodule 

//==========================================================================
//module end
//v1.0
//2018.01.02-16:39
//==========================================================================