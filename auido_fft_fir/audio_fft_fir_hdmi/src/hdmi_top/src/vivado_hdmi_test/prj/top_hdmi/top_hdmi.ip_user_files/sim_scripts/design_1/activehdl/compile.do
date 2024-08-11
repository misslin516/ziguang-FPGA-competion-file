vlib work
vlib activehdl

vlib activehdl/xilinx_vip
vlib activehdl/xpm
vlib activehdl/xil_defaultlib

vmap xilinx_vip activehdl/xilinx_vip
vmap xpm activehdl/xpm
vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xilinx_vip  -sv2k12 "+incdir+D:/xinlinx/Vivado/2021.1/data/xilinx_vip/include" \
"D:/xinlinx/Vivado/2021.1/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"D:/xinlinx/Vivado/2021.1/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"D:/xinlinx/Vivado/2021.1/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"D:/xinlinx/Vivado/2021.1/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"D:/xinlinx/Vivado/2021.1/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"D:/xinlinx/Vivado/2021.1/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"D:/xinlinx/Vivado/2021.1/data/xilinx_vip/hdl/axi_vip_if.sv" \
"D:/xinlinx/Vivado/2021.1/data/xilinx_vip/hdl/clk_vip_if.sv" \
"D:/xinlinx/Vivado/2021.1/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm  -sv2k12 "+incdir+../../../../top_hdmi.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../top_hdmi.gen/sources_1/bd/design_1/ipshared/f42d/hdl" "+incdir+D:/xinlinx/Vivado/2021.1/data/xilinx_vip/include" \
"D:/xinlinx/Vivado/2021.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/xinlinx/Vivado/2021.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"D:/xinlinx/Vivado/2021.1/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../top_hdmi.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../top_hdmi.gen/sources_1/bd/design_1/ipshared/f42d/hdl" "+incdir+D:/xinlinx/Vivado/2021.1/data/xilinx_vip/include" \
"c:/Users/86151/Desktop/auido_fft_fir/audio_fft_fir_hdmi/src/hdmi_top/src/vivado_hdmi_test/prj/top_hdmi/top_hdmi.gen/sources_1/bd/design_1/ip/design_1_processing_system7_0_0/design_1_processing_system7_0_0_sim_netlist.v" \
"../../../bd/design_1/sim/design_1.v" \

vlog -work xil_defaultlib \
"glbl.v"

