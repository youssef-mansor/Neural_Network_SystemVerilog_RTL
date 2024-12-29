//`include "fpu_lib.sv"
//`include "add_sub.sv"
//`include "multiplier.sv"
//`include "dot_product.sv"

module matrix_multiply_1x2_2x1 #(
    parameter exp_width = 8,
    parameter mant_width = 24
) (
    input  wire [(exp_width + mant_width-1):0] a11,
    input  wire [(exp_width + mant_width-1):0] a12,
    input  wire [(exp_width + mant_width-1):0] b1,
    input  wire [(exp_width + mant_width-1):0] b2,
    input  wire [2:0]                          round_mode,
    
    output wire [(exp_width + mant_width-1):0] c1
    // output wire [4:0]                         exceptions // combined exceptions from all operations

);

    // Internal signals for intermediate values and connections
    wire [(exp_width + mant_width)-1:0] p11, p12;
    //wire [4:0]                          mult_exceptions_11, mult_exceptions_12;
    wire [(exp_width + mant_width-1):0] temp_c1;
   // wire [4:0]                          add_exceptions_c1;

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
    
    // Instantiate adders
    add_sub add_c1 (
        .in_x(p11),
        .in_y(p12),
        .operation(1'b0), // 0 for add, 1 for sub
        .round_mode(round_mode),
        .out_z(temp_c1),
       // .exceptions(add_exceptions_c1)
        .exceptions()
    );
   

    assign c1 = temp_c1;
     // Combine exceptions using a bitwise OR operation
   // assign exceptions = mult_exceptions_11 | mult_exceptions_12 | add_exceptions_c1 ;


endmodule
