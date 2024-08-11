import ssl
import time
import requests
import json
from matplotlib.pyplot import imshow
from io import BytesIO  # BytesIO实现了在内存中读写bytes
from PIL import Image
import os
import matplotlib.pyplot as plt

"""
the following is API request see :https://console.bce.baidu.com/ai/?_=1714359492019#/ai/intelligentwriting/report/index~appId=4678737
"""

"""
the AI_picture instruction see:https://ai.baidu.com/ai-doc/NLP/qlakgh129
"""

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
    url = "https://aip.baidubce.com/rpc/2.0/ernievilg/v1/txt2img?access_token=" + get_access_token1(API_KEY,SECRET_KEY)

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
    url = "https://aip.baidubce.com/rpc/2.0/ernievilg/v1/getImg?access_token=" + get_access_token(API_KEY,SECRET_KEY)
    # 发送请求获取网页内容
    payload = json.dumps({
        "taskId": task_id
    })
    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    }
    response = requests.request("POST", url, headers=headers, data=payload)
    print(response)
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
def get_access_token(API_KEY,SECRET_KEY):
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

#test example

def main_get(API_KEY,SECRET_KEY,file_name,prompt,resolution,style,numberofpic):
    file_name1 = file_name + "/"
    respose = main1(prompt, resolution, style, numberofpic, API_KEY, SECRET_KEY)
    response_dict = json.loads(respose)
    task_id = response_dict['data']['taskId']  #获取生成任务ID
    print("图片生成中，请稍后...")
    time.sleep(10 * numberofpic)  #生成图片时需要等待
    print("图片已生成，正在为您打开，请稍后...")
    main(str(int(task_id)), file_name1, prompt,API_KEY,SECRET_KEY)
    # picture_show(file_name)
    picture_show1(file_name, prompt)







if __name__ == '__main__':
    API_KEY = "2JVlNgZbBvCvQvAKxDOepXNm"
    SECRET_KEY = "0ZrSzZWEEZeb0vnFz4KKvO5fzGPRsc55"  # 可以换成自己的API
    file_name = "C:/Users/86151/Desktop/auido_fft_fir"

    gender = input(f'请输入性别\n')
    emotion = input(f'请输入情绪\n')

    prompt = "画一个很"+emotion+"的"+ gender
    resolution = "1024*1024"
    style = "写实风格"
    numberofpic = 1
    main_get(API_KEY, SECRET_KEY, file_name, prompt, resolution, style, numberofpic)


