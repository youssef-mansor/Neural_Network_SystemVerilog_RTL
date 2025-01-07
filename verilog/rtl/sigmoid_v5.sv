// `include "defs.vi"
// `include "fpu_lib.sv"
// `include "add_sub.sv"
// `include "multiplier.sv"
// `include "divider.sv"

module sigmoid_approx #(
    parameter exp_width = 8,
    parameter mant_width = 24,
    // Add parameters for FP constants
    parameter [(exp_width + mant_width - 1):0] HALF_VAL = 32'h3f000000, // 0.5 in FP
    parameter [(exp_width + mant_width - 1):0] ONE_VAL  = 32'h3f800000  // 1.0 in FP
)(
    input  wire [(exp_width + mant_width - 1):0] in_x,
    input  wire                                   clk,
    input  wire                                   rst_l,
    input  wire [2:0]                            round_mode,
    input  wire                                  in_valid,
    output reg  [(exp_width + mant_width - 1):0] out_sigmoid,
    output wire                                  out_valid
);

  // Internal Wires for intermediate calculations
  wire [(exp_width + mant_width - 1):0] x_neg;
  wire [(exp_width + mant_width - 1):0] one_minus_x;
  wire [(exp_width + mant_width - 1):0] one_plus_x;

  // Division stage wires and registers
  wire [(exp_width + mant_width - 1):0] x_div_one_minus_x;
  wire [(exp_width + mant_width - 1):0] x_div_one_plus_x;
  wire div_inst1_out_valid, div_inst2_out_valid;
    
  // After Division Stage
  wire [(exp_width + mant_width - 1):0] term1;
  wire [(exp_width + mant_width - 1):0] term2;
  wire [(exp_width + mant_width - 1):0] term1_pre;
  wire [(exp_width + mant_width - 1):0] term1_final;
  wire [(exp_width + mant_width - 1):0] term2_final;
  // wire [(exp_width + mant_width - 1):0] half_val;
  // wire [(exp_width + mant_width - 1):0] one_val;
  wire                                  x_is_negative;
  wire [(exp_width + mant_width - 1):0] out_sigmoid_not_stbl;
  

  // Error exception wires
  //wire [4:0] add_exceptions, sub_exceptions_1, sub_exceptions_2, div_exceptions_1, div_exceptions_2, mul_exceptions_1, mul_exceptions_2;
  
  //   //  Assigning floating point values for 0.5 and 1
  // assign half_val = 32'h3f000000; // 0.5 in FP representation
  // assign one_val =  32'h3f800000;  // 1.0 in FP representation
  wire [(exp_width + mant_width - 1):0] half_val;
  wire [(exp_width + mant_width - 1):0] one_val;
  assign half_val = HALF_VAL;
  assign one_val = ONE_VAL;

    // Register the output of divider once valid
  // always @(posedge clk) begin
  //         if(out_valid) begin
  //           out_sigmoid <= out_sigmoid_not_stbl;
  //         end
  // end
    // Add proper reset to output register
  always @(posedge clk) begin
    if (!rst_l) begin
      out_sigmoid <= {(exp_width + mant_width){1'b0}};
    end
    else if (out_valid) begin
      out_sigmoid <= out_sigmoid_not_stbl;
    end
  end

    
  // 1. Determine if x is negative (sign bit check)
  assign x_is_negative = in_x[(exp_width + mant_width - 1)];

  // 2. Calculate -x if x is negative, else just x for positive case 
  //assign x_neg = (x_is_negative)? ({1'b0,in_x[(exp_width + mant_width - 2) : 0] }):in_x; // For negative, flip the sign bit and use positive value.
 // assign x_neg = {1'b1, in_x[(exp_width + mant_width - 2) : 0] };
   assign x_neg = {~in_x[(exp_width + mant_width)-1], in_x[(exp_width + mant_width)-2:0]};


  // 3. Calculate 1 - x 
   add_sub  add_sub_inst1(
    .in_x(one_val),
    .in_y(x_neg),
    .operation(1'b0), // operation = 0 for addition 
    .round_mode(round_mode),
    .out_z(one_minus_x),
    .exceptions()
    //.exceptions(sub_exceptions_1)
  );
  //(or 1 + x, based on sign)
   add_sub  add_sub_inst2(
    .in_x(one_val),
    .in_y(in_x),
    .operation(1'b0),
    .round_mode(round_mode),
    .out_z(one_plus_x),
    .exceptions()
   // .exceptions(add_exceptions)
   );


  // 4. Calculate -x / (1-x) 
  divider #( .exp_width(exp_width), .mant_width(mant_width)) 
   div_inst1 (
    .rst_l(rst_l),
    .clk(clk),
    .in_valid(in_valid),
    .a(x_neg),
    .b(one_minus_x),
    .round_mode(round_mode),
    .cancel(1'b0),
    .in_ready(),
    .out_valid(div_inst1_out_valid),
    .out(x_div_one_minus_x),
    .exceptions()
    //.exceptions(div_exceptions_1)
  );
//and x / (1+x)
  divider #( .exp_width(exp_width), .mant_width(mant_width)) 
    div_inst2(
    .rst_l(rst_l),
    .clk(clk),
    .in_valid(in_valid),
    .a(in_x),
    .b(one_plus_x),
    .round_mode(round_mode),
    .cancel(1'b0),
    .in_ready(),
    .out_valid(div_inst2_out_valid),
    .out(x_div_one_plus_x),
    .exceptions()
    //.exceptions(div_exceptions_2)
  );
    
  // 5. Calculate  1 + (-x/(1-x))
  add_sub  add_sub_inst3(
    .in_x(one_val),
    .in_y(x_div_one_minus_x),
    .operation(1'b0), // addition
    .round_mode(round_mode),
    .out_z(term1),
    .exceptions()
     //.exceptions(sub_exceptions_2)
  );
// 1 + (x/(1+x)) 
  add_sub  add_sub_inst4(
    .in_x(one_val),
    .in_y(x_div_one_plus_x),
    .operation(1'b0), // addition
    .round_mode(round_mode),
    .out_z(term2),
    .exceptions()
    //.exceptions(sub_exceptions_2)
  );
    

  // 6. Multiply by 0.5
  multiplier #( .exp_width(exp_width), .mant_width(mant_width)) 
  mul_inst1(
    .a(half_val),
    .b(term1),
    .round_mode(round_mode),
    .exceptions(),
   // .exceptions(mul_exceptions_1),
    .out(term1_pre)
  );
  
  //7. term1_final = 1- 0.5(1 + -x/(1-x))
   add_sub  add_sub_inst5(
    .in_x(one_val),
    .in_y(term1_pre),
    .operation(1'b1), // subtraction
    .round_mode(round_mode),
    .out_z(term1_final),
    .exceptions()
   // .exceptions()
  );

  multiplier #( .exp_width(exp_width), .mant_width(mant_width)) 
  mul_inst2(
    .a(half_val),
    .b(term2),
    .round_mode(round_mode),
   // .exceptions(mul_exceptions_2),
   .exceptions(),
    .out(term2_final)
  );

  // 7. Conditional Assignment to output based on x sign
  assign out_sigmoid_not_stbl = (x_is_negative) ? term1_final : term2_final; 

  //  Consolidated Error Output
 // assign exceptions = add_exceptions | sub_exceptions_1 | sub_exceptions_2 | div_exceptions_1 | div_exceptions_2 | mul_exceptions_1 | mul_exceptions_2;
  assign out_valid = (x_is_negative) ? div_inst1_out_valid : div_inst2_out_valid;
  
endmodule
