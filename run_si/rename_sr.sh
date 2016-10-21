#!/bin/sh

if(($#<3));then
    echo "使用前需要把目录前缀改成KASR "
    echo "usage:  in_dir out_dir sample_rate "
    echo "例子:  KING_ASR_test KING_ASR_test_pcm_8k  8k "
    echo  "使用 find_file_iter.py 先生成list, 目录 1 中的          wave/SPEAKER001/SEESION0/***.wav " 
    echo  "转化为目录 2 中的    wave_SPEAKER001_SEESION0_0001.pcm"
    echo "同时会生成 in_dir.list 文件，记录wav列表 "
    exit 0
fi

rm -rf $2 && mkdir $2
smp=$3

### 遍历目录下所有文件(包括子目录)  匹配上后缀为 .wav .WAV 的文件, 输出list 
python find_file_iter.py $1 > ${1}.list

cat ${1}.list |while read line 
do
##new_name=`echo $line |sed 's/\//_/g'`
    new_name=`echo $line |sed 's/\//+/g'`
    name=${new_name%.wav}
    new_name=${name}.pcm
    echo $line " ---> " $new_name
    #cp -r $line $2/$new_name
    sox -t wav $line -t raw -r ${smp} $2/$new_name

done
