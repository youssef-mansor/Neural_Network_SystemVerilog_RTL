`include "fpu_lib.sv"
`include "add_sub.sv"
`include "multiplier.sv"
`include "divider.sv"
`include "matrix_multiply_1x2_2x1.sv"
`include "matrix_multiply_2x2_2x1.sv"
`include "sigmoid_v5.sv"
`include "NN_registers.sv"

module NN #(
    parameter exp_width = 8,
    parameter mant_width = 24
) (
    input wire clk,
    input wire rst_l,
    input wire [2:0] round_mode,
    input wire in_valid_user, //set by the user and will make wire in_valid_pulse be high for one cycle
    
    // Memory
    input wire [31:0] wbs_adr_i, // Caravel: user_proj_example 
    input wire [31:0] wbs_dat_i, // Caravel: user_proj_example 
    input wire  wren, // Caravel: user_proj_example look at it as wren for the csrs
    

    output wire  [(exp_width + mant_width - 1):0] NN_result,
    output wire wbs_ack_o,
    output wire [31:0] wbs_dat_o                // read  data sent to wb    
);
    //after 54 cycles of stable input ready is set to high it denotes when denote when the NN_result is valid
    reg ready;   
    // Inputs, Weights and Biases
    wire [(exp_width + mant_width - 1):0] A;
    wire [(exp_width + mant_width - 1):0] B;
    wire [(exp_width + mant_width - 1):0] w11;
    wire [(exp_width + mant_width - 1):0] w12;
    wire [(exp_width + mant_width - 1):0] w21;
    wire [(exp_width + mant_width - 1):0] w22;
    wire [(exp_width + mant_width - 1):0] b1;
    wire [(exp_width + mant_width - 1):0] b2;
    wire [(exp_width + mant_width - 1):0] w31;
    wire [(exp_width + mant_width - 1):0] w32;
    wire [(exp_width + mant_width - 1):0] b3;
    // NN_result holds the temporary result before it is stabilized (last sequential divider finishes its operations)
    wire  [(exp_width + mant_width - 1):0] final_res;    
    wire [(exp_width + mant_width - 1):0] int_wbs_dat_o;
    assign wbs_dat_o = wren? 32'h00000000: int_wbs_dat_o; //if writting is enabled you can not read data


    // Generate in_valid_pulse (pulse for one clock cycle)
    reg in_valid_user_d; // Delayed signal to detect rising edge
    reg in_valid_pulse;  // Pulse signal
    always @(posedge clk or negedge rst_l) begin
        if (~rst_l) begin
            in_valid_user_d <= 1'b0;
            in_valid_pulse <= 1'b0;
        end else begin
            in_valid_user_d <= in_valid_user;
            in_valid_pulse <= in_valid_user & ~in_valid_user_d;
        end
    end
    
    // Counter to track how many out_valid signals are high
    reg [1:0] out_valid_counter; // 2-bit counter

    always @(posedge clk or negedge rst_l) begin
        if (~rst_l) begin
            out_valid_counter <= 2'b00;
        end else begin
            if (out_valid_sig1) begin
                out_valid_counter[0] <= 1'b1; // Signal 1 is high
            end
            if (out_valid_sig2) begin
                out_valid_counter[1] <= 1'b1; // Signal 2 is high
            end
        end
    end

    // Generate in_valid_sig3 pulse when counter reaches 2
    reg in_valid_sig3;

    always @(posedge clk or negedge rst_l) begin
        if (~rst_l) begin
            in_valid_sig3 <= 1'b0;
        end else begin
            if (out_valid_counter == 2'b11) begin // Both signals are high
                in_valid_sig3 <= 1'b1;  // Pulse in_valid_sig3
                out_valid_counter[0] <= 1'b0; // Signal 1 is low
                out_valid_counter[1] <= 1'b0; // Signal 2 is low
            end else begin
                in_valid_sig3 <= 1'b0;  // Reset pulse after one cycle
            end
        end
    end



    NN_registers u_NN_registers (
    .clk      (clk),  // Input: Clock signal
    .rst_l    (rst_l),  // Input: Active-low reset signal
    .wbs_adr_i     (wbs_adr_i),  // Input: Address
    .wren     (wren),  // Input: Write enable
    .wbs_dat_i   (wbs_dat_i),  // Input: Write data

    .wbs_ack_o      (wbs_ack_o),  // Output: Acknowledge signal
    .wbs_dat_o   (int_wbs_dat_o),  // Output: Read data
    .opA      (A),  // Output: Operand A
    .opB      (B),  // Output: Operand B
    .w11      (w11),  // Output: Weight w11
    .w12      (w12),  // Output: Weight w12
    .w21      (w21),  // Output: Weight w21
    .w22      (w22),  // Output: Weight w22
    .b1       (b1),  // Output: Bias b1
    .b2       (b2),  // Output: Bias b2
    .w31      (w31),  // Output: Weight w31
    .w32      (w32),  // Output: Weight w32
    .b3       (b3)   // Output: Bias b3
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
        .c2(intermediate_add2)
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
        .in_valid(in_valid_pulse),
        .out_sigmoid(h1_out),
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
        .in_valid(in_valid_pulse),
        .out_sigmoid(h2_out),
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
        .c1(output_pre_sigmoid)
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
        .in_valid(in_valid_sig3),
        .out_sigmoid(NN_result),
        //.exceptions(exceptions_sig3)
        .out_valid(ready)
    );
    
endmodule
