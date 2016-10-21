#!/bin/sh 

#str_add="spk01 spk02 spk03 spk04 spk05"
#ls -1 $1|sed 's/.pcm//g' |while read line
#do
#   echo "$line ${str_add}" 
#done

#ls -1 data/pcm|grep "so_like_pcm_8k" | sed 's/\.pcm$//g' | awk '{print $0"\tlike"}' > data/lab/like.lab

#ls -1 data/pcm|grep "so_mengjun_pcm_8k" | sed 's/\.pcm$//g' | awk '{print $0"\tmengjun"}' > data/lab/mengjun.lab

#ls -1 data/pcm|grep "so_tts_rjl_pcm_8k" | sed 's/\.pcm$//g' | awk '{print $0"\ttts_rjl"}' > data/lab/tts_rjl.lab

#ls -1 data/pcm|grep "so_data57_pcm_8k" | sed 's/\.pcm$//g' | awk '{print $0"\tdata57"}' > data/lab/data57.lab
#
#
#ls -1 data/pcm |grep "^x"|sed 's/\.pcm$//g'|awk '{print $0"\txxx"}'  > data/lab/xxx.lab

#num=5
#cat $1|while read line
#do
#    echo $line |awk -v n="${num}" '{print $n}' 
#done


#str_test="111_222_333_444_555_666_777_8888_999_100"
str_test="111_222_333_444"
#str_test="hehehe"
num=`echo ${str_test} | awk 'BEGIN{FS="_"} {print NF}'`
num=$((num+1))
echo "num=${num}"
