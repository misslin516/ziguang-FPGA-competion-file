import binascii
import os
import struct
import time
import wave
from datetime import datetime
import librosa
import numpy as np
# import models
import utils
import socket
from extract_feats import opensmile as of
from extract_feats import librosa1 as lf
from models import load
import keyboard
import soundfile as sf
from noisereduce_master import noisereduce as nr
from uart import *

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
UDP接收FPGA数据--修改版本
"""
def udp_receive_revised(start,msunbwav_name,self_define_file,choise,num_channels = 1 ,sample_width = 2,frame_rate = 48000,max_buffer_once = 1024,local_ip = "",local_port =3456):

    # 创建UDP套接字
    global filename2, filename1, final_file1, final_file2
    seconds_str= input('-----------------请输入您采集语音的时间（s）------------------\n')
    seconds = int(seconds_str)
    print('---------------------输入成功-----------------------')
    audio_dat = int(audio_data_compute(seconds))
    # 绑定IP地址和端口
    print("UDP 服务器启动成功，等待接收数据...")
    countt = 0
    int_values1 = []
    while  1:
        if choise == 1:
            if countt == 0:
                seconds_str_noise = input('-----------------请输入您采集噪声的的时间（s）------------------\n')
                seconds_noise = int(seconds_str_noise)
                audio_dat_noise = int(audio_data_compute(seconds_noise))
                filename1 = recive_data(start, msunbwav_name, max_buffer_once, audio_dat_noise,local_ip, local_port)
                final_file1 = txtdata_wav_trans(msunbwav_name, num_channels, sample_width, frame_rate)
                countt = 1
            elif countt == 1 and int(input('准备好接收音频 1-yeah 2-No\n')) == 1:
                # print('------------采集音频中...-----------')
                # print('------------采集音频中...-----------')
                # print('------------采集音频中...-----------')
                filename2 = recive_data(start, msunbwav_name, max_buffer_once, audio_dat,local_ip, local_port)
                final_file2 = txtdata_wav_trans(msunbwav_name, num_channels, sample_width, frame_rate)
                countt = 2
            else:
                file_path1 = find_file_by_partial_name(msunbwav_name, final_file1)
                file_path2 = find_file_by_partial_name(msunbwav_name, final_file2)
                audio_data_noise, sr = librosa.load(file_path1, sr=None)
                audio_data1_audio, sr = librosa.load(file_path2, sr=None)


                reduced_noise = nr.reduce_noise(y=audio_data1_audio, sr=48000, y_noise = audio_data_noise,
                                                time_constant_s=seconds)

                f = write_wav_file(msunbwav_name, self_define_file, reduced_noise, sample_rate=48000)
                return f
        else:
            if int(input('准备好接收音频 1-yeah 2-No\n')):
                filename3 = recive_data(start, msunbwav_name, max_buffer_once, audio_dat,local_ip,local_port)
                print(f'写入文件为：{filename3}')
                final_file = txtdata_wav_trans(msunbwav_name, num_channels, sample_width, frame_rate)

                file_path = find_file_by_partial_name(msunbwav_name,final_file)
                audio_data1_audio, sr = librosa.load(file_path, sr=None)

                #引入自动采集----降噪技术
                reduced_noise = nr.reduce_noise(y=audio_data1_audio, sr=48000, y_noise=None,
                                                        time_constant_s=seconds)


                f = write_wav_file(msunbwav_name, self_define_file, reduced_noise, sample_rate=48000)

                return f



def recive_data(flag,filename,max_recv,data_big,ip,port):
    file_name = f"{ filename + datetime.now().strftime('rawData_%Y-%m-%d-%H-%M-%S')}.txt"
    count = 0
    with open(file_name, 'w') as f:
        while flag:
            print('----------------------------UDP RECEIVE-----------------------')
            udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            local_addr = ('', port)
            udp_socket.bind(local_addr)

            recv_data = udp_socket.recvfrom(max_recv)
            result_recv_data = recv_data[0].hex()
            f.write(result_recv_data)
            udp_socket.close()
            count += max_recv
            if keyboard.is_pressed('s'): #s键停止
                break
    return filename

def txtdata_wav_trans(folder_path,num_channels,sample_width,frame_rate = 48000):
    final_filename = []
    for filename in os.listdir(folder_path):
        if filename.endswith(".txt"):
            input_file = os.path.join(folder_path, filename)

            output_file = os.path.splitext(filename)[0] + ".wav"
            output_file = os.path.join(folder_path, output_file)
            final_filename = [final_filename,os.path.splitext(filename)[0]]
            with open(input_file, 'r') as file:
                datas = []
                hex_data = file.read().strip()
                for i in range(0, len(hex_data), 4):
                    low_data = hex_data[i:i + 4][-2:]
                    high_data = hex_data[i:i + 4][0:2]
                    datas.append(low_data)
                    datas.append(high_data)
                datas = ''.join(datas)
                byte_data = binascii.unhexlify(datas)

                wav_file = wave.open(output_file, 'wb')

                num_frames = len(byte_data)

                wav_file.setparams((num_channels, sample_width, frame_rate, num_frames, 'NONE', 'not compressed'))

                wav_file.writeframes(byte_data)

                wav_file.close()
    return final_filename[-1]



def signed_to_unsigned_16bit(signed_int):
    """
    将有符号16位整数转换为无符号16位整数。

    :param signed_int: 一个有符号的16位整数
    :return: 对应的无符号16位整数
    """
    return signed_int & 0xFFFF

"""
UDP发送FPGA数据
"""
def UDP_transmitter(test,filename,sr = 48000,local_ip = "127.0.0.1",local_port =1234):
    """

    :param audio_data:
    :param local_ip:
    :param local_port:
    :return:
    """
    udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    local_addr = ('', local_port)
    udp_socket.bind(local_addr)
    """
    test = 1时，验证是否将数据发送到主机上
    """
    udp_trans_data = []   #先状态机验证 255，255
    if test == 1:
        # 读取音频文件
        audio_data, sr1 = librosa.load(filename, sr=sr)
        print("UDP 服务器启动成功，等待发送数据...")
        # integer_data = [signed_to_unsigned_16bit((sample * (2 ** 15)).astype(np.int16)) for sample in audio_data]
        integer_data =[i for i in range(1, 1001)]#255,255,234,96
        for ii in range(len(integer_data)):
            high_byte =  (integer_data[ii] >> 8) & 0xFF

            low_byte = integer_data[ii] & 0xFF
            udp_trans_data.append(low_byte)
            udp_trans_data.append(high_byte)

        for i in range(len(udp_trans_data)):
            data = struct.pack('!B', udp_trans_data[i])  # 将整数打包为一个字节，'B'表示一个字节无符号整数
            udp_socket.sendto(data, ("192.168.1.11", 1234))

    else:
        audio_data, sr = librosa.load(filename, sr=sr)
        print("UDP 服务器启动成功，等待发送数据...")
        if uart_rx():
        # if  1:
            integer_data = [signed_to_unsigned_16bit((sample * (2 ** 15)).astype(np.int16)) for sample in audio_data]
            for ii in range(len(integer_data)):
                high_byte = (integer_data[ii] >> 8) & 0xFF

                low_byte = integer_data[ii] & 0xFF
                udp_trans_data.append(low_byte)
                udp_trans_data.append(high_byte)
            for i in range(len(udp_trans_data)):
                data = struct.pack('!B', udp_trans_data[i])  # 将整数打包为一个字节，'B'表示一个字节无符号整数
                udp_socket.sendto(data, ("192.168.1.11", 1234))


    print('-------- DONE --------')







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


def read_wav_frames(file_path):
    try:
        with wave.open(file_path, 'rb') as wav_file:
            # 读取所有帧数据
            frames = wav_file.readframes(wav_file.getnframes())
            return frames

    except Exception as e:
        print(f"An error occurred while reading the WAV file: {str(e)}")
        return None


def write_wav_file(folder_path, file_name, audio_data, sample_rate):
    # 创建保存文件的完整路径
    file_path = os.path.join(folder_path, file_name + '.wav')

    try:
        with wave.open(file_path, 'wb') as wav_file:
            # 设置.wav文件的参数
            wav_file.setnchannels(1)  # 单声道
            wav_file.setsampwidth(2)  # 16位宽度
            wav_file.setframerate(sample_rate)  # 采样率

            # 将浮点型音频数据转换为16位整数
            audio_data = np.int16(audio_data * 32767)

            # 写入数据到.wav文件
            wav_file.writeframes(audio_data.tobytes())

        print(f"Successfully saved WAV file: {file_path}")
        return file_path

    except Exception as e:
        print(f"An error occurred while saving the WAV file: {str(e)}")
        return None


def find_file_by_partial_name(directory,partial):
    """
    返回指定目录下包含特定部分文件名的文件的完整路径列表。

    参数:
    directory (str): 目标目录的路径。
    partial_name (str): 要匹配的文件名的部分。

    返回:
    list: 包含符合条件的文件完整路径的列表。
    """
    found_files = []
    wav_files = []
    txt_files = [os.path.splitext(file)[0] for file in os.listdir(directory) if file.endswith(".txt")]

    for file in os.listdir(directory):
        if partial in file:
            found_files.append(os.path.join(directory, file))
    # return found_files

    for file in (found_files):
        if file.endswith(".wav"):
            wav_files.append(os.path.join(directory, file))
    print(wav_files)
    return wav_files[0]


def final_file(directory):
    # List of .wav files in the directory
    txt_files = [file for file in os.listdir(directory) if file.endswith(".wav")]

    # If there are no .wav files, return None
    if not txt_files:
        return None

    # Get the last file in the sorted list
    last_file = sorted(txt_files)[-1]

    # Join the directory path with the last file name
    last_file_path = os.path.join(directory, last_file)

    return last_file_path


if __name__ == '__main__':
    print('---------------It is test---------------------')

    test = 3
    if test == 1:
        filename = "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/audio_wav_pakage/回声音频/gunshot.wav"
        # filename = "D:/fpga_competition/matlabcode_for_check/C 变声测试音频/变声测试音频样本1.m4a"
        UDP_transmitter(1, filename)
    elif test == 2:
        local_ip = "192.168.1.11"
        filename = "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/audio_wav_pakage/回声音频/gunshot.wav"
        # UDP_transmitter(test, filename, 48000,local_ip = local_ip)
        audio_data1, sr = librosa.load(filename, sr=None)
        print(audio_data1)
        file_path = 'C:/Users/86151/Desktop/auido_fft_fir/pythonProject/test/fpga_output/'
        f = write_wav_file(file_path, 'wav1', audio_data1, sample_rate = 48000)
    # filename = "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/audio_wav_pakage/回声音频/gunshot.wav"
    # UDP_fpga_receive(2048, filename)
    elif test == 3:
        file_name = 'C:/Users/86151/Desktop/auido_fft_fir/pythonProject/test/fpga_output/'
        f = udp_receive_revised(1, file_name, 'wav1', 0, num_channels=1, sample_width=2, frame_rate=48000,max_buffer_once=1024, local_ip=" ", local_port=3456)
        print(f'文件地址为：{f}')

    # found_files = find_file_by_partial_name( 'C:/Users/86151/Desktop/auido_fft_fir/pythonProject/test/fpga_output/','rawData_2024-07-12-21-50-04')
    # print(found_files)
    # file_name = 'C:/Users/86151/Desktop/auido_fft_fir/pythonProject/test/fpga_output/'
    # file = final_file(file_name)
    # filename = "D:/fpga_competition/matlabcode_for_check/C 变声测试音频/变声测试音频样本1.m4a"
    # audio_data1_audio, sr = librosa.load(filename, sr=None)
    # print(final_file(file_name))
    # filename = "C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/audio_wav_pakage/回声音频/gunshot.wav"
    # data,sr = librosa.load(filename,sr = None)
    # integer_data = [signed_to_unsigned_16bit((sample * (2 ** 15)).astype(np.int16)) for sample in data]
    # print(data[300])
    # print(data[9000])
    # print(data[23000])
    # print(integer_data[300])
    # print(integer_data[9000])
    # print(integer_data[23000])
    # for i in range(len(data)):
    #     print(signed_to_unsigned_16bit(data[i]*(1 << 15)))
    # a = [1,2,3,4]
    # a.append(6)
    # a.append(6)
    # a.append(6)
    # print(a)
    #
    # file_name = 'C:/Users/86151/Desktop/auido_fft_fir/pythonProject/test/fpga_output/'
    # print(find_file_by_partial_name(file_name,'rawData_2024-07-12-22-19-25'))















