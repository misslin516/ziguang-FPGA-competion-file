# ----------------------------------------
# Created on: Mon Apr 22 10:02:46 2024
# Auto generated by Pango
# ----------------------------------------

vsim  -novopt  -L work -L usim -L adc -L ddrc -L ddrphy -L hsst_e2 -L iolhr_dft -L ipal_e1 -L pciegen2 tb_audio_data_pkt usim.GTP_GRS
add wave *
view wave
view structure
view signals

run 1000ns

# ----------------------------------------