//**************************************************************//
//**************************************************************//
//Project Name: Novel ECT Hardware Design
//
//Author: Yunjie Yang
//Create  Date: 16:16 2014-11-15
//Design  Name: ECTNew
//Module  Name: UARTArbitrate
//Target Devices: EP3C25F324C8
//Tool versions: 13.1
//Descriptions: This module request onetime demodulation from two channels.
//Revision:
//**************************************************************//
//**************************************************************//

module UARTArbitrate
(
	 ApplyUART,     //Request onetime
	 	 
	 UARTWrite,UARTWreq,
	 UARTWriteMSM,UARTWreqMSM,   //Master sm module
	 UART2Write,UART2Wreq,       //0x02 and 0x03 module
	 UART4Write,UART4Wreq        //0x04 module
);
    //Parameters: command word
	 parameter Work = 2'b10;        //State which is working
	 
	 //Define

	 
	 //Interface
	 input [1:0] ApplyUART;
	 
	 input [31:0] UARTWriteMSM;
	 input UARTWreqMSM;
	 input [31:0] UART2Write;
	 input UART2Wreq; 
	 input [31:0] UART4Write;
	 input UART4Wreq; 
	 
	 //Arbitrate result
	 output reg [31:0] UARTWrite;
	 output reg UARTWreq;
	 
	 //Combinational logic
	 always @ (ApplyUART)
		case (ApplyUART)
		2'b00: begin            //Master state machine
				 UARTWreq <= UARTWreqMSM;
				 UARTWrite <= UARTWriteMSM;
				 end
		2'b01: begin            //Request one demodulation
		       UARTWreq <= UART2Wreq;
				 UARTWrite <= UART2Write;
				 end
		2'b10: begin  				//Request one frame demodulation
				 UARTWreq <= UART4Wreq;
				 UARTWrite <= UART4Write;
				 end
		default: begin
				 UARTWreq <= UARTWreqMSM;
				 UARTWrite <= UARTWriteMSM;
				 end
		endcase

		
endmodule
		
				
				
				
				
				