`include "../rtl/divider.sv"
`timescale 1ns/1ps

module divider_tb;

  // Parameters
  parameter exp_width = 8;
  parameter mant_width = 24;
  parameter total_width = exp_width + mant_width;
  parameter options = 0;

  // Inputs
  reg rst_l;
  reg clk;
  reg in_valid;
  reg [total_width-1:0] a;
  reg [total_width-1:0] b;
  reg [2:0] round_mode;
  reg cancel;

  // Outputs
  wire in_ready;
  wire out_valid;
  wire [total_width-1:0] out;
  wire [4:0] exceptions;

  // Instantiate the module
  divider #(
    .exp_width(exp_width),
    .mant_width(mant_width),
    .options(options)
  ) dut (
    .rst_l(rst_l),
    .clk(clk),
    .in_valid(in_valid),
    .a(a),
    .b(b),
    .round_mode(round_mode),
    .cancel(cancel),
    .in_ready(in_ready),
    .out_valid(out_valid),
    .out(out),
    .exceptions(exceptions)
  );

  // Clock generation
  always #5 clk = ~clk;

  initial begin
    clk = 0;
    rst_l = 0;
    in_valid = 0;
    cancel = 0;
    round_mode = 3'b000; // Round to nearest Even

    #10;
    rst_l = 1;
    #10;
    
    // Test Case 1: Positive Floating-Point Division (6.0 / 2.0)
    $display("==================== Test Case 1 ====================");
    a = 32'h40C00000; // 6.0
    b = 32'h40000000; // 2.0
    in_valid = 1;
    #10;
    in_valid = 0;
    wait(out_valid);
    $display("Input A (Hex): %h", a);
    $display("Input B (Hex): %h", b);
    $display("Output (Hex): %h", out);
    $display("Exceptions: %b", exceptions);
    #20;

      // Test Case 2: Negative Integer Division (-12 / 4)
    $display("==================== Test Case 2 ====================");
    a = 32'hC1400000; // -12
    b = 32'h40800000; // 4
    in_valid = 1;
    #10;
    in_valid = 0;
    wait(out_valid);
    $display("Input A (Hex): %h", a);
    $display("Input B (Hex): %h", b);
    $display("Output (Hex): %h", out);
    $display("Exceptions: %b", exceptions);
    #20;
    
    $finish;
  end
endmodule
