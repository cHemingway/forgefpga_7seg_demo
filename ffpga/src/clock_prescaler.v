module clock_prescaler #(
    parameter N_STAGES = 6
)(
    input wire i_clk,
    input wire i_rst,
    output wire o_clk
);
    reg [N_STAGES:0] counter;

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
    end

    assign o_clk = counter[N_STAGES-1];

endmodule