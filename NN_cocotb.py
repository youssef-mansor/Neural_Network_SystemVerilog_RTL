import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

@cocotb.test()
async def nn_testbench(dut):
    """Testbench for the NN module."""

    # Clock generation
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Initialize inputs
    dut.rst_l.value = 0
    dut.round_mode.value = 0b000
    await RisingEdge(dut.clk)
    dut.rst_l.value = 1

    # Set initial weights and biases (IEEE 754 floating-point values)
    dut.w11.value = 0x40800000  # 4.0
    dut.w12.value = 0x40800000  # 4.0
    dut.w21.value = 0xc0800000  # -4.0
    dut.w22.value = 0xc0800000  # -4.0
    dut.b1.value = 0xc0000000   # -2.0
    dut.b2.value = 0x40c00000   # 6.0
    dut.w31.value = 0x40800000  # 4.0
    dut.w32.value = 0x40800000  # 4.0
    dut.b3.value = 0xc0c00000   # -6.0

    cocotb.log.info("-------------------------------------------------------------------------")
    cocotb.log.info("|       A Value        |       B Value        |       XOR Output        | Output > 0.5 |")
    cocotb.log.info("-------------------------------------------------------------------------")

    # Test cases for XOR
    test_cases = [
        (0x00000000, 0x00000000),
        (0x00000000, 0x3f800000),
        (0x3f800000, 0x00000000),
        (0x3f800000, 0x3f800000),
    ]

    for A_val, B_val in test_cases:
        # Set inputs
        dut.A.value = A_val
        dut.B.value = B_val

        # Wait for 60 clock cycles
        for _ in range(60):
            await RisingEdge(dut.clk)

        # Read and process outputs
        xor_output = int(dut.XOR_output.value)
        output_gt_0_5 = 1 if xor_output > 0x3f000000 else 0

        # Log the results with proper formatting
        cocotb.log.info(f"| {hex(A_val):<18} | {hex(B_val):<18} | {hex(xor_output):<22} | {output_gt_0_5:<11} |")

    cocotb.log.info("-------------------------------------------------------------------------")

