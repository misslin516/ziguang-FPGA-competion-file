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

# ����ǻ�ȡԭʼ�������ļ��Ĳ����ʣ�֡��
def get_audio_info(filepath):
    with SoundFile(filepath) as f:
        sr = f.samplerate
        frames = f.frames
        duration = float(frames) / sr
    # ���ﷵ�ص������� �����ļ�����֡�����������Լ�����ʱ��
    # ������ʵ���Ͼ���һ���ж���֡
    return {"frames": frames, "sr": sr, "duration": duration}

# ����÷��Ƶ��ͼ
def compute_melspec(y, sr, n_mels, fmin, fmax):
    """
    :param y:�������Ƶ���У�ÿ֡�Ĳ���
    :param sr: ������
    :param n_mels: ÷���˲�����Ƶ�ʵ���ϵ��
    :param fmin: ��ʱ����Ҷ�任(STFT)�ķ�����Χ min
    :param fmax: ��ʱ����Ҷ�任(STFT)�ķ�����Χ max
    :return:
    """
    # ����MelƵ��ͼ�ĺ���
    melspec = lb.feature.melspectrogram(y=y, sr=sr, n_mels=n_mels, fmin=fmin, fmax=fmax)  # (128, 1024) ��������һ��������Ƶ�׾���
    # ��Python�����ڽ���Ƶ�źŵĹ���ֵת��Ϊ�ֱ�(dB)ֵ�ĺ���
    melspec = lb.power_to_db(melspec).astype(np.float32)
    return melspec

# �������Ƶ�׾���������򻯴���
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

# �������һ���Ե������е�cut����pad�Ĳ���
# ���������y��һ��һά������,�������һά����y������߲ü���һ��length����
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
# ������г�����Ŀ¼���ļ��еĺ���
def list_folders(path):
    """
    �г�ָ��·���µ������ļ�����
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

        # melspectrogram ��һ�ֽ���Ƶ�ź�ת��Ϊ÷��Ƶ���׵ķ�����÷��Ƶ������һ�ֶ���Ƶ�źŽ���Ƶ�׷����ķ�����
        # ������Ƶ�źŴ�ʱ��(ʱ��)ת����Ƶ��(Ƶ��)������ת�����������Ǹ��õ������Ƶ�źŵ����ԣ��������ߡ�����ȡ�
        melspec = lb.feature.melspectrogram(y=y, sr=self.sr, n_mels=self.n_mels, fmin=self.fmin, fmax=self.fmax, **self.kwargs,)

        #������ת������������ͼת��Ϊ���db��λ��ͼ
        melspec = lb.power_to_db(melspec).astype(np.float32)
        """
        ��librosa��˵�������https://cloud.tencent.com/developer/article/1773059
        """

        return melspec


class BirdCLEFDataset(Dataset):
    def __init__(self, data, sr=32000, n_mels=128, fmin=0, fmax=None, duration=5, step=None, res_type="kaiser_fast",resample=True):
        #�����data�������ľ���һ����ַ������list  [path1,path2,path3......pathn]
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
        image = mono_to_color(melspec)  #�����н������򻯴���
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
