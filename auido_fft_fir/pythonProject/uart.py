import serial
import serial.tools.list_ports

def uart_rx(port = "COM14" ,str = b'udp.start.trans\r\r\n'):
    ports_list = list(serial.tools.list_ports.comports())
    if len(ports_list) <= 0:
        print("NO UART EQUIPMENT")
    else:
        ser = serial.Serial(port= port, baudrate=115200, timeout=1)
        while True:
            com_input = ser.read(100)
            print(f'data form uart is :{com_input}')
            if str in com_input:
                print('----UDP TRANSMISSION----')
                return 1
            # if com_input:  # 如果读取结果非空，则输出
            #     return com_input




def uart_tx(data, port = "COM14" ):
    ports_list = list(serial.tools.list_ports.comports())
    if len(ports_list) <= 0:
        print("NO UART EQUIPMENT")
    else:
        ser = serial.Serial(port=port, baudrate=115200)
        write_len = ser.write(data.encode('utf-8'))
        print("串口发出{}个字节。".format(write_len))
        ser.close()

if __name__ == '__main__':
   data =  uart_rx()
   print(data)