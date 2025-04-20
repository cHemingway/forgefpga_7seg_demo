from pathlib import Path

import cocotb
from cocotb.runner import get_runner
from cocotb.triggers import RisingEdge, ClockCycles, First
from cocotb.clock import Clock

@cocotb.test()
async def test_reset(dut):
    """ Test outputs after reset """
    c = Clock(dut.i_clk, 20, units="ns") # 50 MHz clock
    cocotb.start_soon(c.start(start_high=False))

    # Add reset
    dut.i_rst.value = 1
    await ClockCycles(dut.i_clk, 1)
    dut.i_rst.value = 0
    await ClockCycles(dut.i_clk, 1)

    # Check output is not set to valid after reset
    assert dut.o_bcd_valid == False


@cocotb.test()
async def test_convert_24(dut):
    """ Test converting the number 24 """
    c = Clock(dut.i_clk, 20, units="ns") # 50 MHz clock
    cocotb.start_soon(c.start(start_high=False))
    dut.i_rst.value = 1
    await ClockCycles(dut.i_clk, 1)
    dut.i_rst.value = 0
    await ClockCycles(dut.i_clk, 2)

    # Load in cycle
    dut.i_data.value = 24
    dut.i_load.value = 1
    await ClockCycles(dut.i_clk, 1)
    # Deassert load, o_bcd_valid should go low 1 cycle later
    dut.i_load.value = 0
    await ClockCycles(dut.i_clk, 1)
    assert dut.o_bcd_valid.value == 0
    
    print("TENS \t ONES \t BINARY \t")
    for i in range (10):
        print(bin(dut.scratch.value[0:7]), end="\t")
        print(bin(dut.scratch.value[8:11]), end="\t")
        print(bin(dut.scratch.value[11:15]), end="\t")
        print("")
        await ClockCycles(dut.i_clk, 1)
    assert dut.o_bcd_data.value == 0x24

@cocotb.test()
async def test_99(dut):
    """ Test converting the number 99 """
    c = Clock(dut.i_clk, 20, units="ns") # 50 MHz clock
    cocotb.start_soon(c.start(start_high=False))
    dut.i_rst.value = 1
    await ClockCycles(dut.i_clk, 1)
    dut.i_rst.value = 0
    await ClockCycles(dut.i_clk, 2)

    # Load in cycle
    dut.i_data.value = 99
    dut.i_load.value = 1
    await ClockCycles(dut.i_clk, 1)
    # Deassert load, o_bcd_valid should go low 1 cycle later
    dut.i_load.value = 0
    await ClockCycles(dut.i_clk, 1)
    assert dut.o_bcd_valid.value == 0
    # Should be valid after 8 cycles
    await First(ClockCycles(dut.i_clk, 8), RisingEdge(dut.o_bcd_valid))
    assert dut.o_bcd_valid.value == 1
    assert dut.o_bcd_data.value == 0x99


@cocotb.test()
async def test_latency(dut):
    """ Test latency, should take 8 cycles"""
    c = Clock(dut.i_clk, 20, units="ns") # 50 MHz clock
    cocotb.start_soon(c.start(start_high=False))
    dut.i_rst.value = 1
    await ClockCycles(dut.i_clk, 1)
    dut.i_rst.value = 0
    await ClockCycles(dut.i_clk, 2)
    # Load in cycle
    dut.i_data.value = 55
    dut.i_load.value = 1
    await ClockCycles(dut.i_clk, 1)
    # Deassert load, o_bcd_valid should go low 1 cycle later
    dut.i_load.value = 0
    await ClockCycles(dut.i_clk, 1)
    assert dut.o_bcd_valid.value == 0
    # Should be valid after 8 cycles
    await ClockCycles(dut.i_clk, 7)
    assert dut.o_bcd_valid.value == 0
    await ClockCycles(dut.i_clk, 1)
    assert dut.o_bcd_valid.value == 1
    assert dut.o_bcd_data.value == 0x55
    await ClockCycles(dut.i_clk, 1)
    assert dut.o_bcd_valid.value == 0


@cocotb.test(timeout_time=10, timeout_unit="sec")
async def test_all_numbers(dut):
    """ Test converting the number 99 """
    c = Clock(dut.i_clk, 20, units="ns") # 50 MHz clock
    cocotb.start_soon(c.start(start_high=False))
    dut.i_rst.value = 1
    await ClockCycles(dut.i_clk, 1)
    dut.i_rst.value = 0
    await ClockCycles(dut.i_clk, 2)

    for i in range(100):
        # Load in cycle
        dut.i_data.value = i
        dut.i_load.value = 1
        await ClockCycles(dut.i_clk, 1)
        # Deassert load, o_bcd_valid should go low 1 cycle later
        dut.i_load.value = 0
        await ClockCycles(dut.i_clk, 1)
        assert dut.o_bcd_valid.value == 0
        
        await First(ClockCycles(dut.i_clk, 8), RisingEdge(dut.o_bcd_valid))
        assert dut.o_bcd_valid.value == 1
        assert int(dut.o_bcd_data.value[4:7]) == i % 10 # ones
        assert int(dut.o_bcd_data.value[0:3]) == i // 10 # tens


def test_bcd_convertor_runner():
    sim = "verilator"  # or "icarus", "modelsim", etc.

    if sim == "verilator":
        test_args=["--trace", "--dump-file=test_bcd_convertor.vcd"]
        build_args = ["--trace", "--dump-file=test_bcd_convertor.vcd"]    #Make sure to add --trace to the build args as well
    else:
        test_args=[]
        build_args = []

    proj_path = Path(__file__).resolve().parent.parent

    sources = [proj_path / "ffpga/src/bcd_convertor.v"]

    runner = get_runner(sim)

    runner.build(
        sources=sources,
        hdl_toplevel="bcd_convertor",
        build_args=build_args,
        waves=True
    )

    runner.test(hdl_toplevel="bcd_convertor", test_module="test_bcd_convertor,", 
                test_args=test_args,
                waves=True)

if __name__ == "__main__":
    test_bcd_convertor_runner()