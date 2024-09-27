
set_property IOSTANDARD LVDS_25 [get_ports sysclk_p]
set_property IOSTANDARD LVDS_25 [get_ports sysclk_n]

set_property PACKAGE_PIN D14 [get_ports sysclk_n]
set_property PACKAGE_PIN E14 [get_ports sysclk_p]

set_property PACKAGE_PIN F6 [get_ports gtrefclk_p]
set_property PACKAGE_PIN F5 [get_ports gtrefclk_n]
set_property IOSTANDARD LVDS_25 [get_ports gtrefclk_p]
set_property IOSTANDARD LVDS_25 [get_ports gtrefclk_n]

set_property PACKAGE_PIN G3 [get_ports rxn]
set_property PACKAGE_PIN G4 [get_ports rxp]
set_property PACKAGE_PIN F1 [get_ports txn]
set_property PACKAGE_PIN F2 [get_ports txp]


create_clock -period 8.000 -name sysclk_p -waveform {0.000 4.000} [get_ports sysclk_p]
create_clock -period 8.000 -name gtrefclk_p -waveform {0.000 4.000} [get_ports gtrefclk_p]

