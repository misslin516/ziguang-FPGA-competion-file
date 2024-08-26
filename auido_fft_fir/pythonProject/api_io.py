import ssl
import time
import requests
import json
from matplotlib.pyplot import imshow
from io import BytesIO  # BytesIO实现了在内存中读写bytes
from PIL import Image
import os
import matplotlib.pyplot as plt
import httpx
import pyttsx3
from openai import OpenAI
import configparser
import websocket
import datetime
import hashlib
import base64
import hmac
import json
from urllib.parse import urlencode
import time
import ssl
from wsgiref.handlers import format_date_time
from datetime import datetime
from time import mktime
import _thread as thread

"""
the following is API request see :https://console.bce.baidu.com/ai/?_=1714359492019#/ai/intelligentwriting/report/index~appId=4678737
"""

"""
the AI_picture instruction see:https://ai.baidu.com/ai-doc/NLP/qlakgh129
"""

API_KEY = "换成自己的API"
SECRET_KEY = "换成自己的API"  # 可以换成自己的API


def main1(prompt:str,resolution:str,style:str,numberofpic:int,API_KEY,SECRET_KEY):
    """
    :param prompt: format = （AI绘画描述语句）= 画面主体（画什么）+细节词（长什么样子）+风格词（是什么风格）//「公式」= 图片主体，细节词，修饰词
    :param resolution: 1024 * 1024   1024*1536  1536 * 1024
    :param style:see https://ai.baidu.com/ai-doc/NLP/qlakgh129
    :param numberofpic:
    :param API_KEY:
    :param SECRET_KEY:
    :return:
    """
    url = "https://aip.baidubce.com/rpc/2.0/wenxin/v1/basic/textToImage?access_token=" + get_access_token1(API_KEY,SECRET_KEY)

    payload = json.dumps({
        "text": prompt,  # 输入中文描述
        "resolution": resolution,  # 选择图片分辨率，可支持1024*1024、1024*1536、1536*1024
        "style":style,  # 选择图像风格，古风、二次元、写实风格、浮世绘、未来主义、赛博朋克等等
        "num": numberofpic  # 输入要生成的图片数量，可选1~6张
    })

    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    }

    response = requests.request("POST", url, headers=headers, data=payload)

    print(response.text)
    return response.text

def get_access_token1(API_KEY,SECRET_KEY):
    """
    使用 AK，SK 生成鉴权签名（Access Token）
    :return: access_token，或是None(如果错误)
    """
    url = "https://aip.baidubce.com/oauth/2.0/token"
    params = {"grant_type": "client_credentials", "client_id": API_KEY, "client_secret": SECRET_KEY}
    return str(requests.post(url, params=params).json().get("access_token"))

def main(task_id:str,filename:str,prompt:str,API_KEY,SECRET_KEY):


    # API接口的url
    url = "https://aip.baidubce.com/rpc/2.0/wenxin/v1/basic/getImg?access_token=" + get_access_token_revised()

    payload = json.dumps({
        "taskId": task_id
    })
    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    }

    response = requests.request("POST", url, headers=headers, data=payload)

    print(response.text)
    print('请求的返回值：', response.text)
    json_result = json.loads(response.text)
    # imgUrls = json_result['data']['img_url']  # 返回img_urls的结果
    imgUrls = json_result['data']["imgUrls"]
    # imgUrls = json_result['data'][ "sub_task_result_list"]["final_image_list"]["img_url"]
    print("imgUrls的返回值：",
          imgUrls)  # imgUrls":[{"image":"https://wenxin.baidu.com/younger/file/ERNIE-ViLG/4a90992981919xxxxxx"},{"image":"https://wenxin.baidu.com/younger/file/ERNIE-ViLG/4a90992981919a74f0b4xxxxx"}]
    print("imgUrls类型：", type(imgUrls))  # 查看imgUrls类型，是列表
    print("imgUrls数量：", len(imgUrls))

    # 获得图片网址并将图片保存到本地
    for i in range(0, len(imgUrls)):
        img_url = imgUrls[i]
        print('imges_url:', img_url)
        img_url = img_url['image']
        print('image_url:', img_url)
        # 保存图片到本地
        req = requests.get(img_url)  # 获取图片网址
        image = Image.open(BytesIO(req.content))  # 在内存中打开图片
        image.save(os.path.join(filename, '{}_{}.jpg'.format(i,prompt)), 'JPEG')


