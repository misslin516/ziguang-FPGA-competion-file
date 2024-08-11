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
audio_path = ("./dataset/音频分类")

#这里一共有6个分类
voice_class_list = ["explosion", "mohanveena","screaming", "sitar","violin","wake"]
print(voice_class_list)

file_name_label_dict = {}
with open('./train_data.csv', encoding='utf-8') as f:
    for row in csv.reader(f):
        file_name = row[1]      #file_name音频名称     
        first_label = row[0]    #first_label音频标签
        first_label = (voice_class_list.index(first_label))  #first_label变为bird_class_list对应的列表序号
        label = [first_label]
        file_name_label_dict[file_name] = (label)   #输入的结构是这样：XC365413 [263, 103]
       
    print(file_name_label_dict)

file_name_list = []
images_list = []
file_name_list =  open('./file_name_list.csv', mode='w', newline='')
writer = csv.writer(file_name_list)

for folder_name in tqdm((sound_untils.list_folders(audio_path))):
    files = sound_untils.list_files(folder_name)

    for _file in files:
        writer.writerow([_file.split("\\")[-1]])
        #首先获取语音的序列长度，以及采样率，这里的采样率指的是每秒帧数
        audio, orig_sr = sf.read(_file, dtype="float32")    
            
        if resample and orig_sr != sr:      #如果语音的采样率和设定的采样率不服，则强行修正
            audio = lb.resample(audio, orig_sr=orig_sr, target_sr=sr, res_type=res_type)
        
        if audio.ndim > 1:      #双通道改为单通道，2维变1维
            audio = audio[:, 0]        
        # print(audio.shape)
        # print(audio.ndim)

        #将长度设定为一个长度，此时需要说明的是，sampling_rate是每秒帧数，因此一般这里直接就是crop_or_pad
        audio = sound_untils.crop_or_pad(y=audio,length=sampling_rate * 8)   
        #Todo 这里就是语音转换，将语音序列转换成一个二维图像
        images = sound_untils.audio_to_image(audio,sr, n_mels, fmin, fmax)
        images_list.append(images)
 
#得到大小(83, 128, 751)的矩阵
np.save("./images_list_5s.npy",images_list)
