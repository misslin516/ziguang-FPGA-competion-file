"""
UDP test

"""
import os
import socket
import time
import wave

# import os
# import wave
# import socket
#
import numpy as np
# import utils
#
#
# def udp_receive(MonteCarlo,max_buffer_once,multiple,filename,self_define_file,local_ip ,local_port):
#     """
#
#     :param MonteCarlo: 重复接收次数
#     :param max_buffer_once: udp套接字最大单次接收字节数
#     :param multiple:  接收数据 = multiple * 实际有效字节数
#     :param filename:   保存为wav的文件名字
#     :param local_ip:   pc 的ip地址
#     :param local_port: 端口数
#     :param self_define_file:创建FPGA接收音频数据转化为wav存储的文件夹
#     :return:
#     """
#
#     udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
#
#     # 绑定IP地址和端
#     udp_socket.bind((local_ip, local_port))
#     validytes = 200  # 单次有效数据   因为数据量过大要分多次接收
#     numberoftrans = 144
#     # total_validytes = 0  # 总数据个数
#     # numberoftrans = 5
#     print("UDP 服务器启动成功，等待接收数据...")
#     # 接收数据
#
#     while True:
#         valid_data = []
#         while 1:
#             data, addr = udp_socket.recvfrom(max_buffer_once)  # 一次最多接收 字节的数据  > validytes
#             print(f'接收到来自{format(addr)}的数据,进行数据处理中...')
#             # 将接收到的十六进制数据解析为整数数组
#             int_values = [int(data.hex()[i:i + 4], 16) for i in range(0, len(data), 4)]
#             print(int_values)
#             valid_data = np.concatenate((valid_data, int_values), axis=0)
#             if len(valid_data) >= (multiple* validytes * numberoftrans):
#                 break
#         total_validytes = int(validytes * numberoftrans)
#         valid_num = total_validytes
#         valid_data_true = np.zeros((total_validytes, MonteCarlo))  # 具体根据FPGA修改  这里采用重复接收 来对抗UDP的丢包或者错误问题
#         j = []
#         for i in range(len(valid_data)):
#             if valid_data[i] == 61530:  # 判断帧头
#                 if valid_data[i+3] == 51344:
#                     j.append(i)
#
#         if len(j) == 0:
#             continue
#
#         for jj in range(len(j)):
#             if jj == 0:
#                 valid_data_true[0:valid_num, 0] = valid_data[j[jj] + 4:j[jj] + 4 + valid_num]
#             elif jj > 2:
#                 if jj == 1:
#                     valid_data_true[0:valid_num, 1] = valid_data[j[jj] + 4:j[jj] + 4 + valid_num]
#                 elif jj == 2:
#                     valid_data_true[0:valid_num, 2] = valid_data[j[jj] + 4:j[jj] + 4 + valid_num]
#
#         for jjjj in range(0, 3):
#             for iiii in range(len(valid_data_true[:, jjjj])):
#                 if valid_data_true[iiii, 0] == 61530 or valid_data_true[iiii, 0] == 42255:
#                     valid_data_true[iiii, 0] = 0
#
#         if valid_data_true[0].all() == valid_data_true[1].all() and valid_data_true[1].all() == valid_data_true[
#             2].all():
#
#             print(f'成功捕获到的数据为：{valid_data_true[:, 0]}')
#             print(f'捕获到的数据维度为：{len(valid_data_true[:, 0])}')
#             udp_socket.close()
#             save_wav_file(filename, valid_data_true[:, 0], self_define_file, sample_rate=48000, bit_depth=16)
#             break
#         else:
#             continue
#
#
# def save_wav_file(filename, audio_data, self_define_file:str,sample_rate=48000, bit_depth=16):
#     # 缩放音频数据
#     scaled_audio_data = (audio_data / np.max(np.abs(audio_data))) * (2 ** (bit_depth - 1) - 1)
#     scaled_audio_data = scaled_audio_data.astype(np.int16)
#
#     # 获取当前工作目录
#     current_dir = os.getcwd()
#
#     # 如果当前目录中没有名为 self_define_file" 的文件夹，则创建该文件夹
#     output_dir = os.path.join(current_dir,self_define_file)
#     if not os.path.exists(output_dir):
#         os.makedirs(output_dir)
#
#     # 构造输出文件的完整路径
#     output_file = os.path.join(output_dir, filename)
#     print('写入文件中...')
#     # 写入 WAV 文件
#     with wave.open(output_file, 'wb') as wf:
#         wf.setnchannels(2)  # 单声道音频
#         wf.setsampwidth(bit_depth // 8)  # 采样位宽（字节数）
#         wf.setframerate(sample_rate)  # 采样率
#         wf.writeframes(scaled_audio_data.tobytes())
#
#
#
# if __name__ == '__main__':
#     # MonteCarlo = 3
#     # max_buffer_once = 1024
#     # multiple = 10
#     # filename =  "output.wav"
#     # self_define_file =  "fpga_output"
#     # udp_receive(MonteCarlo, max_buffer_once, multiple, filename, self_define_file, local_ip="169.254.51.120",
#     #             local_port=1234)
#
#     # a = [1,0,2,0,3,0,4,0,5]
#     # b = a[::-1]
#     # c = b[2::2]
#     # d = c[::-1]
#     # print(b)
#     # print(c)
#     # print(d)
#     # for i in range(len(a)):
#     #     if a[i] == 4:
#     #         print("receiving...")
#     #         print("receiving....")
#     #         print("receiving.....")
#     #         data_reg = a[:i+1]
#     #
#     # print(data_reg)
#
#     import librosa
#     import wave
#     import numpy as np
#
#     # file_name = "C:/Users/86151/Desktop/auido_fft_fir/pythonProject/fpga_output/output_20240507-202828.wav"
#     file_name = "D:/fpga_competition/matlabcode_for_check/A 去噪测试音频/去噪测试音频样本1.m4a"
#     filrename1 = "C:/Users/86151/Desktop/auido_fft_fir/pythonProject/Speech_Emotion_Recognition_master/dataset/CASIA/angry/201-angry-liuchanhg.wav"
#     # 读取音频文件
#     audio_data1, sample_rate1 = librosa.load(filrename1, sr=48000,dtype=np.int16)
#     print(len(audio_data1))
#     print(sample_rate1)
#     #
#     # print(f'len = {len(audio_data1)}')
#     # import soundfile as sf
#     # data = []
#     # # 读取音频文件
#     # audio_data2, sample_rate2 = sf.read(filrename1, dtype='int16')
#     # print(f'audio_data2.shape = {audio_data2.shape}')
#     # print(audio_data2)
#     # print(sample_rate2)
#     # audio_data_uint16 = audio_data2.astype(np.uint16)
#     # print(sum(1 for x in audio_data_uint16 if x == 0))
#     # print(len(audio_data_uint16))
#     # for i in range(len(audio_data2)):
#     #     if audio_data2[i] >= 10 and  audio_data2[i] <= 65536:
#     #         data.append(audio_data2[i])
#
#
#
#     # 假设你已经采集到了无符号16位数据，保存在变量 audio_data_uint16 中
#     # 假设采样率为 48000 Hz
#     # 假设你想要保存的文件名为 'output.wav'
#
#
#     with wave.open('result.wav', 'wb') as wf:
#         # 设置WAV文件的参数
#         wf.setnchannels(1)  # 单声道
#         wf.setsampwidth(2)  # 采样位宽为 16 位，即 2 个字节
#         wf.setframerate(sample_rate1)  # 采样率为 48000 Hz
#
#         # 将无符号整数类型的音频数据转换为有符号整数类型
#         audio_data_int16 = audio_data1.astype(np.int16)
#         print(audio_data_int16)
#         # 将数据写入WAV文件
#         wf.writeframes(audio_data_int16.tobytes())
#

