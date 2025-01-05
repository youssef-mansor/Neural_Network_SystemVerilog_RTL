// `include "defs.vi"
// `include "fpu_lib.sv"
// `include "add_sub.sv"
// `include "multiplier.sv"
// `include "divider.sv"
// `include "matrix_multiply_1x2_2x1.sv"
// `include "matrix_multiply_2x2_2x1.sv"
// `include "sigmoid_v5.sv"
// `include "NN_registers.sv"
// `include "NN.sv"

module NN_wb_wrapper (
`ifdef USE_POWER_PINS
    inout VPWR,
    inout VGND,
`endif

    // IOs
    input  [37:0] io_in,  //connected to switches and used by user to confirm operaneds readiness.
    output [37:0] io_out, //connected to LEDS
    output [37:0] io_oeb,

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o
);
    //GPIO Pins S for switches and L for LEDs
// 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
// S  S  S  S  S  S  L  L  L  L  L  L  L  L  L  L  L  L  L  L  L  L  L  L  L  L  L  L  L L L L L L L L L L 
    assign io_oeb = {6'b111111, 32'b0}; // 37-32 -> S (Switches, high impedance), 31-0 -> L (LEDs, enabled)

    wire valid;
    assign valid = wbs_cyc_i && wbs_stb_i; //indicates a tranfer request is active (write/read)
    // write_enable logic
    wire write_enable;
    assign write_enable = wbs_we_i && valid;
    // read_enable logic
    wire read_enable;
    assign read_enable = ~wbs_we_i && valid;

    wire [31:0] NN_result;
    assign io_out[31:0]  = NN_result; // Connect NN output to IO
    assign io_out[37:32] = 6'b0; // Unused bits

    //Dont Assign to inputs
    // wire in_valid_user;
    // assign io_in[37:33] = 5'b0; // Unused bits, set to 0
    // assign io_in[32]    = in_valid_user; // Assign user input signal
    // assign io_in[31:0]  = 32'b0;  // Unused bits for switches (if intended)



    NN NN_inst(
        // Clock and reset.
        .clk(wb_clk_i),
        .rst_l(!wb_rst_i),
        .round_mode(3'b000), //round to nearest
        .in_valid_user(io_in[32]),
        .wbs_adr_i(wbs_adr_i),
        .wbs_dat_i(wbs_dat_i),
        .wren(write_enable),
        .NN_result(NN_result),
        .wbs_ack_o(wbs_ack_o),
        .wbs_dat_o(wbs_dat_o)
    );

endmodule
