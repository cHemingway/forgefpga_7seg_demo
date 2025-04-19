## Simple demo for ForgeFPGA dev kit + PmodSSD
A basic counter example for the ForgeFPGA dev kit, using the [Pmod SSD](https://digilent.com/shop/pmod-ssd-seven-segment-display/) dual seven segment display included in the kit. 


### Credits
- [seven_seg_disp_ctrl_2d.v](ffpga/lib/seven_seg_disp_ctrl_2d.v) is from the ForgeFPGA modules library, copyright Renesas.

- [input_reset_buf](ffpga/src/input_reset_buf.v) is from "AN-FG-015 ForgeFPGA Running String Example", copyright Renesas

### Testbench
cocotb testbench is the best, install cocotb and verilator to run it

Then either run `python ./test_main.py` or install pytest and use that to run them

### TODO
- [ ] Fix counting rate, should be 1Hz
- [ ] Implement decimal to BCD convertor
- [ ] Better coverage in cocotb main testbench, curently 7 seg decoder is untested
- [ ] Make your own 7 seg decoder. Renesas's one has issues with bleeding and is bit undocumented
- [ ] See if I can get less warnings
- [ ] Actually add some timing constraints
    - Added in [timing_constraints.sdc](ffpga/timing-constraints/timing_constraints.sdc) but not yet working. Can't seem to find any working forgefpga examples.
