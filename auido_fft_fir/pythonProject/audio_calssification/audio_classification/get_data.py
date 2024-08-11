#coding=gbk
import torch
import numpy as np
import csv

voice_class_list = ["explosion", "mohanveena","screaming", "sitar","violin","wake"]
file_name_label_dict = {}

with open('./train_data.csv', encoding='utf-8') as f:
    for row in csv.reader(f):
        file_name = row[1]      #file_name音频名称
        first_label = row[0]    #first_label音频标签
        first_label = (voice_class_list.index(first_label))
        label = [first_label]
        #制作独热向量
        label_id = [0.] * len(voice_class_list)
        for lab in label:
            label_id[lab] = 1.
        file_name_label_dict[file_name] = label_id


images_list = np.load("./images_list_5s.npy")
file_name_label = [file_name_label_dict[name] for name in file_name_label_dict]

class BirdDataset(torch.utils.data.Dataset):
    def __init__(self, file_name_label = file_name_label,images_list = images_list, sr=48000, duration=8, augmentations=None):
        self.images_list = images_list
        self.file_name_label = file_name_label
        self.sr = sr
        self.duration = duration
        self.augmentations = augmentations


    def __len__(self):
        return len(self.file_name_label)

    def __getitem__(self, idx):

        image = self.images_list[idx]
        image = torch.tensor(image).float()

        label = file_name_label[idx]
        label = torch.tensor(label).long()

        return image, label


#  测试代码
if __name__ == '__main__':
    datastet = BirdDataset()
    image, label = datastet.__getitem__(0)

    image, label = datastet.__getitem__(1)
    print(image.shape)

    image, label = datastet.__getitem__(2)
    print(image.shape)
