onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib ETH_1000BASEX_opt

do {wave.do}

view wave
view structure
view signals

do {ETH_1000BASEX.udo}

run -all

quit -force
