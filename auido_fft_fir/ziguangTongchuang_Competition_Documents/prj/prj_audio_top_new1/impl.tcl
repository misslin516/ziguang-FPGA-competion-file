#Generated by Fabric Compiler ( version 2022.1 <build 99559> ) at Thu Jul 11 14:57:10 2024

set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
add_fic "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/prj/prj_audio_top_new1/synthesize/audio_top_syn.fic"
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/prj/prj_audio_top_new1/src/udp_top/udp_top1.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/prj/prj_audio_top_new1/src/udp_top/audio_data_pkt1_revised.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/prj/prj_audio_top_new1/src/udp_top/gmii_to_rgmii.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/prj/prj_audio_top_new1/src/udp_top/udp_top.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/prj/prj_audio_top_new1/src/udp_top/udp_rx.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/prj/prj_audio_top_new1/src/udp_top/udp_tx.v"
remove_design C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/prj/prj_audio_top_new1/ipcore/fifo_audo_data_pkt/fifo_audo_data_pkt.idf
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/udp_PDS/arp_cache.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/udp_PDS/arp_mac_top.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/udp_PDS/arp_rx.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/udp_PDS/arp_tx.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/udp_PDS/check_sum.vh"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/udp_PDS/crc32_gen.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/udp_PDS/eth_udp_test.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/udp_PDS/ethernet_test.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/udp_PDS/fifo_ctrl_eth.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/udp_PDS/icmp.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/udp_PDS/ip_layer.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/udp_PDS/ip_rx.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/udp_PDS/ip_tx.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/udp_PDS/ip_tx_mode.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/udp_PDS/mac_layer.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/udp_PDS/mac_rx.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/udp_PDS/mac_tx.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/udp_PDS/mac_tx_mode.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/udp_PDS/rgmii_interface.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/udp_PDS/udp_ip_mac_top.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/udp_PDS/udp_layer.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/udp_PDS/udp_rx.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/udp_PDS/udp_tx.v"
add_design C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/prj/prj_audio_top_new1/ipcore/ram0/ram0.idf
remove_design -force C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/prj/prj_audio_top_new1/ipcore/ram0/ram0.idf
add_design C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/prj/prj_audio_top_new1/ipcore/ram0/ram0.idf
remove_design C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/prj/prj_audio_top_new1/ipcore/ram0/ram0.idf
add_design C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/prj/prj_audio_top_new1/ipcore/ram0/ram0.idf
add_design C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/prj/prj_audio_top_new1/ipcore/ref_clock/ref_clock.idf
add_design C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/prj/prj_audio_top_new1/ipcore/udp_shift_register/udp_shift_register.idf
add_design C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/prj/prj_audio_top_new1/ipcore/icmp_rx_ram_8_256/icmp_rx_ram_8_256.idf
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/prj/prj_audio_top_new1/src/udp_top/crc32_d8.v"
synthesize -ads -selected_syn_tool_opt 2 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/UDP_test/crc32_d8.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/UDP_test/udp.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/UDP_test/udp_rec_top.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/UDP_test/udp_rx.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/UDP_test/udp_tx.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/udp_top/gmii_to_rgmii.v"
add_design C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/prj/prj_audio_top_new1/ipcore/cdc_fifo/cdc_fifo.idf
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/audio/i2s_loop_generate.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/prj/prj_audio_top_new1/src/audio/i2s_loop.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/audio/i2s_loop_generate.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/audio/i2s_loop_generate.v"
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
add_design C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/prj/prj_audio_top_new1/ipcore/pll_eth/pll_eth.idf
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
remove_design -force C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/prj/prj_audio_top_new1/ipcore/pll_eth/pll_eth.idf
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/audio/i2s_loop_generate.sv"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/audio/i2s_loop_generate.v"
add_design C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/prj/prj_audio_top_new1/ipcore/hsst_test/hsst_test.idf
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/hsst/src/hsst_test_chk.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/hsst/src/hsst_test_dut_top.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/hsst/src/hsst_test_if.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/hsst/src/hsst_test_if_top.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/hsst/src/hsst_test_src.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/hsst/src/hsst_test_top.v"
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
add_design C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/prj/prj_audio_top_new1/ipcore/hsst_fifo/hsst_fifo.idf
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/hsst/src/hsst_test_top.v"
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
dev_map 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/audio_recognization/auido_recognization.sv"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/audio_recognization/divide.v"
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/audio_recognization/auido_recognization_top.sv"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/audio_recognization/data_comparator.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/audio_recognization/auido_recognization.sv"
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
dev_map 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/audio/i2s_loop_remove_music.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/audio/i2s_loop_remove_vocals.v"
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
dev_map 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/audio/i2s_loop_remove_music.sv"
add_design "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/audio/i2s_loop_remove_vocals.sv"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/audio/i2s_loop_remove_music.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/audio/i2s_loop_remove_vocals.v"
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
pnr 
pnr 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
pnr 
pnr 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
