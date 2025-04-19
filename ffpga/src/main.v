`timescale 1ns / 1ps


(* top *) module main (
  (* iopad_external_pin, clkbuf_inhibit *) 	input i_clk_50mhz, // input clock signal from on chip osc
  (* iopad_external_pin *) 					input i_por,	// Wired to FPGA_DONE signal
  // Oscillator
  (* iopad_external_pin *) output o_osc_en,	// Enables internal oscillator
  // IO
  (* iopad_external_pin *) output pmod_cat,  // active digit of seven-segment display. 1=digit 1, 0= digit 2
  (* iopad_external_pin *) output [6:0] pmod_segment,		 // Segment + decimal point
  (* iopad_external_pin *) output pmod_oe		// Output enable, shared for all PMOD output pins
);

`ifdef VERILATOR
`define SIMULATION
`endif
`ifdef __ICARUS__
`define SIMULATION
`endif


// Turn on external oscillator. Has to be done by FPGA logic
assign o_osc_en = 1'b1;

// Enable outputs
assign pmod_oe = 1'b1;

`ifdef SIMULATION
localparam TICK_INCREMENT = 10; // Speed up tests under sim
`else
localparam TICK_INCREMENT = 781250;
`endif

wire [1:0] active_digit_onehot;
wire [7:0] o_segment;

reg [20:0] clock_counter = TICK_INCREMENT;
reg [9:0] r_data = 0;
reg load = 0;

// reset buffer
  wire w_rst;
  input_reset_buf impl_input_reset_buf (
    .i_clk        (i_clk_50mhz),
    .i_por        (i_por),
    .o_rst        (w_rst)
  );

// 50MHz / 2^6 = 781.25KHz, lowest we can go that isn't fractional hz
wire clk_781khz;
wire clk_781khz_pulse;
clock_prescaler #(6) counter_clk_gen (i_clk_50mhz, w_rst, clk_781khz);

pulse_generator pulse_gen (
	.clock(i_clk_50mhz),
	.level_in(clk_781khz),
	.pulse_posedge_out(clk_781khz_pulse)
);

wire clk_display_refresh;

`ifdef SIMULATION 
// Speed up tests under sim
clock_prescaler #(5) display_clk_gen (i_clk_50mhz, w_rst, clk_display_refresh);
`else
clock_prescaler #(16) display_clk_gen (i_clk_50mhz, w_rst, clk_display_refresh);
`endif

wire display_refresh_pulse;

pulse_generator display_pulse_gen (
	.clock(i_clk_50mhz),
	.level_in(clk_display_refresh),
	.pulse_posedge_out(display_refresh_pulse)
);


// 7 seg display, common cathode
// i_refresh_clock needs to be a pulse, not a clock
seven_seg_disp_ctrl_2d #(.SEL_CA(1)) seven_seg_ctrl(.i_clk(i_clk_50mhz), 
									  .i_rst(w_rst),
									  .i_load(load), 
									  .i_en(1'b1), 
									  .i_refresh_clock(display_refresh_pulse), 
									  .i_data(r_data), 
									  .o_active_digit(active_digit_onehot), 
									  .o_segment(o_segment));


// 1Hz clock for the digit counter
wire onehertz_pulse;
down_counter #(.COUNT_FROM(TICK_INCREMENT)) onehertz_counter (
	.i_clk(i_clk_50mhz),
	.i_rst(w_rst),
	.i_count_en(clk_781khz_pulse),
	.count_hit(onehertz_pulse)
);

									  
// Digit counter, running off 50MHz clock
// FIXME: seven_seg_disp_ctrl_2d takes in BCD not Binary!
always @(posedge i_clk_50mhz) begin
	if (w_rst) begin
		r_data <= 0;
		load <= 0;
	end else begin
		if (onehertz_pulse) begin
			if (r_data == 99) begin
				r_data <= 0;
				load <= 1;
			end else begin
				r_data <= r_data + 1;
				load <= 1;
			end
		end else begin
			r_data <= r_data;
			load <= 0;
		end
	end
end

// Combinatorial logic for active digit, see PmodSSD schematic
assign pmod_cat = active_digit_onehot[1];

// Drop the decimal place (bit 0)
assign pmod_segment = o_segment[7:1];


endmodule