import numpy as np

import matplotlib.pyplot as plt
import random
import scipy as sc

import numpy as np

# 定义向量的内积

def multiVector(A, B):
    C = np.zeros(len(A))

    for i in range(len(A)):
        C[i] = A[i] * B[i]

    return sum(C)


# 取定给定的反向的个数

def inVector(A, b, a):
    D = np.zeros(b - a + 1)

    for i in range(b - a + 1):
        D[i] = A[i + a]

    return D[::-1]


# lMS算法的函数

def LMS(xn, dn, M, mu, itr):
    en = np.zeros(itr)

    W = [[0] * M for i in range(itr)]

    for k in range(itr)[M - 1:itr]:
        x = inVector(xn, k, k - M + 1)
        d = x.mean()

        y = multiVector(W[k - 1], x)

        en[k] = d - y

        W[k] = np.add(W[k - 1], 2 * mu * en[k] * x)  # 跟新权重

    # 求最优时滤波器的输出序列

    yn = np.inf * np.ones(len(xn))

    for k in range(len(xn))[M - 1:len(xn)]:
        x = inVector(xn, k, k - M + 1)

        yn[k] = multiVector(W[len(W) - 1], x)

    return (yn, en)

def udp_receive(max_buffer_once,wav_name,self_define_file,num_file,local_ip = "169.254.51.120",local_port =1234):
    """
    :param max_buffer_once: udp套接字最大单次接收字节数
    :param wav_name:   保存为wav的文件名字
    :param local_ip:   pc 的ip地址
    :param local_port: 端口数
    :param self_define_file:创建FPGA接收音频数据转化为wav存储的文件夹
    :param num_file :保存文件数量
    :return:
    """

    # 创建UDP套接字
    global b
    global b1
    udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    # 绑定IP地址和端口
    udp_socket.bind((local_ip, local_port))
    print("UDP 服务器启动成功，等待接收数据...")
    int_values1 = []
    count = 0
    while True:
        data, addr = udp_socket.recvfrom(max_buffer_once)  # 一次最多接收 字节的数据  > validytes
        print(f'接收到来自{format(addr)}的数据,进行数据处理中...')
        print(f'receive len = {len(data.hex())},receive data ={data.hex()} ,type = {type(data.hex())}')

        hex_data = data.hex()
        int_values = [int(hex_data[i:i + 4], 16) for i in range(0, len(hex_data), 4)]
        int_values1.append(int_values[1::2])

        if len(np.concatenate(int_values1) >= 480000) and count == 0:
            print('------------COUNT = 0------------')
            a =  np.concatenate(int_values1)
            b = a[:480000]
            int_values1 = []
            count+=1
        elif len(np.concatenate(int_values1) >= 480000) and count == 1:
            print('------------COUNT = 1------------')
            time.sleep(2)
            a1 =  np.concatenate(int_values1)
            b1 = a1[:480000]
            int_values1 = []
            count += 1
            break

    M = 20
    mu = 0.001
    yn, en =  LMS(b1, b, M, mu, len(b1))




            # 创建音频文件名
    file_name = wav_name + time.strftime("%Y%m%d-%H%M%S") + ".wav"
    audio_data = b1 - yn
    # 创建音频数据数组
    # for i in range(len(audio_data)):
    #     if audio_data[i] == 0:
    #         continue
    #     elif audio_data[i] != 0:
    #         audio_data = audio_data[i:]
    #         break



    # 保存音频文件
    save_wav_file(file_name, audio_data, self_define_file, 48000)




