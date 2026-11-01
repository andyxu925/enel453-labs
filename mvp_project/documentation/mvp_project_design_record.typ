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

=== Step 5
=== Step 6
=== Step 7
