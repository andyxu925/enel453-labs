module output_mode_fsm (
    input  logic        clk,
    input  logic        reset,
    input  logic [2:0]  mode_select,  // Two-bit input for mode selection
    output logic        pwm_tri_enable,
    output logic        pwm_saw_enable,
    output logic        r2r_enable,
    output logic        buzzer_enable
);
    typedef enum logic [2:0] {
        OFF_MODE = 3'b000,
        PWM_TRI_MODE = 3'b001,
        PWM_SAW_MODE = 3'b010,
        R2R_MODE = 3'b011,
        BUZZER_MODE = 3'b100
    } statetype;

    statetype current_state, next_state;

    // State register
    always_ff @(posedge clk) begin
        if (reset)
            current_state <= OFF_MODE;
        else
            current_state <= next_state;
    end

    // Next state logic
    always_comb begin
        next_state = statetype'(mode_select);  // Directly use mode_select as the next state
    end

    // Output logic
    always_comb begin
        pwm_tri_enable = 0;
        pwm_saw_enable = 0;
        r2r_enable = 0;
        buzzer_enable = 0;

        case (current_state)
            PWM_TRI_MODE:   pwm_tri_enable = 1;
            PWM_SAW_MODE:   pwm_saw_enable = 1;
            R2R_MODE:       r2r_enable = 1;
            BUZZER_MODE:    buzzer_enable = 1;
            OFF_MODE:       ; // All outputs remain 0
            default: begin
                pwm_tri_enable = 0;
                pwm_saw_enable = 0;
                r2r_enable = 0;
                buzzer_enable = 0;
            end
        endcase
    end
endmodule