import cocotb
from cocotb.regression import TestFactory
from cocotb.clock import Clock
from cocotb.binary import BinaryValue
import logging

# Testbench for NN module
@cocotb.coroutine
def nn_tb(dut):
    # Clock and reset procedure
    cocotb.fork(Clock(dut.clk, 10, units='ns').start())  # 100 MHz clock
    
    # Initialize signals
    dut.rst_l <= 0
    dut.round_mode <= 0b000  # Round to nearest
    dut.wbs_adr_i <= 0
    dut.wbs_dat_i <= 0
    dut.wren <= 0
    dut.in_valid_user <= 0
    
    # Apply reset
    yield RisingEdge(dut.clk)
    dut.rst_l <= 1
    
    # Test Case 1: Set Operand A to 1.0 and Operand B to 0.0
    logging.info("Test Case 1: A=1.0, B=0.0")
    dut.wbs_adr_i <= 0x30000000  # Address for opA
    dut.wbs_dat_i <= BinaryValue("0x3F800000")  # 1.0 in floating-point
    dut.wren <= 1
    yield RisingEdge(dut.clk)
    dut.wren <= 0
    
    dut.wbs_adr_i <= 0x30000004  # Address for opB
    dut.wbs_dat_i <= BinaryValue("0x00000000")  # 0.0 in floating-point
    dut.wren <= 1
    yield RisingEdge(dut.clk)
    dut.wren <= 0
    
    # Activate user signal
    dut.in_valid_user <= 1
    yield cocotb.utils.raise_timeout(dut.clk.negedge, 2)
    dut.in_valid_user <= 0
    
    # Wait for 70 clock cycles for NN processing
    yield cocotb.utils.raise_timeout(dut.clk.negedge, 70)
    
    # Read and display final result
    logging.info(f"Final Result (A=1.0, B=0.0): {dut.NN_result.value}")

    # Test Case 2: Set Operand A to 0.0 and Operand B to 1.0
    logging.info("Test Case 2: A=0.0, B=1.0")
    dut.wbs_adr_i <= 0x30000000  # Address for opA
    dut.wbs_dat_i <= BinaryValue("0x00000000")  # 0.0 in floating-point
    dut.wren <= 1
    yield RisingEdge(dut.clk)
    dut.wren <= 0
    
    dut.wbs_adr_i <= 0x30000004  # Address for opB
    dut.wbs_dat_i <= BinaryValue("0x3F800000")  # 1.0 in floating-point
    dut.wren <= 1
    yield RisingEdge(dut.clk)
    dut.wren <= 0
    
    # Activate user signal
    dut.in_valid_user <= 1
    yield cocotb.utils.raise_timeout(dut.clk.negedge, 2)
    dut.in_valid_user <= 0
    
    # Wait for 70 clock cycles for NN processing
    yield cocotb.utils.raise_timeout(dut.clk.negedge, 70)
    
    # Read and display final result
    logging.info(f"Final Result (A=0.0, B=1.0): {dut.NN_result.value}")

    # Test Case 3: Set Operand A to 1.0 and Operand B to 1.0
    logging.info("Test Case 3: A=1.0, B=1.0")
    dut.wbs_adr_i <= 0x30000000  # Address for opA
    dut.wbs_dat_i <= BinaryValue("0x3F800000")  # 1.0 in floating-point
    dut.wren <= 1
    yield RisingEdge(dut.clk)
    dut.wren <= 0
    
    dut.wbs_adr_i <= 0x30000004  # Address for opB
    dut.wbs_dat_i <= BinaryValue("0x3F800000")  # 1.0 in floating-point
    dut.wren <= 1
    yield RisingEdge(dut.clk)
    dut.wren <= 0
    
    # Activate user signal
    dut.in_valid_user <= 1
    yield cocotb.utils.raise_timeout(dut.clk.negedge, 2)
    dut.in_valid_user <= 0
    
    # Wait for 70 clock cycles for NN processing
    yield cocotb.utils.raise_timeout(dut.clk.negedge, 70)
    
    # Read and display final result
    logging.info(f"Final Result (A=1.0, B=1.0): {dut.NN_result.value}")

    # Test Case 4: Set Operand A to 0.0 and Operand B to 0.0
    logging.info("Test Case 4: A=0.0, B=0.0")
    dut.wbs_adr_i <= 0x30000000  # Address for opA
    dut.wbs_dat_i <= BinaryValue("0x00000000")  # 0.0 in floating-point
    dut.wren <= 1
    yield RisingEdge(dut.clk)
    dut.wren <= 0
    
    dut.wbs_adr_i <= 0x30000004  # Address for opB
    dut.wbs_dat_i <= BinaryValue("0x00000000")  # 0.0 in floating-point
    dut.wren <= 1
    yield RisingEdge(dut.clk)
    dut.wren <= 0
    
    # Activate user signal
    dut.in_valid_user <= 1
    yield cocotb.utils.raise_timeout(dut.clk.negedge, 2)
    dut.in_valid_user <= 0
    
    # Wait for 70 clock cycles for NN processing
    yield cocotb.utils.raise_timeout(dut.clk.negedge, 70)
    
    # Read and display final result
    logging.info(f"Final Result (A=0.0, B=0.0): {dut.NN_result.value}")

# Factory to run the test
factory = TestFactory(nn_tb)

# # Add simulation options
# factory.add_option(["-sv"])

# Run the simulation
factory.generate_tests()
