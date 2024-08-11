import argparse
import functools

import librosa

from mvector.predict import MVectorPredictor
from mvector.utils.record import RecordAudio
from mvector.utils.utils import add_arguments, print_arguments

parser = argparse.ArgumentParser(description=__doc__)
add_arg = functools.partial(add_arguments, argparser=parser)
add_arg('configs',          str,    'configs/ecapa_tdnn.yml',   '配置文件')
add_arg('use_gpu',          bool,   False,                       '是否使用GPU预测')
add_arg('audio_db_path',    str,    'sort_file/',                '音频库的路径')
add_arg('record_seconds',   int,    3,                          '录音长度')
add_arg('threshold',        float,  0.7,                        '判断是否为同一个人的阈值')
add_arg('model_path',       str,    'models/EcapaTdnn_MelSpectrogram/best_model/', '导出的预测模型文件路径')
args = parser.parse_args()
print_arguments(args=args)

# 获取识别器
predictor = MVectorPredictor(configs=args.configs,
                             threshold=args.threshold,
                             audio_db_path=args.audio_db_path,
                             model_path=args.model_path,
                             use_gpu=args.use_gpu)

record_audio = RecordAudio()

save_path ='C:/Users/86151/Desktop/VoiceprintRecognition-Pytorch-release-0.x/dataset/cn-celeb-test/test/1.wav'
librosa_data, librosa_samplerate = librosa.load(save_path, sr=None)
name = predictor.recognition(librosa_data, sample_rate=record_audio.sample_rate)
print(name)


