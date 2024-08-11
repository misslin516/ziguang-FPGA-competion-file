file delete -force work
file delete -force vsim_ipsxe_fft_onboard_top.log
vlib  work
vmap  work work
vlog -incr -sv \
D:/fpga_competition/FPGA_competition/ziguangtongchuang_file/MES50HP_v3/set_up/set_up_file/PDS_2022.1/ip/system_ip/../../arch/vendor/pango/verilog/simulation/GTP_APM_E1.v \
D:/fpga_competition/FPGA_competition/ziguangtongchuang_file/MES50HP_v3/set_up/set_up_file/PDS_2022.1/ip/system_ip/../../arch/vendor/pango/verilog/simulation/GTP_DRM18K_E1.v \
D:/fpga_competition/FPGA_competition/ziguangtongchuang_file/MES50HP_v3/set_up/set_up_file/PDS_2022.1/ip/system_ip/../../arch/vendor/pango/verilog/simulation/GTP_DRM18K.v \
D:/fpga_competition/FPGA_competition/ziguangtongchuang_file/MES50HP_v3/set_up/set_up_file/PDS_2022.1/ip/system_ip/../../arch/vendor/pango/verilog/simulation/GTP_DRM9K.v \
D:/fpga_competition/FPGA_competition/ziguangtongchuang_file/MES50HP_v3/set_up/set_up_file/PDS_2022.1/ip/system_ip/../../arch/vendor/pango/verilog/simulation/GTP_GRS.v \
-f ./ipsxe_fft_onboard_top_filelist.f -l vlog.log
vsim {-voptargs=+acc} -suppress 12110 work.ipsxe_fft_onboard_top_tb -l vsim.log
do ipsxe_fft_onboard_top_wave.do
run -all
