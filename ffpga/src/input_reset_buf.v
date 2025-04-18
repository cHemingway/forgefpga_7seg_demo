//---------------------------------------------------------------------------
//Copyright 2022 Renesas Electronics Corporation. All rights reserved.
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
//to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
//and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
//DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
//OR OTHER DEALINGS IN THE SOFTWARE.
//---------------------------------------------------------------------------
//Module Name: input_reset_buf
//Target Devices: SLG47910
//Tools version:
//  Software: ForgeFPGA Workshop v6.31
//  Hardware: FPGAPAK Development Board Rev.1.0
//Revision:
//  29.08.2022 r001 - New design
//---------------------------------------------------------------------------
//Description :
// Module for input reset bufer
//---------------------------------------------------------------------------
`timescale 1ns / 1ps

module input_reset_buf(
  input      i_clk,     //  input clock domain signal
  input      i_por,     //  input power reset signal
  output reg o_rst      //  output reset signal
);

  reg       r_por;

  always @(posedge i_clk) begin
    r_por <= i_por;
  end

  always @(posedge i_clk) begin
    o_rst <= r_por;
  end
  
endmodule
