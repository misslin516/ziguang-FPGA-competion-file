import numpy as np
import soundfile as sf
from scipy.signal import resample


def voice(x, f):
    f = round(f * 1000)
    d = resample(x, int(len(x) * f / 1000))
    W = 400
    Wov = W // 2
    Kmax = W * 2
    Wsim = Wov
    xdecim = 8
    kdecim = 2
    X = d
    F = f / 1000
    Ss = W - Wov
    xpts = len(X)
    ypts = round(xpts / F)
    Y = np.zeros(ypts)
    xfwin = np.arange(1, Wov + 1) / (Wov + 1)
    ovix = np.arange(1 - Wov, 1)
    newix = np.arange(1, W - Wov + 1)
    simix = np.arange(1, Wsim + 1, xdecim) - Wsim
    padX = np.concatenate((np.zeros(Wsim), X, np.zeros(Kmax + W - Wov)))
    Y[:Wsim] = X[:Wsim]
    lastxpos = 0
    km = 0

    for ypos in range(Wsim, ypts - W, Ss):
        xpos = round(F * ypos)
        kmpred = km + (xpos - lastxpos)
        lastxpos = xpos

        if kmpred <= Kmax:
            km = kmpred
        else:
            ysim = Y[ypos + simix]
            rxy = np.zeros(Kmax + 1)
            rxx = np.zeros(Kmax + 1)
            Kmin = 0

            for k in range(Kmin, Kmax + 1, kdecim):
                xsim = padX[Wsim + xpos + k + simix]
                rxx[k] = np.linalg.norm(xsim)
                rxy[k] = np.dot(ysim, xsim)

            Rxy = np.where(rxx != 0, rxy / rxx, 0)
            km = np.argmax(Rxy)

        xabs = xpos + km
        Y[ypos + ovix] = (1 - xfwin) * Y[ypos + ovix] + xfwin * padX[Wsim + xabs + ovix]
        Y[ypos + newix] = padX[Wsim + xabs + newix]

    return Y



if __name__ == '__main__':

    # y, fs = sf.read("C:/Users/86151/Desktop/ziguangTongchuang_Competition_Documents/audio_wav_pakage/ideal_cirums/201-happy-wangzhe.wav")
    # x1 = y
    #
    # frqratio = 1
    # # ratio = 0.52
    # ratio = 0.52
    # Traudio = voice(x1, ratio)
    #
    # # 写入音频文件
    # sf.write("201-happy-wangzhe-PC变声后.wav", Traudio, int(frqratio * fs))
    a = [10,20,10,10,10,11,21,31,41,51,61,71]
    print(resample(a,int(len(a)/4)))
