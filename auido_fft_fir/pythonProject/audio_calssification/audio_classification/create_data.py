#coding=gbk
import soundfile as sf
import numpy as np
from soundfile import SoundFile
from pathlib import Path
import sound_untils
from tqdm import tqdm
import librosa as lb
import csv
import torch

sampling_rate = 48000
duration = 8
sr = sampling_rate
n_mels = 128
fmin = 0
fmax = sr//2
audio_length = duration * sr    # 48000 * 8
res_type="kaiser_fast"
resample= True
train=True
audio_path = ("./dataset/��Ƶ����")

#����һ����6������
voice_class_list = ["explosion", "mohanveena","screaming", "sitar","violin","wake"]
print(voice_class_list)

file_name_label_dict = {}
with open('./train_data.csv', encoding='utf-8') as f:
    for row in csv.reader(f):
        file_name = row[1]      #file_name��Ƶ����     
        first_label = row[0]    #first_label��Ƶ��ǩ
        first_label = (voice_class_list.index(first_label))  #first_label��Ϊbird_class_list��Ӧ���б����
        label = [first_label]
        file_name_label_dict[file_name] = (label)   #����Ľṹ��������XC365413 [263, 103]
       
    print(file_name_label_dict)

file_name_list = []
images_list = []
file_name_list =  open('./file_name_list.csv', mode='w', newline='')
writer = csv.writer(file_name_list)

for folder_name in tqdm((sound_untils.list_folders(audio_path))):
    files = sound_untils.list_files(folder_name)

    for _file in files:
        writer.writerow([_file.split("\\")[-1]])
        #���Ȼ�ȡ���������г��ȣ��Լ������ʣ�����Ĳ�����ָ����ÿ��֡��
        audio, orig_sr = sf.read(_file, dtype="float32")    
            
        if resample and orig_sr != sr:      #��������Ĳ����ʺ��趨�Ĳ����ʲ�������ǿ������
            audio = lb.resample(audio, orig_sr=orig_sr, target_sr=sr, res_type=res_type)
        
        if audio.ndim > 1:      #˫ͨ����Ϊ��ͨ����2ά��1ά
            audio = audio[:, 0]        
        # print(audio.shape)
        # print(audio.ndim)

        #�������趨Ϊһ�����ȣ���ʱ��Ҫ˵�����ǣ�sampling_rate��ÿ��֡�������һ������ֱ�Ӿ���crop_or_pad
        audio = sound_untils.crop_or_pad(y=audio,length=sampling_rate * 8)   
        #Todo �����������ת��������������ת����һ����άͼ��
        images = sound_untils.audio_to_image(audio,sr, n_mels, fmin, fmax)
        images_list.append(images)
 
#�õ���С(83, 128, 751)�ľ���
np.save("./images_list_5s.npy",images_list)
