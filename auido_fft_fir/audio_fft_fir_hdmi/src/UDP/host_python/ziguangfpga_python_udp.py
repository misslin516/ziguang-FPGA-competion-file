

def compare_matrix(a,b):
    if a.ndim == b.ndim:
        if len(a) == len(b):
            for i in range(len(a)):
                if a[i] == b[i]:
                    return 1
                else:
                    print('数组不相等')
        else:
            print('维度不一致')
    else:
        print('维度不一致')

if __name__ == '__main__':

    import socket
    import numpy as np
    # 创建UDP套接字
    udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    # 绑定IP地址和端口
    local_ip = "169.254.51.120"
    local_port = 1234  # 可以根据需要修改为您自己的端口号
    udp_socket.bind((local_ip, local_port))
    validytes = 500   #单词有效数据   因为数据量过大要分多次接收
    total_validytes = 9999
    total_validytes_matrix = np.zeros(total_validytes,1)
    print("UDP 服务器启动成功，等待接收数据...")

    # 接收数据
    while True:
        while 1:
            valid_data = []
            data, addr = udp_socket.recvfrom(2000)  # 一次最多接收 字节的数据
            # 将接收到的十六进制数据解析为整数数组
            int_values = [int(data.hex()[i:i + 4], 16) for i in range(0, len(data), 4)]
            # print(int_values)
            # print(int_values[0])
            #截取有效数据段
            valid_data = np.concatenate((valid_data, int_values), axis=0)
            if len(valid_data) >= 100*validytes:
                break
        udp_socket.close()
        break
    # print(f'valid_data is {valid_data}')
    valid_num = validytes
    valid_data_true = np.zeros((valid_num,3))   #具体根据FPGA修改
    j = []
    for i in range(len(valid_data)):
        if valid_data[i] == 61530:  #判断帧头
            j.append(i)

    for jj  in range(len(j)):
        if jj == 0:
            # valid_data[j[jj] + 4:j[jj] + 4 + valid_num + 1].shape
            valid_data_true[0:valid_num,0] = valid_data[j[jj]+4:j[jj]+4+valid_num]
        elif jj >2:
               if jj == 1:
                    valid_data_true[0:valid_num,1] = valid_data[j[jj] + 4:j[jj] + 4 + valid_num]
               elif jj == 2:
                    valid_data_true[0:valid_num, 1] = valid_data[j[jj] + 4:j[jj] + 4 + valid_num]


    if valid_data_true[0].all() == valid_data_true[1].all():
        if valid_data_true[1].all() == valid_data_true[2].all():
            print(f'成功捕获到的数据为：{valid_data_true[:,0]}')
            print(f'捕获到的数据维度为：{len(valid_data_true[:,0])}')









