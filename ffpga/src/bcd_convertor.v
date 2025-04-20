// Description: BCD convertor that takes in a 7-bit binary number (0-99) and converts it to BCD format.
// Does not handle negative numbers or numbers greater than 99
// Takes size(i_data)+1 cycles to convert the number, so the output is valid when o_bcd_valid is high.
module bcd_convertor (
    input wire          i_clk,
    input wire          i_rst,         // Syncronous reset
    input wire [7:0]    i_data,        // 0-99
    input wire          i_load,        // pulse to load new data
    output wire [7:0]   o_bcd_data,    // 2 BCD digits, packed
    output reg          o_bcd_valid   // high when valid data
);
    // Algorithm is based on the "Double Dabble" method
    // https://en.wikipedia.org/wiki/Double_dabble
    reg [15:0] scratch;

    reg [3:0] shift_count; // Counter for how many shifts left
    localparam SHIFTS = 8;

    always @(posedge i_clk) begin
        if (i_rst) begin
            scratch <= 0;
            o_bcd_valid <= 0;
        end else if (i_load) begin
            scratch <= {8'b0, i_data}; // Load the input data into the scratch register
            o_bcd_valid <= 0;
            shift_count <= SHIFTS;
        end else begin
            if (shift_count == 0) begin
                o_bcd_valid <= 1;   // Could we shortcut and set this when shift_count is one?
            end else begin
                o_bcd_valid <= 0;
                shift_count <= shift_count - 1;
                if ((scratch & 'hF000) > 'h4000) begin // BCD Ones
                    scratch <= (scratch + 'h3000) << 1;
                end else if ((scratch & 'h0F00) > 'h0400) begin // BCD Tens
                    scratch <= (scratch + 'h0300) << 1;
                end else begin
                    scratch <= scratch << 1;
                end
            end
        end
    end

    assign o_bcd_data = scratch[15:8]; // BCD data is in the upper 8 bits of the scratch register
    

endmodule