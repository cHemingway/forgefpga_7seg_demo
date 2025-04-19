# Fixme, can't seem to find the i_clk_50mhz port. osc_clk doesn't work either.
create_clock -period 20.00 -name i_clk_50mhz [get_pins {top/i_clk_50mhz}]