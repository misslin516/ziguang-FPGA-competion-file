#coding=gbk
import matplotlib
matplotlib.use('agg')#避免与 Qt 或其他 GUI 工具包的兼容性问题
import soundfile as sf
import numpy as np
import sound_untils
import os
import librosa as lb
import torch
from torch.utils.data import DataLoader, Dataset
from tqdm import tqdm
import resnet
import wav_to_mp3

os.environ["CUDA_VISIBLE_DEVICES"] = "0"
device = "cpu"
bird_model = resnet.ResNet().to(device)
bird_model.load_state_dict(torch.load("./sound_model.pth"))

sr = sampling_rate = 48000
n_mels = 128
fmin = 0
fmax = sr//2
duration = 8
audio_length = duration * sr    # 48000 * 8
step = audio_length
res_type="kaiser_fast"
resample= True
train=True
def list_files_in_folder(folder_path):
    files = os.listdir(folder_path)
    return files

# data="./dataset/音频分类/wake/A00036_S0001.mp3"#单个文件测试
data = 'C:/Users/86151/Desktop/07/模型训练/test/gunshot.wav'



voice_class_list = ["explosion", "mohanveena","screaming", "sitar","violin","wake"]


audio, orig_sr = sf.read(data, dtype="float32")

if audio.ndim > 1:
    audio = audio[:, 0]        

if resample and orig_sr != sr:
    audio = lb.resample(audio, orig_sr=orig_sr, target_sr=sr, res_type=res_type)

audio = sound_untils.crop_or_pad(audio,length=sampling_rate * 8)
images = sound_untils.audio_to_image(audio,sr, n_mels, fmin, fmax)
images = torch.unsqueeze(torch.tensor(images,dtype=torch.float),dim=0).to(device)
logits = bird_model(images)
print(logits)
print("---------------------")
logits = torch.nn.Softmax(-1)(logits)
logits= torch.argmax(logits,dim=-1)
print(logits)
print(logits.item())
print("---------------------")


