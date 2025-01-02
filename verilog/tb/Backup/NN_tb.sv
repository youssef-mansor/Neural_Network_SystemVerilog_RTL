`include "../rtl/NN.sv"
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
    //wire [4:0] exceptions;
    wire ready;

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
        .ready(ready)
        //.exceptions(exceptions)
    );
    
    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;

    initial begin
        // Initialize inputs
        clk = 0;
        rst_l = 0;
        round_mode = 3'b000;
        #2 rst_l = 1;


    w11 = 32'h40800000;  // 4.0
    w12 = 32'h40800000;  // 4.0
    w21 = 32'hc0800000;  // -4.0
    w22 = 32'hc0800000;  // -4.0
    b1  = 32'hc0000000;   // -2.0
    b2  = 32'h40c00000;   // 6.0
    w31 = 32'h40800000;  // 4.0
    w32 = 32'h40800000;  // 4.0
    b3  = 32'hc0c00000;   // -6.0
        

        $display("-------------------------------------------------------------------------");
        $display("| A Value      | B Value      |  XOR Output  | Output > 0.5 |");
        $display("-------------------------------------------------------------------------");

        // Test cases for XOR
        A = 32'h00000000; B = 32'h00000000; #640;  $display("| %h    | %h    | %h   | %d      |",   A,  B, XOR_output, XOR_output > 32'h3f000000 ? 1 : 0);
        A = 32'h00000000; B = 32'h3f800000; #640;  $display("| %h    | %h    | %h   | %d      |",  A, B,  XOR_output, XOR_output > 32'h3f000000 ? 1 : 0);
        A = 32'h3f800000; B = 32'h00000000; #640;   $display("| %h    | %h    | %h   | %d      |", A,  B, XOR_output, XOR_output > 32'h3f000000 ? 1 : 0);
        A = 32'h3f800000; B = 32'h3f800000; #640;   $display("| %h    | %h    | %h   | %d      |", A,  B, XOR_output, XOR_output > 32'h3f000000 ? 1 : 0);
         $display("-------------------------------------------------------------------------");
        $finish;
    end
    
      initial begin
    $dumpfile("../sim/NN_tb.vcd");
    $dumpvars(0, NN_tb);
  end

endmodule