def save_wav_file(filename, audio_data, self_define_file:str,sample_rate=48000, bit_depth=16):
    # 缩放音频数据
    # scaled_audio_data = (audio_data / np.max(np.abs(audio_data))) * (2 ** (bit_depth - 1) - 1)
    scaled_audio_data = audio_data.astype(np.int16)

    # 获取当前工作目录
    current_dir = os.getcwd()

    # 如果当前目录中没有名为 self_define_file" 的文件夹，则创建该文件夹
    output_dir = os.path.join(current_dir,self_define_file)
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # 构造输出文件的完整路径
    output_file = os.path.join(output_dir, filename)

    # 写入 WAV 文件
    with wave.open(output_file, 'wb') as wf:
        wf.setnchannels(1)  # 单声道音频
        wf.setsampwidth(2)  # 采样位宽（字节数）
        wf.setframerate(sample_rate)  # 采样率
        wf.writeframes(scaled_audio_data.tobytes())

"""
考虑到工程的实用性
"""
def get_filename(folder_name:str):
    # 获取当前工作目录
    path = []
    current_dir = os.getcwd()
    folder_path = os.path.join(current_dir, folder_name)
    files = os.listdir(folder_path)
    for file in files:
        file_path = os.path.join(folder_path, file)
        path.append(file_path)
    return path

if __name__ == "__main__":
    max_buffer_once = 4096
    num_wav_file = 10
    wav_name = "test1"
    self_define_file = "fpga_output"
    udp_receive(max_buffer_once, wav_name, self_define_file, 1, local_ip="169.254.51.120", local_port=1234)


