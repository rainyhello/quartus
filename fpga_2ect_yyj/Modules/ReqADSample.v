//**************************************************************//
//**************************************************************//
//Project Name: Novel ECT Hardware Design
//
//Author: Yunjie Yang
//Create  Date: 16:16 2014-11-15
//Design  Name: ECTNew
//Module  Name: ReqADSample
//Target Devices: EP3C25F324C8
//Tool versions: 13.1
//Descriptions: This module request onetime ADC waveform from two channels.
//Revision:
//**************************************************************//
//**************************************************************//

module ReqADSample
(
    Clk, Rst,
	 SysState, //System state
	 Enable, Done, //Hand shaking signal
	 
	 UARTAvl,UARTSend,UARTDatLock,ApplyUART,
	 
	 DemodEn1Ch, DemodReady1Ch, DemodResult1Ch, //Channel 1
	 DemodEn2Ch, DemodReady2Ch, DemodResult2Ch  //Channel 2
);
    //Parameters: command word
	 parameter ReqOneDmdCh1 = 8'h02; //State request ch1 demodulation
	 parameter ReqOneDmdCh2 = 8'h03; //State request ch2 demodulation
	 
	 //Define

	 
	 //Interface
	 input Clk, Rst;
	 
	 input [7:0] SysState;
	 input Enable;
	 
	 input UARTAvl;
	 output reg [7:0] UARTSend;
	 output reg UARTDatLock;
	 
	 input DemodReady1Ch;
	 input DemodReady2Ch;
	 input [31:0] DemodResult1Ch;
	 input [31:0] DemodResult2Ch;
	 output reg DemodEn1Ch;
	 output reg DemodEn2Ch;
	 
	 output Done;                  //Finish
	 reg DoneCh1, DoneCh2;
	 
	 output reg ApplyUART;         //Apply for UART bus, if avl get the authority
	 
	 assign Done = DoneCh1 || DoneCh2;
	 
	 //Interal regs
	 reg [31:0] tempDemodCh1;
	 reg [31:0] tempDemodCh2;
	 reg [3:0] Cnt1;
	 reg [3:0] Cnt2;
	 reg [3:0] Stat1;
	 reg [3:0] Stat2;
	 
	 
	 //This is the code for ch1
	 always @ (posedge Clk or negedge Rst)
		if (!Rst) begin			
			DemodEn1Ch <= 0;
			DemodEn2Ch <= 0;
			DoneCh1 <= 0;
			DoneCh2 <= 0;
			tempDemodCh1 <= 32'd0;
			tempDemodCh2 <= 32'd0;
			Cnt1 <= 4'd0;
		   Cnt2 <= 4'd0;
			Stat1 <= 4'd0;
			Stat2 <= 4'd0;
			
			UARTSend <= 8'd0;
			UARTDatLock <= 0;
	      ApplyUART <= 0;		
		end
		///////////////////////////////////////////////////////////////Channel 1
		else if (Enable == 1 && SysState == ReqOneDmdCh1) begin
			case (Stat1)
			0: begin
					DemodEn1Ch <= 1;
					tempDemodCh1 <= 32'd0;
					DoneCh1 <= 0;
					ApplyUART <= 0;
					Stat1 <= 4'd1;
				end
			1: begin //Waiting for the demod done
					if (DemodReady1Ch) begin
						   ApplyUART <= 1; //Apply for bus
							tempDemodCh1 <= DemodResult1Ch;
							DemodEn1Ch <= 0;
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
							ApplyUART <= 0;        //Release the bus
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
					DemodEn2Ch <= 1;
					tempDemodCh2 <= 32'd0;
					DoneCh2 <= 0;
					ApplyUART <= 0;
					Stat2 <= 4'd1;
				end
			1: begin //Waiting for the demod done
					if (DemodReady2Ch) begin
					      ApplyUART <= 1;
							tempDemodCh2 <= DemodResult2Ch;
							DemodEn2Ch <= 0;
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
						   ApplyUART <= 0;
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
					ApplyUART <= 0;
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
			ApplyUART <= 0;
		end
		
endmodule
		
				
				
				
				
				
				
				
				


	 
	 /*always @ (posedge CLK or negedge RST)
		
		if (!RST) begin
			UARTDatLock <= 0;
			SendOut <= 0;
			SendDone <= 0;
			Cnt1 <= 0;
			Stat1 <= 0;
		end
		else if (Ready) begin
			case (Stat1)
			0: begin                     
					if (Cnt1 == SampNum) begin
						Stat1 <= 4;
					end
					else begin
						SendDone <= 0;
						UARTDatLock <= 0;
						SendOut <= {1'b0, 1'b0, TempDat[Cnt1][13:8]};
						Stat1  <= 1;
					end
				end
			1: begin
					if (UARTAvl) begin
						UARTDatLock <= 1;
						Stat1 <= 2;
					end
					else begin
						Stat1 <= 1;
					end
				end
			2: begin
						UARTDatLock <= 0;
						SendOut <= {TempDat[Cnt1][7:2],1'b0, 1'b0};
						Stat1  <= 3;
				end
			3: begin
					if (UARTAvl) begin
						UARTDatLock <= 1;
						Stat1 <= 0;
						Cnt1 <= Cnt1 + 8'd1;
					end
					else begin
						Stat1 <= 3;
					end
				end
			4: begin
					Cnt1 <= 0;
					SendOut <= 0;
					UARTDatLock <= 0;
					SendDone <= 1;
					Stat1 <= 4;
				end
	
			default: Stat1 <= 0;
			endcase
	 end
	 else if (~Ready) begin
		Stat1 <= 0;
		SendDone <= 0;
	 end */