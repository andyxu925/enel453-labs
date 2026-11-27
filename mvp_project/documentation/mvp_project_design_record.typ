#align(center)[#text(
  weight: "bold")[
    ENEL453 \ MVP Design Lab Project --- Spinning Disk Position Control
  ]
]

#align(center)[#text[
  B02 --- Group 24 \ Nick Mulligan, Jake Tanyi, Andy Xu
  ]
]

#outline()

=== Step 4
```sv
// Count one step for each legal move around the ring.
always_ff @(posedge clk) begin
    if (reset) begin
        position <= '0;
    end else begin
        case ({ab_previous, ab})
            //--------------------------------------------------------------
            // TODO: add the eight legal moves around the ring.
            //
            //   - The four FORWARD moves, 00 -> 10 -> 11 -> 01 -> 00,
            //     add 1 to position.
            //   - The four BACKWARD moves (the same ring, the other way
            //     round) subtract 1 from position.
            //
            //   Each case item is the 4-bit pair {ab_previous, ab}: for
            //   example, a jump from 00 to 11 would be written 4'b00_11
            //   (that one is illegal: it belongs in no list). Case items that do
            //   the same thing can share one line, separated by commas:
            //
            //       4'bxx_xx, 4'bxx_xx, ... : position <= position + 1'b1;
            //
            //   Check your work with the testbench tb_quad_decoder, then on
            //   the board: turning the disk by hand should change the angle
            //   on the display, up one way and down the other.
            //--------------------------------------------------------------

            // no change, or both channels changed at once: keep the count
            4'b00_10: position <= position + 1'b1;
            4'b10_11: position <= position + 1'b1;
            4'b11_01: position <= position + 1'b1;
            4'b01_00: position <= position + 1'b1;
            4'b00_01: position <= position - 1'b1;
            4'b01_11: position <= position - 1'b1;
            4'b11_10: position <= position - 1'b1;
            4'b10_00: position <= position - 1'b1;
            default:  position <= position;
        endcase
    end
end
```

#image("4_1.png")

// TODO: annotate according to lab document
#image("4_2.png")
At the start of the plot reset is high and sets position to 0000. Once reset drops low, a leads b as the quadrature sequence steps forward, counting up by 1 per edge from 0000 to 000a around 320 ns. Around 320 ns the direction reverses and counts back down through 0001 to 0000, then into negative two's complement values (ffff = -1, fffe = -2, fffd = -3, fffc = -4).

