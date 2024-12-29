`include "../rtl/matrix_multiply_1x2_2x1.sv"
`timescale 1ns / 1ps

module testbench;

    // Parameters for the floating-point format
    parameter exp_width = 8;
    parameter mant_width = 24;

    // Calculate the data width for the floating-point numbers
    parameter data_width = exp_width + mant_width;


    // Inputs for the matrix multiply module
    logic [data_width-1:0] a11, a12;
    logic [data_width-1:0] b1, b2;
    logic [2:0]           round_mode;
     logic clk;


    // Outputs from the matrix multiply module
    logic [data_width-1:0] c1;
    logic [4:0] exceptions;

    // Instantiate the matrix multiply module
    matrix_multiply_1x2_2x1 #(
        .exp_width(exp_width),
        .mant_width(mant_width)
    ) dut (
        .a11(a11),
        .a12(a12),
        .b1(b1),
        .b2(b2),
        .round_mode(round_mode),
        .c1(c1),
         .exceptions(exceptions)
    );
     initial begin
        // Initialize clock
        clk = 0;
        forever #5 clk = ~clk;
    end
    initial begin
       // Round to nearest even
        round_mode = 3'b000;

        // Set matrix A values: [2, 1.5]
        a11 = 32'h40000000;   // 2.0
        a12 = 32'h3fc00000;   // 1.5


        // Set matrix B values: [1, 2]
        b1  = 32'h3f800000;   // 1.0
        b2  = 32'h40000000;   // 2.0

        // Wait a little for calculations to complete
        #100;

       
        // Display inputs and result
        $display("Test Case Results:");
        $display("Matrix A = [[%h, %h]]", a11, a12);
        $display("Matrix B = [[%h], [%h]]", b1, b2);
        $display("Matrix C = [[%h]]", c1);
        $display("Exceptions = %b", exceptions);
        
        // End the simulation
        $finish;
    end

endmodule
