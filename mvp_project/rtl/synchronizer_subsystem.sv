module synchronizer_subsystem #(kp_width)(
    input  logic                  clk,
    input  logic                  reset_button,
    output logic                  reset,
    input  logic                  ch_a,
    output logic                  encoder_a,
    input  logic                  ch_b,
    output logic                  encoder_b,
    input  logic [kp_width-1:0]   kp_switches,
    output logic [kp_width-1:0]   kp,
    input  logic                  display_switch,
    output logic                  display,
    input  logic                  arm_switch,
    output logic                  arm
);

    // Reset button. The synchronizer has no reset of its own, so it can
    // synchronize the reset button itself.
    synchronizer #(
        .WIDTH(1)
    ) RESET_SYNC (
        .clk(clk),                    // system clock
        .d(reset_button),             // btnC, asynchronous
        .q(reset)                     // synchronized reset for the whole design
    );

    // Encoder channel A.
    synchronizer #(
        .WIDTH(1)
    ) ENCODER_A_SYNC (
        .clk(clk),                    // system clock
        .d(ch_a),                     // encoder channel A, from Pmod JB1
        .q(encoder_a)                 // synchronized channel A
    );

    // Encoder channel B.
    synchronizer #(
        .WIDTH(1)
    ) ENCODER_B_SYNC (
        .clk(clk),                    // system clock
        .d(ch_b),                     // encoder channel B, from Pmod JB2
        .q(encoder_b)                 // synchronized channel B
    );

    // Gain switches, all four bits in one synchronizer.
    synchronizer #(
        .WIDTH(kp_width)              // 4 switches
    ) KP_SYNC (
        .clk(clk),                    // system clock
        .d(kp_switches),              // sw[3:0]
        .q(kp)                        // synchronized gain, 0 to 15
    );

    // Display switch
    synchronizer #(
        .WIDTH(1)
    ) DISPLAY_SYNC (
        .clk(clk),
        .d(display_switch),
        .q(display)
    );

    // Arm switch.
    synchronizer #(
        .WIDTH(1)
    ) ARM_SYNC (
        .clk(clk),                    // system clock
        .d(arm_switch),               // sw[15]
        .q(arm)                       // synchronized: 1 = motor allowed to run
    );

endmodule
