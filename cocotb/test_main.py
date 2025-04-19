from pathlib import Path

import cocotb
from cocotb.runner import get_runner
from cocotb.triggers import Edge, RisingEdge, ClockCycles, Timer
from cocotb.clock import Clock


@cocotb.test()
async def dut_startup(dut):
    """ Basic test """
    c = Clock(dut.i_clk_50mhz, 20, units="ns") # 50 MHz clock
    cocotb.start_soon(c.start())

    dut.fpga_done.value = 0
    dut.i_osc_ready.value = 1
    await ClockCycles(dut.i_clk_50mhz, 2)
    dut.fpga_done.value = 1
    await ClockCycles(dut.i_clk_50mhz, 2)

    # Check that the DUT sets the output enable
    assert dut.o_osc_en.value == 1
    assert dut.pmod_oe.value == 1

@cocotb.test()
async def dut_clock_div(dut):
    """ Basic test """
    c = Clock(dut.i_clk_50mhz, 20, units="ns") # 50 MHz clock
    cocotb.start_soon(c.start(start_high=False))

    dut.fpga_done.value = 0
    dut.i_osc_ready.value = 1
    await ClockCycles(dut.i_clk_50mhz, 2)
    dut.fpga_done.value = 1
    await ClockCycles(dut.i_clk_50mhz, 2)

    # Check clock cycles
    for i in range(10):
        await RisingEdge(dut.clk_781khz)

@cocotb.test()
async def dut_digits_count(dut):
    """ Basic test """
    c = Clock(dut.i_clk_50mhz, 20, units="ns") # 50 MHz clock
    cocotb.start_soon(c.start(start_high=False))

    dut.fpga_done.value = 0
    dut.i_osc_ready.value = 1
    await ClockCycles(dut.i_clk_50mhz, 2)
    dut.fpga_done.value = 1
    await ClockCycles(dut.i_clk_50mhz, 2)

    # Check the frequency of the digits
    old_value = dut.r_data.value

    # Count from 0 to 99 and then reset
    for i in range(100):
        assert dut.r_data.value == i
        await RisingEdge(dut.load)
    # Check that the value resets back to 0
    assert dut.r_data.value == 0
    await RisingEdge(dut.load)
    assert dut.r_data.value == 1
    await RisingEdge(dut.load)
    assert dut.r_data.value == 2

def test_main_runner():
    sim = "verilator"  # or "icarus", "modelsim", etc.

    if sim == "verilator":
        test_args=["--trace-fst"]
        build_args = ["--trace-fst"]    #Make sure to add --trace to the build args as well
    else:
        test_args=[]
        build_args = []

    proj_path = Path(__file__).resolve().parent.parent

    sources = [proj_path / "ffpga/src/main.v",
               proj_path / "ffpga/src/clock_prescaler.v",
               proj_path / "ffpga/src/down_counter.v",
               proj_path / "ffpga/src/input_reset_buf.v",
               proj_path / "ffpga/src/pulse_generator.v",
               proj_path / "ffpga/lib/seven_seg_disp_ctrl_2d.v"
            ]

    runner = get_runner(sim)

    runner.build(
        sources=sources,
        hdl_toplevel="main",
        build_args=build_args,
        waves=True
    )

    runner.test(hdl_toplevel="main", test_module="test_main,", 
                test_args=test_args,
                waves=True)

if __name__ == "__main__":
    test_main_runner()