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
