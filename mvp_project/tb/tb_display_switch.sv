`timescale 1ns / 1ps
//==============================================================================
// Testbench: tb_display_switch
//
// Tries every 16-bit position, -32,768 to +32,767, and compares the result
// with degrees = (position modulo 2048) x 360 / 2048, rounded down.
// Prints PASS or FAIL.
//==============================================================================

module tb_display_switch;

    import disk_pkg::*;    // COUNTS_PER_REV, POSITION_WIDTH, DEGREES_WIDTH

    logic signed [POSITION_WIDTH-1:0]           position = '0;
    logic        [DEGREES_WIDTH-1:0]            degrees;
    logic                                       display_switch = 0;
    logic        [$clog2(COUNTS_PER_REV)-1:0]   display_data;
    logic        [3:0]                          digit_blank;
    int                                         errors   = 0;
    int                                         expected_degrees;
    int                                         expected_counts;

    position_to_degrees PTD (
        .position(position),
        .degrees(degrees)
    );

    display_switch DUT (
        .position(position),
        .degrees(degrees),
        .display_switch(display_switch),
        .display_data(display_data),
        .digit_blank(digit_blank)
    );

    initial begin
        for (int p = -32768; p <= 32767; p++) begin
            position = POSITION_WIDTH'(p);
            display_switch = 0;
            #1;
            // Modulo that is always positive, even for negative positions.
            expected_degrees = ((p % COUNTS_PER_REV + COUNTS_PER_REV) % COUNTS_PER_REV)
                       * 360 / COUNTS_PER_REV;
            if (display_data !== DEGREES_WIDTH'(expected_degrees)) begin
                errors++;
                if (errors <= 10)
                    $display("FAIL position %0d: degrees = %0d, expected %0d",
                             p, display_data, expected_degrees);
            end
            if (digit_blank !== 4'b1000) begin
                errors++;
                if (errors <= 10)
                    $display("FAIL digit is not blanked for degrees");
            end
        end

        for (int p = -32768; p <= 32767; p++) begin
            position = POSITION_WIDTH'(p);
            display_switch = 1;
            #1;
            // Modulo that is always positive, even for negative positions.
            expected_counts = p[$clog2(COUNTS_PER_REV)-1:0];
            if (display_data !== $clog2(COUNTS_PER_REV)'(expected_counts)) begin
                errors++;
                if (errors <= 10)
                    $display("FAIL position %0d: counts = %0d, expected %0d",
                             p, display_data, expected_counts);
            end
            if (digit_blank !== 4'b0000) begin
                errors++;
                if (errors <= 10)
                    $display("FAIL digit is blanked for counts");
            end
        end

        if (errors == 0) $display("PASS tb_display_switch");
        else             $display("FAIL tb_display_switch: %0d errors", errors);
        $finish;
    end

endmodule
