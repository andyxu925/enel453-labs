module display_subsystem
import disk_pkg::*;
(
    input logic clk,
    input logic reset,
    input logic signed [POSITION_WIDTH-1:0] position,
    input logic display_switch,
    output logic CA, CB, CC, CD, CE, CF, CG, DP,
    output logic AN1, AN2, AN3, AN4
);
    logic [DEGREES_WIDTH-1:0] degrees; 
    logic [$clog2(COUNTS_PER_REV)-1:0] revs;
    logic [$clog2(COUNTS_PER_REV)-1:0] display_data;
    logic        [15:0]               degrees_bcd;
    position_to_degrees POSITION_TO_DEGREES (
        .position(position),            // signed position, counts
        .degrees(degrees),              // angle within one revolution, 0 to 359
        .revs(revs),                    // raw encoder value, 0 to 2047
        .display_data(display_data),
        .display_switch(!display_switch)
    );

    bin_to_bcd BIN_TO_BCD (
        .clk(clk),                    // system clock
        .reset(reset),                // synchronous reset
        .bin_in(16'(display_data)),        // 9-bit angle, zero-extended to 16 bits
        .bcd_out(degrees_bcd)         // four BCD digits, e.g. 0359
    );

    logic [3:0] digit_blank_sig;
    assign digit_blank_sig = !display_switch ? 4'b1000 : 4'b0000; 
    seven_segment_display_subsystem SEVEN_SEGMENT_DISPLAY (
        .clk(clk),                    // system clock
        .reset(reset),                // synchronous reset
        .digit1(degrees_bcd[3:0]),    // ones of degrees (rightmost digit)
        .digit2(degrees_bcd[7:4]),    // tens of degrees
        .digit3(degrees_bcd[11:8]),   // hundreds of degrees
        .digit4(degrees_bcd[15:12]),  // thousands: always 0, blanked (leftmost)
        .decimal_point(4'b0000),      // no decimal points
        .digit_blank(digit_blank_sig),        // leftmost digit dark: shows " 090"
        .CA(CA),                      // segment outputs (active low)
        .CB(CB),
        .CC(CC),
        .CD(CD),
        .CE(CE),
        .CF(CF),
        .CG(CG),
        .DP(DP),                      // decimal point output (active low)
        .AN1(AN1),                    // anode outputs (active low)
        .AN2(AN2),
        .AN3(AN3),
        .AN4(AN4)
    );

endmodule