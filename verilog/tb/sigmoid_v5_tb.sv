`include "../rtl/sigmoid_v5.sv"
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
  reg        in_valid;

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
    .in_valid(in_valid),
    .out_sigmoid(out_sigmoid)
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
    #5;
    rst_l = 1;
  end
  
  // Testbench Stimulus
  initial begin
    // in_valid = 0
    // in_ready = 0
    // out_valid = 0
    #5; //wait for reset
    round_mode = 3'b000; // Round to nearest even

                                  $display("--------------------------------------------------------------------------------");
                                  $display("Input                |  Actual Sigmoid |  Right Value");
                                  $display("--------------------------------------------------------------------------------");
    
    // Direct input assignments and display
    // with the first input you set in_valid = 1
    // wait till out_valid is 1 and set in_valid = 0
    // once x changes (new assignment) set in valid = 1
    in_x = 32'hC0A00000; in_valid = 1; #10;  in_valid = 0;#290; $display("0x%h (%2d)      |    0x%h   |  0x%h (%3f) ", in_x, -5, out_sigmoid, 32'h3daaaab0, 0.083333); // -5.0
    in_x = 32'hC0800000; in_valid = 1; #10;  in_valid = 0;#280; $display("0x%h (%2d)      |    0x%h   |  0x%h (%3f) ", in_x, -4, out_sigmoid, 32'h3dccccd0, 0.1000); // -4.0
    in_x = 32'hC0400000; in_valid = 1; #10;  in_valid = 0;#280; $display("0x%h (%2d)      |    0x%h   |  0x%h (%3f) ", in_x, -3, out_sigmoid, 32'h3e000000, 0.125); // -3.0
    in_x = 32'hC0000000; in_valid = 1; #10;  in_valid = 0;#280; $display("0x%h (%2d)      |    0x%h   |  0x%h (%3f) ", in_x, -2, out_sigmoid, 32'h3e2aaaa8, 0.166666); // -2.0
    in_x = 32'hBF800000; in_valid = 1; #10;  in_valid = 0;#280; $display("0x%h (%2d)      |    0x%h   |  0x%h (%3f) ", in_x, -1, out_sigmoid, 32'h3e800000, 0.25); // -1.0
    in_x = 32'h00000000; in_valid = 1; #10;  in_valid = 0;#280; $display("0x%h (%2d)      |    0x%h   |  0x%h (%3f) ", in_x,  0, out_sigmoid, 32'h3f000000, 0.5); // 0.0
    in_x = 32'h3F800000; in_valid = 1; #10;  in_valid = 0;#280; $display("0x%h (%2d)      |    0x%h   |  0x%h (%3f) ", in_x,  1, out_sigmoid, 32'h3f400000, 0.75); // 1.0
    in_x = 32'h40000000; in_valid = 1; #10;  in_valid = 0;#280; $display("0x%h (%2d)      |    0x%h   |  0x%h (%3f) ", in_x,  2, out_sigmoid, 32'h3f555556, 0.833333); // 2.0
    in_x = 32'h40400000; in_valid = 1; #10;  in_valid = 0;#280; $display("0x%h (%2d)      |    0x%h   |  0x%h (%3f) ", in_x,  3, out_sigmoid, 32'h3f600000, 0.875); // 3.0
    in_x = 32'h40800000; in_valid = 1; #10;  in_valid = 0;#280; $display("0x%h (%2d)      |    0x%h   |  0x%h (%3f) ", in_x,  4, out_sigmoid, 32'h3f666666, 0.899999); // 4.0
    in_x = 32'h40A00000; in_valid = 1; #10;  in_valid = 0;#290; $display("0x%h (%2d)      |    0x%h   |  0x%h (%3f) ", in_x,  5, out_sigmoid, 32'h3f6aaaaa, 0.916666); // 5.0


    $display("--------------------------------------------------------------------------------");
    $finish;
  end
  
  
  initial begin
    $dumpfile("../sim/sigmoid_v5.vcd");
    $dumpvars(0, sigmoid_approx_tb);
  end
  
endmodule
          