#Generated by Fabric Compiler ( version 2022.1 <build 99559> ) at Wed Mar 27 13:56:46 2024

add_design C:/Users/86151/Desktop/auido_fft_fir/pango_fifo_test/prj/fifo_test/ipcore/fifo1/fifo1.idf
add_design "C:/Users/86151/Desktop/auido_fft_fir/pango_fifo_test/prj/fifo_test/src/fifo_test.v"
add_simulation "C:/Users/86151/Desktop/auido_fft_fir/pango_fifo_test/prj/fifo_test/sim/tb_fifo_test.v"
set_arch -family Logos -device PGL12G -speedgrade -6 -package LPG144
synthesize -synplify_pro -selected_syn_tool_opt 1 -top_module fifo_test
set_arch -family Logos -device PGL12G -speedgrade -6 -package LPG144
synthesize -synplify_pro -selected_syn_tool_opt 1 -top_module fifo_test
set_arch -family Logos -device PGL12G -speedgrade -6 -package LPG144
synthesize -synplify_pro -selected_syn_tool_opt 1 -top_module fifo_test
set_arch -family Logos -device PGL12G -speedgrade -6 -package LPG144
synthesize -synplify_pro -selected_syn_tool_opt 1 -top_module fifo_test
set_arch -family Logos -device PGL12G -speedgrade -6 -package LPG144
synthesize -synplify_pro -selected_syn_tool_opt 1 -top_module fifo_test
set_arch -family Logos -device PGL12G -speedgrade -6 -package LPG144
compile -top_module fifo_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL12G -speedgrade -6 -package LPG144
compile -top_module fifo_test
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
