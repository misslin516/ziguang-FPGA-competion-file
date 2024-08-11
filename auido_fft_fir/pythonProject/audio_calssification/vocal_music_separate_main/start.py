import os
from gevent.pywsgi import WSGIHandler
# from vocal import cfg
from audio_calssification.vocal_music_separate_main.vocal import cfg
import subprocess
from spleeter.separator import Separator
class CustomRequestHandler(WSGIHandler):
    def log_request(self):
        pass
# wav_name = '人声分离测试音频样本.wav'
# print(wav_name)
# model = "2stems"
# wav_file = os.path.join(cfg.TMP_DIR, wav_name)
# noextname = wav_name[:-4]
# try:
#     p = subprocess.run(
#         ['ffprobe', '-v', 'error', '-show_entries', "format=duration", '-of', "default=noprint_wrappers=1:nokey=1",
#          wav_file], capture_output=True)
#     if p.returncode == 0:
#         sec = float(p.stdout)
# except:
#     sec = 1800
# print(f'{sec=}')
# separator = Separator(f'spleeter:{model}', multiprocess=False)
# dirname = os.path.join(cfg.FILES_DIR, noextname)
# try:
#     separator.separate_to_file(wav_file, destination=dirname, filename_format="{instrument}.{codec}", duration=sec)
# except Exception as e:
# # return jsonify({"code": 1, "msg": str(e)})
#     status = {
#         "accompaniment": "伴奏",
#         "bass": "低音",
#         "drums": "鼓",
#         "piano": "琴",
#         "vocals": "人声",
#         "other": "其他"
#     }
# data = []


def start(wav_name):
    print(wav_name)
    model = "2stems"
    wav_file = os.path.join(cfg.TMP_DIR, wav_name)
    noextname = wav_name[:-4]
    try:
        p = subprocess.run(
            ['ffprobe', '-v', 'error', '-show_entries', "format=duration", '-of', "default=noprint_wrappers=1:nokey=1",
             wav_file], capture_output=True)
        if p.returncode == 0:
            sec = float(p.stdout)
    except:
        sec = 1800
    print(f'{sec=}')
    separator = Separator(f'spleeter:{model}', multiprocess=False)
    dirname = os.path.join(cfg.FILES_DIR, noextname)
    try:
        separator.separate_to_file(wav_file, destination=dirname, filename_format="{instrument}.{codec}", duration=sec)
    except Exception as e:
        # return jsonify({"code": 1, "msg": str(e)})
        status = {
            "accompaniment": "伴奏",
            "bass": "低音",
            "drums": "鼓",
            "piano": "琴",
            "vocals": "人声",
            "other": "其他"
        }
    data = []
if __name__ == '__main__':
    start('C:/Users/86151/Desktop/auido_fft_fir/pythonProject/fpga_output/人声分离FPGA采集.wav')
