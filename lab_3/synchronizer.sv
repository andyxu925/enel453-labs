module synchronizer (
    input               clk,
    input               reset,
    input  logic [15:0] in,
    output logic [15:0] out
);

    logic [15:0] ff1;
    logic [15:0] ff2;

    always_ff @(posedge clk) begin
        if (reset) begin
            ff1 <= 0;
            ff2 <= 0;
        end else begin
            ff1 <= in;
            ff2 <= ff1;
        end
    end

    assign out = ff2;

endmodule