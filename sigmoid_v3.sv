`include "fpu_lib.sv"
`include "add_sub.sv"
`include "multiplier.sv"
`include "divider.sv"

module sigmoid_approx #(parameter exp_width = 8, parameter mant_width = 24)
(
    input  wire [(exp_width + mant_width - 1):0] in_x,
    input  wire                                   clk,
    input  wire                                   rst_l,
    input wire [2:0] round_mode,
    
    output wire [(exp_width + mant_width - 1):0] out_sigmoid,
    output wire [4:0] exceptions
    //input in_valid
    //out in_ready //
    //out out_valid
    //instead of calculating the two terms just one term
);

  // Internal Wires for intermediate calculations
  wire [(exp_width + mant_width - 1):0] x_neg;
  wire [(exp_width + mant_width - 1):0] one_minus_x;
  wire [(exp_width + mant_width - 1):0] one_plus_x;

  // Division stage wires and registers
  wire [(exp_width + mant_width - 1):0] x_div_one_minus_x;
  wire [(exp_width + mant_width - 1):0] x_div_one_plus_x;
  reg  [(exp_width + mant_width - 1):0] x_div_one_minus_x_reg;
  reg  [(exp_width + mant_width - 1):0] x_div_one_plus_x_reg;
  wire div_inst1_out_valid, div_inst2_out_valid;
  reg  div_inst1_valid_reg, div_inst2_valid_reg;
    
  // After Division Stage
  wire [(exp_width + mant_width - 1):0] term1;
  wire [(exp_width + mant_width - 1):0] term2;
  wire [(exp_width + mant_width - 1):0] half_val;
  wire [(exp_width + mant_width - 1):0] one_val;
  wire                                  x_is_negative;

  // Error exception wires
  wire [4:0] add_exceptions, sub_exceptions_1, sub_exceptions_2, div_exceptions_1, div_exceptions_2, mul_exceptions_1, mul_exceptions_2;
  
    //  Assigning floating point values for 0.5 and 1
  assign half_val = 32'h3f000000; // 0.5 in FP representation
  assign one_val =  32'h3f800000;  // 1.0 in FP representation
  
  // 1. Determine if x is negative (sign bit check)
  assign x_is_negative = in_x[(exp_width + mant_width - 1)];

  // 2. Calculate -x if x is negative, else just x for positive case 
  assign x_neg = (x_is_negative)? ({1'b0,in_x[(exp_width + mant_width - 2) : 0] }):in_x; // For negative, flip the sign bit and use positive value.

  // 3. Calculate 1 - x (or 1 + x, based on sign)
   add_sub  add_sub_inst1(
    .in_x(one_val),
    .in_y(x_neg),
    .operation(1'b0), // operation = 0 for addition 
    .round_mode(round_mode),
    .out_z(one_minus_x),
    .exceptions(sub_exceptions_1)
  );
   add_sub  add_sub_inst2(
    .in_x(one_val),
    .in_y(in_x),
    .operation(1'b0),
    .round_mode(round_mode),
    .out_z(one_plus_x),
    .exceptions(add_exceptions)
   );


  // 4. Calculate -x / (1-x)
  divider #( .exp_width(exp_width), .mant_width(mant_width)) 
   div_inst1 (
    .rst_l(rst_l),
    .clk(clk),
    .in_valid(1'b1),
    .a(x_neg),
    .b(one_minus_x),
    .round_mode(round_mode),
    .cancel(1'b0),
    .in_ready(),
    .out_valid(div_inst1_out_valid),
    .out(x_div_one_minus_x),
    .exceptions(div_exceptions_1)
  );
  //calculate x / 1 + x
  divider #( .exp_width(exp_width), .mant_width(mant_width)) 
    div_inst2(
    .rst_l(rst_l),
    .clk(clk),
    .in_valid(1'b1),
    .a(in_x),
    .b(one_plus_x),
    .round_mode(round_mode),
    .cancel(1'b0),
    .in_ready(),
    .out_valid(div_inst2_out_valid),
    .out(x_div_one_plus_x),
    .exceptions(div_exceptions_2)
  );
    
  // Register the output of divider once valid.
  always @(posedge clk or negedge rst_l) begin
    if(!rst_l) begin
        x_div_one_minus_x_reg <= 0;
        x_div_one_plus_x_reg <= 0;
        div_inst1_valid_reg <= 0;
        div_inst2_valid_reg <= 0;
    end else begin
        if(div_inst1_out_valid) begin
           x_div_one_minus_x_reg <= x_div_one_minus_x;
           div_inst1_valid_reg <= 1;
        end else if (div_inst1_valid_reg) begin
           div_inst1_valid_reg <= 0;
        end

        if(div_inst2_out_valid) begin
           x_div_one_plus_x_reg <= x_div_one_plus_x;
           div_inst2_valid_reg <= 1;
        end else if (div_inst2_valid_reg) begin
           div_inst2_valid_reg <= 0;
        end
    end
  end

  // 5. Calculate  1 + (x/(1-x)) or 1 + (x/(1+x)) based on sign
  add_sub  add_sub_inst3(
    .in_x(one_val),
    .in_y(x_div_one_minus_x_reg),
    .operation(1'b0), // addition
    .round_mode(round_mode),
    .out_z(term1),
     .exceptions(sub_exceptions_2)
  );

  add_sub  add_sub_inst4(
    .in_x(one_val),
    .in_y(x_div_one_plus_x_reg),
    .operation(1'b0), // addition
    .round_mode(round_mode),
    .out_z(term2),
    .exceptions(sub_exceptions_2)
  );
    

  // 6. Multiply by 0.5
  multiplier #( .exp_width(exp_width), .mant_width(mant_width)) 
  mul_inst1(
    .a(half_val),
    .b(term1),
    .round_mode(round_mode),
    .exceptions(mul_exceptions_1),
    .out(term1)
  );

  multiplier #( .exp_width(exp_width), .mant_width(mant_width)) 
  mul_inst2(
    .a(half_val),
    .b(term2),
    .round_mode(round_mode),
    .exceptions(mul_exceptions_2),
    .out(term2)
  );

  // 7. Conditional Assignment to output based on x sign
  assign out_sigmoid = (x_is_negative) ? term1 : term2; 

  //  Consolidated Error Output
  assign exceptions = add_exceptions | sub_exceptions_1 | sub_exceptions_2 | div_exceptions_1 | div_exceptions_2 | mul_exceptions_1 | mul_exceptions_2;
  
endmodule
