module adc_subsystem #(
    parameter int SCALE_MULTIPLIER = 5001,
    parameter int SCALE_SHIFT      = 15
) (
    input  logic        clk,
    input  logic        reset,
    input               vauxp15,
    input               vauxn15,
    output logic [15:0] raw_adc_data,
    output logic [15:0] averaged_adc_data,
    output logic [15:0] scaled_adc_data
);

    localparam logic [6:0] CHANNEL_ADDRESS = 7'h1F; 

    logic        xadc_enable;
    logic        xadc_data_ready;
    logic [31:0] scaled_product;

    // The XADC IP must be generated in Vivado as xadc_wiz_0 using the settings
    // in the Lab 5 instructions.
    xadc_wiz_0 XADC_INST (
        .di_in(16'h0000),
        .daddr_in(CHANNEL_ADDRESS),
        .den_in(xadc_enable),
        .dwe_in(1'b0),
        .drdy_out(xadc_data_ready),
        .do_out(raw_adc_data),
        .dclk_in(clk),
        .reset_in(reset),
        .vp_in(1'b0),
        .vn_in(1'b0),
        .vauxp15(vauxp15),
        .vauxn15(vauxn15),
        .channel_out(),
        .eoc_out(xadc_enable),
        .alarm_out(),
        .eos_out(),
        .busy_out()
    );

    averager #(
        .N(14),                 // 2**12 = 4096 samples
        .DATA_WIDTH(16)
    ) AVERAGER (
        .clk(clk),
        .reset(reset),
        .EN(xadc_data_ready),
        .Din(raw_adc_data),
        .Q(averaged_adc_data)
    );

    // Two-stage scaling pipeline. The XADC full-scale representation is FFF0,
    // and (FFF0 * 5001) >> 15 = 9999 after truncation.
    always_ff @(posedge clk) begin
        if (reset) begin
            scaled_product  <= '0;
            scaled_adc_data <= '0;
        end
        else if (xadc_data_ready) begin
            scaled_product  <= averaged_adc_data * SCALE_MULTIPLIER;
            scaled_adc_data <= scaled_product >> SCALE_SHIFT;
        end
    end

endmodule