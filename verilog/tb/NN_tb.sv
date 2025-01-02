`include "../rtl/NN.sv"
module NN_tb;

    // Parameters for the floating-point representation
    parameter exp_width = 8;
    parameter mant_width = 24;

    // Testbench signals
    reg clk;
    reg rst_l;
    reg [2:0] round_mode;
    reg in_valid_user;
    reg [31:0] wbs_adr_i;  // Address input for writes/reads
    reg [31:0] wbs_dat_i;      // Data input for writes
    reg wren;             // Write enable signal
    
    wire [(exp_width + mant_width - 1):0] NN_result; // Final result output
    wire wbs_ack_o;        // Acknowledge signal
    wire [31:0] wbs_dat_o;    // Read data

    // Instantiate the NN module
    NN #(
        .exp_width(exp_width),
        .mant_width(mant_width)
    ) uut (
        .clk(clk),
        .rst_l(rst_l),
        .round_mode(round_mode),
        .in_valid_user(in_valid_user),
        .wbs_adr_i(wbs_adr_i),
        .wbs_dat_i(wbs_dat_i),
        .wren(wren),
        .NN_result(NN_result),
        .wbs_ack_o(wbs_ack_o),
        .wbs_dat_o(wbs_dat_o)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;  // 100 MHz clock
    end

    // Test procedure
    initial begin
        // Open a VCD file to dump signal values
        $dumpfile("../sim/NN_tb.vcd");
        $dumpvars(0, NN_tb);

        // Initialize inputs
        clk = 0;
        rst_l = 0;
        round_mode = 3'b000; // Round to nearest
        wbs_adr_i = 32'h00000000;
        wbs_dat_i = 32'h00000000;
        wren = 0;
        in_valid_user = 0;

        // Release reset after a few cycles
        #10 rst_l = 1;

        // Test Case 1: Set Operand A to 1.0 and Operand B to 0.0
        $display("Test Case 1: A=1.0, B=0.0");
        #10 wbs_adr_i = 32'h30000000;  // Address for opA
        wbs_dat_i = 32'h3F800000;         // 1.0 in floating-point
        wren = 1;
        #10 wren = 0;

        #10 wbs_adr_i = 32'h30000004;  // Address for opB
        wbs_dat_i = 32'h00000000;         // 0.0 in floating-point
        wren = 1;
        #10 wren = 0;
        in_valid_user = 1; #20;
        in_valid_user = 0;
        // Wait for 54 cycles for NN processing
        repeat(70) @(posedge clk);
        #10 $display("Final Result (A=1.0, B=0.0): %h", NN_result);

        // Test Case 2: Set Operand A to 0.0 and Operand B to 1.0
        $display("Test Case 2: A=0.0, B=1.0");
        #10 wbs_adr_i = 32'h30000000;  // Address for opA
        wbs_dat_i = 32'h00000000;         // 0.0 in floating-point
        wren = 1;
        #10 wren = 0;

        #10 wbs_adr_i = 32'h30000004;  // Address for opB
        wbs_dat_i = 32'h3F800000;         // 1.0 in floating-point
        wren = 1;
        #10 wren = 0;
        in_valid_user = 1; #20;
        in_valid_user = 0;
        // Wait for 54 cycles for NN processing
        repeat(70) @(posedge clk);
        #10 $display("Final Result (A=0.0, B=1.0): %h", NN_result);

        // Test Case 3: Set Operand A to 1.0 and Operand B to 1.0
        $display("Test Case 3: A=1.0, B=1.0");
        #10 wbs_adr_i = 32'h30000000;  // Address for opA
        wbs_dat_i = 32'h3F800000;         // 1.0 in floating-point
        wren = 1;
        #10 wren = 0;

        #10 wbs_adr_i = 32'h30000004;  // Address for opB
        wbs_dat_i = 32'h3F800000;         // 1.0 in floating-point
        wren = 1;
        #10 wren = 0;
        in_valid_user = 1; #20;
        in_valid_user = 0;
        // Wait for 54 cycles for NN processing
        repeat(70) @(posedge clk);
        #10 $display("Final Result (A=1.0, B=1.0): %h", NN_result);

        // Test Case 4: Set Operand A to 0.0 and Operand B to 0.0
        $display("Test Case 4: A=0.0, B=0.0");
        #10 wbs_adr_i = 32'h30000000;  // Address for opA
        wbs_dat_i = 32'h00000000;         // 0.0 in floating-point
        wren = 1;
        #10 wren = 0;

        #10 wbs_adr_i = 32'h30000004;  // Address for opB
        wbs_dat_i = 32'h00000000;         // 0.0 in floating-point
        wren = 1;
        #10 wren = 0;
        in_valid_user = 1; #20;
        in_valid_user = 0;
        // Wait for 54 cycles for NN processing
        repeat(70) @(posedge clk);
        #10 $display("Final Result (A=0.0, B=0.0): %h", NN_result);

        // Finish the simulation
        $finish;
    end

endmodule

