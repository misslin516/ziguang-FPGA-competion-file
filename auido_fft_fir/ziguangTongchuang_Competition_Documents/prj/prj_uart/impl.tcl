#Generated by Fabric Compiler ( version 2022.1 <build 99559> ) at Fri May 24 09:41:19 2024

add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/uart/uart_loopback.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/uart/uart_rx.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/uart/uart_tx.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/uart/uart_loopback.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/uart/uart_tx.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/uart/uart_rx.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/uart/key_filter.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/uart/key_uart.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/uart/uart_data_gen.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/uart/uart_rx.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/uart/uart_top.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/uart/uart_tx.v"
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module key_uart
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
add_constraint "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/prj/prj_uart/source/uart/uart_test.fdc"
pnr 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module key_uart
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module key_uart
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module key_uart
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module key_uart
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module key_uart
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module key_uart
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module key_uart
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module key_uart
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module key_uart
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module key_uart
synthesize -ads -selected_syn_tool_opt 2 
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module key_uart
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module key_uart
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module key_uart
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 