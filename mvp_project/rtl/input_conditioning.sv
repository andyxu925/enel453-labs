module input_conditioning
    import disk_pkg::*;
#(
    parameter int CLK_FREQ    = CLK_FREQ_HZ,        // 100 MHz
    parameter int DEBOUNCE_MS = DEBOUNCE_TIME_MS    // 50 ms
) (
    input logic clk,
    input logic reset_button,
    input logic ch_a,
    input logic ch_b,
    input logic kp_switches,
    input logic display_switch,
    input logic arm_switch,
    input logic step_up_button,
    input logic step_down_button,
    output logic reset,
    output logic encoder_a,
    output logic encoder_b,
    output logic kp,
    output logic display,
    output logic arm,
    output logic step_up,
    output logic step_down
);

    synchronizer_subsystem # (KP_WIDTH) SYNCHRONIZER(
        .clk(clk),
        .reset_button(reset_button),
        .reset(reset),
        .ch_a(ch_a),
        .encoder_a(encoder_a),
        .ch_b(ch_b),
        .encoder_b(encoder_b),
        .kp_switches(kp_switches),
        .kp(kp),
        .display_switch(display_switch),
        .display(display),
        .arm_switch(arm_switch),
        .arm(arm)
    );

    debounce_subsystem #(CLK_FREQ, DEBOUNCE_MS) DEBOUNCE(
        .clk(clk),
        .reset(reset),
        .step_up_button(step_up_button),
        .step_up(step_up),
        .step_down_button(step_down_button),
        .step_down(step_down)
    );

endmodule