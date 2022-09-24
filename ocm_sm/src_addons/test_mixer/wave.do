onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /tb/u_psg/clk21m
add wave -noupdate -radix unsigned /tb/u_psg/reset
add wave -noupdate -radix unsigned /tb/u_psg/clkena
add wave -noupdate -radix unsigned /tb/u_psg/req
add wave -noupdate -radix unsigned /tb/u_psg/ack
add wave -noupdate -radix unsigned /tb/u_psg/wrt
add wave -noupdate -radix unsigned /tb/u_psg/adr
add wave -noupdate -radix unsigned /tb/u_psg/dbi
add wave -noupdate -radix unsigned /tb/u_psg/dbo
add wave -noupdate -radix unsigned /tb/u_psg/joya_in
add wave -noupdate -radix unsigned /tb/u_psg/joya_out
add wave -noupdate -radix unsigned /tb/u_psg/stra
add wave -noupdate -radix unsigned /tb/u_psg/joyb_in
add wave -noupdate -radix unsigned /tb/u_psg/joyb_out
add wave -noupdate -radix unsigned /tb/u_psg/strb
add wave -noupdate -radix unsigned /tb/u_psg/kana
add wave -noupdate -radix unsigned /tb/u_psg/cmtin
add wave -noupdate -radix unsigned /tb/u_psg/keymode
add wave -noupdate -radix unsigned /tb/u_psg/wave
add wave -noupdate -radix unsigned /tb/u_psg/psgdbi
add wave -noupdate -radix unsigned /tb/u_psg/psgregptr
add wave -noupdate -radix unsigned /tb/u_psg/rega
add wave -noupdate -radix unsigned /tb/u_psg/regb
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 160
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 2
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {144007115 ps}
