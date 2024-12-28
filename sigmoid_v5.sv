//`include "fpu_lib.sv"
//`include "add_sub.sv"
//`include "multiplier.sv"
//`include "divider.sv"

module sigmoid_approx #(parameter exp_width = 8, parameter mant_width = 24)
(
    input  wire [(exp_width + mant_width - 1):0] in_x,
    input  wire                                   clk,
    input  wire                                   rst_l,
    input wire [2:0] round_mode,
    
    output wire [(exp_width + mant_width - 1):0] out_sigmoid,
    output wire [4:0] exceptions,
    output wire out_valid //indicates when output is ready because calculations take multiple cycles
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
  reg  div_inst1_in_valid, div_inst2_in_valid;
  reg  [(exp_width + mant_width - 1):0] in_x_reg;
    
  // After Division Stage
  wire [(exp_width + mant_width - 1):0] term1;
  wire [(exp_width + mant_width - 1):0] term2;
  wire [(exp_width + mant_width - 1):0] term1_pre;
  wire [(exp_width + mant_width - 1):0] term1_final;
  wire [(exp_width + mant_width - 1):0] term2_final;
  wire [(exp_width + mant_width - 1):0] half_val;
  wire [(exp_width + mant_width - 1):0] one_val;
  wire                                  x_is_negative;
  
  // Counters to keep div_inst*_in_valid high for two cycles
  reg [1:0] div_inst1_in_valid_counter;
  reg [1:0] div_inst2_in_valid_counter;

  // Error exception wires
  wire [4:0] add_exceptions, sub_exceptions_1, sub_exceptions_2, div_exceptions_1, div_exceptions_2, mul_exceptions_1, mul_exceptions_2;
  
    //  Assigning floating point values for 0.5 and 1
  assign half_val = 32'h3f000000; // 0.5 in FP representation
  assign one_val =  32'h3f800000;  // 1.0 in FP representation
  
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
    .exceptions(sub_exceptions_1)
  );
  //(or 1 + x, based on sign)
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
    .in_valid(div_inst1_in_valid),
    .a(x_neg),
    .b(one_minus_x),
    .round_mode(round_mode),
    .cancel(1'b0),
    .in_ready(),
    .out_valid(div_inst1_out_valid),
    .out(x_div_one_minus_x),
    .exceptions(div_exceptions_1)
  );
//and x / (1+x)
  divider #( .exp_width(exp_width), .mant_width(mant_width)) 
    div_inst2(
    .rst_l(rst_l),
    .clk(clk),
    .in_valid(div_inst2_in_valid),
    .a(in_x),
    .b(one_plus_x),
    .round_mode(round_mode),
    .cancel(1'b0),
    .in_ready(),
    .out_valid(div_inst2_out_valid),
    .out(x_div_one_plus_x),
    .exceptions(div_exceptions_2)
  );
    
// Register the output of divider once valid
always @(posedge clk or negedge rst_l) begin
    if (!rst_l) begin
        x_div_one_minus_x_reg <= 0;
        x_div_one_plus_x_reg <= 0;
        div_inst1_in_valid <= 0;
        div_inst2_in_valid <= 0;
        div_inst1_in_valid_counter <= 0;
        div_inst2_in_valid_counter <= 0;
        in_x_reg <= 0;
    end else begin
        // Detect a new input to start the process
        if (in_x != in_x_reg) begin
            div_inst1_in_valid <= 1;
            div_inst2_in_valid <= 1;
            div_inst1_in_valid_counter <= 2; // Set counter for 2 cycles
            div_inst2_in_valid_counter <= 2; // Set counter for 2 cycles
            in_x_reg <= in_x;
        end

        // Handle counters for div_inst1_in_valid
        if (div_inst1_in_valid_counter > 0) begin
            div_inst1_in_valid_counter <= div_inst1_in_valid_counter - 1;
        end
        if (div_inst1_in_valid_counter == 1) begin
            div_inst1_in_valid <= 0;
        end

        // Handle counters for div_inst2_in_valid
        if (div_inst2_in_valid_counter > 0) begin
            div_inst2_in_valid_counter <= div_inst2_in_valid_counter - 1;
        end
        if (div_inst2_in_valid_counter == 1) begin
            div_inst2_in_valid <= 0;
        end

        // Capture the outputs of the dividers when valid
        if (div_inst1_out_valid) begin
            x_div_one_minus_x_reg <= x_div_one_minus_x;
        end

        if (div_inst2_out_valid) begin
            x_div_one_plus_x_reg <= x_div_one_plus_x;
        end
    end
end
  // 5. Calculate  1 + (-x/(1-x))
  add_sub  add_sub_inst3(
    .in_x(one_val),
    .in_y(x_div_one_minus_x_reg),
    .operation(1'b0), // addition
    .round_mode(round_mode),
    .out_z(term1),
     .exceptions(sub_exceptions_2)
  );
// 1 + (x/(1+x)) 
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
  );

  multiplier #( .exp_width(exp_width), .mant_width(mant_width)) 
  mul_inst2(
    .a(half_val),
    .b(term2),
    .round_mode(round_mode),
    .exceptions(mul_exceptions_2),
    .out(term2_final)
  );

  // 7. Conditional Assignment to output based on x sign
  assign out_sigmoid = (x_is_negative) ? term1_final : term2_final; 

  //  Consolidated Error Output
  assign exceptions = add_exceptions | sub_exceptions_1 | sub_exceptions_2 | div_exceptions_1 | div_exceptions_2 | mul_exceptions_1 | mul_exceptions_2;
  assign out_valid = (x_is_negative) ? div_inst1_out_valid : div_inst2_out_valid;
  
endmodule
