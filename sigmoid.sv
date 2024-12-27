`include "fpu_lib.sv"
`include "add_sub.sv"
`include "multiplier.sv"

module sigmoid (
  input  wire [31:0] in_x,      // IEEE 754 input floating-point number
  input  wire [2:0]  round_mode, // Rounding mode for all FP operations
  output wire [31:0] out_sigmoid, // IEEE 754 output, sigmoid(in_x)
  output wire [4:0] exceptions    // Exception flags of the whole module
);

  // Internal signals
  wire [31:0] x_sq;
  wire [31:0] x_cub;
  wire [31:0] term2;
  wire [31:0] term3;
  wire [31:0] sum_terms;
  wire [4:0] mult_ex,addsub_ex1,addsub_ex2,addsub_ex3;
  wire sign_bit;
  wire [31:0] abs_x;
  wire [31:0] const_05, const_025,const_002083333;
  wire [31:0] four_f;
  reg [31:0] out_sigmoid_reg; // Register for out_sigmoid
  reg [4:0] exceptions_reg;   // Register for exceptions

  // Constants for multiplication
  assign const_05 = 32'h3f000000;  // 0.5
  assign const_025 = 32'h3e800000; // 0.25
  assign const_002083333 = 32'h3d555555; // 1/48


    // Convert input to absolute value to compare
    assign sign_bit = in_x[31];
    assign abs_x = sign_bit == 1'b1 ? ({1'b0, in_x[30:0]}): in_x;

  //compare with four
    assign four_f = 32'h40800000;
    
    
    //compare absolute value of x with 4

  // Multiplication: x*x 
  multiplier #( .exp_width(8), .mant_width(24)) mult_1 (
    .a(in_x),
    .b(in_x),
    .round_mode(round_mode),
    .out(x_sq),
    .exceptions(mult_ex)
  );

    // Multiplication: x*x*x
  multiplier #( .exp_width(8), .mant_width(24)) mult_2 (
    .a(x_sq),
    .b(in_x),
    .round_mode(round_mode),
    .out(x_cub),
    .exceptions()
  );

  // Multiplication: 0.25*x
   multiplier #( .exp_width(8), .mant_width(24)) mult_3 (
    .a(in_x),
    .b(const_025),
    .round_mode(round_mode),
    .out(term2),
    .exceptions()
  );

  // Multiplication: x^3/48
    multiplier #( .exp_width(8), .mant_width(24)) mult_4 (
    .a(x_cub),
    .b(const_002083333),
    .round_mode(round_mode),
    .out(term3),
    .exceptions()
    );

  // Addition: 0.5 + 0.25x
  add_sub add_sub_1 (
    .in_x(const_05),
    .in_y(term2),
    .operation(1'b0), // Addition
    .round_mode(round_mode),
    .out_z(sum_terms),
    .exceptions(addsub_ex1)
  );
    
    // Subtraction: (0.5 + 0.25x) - x^3/48
    add_sub add_sub_2 (
        .in_x(sum_terms),
        .in_y(term3),
        .operation(1'b1), // Subtraction
        .round_mode(round_mode),
        .out_z(out_sigmoid_reg),
        .exceptions(addsub_ex2)
     );
  
    assign exceptions = mult_ex | addsub_ex1 | addsub_ex2;


  //handle x>4 and x < -4 case
//    always @(*) begin
  //      if(abs_x>=four_f) begin
    //        if(in_x[31]==1'b0) begin
      //       out_sigmoid_reg <= 32'h3f800000; // 1.0
        //     exceptions_reg <= 5'b0;
          //   end
            //else begin
             //out_sigmoid_reg <= 32'h00000000; // 0.0
            // exceptions_reg <= 5'b0;
          //   end
        // end
      //   else begin
    //         exceptions_reg = exceptions;
  //       end
//    end

    assign out_sigmoid = out_sigmoid_reg;
     assign exceptions = exceptions_reg;
endmodule
