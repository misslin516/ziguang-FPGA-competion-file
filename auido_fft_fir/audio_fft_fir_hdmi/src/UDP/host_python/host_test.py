"""
将音频文件保存为wav文件进行调用
"""

import torchaudio
file_path = "D:/fpga_competition/matlabcode_for_check/calss_emotion/1.m4a"
waveform, sr = torchaudio.load(file_path, normalize=True)



