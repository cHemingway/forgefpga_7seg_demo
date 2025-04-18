// Custom Module
`timescale 1ns / 1ps

module t(
	input clk,
	input d,
	output reg q
);

 initial begin
  q = 0;
 end

 always @(posedge clk) begin
	 q <= ~d;
 end

endmodule

module clock_prescaler #(parameter N_STAGES	= 6)
(
	input i_clk,
	output o_clk
);

/* verilator lint_off WIDTHEXPAND */
wire [N_STAGES:0] carry; 
/* verilator lint_on WIDTHEXPAND */


for (genvar i = 0; i<N_STAGES; i=i+1) begin: gen_stages
	t t_inst (
		.clk(i_clk),
		.d(carry[i]),
		.q(carry[i+1])
	);
end

assign carry[0] = i_clk; // Bit zero is input clock
// The last stage is the output clock
assign o_clk = carry[N_STAGES];

endmodule
