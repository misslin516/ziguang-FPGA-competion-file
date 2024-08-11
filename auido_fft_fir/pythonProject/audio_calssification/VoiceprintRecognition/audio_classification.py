import os
import re
import os
import shutil

from pydub import AudioSegment
from pydub.utils import mediainfo

from audio_calssification.VoiceprintRecognition.mvector.predict import MVectorPredictor
import pandas as pd
import os
from pydub import AudioSegment



# 文件夹路径
folder_path= 'dataset/cn-celeb-test/test/'

# 输出文件名
output_filename ='dataset/cn-celeb-test/trials_list.txt'


# 使用with语句确保文件会正确关闭

def wr_label(folder_path,output_filename):
    with open(output_filename, 'a') as file:
        # os.listdir返回指定路径下的文件和文件夹列表
        for filename in os.listdir(folder_path):
                # 使用正则表达式查找文件名中的数字
            numbers = re.findall(r'\b\d+\b', filename)
            print(filename)
            if filename.endswith('.mp3') or filename.endswith('.m4a') :  # 确保处理的是.flac文件
                # 构建完整的文件路径
                full_path = os.path.join(folder_path, filename)
                # 写入文件路径和固定的数字
                file.write(f"{full_path}\t{int(numbers[0])+199}\n")
    print(f"所有文件已被记录到 {output_filename}")




def convert_to_wav(source_folder):
    # 遍历文件夹中的所有文件
    for filename in os.listdir(source_folder):
        # 获取文件的完整路径
        file_path = os.path.join(source_folder, filename)
        # 检查文件格式并转换
        if filename.endswith('.mp3'):
            audio = AudioSegment.from_mp3(file_path)
            wav_path = os.path.join(source_folder, os.path.splitext(filename)[0] + '.wav')
            audio.export(wav_path, format='wav')
        elif filename.endswith('.m4a'):
            audio = AudioSegment.from_file(file_path, 'm4a')
            wav_path = os.path.join(source_folder, os.path.splitext(filename)[0] + '.wav')
            audio.export(wav_path, format='wav')
        elif filename.endswith('.flac'):
            audio = AudioSegment.from_file(file_path, 'flac')
            wav_path = os.path.join(source_folder, os.path.splitext(filename)[0] + '.wav')
            audio.export(wav_path, format='wav')





def convert_to_wav1(source_folder, output_folder):
    # 遍历文件夹中的所有文件
    for filename in os.listdir(source_folder):
        # 获取文件的完整路径
        file_path = os.path.join(source_folder, filename)
        # 检查文件格式并转换
        if filename.endswith('.mp3'):
            audio = AudioSegment.from_mp3(file_path)
        elif filename.endswith('.m4a'):
            audio = AudioSegment.from_file(file_path, 'm4a')
        elif filename.endswith('.flac'):
            audio = AudioSegment.from_file(file_path, 'flac')
        else:
            continue  # 跳过不支持的文件格式

        # 构建输出路径
        wav_filename = os.path.splitext(filename)[0] + '.wav'
        wav_path = os.path.join(output_folder, wav_filename)

        # 导出为 WAV 文件
        audio.export(wav_path, format='wav')


import os
import librosa


# 自定义函数对两个音频文件进行相似度对比
def contrast_audio_files(file1, file2):
    # 读取音频文件
    audio_data1, sr1 = librosa.load(file1, sr=None)
    audio_data2, sr2 = librosa.load(file2, sr=None)

    # 确保采样率相同
    if sr1 != sr2:
        raise ValueError(f"Sampling rates are different for {file1} and {file2}")

    # 计算相似度
    predictor = MVectorPredictor(configs='VoiceprintRecognition/configs/ecapa_tdnn.yml',
                                 model_path='VoiceprintRecognition/models/EcapaTdnn_MelSpectrogram/best_model/')
    print(predictor)
    similarity = predictor.contrast(audio_data1=audio_data1, audio_data2=audio_data2)
    return similarity


def get_audio_files(directory):
    """获取目录下所有音频文件的路径"""
    audio_files = []
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.wav') or file.endswith('.m4a') or file.endswith('.mp3')  :  # 根据需要调整文件扩展名
                audio_files.append(os.path.join(root, file))
    return audio_files


def batch_compare(directory,threhold):
    """批量比较目录下的音频文件"""

    audio_files = get_audio_files(directory)
    results = []
    with open('comparison_results.txt', 'w') as file:
        for i in range(len(audio_files)):
            for j in range(i + 1, len(audio_files)):
                file1 = audio_files[i]
                file2 = audio_files[j]

                try:
                    similarity = contrast_audio_files(file1, file2)
                    if similarity >= threhold:
                            file.write(f"{file1} \t{file2} \t{similarity}\t\n")
                    print(f"Compared {file1} and {file2}: similarity = {similarity}")
                except Exception as e:
                    print(f"Error comparing {file1} and {file2}: {e}")
    return results




def audio_calssfication(file_path,dest_path):

    pass





