import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
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

    # Define test cases: each tuple is (A, B)
    test_cases = [
        (0x00000000, 0x00000000),  # A=0.0, B=0.0
        (0x3F800000, 0x00000000),  # A=1.0, B=0.0
        (0x00000000, 0x3F800000),  # A=0.0, B=1.0
        (0x3F800000, 0x3F800000),  # A=1.0, B=1.0
    ]

    # Header for results log
    cocotb.log.info("|   A   |   B   | Result Hex | Result Decimal| > 0.5 |")
    cocotb.log.info("|-------|-------|------------|---------------|-------|")

    for A, B in test_cases:
        # Write Operand A
        await Timer(10, units="ns")
        dut.wbs_adr_i.value = 0x30000000  # Address for opA
        dut.wbs_dat_i.value = A
        dut.wren.value = 1
        await Timer(10, units="ns")
        dut.wren.value = 0

        # Write Operand B
        await Timer(10, units="ns")       
        dut.wbs_adr_i.value = 0x30000004  # Address for opB
        dut.wbs_dat_i.value = B
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

        # Log results
        A_float = struct.unpack('!f', A.to_bytes(4, byteorder='big'))[0]
        B_float = struct.unpack('!f', B.to_bytes(4, byteorder='big'))[0]
        cocotb.log.info(f"| {A_float: .1f}  | {B_float: .1f}  |  {result_hex:08X}  |   {result_float: .6f}   |   {greater_than_half}   |")

    # End the simulation
    await Timer(10, units="ns")
