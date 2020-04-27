onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib sdram_ddr_opt

do {wave.do}

view wave
view structure
view signals

do {sdram_ddr.udo}

run -all

quit -force
