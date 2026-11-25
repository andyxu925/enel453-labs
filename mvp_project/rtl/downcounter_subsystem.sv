`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2026 12:04:00 PM
// Design Name: 
// Module Name: downcounter_subsystem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module downcounter_subsystem #(CTRL_PERIOD, PWM_TICK_PERIOD) (
    input  clk,
    input  reset,
    input  enable,
    output control_tick,
    output pwm_tick
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