# 获取Access Token
def get_access_token():
    """
    使用 AK，SK 生成鉴权签名（Access Token）
    :return: access_token，或是None(如果错误)
    """
    url = "https://aip.baidubce.com/oauth/2.0/token"
    params = {"grant_type": "client_credentials", "client_id": API_KEY, "client_secret": SECRET_KEY}
    return str(requests.post(url, params=params).json().get("access_token"))



def picture_show1(folder_path:str, keyword:str):
    """
    :param folder_path:
    :param keyword: 我们希望仅仅读取prompt对应的图片供用户选择
    :return:
    """
    # 获取文件夹中的所有文件
    files = os.listdir(folder_path)

    # 遍历文件夹中的每个文件
    for file_name in files:
        # 检查文件是否为图像文件（这里假设只处理 JPEG 和 PNG 格式的图像）
        if file_name.endswith(('.jpg', '.jpeg', '.png')):
            # 检查文件名是否包含关键词
            if keyword in file_name:
                # 构建图像文件的完整路径
                file_path = os.path.join(folder_path, file_name)
                # 使用 PIL 打开图像
                image = Image.open(file_path)
                # 显示图像
                plt.imshow(image)
                plt.axis('off')  # 关闭坐标轴
                plt.show()

def main_revised(taskId):
    url = "https://aip.baidubce.com/rpc/2.0/wenxin/v1/basic/getImg?access_token=" + get_access_token_revised()

    payload = json.dumps({
        "taskId": str(taskId)
    })
    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    }

    response = requests.request("POST", url, headers=headers, data=payload)

    print(response.text)


def get_access_token_revised():
    """
    使用 AK，SK 生成鉴权签名（Access Token）
    :return: access_token，或是None(如果错误)
    """
    url = "https://aip.baidubce.com/oauth/2.0/token"
    params = {"grant_type": "client_credentials", "client_id": API_KEY, "client_secret": SECRET_KEY}
    return str(requests.post(url, params=params).json().get("access_token"))




#test example

def main_get(API_KEY,SECRET_KEY,file_name,prompt,resolution,style,numberofpic):
    file_name1 = file_name + "/"
    respose = main1(prompt, resolution, style, numberofpic, API_KEY, SECRET_KEY)
    response_dict = json.loads(respose)
    print(response_dict)
    task_id = response_dict['data']['taskId']  #获取生成任务ID
    print("图片生成中，请稍后...")
    time.sleep(20 * numberofpic)  #生成图片时需要等待
    print("图片已生成，正在为您打开，请稍后...")
    main_re(task_id,prompt)
    picture_show_re(file_name, prompt)


def main_re(taskId,prompt):
    url = "https://aip.baidubce.com/rpc/2.0/wenxin/v1/basic/getImg?access_token=" + get_access_token_re()

    payload = json.dumps({
        "taskId": taskId
    })
    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    }

    response = requests.post(url, headers=headers, data=payload)
    json_result = response.json()
    imgUrls = json_result['data']["imgUrls"]

    print("imgUrls的返回值：", imgUrls)
    print("imgUrls类型：", type(imgUrls))
    print("imgUrls数量：", len(imgUrls))

    # prompt = "image_description"  # Define your prompt string

    # 获得图片网址并将图片保存到本地
    for i, img_url_dict in enumerate(imgUrls):
        img_url = img_url_dict['image']
        print('image_url:', img_url)

        # 保存图片到本地
        req = requests.get(img_url)  # 获取图片网址
        image = Image.open(BytesIO(req.content))  # 在内存中打开图片

        file_path = os.path.join('C:/Users/86151/Desktop/auido_fft_fir/pythonProject/test/', f'{i}_{prompt}.jpg')
        image.save(file_path, 'JPEG')
        picture_show1('C:/Users/86151/Desktop/auido_fft_fir/pythonProject/test/', prompt)


