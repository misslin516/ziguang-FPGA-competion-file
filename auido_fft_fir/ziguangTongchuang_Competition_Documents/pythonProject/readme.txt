1.audio_classification:包含了音频情绪识别、性别识别和人声分离。其中：
1) Code文件夹里面是音频的性别识别代码；
2) Vocal_music_separate_main文件夹是人声分离代码；
3) Noisereduce_master文件夹是FPGA采集音频UDP传输的噪声消除代码；
4) 其他文件夹大多是情绪识别情绪识别的数据训练模型文件；
5) 如果你想要运行此代码，请直接运行predict_gender_and_emotion.py文件
2.api_io.py是API调用文心一言的相关接口；
3.change_voice为人声调整代码；
以上为主要代码文件说明；
