onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Clock&Reset Ports}
add wave -noupdate /ipsxe_fft_onboard_top_tb/u_onboard_top/u_fft_wrapper/i_aclk
add wave -noupdate -divider {Configuration Input Ports}
add wave -noupdate /ipsxe_fft_onboard_top_tb/u_onboard_top/u_fft_wrapper/i_axi4s_cfg_tdata
add wave -noupdate /ipsxe_fft_onboard_top_tb/u_onboard_top/u_fft_wrapper/i_axi4s_cfg_tvalid
add wave -noupdate -divider {Data Input Ports}
add wave -noupdate -radix hexadecimal /ipsxe_fft_onboard_top_tb/u_onboard_top/u_fft_wrapper/i_axi4s_data_tdata
add wave -noupdate /ipsxe_fft_onboard_top_tb/u_onboard_top/u_fft_wrapper/i_axi4s_data_tlast
add wave -noupdate /ipsxe_fft_onboard_top_tb/u_onboard_top/u_fft_wrapper/i_axi4s_data_tvalid
add wave -noupdate /ipsxe_fft_onboard_top_tb/u_onboard_top/u_fft_wrapper/o_axi4s_data_tready
add wave -noupdate -divider {Data Output Ports}
add wave -noupdate -radix hexadecimal /ipsxe_fft_onboard_top_tb/u_onboard_top/u_fft_wrapper/o_axi4s_data_tdata
add wave -noupdate /ipsxe_fft_onboard_top_tb/u_onboard_top/u_fft_wrapper/o_axi4s_data_tlast
add wave -noupdate -radix hexadecimal /ipsxe_fft_onboard_top_tb/u_onboard_top/u_fft_wrapper/o_axi4s_data_tuser
add wave -noupdate /ipsxe_fft_onboard_top_tb/u_onboard_top/u_fft_wrapper/o_axi4s_data_tvalid
add wave -noupdate -divider {Status&Alarm Ports}
add wave -noupdate /ipsxe_fft_onboard_top_tb/u_onboard_top/u_fft_wrapper/o_stat
add wave -noupdate /ipsxe_fft_onboard_top_tb/u_onboard_top/u_fft_wrapper/o_alm
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 1} {{Cursor 2} {185345686 ps} 1}
quietly wave cursor active 2
configure wave -namecolwidth 150
configure wave -valuecolwidth 83
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1552951536 ps}
