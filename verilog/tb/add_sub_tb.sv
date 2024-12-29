`timescale 1ns / 1ps
`include "../rtl/add_sub.sv"

module add_sub_tb;

  // Inputs
  reg [31:0] in_x;
  reg [31:0] in_y;
  reg        operation;
  reg [2:0]  round_mode;

  // Outputs
  wire [31:0] out_z;
  wire [4:0]  exceptions;

  // Instantiate the Unit Under Test (UUT)
  add_sub uut (
    .in_x(in_x),
    .in_y(in_y),
    .operation(operation),
    .round_mode(round_mode),
    .out_z(out_z),
    .exceptions(exceptions)
  );

  initial begin
    // Initialize inputs
    in_x = 32'b0;
    in_y = 32'b0;
    operation = 0;
    round_mode = 0;

    // Initialize waveform dump
    $dumpfile("../sim/add_sub.vcd"); // Specify the VCD file name
    $dumpvars(0, add_sub_tb);    // Dump all signals in this module (add_sub_tb)


    // Test Case 1: Simple Addition
    $display("Test Case 1: Simple Addition");
    in_x = 32'h3f800000; // 1.0
    in_y = 32'h3f800000; // 1.0
    operation = 0;
    round_mode = 3'b000;
    #10;

    // Test Case 2: Simple Subtraction
     $display("Test Case 2: Simple Subtraction");
    in_x = 32'h40000000; // 2.0
    in_y = 32'h3f800000; // 1.0
    operation = 1;
    round_mode = 3'b000;
    #10;

    // Test Case 3: Subtraction with Negatives
     $display("Test Case 3: Subtraction with Negatives");
    in_x = 32'hbf800000; // -1.0
    in_y = 32'h3f800000; // 1.0
    operation = 1;
    round_mode = 3'b000;
    #10;

    // Test Case 4: Addition with Zero
     $display("Test Case 4: Addition with Zero");
    in_x = 32'h3f800000; // 1.0
    in_y = 32'h00000000; // 0.0
    operation = 0;
    round_mode = 3'b000;
    #10;

    // Test Case 5: Subtraction with Zero
     $display("Test Case 5: Subtraction with Zero");
    in_x = 32'h3f800000; // 1.0
    in_y = 32'h00000000; // 0.0
    operation = 1;
    round_mode = 3'b000;
    #10;
    
    // Test Case 6: Subtraction with same operands
     $display("Test Case 6: Subtraction with same operands");
    in_x = 32'h3f800000; // 1.0
    in_y = 32'h3f800000; // 1.0
    operation = 1;
    round_mode = 3'b000;
    #10;
    
    // Test Case 7: Subnormal Number
     $display("Test Case 7: Subnormal Number");
    in_x = 32'h00400000; // subnormal
    in_y = 32'h3f800000; // 1.0
    operation = 0;
    round_mode = 3'b000;
    #10;
    
    // Test Case 8: Infinity
     $display("Test Case 8: Infinity");
    in_x = 32'h7f800000; // Infinity
    in_y = 32'h3f800000; // 1.0
    operation = 0;
    round_mode = 3'b000;
    #10;
    
    // Test Case 9: QNaN
     $display("Test Case 9: QNaN");
    in_x = 32'h7fc00000; // QNaN
    in_y = 32'h3f800000; // 1.0
    operation = 0;
    round_mode = 3'b000;
    #10;
    
    // Test Case 10: Addition causing overflow
     $display("Test Case 10: Addition causing overflow");
    in_x = 32'h7f7fffff;
    in_y = 32'h3f7fffff;
    operation = 0;
    round_mode = 3'b000;
    #10;

    $finish;
  end

endmodule
