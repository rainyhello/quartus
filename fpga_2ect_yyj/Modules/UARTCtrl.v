//**************************************************************//
//**************************************************************//
//Project Name: Novel ECT Hardware Design
//
//Author: Yunjie Yang
//Create  Date: 16:16 2014-11-15
//Design  Name: ECTNew
//Module  Name: UARTCtrl
//Target Devices: EP3C25F324C8
//Tool versions: 13.1
//Descriptions: This module gets data from UART FIFO and sends out.
//Revision:
//**************************************************************//
//**************************************************************//

module UARTCtrl
(
    Clk, Rst,
	 //UART Interface
	 UARTAvl, UARTDatLock, UARTSend,
	 //FIFO
	 RdReq, Q, FIFOEmp, AlmostFul, NumFIFO,
	 //WrReq, D, FIFOFul, FIFOClr,
	 //RdThre,
	 TestLED
);
    //Parameters 
	 
	 
	 //Define

	 
	 //Interface
	 input Clk, Rst;
	 
	 input UARTAvl;
	 output reg [7:0] UARTSend;
	 output reg UARTDatLock;

	 input FIFOEmp;
	 input AlmostFul;
	 input [9:0] NumFIFO;
	 input [31:0] Q;
	 output reg RdReq;
	 
	 //input FIFOFul;
	 //output reg WrReq;
	 //output reg [31:0] D;
	 //output reg FIFOClr;
	 
	 output reg TestLED;
	 
	 //Internal Register
	 reg [3:0] Stat;
	 reg [31:0] tempData;
	 reg [3:0] Cnt;
	 reg Enable;
	 reg Done;
	 
	 always @ (posedge Clk or negedge Rst)
		if (!Rst) begin
			Enable <= 0;
		end
		else if (!FIFOEmp && NumFIFO > 0) begin     //FIFO not empty, send data out
			Enable <= 1;
		end
		else if (FIFOEmp && Done) begin
			Enable <= 0;
		end
	 
	 always @ (posedge Clk or negedge Rst)
		if (!Rst) begin		
			UARTSend <= 0;
			UARTDatLock <= 0;
			RdReq <= 0;
			tempData <= 0;
			Done <= 0;		
			Cnt <= 0;
			TestLED <= 1;
			
			Stat <= 0;
		end
		else if (Enable) begin     //FIFO not empty, send data out
			case (Stat)
			0: //Assert Request
				begin
					RdReq <= 1;
					Cnt <= 0;
					Done <= 0;
					Stat <= 1;
				end
			1: //Deassert Request
				begin
					RdReq <= 0;
					Stat <= 2;
				end
			2: begin
					tempData <= Q;
					Stat <= 3;
				end
			3: begin //Send out via UART
					if (Cnt == 4) begin
							Done <= 1;
							Cnt <= 0;
							Stat <= 5;
					end
					else begin
							UARTDatLock <= 0;
							UARTSend <= tempData[31:24];
							tempData <= (tempData << 8);
							Cnt <= Cnt + 4'd1;
							Stat <= 4;
					end
				end
			4: begin
					if (UARTAvl) begin
							UARTDatLock <= 1;
							Stat <= 3;
					end
					else begin
							Stat <= 4;
					end
				end
			5: begin
					TestLED <= 0;
					Stat <= 0;
					tempData <= 0;
				end
			default: Stat <= 0;
			endcase		
		end
		else if (!Enable) begin
			Done <= 0;
			Stat <= 0;
		end
		
endmodule
		
				
				
				
				
				
				
				
				