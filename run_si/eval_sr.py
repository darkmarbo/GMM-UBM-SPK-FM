# -*- coding: utf-8 -*-

import sys
import os
import string
import re

if len(sys.argv) < 4:
    print ("usage: %s res.txt lab.lab out.eval N_spk "%(sys.argv[0]));
    print ("usage: %s res/target-seg_gmm.res data/evaluate.lab res.eval 5 "%(sys.argv[0]));
    sys.exit(0);

fp_res = open(sys.argv[1]);
fp_lab = open(sys.argv[2]);
fp_out = open(sys.argv[3],"w");
fp_log = open("log.txt","w");
N_spk = int(sys.argv[4]);

fp_out.write("wav_name\tres_spk_1\tres_spk_2\tres_spk_3\tres_score\tlab_spk\n");

map_lab = {};  ### [wav,spk]
num_all_wav  = 0;
num_all_wav_ok  = 0;
num_all_wav_err  = 0;

##  so_data57_pcm_8k_003416	data57
### 去读 lab 文件  将[wav,spk]添加到map_lab中 
for line in fp_lab:
    line  = line[:-1]
    list_line = line.split("\t");
    if len(list_line)<2:
        print("ERROR:resule format err!");
        continue;

    spk = list_line[1]
    wav = list_line[0]
    map_lab[wav] = spk;
    #print("test: %s\t%s"%(wav,spk));


#### 读取 res 文件  统计出正确率  输出错误的wav 
###  M like 1 so_data57_pcm_8k_003405 0.302612

num_spk = 0;    ## 记录当前是第几个spk模型识别的结果 
spk_max = ["xxx", 'xxx', 'xxx'];   ## 记录目前为止 识别最好的那个spk是啥
score_max = [0,0,0,0];  ## 记录目前为止 识别最好的那个spk得分

for line in fp_res:
    list_line = line.split(" ");
    if len(list_line)<5:
        print("ERROR:resule format err!");
        break;

    spk = list_line[1]
    wav = list_line[3]
    score = float(list_line[4]);
    ### score 小于 0 时  记录为 xxx 
    if score < 0.0:
        spk = "xxx";
    #print("test: %s\t%s\t%s"%(wav,spk,score));

    if score > float(score_max[0]):
        score_max[2] = score_max[1];
        score_max[1] = score_max[0];
        score_max[0] = score;

        spk_max[2] = spk_max[1];
        spk_max[1] = spk_max[0];
        spk_max[0] = spk;

    elif score > score_max[1]:
        score_max[2] = score_max[1];
        score_max[1] = score;

        spk_max[2] = spk_max[1];
        spk_max[1] = spk;

    elif score > score_max[2]:
        score_max[2] = score;

        spk_max[2] = spk;

    num_spk += 1;
    ### 最后一个已经计算完毕了 
    if map_lab.has_key(wav):
        spk_ok = map_lab[wav]
    else:
        spk_ok = "xxx";

    ### 统计完了 spk_max[123]和score_max[123] 可以得到这个语音的识别结果了 
    if num_spk == N_spk:
        num_all_wav += 1;
        ### 正确
        if spk_ok == spk_max[0]:
            num_all_wav_ok += 1;
        else:
            num_all_wav_err += 1;
        fp_out.write("%s\t%s\t%s\t%s\t%s\n"%(wav, spk_max[0], spk_max[1], spk_max[2], spk_ok));
        
        num_spk = 0;
        spk_max = ["xxx", 'xxx', 'xxx'];   ## 记录目前为止 识别最好的那个spk是啥
        score_max = [0,0,0,0];

fp_log.write("num_all_wav:%d\n"%(num_all_wav));
fp_log.write("num_all_wav_ok:%d\n"%(num_all_wav_ok));
fp_log.write("num_all_wav_err:%d\n"%(num_all_wav_err));

fp_out.write("wav_name\tres_spk_1\tres_spk_2\tres_spk_3\tres_score\tlab_spk\n");


fp_res.close();
fp_lab.close();
fp_out.close();
fp_log.close();

sys.exit(0)

