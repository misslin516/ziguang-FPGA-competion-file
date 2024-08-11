import argparse
import base64
import functools
import hashlib
import hmac
import os
import shutil
import ssl
import struct
import time
import wave
import socket
from datetime import datetime
from urllib.parse import urlencode
from wsgiref.handlers import format_date_time

import httpx
import librosa
import matplotlib
import numpy as np
from tornado import websocket

from api_io import main_get
from audio_calssification import utils
from audio_calssification.VoiceprintRecognition import audio_classification
from audio_calssification.VoiceprintRecognition.audio_classification import batch_compare, sort_txt, save_audio_files
from audio_calssification.VoiceprintRecognition.mvector.predict import MVectorPredictor
from audio_calssification.VoiceprintRecognition.mvector.utils.record import RecordAudio
from audio_calssification.VoiceprintRecognition.mvector.utils.utils import add_arguments, print_arguments
from audio_calssification.models import load
from change_voice import voice
from gender_and_emotion.Speech_Emotion_Recognition_master.predict import predict
from predict import udp_receive_revised, get_filename, UDP_transmitter
from Code import GenderIdentifier
import soundfile as sf
import os
import glob
from audio_calssification.vocal_music_separate_main import start
import torch
from modelscope import snapshot_download, AutoModelForCausalLM, AutoTokenizer, GenerationConfig


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
matplotlib.use('agg')#避免与 Qt 或其他 GUI 工具包的兼容性问题

import soundfile as sf
import numpy as np
import os
import librosa as lb
import torch
from torch.utils.data import DataLoader, Dataset
from tqdm import tqdm
from audio_calssification.audio_classification import resnet
from audio_calssification.audio_classification import sound_untils
from audio_calssification.audio_classification import wav_to_mp3
# define
STATUS_FIRST_FRAME = 0  # 第一帧的标识
STATUS_CONTINUE_FRAME = 1  # 中间帧标识
STATUS_LAST_FRAME = 2  # 最后一帧的标识
final_sentance = ''

