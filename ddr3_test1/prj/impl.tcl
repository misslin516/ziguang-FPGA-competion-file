#Generated by Fabric Compiler ( version 2022.1 <build 99559> ) at Mon Jun  3 11:21:43 2024

add_design "C:/Users/86151/Desktop/ddr3_test1/src/axi_m.v"
add_design "C:/Users/86151/Desktop/ddr3_test1/src/axi_m_revised.v"
add_design "C:/Users/86151/Desktop/ddr3_test1/src/axi_m_top.v"
add_design "C:/Users/86151/Desktop/ddr3_test1/src/ddr_test.v"
add_design "C:/Users/86151/Desktop/ddr3_test1/src/ddr3_test.v"
add_design "C:/Users/86151/Desktop/ddr3_test1/src/led_disp.v"
add_design "C:/Users/86151/Desktop/ddr3_test1/src/rw_fifo_ctrl.v"
remove_design -verilog "C:/Users/86151/Desktop/ddr3_test1/src/axi_m.v"
remove_design -verilog "C:/Users/86151/Desktop/ddr3_test1/src/ddr_test.v"
add_design "C:/Users/86151/Desktop/ddr3_test1/src/ddr_data_inandout.v"
add_design C:/Users/86151/Desktop/ddr3_test1/prj/ipcore/ddr_test/ddr_test.idf
add_constraint "C:/Users/86151/Desktop/ddr3_test1/prj/source/src/ddr3_test.fdc"
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
add_design C:/Users/86151/Desktop/ddr3_test1/prj/ipcore/write_ddr_fifo/write_ddr_fifo.idf
add_design C:/Users/86151/Desktop/ddr3_test1/prj/ipcore/read_ddr_fifo/read_ddr_fifo.idf
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
add_fic "C:/Users/86151/Desktop/ddr3_test1/prj/synthesize/ddr3_test_syn.fic"
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
dev_map 
dev_map 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
remove_fic "C:/Users/86151/Desktop/ddr3_test1/prj/synthesize/ddr3_test_syn.fic"
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
add_fic "C:/Users/86151/Desktop/ddr3_test1/prj/synthesize/ddr3_test_syn.fic"
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
add_design "C:/Users/86151/Desktop/ddr3_test1/src/axi_m.v"
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
add_simulation "C:/Users/86151/Desktop/ddr3_test1/src/ddr_sim.v"
remove_fic "C:/Users/86151/Desktop/ddr3_test1/prj/synthesize/ddr3_test_syn.fic"
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
add_fic "C:/Users/86151/Desktop/ddr3_test1/prj/synthesize/ddr3_test_syn.fic"
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
remove_fic -force"C:/Users/86151/Desktop/ddr3_test1/prj/synthesize/ddr3_test_syn.fic"
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
remove_simulation "C:/Users/86151/Desktop/ddr3_test1/src/ddr_sim.v"
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
add_fic "C:/Users/86151/Desktop/ddr3_test1/prj/synthesize/ddr3_test_syn.fic"
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
synthesize -ads -selected_syn_tool_opt 2 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
dev_map 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module ddr3_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
