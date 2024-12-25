`include "multiplier.sv"
module multiplier_tb;
// Parameters (matching the module)
parameter exp_width = 8;
parameter mant_width = 24;
// Local Parameters
localparam total_width = exp_width + mant_width;
// Inputs
logic [total_width - 1:0] a;
logic [total_width - 1:0] b;
logic [2:0]                round_mode;
// Outputs
wire [4:0]                exceptions;  // Changed to wire
wire [total_width - 1:0]       out;       // Changed to wire
// Instantiate the DUT (Device Under Test)
multiplier #(
.exp_width   (exp_width),
.mant_width  (mant_width)
) dut (
.a           (a),
.b           (b),
.round_mode  (round_mode),
.exceptions  (exceptions),
.out         (out)
);
// Simulation Controls
initial begin
$dumpfile("multiplier_tb.vcd");
$dumpvars(0, multiplier_tb);
end
initial begin
// Test Case 1: Normal Multiplication (positive numbers)
 a = {1'b0, 8'h80, 23'h400000}; // 1.5
 b = {1'b0, 8'h80, 23'h200000}; // 1.25
 round_mode = 3'b000;  // Round to Nearest Even
 #10;
    
 // Test Case 2: Multiplication with a negative number
 a = {1'b1, 8'h80, 23'h400000}; // -1.5
 b = {1'b0, 8'h80, 23'h200000}; // 1.25
 round_mode = 3'b000;  // Round to Nearest Even
 #10;
 
 // Test Case 3: Zero case
 a = {1'b0, 8'h00, 23'h000000};
 b = {1'b0, 8'h80, 23'h200000};
 round_mode = 3'b000;  // Round to Nearest Even
 #10;
    
 // Test Case 4: Multiplication with a subnormal number
 a = {1'b0, 8'h01, 23'h100000}; //  subnormal number
 b = {1'b0, 8'h80, 23'h200000};
 round_mode = 3'b000;
 #10;
    
  //Test case 5: Multiplication with Infinity
  a = {1'b0, 8'hff, 23'h000000}; // Infinity
  b = {1'b0, 8'h80, 23'h200000};
  round_mode = 3'b000;
  #10;
   
 // Test case 6: NaN case
  a = {1'b0, 8'hff, 23'h400000}; // NaN
  b = {1'b0, 8'h80, 23'h200000};
  round_mode = 3'b000;
  #10;

  //Test case 7: Round Up
  a = {1'b0, 8'h80, 23'h400000}; // 1.5
  b = {1'b0, 8'h80, 23'h200000}; // 1.25
  round_mode = 3'b001; // Round Up
  #10;
  
  //Test case 8: Round Down
  a = {1'b0, 8'h80, 23'h400000}; // 1.5
  b = {1'b0, 8'h80, 23'h200000}; // 1.25
  round_mode = 3'b010; // Round Down
  #10;

  // End Simulation
  $finish;
end
endmodule