def get_access_token_re():
    """
    使用 AK，SK 生成鉴权签名（Access Token）
    :return: access_token，或是None(如果错误)
    """
    url = "https://aip.baidubce.com/oauth/2.0/token"
    params = {"grant_type": "client_credentials", "client_id": API_KEY, "client_secret": SECRET_KEY}
    return str(requests.post(url, params=params).json().get("access_token"))


def picture_show_re(folder_path: str, keyword: str):
    """
    :param folder_path:
    :param keyword: 我们希望仅仅读取prompt对应的图片供用户选择
    :return:
    """
    # 获取文件夹中的所有文件
    files = os.listdir(folder_path)

    # 遍历文件夹中的每个文件
    for file_name in files:
        # 检查文件是否为图像文件（这里假设只处理 JPEG 和 PNG 格式的图像）
        if file_name.endswith(('.jpg', '.jpeg', '.png')):
            # 检查文件名是否包含关键词
            if keyword in file_name:
                # 构建图像文件的完整路径
                file_path = os.path.join(folder_path, file_name)
                # 使用 PIL 打开图像
                image = Image.open(file_path)
                # 显示图像
                plt.imshow(image)
                plt.axis('off')  # 关闭坐标轴
                plt.show()


# -*- coding:utf-8 -*-
#
#   author: iflytek
#
#  本demo测试时运行的环境为：Windows + Python3.7
#  本demo测试成功运行时所安装的第三方库及其版本如下，您可自行逐一或者复制到一个新的txt文件利用pip一次性安装：
#   cffi==1.12.3
#   gevent==1.4.0
#   greenlet==0.4.15
#   pycparser==2.19
#   six==1.12.0
#   websocket==0.2.1
#   websocket-client==0.56.0
#
#  语音听写流式 WebAPI 接口调用示例 接口文档（必看）：https://doc.xfyun.cn/rest_api/语音听写（流式版）.html
#  webapi 听写服务参考帖子（必看）：http://bbs.xfyun.cn/forum.php?mod=viewthread&tid=38947&extra=
#  语音听写流式WebAPI 服务，热词使用方式：登陆开放平台https://www.xfyun.cn/后，找到控制台--我的应用---语音听写（流式）---服务管理--个性化热词，
#  设置热词
#  注意：热词只能在识别的时候会增加热词的识别权重，需要注意的是增加相应词条的识别率，但并不是绝对的，具体效果以您测试为准。
#  语音听写流式WebAPI 服务，方言试用方法：登陆开放平台https://www.xfyun.cn/后，找到控制台--我的应用---语音听写（流式）---服务管理--识别语种列表
#  可添加语种或方言，添加后会显示该方言的参数值
#  错误码链接：https://www.xfyun.cn/document/error-code （code返回错误码时必看）
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# This code include the function of tranmiting audio into txt,and let txt become prompt access to 通义千问

STATUS_FIRST_FRAME = 0  # 第一帧的标识
STATUS_CONTINUE_FRAME = 1  # 中间帧标识
STATUS_LAST_FRAME = 2  # 最后一帧的标识
final_sentance = ''


