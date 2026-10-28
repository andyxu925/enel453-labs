module output_mux (
    input  logic        pwm_tri_enable,
    input  logic        pwm_saw_enable,
    input  logic        pwm_tri_out_internal,
    input  logic        pwm_saw_out_internal,
    output logic        triangle_en,
    output logic        pwm_out,

    input  logic        r2r_enable,
    input  logic [7:0]  R2R_out_internal,
    output logic [7:0]  R2R_out,

    input  logic        buzzer_pwm_enable,
    input  logic        buzzer_chirp_enable,
    input  logic        buzzer_pwm_out_internal,
    input  logic        buzzer_chirp_out_internal,
    output logic        buzzer_out,

    input  logic [15:0] scaled_adc_data,
    output logic [15:0] led
);
    logic pwm_out_internal;

    // Connect ADC data to LEDs, make LEDs' brightness pulse with pwm_out
    assign led = pwm_out_internal ? scaled_adc_data : '0;

    assign triangle_en = pwm_tri_enable | r2r_enable;

    always_comb begin
        if (pwm_tri_enable) begin
            pwm_out_internal = pwm_tri_out_internal;
        end else if (pwm_saw_enable) begin
            pwm_out_internal = pwm_saw_out_internal;
        end else begin
            pwm_out_internal = 0;
        end

        if (buzzer_pwm_enable) begin
            buzzer_out = buzzer_pwm_out_internal;
        end else if (buzzer_chirp_enable) begin
            buzzer_out = buzzer_chirp_out_internal;
        end else begin
            buzzer_out = 0;
        end

        // pwm_out = pwm_enable ? pwm_out_internal : 0;
        pwm_out = pwm_out_internal;
        R2R_out = r2r_enable ? R2R_out_internal : '0;
        // buzzer_out = buzzer_enable ? buzzer_out_internal : 0;
    end

endmodule