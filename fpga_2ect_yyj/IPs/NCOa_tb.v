//	Copyright (C) 1988-2013 Altera Corporation

//	Any megafunction design, and related net list (encrypted or decrypted),
//	support information, device programming or simulation file, and any other
//	associated documentation or information provided by Altera or a partner
//	under Altera's Megafunction Partnership Program may be used only to
//	program PLD devices (but not masked PLD devices) from Altera.  Any other
//	use of such megafunction design, net list, support information, device
//	programming or simulation file, or any other related documentation or
//	information is prohibited for any other purpose, including, but not
//	limited to modification, reverse engineering, de-compiling, or use with
//	any other silicon devices, unless such use is explicitly licensed under
//	a separate agreement with Altera or a megafunction partner.  Title to
//	the intellectual property, including patents, copyrights, trademarks,
//	trade secrets, or maskworks, embodied in any such megafunction design,
//	net list, support information, device programming or simulation file, or
//	any other related documentation or information provided by Altera or a
//	megafunction partner, remains with Altera, the megafunction partner, or
//	their respective licensors.  No other licenses, including any licenses
//	needed under any third party's intellectual property, are provided herein.

//   NCO ver 13.1 VERILOG HDL TESTBENCH
`timescale 1ps / 1ps
module NCOa_tb;

wire out_valid;
wire [13:0] sin_val;
wire [13:0] cos_val;
reg [31:0] phi;
reg [31:0] fmod;
reg [15:0] pmod;
reg reset_n;
reg clken;
reg clk;

parameter CYCLE = 100000;
parameter HALF_CYCLE = 50000;
initial
  begin
    $dumpvars;
    #0 clk = 1'b0;
    #0 reset_n = 1'b0;
    #0 clken = 1'b1;
    #0 phi = 32'b00000101000111101011100001010010;
    #0 fmod = 32'b00010000000000000000000000000000;
    #0 pmod = 4096;
    #(14*HALF_CYCLE) reset_n = 1'b1;
  end

always
  begin
    #HALF_CYCLE clk = 1;
    #HALF_CYCLE clk = 0;
  end

integer sin_ch, sin_print;
integer cos_ch, cos_print;
initial
  begin
    sin_ch = $fopen ("fsin_o_ver_NCOa.txt");
    cos_ch = $fopen ("fcos_o_ver_NCOa.txt");
  end

always @(posedge clk)
  begin
    if(reset_n==1'b1 & out_valid==1'b1)
      begin
        if (sin_val[13:0] < (1<<13))
          sin_print = sin_val[13:0];
        else
          sin_print =  sin_val[13:0] - (1<<14);

      if (cos_val[13:0] < (1<<13))
        cos_print = cos_val[13:0];
      else
        cos_print =  cos_val[13:0] - (1<<14);

    $fdisplay (sin_ch, "%0d", sin_print);
    $fdisplay (cos_ch, "%0d", cos_print);
      end
end

NCOa i_NCOa (
    .out_valid(out_valid),
    .fsin_o(sin_val[13:0]),
    .fcos_o(cos_val[13:0]),
    .phi_inc_i(phi[31:0]),
    .freq_mod_i(fmod),
    .phase_mod_i(pmod),
    .reset_n(reset_n),
    .clken(clken),
    .clk(clk)
    );

endmodule
