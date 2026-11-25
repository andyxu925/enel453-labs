`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2026 11:49:53 AM
// Design Name: 
// Module Name: debounce_subsystem
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


module debounce_subsystem #(CLK_FREQ, DEBOUNCE_MS)(
    input  logic clk,
    input  logic reset,
    input  logic step_up_button,
    output logic step_up,
    input  logic step_down_button,
    output logic step_down
    );
        // Step-up button (btnR).
    debounce #(
        .CLK_FREQ(CLK_FREQ),          // system clock frequency, Hz
        .STABLE_TIME_MS(DEBOUNCE_MS)  // button must be steady this long
    ) STEP_UP_DEBOUNCE (
        .clk(clk),                    // system clock
        .reset(reset),                // synchronous reset
        .button(step_up_button),      // raw btnR
        .result(step_up)              // debounced: 1 while held
    );

    // Step-down button (btnL).
    debounce #(
        .CLK_FREQ(CLK_FREQ),          // system clock frequency, Hz
        .STABLE_TIME_MS(DEBOUNCE_MS)  // button must be steady this long
    ) STEP_DOWN_DEBOUNCE (
        .clk(clk),                    // system clock
        .reset(reset),                // synchronous reset
        .button(step_down_button),    // raw btnL
        .result(step_down)            // debounced: 1 while held
    );
endmodule
