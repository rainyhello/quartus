//文件名:usb_ctl
//
//email:huangxiaoqing@leengstar.com
//
//company:tsinghua university
//
//
//修改记录：2018-01-16	hxq	创建
//
//
//==========================================================================
module usb_ctl
					(
//-----------led--output------------
						led_usb,
//-----------解调参数--output---------
//						demod_mode,
//						demod_chn,
//						pga_gain,
//						rst_sleep,	//上位机用于复位睡眠ECT/ERT板卡
						demod_data,
						frm_data,
						gain_data,
						tail_data,
//----------系统参数--input or output-
						usb_clk,
						sys_rst,
//-----------fifo参数----------
						fifo_rd_req,
						fifo_data,
						fifo_empty,
//-----------usb控制相关管脚-----
						fx2_flaga,
						fx2_flagc,
						fx2_slcs_n,
						fx2_slwr_n,
						fx2_slrd_n,
						fx2_sloe_n,
						fx2_pktend_n,
						fx2_a,
						fx2_db
					);
//==========================================================================

//系统参数
input usb_clk;						//48MHz，由USB芯片提供
input sys_rst;						//低电平复位
//output reg [3:0] rst_sleep;	//[3]-ECT复位|[2]-ERT复位|[1]-ECT睡眠|[0]-ERT睡眠(0表示有效，1表示无效)
////解调相关参数
output reg led_usb;
//output reg [7:0] demod_mode;
//output reg [3:0] demod_chn;
//output reg [3:0] pga_gain;
output reg	[15:0] demod_data,frm_data,gain_data,tail_data;
reg	[15:0] demod_data_n,frm_data_n,gain_data_n,tail_data_n;
//FX2 Slave FIFO接口
input	fx2_flaga;				//FIFO FULL标志位，低电平有效	
input fx2_flagc;				//FIFO EMPTY标志位，低电平有效
output reg fx2_slcs_n;		//FIFO片选信号，低电平有效
output reg fx2_slwr_n;		//FIFO写使能信号，低电平有效
output reg fx2_slrd_n;		//FIFO读使能信号，低电平有效
output reg fx2_sloe_n;		//FIFO输出使能信号，低电平有效
output  	  fx2_pktend_n;	//FIFO包结束信号
output reg [1:0] fx2_a;		//FIFO地址
inout [15:0] fx2_db;			//FIFO数据
//fifo读取
input [15:0] fifo_data;		//要发送至PC上的数据
output reg fifo_rd_req;		//FIFO读请求信号，高电平有效
input fifo_empty;				//fifo 空标志
/////////////////////////////////////////////////////////////
//定时读取FX2 FIFO数据并送入FIFO中
reg[7:0] num;		//读数据操作标志位
reg 		wr_flag; //写操作标志位
reg		rd_flag;
//命令解析宏定义
parameter CMD_HEAD		= 8'h53;	//0x53 -->83
parameter CMD_TAIL		= 8'hcd;
parameter CMD_LEN			= 4'h8;	//

parameter CMD_SETUP		= 8'ha0;	//0xa0 -->160
parameter CMD_ECT_SET	= 8'ha1;
parameter CMD_ERT_SET	= 8'ha2;

parameter CMD_RESET		= 8'h35;	//0x35 -->53
parameter CMD_ECT_RST	= 8'h36;	//0xa2 -->162
parameter CMD_ERT_RST	= 8'h37;	//0xa2 -->162

parameter CMD_SLEEP		= 8'h11;
parameter CMD_ECT_SLP	= 8'h12;	//睡眠
parameter CMD_ERT_SLP	= 8'h13;

parameter CMD_FREQ		= 8'h70;
parameter CMD_ECT_FREQ	= 8'h71;	//频率设置
parameter CMD_ERT_FREQ	= 8'h72;
//-----------------------------------------
reg[3:0] fxstate;	//状态寄存器
parameter	FXS_REST	= 4'd0;
parameter	FXS_IDLE	= 4'd1;
parameter	FXS_READ	= 4'd2;
parameter	FXS_RSOP = 4'd3;
parameter	FXS_WRIT	= 4'd4;
parameter	FXS_WSOP	= 4'd5;

