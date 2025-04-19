// Description: This module implements a counter that counts down from a specified value (COUNT_FROM) to zero.
// It generates a signal (count_hit) when the counter reaches zero, and resets the counter back to COUNT_FROM.

module down_counter #(
    parameter COUNT_FROM = 100 // Initial value to count down from
)(
    input wire i_clk,
    input wire i_rst,
    input wire i_count_en,
    output reg count_hit
);
    // Counter to count from COUNT_TO to zero
    localparam COUNTER_WIDTH = $clog2(COUNT_FROM);

    reg [COUNTER_WIDTH:0] counter;
    
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            counter <= COUNT_FROM-1;
        end else begin
            if (i_count_en) begin
                if (counter == 0) begin
                    counter <= COUNT_FROM-1;
                    count_hit <= 1;
                end else begin
                    counter <= counter - 1;
                    count_hit <= 0;
                end
            end else begin
                count_hit <= 0;
            end
        end
    end

endmodule