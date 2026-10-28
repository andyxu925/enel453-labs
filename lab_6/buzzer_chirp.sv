module buzzer_chirp #(
    parameter int CLOCK_FREQ  = 100_000_000
) (
    input  logic clk,
    input  logic reset,
    input  logic enable,
    output logic pwm_out
);
    // Sweep frequency from 500 Hz to 10000 Hz
    // over an approximate 2 second interval
    // using increments of 1 (9500 steps).
    // (2 s) * CLOCK_FREQ = total ticks over 2 seconds.
    // (Total ticks) / (9500 steps) = ticks per step.
    localparam int STEP_COUNT = (2 * CLOCK_FREQ) / 9500;

    // MAX_COUNT_500 = 100000 clock ticks
    localparam int MAX_COUNT_500 = CLOCK_FREQ / 500 / 2;

    // MAX_COUNT_10000 = 5000 clock ticks
    localparam int MAX_COUNT_10000 = CLOCK_FREQ / 10000 / 2;

    logic [31:0] pwm_ticks;
    logic [31:0] step_ticks;
    logic [31:0] max_ticks;

    always_ff @(posedge clk) begin
        if (reset || !enable) begin
            pwm_out    <= '0;
            pwm_ticks  <= '0;
            step_ticks <= '0;
            max_ticks  <= MAX_COUNT_500;
        end else if (enable) begin
            if (pwm_ticks == max_ticks) begin
                pwm_ticks <= '0;
                pwm_out   <= ~pwm_out;
            end else begin
                pwm_ticks <= pwm_ticks + 1;
            end

            if (step_ticks == STEP_COUNT) begin
                step_ticks <= '0;
                if (max_ticks == MAX_COUNT_10000) begin
                    max_ticks <= MAX_COUNT_500;
                end else begin
                    max_ticks <= max_ticks - 1;
                end
            end else begin
                step_ticks <= step_ticks + 1;
            end
        end
    end

endmodule