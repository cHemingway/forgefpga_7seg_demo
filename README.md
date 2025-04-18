## Simple demo for ForgeFPGA dev kit + PmodSSD
A basic counter example for the ForgeFPGA dev kit, using the Pmod


### Credits
- [seven_seg_disp_ctrl_2d.v](ffpga/lib/seven_seg_disp_ctrl_2d.v) is from the ForgeFPGA modules library, copyright Renesas.

- [input_reset_buf](ffpga/src/input_reset_buf.v) is from "AN-FG-015 ForgeFPGA Running String Example", copyright Renesas

### Testbench
cocotb testbench is the best, install cocotb and verilator to run it

Then either run `python ./test_main.py` or install pytest and use that to run them

### TODO
- [ ] Implement decimal to BCD convertor
- [ ] Better coverage in cocotb, curently 7 seg decoder is untested
- [ ] See if I can get less warnings
- [ ] Actually add some timing constraints
