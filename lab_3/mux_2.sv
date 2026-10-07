module mux_2 (
    input  logic [15:0] in_1;
    input  logic [15:0] in_2;
    input  logic        sel;
    output logic [15:0] out;
);

    always_comb begin
        case (sel)
            1'b0: begin
                out = in_1;
            end
            1'b1: begin
                out = in_2;
            end
            default: begin
                out = '0;
            end
        endcase
    end

endmodule