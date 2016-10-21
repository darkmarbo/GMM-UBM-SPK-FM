# -*- coding: utf-8 -*-

import sys
import os

if(len(sys.argv)<4):
    print ("usage: %s in_file out_file thr"%(sys.argv[0]));
    print ("usage: %s   *.sort(eval_1vs1.py的输出)  out_file  大于等于 htr = 6 or 7 的才统计成pair"%(sys.argv[0]));
    sys.exit(0);

tab_chr_1 = "\t"; 
tab_chr_2 = "+"; 

## 存储 (abd)(ce)... 
list_spk = [];
## 存储 (4 5)... 
list_score = [];

fp_in = open(sys.argv[1]);
fp_out = open(sys.argv[2],"w");
thr = float(sys.argv[3]);

### 在list_spk中查找 spk 
def find_spk(list_spk, spk):
    len_list = len(list_spk);
    for ii in range(0,len_list):
        if spk in list_spk[ii]:
                return ii;

    return -1;


for line in fp_in:

    line=line[:-1]
    if(len(line) == 0):
        continue;

    vec_line = line.split(tab_chr_1);
    if len(vec_line) < 2:
        print("line_in format err!");
        continue;

    ## spk1+spk2
    spk_pair = vec_line[0];
    score = float(vec_line[1]);  ###  5555
    if score < thr:
        continue;

    vec_spk_pair = spk_pair.split(tab_chr_2);
    spk1 = vec_spk_pair[0]
    spk2 = vec_spk_pair[1]
    ##print ("test spk1=%s\tspk2=%s"%(spk1,spk2));
    
    idx_1 = find_spk(list_spk, spk1);
    idx_2 = find_spk(list_spk, spk2);

    if idx_1 > -1 and idx_1 == idx_2:
        ### 两个本来就存在于同一个set中  (a b spk1 spk2)
        list_score[idx_1] += score;
    elif idx_1 > -1 and idx_2 > -1 :
        ### 都存在 但非同一个set中 
        ### 需要将这两个set合并 (abcd)(ef)  ce 并且把score加进去:
        ### 一定注意：先添加 后删除 
        list_spk[idx_1] = (list_spk[idx_1] | list_spk[idx_2]); 
        list_score[idx_1] += list_score[idx_2] + score;

        list_spk.pop(idx_2) ## delete spk2
        list_score.pop(idx_2); ## delete spk2
        

    elif idx_1 > -1:
        ## spk1 存在 spk2不存在
        ## 将spk2 加入到set1中
        set_2 = set();
        set_2.add(spk2);
        list_spk[idx_1] = list_spk[idx_1] | set_2;
        list_score[idx_1] += score;
    elif idx_2 > -1:
        set_1 = set();
        set_1.add(spk1);
        list_spk[idx_2] = list_spk[idx_2] | set_1;
        list_score[idx_2] += score;
    else:
        ## 都不存在 加入到一个set中
        list_spk.append(set([spk1,spk2]));
        list_score.append(score);

    #print ("##########################################\n");
    #print ("%s"%(line));
    #print(list_spk);


#print "list_spk_len = %d"%(len(list_spk))
if len(list_spk) != len(list_score):
    print("len_spk != len_score");
    sys.exit(0);

for ii in range(0,len(list_spk)):
    set_tmp = list_spk[ii] ## (abef)

    #print set_tmp
    #print list_score[ii] 

    jj = 0;
    for spk in set_tmp:
        jj += 1;
        if jj != 1:
            fp_out.write("+");
        fp_out.write("%s"%(spk));
    
    fp_out.write("\t%.2f\n"%(list_score[ii]));

fp_in.close();
fp_out.close();


