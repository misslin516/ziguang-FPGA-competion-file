#Generated by Fabric Compiler ( version 2022.1 <build 99559> ) at Thu May  9 10:21:21 2024

add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/audio_fft_top.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/asyn_fifo.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/cordic_jpl.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/cordic_newton.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/data_module_fft.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/fft_ctrl.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/fft_test.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/fft_top.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/cordic_newton.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/fft_test.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/pnr/core_only/ipsxe_fft_core_only.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/example_design/rtl/ipsxe_fft_frame_chk.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/example_design/rtl/ipsxe_fft_frame_gen.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/example_design/rtl/ipsxe_fft_onboard_top.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/example_design/rtl/ipsxe_fft_sync_arstn.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/distram_sdpram/ipsxe_fft_distram_sdpram.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/distram_sreg/ipsxe_fft_distram_sreg.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/distram_sreg/rtl/ipsxe_fft_distributed_sdpram_v1_2.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/distram_sreg/rtl/ipsxe_fft_distributed_shiftregister_v1_3.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/drm_sdpram/ipsxe_fft_drm_sdpram_18k.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/drm_sdpram/ipsxe_fft_drm_sdpram_36k.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/drm_sdpram/rtl/drm_init_param.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/drm_sdpram/rtl/ipml_sdpram_v1_7_drm.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/synplify/ipsxe_fft_core_v1_1_vpAll.vp"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/fft_demo_00.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/ipsxe_fft_exp_rom.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/example_design/rtl/ipsxe_fft_onboard_top.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/example_design/rtl/ipsxe_fft_frame_chk.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/example_design/rtl/ipsxe_fft_frame_gen.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/example_design/rtl/ipsxe_fft_sync_arstn.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/ipsxe_fft_exp_rom.v"
set_arch -family Logos -device PGL12G -speedgrade -5 -package FBG256
compile -top_module audio_fft_top
set_arch -family Logos -device PGL12G -speedgrade -5 -package FBG256
compile -top_module audio_fft_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/example_design/rtl/ipsxe_fft_frame_chk.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/example_design/rtl/ipsxe_fft_frame_gen.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/example_design/rtl/ipsxe_fft_onboard_top.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/example_design/rtl/ipsxe_fft_sync_arstn.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/ipsxe_fft_exp_rom.v"
set_arch -family Logos -device PGL12G -speedgrade -5 -package FBG256
compile -top_module audio_fft_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
dev_map 
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/example_design/rtl/ipsxe_fft_onboard_top.v"
set_arch -family Logos -device PGL12G -speedgrade -5 -package FBG256
compile -top_module audio_fft_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/drm_sdpram/rtl/drm_init_param.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/example_design/rtl/ipsxe_fft_sync_arstn.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/example_design/rtl/ipsxe_fft_frame_gen.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/example_design/rtl/ipsxe_fft_frame_chk.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/fft_demo_00.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/synplify/ipsxe_fft_core_v1_1_vpAll.vp"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/synplify/ipsxe_fft_core_v1_1_vpAll.vp"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/synplify/ipsxe_fft_core_v1_1_vpAll.vp"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/synplify/ipsxe_fft_core_v1_1_vpAll.vp"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/synplify/ipsxe_fft_core_v1_1_vpAll.vp"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/synplify/ipsxe_fft_core_v1_1_vpAll.vp"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/pnr/core_only/ipsxe_fft_core_only.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/distram_sdpram/ipsxe_fft_distram_sdpram.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/distram_sreg/ipsxe_fft_distram_sreg.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/drm_sdpram/ipsxe_fft_drm_sdpram_18k.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/drm_sdpram/ipsxe_fft_drm_sdpram_36k.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/ipsxe_fft_exp_rom.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/drm_sdpram/rtl/ipml_sdpram_v1_7_drm.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/distram_sreg/rtl/ipsxe_fft_distributed_shiftregister_v1_3.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/distram_sreg/rtl/ipsxe_fft_distributed_sdpram_v1_2.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/fft_demo_00.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/ipsxe_fft_exp_rom.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/example_design/rtl/ipsxe_fft_frame_chk.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/example_design/rtl/ipsxe_fft_frame_gen.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/example_design/rtl/ipsxe_fft_onboard_top.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/example_design/rtl/ipsxe_fft_sync_arstn.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/pnr/core_only/ipsxe_fft_core_only.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/distram_sdpram/ipsxe_fft_distram_sdpram.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/distram_sreg/ipsxe_fft_distram_sreg.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/distram_sreg/rtl/ipsxe_fft_distributed_sdpram_v1_2.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/distram_sreg/rtl/ipsxe_fft_distributed_shiftregister_v1_3.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/drm_sdpram/ipsxe_fft_drm_sdpram_18k.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/drm_sdpram/ipsxe_fft_drm_sdpram_36k.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/drm_sdpram/rtl/drm_init_param.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/drm_sdpram/rtl/ipml_sdpram_v1_7_drm.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/synplify/ipsxe_fft_core_v1_1_vpAll.vp"
set_arch -family Logos -device PGL12G -speedgrade -5 -package FBG256
compile -top_module audio_fft_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
dev_map 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_fft_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
add_simulation "C:/Users/86151/Desktop/auido_fft_fir/audio_top/prj_file_test/prj_audio_fft_top/sim/tb_audio_fft_top.v"
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_fft_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/example_design/rtl/ipsxe_fft_onboard_top.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/example_design/rtl/ipsxe_fft_sync_arstn.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/example_design/rtl/ipsxe_fft_frame_gen.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/fft_demo_00.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/example_design/rtl/ipsxe_fft_frame_chk.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/fft_demo_00.v"
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_fft_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_fft_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/drm_sdpram/rtl/drm_init_param.v"
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_fft_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/fft_top/logos_fft_demo/rtl/drm_sdpram/rtl/drm_init_param.v"
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_fft_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_fft_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_fft_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_fft_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
remove_simulation "C:/Users/86151/Desktop/auido_fft_fir/audio_top/prj_file_test/prj_audio_fft_top/sim/tb_audio_fft_top.v"
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_fft_top
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/hdmi_top/src/hdmi_test_revised.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/hdmi_top/src/hdmi_top.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/hdmi_top/src/iic_dri.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/hdmi_top/src/ms72xx_ctl.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/hdmi_top/src/ms7200_ctl.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/hdmi_top/src/ms7210_ctl.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/hdmi_top/src/pattern_vg_revised.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/hdmi_top/src/rw_ram_ctrl.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/hdmi_top/src/single_ram.v"
add_design "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/hdmi_top/src/sync_vg_revised.v"
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_fft_top
add_design C:/Users/86151/Desktop/auido_fft_fir/audio_top/prj_file_test/prj_audio_fft_top/ipcore/pll/pll.idf
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_fft_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_fft_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_fft_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_fft_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_fft_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_fft_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_fft_top
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_fft_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
add_constraint "C:/Users/86151/Desktop/auido_fft_fir/audio_top/prj_file_test/prj_audio_fft_top/source/prj_audio_fft_top/audio_fft_top.fdc"
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_fft_top
synthesize -ads -selected_syn_tool_opt 2 
synthesize -ads -selected_syn_tool_opt 2 
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
add_fic "C:/Users/86151/Desktop/auido_fft_fir/audio_top/prj_file_test/prj_audio_fft_top/synthesize/audio_fft_top_syn.fic"
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_fft_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/hdmi_top/src/hdmi_top.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/hdmi_top/src/hdmi_test_revised.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/hdmi_top/src/rw_ram_ctrl.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/hdmi_top/src/ms72xx_ctl.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/hdmi_top/src/pattern_vg_revised.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/hdmi_top/src/single_ram.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/hdmi_top/src/sync_vg_revised.v"
remove_design C:/Users/86151/Desktop/auido_fft_fir/audio_top/prj_file_test/prj_audio_fft_top/ipcore/pll/pll.idf
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/hdmi_top/src/ms7210_ctl.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/hdmi_top/src/ms7200_ctl.v"
remove_design -verilog "C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/hdmi_top/src/iic_dri.v"
remove_constraint  -logic -fdc "C:/Users/86151/Desktop/auido_fft_fir/audio_top/prj_file_test/prj_audio_fft_top/source/prj_audio_fft_top/audio_fft_top.fdc"
remove_fic "C:/Users/86151/Desktop/auido_fft_fir/audio_top/prj_file_test/prj_audio_fft_top/synthesize/audio_fft_top_syn.fic"
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_fft_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
add_simulation "C:/Users/86151/Desktop/auido_fft_fir/audio_top/prj_file_test/prj_audio_fft_top/sim/tb_audio_fft_top.v"
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_fft_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_fft_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module audio_fft_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 