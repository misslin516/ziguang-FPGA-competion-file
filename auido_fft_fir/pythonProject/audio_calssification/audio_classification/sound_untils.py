#coding=gbk
import numpy as np
import librosa as lb
import soundfile as sf
import pandas as pd
import cv2
import os
from pathlib import Path
import re
import librosa as lb
import librosa.display as lbd
import torch
from  torch.utils.data import Dataset, DataLoader
import torchvision.models as models
from tqdm.notebook import tqdm
import sys
import timm
from soundfile import SoundFile

# 这个是获取原始的语音文件的采样率，帧数
def get_audio_info(filepath):
    with SoundFile(filepath) as f:
        sr = f.samplerate
        frames = f.frames
        duration = float(frames) / sr
    # 这里返回的依次是 整个文件的总帧数、采样率以及持续时间
    # 采样率实际上就是一秒有多少帧
    return {"frames": frames, "sr": sr, "duration": duration}

# 计算梅尔频率图
def compute_melspec(y, sr, n_mels, fmin, fmax):
    """
    :param y:传入的音频序列，每帧的采样
    :param sr: 采样率
    :param n_mels: 梅尔滤波器的频率倒谱系数
    :param fmin: 短时傅里叶变换(STFT)的分析范围 min
    :param fmax: 短时傅里叶变换(STFT)的分析范围 max
    :return:
    """
    # 计算Mel频谱图的函数
    melspec = lb.feature.melspectrogram(y=y, sr=sr, n_mels=n_mels, fmin=fmin, fmax=fmax)  # (128, 1024) 这个是输出一个声音的频谱矩阵
    # 是Python中用于将音频信号的功率值转换为分贝(dB)值的函数
    melspec = lb.power_to_db(melspec).astype(np.float32)
    return melspec

# 对输入的频谱矩阵进行正则化处理
def mono_to_color(X, eps=1e-6, mean=None, std=None):
    mean = mean or X.mean()
    std = std or X.std()
    X = (X - mean) / (std + eps)

    _min, _max = X.min(), X.max()

    if (_max - _min) > eps:
        V = np.clip(X, _min, _max)
        V = 255. * (V - _min) / (_max - _min)
        V = V.astype(np.uint8)
    else:
        V = np.zeros_like(X, dtype=np.uint8)
    return V

# 这里就是一个对单独序列的cut或者pad的操作
# 这里输入的y是一个一维的序列,将输入的一维序列y拉伸或者裁剪到一个length长度
def crop_or_pad(y, length, is_train=True, start=None):
    if len(y) < length:
        y = np.concatenate([y, np.zeros(length - len(y))])

        n_repeats = length // len(y)
        epsilon = length % len(y)
        y = np.concatenate([y] * n_repeats + [y[:epsilon]])

    elif len(y) > length:
        if not is_train:
            start = start or 0
        else:
            start = start or np.random.randint(len(y) - length)

        y = y[start:start + length]
    return y

import os
# 这个是列出所有目录下文件夹的函数
def list_folders(path):
    """
    列出指定路径下的所有文件夹名
    """
    folders = []
    for root, dirs, files in os.walk(path):
        for dir in dirs:
            folders.append(os.path.join(root, dir))
    return folders

def list_files(path):
    files = []
    for item in os.listdir(path):
        file = os.path.join(path, item)
        if os.path.isfile(file):
            files.append(file)
    return files

def audio_to_image(audio, sr, n_mels, fmin, fmax):
    melspec = compute_melspec(audio, sr, n_mels, fmin, fmax)
    image = mono_to_color(melspec)
    return image

class MelSpecComputer:
    def __init__(self, sr, n_mels, fmin, fmax, **kwargs):
        self.sr = sr
        self.n_mels = n_mels
        self.fmin = fmin
        self.fmax = fmax
        kwargs["n_fft"] = kwargs.get("n_fft", self.sr//10)
        kwargs["hop_length"] = kwargs.get("hop_length", self.sr//(10*4))
        self.kwargs = kwargs

    def __call__(self, y):

        # melspectrogram 是一种将音频信号转换为梅尔频率谱的方法。梅尔频率谱是一种对音频信号进行频谱分析的方法，
        # 它将音频信号从时域(时间)转换到频域(频率)。这种转换有助于我们更好地理解音频信号的特性，例如音高、节奏等。
        melspec = lb.feature.melspectrogram(y=y, sr=self.sr, n_mels=self.n_mels, fmin=self.fmin, fmax=self.fmax, **self.kwargs,)

        #功率谱转换。能量光谱图转化为响度db单位的图
        melspec = lb.power_to_db(melspec).astype(np.float32)
        """
        对librosa的说明在这里：https://cloud.tencent.com/developer/article/1773059
        """

        return melspec


class BirdCLEFDataset(Dataset):
    def __init__(self, data, sr=32000, n_mels=128, fmin=0, fmax=None, duration=5, step=None, res_type="kaiser_fast",resample=True):
        #这里的data传进来的就是一个地址的序列list  [path1,path2,path3......pathn]
        self.data = data

        self.sr = sr
        self.n_mels = n_mels
        self.fmin = fmin
        self.fmax = fmax or self.sr // 2

        self.duration = duration
        self.audio_length = self.duration * self.sr
        self.step = self.audio_length

        self.res_type = res_type
        self.resample = resample

        self.mel_spec_computer = MelSpecComputer(sr=self.sr, n_mels=self.n_mels, fmin=self.fmin,fmax=self.fmax)

    def __len__(self):
        return len(self.data)

    @staticmethod
    def normalize(image):
        image = image.astype("float32", copy=False) / 255.0
        image = np.stack([image, image, image])
        return image

    def audio_to_image(self, audio):
        melspec = self.mel_spec_computer(audio)
        image = mono_to_color(melspec)  #对序列进行正则化处理
        image = self.normalize(image)
        return image

    def read_file(self, filepath):
        audio, orig_sr = sf.read(filepath, dtype="float32")

        if self.resample and orig_sr != self.sr:
            audio = lb.resample(audio, orig_sr, self.sr, res_type=self.res_type)

        audios = []
        for i in range(self.audio_length, len(audio) + self.step, self.step):
            start = max(0, i - self.audio_length)
            end = start + self.audio_length
            audios.append(audio[start:end])

        if len(audios[-1]) < self.audio_length:
            audios = audios[:-1]

        images = [self.audio_to_image(audio) for audio in audios]
        images = np.stack(images)

        return images

    def __getitem__(self, idx):
        return self.read_file(self.data[idx])

if __name__ == '__main__':
    pass
    # audio_path = ('./BirdCLEF/dataset/kaggel_birdCLEF2023/train_audio')
    # out_dir_train = ('./BirdCLEF/specs/train')
    # out_dir_valid = ('./BirdCLEF/specs/valid')

    # example_audio_file = "./BirdCLEF/dataset/kaggel_birdCLEF2023/train_audio/abythr1/XC115981.ogg"

    # folder_name = ((list_folders(audio_path))[0])
    # files = list_files(folder_name)
    # print(files)
    # train_dataset = BirdCLEFDataset([example_audio_file])
    # image = (train_dataset.__getitem__(0))
    # print(image.shape)
