# Create generated clocks based on PLLs
# -------------------------------------
derive_pll_clocks -use_tan_name

# Original Clock Setting Name: pClk21m
# ------------------------------------
create_clock -period "46.554 ns" -name {pClk21m} {pClk21m}

# ** Multicycles
# --------------
set_multicycle_path -from [get_clocks {PLL4X:U00|altpll:altpll_component|_clk0}] -to [get_clocks {PLL4X:U00|altpll:altpll_component|_clk1}] -setup 2
set_multicycle_path -from [get_clocks {PLL4X:U00|altpll:altpll_component|_clk0}] -to [get_clocks {PLL4X:U00|altpll:altpll_component|_clk1}] -hold 1
set_multicycle_path -from [get_clocks {PLL4X:U00|altpll:altpll_component|_clk1}] -to [get_clocks {PLL4X:U00|altpll:altpll_component|_clk0}] -setup 2
set_multicycle_path -from [get_clocks {PLL4X:U00|altpll:altpll_component|_clk1}] -to [get_clocks {PLL4X:U00|altpll:altpll_component|_clk0}] -hold 1

# ** Input/Output Delays
# ----------------------
set_input_delay -clock [get_clocks {PLL4X:U00|altpll:altpll_component|_clk1}] -max 6.4 [get_ports pMemDat[*]]
set_input_delay -clock [get_clocks {PLL4X:U00|altpll:altpll_component|_clk1}] -min 3.2 [get_ports pMemDat[*]]
set_output_delay -clock [get_clocks {PLL4X:U00|altpll:altpll_component|_clk1}] -max  1.5 [get_ports {pMemDat[*] pMemAdr[*] pMemLdq pMemUdq pMemWe_n pMemCas_n pMemRas_n pMemCs_n}]
set_output_delay -clock [get_clocks {PLL4X:U00|altpll:altpll_component|_clk1}] -min -0.8 [get_ports {pMemDat[*] pMemAdr[*] pMemLdq pMemUdq pMemWe_n pMemCas_n pMemRas_n pMemCs_n}]
