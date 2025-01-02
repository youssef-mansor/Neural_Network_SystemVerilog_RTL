`include "../rtl/NN_registers.sv"
module NN_registers_tb();

    // Testbench Signals
    reg clk;
    reg rst_l;
    reg [31:0] NN_result;
    reg [31:0] wbs_adr_i;
    reg wren;
    reg ready;
    reg [31:0] wbs_dat_i;

    // Outputs
    wire [31:0] final_res;
    wire wbs_ack_o;
    wire [31:0] wbs_dat_o;
    wire [31:0] opA;
    wire [31:0] opB;
    wire [31:0] w11;
    wire [31:0] w12;
    wire [31:0] w21;
    wire [31:0] w22;
    wire [31:0] b1;
    wire [31:0] b2;
    wire [31:0] w31;
    wire [31:0] w32;
    wire [31:0] b3;

    // Instantiate the NN_registers module
    NN_registers uut (
        .clk(clk),
        .rst_l(rst_l),
        .NN_result(NN_result),
        .final_res(final_res),
        .wbs_adr_i(wbs_adr_i),
        .wren(wren),
        .ready(ready),
        .wbs_dat_i(wbs_dat_i),
        .wbs_ack_o(wbs_ack_o),
        .wbs_dat_o(wbs_dat_o),
        .opA(opA),
        .opB(opB),
        .w11(w11),
        .w12(w12),
        .w21(w21),
        .w22(w22),
        .b1(b1),
        .b2(b2),
        .w31(w31),
        .w32(w32),
        .b3(b3)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;  // 100 MHz clock
    end

    // Test procedure
    initial begin
        // Initialize signals
        clk = 0;
        rst_l = 0;
        NN_result = 32'h00000000;
        wbs_adr_i = 32'h00000000;
        wren = 0;
        ready = 0;
        wbs_dat_i = 32'h00000000;

        // Open a VCD file to dump signal values
        $dumpfile("NN_registers_tb.vcd");
        $dumpvars(0, NN_registers_tb);

        // Reset the system
        #10 rst_l = 1;  // release reset after 10 time units

        // Test Case 1: Write to Operand A
        // Write value 32'h12345678 to Operand A (wbs_adr_iess 0x30000000)
        #10 wbs_adr_i = 32'h30000000;
        wbs_dat_i = 32'h12345678;
        wren = 1;
        ready = 0; // not writing to result yet
        #10 wren = 0; // stop writing

        // Test Case 2: Write to Operand B
        // Write value 32'h87654321 to Operand B (address 0x30000004)
        #10 wbs_adr_i = 32'h30000004;
        wbs_dat_i = 32'h87654321;
        wren = 1;
        #10 wren = 0; // stop writing

        // Monitor the values of opA and opB
        #10;
        $display("opA: %h", opA);
        $display("opB: %h", opB);

        // Test Case 3: Set NN_result and ready, then write result
        // Set NN_result value
        #10 NN_result = 32'hDEADBEEF;  // Set NN_result to a test value
        
        // Set ready high to trigger result writing
        #10 ready = 1;  // Set ready high to write NN_result to the result register
        #10 ready = 0;  // Set ready low to stop writing

        // Monitor the result register
        #10;
        $display("Result after ready is set: %h", final_res);

        // Test Case 4: Read Operand A and Operand B
        // Now read Operand A and B
        #10 wbs_adr_i = 32'h30000000;  // Read Operand A
        #10 wbs_adr_i = 32'h30000004;  // Read Operand B

        // Test Case 5: Read Result after ready is set
        // Now read the result (address 0x30000030)
        #10 wbs_adr_i = 32'h30000030;  // Read Result
        #10;
        $display("Final Result read from address 0x30000030: %h", final_res);

        // Finish simulation
        $finish;
    end

endmodule