class Ws_Param(object):
    # 初始化
    def __init__(self, APPID, APIKey, APISecret, AudioFile):
        self.APPID = APPID
        self.APIKey = APIKey
        self.APISecret = APISecret
        self.AudioFile = AudioFile

        # 公共参数(common)
        self.CommonArgs = {"app_id": self.APPID}
        # 业务参数(business)，更多个性化参数可在官网查看
        self.BusinessArgs = {"domain": "iat", "language": "zh_cn", "accent": "mandarin", "vinfo":1,"vad_eos":10000}

    # 生成url
    def create_url(self):
        url = 'wss://ws-api.xfyun.cn/v2/iat'
        # 生成RFC1123格式的时间戳
        now = datetime.now()
        date = format_date_time(mktime(now.timetuple()))

        # 拼接字符串
        signature_origin = "host: " + "ws-api.xfyun.cn" + "\n"
        signature_origin += "date: " + date + "\n"
        signature_origin += "GET " + "/v2/iat " + "HTTP/1.1"
        # 进行hmac-sha256进行加密
        signature_sha = hmac.new(self.APISecret.encode('utf-8'), signature_origin.encode('utf-8'),
                                 digestmod=hashlib.sha256).digest()
        signature_sha = base64.b64encode(signature_sha).decode(encoding='utf-8')

        authorization_origin = "api_key=\"%s\", algorithm=\"%s\", headers=\"%s\", signature=\"%s\"" % (
            self.APIKey, "hmac-sha256", "host date request-line", signature_sha)
        authorization = base64.b64encode(authorization_origin.encode('utf-8')).decode(encoding='utf-8')
        # 将请求的鉴权参数组合为字典
        v = {
            "authorization": authorization,
            "date": date,
            "host": "ws-api.xfyun.cn"
        }
        # 拼接鉴权参数，生成url
        url = url + '?' + urlencode(v)
        # print("date: ",date)
        # print("v: ",v)
        # 此处打印出建立连接时候的url,参考本demo的时候可取消上方打印的注释，比对相同参数时生成的url与自己代码生成的url是否一致
        # print('websocket url :', url)
        return url


# 收到websocket消息的处理
def on_message(ws, message):
    global final_sentance
    try:
        code = json.loads(message)["code"]
        sid = json.loads(message)["sid"]
        if code != 0:
            errMsg = json.loads(message)["message"]
            print("sid:%s call error:%s code is:%s" % (sid, errMsg, code))

        else:
            w_values = []
            data = json.loads(message)["data"]["result"]["ws"]
            # print(json.loads(message))
            result = ""
            for i in data:
                for w in i["cw"]:
                    result += w["w"]
            # print("sid:%s call success!,data is:%s" % (sid, json.dumps(data, ensure_ascii=False)))
            for item in data:
                for cw_item in item['cw']:
                    if 'w' in cw_item:
                        w_values.append(cw_item['w'])
            sentence= ''.join(w_values)
            print( f'the correct answer is{sentence}')
            final_sentance += sentence
    except Exception as e:
        print("receive msg,but parse exception:", e)



# 收到websocket错误的处理
def on_error(ws, error):
    print("### error:", error)


# 收到websocket关闭的处理
def on_close(ws,a,b):
    print("### closed ###")


# 收到websocket连接建立的处理
def on_open(ws):
    def run(*args):
        frameSize = 8000  # 每一帧的音频大小
        intervel = 0.04  # 发送音频间隔(单位:s)
        status = STATUS_FIRST_FRAME  # 音频的状态信息，标识音频是第一帧，还是中间帧、最后一帧

        with open(wsParam.AudioFile, "rb") as fp:
            while True:
                buf = fp.read(frameSize)
                # 文件结束
                if not buf:
                    status = STATUS_LAST_FRAME
                # 第一帧处理
                # 发送第一帧音频，带business 参数
                # appid 必须带上，只需第一帧发送
                if status == STATUS_FIRST_FRAME:

                    d = {"common": wsParam.CommonArgs,
                         "business": wsParam.BusinessArgs,
                         "data": {"status": 0, "format": "audio/L16;rate=16000",
                                  "audio": str(base64.b64encode(buf), 'utf-8'),
                                  "encoding": "raw"}}
                    d = json.dumps(d)
                    ws.send(d)
                    status = STATUS_CONTINUE_FRAME
                # 中间帧处理
                elif status == STATUS_CONTINUE_FRAME:
                    d = {"data": {"status": 1, "format": "audio/L16;rate=16000",
                                  "audio": str(base64.b64encode(buf), 'utf-8'),
                                  "encoding": "raw"}}
                    ws.send(json.dumps(d))
                # 最后一帧处理
                elif status == STATUS_LAST_FRAME:
                    d = {"data": {"status": 2, "format": "audio/L16;rate=16000",
                                  "audio": str(base64.b64encode(buf), 'utf-8'),
                                  "encoding": "raw"}}
                    ws.send(json.dumps(d))
                    time.sleep(1)
                    break
                # 模拟音频采样间隔
                time.sleep(intervel)
        ws.close()

    thread.start_new_thread(run, ())

