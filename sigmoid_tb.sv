`include "sigmoid.sv" // Include the sigmoid module definition

module sigmoid_tb;

  // Signals
  logic [31:0] in_x;
  logic [2:0] round_mode;
  logic [31:0] out_sigmoid;
  wire [4:0] exceptions;


  // Instantiate the module
  sigmoid dut (
    .in_x(in_x),
    .round_mode(round_mode),
    .out_sigmoid(out_sigmoid),
    .exceptions(exceptions)
  );

  initial begin
    // Set round mode (e.g., round to nearest even)
    round_mode = 3'b000;

    $display("--------------------------------------------------");
    $display("Test Case | Input (Hex) | Sigmoid (Hex) | Exceptions");
    $display("--------------------------------------------------");

    // Test cases with x between -4 and 4
        in_x = 32'h40800000; //  4.0
        #10;
        $display("       %8h    |    %8h    |      %5b     ",
                   in_x, out_sigmoid, exceptions);
        in_x = 32'h40000000; //  2.0
        #10;
        $display("       %8h    |    %8h    |      %5b     ",
                   in_x, out_sigmoid, exceptions);
        in_x = 32'h3fb00000; //   1.0
        #10;
        $display("       %8h    |    %8h    |      %5b     ",
                   in_x, out_sigmoid, exceptions);
        in_x = 32'h3f800000; //  0.0
        #10;
         $display("       %8h    |    %8h    |      %5b     ",
                    in_x, out_sigmoid, exceptions);
        in_x = 32'hbf800000; // -1.0
        #10;
         $display("       %8h    |    %8h    |      %5b     ",
                    in_x, out_sigmoid, exceptions);

        in_x = 32'hc0000000; // -2.0
        #10;
        $display("       %8h    |    %8h    |      %5b     ",
                    in_x, out_sigmoid, exceptions);
        in_x = 32'hc0800000; // -4.0
        #10;
        $display("       %8h    |    %8h    |      %5b     ",
                   in_x, out_sigmoid, exceptions);

         in_x = 32'h40700000; //  3.0
        #10;
        $display("       %8h    |    %8h    |      %5b     ",
                   in_x, out_sigmoid, exceptions);
        in_x = 32'h3fa00000; //  1.25
        #10;
         $display("       %8h    |    %8h    |      %5b     ",
                    in_x, out_sigmoid, exceptions);
        in_x = 32'hbf000000; // -0.5
        #10;
        $display("       %8h    |    %8h    |      %5b     ",
                     in_x, out_sigmoid, exceptions);
    $finish;
  end

endmodule
