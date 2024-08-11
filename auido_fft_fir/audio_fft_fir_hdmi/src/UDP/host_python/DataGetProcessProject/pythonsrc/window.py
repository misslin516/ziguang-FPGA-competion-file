import tkinter as tkt
import threading as th
import socket as sck
from time import *
HOST =  '192.168.1.105'
PORT = 8080
BUFFSIZE = 1024
CMD_output='1'
addr=('192.168.0.2',8080)
ADDR = (HOST,PORT)
dataout="at %s :%s " %(ctime(),CMD_output)
udpSerSock = sck.socket(sck.AF_INET,sck.SOCK_DGRAM)
udpSerSock.bind(ADDR)
typebtn='normal'

def cmd_output():
    udpSerSock.sendto(CMD_output.encode('ascii'),addr)
    cv.delete(tkt.ALL)
    lt=ListenThread()
    lt.setDaemon(True)
    lt.start()
top = tkt.Tk()
top.attributes("-alpha",0.99)
#width=600,height=600)
top.title('数据采集处理系统')
#top.geometry('1000x650+150+50')

frame_top=tkt.Frame(width=130,height=40,bg='lightseagreen')
frame_top_right=tkt.Frame(width=800,height=40,bg='lightseagreen')
frame_left=tkt.Frame(width=130,height=600,bg='#AFEEEE')
frame_right=tkt.Frame(width=800,height=600,bg='#AFEEEE')
frame_top.grid(row=0,column=0,padx=0,pady=0)
frame_top_right.grid(row=0,column=1,padx=0,pady=0)
frame_left.grid(row=1,column=0,padx=5,pady=3)
frame_right.grid(row=1,column=1,rowspan=1,padx=0,pady=0)

btn_sample=tkt.Button(frame_left,bg='#00C1D1',fg='white',relief=tkt.FLAT,text='导入数据',state=typebtn,command=cmd_output)
btn_sample.place(x=30,y=20)

cv = tkt.Canvas(frame_right,bg='white',width=800,height=600)
cv.pack()

class ListenThread(th.Thread):
    en=1
    def init(self):
        th.Thread.__init__(self)
    def stop(self):
        self.__flag.set()
        self.__running.clear()
    def run(self):
        a=0
        i=0
        d=0
        while True:
            #cv.create_line(110, 10, 10, 100)
            data = udpSerSock.recv(BUFFSIZE)
            #cv.create_line(10, 10, 100, 100)
            i=i+1
            en=0
            #cv.create_line(10, 10, 100, 100)
            for item in range(BUFFSIZE):
                if item==6:
                    #i=i+1
                    if data[item]>=48 and data[item] <58:
                        a = data[item]-48
                    elif data[item]>=65 and data[item] <71:
                        a=data[item]-65+10
                elif item==7:
                    if data[item]>=48 and data[item] <58:
                        b = data[item]-48
                    elif data[item]>=65 and data[item] <71:
                        b=data[item]-65+10
                elif item==8:
                    if data[item]>=48 and data[item] <58:
                        c = data[item]-48
                    elif data[item]>=65 and data[item] <71:
                        c=data[item]-65+10
                    dtemp=d
                    d=512-(a*256+b*16+c)/8
                    cv.create_line(i - 1, dtemp, i, d)

                    #cv.create_line(10, 10, 100, 100)
            if i>511:
                break;
top.mainloop()