//**************************************************************//
//**************************************************************//
//Project Name: Novel ECT Hardware Design
//
//Author: Yunjie Yang
//Create  Date: 16:16 2014-11-15
//Design  Name: ECTNew
//Module  Name: ReqADCSample
//Target Devices: EP3C25F324C8
//Tool versions: 13.1
//Descriptions: This module requests data sampling from ADC.
//Revision:
//**************************************************************//
//**************************************************************//

module ReqADCSample
(
    Clk, Rst,
	 SysState, //System state
	 Enable, Done, //Hand shaking signal
	 
	 UARTAvl,UARTDatReady,UARTReceive,UARTSend,UARTDatLock,
	 
	 DemodEnCh1, DemodReadyCh1, DemodResultCh1, //Channel 1
	 DemodEnCh2, DemodReadyCh2, DemodResultCh2  //Channel 2
);
    //Parameters: command word
	 parameter MeasCtrlWord = 8'h06; //State request ch1 demodulation
	 
	 //Define

	 
	 //Interface
	 input Clk, Rst;
	 
	 input [7:0] SysState;
	 input Enable;
	 
	 input UARTDatReady;
	 input [7:0] UARTReceive;
	 
	 input UARTAvl;
	 output reg [7:0] UARTSend;
	 output reg UARTDatLock;
	 
	 input DemodReadyCh1;
	 input DemodReadyCh2;
	 input [31:0] DemodResultCh1;
	 input [31:0] DemodResultCh2;
	 output reg DemodEnCh1;
	 output reg DemodEnCh2;
	 
	 output Done;                  //Finish
	 reg DoneCh1, DoneCh2;
	 
	 assign Done = DoneCh1 || DoneCh2;
	 
	 //Interal regs
	 reg [31:0] tempDemodCh1;
	 reg [31:0] tempDemodCh2;
	 reg [3:0] Cnt1;
	 reg [3:0] Cnt2;
	 reg [3:0] Stat1;
	 reg [3:0] Stat2;
	 
	 /*
	 //This is the code for ch1
	 always @ (posedge Clk or negedge Rst)
		if (!Rst) begin			
			DemodEnCh1 <= 0;
			DemodEnCh2 <= 0;
			DoneCh1 <= 0;
			DoneCh2 <= 0;
			tempDemodCh1 <= 32'd0;
			tempDemodCh1 <= 32'd0;
			Cnt1 <= 4'd0;
			Stat1 <= 4'd0;
			
			UARTSend <= 8'd0;
			UARTDatLock <= 0;			
		end
		///////////////////////////////////////////////////////////////Channel 1
		else if (Enable == 1 && SysState == ReqOneDmdCh1) begin
			case (Stat1)
			0: begin
					DemodEnCh1 <= 1;
					tempDemodCh1 <= 32'd0;
					DoneCh1 <= 0;
					Stat1 <= 4'd1;
				end
			1: begin //Waiting for the demod done
					if (DemodReadyCh1) begin
							tempDemodCh1 <= DemodResultCh1;
							DemodEnCh1 <= 0;
							Cnt1 <= 4'd0;
							Stat1 <= 4'd2;
						end
					else begin
							Stat1 <= 1;
						end
				end
			2: begin //Send out via UART
					if (Cnt1 == 4'd4) begin
							Stat1 <= 4'd4;         /////////////////////////////////
							Cnt1 <= 4'd0;
							DoneCh1 <= 1;
					end
					else begin
							UARTDatLock <= 0;
							UARTSend <= tempDemodCh1 [31:24];
							tempDemodCh1 <= (tempDemodCh1 << 8);
							Cnt1 <= Cnt1 + 4'd1;
							Stat1 <= 4'd3;
					end
				end
			3: begin
					if (UARTAvl) begin
							UARTDatLock <= 1;
							Stat1 <= 4'd2;
					end
					else begin
							Stat1 <= 4'd3;
					end
				end
			4: begin
					Stat1 <= 4'd4;
				end
			
			default: Stat1 <= 4'd0;
			endcase									
		end
		///////////////////////////////////////////////////////////////Channel 2
		else if (Enable == 1 && SysState == ReqOneDmdCh2) begin
			case (Stat2)
			0: begin
					DemodEnCh2 <= 1;
					tempDemodCh2 <= 32'd0;
					DoneCh2 <= 0;
					Stat2 <= 4'd1;
				end
			1: begin //Waiting for the demod done
					if (DemodReadyCh2) begin
							tempDemodCh2 <= DemodResultCh2;
							DemodEnCh2 <= 0;
							Cnt2 <= 4'd0;
							Stat2 <= 4'd2;
						end
					else begin
							Stat2 <= 1;
						end
				end
			2: begin //Send out via UART
					if (Cnt2 == 4'd4) begin
							Stat2 <= 4'd4;         /////////////////////////////////
							Cnt2 <= 4'd0;
							DoneCh2 <= 1;
					end
					else begin
							UARTDatLock <= 0;
							UARTSend <= tempDemodCh2 [31:24];
							tempDemodCh2 <= (tempDemodCh2 << 8);
							Cnt2 <= Cnt2 + 4'd1;
							Stat2 <= 4'd3;
					end
				end
			3: begin
					if (UARTAvl) begin
							UARTDatLock <= 1;
							Stat2 <= 4'd2;
					end
					else begin
							Stat2 <= 4'd3;
					end
				end
			4: begin
					Stat2 <= 4'd4;
				end
			
			default: Stat2 <= 4'd0;
			endcase									
		end		
	   ///////////////////////////////////////////////////////////////Finished
		else if (Enable == 0) begin
			DoneCh1 <= 0;
			DoneCh2 <= 0;
			Stat1 <= 0;
			Stat2 <= 0;
		end
		*/
		
endmodule
		
				
				
				
				
				
				
				
				