os.environ["CUDA_VISIBLE_DEVICES"] = "0"
device = "cpu"
bird_model = resnet.ResNet().to(device)
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
        date = format_date_time(time.mktime(now.timetuple()))

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
    if int(input('---------------------------FPGA-->PC?(1---yes,0---No)---------------------------\n')):
        test = 0    #用以测试初始值
        max_buffer_once = 4096
        num_wav_file = 1
        # wav_name = "fpga_reveive1"
        self_define_file ='C:/Users/86151/Desktop/auido_fft_fir/pythonProject/test/fpga_output/'
        destination_folder = 'C:/Users/86151/Desktop/auido_fft_fir/pythonProject/fpga_output/'
        print('------------------------------UDP RECEIVE---------------------------------')
        choice = int(input('是否单独采集噪声： 1 -- YES ,2 -- NO\n'))
        wav_name = str(input('--------------------输入保存的音频文件名字----------------\n'))
        file_youwanna = udp_receive_revised(1, self_define_file, wav_name, choice, num_channels=1, sample_width=2, frame_rate=48000, max_buffer_once=1024,
                            local_ip=" ", local_port=3456)
    #should revised 只针对于采集的音频进行识别
        # file_youwanna = 'C:/Users/86151/Desktop/auido_fft_fir/pythonProject/test/fpga_output/test1111.wav'
        print(f'保存的文件地址为：{file_youwanna}')
        shutil.copy(file_youwanna, destination_folder)
        print(f'新文件地址为：{destination_folder}')
        audio_path = get_filename('C:/Users/86151/Desktop/auido_fft_fir/pythonProject/fpga_output/')
        re_vec = []
        Emotion = []
        gender = []
        print('------------------------------PREDICT EMOTION---------------------------------')
        print('---------请选择你想要进行情绪识别的模型：-----------\n')
        model_choise = int(input('1 -- CNN,2 -- LSTM,3 -- MLP ,4 -- SVM\n'))
        if model_choise == 1:
            model_file = 'C:/Users/86151/Desktop/auido_fft_fir/pythonProject/gender_and_emotion/Speech_Emotion_Recognition_master/configs/cnn1d.yaml'
        elif model_choise == 2:
            model_file = 'C:/Users/86151/Desktop/auido_fft_fir/pythonProject/gender_and_emotion/Speech_Emotion_Recognition_master/configs/lstm.yaml'
        elif model_choise == 3:
            model_file = 'C:/Users/86151/Desktop/auido_fft_fir/pythonProject/gender_and_emotion/Speech_Emotion_Recognition_master/configs/mlp.yaml'
        else:
            model_file = 'C:/Users/86151/Desktop/auido_fft_fir/pythonProject/gender_and_emotion/Speech_Emotion_Recognition_master/configs/svm.yaml'


        config = utils.parse_opt(model_file)
        model = load(config)
        re1 = predict(config, file_youwanna, model)
        re_vec.append(re1)
        for i in range(0, len(re_vec)):
            emotion = []
            if re_vec[i] == 'angry':       emotion = "生气"
            elif re_vec[i] == 'fear':      emotion = "害怕"
            elif re_vec[i] == 'happy':     emotion = "快乐"
            elif re_vec[i] == 'neutral':   emotion = "波澜不惊、不动声色"
            elif re_vec[i] == 'sad':       emotion = "悲伤"
            elif re_vec[i] == 'surprise':  emotion = "惊喜"
            else: print('暂不支持该情绪...')
            Emotion.append(emotion)
        print('------------------------------PREDICT GENDER---------------------------------')
        if test:
            os.chdir("C:\\Users\\86151\Desktop\\auido_fft_fir\\pythonProject\\audio_calssification\\Code")
            gender_identifier = GenderIdentifier.GenderIdentifier("TestingData/females", "TestingData/males", "females.gmm", "males.gmm")
            gender_identifier.process()
        else:
            file = 'C:/Users/86151/Desktop/auido_fft_fir/pythonProject/audio_calssification/Code/'
            gender_identifier = GenderIdentifier.GenderIdentifier(destination_folder, destination_folder, file+"females.gmm",file+"males.gmm")
            gender = gender_identifier.process_fpga()
        print('------------------------------API PICTURE---------------------------------')



        for ii in range(len(audio_path)):
            prompt = []
            if  gender[ii] == "male":
                prompt = "画一个" + "很" + Emotion[ii] + "的" + "男孩"
            elif  gender[ii] == "female":
                prompt = "画一个" + "很" + Emotion[ii] + "的" + "女孩"
            file_name = 'C:/Users/86151/Desktop/auido_fft_fir/pythonProject/test'   #存放图片路径
            resolution = "1024*1024"   #分辨率
            style = "写实风格"
            numberofpic = 1     #数量
            API_KEY = "z2bHcykNdmUEufig352qsuw8"
            SECRET_KEY = "oJNgl5yo8SwDya1Aw3s6tX17j2KFx44s"
            main_get(API_KEY, SECRET_KEY, file_name, prompt, resolution, style, numberofpic)



        Adjustmentschoice = int(input('是否需要进行人声调整:1 -- Yes , 2 -- NO\n'))
        if Adjustmentschoice:
            print('------------------------------Vocal Adjustments---------------------------------')
            y, fs = sf.read(file_youwanna)
            x1 = y
            if gender == 'male':
                frqratio = 1
                ratio = 0.52
                Traudio = voice(x1, ratio)
                sf.write("变声测试音频样本2_output.wav", Traudio, int(frqratio * fs))
            else:
                frqratio = 1
                ratio = 1.52
                Traudio = voice(x1, ratio)
                sf.write("变声测试音频样本2_output.wav", Traudio, int(frqratio * fs))


        Separationchoice = int(input('是否需要进行人声分离:1 -- Yes , 2 -- NO\n'))
        if Separationchoice:
            print('------------------------------AUDIO SEPARATION---------------------------------')
            # 记录当前工作目录
            original_dir = os.getcwd()
            print("Original Directory:", original_dir)

            # 要切换到的新目录
            new_dir = 'C:/Users/86151/Desktop/auido_fft_fir/pythonProject/audio_calssification/vocal_music_separate_main'

            try:
                # 切换到新目录
                os.chdir(new_dir)
                print("Switched to New Directory:", os.getcwd())
                # audio_path1 = get_filename('C:/Users/86151/Desktop/auido_fft_fir/pythonProject/fpga_output/')
                start.start(file_youwanna)
                # 在新目录下执行一些操作
                # ...
            finally:
                # 切换回原来的工作目录
                os.chdir(original_dir)
                print("Switched Back to Original Directory:", os.getcwd())

        if int(input('是否需要进行声音分类（wake,explosion etc）:1 -- Yes , 2 -- NO\n')):
            voice_class_list = ["explosion", "mohanveena", "screaming", "sitar", "violin", "wake"]
            bird_model.load_state_dict(torch.load("C:/Users/86151/Desktop/auido_fft_fir/pythonProject/audio_calssification/audio_classification/sound_model.pth"))
            sr = sampling_rate = 48000
            n_mels = 128
            fmin = 0
            fmax = sr // 2
            duration = 8
            audio_length = duration * sr  # 48000 * 8
            step = audio_length
            res_type = "kaiser_fast"
            resample = True
            train = True

            # data="./dataset/音频分类/wake/A00036_S0001.mp3"#单个文件测试
            # data = 'C:/Users/86151/Desktop/auido_fft_fir/pythonProject/audio_calssification/audio_classification/test/gunshot.wav'
            data = file_youwanna


            audio, orig_sr = sf.read(data, dtype="float32")

            if audio.ndim > 1:
                audio = audio[:, 0]

            if resample and orig_sr != sr:
                audio = lb.resample(audio, orig_sr=orig_sr, target_sr=sr, res_type=res_type)

            audio = sound_untils.crop_or_pad(audio, length=sampling_rate * 8)
            images = sound_untils.audio_to_image(audio, sr, n_mels, fmin, fmax)
            images = torch.unsqueeze(torch.tensor(images, dtype=torch.float), dim=0).to(device)
            logits = bird_model(images)
            print(logits)
            print("---------------------")
            logits = torch.nn.Softmax(-1)(logits)
            logits = torch.argmax(logits, dim=-1)
            print(logits)
            print(logits.item())
            if logits.item() == 0:
                print(f'--------------------检测到爆炸的声音--------------------')
            elif logits.item() == 1:
                print(f'--------------------检测到滑音吉他的声音--------------------')
            elif  logits.item() == 2:
                print(f'--------------------检测到尖叫的声音--------------------')
            elif logits.item() == 3:
                print(f'--------------------检测到锡塔尔琴的声音--------------------')
            elif logits.item() == 4:
                print(f'--------------------检测到小提琴的声音--------------------')
            elif logits.item() == 5:
                print(f'--------------------检测到唤醒的声音--------------------')
            else:
                print(f'--------------------暂不支持的声音类型--------------------')

        if int(input('是否需要进行声纹分类:1 -- Yes , 2 -- NO\n')):
            directory = 'VoiceprintRecognition/dataset/Voiceprintrecognition/'
            batch_compare(directory,0.8)
            sort_file = 'sort_file'
            num = sort_txt('comparison_results.txt', 'comparison_results_sort1.txt', sort_file)
            if num == 100:
                print('-------------------------SUCCESS:官方给定音频文件全部被分类-------------------------------')
            else:
                print(f'------------------------WARNING:官方给定音频文件未全部被分类,还剩下{abs(100-num - 1)}个WAV未被分类，请调整阈值-------------------')



        if(int(input('是否需要进行声纹识别:1 -- Yes , 2 -- NO\n'))):
            parser = argparse.ArgumentParser(description=__doc__)
            add_arg = functools.partial(add_arguments, argparser=parser)
            add_arg('configs', str, 'VoiceprintRecognition/configs/ecapa_tdnn.yml', '配置文件')
            add_arg('use_gpu', bool, False, '是否使用GPU预测')
            add_arg('audio_db_path', str, 'C:/Users/86151/Desktop/auido_fft_fir/pythonProject/audio_calssification/VoiceprintRecognition/声纹用户/', '音频库的路径')
            add_arg('record_seconds', int, 3, '录音长度')
            add_arg('threshold', float, 0.6, '判断是否为同一个人的阈值')
            add_arg('model_path', str, 'VoiceprintRecognition/models/EcapaTdnn_MelSpectrogram/best_model/', '导出的预测模型文件路径')
            args = parser.parse_args()
            print_arguments(args=args)

            # 获取识别器
            predictor = MVectorPredictor(configs=args.configs,
                                         threshold=args.threshold,
                                         audio_db_path=args.audio_db_path,
                                         model_path=args.model_path,
                                         use_gpu=args.use_gpu)

            record_audio = RecordAudio()

            # save_path = 'C:/Users/86151/Desktop/VoiceprintRecognition-Pytorch-release-0.x/dataset/cn-celeb-test/test/1.wav'
            save_path =file_youwanna
            librosa_data, librosa_samplerate = librosa.load(save_path, sr=None)
            name = predictor.recognition(librosa_data, sample_rate=record_audio.sample_rate)
            print(f'--------------------------------识别出的用户是：{name}--------------------------------')

        if(int(input('您想要与AI进行对话吗？（1----是，0----否）\n'))):
            # 采用科大讯飞的语音识别，然后通过openai接入通义千问API，然后通过pyttsx3将AI回复的消息转化成语音播放
            #如果你想要对其进行特定场景下的聊天，请对模型进行预训练，或者下载已经训练好的模型，这里给出：https://modelscope.cn/models/Shanghai_AI_Laboratory/internlm-7b的预训练模型，
            # 方便您直接与AI交互
            if ~int(input('是否采用预训练后的模型？（1----是，0----否）\n')):
                time1 = datetime.now()
                wsParam = Ws_Param(APPID='53f02355', APISecret='MzJhNzY2MzVmODQyMjQ2MDczOTYyZGRm',
                                   APIKey='0a2c1187f94d5404915bf4fd496f3df1',
                                   AudioFile= file_youwanna)  #
                websocket.enableTrace(False)
                wsUrl = wsParam.create_url()
                ws = websocket.WebSocketApp(wsUrl, on_message=on_message, on_error=on_error, on_close=on_close)
                ws.on_open = on_open
                ws.run_forever(sslopt={"cert_reqs": ssl.CERT_NONE})
                time2 = datetime.now()
                print(f'The time spent on trans wav2txt:{time2 - time1}')
                print(final_sentance)
                return_message = llm_api(final_sentance)  # 该API不能够支持较长的文本
                print(return_message)
                txt2audio(0, 0, str(return_message), 0)
            else:
                cache_dir = "F:/model/Shanghai_AI_Laboratory/internlm-7b/"
                #这里模型下载好后，直接加载即可
                model_dir = snapshot_download("Shanghai_AI_Laboratory/internlm-7b", revision='v1.0.2', cache_dir=cache_dir)
                tokenizer = AutoTokenizer.from_pretrained(model_dir, device_map="cpu",
                                                          trust_remote_code=True, torch_dtype=torch.float32)
                model = AutoModelForCausalLM.from_pretrained(model_dir, device_map="cpu",
                                                             trust_remote_code=True, torch_dtype=torch.float32)

                # 加载生成配置
                model.generation_config = GenerationConfig.from_pretrained(model_dir)

                # 准备消息并生成响应
                time1 = datetime.now()
                wsParam = Ws_Param(APPID='53f02355', APISecret='MzJhNzY2MzVmODQyMjQ2MDczOTYyZGRm',
                                   APIKey='0a2c1187f94d5404915bf4fd496f3df1',
                                   AudioFile=r"audio/id00841-enroll.wav")  #循环改变文件地址，可以实现不同的对话,这里笔记本内存不够 呜呜呜~~~~~~~~~
                websocket.enableTrace(False)
                wsUrl = wsParam.create_url()
                ws = websocket.WebSocketApp(wsUrl, on_message=on_message, on_error=on_error, on_close=on_close)
                ws.on_open = on_open
                ws.run_forever(sslopt={"cert_reqs": ssl.CERT_NONE})
                time2 = datetime.now()
                print(f'The time spent on trans wav2txt:{time2 - time1}')
                print(final_sentance)
                messages = []
                messages.append({"role": "user", "content": final_sentance})
                response = model.chat(tokenizer, messages)
                print(response)
                txt2audio(0, 0, str(response), 0)
                # 添加助手响应并生成下一个响应
                messages.append({'role': 'assistant', 'content': response})
                print(response)
    elif int(input('---------------------------PC-->FPGA(1---yes,0---No)---------------------------\n')):
        if int(input('-------------------你想要传输LMS的音频信号还是特征？ (1----LMS,0----音频特征)-------------------\n')):
            filename = 'C:/Users/86151/Desktop/auido_fft_fir/pythonProject/回声音频/201-angry-liuchanhg.wav'

            for i in range(2):
                UDP_transmitter(0, filename, sr=48000, local_ip="192.168.1.11", local_port=1234)
        else:#资源不够，就带了一块板子
            print('--------------------先采集语音信号，然后提取声纹特征，传入FPGA，然后计算----------------------')
            self_define_file = 'C:/Users/86151/Desktop/auido_fft_fir/pythonProject/test/fpga_output/'
            destination_folder = 'C:/Users/86151/Desktop/auido_fft_fir/pythonProject/fpga_output/'
            print('------------------------------UDP RECEIVE---------------------------------')
            wav_name = str(input('--------------------输入保存的音频文件名字----------------\n'))
            file_youwanna = udp_receive_revised(1, self_define_file, wav_name, 0, num_channels=1, sample_width=2,
                                                frame_rate=48000, max_buffer_once=1024,
                                                local_ip=" ", local_port=3456)
            print(f'保存的文件地址为：{file_youwanna}')
    #         提取特征
            predictor = MVectorPredictor(
                configs='C:/Users/86151/Desktop/auido_fft_fir/pythonProject/audio_calssification/VoiceprintRecognition/configs/ecapa_tdnn.yml',
                model_path='C:/Users/86151/Desktop/auido_fft_fir/pythonProject/audio_calssification/VoiceprintRecognition/models/EcapaTdnn_MelSpectrogram/best_model/')
            audio_data1, sr1 = librosa.load(file_youwanna, sr=None)

                # 计算相似度
            udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            local_addr = ('', 1234)
            udp_socket.bind(local_addr)
            feature1 = predictor.predict(audio_data1)
            print(f'The deature is ：{feature1}')
            print(f'The deature is ：{len(feature1)}')
            udp_trans_data = []
            # 这里修改一下，判断正负
            integer_data = [round(x * (2**12)) for x in feature1]
            for ii in range(len(integer_data)):
                if integer_data[ii] < 0:
                    # 将负数转换为16位补码形式
                    integer_data[ii] = (1 << 16) + integer_data[ii]

                high_byte = (integer_data[ii] >> 8) & 0xFF
                low_byte = integer_data[ii] & 0xFF

                udp_trans_data.append(low_byte)
                udp_trans_data.append(high_byte)

            for i in range(len(udp_trans_data)):
                data = struct.pack('!B', udp_trans_data[i])  # 将整数打包为一个字节，'B'表示一个字节无符号整数
                udp_socket.sendto(data, ("192.168.1.11", 1234))

    else:
        print('--------------------------------No this choice!!!!!------------------------')


    print('------HAVE A GOOD TIME------')


# 目前任务：将新训练的声纹模型复制上来（已复制）
# 将PC到上位机的过程进行测试，声纹识别测试










