vlib work
vcom lpf.vhd
vcom tapram.vhd
vcom esefir5.vhd
vcom esepwm.vhd
vcom -2008 sm_emsx_top.vhd
vlog tb.sv
pause "[Please check error(s)]"

vsim -c -t 1ps -do run.do tb
move transcript log.txt
