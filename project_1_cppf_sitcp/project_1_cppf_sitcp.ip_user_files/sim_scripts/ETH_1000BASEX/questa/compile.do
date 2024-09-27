vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/gig_ethernet_pcs_pma_v16_1_6
vlib questa_lib/msim/xil_defaultlib

vmap gig_ethernet_pcs_pma_v16_1_6 questa_lib/msim/gig_ethernet_pcs_pma_v16_1_6
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vcom -work gig_ethernet_pcs_pma_v16_1_6 -64 -93 \
"../../../ipstatic/hdl/gig_ethernet_pcs_pma_v16_1_rfs.vhd" \

vlog -work gig_ethernet_pcs_pma_v16_1_6 -64 \
"../../../ipstatic/hdl/gig_ethernet_pcs_pma_v16_1_rfs.v" \

vcom -work xil_defaultlib -64 -93 \
"../../../../project_1_cppf_sitcp.srcs/sources_1/ip/ETH_1000BASEX/synth/transceiver/ETH_1000BASEX_cpll_railing.vhd" \
"../../../../project_1_cppf_sitcp.srcs/sources_1/ip/ETH_1000BASEX/synth/transceiver/ETH_1000BASEX_gtwizard.vhd" \
"../../../../project_1_cppf_sitcp.srcs/sources_1/ip/ETH_1000BASEX/synth/transceiver/ETH_1000BASEX_gtwizard_multi_gt.vhd" \
"../../../../project_1_cppf_sitcp.srcs/sources_1/ip/ETH_1000BASEX/synth/transceiver/ETH_1000BASEX_gtwizard_gt.vhd" \
"../../../../project_1_cppf_sitcp.srcs/sources_1/ip/ETH_1000BASEX/synth/transceiver/ETH_1000BASEX_gtwizard_init.vhd" \
"../../../../project_1_cppf_sitcp.srcs/sources_1/ip/ETH_1000BASEX/synth/transceiver/ETH_1000BASEX_tx_startup_fsm.vhd" \
"../../../../project_1_cppf_sitcp.srcs/sources_1/ip/ETH_1000BASEX/synth/transceiver/ETH_1000BASEX_rx_startup_fsm.vhd" \
"../../../../project_1_cppf_sitcp.srcs/sources_1/ip/ETH_1000BASEX/synth/ETH_1000BASEX_reset_sync.vhd" \
"../../../../project_1_cppf_sitcp.srcs/sources_1/ip/ETH_1000BASEX/synth/ETH_1000BASEX_sync_block.vhd" \
"../../../../project_1_cppf_sitcp.srcs/sources_1/ip/ETH_1000BASEX/synth/transceiver/ETH_1000BASEX_reset_wtd_timer.vhd" \
"../../../../project_1_cppf_sitcp.srcs/sources_1/ip/ETH_1000BASEX/synth/transceiver/ETH_1000BASEX_transceiver.vhd" \
"../../../../project_1_cppf_sitcp.srcs/sources_1/ip/ETH_1000BASEX/synth/ETH_1000BASEX_block.vhd" \
"../../../../project_1_cppf_sitcp.srcs/sources_1/ip/ETH_1000BASEX/synth/ETH_1000BASEX.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

