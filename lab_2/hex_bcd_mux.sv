module hex_bcd_mux(
    input  logic [15:0] hex,
    input  logic [15:0] bcd,
    input  logic        sel,
    output logic [15:0] out 
);

    always_comb begin
        case (sel)
            1'b0: out = hex;
            1'b1: out = bcd;
            default: out = '0;
        endcase
    end

endmodule