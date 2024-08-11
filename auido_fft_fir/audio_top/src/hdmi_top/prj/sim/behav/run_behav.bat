@echo off
set bin_path=D:/modelsim106/setup/win64
cd C:/Users/86151/Desktop/auido_fft_fir/audio_top/src/hdmi_top/prj/sim/behav
call "%bin_path%/modelsim"   -do "do {run_behav_compile.tcl};do {run_behav_simulate.tcl}" -l run_behav_simulate.log
if "%errorlevel%"=="1" goto END
if "%errorlevel%"=="0" goto SUCCESS
:END
exit 1
:SUCCESS
exit 0
