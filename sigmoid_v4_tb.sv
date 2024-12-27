`include "sigmoid_v4.sv"
`timescale 1ns/1ps

module sigmoid_approx_tb;

  // Parameters (Match the module parameters)
  parameter exp_width = 8;
  parameter mant_width = 24;
  parameter total_width = exp_width + mant_width;

  // Clock and Reset
  reg clk;
  reg rst_l;
  
  // Input to sigmoid_approx
  reg  [total_width - 1:0] in_x;
  reg  [2:0] round_mode;

  // Output from sigmoid_approx
  wire [total_width - 1:0] out_sigmoid;
  wire [4:0] exceptions;


  // Instance of the module
  sigmoid_approx #(
      .exp_width(exp_width),
      .mant_width(mant_width)
  ) uut (
    .in_x(in_x),
    .clk(clk),
    .rst_l(rst_l),
    .round_mode(round_mode),
    .out_sigmoid(out_sigmoid),
    .exceptions(exceptions)
    //input in_valid
    //out in_ready //
    //out out_valid
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Reset generation
  initial begin
    rst_l = 0;
    #10;
    rst_l = 1;
  end
  
  // Testbench Stimulus
  initial begin
    // in_valid = 0
    // in_ready = 0
    // out_valid = 0
    
    round_mode = 3'b000; // Round to nearest even

    $display("--------------------------------------------------------------------------------");
    $display("Input        |  Actual Sigmoid ");
    $display("--------------------------------------------------------------------------------");
    
    // Direct input assignments and display
    // with the first input you set in_valid = 1
    // wait till out_valid is 1 and set in_valid = 0
    // once x changes (new assignment) set in valid = 1
    in_x = 32'hC0A00000;    #320; $display("0x%h      |    0x%h ", in_x, out_sigmoid); // -5.0
    in_x = 32'hC0800000;    #320; $display("0x%h      |    0x%h ", in_x, out_sigmoid); // -4.0
    in_x = 32'hC0400000;    #320; $display("0x%h      |    0x%h ", in_x, out_sigmoid); // -3.0
    in_x = 32'hC0000000;    #320; $display("0x%h      |    0x%h ", in_x, out_sigmoid); // -2.0
    in_x = 32'hBF800000;    #320; $display("0x%h      |    0x%h ", in_x, out_sigmoid); // -1.0
    in_x = 32'h00000000;    #320; $display("0x%h      |    0x%h ", in_x, out_sigmoid); // 0.0
    in_x = 32'h3F800000;    #320; $display("0x%h      |    0x%h ", in_x, out_sigmoid); // 1.0
    in_x = 32'h40000000;    #320; $display("0x%h      |    0x%h ", in_x, out_sigmoid); // 2.0
    in_x = 32'h40400000;    #320; $display("0x%h      |    0x%h ", in_x, out_sigmoid); // 3.0
    in_x = 32'h40800000;    #320; $display("0x%h      |    0x%h ", in_x, out_sigmoid); // 4.0
    in_x = 32'h40A00000;    #320; $display("0x%h      |    0x%h ", in_x, out_sigmoid); // 5.0


    $display("--------------------------------------------------------------------------------");
    $finish;
  end
  
  
  initial begin
    $dumpfile("sigmoid_v4.vcd");
    $dumpvars(0, sigmoid_approx_tb);
  end
  
endmodule
