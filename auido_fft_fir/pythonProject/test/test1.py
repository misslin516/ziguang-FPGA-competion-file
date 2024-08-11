import os
import socket
import time
import wave
from array import array
import scipy.io as sio
import numpy as np
import utils
def save_wav_file(filename, audio_data, self_define_file:str,sample_rate):
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
    print('写入文件中...')
    # 写入 WAV 文件
    with wave.open(output_file, 'wb') as wf:
        wf.setnchannels(1)  # 1-单声道音频 2-double
        wf.setsampwidth(2)  # 采样位宽（字节数）
        wf.setframerate(sample_rate)  # 采样率
        wf.writeframes(scaled_audio_data.tobytes())

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


if __name__ == '__main__':

    # 创建UDP套接字
    udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    # 绑定IP地址和端口
    local_ip = "169.254.51.120"
    local_port = 1234  # 可以根据需要修改为您自己的端口号
    udp_socket.bind((local_ip, local_port))
    validytes = 40  # 单次有效数据   因为数据量过大要分多次接收
    total_validytes = 0   # 总数据个数
    numberoftrans = 1
    print("UDP 服务器启动成功，等待接收数据...")
    # 接收数据
    MonteCarlo = 3
    count = 0
    data1 = []
    int_values1 = []


    while True:
        data, addr = udp_socket.recvfrom(4096)  # 一次最多接收 字节的数据  > validytes
        print(f'接收到来自{format(addr)}的数据,进行数据处理中...')
        print(f'receive len = {len(data.hex())},receive data ={data.hex()} ,type = {type(data.hex())}')

        hex_data = data.hex()
        int_values = [int(hex_data[i:i + 4], 16) for i in range(0, len(hex_data), 4)]

        print(f'int_values = ')
        print(f'int_values =')
        print(f'int_values = {int_values}')

        int_values1.append(int_values[1::2])
        print(f'the data = {int_values[1::2]}')



