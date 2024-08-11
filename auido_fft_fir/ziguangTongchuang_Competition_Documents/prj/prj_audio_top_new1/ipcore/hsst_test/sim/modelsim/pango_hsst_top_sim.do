file delete -force work
vlib  work
vmap  work work
vlog -incr +define+IPML_HSST_SPEEDUP_SIM \
D:/fpga_competition/FPGA_competition/ziguangtongchuang_file/MES50HP_v3/set_up/set_up_file/PDS_2022.1/ip/module_ip/ipml_flex_hsst/ipml_hsst_eval/ipml_hsst/../../../../../arch/vendor/pango/verilog/simulation/modelsim10.2c/hsst_e2_source_codes/*.vp\
D:/fpga_competition/FPGA_competition/ziguangtongchuang_file/MES50HP_v3/set_up/set_up_file/PDS_2022.1/ip/module_ip/ipml_flex_hsst/ipml_hsst_eval/ipml_hsst/../../../../../arch/vendor/pango/verilog/simulation/GTP_HSST_E2.v \
-f ./pango_hsst_top_filelist.f -l vlog.log
vsim -novopt +define+IPML_HSST_SPEEDUP_SIM work.hsst_test_top_tb -l vsim.log
do pango_hsst_top_wave.do
run -all
