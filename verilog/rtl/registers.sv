module #(
    parameter exp_width = 8,
    parameter mant_width = 24
) NN_registers(
    input  wire         clk,
    input  wire         rst_l,
    input  wire  [31:0] NN_result, //contaminated
    input  wire  [31:0] result, //written only when ready
    input  wire  [31:0] addr,
    input  wire         wren,
    input  wire         ready, //to act as wren for result
    input  wire  [31:0] wrdata,

    output wire         ack,
    output wire [(exp_width + mant_width - 1):0] rddata,
    output wire [(exp_width + mant_width - 1):0] opA,
    output wire [(exp_width + mant_width - 1):0] opB,
    output wire [(exp_width + mant_width - 1):0] w11,
    output wire [(exp_width + mant_width - 1):0] w12,
    output wire [(exp_width + mant_width - 1):0] w21,
    output wire [(exp_width + mant_width - 1):0] w22,
    output wire [(exp_width + mant_width - 1):0] b1,
    output wire [(exp_width + mant_width - 1):0] b2,
    output wire [(exp_width + mant_width - 1):0] w31,
    output wire [(exp_width + mant_width - 1):0] w32,
    output wire [(exp_width + mant_width - 1):0] b3,

);

   localparam base_addr = 32'h3000_0000;
    
   // ----------------------------------------------------------------------
   // OPERAND_A (RW)
   //  [31:0]   OPERAND_A
   localparam OPERAND_A = base_addr + 8'h00;

   wire        addr_A;
   wire        wr_opA;
   wire [31:0] opA_ns;

   assign addr_A = (addr[31:0] == OPERAND_A);
   assign wr_opA = wren && addr_A;
   assign opA_ns = wrdata;

   rvdffe #(32) opA_ff (.clk(clk), .rst_l(rst_l), .en(wr_opA), .din(opA_ns), .dout(opA));


   // ----------------------------------------------------------------------
   // OPERAND_B (RW)
   //  [31:0]   OPERAND_B
   localparam OPERAND_B = base_addr + 8'h04;

   wire        addr_B;
   wire        wr_opB;
   wire [31:0] opB_ns;

   assign addr_B = (addr[31:0] == OPERAND_B);
   assign wr_opB = wren && addr_B;
   assign opB_ns = wrdata;

   rvdffe #(32) opB_ff (.clk(clk), .rst_l(rst_l), .en(wr_opB), .din(opB_ns), .dout(opB));

   // ----------------------------------------------------------------------
   // RESULT (RW)
   //  [31:0]   RESULT
   localparam RESULT = base_addr + 8'h0C;

   wire        addr_result;
   wire        wr_result;
   wire [31:0] result_ns;

   assign addr_result = (addr[31:0] == RESULT);
   assign wr_result   = ready;
   assign result_ns   = NN_result;

   rvdffe #(32) result_ff (.clk(clk), .rst_l(rst_l), .en(wr_result), .din(result_ns), .dout(result));


   // ----------------------------------------------------------------------


   assign fcsr_read = {frm, fflags};

   assign rddata    = ({32{addr_A}}        & opA)                |
                      ({32{addr_B}}        & opB)                |
                      ({32{addr_result}}   & result)             ;
                      ({32{fcsr_addr}}     & {24'b0, fcsr_read});

    assign ack = (addr == OPERAND_A) | (addr == OPERAND_B) | (addr == RESULT);

endmodule
