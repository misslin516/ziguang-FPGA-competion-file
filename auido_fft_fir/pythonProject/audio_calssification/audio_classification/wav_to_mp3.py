#coding=gbk
from pydub import AudioSegment
import os

# �������������ļ���·��
# input_folder = 'dataset/��Ƶ����/explosion'
# output_folder = './wake'



# ѭ�������ļ����µ�ÿ�� WAV �ļ�
def audio_wav2mp3(input_folder,output_folder):
    for filename in os.listdir(input_folder):
        if filename.endswith('.wav'):
            # �������������ļ�������·��
            input_path = os.path.join(input_folder, filename)
            output_path = os.path.join(output_folder, filename.replace('.wav', '.mp3'))

            # ���� WAV �ļ�
            sound = AudioSegment.from_wav(input_path)

            # ת��Ϊ MP3 ��ʽ�������浽����ļ���
            sound.export(output_path, format="mp3")

# ����ת������
def convert_wav_to_mp3(wav_file, mp3_file):
    # ���� WAV �ļ�
    audio = AudioSegment.from_wav(wav_file)
    # ����Ϊ MP3 �ļ�
    audio.export(mp3_file, format="mp3")
    print(f"ת����ɣ�{wav_file} -> {mp3_file}")






if __name__ == '__main__':
    filename = 'C:/Users/86151/Desktop/07/ģ��ѵ��/test/gunshot.wav'
    # audio_wav2mp3(filename,filename + '1' )
    convert_wav_to_mp3(filename,filename + '1')