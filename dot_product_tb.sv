`include "dot_product.sv"
`timescale 1ns/1ps

module dot_product_tb;

  // Parameters for the dot_product module
  parameter DATA_WIDTH = 32;
  parameter VECTOR_SIZE = 4;

  // Inputs for dot_product
  logic [DATA_WIDTH-1:0] test_row [VECTOR_SIZE];
  logic [DATA_WIDTH-1:0] test_col [VECTOR_SIZE];
  logic [2:0] test_round_mode;

  // Outputs from dot_product
  wire [DATA_WIDTH-1:0] dot_product_out;
  wire [4:0] exceptions;


  // Instantiate the dot_product module
  dot_product #(
    .DATA_WIDTH(DATA_WIDTH),
    .VECTOR_SIZE(VECTOR_SIZE)
  ) dut (
    .row(test_row),
    .col(test_col),
    .round_mode(test_round_mode),
    .dot_product_out(dot_product_out),
    .exceptions(exceptions)
  );

  initial begin
    // Initialize VCD dumping
    $dumpfile("dot_product.vcd");
    $dumpvars(0, dot_product_tb);

    // Test Case 1: [1, 2, 1.5, -1] * [3, 1, -2, 1.5]

    // 1.0  -> 0x3f800000
    test_row[0] = 32'h3f800000;
    // 2.0  -> 0x40000000
    test_row[1] = 32'h40000000;
    // 1.5  -> 0x3fc00000
    test_row[2] = 32'h3fc00000;
    // -1.0 -> 0xbf800000
    test_row[3] = 32'hbf800000;

    // 3.0  -> 0x40400000
    test_col[0] = 32'h40400000;
    // 1.0  -> 0x3f800000
    test_col[1] = 32'h3f800000;
    // -2.0 -> 0xc0000000
    test_col[2] = 32'hc0000000;
    // 1.5  -> 0x3fc00000
    test_col[3] = 32'h3fc00000;

      test_round_mode = 3'b000; // Round to nearest even

     #100;
    // Display the result
    $display("Dot product result = %h", dot_product_out);
    $display("Exceptions = %b", exceptions);

    #100;
    // Finish simulation
    $finish;
  end
endmodule
