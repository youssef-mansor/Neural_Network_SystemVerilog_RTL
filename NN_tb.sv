`include "NN.sv"
module NN_tb;

    // Parameters for floating-point representation
    parameter exp_width = 8;
    parameter mant_width = 24;
    parameter data_width = exp_width + mant_width;

    // Inputs
    reg [data_width-1:0] w11, w12, w21, w22, b1, b2, w31, w32, b3, A, B;
    reg clk, rst_l;
    reg [2:0] round_mode;

    // Outputs
    wire [data_width-1:0] XOR_output;
    wire [4:0] exceptions;

    // Clock period
    parameter CLK_PERIOD = 10;

    // Instantiate the NN module
    NN #(
        .exp_width(exp_width),
        .mant_width(mant_width)
    ) dut (
        .w11(w11),
        .w12(w12),
        .w21(w21),
        .w22(w22),
        .b1(b1),
        .b2(b2),
        .w31(w31),
        .w32(w32),
        .b3(b3),
        .A(A),
        .B(B),
        .clk(clk),
        .rst_l(rst_l),
        .round_mode(round_mode),
        .XOR_output(XOR_output),
        .exceptions(exceptions)
    );
    
    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;

    initial begin
        // Initialize inputs
        clk = 0;
        rst_l = 0;
        round_mode = 3'b000;
        #2 rst_l = 1;


        w11 = 32'h3f800000;  //1.0
        w21 = 32'h3f800000;   //1.0
        w12 = 32'h3f800000;  //1.0
        w22 = 32'h3f800000;  //1.0
        w31 = 32'h3f800000;  //1.0
        w32 = 32'h3f800000;  //1.0
        b1  = 32'h3f000000; //0.5
        b2  = 32'hbfc00000; //-1.5
        b3  = 32'hbf800000; //-1.0
        

        $display("-------------------------------------------------------------------------");
        $display("| A Value      | B Value      |  XOR Output  | HEX Output     |");
        $display("--------------------------------------------------------------------------");

        // Test cases for XOR
        A = 32'h00000000; B = 32'h00000000; #320;  $display("| %h    | %h    | %h   | %h      |",   A,  B, XOR_output, XOR_output);
        A = 32'h00000000; B = 32'h3f800000; #320;  $display("| %h    | %h    | %h   | %h      |",  A, B,  XOR_output, XOR_output);
        A = 32'h3f800000; B = 32'h00000000;  #320;   $display("| %h    | %h    | %h   | %h      |", A,  B, XOR_output, XOR_output);
        A = 32'h3f800000; B = 32'h3f800000;  #320;   $display("| %h    | %h    | %h   | %h      |", A,  B, XOR_output, XOR_output);
         $display("-------------------------------------------------------------------------");
        $finish;
    end
    
      initial begin
    $dumpfile("NN_tb.vcd");
    $dumpvars(0, NN_tb);
  end

endmodule