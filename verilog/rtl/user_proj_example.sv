// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

`include "fpu_lib.sv"
`include "add_sub.sv"
`include "multiplier.sv"
`include "divider.sv"
`include "matrix_multiply_1x2_2x1.sv"
`include "matrix_multiply_2x2_2x1.sv"
`include "sigmoid_v5.sv"
`include "NN_registers.sv"
`include "NN.sv"

module user_proj_example #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,	//to determine valid signal
    input wbs_cyc_i,	//to determine valid signal
    input wbs_we_i,	//to determine valid signal
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i, //connected to wdata
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o, //connected to rdata wire

    // IOs
    input  [37:0] io_in,
    output [37:0] io_out, //connected to result wire
    output [37:0] io_oeb
);
    wire clk;
    wire rst;

    wire [BITS-1:0] rdata; 
    wire [BITS-1:0] wdata;
    wire [BITS-1:0] result;

    wire valid;
    wire [3:0] wstrb;
    wire ready;

    // WB MI A
    assign valid = wbs_cyc_i && wbs_stb_i && wbs_we_i; 
    //assign wstrb = wbs_sel_i & {4{wbs_we_i}};
    assign wbs_dat_o = rdata;
    assign wdata = wbs_dat_i;

    // IO
    assign io_out = result;
    assign io_oeb = {(BITS){rst}};


// Instantiate the NN_registers module
    NN_registers csrs(
        .clk(clk),
        .rst_l(~rst),  // Active low reset
        .NN_result(NN_result),
        .addr(wbs_adr_i),
        .wren(valid && wbs_we_i),
        .ready(ready),
        .wrdata(wbs_dat_i),
        .result(result),
        .ack(wbs_ack_o),
        .rddata(rdata),
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

    // Instantiate the NN module
    NN NN_inst(
        .w11(w11),
        .w12(w12),
        .w21(w21),
        .w22(w22),
        .b1(b1),
        .b2(b2),
        .w31(w31),
        .w32(w32),
        .b3(b3),
        .A(opA),
        .B(opB),
        .clk(clk),
        .rst_l(~rst),  // Active low reset
        .round_mode(io_in[2:0]),  // Using lower 3 bits of io_in for round_mode
        .ready(ready),
        .XOR_output(NN_result)
    );


endmodule

`default_nettype wire
