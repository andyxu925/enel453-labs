`timescale 1ns / 1ps

module hex_bcd_mux_tb();

    parameter DELAY = 500000;

    logic [15:0] hex;
    logic [15:0] bcd;
    logic        sel;
    logic [15:0] out;

    hex_bcd_mux uut (
        .hex(hex),
        .bcd(bcd),
        .sel(sel),
        .out(out)
    );

    initial begin
        #100;
        
        // Test HEX output
        hex = '0; #10;
        bcd = '0; #10;

        sel = 1'b0; #10;

        hex = 16'ha5a5; #DELAY;
        hex = 16'h5a5a; #DELAY;
        hex = 16'h00a5; #DELAY;
        hex = 16'h005a; #DELAY;

        // Test BCD output
        hex = '0; #10;
        bcd = '0; #10;
        
        sel = 1'b1; #10;
        
        bcd = 16'ha5a5; #DELAY;
        bcd = 16'h5a5a; #DELAY;
        bcd = 16'h00a5; #DELAY;
        bcd = 16'h005a; #DELAY;

        #DELAY;
        $stop;
    end

endmodule