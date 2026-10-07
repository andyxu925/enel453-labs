module lab_3_top_level (
    input  logic        clk,
    input  logic        reset, // center pushbutton (push to reset): Basys3 pushbuttons are normally 0, and 1 when pushed down

    input  logic        sw_reg_sel,

    input  logic        reg_reset,
    input  logic        reg_ena,

    input  logic        hex_bcd_sel, // top pushbutton

    input  logic [15:0] switches_inputs, // slide switches (0 towards Basys3 board edge, 1 towards board center)

    output logic        CA, CB, CC, CD, CE, CF, CG, DP, // 7-segment display LED elements
    output logic        AN1, AN2, AN3, AN4, // anodes of 7-seg display LEDs, to select one of the four 7-seg displays (time-multiplexed)
    output logic [15:0] led // mapped to the LEDs above the slide switches, LEDs: write a 1 to light LED, 0 to turn it off
);


    // Internal signal declarations

    logic [15:0] reg_out;

    logic [15:0] mux_out;

    logic [15:0] bcd_out;
    logic        overflow;

    logic [15:0] hex_bcd_out;

    logic [15:0] switches_outputs;




    // Instantiate components
    reg_16_bit REG_16_BIT(
        .clk(       clk),
        .reset(     reg_reset),
        .ena(       reg_ena),
        .in(        switches_inputs),
        .out(       reg_out)
    );


    mux_2 MUX_2(
        .in_1(  switches_inputs),
        .in_2(  reg_out),
        .sel(   sw_reg_sel),
        .out(   mux_out)
    );


    bin_to_bcd BIN_TO_BCD(
        .clk(       clk),
        .reset(     reset),
        .bin_in(    mux_out),
        .bcd_out(   bcd_out)
    );


    hex_bcd_mux HEX_BCD_MUX(
        .hex(       mux_out),
        .bcd(       bcd_out),
        .sel(       hex_bcd_sel),
        .out(       hex_bcd_out),
        .overflow(  overflow)
    );


    seven_segment_display_subsystem SEVEN_SEGMENT_DISPLAY (
        .clk(       clk),
        .reset(     reset),
        .overflow(  overflow),
        .sec_dig1(  hex_bcd_out[3:0]),
        .sec_dig2(  hex_bcd_out[7:4]),
        .min_dig1(  hex_bcd_out[11:8]),
        .min_dig2(  hex_bcd_out[15:12]),
        .CA(        CA),
        .CB(        CB),
        .CC(        CC),
        .CD(        CD),
        .CE(        CE),
        .CF(        CF),
        .CG(        CG),
        .DP(        DP),
        .AN1(       AN1),
        .AN2(       AN2),
        .AN3(       AN3),
        .AN4(       AN4)
    );


    switch_logic SWITCHES (
         .switches_inputs( switches_inputs),
         .switches_outputs(switches_outputs)
    );


    assign led = switches_outputs;

endmodule