//定时读写操作状态机
always @(posedge usb_clk or negedge sys_rst)
	if(!sys_rst) fxstate <= FXS_REST;
	else begin
		case(fxstate)
			FXS_REST: begin
				fxstate <= FXS_IDLE;
			end
			
			FXS_IDLE: begin
				if(fx2_flaga) fxstate <= FXS_READ;			//读数据，读取数据个数是8
				else if(fx2_flagc) fxstate <= FXS_WRIT;	//写数据
				else fxstate <= FXS_IDLE;
			end
			
			FXS_READ: begin
				if(!fx2_flaga) fxstate <= FXS_RSOP;
				else fxstate <= FXS_READ;
			end
			
			FXS_RSOP:fxstate <= FXS_IDLE;
			
			FXS_WRIT: begin
				if(!fx2_flagc) fxstate <= FXS_WSOP;
				else fxstate <= FXS_WRIT;
			end
			
			FXS_WSOP: fxstate <= FXS_IDLE;
			default: fxstate <= FXS_IDLE;
		endcase
	end

//数据计数器，用于产生读写时序
always @(posedge usb_clk or negedge sys_rst)
	if(!sys_rst)
		num <= 8'h0;
	else if(fxstate == FXS_READ)
		num <= num + 8'h1;
	else
		num <= 8'h0;
//--------------------------------------------------------------------------
always @(posedge usb_clk or negedge sys_rst)
	if(!sys_rst)
		wr_flag <= 1'b0;
	else if(fxstate == FXS_READ || fxstate == FXS_WRIT)
		wr_flag <= ~ wr_flag;
	else
		wr_flag <= 1'b0;
//--------------------------------------------------------------------------
//always @(posedge usb_clk or negedge sys_rst)
//	if(!sys_rst)
//		rd_flag <= 1'b0;
//	else if((fxstate == FXS_READ)&&(num >= 8'h2))
//		rd_flag <= ~ rd_flag;
//	else
//		rd_flag <= 1'b0;
/////////////////////////////////////////////////////////////
//FX2 Slave FIFO控制信号时序产生
parameter FX2_ON	= 1'b0;
parameter FX2_OFF	= 1'b1;

assign fx2_pktend_n	= FX2_OFF;

always @(posedge usb_clk or negedge sys_rst)
	if(!sys_rst) begin
		fx2_slcs_n <= FX2_OFF;
		fx2_slwr_n <= FX2_OFF;
		fx2_slrd_n <= FX2_OFF;
		fx2_sloe_n <= FX2_OFF;
		fx2_a <= 2'b00;
	end
	else if(fxstate == FXS_READ) begin

		if(!wr_flag) begin
			fx2_slcs_n <= FX2_ON;
			fx2_slwr_n <= FX2_OFF;
			fx2_slrd_n <= FX2_ON;
			fx2_sloe_n <= FX2_ON;
			fx2_a <= 2'b00;
		end
		else if(wr_flag)begin
			fx2_slcs_n <= FX2_ON;
			fx2_slwr_n <= FX2_OFF;
			fx2_slrd_n <= FX2_OFF;
			fx2_sloe_n <= FX2_ON;
			fx2_a <= 2'b00;
		end
		else if(!fx2_flaga)begin
			fx2_slcs_n <= FX2_OFF;
			fx2_slwr_n <= FX2_OFF;
			fx2_slrd_n <= FX2_OFF;
			fx2_sloe_n <= FX2_OFF;
			fx2_a <= 2'b00;
		end
	end
	else if(fxstate == FXS_WRIT) begin
		if(!wr_flag) begin
			fx2_slcs_n <= FX2_ON;
			fx2_slwr_n <= FX2_OFF;
			fx2_slrd_n <= FX2_OFF;
			fx2_sloe_n <= FX2_OFF;
			fx2_a <= 2'b10;
		end
		else if(wr_flag) begin
			fx2_slcs_n <= FX2_ON;
			fx2_slwr_n <= FX2_ON;
			fx2_slrd_n <= FX2_OFF;
			fx2_sloe_n <= FX2_OFF;
			fx2_a <= 2'b10;
		end
		else if(!fx2_flagc || fifo_empty)begin
			fx2_slcs_n <= FX2_OFF;
			fx2_slwr_n <= FX2_OFF;
			fx2_slrd_n <= FX2_OFF;
			fx2_sloe_n <= FX2_OFF;
			fx2_a <= 2'b10;
		end	
	end
	else begin
		fx2_slcs_n <= FX2_OFF;
		fx2_slwr_n <= FX2_OFF;
		fx2_slrd_n <= FX2_OFF;
		fx2_sloe_n <= FX2_OFF;
	end 

/////////////////////////////////////////////////////////////

reg	[7:0]		frm_head,frm_cmd;
reg	[15:0]	pc_data;			//FX2读出数据缓存
reg	[15:0]	fx_wdb;

always@(posedge usb_clk or negedge sys_rst)
	if(!sys_rst)begin
		
	end
	else if((fxstate == FXS_READ)) begin	// 

	end
	else begin

	end

