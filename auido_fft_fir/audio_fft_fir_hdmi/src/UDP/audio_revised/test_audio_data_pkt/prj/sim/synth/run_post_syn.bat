@echo off
set bin_path=D:/modelsim20204/ssetup/win64
cd C:/Users/86151/Desktop/auido_fft_fir/audio_fft_fir_hdmi/src/UDP/audio_revised/test_audio_data_pkt/prj/sim/synth
call "%bin_path%/modelsim"   -do "do {run_post_syn_compile.tcl};do {run_post_syn_simulate.tcl}" -l run_post_syn_simulate.log
if "%errorlevel%"=="1" goto END
if "%errorlevel%"=="0" goto SUCCESS
:END
exit 1
:SUCCESS
exit 0
