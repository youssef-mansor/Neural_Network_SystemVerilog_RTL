`include "sigmoid_v2.sv"
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
    round_mode = 3'b000; // Round to nearest even

    $display("--------------------------------------------------------------------------------");
    $display("Input        |  Actual Sigmoid ");
    $display("--------------------------------------------------------------------------------");
    
    // Direct input assignments and display
    in_x = 32'hC0A00000;    #20; $display("0x%h      |    0x%h ", in_x, out_sigmoid); // -5.0
    in_x = 32'hC0800000;    #20; $display("0x%h      |    0x%h ", in_x, out_sigmoid); // -4.0
    in_x = 32'hC0400000;    #20; $display("0x%h      |    0x%h ", in_x, out_sigmoid); // -3.0
    in_x = 32'hC0000000;    #20; $display("0x%h      |    0x%h ", in_x, out_sigmoid); // -2.0
    in_x = 32'hBF800000;    #20; $display("0x%h      |    0x%h ", in_x, out_sigmoid); // -1.0
    in_x = 32'h00000000;    #20; $display("0x%h      |    0x%h ", in_x, out_sigmoid); // 0.0
    in_x = 32'h3F800000;    #20; $display("0x%h      |    0x%h ", in_x, out_sigmoid); // 1.0
    in_x = 32'h40000000;    #20; $display("0x%h      |    0x%h ", in_x, out_sigmoid); // 2.0
    in_x = 32'h40400000;    #20; $display("0x%h      |    0x%h ", in_x, out_sigmoid); // 3.0
    in_x = 32'h40800000;    #20; $display("0x%h      |    0x%h ", in_x, out_sigmoid); // 4.0
    in_x = 32'h40A00000;    #20; $display("0x%h      |    0x%h ", in_x, out_sigmoid); // 5.0


    $display("--------------------------------------------------------------------------------");
    $finish;
  end
  
  
  initial begin
    $dumpfile("sigmoid_v2.vcd");
    $dumpvars(0, sigmoid_approx_tb);
  end
  
endmodule
