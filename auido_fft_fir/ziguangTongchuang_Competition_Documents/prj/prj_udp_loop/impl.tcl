#Generated by Fabric Compiler ( version 2022.1 <build 99559> ) at Sun May 26 10:19:28 2024

add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/gmii_to_rgmii.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/udp_loop.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/udp_rx.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/udp_top.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/udp_tx.v"
add_design C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/prj/prj_udp_loop/ipcore/fifo_udp_loop/fifo_udp_loop.idf
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/crc32_d8.v"
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module udp_loop
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
add_constraint "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/prj/prj_udp_loop/source/udp_top/udp_loop.fdc"
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module udp_loop
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/eth_ctrl.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/arp/arp.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/arp/arp_rx.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/arp/arp_tx.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/icmp/icmp.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/icmp/icmp_rx.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/icmp/icmp_tx.v"
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module udp_loop
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
