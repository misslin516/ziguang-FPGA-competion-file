import os
import struct
import time
import wave
import librosa
import numpy as np
# import models
import utils
import socket

from extract_feats import opensmile as of
from extract_feats import librosa1 as lf
from models import load

import soundfile as sf
from noisereduce_master import noisereduce as nr


def predict(config, audio_path: str, model) -> None:
    """
    预测音频情感

    Args:
        config: 配置项
        audio_path (str): 要预测的音频路径
        model: 加载的模型
    """

    # utils.play_audio(audio_path)

    if config.feature_method == 'o':
        # 一个玄学 bug 的暂时性解决方案
        of.get_data(config, audio_path, train=False)
        test_feature = of.load_feature(config, train=False)
    elif config.feature_method == 'l':
        test_feature = lf.get_data(config, audio_path, train=False)
    # print(test_feature)
    result = model.predict(test_feature)
    result_prob = model.predict_proba(test_feature)

    print(f'Recogntion:{config.class_labels[int(result)]}')
    print(f'Probability:{result_prob}')
    # utils.radar(result_prob, config.class_labels)
    return config.class_labels[int(result)]



def audio_data_compute(seconds,channel =1,sr = 48000,bit = 16):
    """
        # 数据量 =（采样频率×采样位数×声道数×时间） / 8
    :param sr: 采样频率
    :param bit: 采样位数
    :param channel: 声道数
    :param seconds: 时间
    :return: 数据量
    """
    return (sr*bit*channel*seconds)/16





"""
UDP接收FPGA数据
"""
def udp_receive(max_buffer_once,wav_name,self_define_file,num_file,choise,local_ip = "169.254.51.120",local_port =1234):
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
    global y_noise
    udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)


    seconds_str= input('-----------------请输入您采集语音的时间（s）------------------\n')
    seconds = int(seconds_str)
    print('---------------------输入成功-----------------------')
    audio_dat = int(audio_data_compute(seconds))
    # 绑定IP地址和端口
    udp_socket.bind((local_ip, local_port))
    print("UDP 服务器启动成功，等待接收数据...")
    countt = 0
    int_values1 = []
    if choise == 1:
        while True:
            data, addr = udp_socket.recvfrom(max_buffer_once)  # 一次最多接收 字节的数据  > validytes
            print(f'接收到来自{format(addr)}的数据,进行数据处理中...')
            print(f'receive len = {len(data.hex())},receive data ={data.hex()} ,type = {type(data.hex())}')

            hex_data = data.hex()
            int_values = [int(hex_data[i:i + 4], 16) for i in range(0, len(hex_data), 4)]
            int_values1.append(int_values[1::2])
            print(f'----------------接收长度 = : {len(np.concatenate(int_values1))}')
            if countt == 0:
                print('---------------采集噪声中...------------')
                print('---------------采集噪声中...------------')
                if len(np.concatenate(int_values1)) >=  audio_dat:
                    aaa = np.concatenate(int_values1)
                    y_noise =aaa[:audio_dat]
                    int_values1 = []
                    countt =1
                    input('准备好接收音频 1-yeah 2-No\n')
            elif countt == 1:
                print('------------采集音频中...-----------')
                print('------------采集音频中...-----------')
                print('------------采集音频中...-----------')

                if len(np.concatenate(int_values1)) >= audio_dat:
                    # 创建音频文件名
                    file_name = wav_name + time.strftime("%Y%m%d-%H%M%S") + ".wav"

                    # 创建音频数据数组
                    audio_data = np.concatenate(int_values1)

                    reduced_noise = nr.reduce_noise(y=audio_data[:audio_dat], sr=48000,y_noise=y_noise,time_constant_s=seconds)
                    # 保存音频文件
                    save_wav_file(file_name, reduced_noise, self_define_file, 48000)
           #have bug this place,it means we need create different file to storage it,but the num_file is 1 is ok
                    break
    else:
        input('准备好接收音频 1-yeah 2-No\n')
        while True:
            data, addr = udp_socket.recvfrom(max_buffer_once)  # 一次最多接收 字节的数据  > validytes
            print(f'接收到来自{format(addr)}的数据,进行数据处理中...')
            print(f'receive len = {len(data.hex())},receive data ={data.hex()} ,type = {type(data.hex())}')

            hex_data = data.hex()
            int_values = [int(hex_data[i:i + 4], 16) for i in range(0, len(hex_data), 4)]
            int_values1.append(int_values[1::2])
            print(f'----------------接收长度 = : {len(np.concatenate(int_values1))}')
            print('------------采集音频中...-----------')
            print('------------采集音频中...-----------')
            print('------------采集音频中...-----------')

            if len(np.concatenate(int_values1)) >= audio_dat:
                # 创建音频文件名
                file_name = wav_name + time.strftime("%Y%m%d-%H%M%S") + ".wav"

                # 创建音频数据数组
                audio_data = np.concatenate(int_values1)

                reduced_noise = nr.reduce_noise(y=audio_data[:audio_dat], sr=48000, y_noise=None,
                                                time_constant_s=seconds)
                # 保存音频文件
                save_wav_file(file_name, reduced_noise, self_define_file, 48000)
        # have bug this place,it means we need create different file to storage it,but the num_file is 1 is ok
                break



