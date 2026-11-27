module control_loop_subsystem
    import disk_pkg::*;
(
    input  logic                                clk,
    input  logic                                reset,
    input  logic                                encoder_a,
    input  logic                                encoder_b,
    input  logic                                step_up,
    input  logic                                step_down,
    input  logic                                control_tick,
    input  logic        [KP_WIDTH-1:0]          kp,
    input  logic                                arm,
    input  logic                                pwm_tick,
    output logic                                motor_en,
    output logic                                motor_in1,
    output logic                                motor_in2,
    output logic signed [POSITION_WIDTH-1:0]    position_output
);

    logic signed [POSITION_WIDTH-1:0] position;
    logic signed [POSITION_WIDTH-1:0] setpoint;
    logic signed [COMMAND_WIDTH-1:0]  command;

    // Measure: encoder channels -> position in counts.
    quad_decoder QUAD_DECODER (
        .clk(clk),                    // system clock
        .reset(reset),                // synchronous reset: position = 0
        .a(encoder_a),                // synchronized channel A
        .b(encoder_b),                // synchronized channel B
        .position(position)           // signed position, counts
    );
    assign position_output = position;

    // Setpoint: +/-90 degrees per button press.
    setpoint_control SETPOINT_CONTROL (
        .clk(clk),                    // system clock
        .reset(reset),                // synchronous reset: setpoint = 0
        .step_up(step_up),            // debounced btnR
        .step_down(step_down),        // debounced btnL
        .setpoint(setpoint)           // desired position, counts
    );

    // Compare: command = Kp x (setpoint - position), limited to +/-255.
    // p_controller knows nothing about the disk (it is written to be reused
    // unchanged, for example inside a PI controller), so the disk's sizes and
    // limits are given to it here, as parameters.
    p_controller #(
        .IN_WIDTH(POSITION_WIDTH),    // setpoint and position: 16 bits
        .KP_WIDTH(KP_WIDTH),          // kp: 4 bits, 0 to 15
        .FRAC_BITS(0),                // Kp is a whole number
        .OUT_WIDTH(COMMAND_WIDTH),    // command: 9 bits
        .OUT_MAX(COMMAND_MAX),        // +255: full power forward
        .OUT_MIN(-COMMAND_MAX)        // -255: full power reverse
    ) P_CONTROLLER (
        .clk(clk),                    // system clock
        .reset(reset),                // synchronous reset: command = 0
        .sample_tick(control_tick),   // update 100 times per second
        .reference(setpoint),         // desired position, counts
        .measured(position),          // measured position, counts
        .kp(kp),                      // gain from sw[3:0]
        .error(),                     // setpoint - position: not needed here
        .p_action(command)            // -255 (full reverse) to +255 (full forward)
    );

    // Drive: command -> L298N direction and PWM signals.
    motor_drive MOTOR_DRIVE (
        .clk(clk),                    // system clock
        .reset(reset),                // synchronous reset: motor off
        .arm(arm),                    // sw[15]: 0 forces the motor off
        .pwm_tick(pwm_tick),          // sets the PWM frequency
        .command(command),            // signed motor command
        .motor_en(motor_en),          // to L298N ENB (PWM)
        .motor_in1(motor_in1),        // to L298N IN3 (forward)
        .motor_in2(motor_in2)         // to L298N IN4 (reverse)
    );

endmodule
