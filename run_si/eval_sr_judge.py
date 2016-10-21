# -*- coding: utf-8 -*-

import sys
import os
import string
import re

if len(sys.argv) < 3:
    print ("usage: %s in.file out.file "%(sys.argv[0]));
    print ("usage: %s res.eval out.log "%(sys.argv[0]));
    sys.exit(0);

out_log = sys.argv[2] + ".log"

fp_res = open(sys.argv[1]);
fp_out_err = open(sys.argv[2],"w");
fp_log = open(out_log,"w");

map_final = {};  ### [存储spk1和2之间的相似度 ]
map_lab = {};  ### [spk0_spk1:num]
num_all_wav_ok  = 0;
num_all_wav_err  = 0;


#### 读取 res 文件  组成  spk_1:spk_2 对 
## KASR_137_2_200S0_Speaker0015_Session0_101	Speaker0015	Speaker0106	Speaker0072	Speaker0015
#### spkeaker spk1_num spk2_num spk_3_num ok?
num_spk = 0;    ## 记录当前是第几个spk模型识别的结果 

spk_max = ["xxx", 'xxx', 'xxx'];   ## 记录 spk1 spk2 spk3 名字 
num_max = [0,0,0];  ## spk1 spk2 spk3 对应的数目/百分比 
num_all  = 0;  ## 记录每个speaker 的的总测试语音数 num=150
spk_f = "xxx";  ## 上一个speaker 

for line in fp_res:

    line = line[:-1]
    list_line = line.split("\t");
    if len(list_line)<5:
        print("ERROR:resule format err: %s"%(line));
        break;

    spk0 = list_line[4]
    
    ### 当前这个spk 与上一行不相等了 
    ### 开始统计上一个spk0 对应的相似spk1 spk2 spk3  
    if spk0 != spk_f:
        ## 前面已经计算完毕 选取top3的spk 输出  
        for key in map_lab.keys():
            if map_lab[key] > num_max[0]:
                num_max[2] = num_max[1];
                spk_max[2] = spk_max[1];
                num_max[1] = num_max[0];
                spk_max[1] = spk_max[0];
                num_max[0] = map_lab[key];
                spk_max[0] = key;
            elif map_lab[key] > num_max[1]:
                num_max[2] = num_max[1];
                spk_max[2] = spk_max[1];
                num_max[1] = map_lab[key];
                spk_max[1] = key;
            elif map_lab[key] > num_max[2]:
                num_max[2] = map_lab[key];
                spk_max[2] = key;

        #print num_max;
        ### 去除掉第1行 和 最后一行  
        num_max_all = num_max[0] + num_max[1] + num_max[2];
        if num_max_all > 3:
            rate2 = float(num_max[1]) / float(num_max[0]);
            rate3 = float(num_max[2]) / float(num_max[0]);

            fp_log.write("%s\t%.4f\n"%(spk_max[1], rate2));
            fp_log.write("%s\t%.4f\n"%(spk_max[2], rate3));




            ### 第一候选不是自己 +5  第二候选大于0.4 +4 
            ### 第二候选大于0.33 +3  第二候选大于0.25 +2 
            if spk_max[0].split("+")[0] != spk_max[0].split("+")[1]:
                new_pair = spk_max[0].split("+")[1] + "+" + spk_max[0].split("+")[0];

                if map_final.has_key(new_pair):
                    map_final[new_pair] = map_final[new_pair]+5;
                else:
                    map_final[spk_max[0]] = 5;
            else:
                ### 第二候选占第一候选的比例  0.8 0.7  0.6 0.5
                new_pair = spk_max[1].split("+")[1] + "+" + spk_max[1].split("+")[0];
                if rate2 > 0.8:
                    if map_final.has_key(new_pair):
                        map_final[new_pair] = map_final[new_pair] + 4;
                    else:
                        map_final[spk_max[1]] = 5;
                elif rate2 > 0.7:
                    if map_final.has_key(new_pair):
                        map_final[new_pair] =  map_final[new_pair] + 3;
                    else:
                        map_final[spk_max[1]] = 4;
                elif rate2 > 0.6:
                    if map_final.has_key(new_pair):
                        map_final[new_pair] =  map_final[new_pair] + 2;
                    else:
                        map_final[spk_max[1]] = 3;
                elif rate2 > 0.5:
                    if map_final.has_key(new_pair):
                        map_final[new_pair] =  map_final[new_pair] + 1;
                    else:
                        map_final[spk_max[1]] = 2;
                elif rate2 > 0.4:
                    if map_final.has_key(new_pair):
                        map_final[new_pair] =  map_final[new_pair] + 1;
                    else:
                        map_final[spk_max[1]] = 1;

                ### 第三候选 占 第一候选比例 
                new_pair = spk_max[2].split("+")[1] + "+" + spk_max[2].split("+")[0];
                if rate3 > 0.8:
                    if map_final.has_key(new_pair):
                        map_final[new_pair] = map_final[new_pair] + 4;
                    else:
                        map_final[spk_max[2]] = 5;
                elif rate3 > 0.7:
                    if map_final.has_key(new_pair):
                        map_final[new_pair] =  map_final[new_pair] + 3;
                    else:
                        map_final[spk_max[2]] = 4;
                elif rate3 > 0.6:
                    if map_final.has_key(new_pair):
                        map_final[new_pair] =  map_final[new_pair] + 2;
                    else:
                        map_final[spk_max[2]] = 3;
                elif rate3 > 0.5:
                    if map_final.has_key(new_pair):
                        map_final[new_pair] =  map_final[new_pair] + 1;
                    else:
                        map_final[spk_max[2]] = 2;
                elif rate3 > 0.4:
                    if map_final.has_key(new_pair):
                        map_final[new_pair] =  map_final[new_pair] + 1;
                    else:
                        map_final[spk_max[2]] = 1;



        #fp_log.write("%s\t%d\n"%(spk_max[0], num_max[0]) );
        #fp_log.write("%s\t%d\n"%(spk_max[1], num_max[1]) );
        #fp_log.write("%s\t%d\n"%(spk_max[2], num_max[2]) );

        #print line;
        map_lab={}
        spk_f = spk0;
        spk_max = ["xxx", 'xxx', 'xxx'];   
        num_max = [0,0,0,0];  
        num_all  = 0;  

    ## 计算这一行对应的 spk 123 数
    for ii in range(1,4):

        spk1 = list_line[ii]
        spk01 = spk0 + "+" + spk1;

        if map_lab.has_key(spk01):
            map_lab[spk01] += 1;
        else:
            map_lab[spk01] = 1;


### map_final 中 spk1--spk2   spk2---spk1 合并 
##for key in map_final.keys():

### 最终error输出
for key in map_final.keys():
    #print ("%s\t%s"%(key,map_final[key]));
    fp_out_err.write("%s\t%s\n"%(key, map_final[key]));

fp_res.close();
fp_log.close();
fp_out_err.close();
