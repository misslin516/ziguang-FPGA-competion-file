#coding=gbk
from pydub import AudioSegment
import os

# 定义输入和输出文件夹路径
# input_folder = 'dataset/音频分类/explosion'
# output_folder = './wake'



# 循环处理文件夹下的每个 WAV 文件
def audio_wav2mp3(input_folder,output_folder):
    for filename in os.listdir(input_folder):
        if filename.endswith('.wav'):
            # 构建输入和输出文件的完整路径
            input_path = os.path.join(input_folder, filename)
            output_path = os.path.join(output_folder, filename.replace('.wav', '.mp3'))

            # 加载 WAV 文件
            sound = AudioSegment.from_wav(input_path)

            # 转换为 MP3 格式，并保存到输出文件夹
            sound.export(output_path, format="mp3")

# 定义转换函数
def convert_wav_to_mp3(wav_file, mp3_file):
    # 加载 WAV 文件
    audio = AudioSegment.from_wav(wav_file)
    # 导出为 MP3 文件
    audio.export(mp3_file, format="mp3")
    print(f"转换完成：{wav_file} -> {mp3_file}")






if __name__ == '__main__':
    filename = 'C:/Users/86151/Desktop/07/模型训练/test/gunshot.wav'
    # audio_wav2mp3(filename,filename + '1' )
    convert_wav_to_mp3(filename,filename + '1')