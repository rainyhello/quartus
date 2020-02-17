`timescale 1ns/1ps
//**************************************************************//
//**************************************************************//
//Project Name: Novel ECT Hardware Design
//
//Author: Yunjie Yang
//Create  Date: 16:16 2014-11-15
//Design  Name: ECTNew
//Module  Name: USBCtrl
//Target Devices: EP3C25F324C8
//Tool versions: 13.1
//Descriptions: This module realizes the Slave FIFO methods of USB2.0.
//Revision:
//**************************************************************//
//**************************************************************//

module USBCtrl
(
    IFCLK, RST,                           //Input, Clk from FPGA, 5 - 48MHz
	 //Internal ctrl signal
	 WState, Send,                         //Number to write
	 RState, Receive, RReady,              //Number to readt
	 //USB Slave FIFO Signal
	 USBDat,                               //Bidirection
	 FIFOEmp, FIFOFull, FIFOPf, USBFlagD,  //Input, Flags from Cypress
	 USBInt0,                              //Interuppt
	 USBSloe, USBSlrd, USBSlwr,            //Output, ctrl signal
	 FIFOAddr,                             //Output, selection of endpoint 2 4 6 8
	 PKTEND,                               //Packet end signal
	 TestLED,
	 
	 //External write fifo
	 USBEmpty, USBNum, USBRreq
	 
);
    //Parameters
	 parameter EP2 = 2'b00;                    //Using EP2 as out to fpaga, computer write to ep2
	 parameter EP4 = 2'b01;
	 parameter EP6 = 2'b10;                    //Using EP6 as in from fpga, computer read from ep6
	 parameter EP8 = 2'b11;
	 parameter IDLE = 4'd0;
    parameter WRITE = 4'd4;
	 parameter WDONE = 4'd5;
	 parameter READ = 4'd2;
	 parameter RDONE = 4'd3;
	 
	 //Define
	 
	 
	 //FIFO Interface
	 input IFCLK, RST;                       //Input clk should be 5Mhz to 48Mhz for the fifo operation
	 
	 output [3:0] WState, RState;
	 
	 input [15:0] Send;
	 output reg [15:0] Receive;
	 output reg RReady;
	 
	 input FIFOEmp;                          //EP2 OUT
	 input FIFOFull;                         //EP6 IN (FPGA write to EP6), full flag: FIFOFull;
	 input FIFOPf, USBFlagD;
	 
	 inout [15:0] USBDat;
	 output reg [1:0] FIFOAddr;              //Endpoint 2 4 6 8
	 output reg USBSlrd, USBSlwr, USBSloe;
	 output reg USBInt0;
	 output reg PKTEND;
	 
	 output reg TestLED;
	 
	 //External FIFO
	 input USBEmpty;
	 output reg USBRreq;
	 input [13:0] USBNum;	 
	 reg WEnable;
    reg Done; 	 
	 
	 //Internal Variables
	 reg [3:0] StatW;
	 reg [3:0] StatR;
	 reg [15:0] UDatOut;                  //FPGA->USB
	 reg [15:0] tempData;
	 
	 //Tri state
	 assign USBDat = USBSlwr? 16'bZ: UDatOut;
	 
	 //State
	 assign WState = StatW;
	 assign RState = StatR;
	 
	 
	 initial begin
	 	USBSlwr = 1;          //Disassert wr
		USBSloe = 1;          //Disassert sloE
		USBSlrd = 1;          //Disassert slrD
		USBInt0 = 1;
		PKTEND = 1;
		FIFOAddr = EP2;
	 end
	
	 //Rd and Wr signal ctrl and FIFO Addr Ctrl
	 always @(*)
		if (StatW == WRITE) begin //Write stat
			USBSlwr <= 0;          //Assert wr
			USBSloe <= 1;          //Disassert sloE
			USBSlrd <= 1;          //Disassert slrD
			
			FIFOAddr <= EP6;
		end
		else if (StatR == READ) begin
			USBSlwr <= 1;          //Disassert wr
			USBSloe <= 0;          //Assert sloE
			USBSlrd <= 0;          //Assert slrD
			
			FIFOAddr <= EP2;
		end
		else begin
			USBSlwr <= 1;          //Disassert wr
			USBSloe <= 1;          //Disassert sloE
			USBSlrd <= 1;          //Disassert slrD
			
			FIFOAddr <= EP2;
		end
			
			
//////////////////////////////////////////////////////////////////////////////////////////////////////////////USB Write with External FIFO			
	 //External FIFO
	 always @ (posedge IFCLK or negedge RST)
		if (!RST) begin
			WEnable <= 0;
		end
		else if (!USBEmpty && USBNum > 0) begin     //FIFO not empty, send data out
			WEnable <= 1;
		end
		else if (USBEmpty && Done) begin            //Already sent out
			WEnable <= 0;
		end
	 
	 ////////////////////////////////////////////////////////////////////FPGA Write to USB
	 //Sychronous Slave FIFO Writes, EP6 as IN, FPGA write to the USB
	 always @ (posedge IFCLK or negedge RST)
		if (!RST) begin
			UDatOut <=  16'd0;
			tempData <= 0;
			PKTEND <= 1;
			
			StatW <= 4'd0;
		end
		else if (WEnable) begin
			case (StatW)
			IDLE: begin
					//External
					USBRreq <= 1;
					Done <= 0;
					PKTEND <= 1;	 
						 
					StatW <= 4'd1;
				end
			1: begin
					USBRreq <= 0; //Deassert Request
					StatW <= 4'd2;
				end
			2: begin
					tempData <= Send;
					StatW <= 4'd3;
				end
			3: begin		
					if (FIFOFull && WEnable) begin      //EP6 is not full, active low
						StatW <= WRITE;
						if (tempData == 16'hFAFA) begin
							PKTEND <= 0;
						end
					end
					else begin
						StatW <= StatW;                   
					end
				end
			WRITE: begin
					UDatOut <= tempData;                //Drive data on the bus					
					Done <= 1;
					StatW <= WDONE;                     //More data to send
					
					if (tempData == 16'hFAFA) begin
						PKTEND <= 1;
					end
					
				end
			WDONE: begin
					StatW <= IDLE;
				end
					 
			 default: StatW <= IDLE;
			 endcase
		end
		else if (!WEnable) begin
			PKTEND <= 1;
			Done <= 0;
			StatW <= IDLE;
		end
	 ////////////////////////////////////////////////////////////////////FPGA Write to USB End
//////////////////////////////////////////////////////////////////////////////////////////////////////////////USB Write with External FIFO		

				
	 ////////////////////////////////////////////////////////////////////Computer write to USB to FPGA
	 //Sychronous Slave FIFO Read, EP2 as OUT ENDpoint
	 always @ (posedge IFCLK or negedge RST)
	 
		if (!RST) begin
			Receive <=  16'd0;
			RReady <= 0;
			TestLED <= 1;
			
			StatR <= 4'd0;
		end
		else begin
			case (StatR)						
			IDLE: begin				 
				   RReady <= 0;
					StatR <= 4'd1;
			   end
			1: begin
					if (FIFOEmp && !WEnable) begin       //FIFO is not empty, can read
						StatR <= READ;		
					end
					else begin
						StatR <= StatR;
					end
				end
			READ: begin		
					Receive <= USBDat;                   //Sample the data
					
					//if (USBDat == 16'hAA00)
					//	TestLED <= ~TestLED;
					RReady <= 1;
					
					StatR <= RDONE;
				end
			RDONE: begin
						StatR <= IDLE;
					end
			
			 default: StatR <= IDLE;
			 endcase
		end		
						
endmodule
