# -*- coding: utf-8 -*-

import sys
import os
import string
import re

if len(sys.argv) < 4:
    print ("usage: %s res.txt  out.res score_thre"%(sys.argv[0]));
    print ("usage: %s res/target-seg_gmm.res out.res 4(0.8 * 5) "%(sys.argv[0]));
    print ("大于等于 0.8(4) 的pair才被输出 ");
    sys.exit(0);

out_file = sys.argv[2];
out_file_sort = out_file + ".sort";
out_file_log = out_file + ".alllog";
out_file_log_sort = out_file_log + ".sort";

fp_res = open(sys.argv[1]);
score_th = float(sys.argv[3]);

fp_out = open(out_file,"w");
fp_out_log = open(out_file_log,"w");
#th_sub = 0.8;

map_pair = {};  ### [spk1,spk2]
map_pair_count = {};  ### 记录 [spk1,spk2] 统计了多少对语音得分 count
num_all_wav  = 0;
num_all_wav_ok  = 0;
num_all_wav_err  = 0;


#### 读取 res 文件  统计出正确率  输出错误的wav 
###  M 2016_06_26_09_24_42_376 0 en-ca+2016_06_24_19_29_05_647+spl_aa -0.0585137

for line in fp_res:
    list_line = line.split(" ");
    if len(list_line)<5:
        print("ERROR:resule format err!");
        continue;

    spk_res = list_line[1]
    wav_spl = list_line[3].split("+");
    if len(wav_spl) < 3:
        print("not :en-ca+2016_06_24_19_29_05_647+spl_aa format!");
        continue;
    spk_ok = wav_spl[1];

    score = float(list_line[4]);


    ## spk_ok:spk_res pari 
    spk_pair = spk_ok + "+" + spk_res;
    spk_pair_rev = spk_res + "+" + spk_ok;

    if spk_ok == spk_res:
        continue;

    ### 先把 count加上 
    if map_pair_count.has_key(spk_pair):
        map_pair_count[spk_pair] += 1;
    else:
        map_pair_count[spk_pair] = 1;
    if map_pair_count.has_key(spk_pair_rev):
        map_pair_count[spk_pair_rev] += 1;
    else:
        map_pair_count[spk_pair_rev] = 1;

    #if score < th_sub:
    #    continue;

    if map_pair.has_key(spk_pair_rev):
        map_pair[spk_pair_rev] += score;
    elif map_pair.has_key(spk_pair):
        map_pair[spk_pair] += score;
    else:
        map_pair[spk_pair] = score;

    

for key in map_pair.keys():

    if not map_pair_count.has_key(key):
        print ("map_pair[key] !- map_pair_count[key]");
        continue;

    #print("count[%s]=%d\t%.2f"%(key, map_pair_count[key], map_pair[key]));
    map_pair[key] = float(map_pair[key])/float(map_pair_count[key]);

    ### 处理成2-10
    
    value_int = int(map_pair[key] * 5.0)
    if value_int > 10:
        value_int = 10;


    fp_out_log.write("%s\t%.2f\n"%(key, map_pair[key]));

    if value_int < score_th:
        continue;

    fp_out.write("%s\t%d\n"%(key, value_int));


fp_res.close();
fp_out.close();
fp_out_log.close();

cmd_sort = "sort -n -r -k2 %s &> %s"%(out_file, out_file_sort);
os.system(cmd_sort);
cmd_sort_log = "sort -n -r -k2 %s &> %s"%(out_file_log, out_file_log_sort);
os.system(cmd_sort);

sys.exit(0)



