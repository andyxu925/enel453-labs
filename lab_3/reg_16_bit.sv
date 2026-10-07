module reg_16_bit (
    input  logic        clk,
    input  logic        reset,
    input  logic        ena,
    input  logic [15:0] in,
    output logic [15:0] out
)

    logic [15:0] q;

    always_ff @(posedge clk) begin
        if (reset) begin
            q <= '0;
        end else if (ena) begin
            q <= in;
        end
    end

    assign out = q;

endmodule