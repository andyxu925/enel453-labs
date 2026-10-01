module hex_bcd_mux(
    input  logic [15:0] hex,
    input  logic [15:0] bcd,
    input  logic        sel,
    output logic [15:0] out,
    output logic        overflow
);

    always_comb begin
        case (sel)
            1'b0: begin
                out      = hex;
                overflow = 1'b0;
            end
            1'b1: begin
                out = bcd;
                if (bcd >= 16'hEEEE) overflow = 1'b1;
                else                 overflow = 1'b0;
            end
            default: begin
                out = '0;
                overflow = 1'b0;
            end
        endcase
    end

endmodule