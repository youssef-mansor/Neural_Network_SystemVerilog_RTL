//`include "fpu_lib.sv"
//`include "add_sub.sv"
//`include "multiplier.sv"
//`include "dot_product.sv"

module matrix_multiply_2x2_2x1 #(
    parameter exp_width = 8,
    parameter mant_width = 24
) (
    input  wire [(exp_width + mant_width-1):0] a11,
    input  wire [(exp_width + mant_width-1):0] a12,
    input  wire [(exp_width + mant_width-1):0] a21,
    input  wire [(exp_width + mant_width-1):0] a22,
    input  wire [(exp_width + mant_width-1):0] b1,
    input  wire [(exp_width + mant_width-1):0] b2,
    input  wire [2:0]                          round_mode,
    
    output wire [(exp_width + mant_width-1):0] c1,
    output wire [(exp_width + mant_width-1):0] c2
    //output wire [4:0]                         exceptions // combined exceptions from all operations
);
    
    // Internal signals for intermediate values and connections
    wire [(exp_width + mant_width)-1:0] p11, p12, p21, p22;
   // wire [4:0]                          mult_exceptions_11, mult_exceptions_12, mult_exceptions_21, mult_exceptions_22;
    wire [(exp_width + mant_width-1):0] temp_c1, temp_c2;
   // wire [4:0]                          add_exceptions_c1, add_exceptions_c2;
    
    // Instantiate multipliers
    multiplier #(
        .exp_width(exp_width),
        .mant_width(mant_width)
    ) mult11 (
        .a(a11),
        .b(b1),
        .round_mode(round_mode),
        //.exceptions(mult_exceptions_11),
        .exceptions(),
        .out(p11)
    );
    
    multiplier #(
        .exp_width(exp_width),
        .mant_width(mant_width)
    ) mult12 (
        .a(a12),
        .b(b2),
        .round_mode(round_mode),
        //.exceptions(mult_exceptions_12),
        .exceptions(),
        .out(p12)
    );

     multiplier #(
        .exp_width(exp_width),
        .mant_width(mant_width)
    ) mult21 (
        .a(a21),
        .b(b1),
        .round_mode(round_mode),
        //.exceptions(mult_exceptions_21),
        .exceptions(),
        .out(p21)
    );
    
    multiplier #(
        .exp_width(exp_width),
        .mant_width(mant_width)
    ) mult22 (
        .a(a22),
        .b(b2),
        .round_mode(round_mode),
        //.exceptions(mult_exceptions_22),
        .exceptions(),
        .out(p22)
    );
    
    // Instantiate adders
    add_sub add_c1 (
        .in_x(p11),
        .in_y(p12),
        .operation(1'b0), // 0 for add, 1 for sub
        .round_mode(round_mode),
        .out_z(temp_c1),
        .exceptions()
        //.exceptions(add_exceptions_c1)
    );
    
     add_sub add_c2 (
        .in_x(p21),
        .in_y(p22),
        .operation(1'b0), // 0 for add, 1 for sub
        .round_mode(round_mode),
        .out_z(temp_c2),
        .exceptions()
        //.exceptions(add_exceptions_c2)
    );


     assign c1 = temp_c1;
     assign c2 = temp_c2;

     // Combine exceptions using a bitwise OR operation
    //assign exceptions = mult_exceptions_11 | mult_exceptions_12 | mult_exceptions_21 | mult_exceptions_22 | add_exceptions_c1 | add_exceptions_c2;
    

endmodule
