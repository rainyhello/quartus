`timescale 1ns/1ps
//**************************************************************//
//**************************************************************//
//Project Name: Novel ECT Hardware Design
//
//Author: Yunjie Yang
//Create  Date: 16:16 2014-11-15
//Design  Name: ECTNew
//Module  Name: SendCtrl
//Target Devices: EP3C25F324C8
//Tool versions: 13.1
//Descriptions: This module realizes the read logic of FIFO buffer and the send logic of UART. When rdempty is low, always send data.
//Revision:
//**************************************************************//
//**************************************************************//

module SendCtrl
(
    CLK, RST, 
	 RdEmpty, RdReq, Q,               //Interface for reading the fifo
	 DataLock, DataOut, SendAvailable //Interface for sending data via UART TX
);
    //Parameters
	 
	 
	 //Macro Defination
	 
	 
	 //Interface for FIFO Rd
	 input CLK, RST;
	 input RdEmpty;           //Assert High
	 input [7:0] Q;           //First low byte, then high byte
    output RdReq;            //High
	 
	 //Interface for UART Send Ctrl
	 input SendAvailable;     //High == Available
	 output reg DataLock;     //Posedge lock the data to send
	 output reg [7:0] DataOut;//Data for Send

	 //Internal Registers
	 reg [3:0] Stat;           //State machine state
	 
	 assign RdReq = SendAvailable && (~RdEmpty);
		
    //Logic for UART send, posedge of clk
	 always @ (posedge CLK or negedge RST)
	 
		if (RST==0) begin
			DataLock <= 0;
			DataOut <= 0;
			Stat <= 0;
			end
		else if (RdReq) begin        //If the FIFO is NOT empty, start sending to UART
			case (Stat)
			0: begin
				DataOut <= Q;          //The lowest byte first
				DataLock <= 0;
				Stat <= Stat + 1;
				end
			1: begin
				DataLock <= 1;
				Stat <= 0;
				end
			default: Stat <= 0;
			endcase
		end
		else begin
			DataOut <= 0;
			DataLock <= 0;
			Stat <= 0;
		end
			
endmodule
	 