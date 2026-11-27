module display_subsystem
    import disk_pkg::*;
(
    input  logic                             clk,
    input  logic                             reset,
    input  logic signed [POSITION_WIDTH-1:0] position,
    input  logic                             display_switch,
    output logic                             CA,
    output logic                             CB,
    output logic                             CC,
    output logic                             CD,
    output logic                             CE,
    output logic                             CF,
    output logic                             CG,
    output logic                             DP,
    output logic                             AN1,
    output logic                             AN2,
    output logic                             AN3,
    output logic                             AN4
);

    localparam int REV_BITS = $clog2(COUNTS_PER_REV);

    logic [DEGREES_WIDTH-1:0] degrees;
    logic [REV_BITS-1:0]      display_data;
    logic [15:0]              display_bcd;
    logic [3:0]               digit_blank;

    position_to_degrees POSITION_TO_DEGREES (
        .position       (position),
        .degrees        (degrees)
    );

    display_switch DISPLAY_SWITCH (
        .position       (position),
        .degrees        (degrees),
        .display_switch (display_switch),
        .display_data   (display_data),
        .digit_blank    (digit_blank)
    );

    bin_to_bcd BIN_TO_BCD (
        .clk      (clk),
        .reset    (reset),
        .bin_in   (16'(display_data)),
        .bcd_out  (display_bcd)
    );

    seven_segment_display_subsystem SEVEN_SEGMENT_DISPLAY (
        .clk            (clk),
        .reset          (reset),
        .digit1         (display_bcd[3:0]),
        .digit2         (display_bcd[7:4]),
        .digit3         (display_bcd[11:8]),
        .digit4         (display_bcd[15:12]),
        .decimal_point  (4'b0000),
        .digit_blank    (digit_blank),
        .CA             (CA),
        .CB             (CB),
        .CC             (CC),
        .CD             (CD),
        .CE             (CE),
        .CF             (CF),
        .CG             (CG),
        .DP             (DP),
        .AN1            (AN1),
        .AN2            (AN2),
        .AN3            (AN3),
        .AN4            (AN4)
    );

endmodule
