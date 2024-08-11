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

import requests
import json

from click import prompt

API_KEY = "z2bHcykNdmUEufig352qsuw8"
SECRET_KEY = "oJNgl5yo8SwDya1Aw3s6tX17j2KFx44s"


def main():
    url = "https://aip.baidubce.com/rpc/2.0/wenxin/v1/basic/getImg?access_token=" + get_access_token()

    payload = json.dumps({
        "taskId": "1816385834356418073"
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

    prompt = "image_description"  # Define your prompt string

    # 获得图片网址并将图片保存到本地
    for i, img_url_dict in enumerate(imgUrls):
        img_url = img_url_dict['image']
        print('image_url:', img_url)

        # 保存图片到本地
        req = requests.get(img_url)  # 获取图片网址
        image = Image.open(BytesIO(req.content))  # 在内存中打开图片

        file_path = os.path.join('C:/Users/86151/Desktop/auido_fft_fir/pythonProject/test/', f'{i}_{prompt}.jpg')
        image.save(file_path, 'JPEG')
    picture_show1('C:/Users/86151/Desktop/auido_fft_fir/pythonProject/test/','image_description')


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



if __name__ == '__main__':
    main()