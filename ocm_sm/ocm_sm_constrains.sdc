# Create generated clocks based on PLLs
# -------------------------------------
derive_pll_clocks -create_base_clocks

derive_clock_uncertainty

# ** Multicycles
# --------------
set_multicycle_path -from [get_clocks {ocm|U00|altpll_component|auto_generated|pll1|clk[0]}] -to [get_clocks {ocm|U00|altpll_component|auto_generated|pll1|clk[1]}] -setup 2
set_multicycle_path -from [get_clocks {ocm|U00|altpll_component|auto_generated|pll1|clk[0]}] -to [get_clocks {ocm|U00|altpll_component|auto_generated|pll1|clk[1]}] -hold 1
set_multicycle_path -from [get_clocks {ocm|U00|altpll_component|auto_generated|pll1|clk[1]}] -to [get_clocks {ocm|U00|altpll_component|auto_generated|pll1|clk[0]}] -setup 2
set_multicycle_path -from [get_clocks {ocm|U00|altpll_component|auto_generated|pll1|clk[1]}] -to [get_clocks {ocm|U00|altpll_component|auto_generated|pll1|clk[0]}] -hold 1

# ** Input/Output Delays
# ----------------------
set_input_delay -clock [get_clocks {ocm|U00|altpll_component|auto_generated|pll1|clk[1]}] -max 6.4 [get_ports sdram_da_io[*]]
set_input_delay -clock [get_clocks {ocm|U00|altpll_component|auto_generated|pll1|clk[1]}] -min 3.2 [get_ports sdram_da_io[*]]
set_output_delay -clock [get_clocks {ocm|U00|altpll_component|auto_generated|pll1|clk[1]}] -max  1.5 [get_ports {sdram_da_io[*] sdram_ad_o[*] sdram_dqm_o[*] sdram_we_o sdram_cas_o sdram_ras_o sdram_cs_o}]
set_output_delay -clock [get_clocks {ocm|U00|altpll_component|auto_generated|pll1|clk[1]}] -min -0.8 [get_ports {sdram_da_io[*] sdram_ad_o[*] sdram_dqm_o[*] sdram_we_o sdram_cas_o sdram_ras_o sdram_cs_o}]
