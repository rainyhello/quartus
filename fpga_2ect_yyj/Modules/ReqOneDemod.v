//**************************************************************//
//**************************************************************//
//Project Name: Novel ECT Hardware Design
//
//Author: Yunjie Yang
//Create  Date: 16:16 2014-11-15
//Design  Name: ECTNew
//Module  Name: ReqOneDemod
//Target Devices: EP3C25F324C8
//Tool versions: 13.1
//Descriptions: This module request onetime demodulation from two channels.
//Revision:
//**************************************************************//
//**************************************************************//

module ReqOneDemod
(
    Clk, Rst,
	 SysState, //System state
	 Enable, Done, //Hand shaking signal
	 
	 USBFIFOFul,USBWrite,USBWreq,NumFIFO,ApplyUSB,
	 
	 DemodEn1Ch, DemodReady1Ch, DemodResult1Ch, //Channel 1
	 DemodEn2Ch, DemodReady2Ch, DemodResult2Ch  //Channel 2
	 
);
    //Parameters: command word
	 parameter ReqOneDmdCh1 = 16'h0002; //State request ch1 demodulation
	 parameter ReqOneDmdCh2 = 16'h0003; //State request ch2 demodulation
	 
	 //Define

	 
	 //Interface
	 input Clk, Rst;
	 
	 input [15:0] SysState;
	 input Enable;
	 
	 input USBFIFOFul;
	 input [9:0] NumFIFO;
	 output reg [31:0] USBWrite;
	 output reg USBWreq;
	 
	 input DemodReady1Ch;
	 input DemodReady2Ch;
	 input [31:0] DemodResult1Ch;
	 input [31:0] DemodResult2Ch;
	 output reg DemodEn1Ch;
	 output reg DemodEn2Ch;
	 
	 output Done;                  //Finish
	 reg DoneCh1, DoneCh2;
	 
	 output reg ApplyUSB;         //Apply for USB bus, if avl get the authority
	 
	 assign Done = DoneCh1 || DoneCh2;
	 
	 //Interal regs
	 reg [31:0] tempDemodCh1;
	 reg [31:0] tempDemodCh2;
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
			Stat1 <= 4'd0;
			Stat2 <= 4'd0;
			
			USBWrite <= 32'd0;
			USBWreq <= 0;
	      ApplyUSB <= 0;		
		end
		///////////////////////////////////////////////////////////////Channel 1
		else if (Enable == 1 && SysState == ReqOneDmdCh1) begin
			case (Stat1)
			0: begin
					DemodEn1Ch <= 1;
					tempDemodCh1 <= 32'd0;
					DoneCh1 <= 0;
					USBWreq <= 0;
					ApplyUSB <= 0;
					
					Stat1 <= 4'd1;
				end
			1: begin //Waiting for the demod done
					if (DemodReady1Ch) begin
						   ApplyUSB <= 1; //Apply for bus
							tempDemodCh1 <= DemodResult1Ch;
							DemodEn1Ch <= 0;
							
							Stat1 <= 4'd2;
						end
					else begin
							Stat1 <= 1;
						end
				end
			2: begin //Write to USB FIFO
					if (!USBFIFOFul && NumFIFO < 1023) begin
						USBWreq <= 1;
						USBWrite <= tempDemodCh1;
						Stat1 <= 4'd3;
					end
					else begin
						Stat1 <= 4'd2;
					end
				end
			3: begin
					USBWreq <= 0;
					DoneCh1 <= 1;
					ApplyUSB <= 0;
					Stat1 <= 4'd3;
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
					USBWreq <= 0;
					ApplyUSB <= 0;
					
					Stat2 <= 4'd1;
				end
			1: begin //Waiting for the demod done
					if (DemodReady2Ch) begin
					      ApplyUSB <= 1;
							tempDemodCh2 <= DemodResult2Ch;
							DemodEn2Ch <= 0;
							
							Stat2 <= 4'd2;
						end
					else begin
							Stat2 <= 1;
						end
				end
			2: begin //Write to USB FIFO
					if (!USBFIFOFul && NumFIFO < 1023) begin
						USBWreq <= 1;
						USBWrite <= tempDemodCh2;
						Stat2 <= 4'd3;
					end
					else begin
						Stat2 <= 4'd2;
					end
				end
			3: begin
					USBWreq <= 0;
					ApplyUSB <= 0;
					DoneCh1 <= 1;
					Stat2 <= 4'd3;
				end
			
			default: Stat2 <= 4'd0;
			endcase								
		end		
	   ///////////////////////////////////////////////////////////////Finished
		else if (Enable == 0) begin
			DoneCh1 <= 0;
			DoneCh2 <= 0;
			USBWreq <= 0;
			ApplyUSB <= 0;
			Stat1 <= 0;
			Stat2 <= 0;
		end
		
endmodule
		
				
				
				
				
				
				
				
				