module sawtooth_generator #(
    parameter int   WIDTH       = 8,
    parameter int   CLOCK_FREQ  = 100_000_000,
    parameter real  WAVE_FREQ   = 1.0
) (
    input   logic               clk,
    input   logic               reset,
    input   logic               enable,
    output  logic               pwm_out
);

    localparam int MAX_DUTY_CYCLE       = (2 ** WIDTH) - 1;
    localparam int TOTAL_STEPS          = MAX_DUTY_CYCLE + 1;
    localparam int DOWNCOUNTER_PERIOD   = integer'(CLOCK_FREQ / (WAVE_FREQ * TOTAL_STEPS));

    initial begin
        if (DOWNCOUNTER_PERIOD <= 0) begin
            $error("DOWNCOUNTER_PERIOD must be positive. Adjust CLOCK_FREQ or WAVE_FREQ.");
        end
    end

    logic               zero;
    logic [WIDTH-1:0]   duty_cycle;

    downcounter #(
        .PERIOD(DOWNCOUNTER_PERIOD)
    ) downcounter_inst (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .zero(zero)
    );

    always_ff @(posedge clk) begin
        if (reset || !enable) begin
            duty_cycle <= 0;
        end else if (enable) begin
            if (zero) begin
                if (duty_cycle == MAX_DUTY_CYCLE) begin
                    duty_cycle <= 0;
                end else begin
                    duty_cycle <= duty_cycle + 1;
                end
            end
        end
    end

    pwm #(
        .WIDTH(WIDTH)
    ) pwm_inst (
        .clk(       clk),
        .reset(     reset),
        .enable(    enable),
        .duty_cycle(duty_cycle),
        .pwm_out(   pwm_out)
    );

endmodule