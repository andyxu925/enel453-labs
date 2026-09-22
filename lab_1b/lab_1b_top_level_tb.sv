`timescale 1ns / 1ps

module lab_1b_top_level_tb();

    // Parameters
    parameter CLK_PERIOD = 10; // 10ns for 100MHz clock

    // Signals
    logic clk;
    logic reset;
    logic [15:0] switches_inputs;

    logic CA, CB, CC, CD, CE, CF, DP;
    logic AN1, AN2, AN3, AN4;

    logic [15:0] led;

    // Instantiate the Unit Under Test (UUT)
    lab_1b_top_level uut (
        .clk(clk),
        .reset(reset),
        .switches_inputs(switches_inputs),
        .CA(CA), .CB(CB), .CC(CC), .CD(CD), .CE(CE), .CF(CF), .DP(DP),
        .AN1(AN1), .AN2(AN2), .AN3(AN3), .AN4(AN4),
        .led(led)
    );

    // Clock generation
    always begin
        clk = 0;
        #(CLK_PERIOD/2);
        clk = 1;
        #(CLK_PERIOD/2);
    end

    // Test stimulus
    initial begin
        // Initialize inputs
        reset = 1; #CLK_PERIOD;
        reset = 0; #CLK_PERIOD;

        // Test case 1:
        switches_inputs = 16'b0000_0000_0000_0000; #(100000 * CLK_PERIOD);

        // Test case 2:
        switches_inputs = 16'b1111_1111_1111_1111; #(100000 * CLK_PERIOD);

        // Test case 2:
        switches_inputs = 16'b0101_0101_0101_0101; #(100000 * CLK_PERIOD);

        // Test case 3:
        switches_inputs = 16'b1010_1010_1010_1010; #(100000 * CLK_PERIOD);

        // Test case 4:
        switches_inputs = 16'b1100_1100_1100_1100; #(100000 * CLK_PERIOD);

        // Test case 5:
        switches_inputs = 16'b0011_0011_0011_0011; #(100000 * CLK_PERIOD);

        // End simulation
        #(500000 * CLK_PERIOD);
        $stop;
    end

    // Optional: Monitor changes
    initial begin
        $monitor("Time = %0t: switches_inputs = %b, led = %b", 
                 $time, switches_inputs, led);
    end

endmodule