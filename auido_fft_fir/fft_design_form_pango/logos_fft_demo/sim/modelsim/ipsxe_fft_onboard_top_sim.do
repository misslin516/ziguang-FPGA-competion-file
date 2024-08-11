file delete -force work
file delete -force vsim_ipsxe_fft_onboard_top.log
vlib  work
vmap  work work
vlog -incr -sv \
E:/software/PDS_trunk-pro-win64-svn139183-pm5/ip/system_ip/ipsxe_fft_eval/ipsxe_fft/../../../../arch/vendor/pango/verilog/simulation/GTP_APM_E1.v \
E:/software/PDS_trunk-pro-win64-svn139183-pm5/ip/system_ip/ipsxe_fft_eval/ipsxe_fft/../../../../arch/vendor/pango/verilog/simulation/GTP_DRM18K_E1.v \
E:/software/PDS_trunk-pro-win64-svn139183-pm5/ip/system_ip/ipsxe_fft_eval/ipsxe_fft/../../../../arch/vendor/pango/verilog/simulation/GTP_DRM18K.v \
E:/software/PDS_trunk-pro-win64-svn139183-pm5/ip/system_ip/ipsxe_fft_eval/ipsxe_fft/../../../../arch/vendor/pango/verilog/simulation/GTP_DRM9K.v \
E:/software/PDS_trunk-pro-win64-svn139183-pm5/ip/system_ip/ipsxe_fft_eval/ipsxe_fft/../../../../arch/vendor/pango/verilog/simulation/GTP_GRS.v \
-f ./ipsxe_fft_onboard_top_filelist.f -l vlog.log
vsim {-voptargs=+acc} -suppress 12110 work.ipsxe_fft_onboard_top_tb -l vsim.log
do ipsxe_fft_onboard_top_wave.do
run -all
