`include "fpu_lib.sv"
`include "add_sub.sv"
`include "multiplier.sv"
`include "dot_product.sv"

module matrix_multiplier #(
    parameter DATA_WIDTH = 32,
    parameter MATRIX_A_ROWS = 4,
    parameter VECTOR_SIZE = 4, //same as common dimension between two matrices
    parameter MATRIX_B_COLS = 4
) (
    input  wire [DATA_WIDTH-1:0] matrix_a [MATRIX_A_ROWS][VECTOR_SIZE],
    input  wire [DATA_WIDTH-1:0] matrix_b [VECTOR_SIZE][MATRIX_B_COLS],
    input  wire [2:0] round_mode,
    output wire [DATA_WIDTH-1:0] matrix_out [MATRIX_A_ROWS][MATRIX_B_COLS],
    output wire [4:0] exceptions [MATRIX_A_ROWS][MATRIX_B_COLS]
);

  localparam NUM_DOT_PRODS = MATRIX_A_ROWS * MATRIX_B_COLS;
  logic [VECTOR_SIZE-1:0] col_temp;
  
  // Intermediary dot product out
   wire [DATA_WIDTH-1:0] dot_prod_outs [NUM_DOT_PRODS];
   wire [4:0] dot_prod_exceptions [NUM_DOT_PRODS];

    genvar i, j, m;
   generate
      for(i = 0; i < MATRIX_A_ROWS; i++) begin: row_gen
          for(j = 0; j < MATRIX_B_COLS; j++) begin: col_gen
          // Extract Matrix B Column
	    for (m = 0; m < VECTOR_SIZE; m++) begin : gen_col
	      assign col_temp[m] = matrix_b[m][j]; //  'j' is the column index
	    end
          
           // Dot product instantiation
           dot_product #(
            .DATA_WIDTH(DATA_WIDTH),
            .VECTOR_SIZE(VECTOR_SIZE)
            ) dot_prod_inst(
              .row(matrix_a[i]),
              .col(col_temp), //matrix_b[0:VECTOR_SIZE-1][j]
              .round_mode(round_mode), //round_mode
              .dot_product_out(dot_prod_outs[i * MATRIX_B_COLS  + j]), //i * MATRIX_B_COLS  + j
              .exceptions(dot_prod_exceptions[i * MATRIX_B_COLS + j]) //i * MATRIX_B_COLS + j
           );
          end
      end
   endgenerate

  generate
    for (i = 0; i < MATRIX_A_ROWS; i++) begin: output_rows
      for (j = 0; j < MATRIX_B_COLS; j++) begin: output_cols
        assign matrix_out[i][j] = dot_prod_outs[i * MATRIX_B_COLS + j];
        assign exceptions[i][j] = dot_prod_exceptions[i * MATRIX_B_COLS + j];
      end
    end
  endgenerate

endmodule
