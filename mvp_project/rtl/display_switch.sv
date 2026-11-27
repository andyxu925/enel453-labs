`timescale 1ns / 1ps
//==============================================================================
// Module: display_switch
//
// Purpose
//   Selects between raw encoder counts within one revolution (0 to 2047) and
//   pre-computed angle in degrees (0 to 359) for the display output based on
//   display_switch, and sets digit blanking for the 4-digit display.
//
// Equations (COUNTS_PER_REV = 2048)
//
//   1. Position within one revolution, 0 to 2047:
//        count_in_rev = position modulo 2048 = the low 11 bits of position
//      Taking the low bits also works for negative positions, because of
//      two's complement:
//        position = -512 = 1111_1110_0000_0000 -> low 11 bits = 1536
//        and 1536 counts is 270 degrees, which is the same as -90 degrees.
//
//   2. Display data selection:
//        display_data = display_switch ? count_in_rev : degrees
//      When display_switch is 1, count_in_rev (11 bits) passes directly to
//      display_data. When display_switch is 0, degrees (9 bits) is
//      zero-extended to 11 bits ($clog2(COUNTS_PER_REV)).
//
//   3. Digit blanking:
//        digit_blank = display_switch ? 4'b0000 : 4'b1000
//      Blanks the leftmost digit (4'b1000) in degree mode (0 to 359 fits in
//      3 digits) and enables all 4 digits (4'b0000) in count mode (0 to 2047
//      needs up to 4 decimal digits).
//
//   Examples:
//     position  display_switch  count_in_rev  degrees  display_data  digit_blank
//     --------  --------------  ------------  -------  ------------  -----------
//          0           0               0          0           0         4'b1000
//        512           0             512         90          90         4'b1000
//        512           1             512         90         512         4'b0000
//       -512           0            1536        270         270         4'b1000
//       -512           1            1536        270        1536         4'b0000
//
// Data types
//   count_in_rev    : unsigned 11 bits, 0 to 2047
//   display_data    : unsigned 11 bits, 0 to 2047 (width $clog2(COUNTS_PER_REV))
//   digit_blank     : 4-bit active-high blanking mask
//
// Constants (from disk_pkg)
//   COUNTS_PER_REV  : encoder counts per revolution, 2048. MUST be a power of two.
//   POSITION_WIDTH  : width of position (16 bits, signed)
//   DEGREES_WIDTH   : width of degrees (9 bits)
//
// Inputs
//   position       : signed disk position, in encoder counts
//   degrees        : angle within one revolution, 0 to 359 degrees
//   display_switch : selects count_in_rev + 4'b0000 (1) or degrees + 4'b1000 (0)
//
// Outputs
//   display_data   : selected display value, width $clog2(COUNTS_PER_REV)
//   digit_blank    : 4-bit digit blanking control vector
//
// Internal signals
//   count_in_rev    : unsigned position modulo one revolution, width REV_BITS
//==============================================================================

module display_switch
    import disk_pkg::*;
(
    input  logic signed [POSITION_WIDTH-1:0]            position,
    input  logic        [DEGREES_WIDTH-1:0]             degrees,
    input  logic                                        display_switch,
    output logic        [$clog2(COUNTS_PER_REV)-1:0]    display_data,
    output logic        [3:0]                           digit_blank
);

    localparam int REV_BITS     = $clog2(COUNTS_PER_REV);    // 11 bits count 0..2047

    logic [REV_BITS-1:0]     count_in_rev;

    assign count_in_rev = position[REV_BITS-1:0];                  // modulo 2048
    assign display_data = display_switch ? count_in_rev : degrees;
    assign digit_blank  = display_switch ? 4'b0000 : 4'b1000;

endmodule
