// ---------------------------------------------------------------------------
// © 2024 Renesas Electronics
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
// OR OTHER DEALINGS IN THE SOFTWARE.
// ---------------------------------------------------------------------------
// Base Module Name: seven_seg_disp_ctrl_2d
// Target Device: SLG47910
// Tools version:
//   Software: ForgeFPGA Workshop v.6.34
//   Hardware: FPGAPAK Development Board Rev.1.1
// Revision:
//   05.11.2021 r001 - New design
//   03.15.2023 r002 - Code style review
//   04.01.2024 r003 - Limits added in the parameters comments
// ---------------------------------------------------------------------------
// Description :
//   The seven-segment display controller is used for displaying numbers and symbols on seven segment display. Two symbols.
// ---------------------------------------------------------------------------

`timescale 1ns / 1ps

module seven_seg_disp_ctrl_2d #(
  parameter SEL_CA = 1'b0   // 0 - common anode, 1 - common cathode (Type - Boolean, Default value = 1'b0, Min value = 1'b0, Max value = 1'b1)
) (
  input        i_clk,           // input clock signal
  input        i_rst,           // input reset signal
  input        i_load,          // load signal
  input        i_en,            // display enable signal
  input        i_refresh_clock, // clock from the external counter for dynamic indication
  input  [9:0] i_data,          // input data bus
  output [1:0] o_active_digit,  // active digit of seven-segment display. Connected to Ground/Vcc based on type of display
  output [7:0] o_segment        // seven-segment LED outputs [a, b, c, d, e, f, g, dp]
);

  localparam DIGIT_0 = (SEL_CA) ? 2'b01 : 2'b10;
  localparam DIGIT_1 = (SEL_CA) ? 2'b10 : 2'b01;

  reg [9:0] r_data;
  reg [4:0] r_digit;
  reg [6:0] r_digit_out;
  reg       r_dp;
  reg [1:0] r_active_digit;

  // selector of active digit
  always @(posedge i_clk) begin
    if (i_rst) begin
      r_active_digit    <= DIGIT_0;
    end else if (i_refresh_clock) begin
      r_active_digit    <= r_active_digit << 1;
      r_active_digit[0] <= r_active_digit[1];
    end
  end

  // buffered input data
  always @(posedge i_clk) begin
    if (i_rst) begin
      r_data <= 'h0;
    end else if (i_load) begin
      r_data <= i_data;
    end
  end

  // buffered data input
  always @(posedge i_clk) begin
    if (i_rst) begin
      r_digit <= 'h0;
    end else begin
      case (r_active_digit)
        DIGIT_0: r_digit <= {r_data[8], r_data[3:0]};
        DIGIT_1: r_digit <= {r_data[9], r_data[7:4]};
        default: r_digit <= {r_data[8], r_data[3:0]};
      endcase
    end
  end

  // decoder from input digit to segment
  always @(posedge i_clk) begin
    if (i_rst) begin
      r_digit_out <= (SEL_CA) ? 7'b0000000 : 7'b1111111;
    end else if (i_en) begin
      case (r_digit[3:0])
        4'b0000 : r_digit_out <= (SEL_CA) ? 7'b1111110 : 7'b0000001; // "0" 0x01
        4'b0001 : r_digit_out <= (SEL_CA) ? 7'b0110000 : 7'b1001111; // "1" 0x4F
        4'b0010 : r_digit_out <= (SEL_CA) ? 7'b1101101 : 7'b0010010; // "2" 0x12
        4'b0011 : r_digit_out <= (SEL_CA) ? 7'b1111001 : 7'b0000110; // "3" 0x06
        4'b0100 : r_digit_out <= (SEL_CA) ? 7'b0110011 : 7'b1001100; // "4" 0x4C
        4'b0101 : r_digit_out <= (SEL_CA) ? 7'b1011011 : 7'b0100100; // "5" 0x24
        4'b0110 : r_digit_out <= (SEL_CA) ? 7'b1011111 : 7'b0100000; // "6" 0x20
        4'b0111 : r_digit_out <= (SEL_CA) ? 7'b1110000 : 7'b0001111; // "7" 0x0F
        4'b1000 : r_digit_out <= (SEL_CA) ? 7'b1111111 : 7'b0000000; // "8" 0x00
        4'b1001 : r_digit_out <= (SEL_CA) ? 7'b1111011 : 7'b0000100; // "9" 0x04
        4'b1010 : r_digit_out <= (SEL_CA) ? 7'b1110111 : 7'b0001000; // "A" 0x08
        4'b1011 : r_digit_out <= (SEL_CA) ? 7'b0011111 : 7'b1100000; // "b" 0x60
        4'b1100 : r_digit_out <= (SEL_CA) ? 7'b1001110 : 7'b0110001; // "C" 0x31
        4'b1101 : r_digit_out <= (SEL_CA) ? 7'b0111101 : 7'b1000010; // "d" 0x42
        4'b1110 : r_digit_out <= (SEL_CA) ? 7'b1001111 : 7'b0110000; // "E" 0x30
        4'b1111 : r_digit_out <= (SEL_CA) ? 7'b1000111 : 7'b0111000; // "F" 0x38
        default : r_digit_out <= (SEL_CA) ? 7'b0000000 : 7'b1111111; // display none
      endcase
    end else begin
      r_digit_out <= (SEL_CA) ? 7'b0000000 : 7'b1111111;
    end
  end

  // prepare digit point LED
  always @(posedge i_clk) begin
    if (i_rst) begin
      r_dp <= (SEL_CA) ? 1'b0 : 1'b1;
    end else if (i_en) begin
      r_dp <= (SEL_CA) ? r_digit[4] : ~r_digit[4];
    end else begin
      r_dp <= (SEL_CA) ? 1'b0 : 1'b1;
    end
  end

  // seven-segment LED outputs [a, b, c, d, e, f, g, dp]
  assign o_segment      = {r_digit_out, r_dp};
  assign o_active_digit = r_active_digit;

endmodule
