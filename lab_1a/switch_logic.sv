module switch_logic (
    input  logic [15:0] switches_inputs,
    output logic [15:0] switches_outputs 
);

    //assign switches_outputs = ~switches_inputs; 
    
    assign switches_outputs[15:8] = ~switches_inputs[15:8]; 
    assign switches_outputs[7:1]  = switches_inputs[7:1];
    assign switches_outputs[0]    = switches_inputs[1] & switches_inputs[0];
    
    // Step 13
    // Down = 0, Up = 1
    // Assign each switch output directly to inverted input
    // Therefore, Down => LED = ~0 = 1 = ON
    // Up => LED = ~1 = 0 = OFF 
    // assign switches_outputs[15:0] = ~switches_inputs[15:0];
    
    // Step 15
    // Down = 0, Up = 1
    // Assign each switch output directly to input
    // Therefore, Down => LED = 0 = OFF
    // Up => LED = 1 = ON 
    // assign switches_outputs[15:0] = switches_inputs[15:0];
     

endmodule
