module display_switch
    import disk_pkg::*;
(
    input  logic signed [POSITION_WIDTH-1:0] position,
    input  logic        [DEGREES_WIDTH-1:0]  degrees,
    input  logic                             display_switch,
    output logic        [DEGREES_WIDTH-1:0]  display_data
)

    localparam int REV_BITS     = $clog2(COUNTS_PER_REV);    // 11 bits count 0..2047
    localparam int SCALED_WIDTH = REV_BITS + DEGREES_WIDTH;  // 11 + 9 = 20 bits

    logic [REV_BITS-1:0]     count_in_rev;

    assign count_in_rev = position[REV_BITS-1:0];                       // modulo 2048
    assign display_data = display_switch ? count_in_rev : degrees;

endmodule
