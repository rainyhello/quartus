`timescale 1ns/1ps
//**************************************************************//
//**************************************************************//
//Project Name: Novel ECT Hardware Design
//
//Author: Yunjie Yang
//Create  Date: 16:16 2014-11-15
//Design  Name: ECTNew
//Module  Name: UART SpeedSelect, UARTRecieve, UARTSend.
//Target Devices: EP3C25F324C8
//Tool versions: 13.1
//Descriptions: This module realizes UART protocol.
//Revision:
//**************************************************************//
//**************************************************************//


/////////////////////////////////////////////////////////////////
//Module 1: UART SpeedSelect
/////////////////////////////////////////////////////////////////
module UARTSpeedSelect
(
	CLK, RST, BpsStart, ClkBps
);

	input CLK;      //System clk
	input RST;  	 //Global reset 
	input BpsStart; //Bps signal start

	output ClkBps;  //Bps signal output

	/*************************************************************
			Using 50 MHz CLK
			1s/bps/20ns=5208.33333~5208
			parameter          bps9600     = 5208, 2604
									 bps19200    = 2604, 1302
									 bps38400    = 1302, 652
									 bps57600    = 868,  434
									 bps115200   = 434;  217
									 bps454000   = 110;  55 
									 bps460000   = 108;  54
									 bps1000000  = 50;   25
		    Using 40 MHz CLK
		    1s/19200/25ns  =2083  1041
		    1s/38400/25ns  =1042  521  
		    1s/57600/25ns  =694   347
          1s/115200/25ns =347   174  			 
	**************************************************************/

	`define BPS_PAR  50  //bps1000000
	`define BPS_PAR2 25  //bps1000000

	reg [12:0] cnt;
	reg ClkBpsR;

	reg[2:0] UARTCtrl;
	

	always @ (posedge CLK or negedge RST)

		if (!RST) 
			cnt <= 13'd0;
		else if (cnt == `BPS_PAR || !BpsStart) //Disable bps
			cnt <= 13'd0;
		else 												//Enable bps
			cnt <= cnt + 1'b1;

	always @ (posedge CLK or negedge RST)

		if (!RST) 
			ClkBpsR <= 1'b0;
		else if (cnt == `BPS_PAR2) 
			ClkBpsR <= 1'b1;
		else 
			ClkBpsR <= 1'b0;
		
		assign ClkBps = ClkBpsR;
		
endmodule

/////////////////////////////////////////////////////////////////
//Module 2: UART Send One Byte
/////////////////////////////////////////////////////////////////
module UARTSend
(
	CLK, RST, DataLock, DataIn, Available, ClkBps, BpsStart, TXD
);

	input CLK,RST,DataLock,ClkBps;
	input[7:0] DataIn;
	output Available,BpsStart,TXD;
	
	reg Available;        //1 means send available; 0 means not available
	
	reg [7:0] DataBuffer; //Data buffer
	reg BpsStartR;
	reg [3:0] num;
	reg [3:0] stat;
	reg PreDataLock; //One positive pulse of datalock to lock the data to the send buffer

	always @ (posedge CLK or negedge RST)
		if(!RST) begin
				BpsStartR <= 1'bz;
				Available <= 1'b1;
				DataBuffer <= 8'd0;
				PreDataLock <= 0;
				stat <= 0;
			end
		else begin
				PreDataLock <= DataLock;
				case(stat)
					0:
						if (PreDataLock==0&&DataLock==1) begin //Start Sending Data
									BpsStartR <= 1'b1;            //Start bound rate
									DataBuffer <= DataIn;	
									Available <= 1'b0;            //Diassert available
									stat <= stat + 4'd1;
						end		
					1:
						if (num==4'd11) begin						//One send finished
									BpsStartR <= 1'b0;
									Available <= 1'b1;
									stat <= 0;
						end
					default: stat <= 0;
				endcase
			end

	assign BpsStart = BpsStartR;

	reg TXDTemp; //Temp reg for TXD

	always @ (posedge CLK or negedge RST)
		if(!RST) begin
				num <= 4'd0;
				TXDTemp <= 1'b1;
			end
		else if(!Available) begin // Busy sending current task
				if(ClkBps)	begin
						num <= num+1'b1;
						case (num)
							4'd0: TXDTemp <= 1'b0; 	   
							4'd1: TXDTemp <= DataBuffer[0];	//bit0
							4'd2: TXDTemp <= DataBuffer[1];	//bit1
							4'd3: TXDTemp <= DataBuffer[2];	//bit2
							4'd4: TXDTemp <= DataBuffer[3];	//bit3
							4'd5: TXDTemp <= DataBuffer[4];	//bit4
							4'd6: TXDTemp <= DataBuffer[5];	//bit5
							4'd7: TXDTemp <= DataBuffer[6];	//bit6
							4'd8: TXDTemp <= DataBuffer[7];	//bit7
							4'd9: TXDTemp <= 1'b1;	  
							default: TXDTemp <= 1'b1;
							endcase
					end
				else if(num == 4'd11) num <= 4'd0;	
			end

	assign TXD = TXDTemp;

endmodule

/////////////////////////////////////////////////////////////////
//Module 3: UART Recieve One Byte
/////////////////////////////////////////////////////////////////
module UARTRecieve
(
	CLK, RST, ClkBps, URX, BpsStart, DataOut, DataReady
);
	input CLK;
	input RST;
	input URX;
	input ClkBps;
	output BpsStart;
	output [7:0] DataOut;
	output DataReady;             //When equals 1, data is ready to read out

	reg DataReady;
	reg URX0, URX1, URX2, URX3;

	wire NegURx;

	always @ (posedge CLK or negedge RST)
		if (!RST) begin
			URX0 <= 1'b0;
			URX1 <= 1'b0;
			URX2 <= 1'b0;
			URX3 <= 1'b0;
		end
		else begin
			URX0 <= URX;
			URX1 <= URX0;
			URX2 <= URX1;
			URX3 <= URX2;
		end

	assign NegURx = URX3 & URX2 & ~URX1 & ~URX0; //Debouncing of RX signal, detect of positive pulse stably

	reg BpsStartR;
	reg [3:0] num;
	reg RxInit;
	reg [3:0] stat;

	always @ (posedge CLK or negedge RST)
		if (!RST) begin
			BpsStartR <= 1'bz;
			DataReady <= 1'b0;
			stat <= 0;
			end
		else begin
			case (stat)
				0:
					if (NegURx) begin              
							BpsStartR <= 1'b1;
							DataReady <= 0;
							RxInit <= 1'b1;
							stat <= stat + 4'd1;
						end
				1:
					if (num == 4'd12) begin
							BpsStartR <= 1'b0;
							RxInit <= 1'b0;
							DataReady <= 1;
							stat <= stat + 4'd1;
						end
				5:
					begin
						DataReady <= 0;
						stat <= 0;
					end
				default: stat <= 0;
			endcase
		end

	assign BpsStart = BpsStartR;

	reg [7:0] RxDataR;
	reg [7:0] RxTempData;

	always @ (posedge CLK or negedge RST)
		if (!RST) begin
				RxTempData <= 8'd0;
				num <= 4'd0;
				RxDataR <= 8'd0;
			end
		else if (RxInit) begin                //start to recieve data
				if (ClkBps) begin
						num <= num + 1'b1;
						case (num)
							4'd1: RxTempData[0] <= URX;
							4'd2: RxTempData[1] <= URX;
							4'd3: RxTempData[2] <= URX;
							4'd4: RxTempData[3] <= URX;
							4'd5: RxTempData[4] <= URX;
							4'd6: RxTempData[5] <= URX;
							4'd7: RxTempData[6] <= URX;
							4'd8: RxTempData[7] <= URX;
							default: ;
						 endcase
						end
				 
				 else if (num == 4'd12) begin
						num <= 4'd0;
						RxDataR <= RxTempData;
						end		
		end

	assign DataOut = RxDataR;
										
endmodule