"""
UDP发送FPGA数据
"""
def UDP_transmitter(max_buffer_once,filename,local_ip = "169.254.51.120",local_port =1234):
    """

    :param audio_data:
    :param local_ip:
    :param local_port:
    :return:
    """
    udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    # 读取音频文件
    audio_data, sr = librosa.load(filename, sr=None)
    # 绑定IP地址和端口
    udp_socket.bind((local_ip, local_port))
    print("UDP 服务器启动成功，等待接收数据...")
    data, addr = udp_socket.recvfrom(max_buffer_once)  # 一次最多接收 字节的数据  > validytes
    print(f'接收到来自{format(addr)}的数据,进行数据处理中...')
    print(f'receive len = {len(data.hex())},receive data ={data.hex()} ,type = {type(data.hex())}')
    hex_data = data.hex()
    int_values = [int(hex_data[i:i + 4], 16) for i in range(0, len(hex_data), 4)]

    if int_values[0] > 5:
    #发送音频数据
        for i in range(len(audio_data)):
            integer_data = [int(sample * (1 << 15)) for sample in audio_data[i]]
            udp_socket.sendto(integer_data.encode("utf-8"), ("127.0.0.1", 1234))



def floatToHex(floatValue):  # float转16进制
    return struct.pack('>f', floatValue).hex().upper()









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



def get_audio_info(audio_file):
    # 加载音频文件
    y, sr = librosa.load(audio_file, sr=None)

    # 获取音频持续时间（秒）
    duration = librosa.get_duration(y=y, sr=sr)

    # 返回持续时间和采样率
    return duration, sr,duration * sr








if __name__ == '__main__':
    print('---------------It is test---------------------')
    print(audio_data_compute(3,channel =1,sr = 48000,bit = 16))
    audio_data = [0.1,-0.01]
    integer_data = [int(sample * (1 << 15)) for sample in audio_data]

    hex_data = [format(sample & 0xFFFF, '04x') for sample in integer_data]
    print(hex_data)
    # re_vec =[]
    #
    # max_buffer_once = 4096
    # num_wav_file = 10
    # wav_name = "fpga_reveive1"
    # self_define_file = "fpga_output"
    #
    # udp_receive(max_buffer_once, wav_name, self_define_file, num_wav_file, local_ip="169.254.51.120", local_port=1234)
    # audio_path = get_filename('C:/Users/86151/Desktop/auido_fft_fir/pythonProject/audio_calssification/fpga_output')
    # for i in range(0,len(audio_path)):
    #     config = utils.parse_opt()
    #     model = load(config)
    #     re1 = predict(config, audio_path[i], model)
    #     re_vec.append(re1)
    # for i in range(0,len(re_vec)):
    #     emotion = 0
    #     if re_vec[i] == 'angry':
    #         emotion = "生气"
    #     elif re_vec[i] == 'fear':
    #         emotion = "害怕"
    #     elif re_vec[i] == 'happy':
    #         emotion = "快乐"
    #     elif re_vec[i] == 'neutral':
    #         emotion = "无动声色"
    #     elif re_vec[i] == 'sad':
    #         emotion = "悲伤"
    #     elif re_vec[i] == 'surprise':
    #         emotion = "惊喜"
    #     else:
    #         print('暂不支持该情绪...')
    #     # age = 20
    #     # gender = "女人"
    #     # prompt = "画一个" + str(age) +"岁"+ "的" + gender + "他的情绪是：" + emotion + "要求该画像细节清晰，全身立绘"
    #     #
    #     # print(emotion)
    #     # API_KEY = "2JVlNgZbBvCvQvAKxDOepXNm"
    #     # SECRET_KEY = "0ZrSzZWEEZeb0vnFz4KKvO5fzGPRsc55"  # 可以换成自己的API
    #     # file_name = "C:/Users/86151/Desktop/auido_fft_fir"
    #     # resolution = "1024*1024"
    #     # style = "写实风格"
    #     # numberofpic = 1
    #     # main_get(API_KEY, SECRET_KEY, file_name, prompt, resolution, style, numberofpic)













