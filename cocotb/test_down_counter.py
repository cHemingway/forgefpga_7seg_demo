from pathlib import Path

import cocotb
from cocotb.runner import get_runner
from cocotb.triggers import RisingEdge, ClockCycles, First
from cocotb.clock import Clock

COUNT_FROM = 100


@cocotb.test()
async def test_down_counter_resets(dut):
    c = Clock(dut.i_clk, 20, units="ns")  # 50 MHz clock
    cocotb.start_soon(c.start())

    dut.i_count_en.value = 0

    # Reset the DUT
    dut.i_rst.value = 1
    await ClockCycles(dut.i_clk, 2)
    dut.i_rst.value = 0
    await ClockCycles(dut.i_clk, 1)

    # Check count_hit is zero after reset
    assert dut.count_hit.value == 0


@cocotb.test()
async def test_down_counter_continuous(dut):
    """Basic test, check that the counter counts down"""
    c = Clock(dut.i_clk, 20, units="ns")  # 50 MHz clock
    cocotb.start_soon(c.start())

    dut.i_count_en.value = 0

    # Reset the DUT
    dut.i_rst.value = 1
    await ClockCycles(dut.i_clk, 2)
    dut.i_rst.value = 0
    await ClockCycles(dut.i_clk, 1)

    # Check count_hit is zero after reset
    assert dut.count_hit.value == 0

    # Enable the counter, and check that it counts down ok
    dut.i_count_en.value = 1
    await ClockCycles(dut.i_clk, COUNT_FROM)
    assert dut.count_hit.value == 0
    await ClockCycles(dut.i_clk, 1)
    assert dut.count_hit.value == 1
    await ClockCycles(dut.i_clk, 1)
    assert dut.count_hit.value == 0

    # Disable the counter, and check that it stops counting, 2x cycles should do it
    dut.i_count_en.value = 0
    await First(ClockCycles(dut.i_clk, COUNT_FROM * 2), RisingEdge(dut.count_hit))
    assert dut.count_hit.value == 0


@cocotb.test()
async def test_down_counter_disabled(dut):
    """Check doesn't count when disabled"""
    c = Clock(dut.i_clk, 20, units="ns")  # 50 MHz clock
    cocotb.start_soon(c.start())

    dut.i_count_en.value = 0

    # Reset the DUT
    dut.i_rst.value = 1
    await ClockCycles(dut.i_clk, 2)
    dut.i_rst.value = 0
    await ClockCycles(dut.i_clk, 1)

    # Check count_hit is zero after reset
    assert dut.count_hit.value == 0

    # Disable the counter, and check that it doesn't count, 2x cycles should do it
    dut.i_count_en.value = 0
    await First(ClockCycles(dut.i_clk, COUNT_FROM * 2), RisingEdge(dut.count_hit))
    assert dut.count_hit.value == 0


@cocotb.test()
async def test_down_counter_pulses(dut):
    """Checks counts pulses"""
    c = Clock(dut.i_clk, 20, units="ns")  # 50 MHz clock
    cocotb.start_soon(c.start())

    dut.i_count_en.value = 0

    # Reset the DUT
    dut.i_rst.value = 1
    await ClockCycles(dut.i_clk, 2)
    dut.i_rst.value = 0
    await ClockCycles(dut.i_clk, 1)

    # Check count_hit is zero after reset
    assert dut.count_hit.value == 0

    # Drive a pulse every 4 clock cycles
    for i in range(COUNT_FROM - 1):
        dut.i_count_en.value = 1
        await ClockCycles(dut.i_clk, 1)
        dut.i_count_en.value = 0
        assert dut.count_hit.value == 0
        await ClockCycles(dut.i_clk, 3)
        assert dut.count_hit.value == 0
    # Now one more cycle, and check that it counts
    dut.i_count_en.value = 1
    await ClockCycles(dut.i_clk, 1)
    assert dut.count_hit.value == 0
    await ClockCycles(dut.i_clk, 1)
    assert dut.count_hit.value == 1  # One cycle latency on this output
    await ClockCycles(dut.i_clk, 1)
    assert dut.count_hit.value == 0  # Make sure it goes low again


def test_down_counter_runner():
    sim = "verilator"  # or "icarus", "modelsim", etc.

    if sim == "verilator":
        test_args = ["--trace-fst"]
        build_args = [
            "--trace-fst"
        ]  # Make sure to add --trace to the build args as well
    else:
        test_args = []
        build_args = []

    proj_path = Path(__file__).resolve().parent.parent

    sources = [proj_path / "ffpga/src/down_counter.v"]

    runner = get_runner(sim)

    runner.build(
        sources=sources, hdl_toplevel="down_counter", build_args=build_args, waves=True
    )

    runner.test(
        hdl_toplevel="down_counter",
        test_module="test_down_counter,",
        test_args=test_args,
        waves=True,
    )


if __name__ == "__main__":
    test_down_counter_runner()