# 通义千问API
#simple API interface
def llm_api(messages):
    config = configparser.ConfigParser()
    config.read('config.ini')
    api_key = config.get('openai', 'api_key')
    base_url = config.get('openai', 'base_url')
    model_name = config.get('openai', 'model_name')
    client = OpenAI(
        api_key=api_key,
        base_url=base_url,
        http_client=httpx.Client(verify=False)
    )
    completion = client.chat.completions.create(
        model= model_name,
        messages=[{"role": "user", "content": messages}]
    )
    result = json.loads(completion.model_dump_json())

    return result['choices'][0]['message']['content']

# use pyttsx3  to make the function of transmiting txt to audio beconme true
def txt2audio(choice,savchoice,txt,filename):
    engine = pyttsx3.init()  # object creation
    if choice == 1:
        """ RATE"""
        rate = engine.getProperty('rate')   # getting details of current speaking rate
        print (f'The current rate is {rate}')                        #printing current voice rate
        new_rate = float(input('-----------------请输入您想要的说话速度-------------------\n'))
        engine.setProperty('rate', new_rate)     # setting up new voice rate
    elif choice == 2:
        """VOLUME"""
        volume = engine.getProperty('volume')   #getting to know current volume level (min=0 and max=1)
        print(f'The current rate is {volume}')
        new_volume =float(input('-----------------请输入您想要的播放音量(0-1)-------------------\n'))
        engine.setProperty('volume',new_volume)    # setting up volume level  between 0 and 1
    elif choice == 3:
        """VOICE"""
        voices = engine.getProperty('voices')       #getting details of current voice
        new_voices = int(input('-----------------请输入您想要的说话人性别（0-male,1-female)-------------------\n'))
        #engine.setProperty('voice', voices[0].id)  #changing index, changes voices. o for male
        # engine.setProperty('voice', voices[1].id)   #changing index, changes voices. 1 for female
        engine.setProperty('voice', voices[new_voices].id)
    else:
        print('Do not support this choice!!!')
    if savchoice:
        engine.save_to_file(txt, 'test.mp3')
        engine.runAndWait()
    else:
        engine.say(txt)
        engine.runAndWait()





if __name__ == '__main__':
    API_KEY = "自己的API"
    SECRET_KEY = "自己的API"  # 可以换成自己的API
    file_name = "C:/Users/86151/Desktop/auido_fft_fir"

    gender = input(f'请输入性别\n')
    emotion = input(f'请输入情绪\n')

    prompt = "画一个很"+emotion+"的"+ gender
    resolution = "1024*1024"
    style = "写实风格"
    numberofpic = 1
    main_get(API_KEY, SECRET_KEY, file_name, prompt, resolution, style, numberofpic)

    print()
    # note：
        # 1.测试时候在此处正确填写相关信息即可运行
        # 2.相应的API可以在官网自己申请
    time1 = datetime.now()
    wsParam = Ws_Param(APPID='自己的API', APISecret='自己的API',
                       APIKey='自己的API',
                       AudioFile=r"audio/id00841-enroll.wav")     #
    websocket.enableTrace(False)
    wsUrl = wsParam.create_url()
    ws = websocket.WebSocketApp(wsUrl, on_message=on_message, on_error=on_error, on_close=on_close)
    ws.on_open = on_open
    ws.run_forever(sslopt={"cert_reqs": ssl.CERT_NONE})
    time2 = datetime.now()
    print(time2-time1)
    print(final_sentance)
    return_message = llm_api(final_sentance)  #该API不能够支持较长的文本
    print(return_message)
    #
    txt2audio(0, 0,str(return_message),0)


