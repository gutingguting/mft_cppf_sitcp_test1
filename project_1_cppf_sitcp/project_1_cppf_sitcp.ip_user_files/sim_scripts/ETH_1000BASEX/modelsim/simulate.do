onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L gig_ethernet_pcs_pma_v16_1_6 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.ETH_1000BASEX xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {ETH_1000BASEX.udo}

run -all

quit -force