Caption: tb_quad_decoder waveform showing reset clearing position to 0000, a and b counting up to 000a (10), and then reversing down through 0000 into ffff, fffe, fffd, and fffc.
=== Step 5
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
```
display_switch Testbench Pass:
#image("pre-mod/ds.png")
Counts Check:
```
    task automatic check_settled(int target, string what);
        int position, degrees, count_in_rev, shown;
        position     = DUT.position;
        degrees      = ((position % COUNTS_PER_REV + COUNTS_PER_REV) % COUNTS_PER_REV)
                     * 360 / COUNTS_PER_REV;
        count_in_rev = position[REV_BITS-1:0];
        shown        = DUT.DISPLAY_SUBSYSTEM.display_bcd[15:12] * 1000
                     + DUT.DISPLAY_SUBSYSTEM.display_bcd[11:8]  * 100
                     + DUT.DISPLAY_SUBSYSTEM.display_bcd[7:4]   * 10
                     + DUT.DISPLAY_SUBSYSTEM.display_bcd[3:0];
        if (DUT.CONTROL_LOOP_SUBSYSTEM.setpoint !== POSITION_WIDTH'(target)) begin
            errors++;
            $display("FAIL %s: setpoint = %0d, expected %0d", what, DUT.CONTROL_LOOP_SUBSYSTEM.setpoint, target);
        end
        if (position < target - TOLERANCE || position > target + TOLERANCE) begin
            errors++;
            $display("FAIL %s: position = %0d, expected %0d +/- %0d",
                     what, position, target, TOLERANCE);
        end
        if (display_switch == 0) begin
            if (shown != degrees) begin
                errors++;
                $display("FAIL %s: display shows %0d, expected %0d degrees", what, shown, degrees);
            end
        end else begin
            if (shown != count_in_rev) begin
                errors++;
                $display("FAIL %s: display shows %0d, expected %0d counts", what, shown, count_in_rev);
            end
        end
        // $display("%-16s setpoint %5d  position %5d  display %04h deg",
        //         what, target, position, DUT.DISPLAY_SUBSYSTEM.display_bcd);
         $display("%-16s setpoint %5d  position %5d  display %0d %s",
                 what, target, position, shown, display_switch ? "counts" : "deg");
    endtask
```
=== Step 6
All 7 testbenches were simulated and passed. Below are the images for each pass.
#image("6_1.png")
#image("6_2.png")
#image("6_3.png")
#image("6_4.png")
#image("6_5.png")
#image("6_6.png")
#image("6_7.png")
=== Step 7
Pre-Modularized:
#image("pre-mod/btb.png")
#image("pre-mod/db.png")
#image("pre-mod/ds.png")
#image("pre-mod/dt.png")
#image("pre-mod/md.png")
#image("pre-mod/pc.png")
#image("pre-mod/ptd.png")
#image("pre-mod/qd.png")
#image("pre-mod/rtl.png")
Post-Modularized:
#image("post-mod/btb.png")
#image("post-mod/db.png")
#image("post-mod/ds.png")
#image("post-mod/dt.png")
#image("post-mod/md.png")
#image("post-mod/pc.png")
#image("post-mod/ptd.png")
#image("post-mod/qd.png")
#image("post-mod/rtl.png")
=== Step 9
// Attaches the video inside the PDF file itself
#pdf.attach("q9.mp4", description: "Demo Video")

// Visual placeholder in the document text
#figure(
  image("q9.png", width: 70%),
  caption: [Open the PDF Attachments panel to play `q9.mp4`],
)
=== Step 11
// Attaches the video inside the PDF file itself
#pdf.attach("q11.mp4", description: "Demo Video")

// Visual placeholder in the document text
#figure(
  image("q11.png", width: 70%),
  caption: [Open the PDF Attachments panel to play `q11.mp4`],
)
=== Step 12
// Attaches the video inside the PDF file itself
#pdf.attach("q12.mp4", description: "Demo Video")

// Visual placeholder in the document text
#figure(
  image("q12.png", width: 70%),
  caption: [Open the PDF Attachments panel to play `q12.mp4`],
)
=== Step 15
// Attaches the video inside the PDF file itself
#pdf.attach("q15_1.mp4", description: "Demo Video")

// Visual placeholder in the document text
#figure(
  image("q15_1.png", width: 70%),
  caption: [Open the PDF Attachments panel to play `q15_1.mp4`],
)
// Attaches the video inside the PDF file itself
#pdf.attach("q15_2.mp4", description: "Demo Video")

// Visual placeholder in the document text
#figure(
  image("q15_2.png", width: 70%),
  caption: [Open the PDF Attachments panel to play `q15_2.mp4`],
)
Disturbance test:
No it does not return exactly to the setpoint because it is a proportional controller that is dependent on the position error. As the disk approaches the setpoint, the error becomes smaller and the PWM reduces and cannot overcome the friction of the disk. At $k_p$ = 1, the disk stops a few degrees short, when increased to 2 it gets better, and generally the increase in $k_p$ will reduce error. 
#table(
  columns: (auto, auto, auto), // Column widths: auto, fractional, or fixed (e.g., 2cm)
  inset: 10pt,                 // Cell padding
  align: horizon,              // Vertical/horizontal alignment
  table.header(
    [*Variable*], [*Value*], [*How We Measured*],
  ),
  [$k_u$], [6], [We observed that the $k_p$ value that first resulted in an unsettled state was 6],
  [$T_u$],[0.1497],[Slo motion video: $T_u$ = time / cycles],
  [$k_p$],[3],[$k_p$ = $k_u$/2],
)


Questions:

(a) Why does the loop oscillate at high Kp, when the simple
textbook model says it never should? 

In typical textbook models, we assume an ideal case where the controller reacts immediately to the signal sent to the FPGA board to also immediately update the disk to move to some position, additionally failing to take into account inertia and motor current time. However, in a real case, we have some delay between the controller and FPGA board as it updates once every 100MHz. When the controller attempts to correct itself at high $k_p$, the controller has already moved outside of its previous reading to update because of the delay. Therefore, overshoot as well as the delayed correction continuosly repeats itself.

(b) Why does the disk sometimes stop short of the setpoint at
low Kp?

Again, a real case fails to take into consideration certain physical parameters like friction. The disk movement to a certain position is also a small torque, so when the disk moves the disk fails to overcome all of the friction and has slight undershoot.

Project Summary and Timing Requirements:
#image("ts.png")

$ 1/(10-1.547) times 10^9 = 118301194.842 $
The maximum is 118.3 MHz, which meets the timing requirement of 100 MHz.