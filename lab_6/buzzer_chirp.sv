module buzzer_chirp #(
    parameter int CLOCK_FREQ = 100_000_000, // in Hz
    parameter int SWEEP_DUR  = 2,           // in s
    parameter int LOW_F      = 500,         // in Hz
    parameter int HIGH_F     = 10000        // in Hz
) (
    input  logic clk,
    input  logic reset,
    input  logic enable,
    output logic pwm_out
);
    // E.g., LOW_F  = 500   Hz, MAX_COUNT_LOW_F  = 100000 clock ticks
    // E.g., HIGH_F = 10000 Hz, MAX_COUNT_HIGH_F = 5000   clock ticks
    localparam int MAX_COUNT_LOW_F  = CLOCK_FREQ / LOW_F / 2;
    localparam int MAX_COUNT_HIGH_F = CLOCK_FREQ / HIGH_F / 2;
    

    // Sweep frequency from LOW_F Hz to HIGH_F Hz
    // over an approximate SWEEP_DUR second interval
    // using increments of 1 (MAX_COUNT_LOW_F - MAX_COUNT_HIGH_F steps).
    // Total ticks over SWEEP_DUR seconds = (SWEEP_DUR) * CLOCK_FREQ.
    // Ticks per step = (Total ticks) / (MAX_COUNT_LOW_F - MAX_COUNT_HIGH_F steps).
    localparam int STEP_COUNT = (SWEEP_DUR * CLOCK_FREQ) / (MAX_COUNT_LOW_F - MAX_COUNT_HIGH_F);

    logic [31:0] pwm_ticks;
    logic [31:0] step_ticks;
    logic [31:0] max_ticks;

    always_ff @(posedge clk) begin
        if (reset || !enable) begin
            pwm_out    <= '0;
            pwm_ticks  <= '0;
            step_ticks <= '0;
            max_ticks  <= MAX_COUNT_LOW_F;
        end else if (enable) begin
            if (pwm_ticks >= max_ticks) begin
                pwm_ticks <= '0;
                pwm_out   <= ~pwm_out;
            end else begin
                pwm_ticks <= pwm_ticks + 1;
            end

            if (step_ticks >= STEP_COUNT) begin
                step_ticks <= '0;
                if (max_ticks <= MAX_COUNT_HIGH_F) begin
                    max_ticks <= MAX_COUNT_LOW_F;
                end else begin
                    max_ticks <= max_ticks - 1;
                end
            end else begin
                step_ticks <= step_ticks + 1;
            end
        end
    end

endmodule