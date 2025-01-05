//`include "fpu_lib.sv"

// module rvdffe #(
//     parameter WIDTH = 8  // Default width is 8 bits
// ) (
//     input wire clk,        // Clock signal
//     input wire rst_l,      // Active low reset
//     input wire en,         // Enable input
//     input wire [WIDTH-1:0] din, // Data input
//     output reg [WIDTH-1:0] dout // Data output
// );

//     always @(posedge clk or negedge rst_l) begin
//         if (!rst_l) begin
//             dout <= {WIDTH{1'b0}}; // Reset output to 0 on reset
//         end else if (en) begin
//             dout <= din; // Load input to output on enable
//         end
//     end

// endmodule
 
module  NN_registers(
    input  wire         clk,
    input  wire         rst_l,
    input  wire  [31:0] wbs_adr_i,
    input  wire         wren,
    input  wire  [31:0] wbs_dat_i,

    output wire         wbs_ack_o,
    output wire [31:0] wbs_dat_o,
    output wire [31:0] opA,
    output wire [31:0] opB,
    output wire [31:0] w11,
    output wire [31:0] w12,
    output wire [31:0] w21,
    output wire [31:0] w22,
    output wire [31:0] b1,
    output wire [31:0] b2,
    output wire [31:0] w31,
    output wire [31:0] w32,
    output wire [31:0] b3
);


   localparam base_addr = 32'h3000_0000;

   // Define addresses for weights and biases
   localparam W11_ADDR = base_addr + 8'h08;
   localparam W12_ADDR = base_addr + 8'h0C;
   localparam W21_ADDR = base_addr + 8'h10;
   localparam W22_ADDR = base_addr + 8'h18;
   localparam W31_ADDR = base_addr + 8'h1C;
   localparam W32_ADDR = base_addr + 8'h20;
   localparam B1_ADDR  = base_addr + 8'h24;
   localparam B2_ADDR  = base_addr + 8'h28;
   localparam B3_ADDR  = base_addr + 8'h2C;

   // Initialize weights and biases
   wire [31:0] w11_reg, w12_reg, w21_reg, w22_reg, w31_reg, w32_reg;
   wire [31:0] b1_reg, b2_reg, b3_reg;

   assign w11 = w11_reg;
   assign w12 = w12_reg;
   assign w21 = w21_reg;
   assign w22 = w22_reg;
   assign w31 = w31_reg;
   assign w32 = w32_reg;
   assign b1  = b1_reg;
   assign b2  = b2_reg;
   assign b3  = b3_reg;

   // Register files for weights and biases (initialized at reset) //TODO update the logic here so that writting happens only rst_l is set high 
   rvdffe #(32) w11_ff (.clk(clk), .rst_l(rst_l), .en(1'b1), .din(32'h40800000), .dout(w11_reg));
   rvdffe #(32) w12_ff (.clk(clk), .rst_l(rst_l), .en(1'b1), .din(32'h40800000), .dout(w12_reg));
   rvdffe #(32) w21_ff (.clk(clk), .rst_l(rst_l), .en(1'b1), .din(32'hc0800000), .dout(w21_reg));
   rvdffe #(32) w22_ff (.clk(clk), .rst_l(rst_l), .en(1'b1), .din(32'hc0800000), .dout(w22_reg));
   rvdffe #(32) w31_ff (.clk(clk), .rst_l(rst_l), .en(1'b1), .din(32'h40800000), .dout(w31_reg));
   rvdffe #(32) w32_ff (.clk(clk), .rst_l(rst_l), .en(1'b1), .din(32'h40800000), .dout(w32_reg));
   rvdffe #(32) b1_ff  (.clk(clk), .rst_l(rst_l), .en(1'b1), .din(32'hc0000000), .dout(b1_reg));
   rvdffe #(32) b2_ff  (.clk(clk), .rst_l(rst_l), .en(1'b1), .din(32'h40c00000), .dout(b2_reg));
   rvdffe #(32) b3_ff  (.clk(clk), .rst_l(rst_l), .en(1'b1), .din(32'hc0c00000), .dout(b3_reg));

   // Address decoding for weights and biases
   wire addr_w11 = (wbs_adr_i[31:0] == W11_ADDR);
   wire addr_w12 = (wbs_adr_i[31:0] == W12_ADDR);
   wire addr_w21 = (wbs_adr_i[31:0] == W21_ADDR);
   wire addr_w22 = (wbs_adr_i[31:0] == W22_ADDR);
   wire addr_w31 = (wbs_adr_i[31:0] == W31_ADDR);
   wire addr_w32 = (wbs_adr_i[31:0] == W32_ADDR);
   wire addr_b1  = (wbs_adr_i[31:0] == B1_ADDR);
   wire addr_b2  = (wbs_adr_i[31:0] == B2_ADDR);
   wire addr_b3  = (wbs_adr_i[31:0] == B3_ADDR);
    
   // ----------------------------------------------------------------------
   // OPERAND_A (RW)
   //  [31:0]   OPERAND_A
   localparam OPERAND_A = base_addr + 8'h00;

   wire        addr_A;
   wire        wr_opA;
   wire [31:0] opA_ns;

   assign addr_A = (wbs_adr_i[31:0] == OPERAND_A);
   assign wr_opA = wren && addr_A;
   assign opA_ns = wbs_dat_i;

   rvdffe #(32) opA_ff (.clk(clk), .rst_l(rst_l), .en(wr_opA), .din(opA_ns), .dout(opA));


   // ----------------------------------------------------------------------
   // OPERAND_B (RW)
   //  [31:0]   OPERAND_B
   localparam OPERAND_B = base_addr + 8'h04;

   wire        addr_B;
   wire        wr_opB;
   wire [31:0] opB_ns;

   assign addr_B = (wbs_adr_i[31:0] == OPERAND_B);
   assign wr_opB = wren && addr_B;
   assign opB_ns = wbs_dat_i;

   rvdffe #(32) opB_ff (.clk(clk), .rst_l(rst_l), .en(wr_opB), .din(opB_ns), .dout(opB));

   // ----------------------------------------------------------------------


 // Assign read data (MUX logic for wbs_dat_o)
   assign wbs_dat_o = ({32{addr_A}}        & opA)      |
                      ({32{addr_B}}        & opB)      |
                      ({32{addr_w11}}      & w11_reg)  |
                      ({32{addr_w12}}      & w12_reg)  |
                      ({32{addr_w21}}      & w21_reg)  |
                      ({32{addr_w22}}      & w22_reg)  |
                      ({32{addr_w31}}      & w31_reg)  |
                      ({32{addr_w32}}      & w32_reg)  |
                      ({32{addr_b1}}       & b1_reg)   |
                      ({32{addr_b2}}       & b2_reg)   |
                      ({32{addr_b3}}       & b3_reg);

   // Acknowledge signal (It doesn't wait for a  clock cycle but rather acknowledge once a correct address is received)
   assign wbs_ack_o = addr_A | addr_B | addr_w11 | addr_w12 | addr_w21 |
                addr_w22 | addr_w31 | addr_w32 | addr_b1 | addr_b2 | addr_b3;

endmodule