def sort_txt(origin_file, des_file,sort_file):
    # 读取数据
    data = []
    with open(origin_file, 'r', encoding='GBK') as file:
        for line in file:
            parts = line.strip().split('\t')
            file1 = parts[0]
            file2 = parts[1]
            similarity = float(parts[2])
            data.append((file1, file2, similarity))

    # 转换为DataFrame
    df = pd.DataFrame(data, columns=["File1", "File2", "Similarity"])

    # 按相似度降序排列
    df_sorted = df.sort_values(by="Similarity", ascending=False)

    # 保存到新的文件
    df_sorted.to_csv(des_file, sep='\t', index=False, header=False)

    # 创建结果文件夹
    result_dir = sort_file
    os.makedirs(result_dir, exist_ok=True)

    # 处理每一行数据，并将文件复制到相应的文件夹
    user_count = 1
    file_to_user = {}

    for index, row in df_sorted.iterrows():
        file1, file2, _ = row

        # 查找已有的用户文件夹
        if file1 in file_to_user:
            user_folder = file_to_user[file1]
        elif file2 in file_to_user:
            user_folder = file_to_user[file2]
        else:
            # 创建新的用户文件夹
            user_folder = os.path.join(result_dir, f'用户{user_count}')
            os.makedirs(user_folder, exist_ok=True)
            user_count += 1

        # 将文件与用户文件夹关联
        file_to_user[file1] = user_folder
        file_to_user[file2] = user_folder

    # 将文件复制到对应的用户文件夹
    for file, folder in file_to_user.items():
        dest_path = os.path.join(folder, os.path.basename(file))
        if not os.path.exists(dest_path):
            shutil.copy(file, dest_path)

    # 打印用户文件夹分配情况
    for file, folder in file_to_user.items():
        print(f'{file} -> {folder}')

    # 统计并打印每个文件夹的文件总数
    file_num = 0
    for folder in os.listdir(result_dir):
        folder_path = os.path.join(result_dir, folder)
        if os.path.isdir(folder_path):
            file_count = len(os.listdir(folder_path))
            file_num += file_count
            if file_count == 0:
                os.rmdir(folder_path)
                print(f'已删除空文件夹: {folder_path}')
            else:
                print(f'文件夹 {folder_path} 包含 {file_count} 个文件')
    return file_num

# # 指定需要转换的文件夹路径
# source_folder = 'path_to_your_folder'
# convert_to_wav(source_folder)
# 单个文件的特征值获取
def save_audio_files(audio_files,output_filename):
    # 读取音频文件
    predictor = MVectorPredictor(configs='C:/Users/86151/Desktop/auido_fft_fir/pythonProject/audio_calssification/VoiceprintRecognition/configs/ecapa_tdnn.yml',
                                 model_path='C:/Users/86151/Desktop/auido_fft_fir/pythonProject/audio_calssification/VoiceprintRecognition/models/EcapaTdnn_MelSpectrogram/best_model/')
    with open(output_filename, 'a') as file:
        audio_data1, sr1 = librosa.load(audio_files, sr=None)

        # 计算相似度

        feature1 = predictor.predict(audio_data1)
        print(f'The deature is ：{feature1}')
        print(f'The deature is ：{len(feature1)}')
            # print(f'--------{feature1}--------------')
            # Write the feature to the file with the specified format
            # for i, feature in enumerate(feature1, start=1):
        file.write(f"{[round(x * (2**12)) for x in feature1]}\n")


if __name__ == '__main__':
    print()
    # # source_folder = 'dataset/cn-celeb-test/test1/test/'
    # # output_folder = 'dataset/cn-celeb-test/test1/test1'
    # # convert_to_wav1(source_folder,output_folder)
    #
    # from mvector.predict import MVectorPredictor
    #
    # predictor = MVectorPredictor(configs='configs/ecapa_tdnn.yml',
    #                              model_path='models/EcapaTdnn_MelSpectrogram/best_model/')
    # # 获取音频特征
    # embedding = predictor.predict(audio_data='dataset/cn-celeb-test/test/id00800-singing-01-001.wav')
    # # 获取两个音频的相似度
    # similarity = predictor.contrast(audio_data1='dataset/cn-celeb-test/test/id00800-singing-01-001.wav', audio_data2='audio_db/1/id00800-singing-01-001.wav')
    # print(f'similarity = {similarity}')
    #
    # # 注册用户音频
    # predictor.register(user_name='夜雨飘零', audio_data='audio_db/1/id00800-singing-01-001.wav')
    # # 识别用户音频
    # name, score = predictor.recognition(audio_data='audio_db/1/id00800-singing-01-001.wav')
    # # 获取所有用户
    # users_name = predictor.get_users()
    # # 删除用户音频
    # predictor.remove_user(user_name='夜雨飘零')
    # directory = 'dataset/Voiceprintrecognition/'
    # batch_compare(directory)
    # sort_file = 'sort_file'
    # num = sort_txt('comparison_results.txt', 'comparison_results_sort1.txt',sort_file)
    # print(f'文件总数为：{num}')

    filname = 'C:/Users/86151/Desktop/auido_fft_fir/pythonProject/audio_calssification/VoiceprintRecognition/声纹用户/男4/4.m4a'
    save_audio_files(filname, 'feature')
