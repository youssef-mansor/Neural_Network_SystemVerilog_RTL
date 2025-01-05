import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer
import struct

@cocotb.test()
async def nn_tb(dut):
    """
    Testbench for the NN module using cocotb.
    """
    # Clock generation: 100 MHz clock (10 ns period)
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Initialize inputs
    dut.rst_l.value = 0
    dut.round_mode.value = 0b000  # Round to nearest
    dut.wbs_adr_i.value = 0x00000000
    dut.wbs_dat_i.value = 0x00000000
    dut.wren.value = 0
    dut.in_valid_user.value = 0

    # Reset sequence
    await Timer(10, units="ns")  # Wait for 10 ns
    dut.rst_l.value = 1  # Release reset

    # Wait a few clock cycles to ensure stable simulation
    for _ in range(5):
        await RisingEdge(dut.clk)

    # Test Case 1: Set Operand A to 1.0 and Operand B to 0.0
    cocotb.log.info("Test Case 1: A=1.0, B=0.0")

    # Write Operand A (1.0 in floating-point)
    await Timer(10, units="ns")
    dut.wbs_adr_i.value = 0x30000000  # Address for opA
    dut.wbs_dat_i.value = 0x3F800000  # 1.0 in floating-point
    dut.wren.value = 1
    await Timer(10, units="ns")
    dut.wren.value = 0

    # Write Operand B (0.0 in floating-point)
    await Timer(10, units="ns")
    dut.wbs_adr_i.value = 0x30000004  # Address for opB
    dut.wbs_dat_i.value = 0x00000000  # 0.0 in floating-point
    dut.wren.value = 1
    await Timer(10, units="ns")
    dut.wren.value = 0

    # Signal input valid
    dut.in_valid_user.value = 1
    await Timer(20, units="ns")
    dut.in_valid_user.value = 0

    # Wait for 54 cycles for NN processing
    for _ in range(70):
        await RisingEdge(dut.clk)

    # Extract result and convert to decimal
    result_hex = int(dut.NN_result.value)
    result_float = struct.unpack('!f', result_hex.to_bytes(4, byteorder='big'))[0]
    greater_than_half = 1 if result_float > 0.5 else 0

    # Log results in table format
    cocotb.log.info("|   A   |   B   | Result Hex | Result Decimal | > 0.5 |")
    cocotb.log.info("|-------|-------|------------|----------------|-------|")
    cocotb.log.info(f"|  1.0  |  0.0  |  {result_hex:08X}  |   {result_float: .6f}   |   {greater_than_half}   |")

    # End the simulation
    await Timer(10, units="ns")
