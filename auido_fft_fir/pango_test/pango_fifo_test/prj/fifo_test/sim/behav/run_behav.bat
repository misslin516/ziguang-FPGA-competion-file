@echo off
set bin_path=D:/modelsim20204/setup/win64
cd C:/Users/86151/Desktop/auido_fft_fir/pango_fifo_test/prj/fifo_test/sim/behav
call "%bin_path%/modelsim"   -do "do {run_behav_compile.tcl};do {run_behav_simulate.tcl}" -l run_behav_simulate.log
if "%errorlevel%"=="1" goto END
if "%errorlevel%"=="0" goto SUCCESS
:END
exit 1
:SUCCESS
exit 0
