from pathlib import Path

import cocotb
from cocotb.runner import get_runner
from cocotb.triggers import RisingEdge, ClockCycles
from cocotb.clock import Clock

@cocotb.test()
async def clock_prescaler(dut):
    """ Basic test """
    c = Clock(dut.i_clk, 20, units="ns") # 50 MHz clock
    cocotb.start_soon(c.start(start_high=False))

    # Add reset
    dut.i_rst.value = 1
    await ClockCycles(dut.i_clk, 2)
    dut.i_rst.value = 0
    await ClockCycles(dut.i_clk, 2)

    # Skip the first output edge
    await RisingEdge(dut.o_clk)

    # Check the 2nd and 3rd output edge timing
    await RisingEdge(dut.o_clk)
    start_time = cocotb.utils.get_sim_time("ns")
    
    await RisingEdge(dut.o_clk)
    finish_time = cocotb.utils.get_sim_time("ns")
    
    # Check the clock period, should be 2**6 = 64 times the input clock period
    assert (finish_time - start_time) == 128 * 20

def test_clock_prescaler_runner():
    sim = "verilator"  # or "icarus", "modelsim", etc.

    if sim == "verilator":
        test_args=["--trace", "--dump-file=test_clock_prescaler.vcd"]
        build_args = ["--trace", "--dump-file=test_clock_prescaler.vcd"]    #Make sure to add --trace to the build args as well
    else:
        test_args=[]
        build_args = []

    proj_path = Path(__file__).resolve().parent.parent

    sources = [proj_path / "ffpga/src/clock_prescaler.v"]

    runner = get_runner(sim)

    runner.build(
        sources=sources,
        hdl_toplevel="clock_prescaler",
        build_args=build_args,
        waves=True
    )

    runner.test(hdl_toplevel="clock_prescaler", test_module="test_clock_prescaler,", 
                test_args=test_args,
                waves=True)

if __name__ == "__main__":
    test_clock_prescaler_runner()