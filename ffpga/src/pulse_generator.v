// Description: Pulse generator module that generates a pulse on the rising edge of the input signal.
`default_nettype none

module pulse_generator
(
    input   wire    clock,
    input   wire    level_in,
    output  reg     pulse_posedge_out
);

    initial begin
        pulse_posedge_out = 1'b0;
    end

    reg level_in_delayed = 0;

    always @(posedge clock) begin
        level_in_delayed <= level_in;
    end
    always @(posedge clock) begin
        if (level_in && !level_in_delayed) begin
            pulse_posedge_out <= 1'b1;
        end else begin
            pulse_posedge_out <= 1'b0;
        end
    end
endmodule
