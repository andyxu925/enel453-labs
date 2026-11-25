module downcounter_subsystem
    import disk_pkg::*;
#(
    parameter int CTRL_PERIOD = CLK_FREQ_HZ / CONTROL_FREQ_HZ,
    parameter int PWM_TICK_PERIOD = CLK_FREQ_HZ / (PWM_FREQ_HZ * COMMAND_MAX)
) (
    input  logic clk,
    input  logic reset,
    output logic control_tick,
    output logic pwm_tick
);
    // 100 Hz pulse: tells the controller when to take a sample.
    downcounter #(
        .PERIOD(CTRL_PERIOD)          // 1,000,000 cycles = 10 ms
    ) CONTROL_TICK_GEN (
        .clk(clk),                    // system clock
        .reset(reset),                // synchronous reset
        .enable(1'b1),                // always counting
        .zero(control_tick)           // one-cycle pulse every 10 ms
    );

    // 2.56 MHz pulse: steps the PWM counter (255 steps = one 10 kHz period).
    downcounter #(
        .PERIOD(PWM_TICK_PERIOD)      // 39 cycles = 390 ns
    ) PWM_TICK_GEN (
        .clk(clk),                    // system clock
        .reset(reset),                // synchronous reset
        .enable(1'b1),                // always counting
        .zero(pwm_tick)               // one-cycle pulse every 39 cycles
    );

endmodule