//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
assign fx2_db = ((fxstate == FXS_WRIT) && (!wr_flag)) ? fifo_data : 16'hzzzz;	//FX2数据总线方向控制	

/////////////////////////////////////////////////////////////

always @(posedge usb_clk or negedge sys_rst)
	if(!sys_rst)begin
		led_usb <= 1'b1;
		fifo_rd_req <= 1'b0;
	end
	else if((fxstate == FXS_WRIT) && !wr_flag)begin
		fifo_rd_req <= 1'b1;
		led_usb <= 1'b0;
	end
	else begin
		fifo_rd_req <= 1'b0;
		led_usb <= 1'b1;
	end

//------------------------------------------------------------------
//always@(posedge usb_clk or negedge sys_rst)
//	if(!sys_rst)
//		begin
//			demod_mode	<= 4'h0;
//			demod_chn	<= 8'h00;
//			pga_gain		<= 4'h0;
//			rst_sleep	<= 4'hf;
//		end
//	else
//		begin
//			demod_mode	<= 4'h0;
//			demod_chn	<= 8'h00;
//			pga_gain		<= 4'h0;
//			rst_sleep	<= 4'hf;
//		end
//
//	else if((frm_head == CMD_HEAD)&&(tail_data == CMD_TAIL))
//		case(frm_cmd)
//			CMD_RESET : begin				//ECT/ERT都复位
//				rst_sleep <= 4'b0011;	
//			end
//			
//			CMD_ECT_RST : begin			//ECT复位
//				rst_sleep <= 4'b0111;	
//			end
//			
//			CMD_ERT_RST : begin			//ERT复位
//				rst_sleep <= 4'b1011;
//			end
////---------------------------------------------------------
//			CMD_SLEEP : begin				//ECT/ERT都睡眠
//				rst_sleep <= 4'b1100;	
//			end
//			
//			CMD_ECT_SLP : begin		//ECT睡眠
//				rst_sleep <= 4'b1101;	
//			end
//			
//			CMD_ERT_SLP : begin		//ERT睡眠
//				rst_sleep <= 4'b1110;	
//			end
////----------------------------------------------------------
//			CMD_SETUP	: begin
//				demod_mode	<= demod_data[3:0];
//				pga_gain		<= demod_data[7:4];
//				demod_chn	<= demod_data[15:8];
//			end
//			CMD_ECT_FREQ : begin			//ECT激励频率/采样频率设置
//				ect_freq <= 4'b1101;	
//			end
//			
//			CMD_ERT_FREQ : begin			//ERT激励频率/采样频率设置
//				ert_freq <= 4'b1110;	
//			end
//----------------------------------------------------------		
//			CMD_ECT_SET : begin
//				ect_demod_mode	<= demod_data[3:0];
//				ect_pga_gain	<= demod_data[7:4];
//				ect_demod_chn	<= demod_data[15:8];
//			end
//			
//			CMD_ERT_SET : begin
//				ert_demod_mode	<= demod_data[3:0];
//				ert_pga_gain	<= demod_data[7:4];
//				ert_demod_chn	<= demod_data[15:8];
//			end
//----------------------------------------------------------
//			default : rst_sleep	<= 4'hf;
//		endcase
//	else
//		begin
//			demod_mode	<= 4'h0;
//			demod_chn	<= 8'h00;
//			pga_gain		<= 4'h0;
//			rst_sleep	<= 4'hf;
//		end
//--------------------------------------------------------------------------

//----------命令解析---------------
//always@(*)
//	if(!sys_rst)
//		begin
//			frm_data		<= 16'h0000;
//			demod_data	<= 16'h0000;
//			gain_data	<= 16'h0000;
//			tail_data	<= 16'h0000;
//			frm_head		<= 8'h00;
//			frm_cmd		<= 8'h00;
//		end
//	else if(fxstate == FXS_READ)
//		case(num)
//			4'h2 : begin
//				frm_data		<= pc_data;
//			end
//			4'h3 : begin
//				demod_data	<= pc_data;
//			end
//			4'h4 : begin
//				gain_data	<= pc_data;
//			end
//			4'ha : begin
//				tail_data	<= pc_data;
//			end
//			default : begin
////				frm_head <= frm_data[7:0];		//获取帧头
////				frm_cmd	<= frm_data[15:8];	//获取命令码
//			end
//		endcase

//	else
//		begin
//			frm_data		<= 16'h2222;
//			demod_data	<= 16'h2222;
//			gain_data	<= 16'h2222;
//			tail_data	<= 16'h2222;
//			frm_head		<= 8'h00;
//			frm_cmd		<= 8'h00;
//		end









endmodule

