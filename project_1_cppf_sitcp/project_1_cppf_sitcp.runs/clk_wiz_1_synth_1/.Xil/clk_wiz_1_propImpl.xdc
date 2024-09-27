set_property SRC_FILE_INFO {cfile:c:/Users/DELL/Desktop/mft_k7_project/9.26/project_1_cppf_sitcp/project_1_cppf_sitcp.srcs/sources_1/ip/clk_wiz_1/clk_wiz_1.xdc rfile:../../../project_1_cppf_sitcp.srcs/sources_1/ip/clk_wiz_1/clk_wiz_1.xdc id:1 order:EARLY scoped_inst:inst} [current_design]
current_instance inst
set_property src_info {type:SCOPED_XDC file:1 line:57 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk_in1]] 0.08
