`include "fpu_lib.sv"
`include "add_sub.sv"
`include "multiplier.sv"
`include "divider.sv"
`include "matrix_multiply_1x2_2x1.sv"
`include "matrix_multiply_2x2_2x1.sv"
`include "sigmoid_v5.sv"

module NN #(
    parameter exp_width = 8,
    parameter mant_width = 24
) (
    // Inputs: Weights and Biases
    input wire [(exp_width + mant_width - 1):0] w11,
    input wire [(exp_width + mant_width - 1):0] w12,
    input wire [(exp_width + mant_width - 1):0] w21,
    input wire [(exp_width + mant_width - 1):0] w22,
    input wire [(exp_width + mant_width - 1):0] b1,
    input wire [(exp_width + mant_width - 1):0] b2,
    input wire [(exp_width + mant_width - 1):0] w31,
    input wire [(exp_width + mant_width - 1):0] w32,
    input wire [(exp_width + mant_width - 1):0] b3,

    // Inputs: User inputs A and B
    input wire [(exp_width + mant_width - 1):0] A,
    input wire [(exp_width + mant_width - 1):0] B,
    input wire clk,
    input wire rst_l,
     input wire [2:0] round_mode,

    // Output: XOR result
    output wire  [(exp_width + mant_width - 1):0] XOR_output
    //output wire  [4:0] exceptions
);

    // Internal Wires for Hidden Layer
    wire [(exp_width + mant_width - 1):0] h1_pre_sigmoid;
    wire [(exp_width + mant_width - 1):0] h2_pre_sigmoid;
    wire [(exp_width + mant_width - 1):0] h1_out;
    wire [(exp_width + mant_width - 1):0] h2_out;
    wire [(exp_width + mant_width - 1):0] output_pre_sigmoid;
    wire [(exp_width + mant_width - 1):0] output_pre_sigmoid_and_bias;
    //wire [4:0] exceptions_mm1,exceptions_mm2,exceptions_sig1,exceptions_sig2,exceptions_add1,exceptions_add2, exceptions_add3,exceptions_sig3;
    wire out_valid_sig1,out_valid_sig2,out_valid_sig3;
    wire [(exp_width + mant_width - 1):0] intermediate_add1;
    wire [(exp_width + mant_width - 1):0] intermediate_add2;
    //wire [4:0] exceptions_total;



    
    //assign exceptions_total = exceptions_mm1 | exceptions_mm2 | exceptions_sig1|exceptions_sig2 | exceptions_add1|exceptions_add2|exceptions_add3|exceptions_sig3;
    
    //assign exceptions = exceptions_total;


    // Instantiate matrix multiplication module for the first layer
    matrix_multiply_2x2_2x1 #(
        .exp_width(exp_width),
        .mant_width(mant_width)
    ) mm_layer1 (
        .a11(w11),
        .a12(w12),
        .a21(w21),
        .a22(w22),
        .b1(A),
        .b2(B),
        .round_mode(round_mode),
        .c1(intermediate_add1),
        .c2(intermediate_add2),
        .exceptions()
        //.exceptions(exceptions_mm1)
    );
    
       add_sub #(
       ) add_bias_1 (
            .in_x(intermediate_add1),
            .in_y(b1),
            .operation(1'b0),
            .round_mode(round_mode),
            .out_z(h1_pre_sigmoid),
        	.exceptions()
            //.exceptions(exceptions_add1)
       );

       add_sub #(
       ) add_bias_2 (
           .in_x(intermediate_add2),
           .in_y(b2),
           .operation(1'b0),
           .round_mode(round_mode),
           .out_z(h2_pre_sigmoid),
	.exceptions()
          // .exceptions(exceptions_add2)
       );

    // Instantiate sigmoid activation function for the first hidden neuron
    sigmoid_approx #(
        .exp_width(exp_width),
        .mant_width(mant_width)
    ) sigmoid_h1 (
        .in_x(h1_pre_sigmoid),
        .clk(clk),
        .rst_l(rst_l),
        .round_mode(round_mode),
        .out_sigmoid(h1_out),
        .exceptions(),
        //.exceptions(exceptions_sig1)
        .out_valid(out_valid_sig1)
    );

    // Instantiate sigmoid activation function for the second hidden neuron
    sigmoid_approx #(
         .exp_width(exp_width),
         .mant_width(mant_width)
    ) sigmoid_h2 (
        .in_x(h2_pre_sigmoid),
        .clk(clk),
        .rst_l(rst_l),
        .round_mode(round_mode),
        .out_sigmoid(h2_out),
        .exceptions(),
         //.exceptions(exceptions_sig2)
         .out_valid(out_valid_sig2)
     );

    // Instantiate matrix multiplication module for the second layer
        matrix_multiply_1x2_2x1 #(
        .exp_width(exp_width),
        .mant_width(mant_width)
     ) mm_layer2 (
        .a11(w31),
        .a12(w32),
        .b1(h1_out),
        .b2(h2_out),
        .round_mode(round_mode),
        .c1(output_pre_sigmoid),
        .exceptions()
        //.exceptions(exceptions_mm2)
    );
        
     add_sub #(
       ) add_bias_3 (
           .in_x(output_pre_sigmoid),
           .in_y(b3),
           .operation(1'b0),
           .round_mode(round_mode),
           .out_z(output_pre_sigmoid_and_bias),
           .exceptions()
           //.exceptions(exceptions_add1)
       );

    // Instantiate sigmoid activation function for the output neuron
    sigmoid_approx #(
        .exp_width(exp_width),
        .mant_width(mant_width)
    ) sigmoid_out (
        .in_x(output_pre_sigmoid_and_bias),
        .clk(clk),
        .rst_l(rst_l),
        .round_mode(round_mode),
        .out_sigmoid(XOR_output),
        .exceptions(),
        //.exceptions(exceptions_sig3)
        .out_valid(out_valid_sig3)
    );



endmodule
