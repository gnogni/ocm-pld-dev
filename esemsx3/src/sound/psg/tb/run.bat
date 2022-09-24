vlib work
vcom ../psg.vhd
vcom ../psg_wave.vhd
vlog tb.sv
pause "[Please check error(s)]"

vsim -c -t 1ps -do run.do tb
move transcript log.txt
