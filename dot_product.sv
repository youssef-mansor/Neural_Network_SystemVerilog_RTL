//`include "fpu_lib.sv"
//`include "add_sub.sv"
//`include "multiplier.sv"



module dot_product #(parameter DATA_WIDTH = 32, parameter VECTOR_SIZE = 4) (
  input  wire [DATA_WIDTH-1:0] row [VECTOR_SIZE],
  input  wire [DATA_WIDTH-1:0] col [VECTOR_SIZE],
  input  wire [2:0] round_mode,
  output wire [DATA_WIDTH-1:0] dot_product_out,
  output wire [4:0] exceptions
);

  wire [DATA_WIDTH-1:0] products [VECTOR_SIZE];
  wire [4:0] product_exceptions [VECTOR_SIZE];

  genvar i;
  generate
    for (i = 0; i < VECTOR_SIZE; i++) begin : gen_mults
      multiplier #( .exp_width(8), .mant_width(24)) mult (
        .a(row[i]),
        .b(col[i]),
        .round_mode(round_mode),
        .exceptions(product_exceptions[i]),
        .out(products[i])
      );
    end
  endgenerate

  // Adder Tree Implementation using generate blocks
  localparam  TREE_DEPTH = $clog2(VECTOR_SIZE);
  wire [DATA_WIDTH-1:0]  adder_tree_wires[TREE_DEPTH+1][VECTOR_SIZE];
  wire [4:0]  exceptions_wires[TREE_DEPTH+1][VECTOR_SIZE];
  
  generate
    for (i = 0; i < VECTOR_SIZE; i++) begin: init_stage
      assign adder_tree_wires[0][i] = products[i];
       assign exceptions_wires[0][i] = product_exceptions[i];
    end
  endgenerate

  genvar stage;
  generate
    for (stage = 0; stage < TREE_DEPTH; stage++) begin : gen_add_stages
      for (i = 0; i < VECTOR_SIZE; i = i+2) begin : gen_add_pairs

        if (i+1 < VECTOR_SIZE) begin
            add_sub adder(
               .in_x(adder_tree_wires[stage][i]),
               .in_y(adder_tree_wires[stage][i+1]),
               .operation(1'b0),
               .round_mode(round_mode),
               .out_z(adder_tree_wires[stage+1][i/2]),
                .exceptions(exceptions_wires[stage+1][i/2])
            );
         end else begin
            assign adder_tree_wires[stage+1][i/2] = adder_tree_wires[stage][i];
             assign exceptions_wires[stage+1][i/2] = exceptions_wires[stage][i];
         end

      end
    end
  endgenerate
    
    assign dot_product_out = (VECTOR_SIZE == 1) ? products[0] : adder_tree_wires[TREE_DEPTH][0];
    assign exceptions = (VECTOR_SIZE == 1) ? product_exceptions[0] : exceptions_wires[TREE_DEPTH][0];

endmodule
