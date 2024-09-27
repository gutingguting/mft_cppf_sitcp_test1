onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+ETH_1000BASEX -L gig_ethernet_pcs_pma_v16_1_6 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.ETH_1000BASEX xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {ETH_1000BASEX.udo}

run -all

endsim

quit -force
