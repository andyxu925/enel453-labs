`timescale 1ns / 1ps

module reg_16_bit_tb();
    parameter CLK_PERIOD = 10;

    logic clk;
    logic reset;
    logic ena;

    logic [15:0] in;
    logic [15:0] out;

    reg_16_bit uut (
        .clk(   clk),
        .reset( reset),
        .ena(   ena),
        .in(    in),
        .out(   out)
    );

    always begin
        clk = 0;
        #(CLK_PERIOD/2);
        clk = 1;
        #(CLK_PERIOD/2);
    end

    initial begin
        reset = 0;
        ena   = 0;
                   #100;        // GSR
        reset = 1; #CLK_PERIOD; // Reset
        reset = 0; #CLK_PERIOD;

        ena = 1;        #CLK_PERIOD;
        in  = 16'h0123; #CLK_PERIOD;
        ena = 0;        #CLK_PERIOD;
        in  = 16'h4567; #CLK_PERIOD;

        ena = 1;        #CLK_PERIOD;
        in  = 16'h4567; #CLK_PERIOD;
        ena = 0;        #CLK_PERIOD;
        in  = 16'h89AB; #CLK_PERIOD;

        ena = 1;        #CLK_PERIOD;
        in  = 16'h89AB; #CLK_PERIOD;
        ena = 0;        #CLK_PERIOD;
        in  = 16'hCDEF; #CLK_PERIOD;

        ena = 1;        #CLK_PERIOD;
        in  = 16'hCDEF; #CLK_PERIOD;

        #(50000 * CLK_PERIOD);
        $stop;
    end

endmodule