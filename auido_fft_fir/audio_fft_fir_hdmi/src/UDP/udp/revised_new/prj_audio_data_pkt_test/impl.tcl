#Generated by Fabric Compiler ( version 2022.1 <build 99559> ) at Wed May  1 15:58:36 2024

add_design C:/Users/86151/Desktop/auido_fft_fir/audio_fft_fir_hdmi/src/UDP/udp/revised_new/prj_audio_data_pkt_test/ipcore/fifo_audo_data_pkt/fifo_audo_data_pkt.idf
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_fft_fir_hdmi/src/UDP/udp/revised_new/audio_data_pkt.v"
add_simulation "C:/Users/86151/Desktop/auido_fft_fir/audio_fft_fir_hdmi/src/UDP/udp/revised_new/prj_audio_data_pkt_test/sim/tb_audio_data_pkt.v"
set_arch -family Logos -device PGL12G -speedgrade -5 -package FBG256
compile -top_module audio_data_pkt
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL12G -speedgrade -5 -package FBG256
compile -top_module audio_data_pkt
synthesize -ads -selected_syn_tool_opt 2 
set_arch -family Logos -device PGL12G -speedgrade -5 -package FBG256
compile -top_module audio_data_pkt
synthesize -ads -selected_syn_tool_opt 2 
synthesize -ads -selected_syn_tool_opt 2 
set_arch -family Logos -device PGL12G -speedgrade -5 -package FBG256
compile -top_module audio_data_pkt
synthesize -ads -selected_syn_tool_opt 2 
set_arch -family Logos -device PGL12G -speedgrade -5 -package FBG256
compile -top_module audio_data_pkt
synthesize -ads -selected_syn_tool_opt 2 
set_arch -family Logos -device PGL12G -speedgrade -5 -package FBG256
compile -top_module audio_data_pkt
synthesize -ads -selected_syn_tool_opt 2 
