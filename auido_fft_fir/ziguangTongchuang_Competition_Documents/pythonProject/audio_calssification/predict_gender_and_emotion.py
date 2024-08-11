import os
import time
import wave
import socket
import librosa
import numpy as np

from api_io import main_get
from audio_calssification import utils
from audio_calssification.models import load
from change_voice import voice
from gender_and_emotion.Speech_Emotion_Recognition_master.predict import predict
from predict import udp_receive,get_filename
from Code import GenderIdentifier
import soundfile as sf
import os
import glob
from audio_calssification.vocal_music_separate_main import start


if __name__ == '__main__':
    test = 0    #用以测试初始值
    max_buffer_once = 4096
    num_wav_file = 1
    wav_name = "fpga_reveive1"
    self_define_file ='C:/Users/86151/Desktop/auido_fft_fir/pythonProject/fpga_output'
    print('------------------------------UDP RECEIVE---------------------------------')
    choice = int(input('是否单独采集噪声： 1 -- YES ,2 -- NO\n'))
    # udp_receive(max_buffer_once, wav_name, self_define_file, num_wav_file, choice,local_ip="169.254.51.120", local_port=1234)


    audio_path = get_filename('C:/Users/86151/Desktop/auido_fft_fir/pythonProject/fpga_output/')
    print(audio_path)
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

    for i in range(0, len(audio_path)):
        config = utils.parse_opt(model_file)
        model = load(config)
        re1 = predict(config, audio_path[i], model)
        re_vec.append(re1)
    for i in range(0, len(re_vec)):
        emotion = []
        if re_vec[i] == 'angry':       emotion = "生气"
        elif re_vec[i] == 'fear':      emotion = "害怕"
        elif re_vec[i] == 'happy':     emotion = "快乐"
        elif re_vec[i] == 'neutral':   emotion = "无动声色"
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
        gender_identifier = GenderIdentifier.GenderIdentifier(self_define_file, self_define_file, file+"females.gmm",file+"males.gmm")
        gender = gender_identifier.process_fpga()
    print('------------------------------API PICTURE---------------------------------')



    for ii in range(len(audio_path)):
        prompt = []
        if  gender[ii] == "male":
            prompt = "画一个" + "很" + Emotion[ii] + "的" + "男孩"
        elif  gender[ii] == "female":
            prompt = "画一个" + "很" + Emotion[ii] + "的" + "女孩"
        file_name = "C:/Users/86151/Desktop/auido_fft_fir"   #存放图片路径
        resolution = "1024*1024"   #分辨率
        style = "写实风格"
        numberofpic = 1     #数量
        API_KEY = "2JVlNgZbBvCvQvAKxDOepXNm"
        SECRET_KEY = "0ZrSzZWEEZeb0vnFz4KKvO5fzGPRsc55"  # 可以换成自己的API
        main_get(API_KEY, SECRET_KEY, file_name, prompt, resolution, style, numberofpic)



    Adjustmentschoice = int(input('是否需要进行人声调整:1 -- Yes , 2 -- NO\n'))
    if Adjustmentschoice:
        print('------------------------------Vocal Adjustments---------------------------------')
        for wav_file in audio_path:
            y, fs = sf.read(wav_file)
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
            audio_path1 = get_filename('C:/Users/86151/Desktop/auido_fft_fir/pythonProject/fpga_output/')
            start.start(audio_path1[0])
            # 在新目录下执行一些操作
            # ...
        finally:
            # 切换回原来的工作目录
            os.chdir(original_dir)
            print("Switched Back to Original Directory:", os.getcwd())

    print('------HAVE A GOOD TIME------')













