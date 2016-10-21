#!/bin/sh -x 

## so_data57_pcm_8k_003407	data57
## 查看data/pcm目录下所有文件  然后过滤出包含 name 的数据  把他们编排成 spk

if(($#>0));then
    echo "usage: ./$0"
    echo "使用 ndx/trainModel.ndx"
    echo "将data/pcm中的文件做成list"
    exit 0
fi

rm -rf data/lab && mkdir data/lab

spk_num=`wc -l ndx/trainModel.ndx|awk '{print $1}'`
str_add=`cat ndx/trainModel.ndx|awk -v sn="$spk_num" '{ if(NR<sn){printf $1" "} else{printf $1} }'`

echo $str_add |awk '{for(ii=1;ii<NF+1;ii++){print $ii}}' | while read spk
do
    echo "process...: "$spk
    ### ls -1 data/pcm | sed 's/\.pcm$//g' | grep "${spk}" |while read line 
    ls -1 data/pcm | sed 's/\.pcm$//g' | grep "${spk}" | while read line 
    do
        #echo "$line $spk"
        echo -e "$line\t$spk" >> data/lab/${spk}.lab
    done 

done

cat data/lab/* > data/evaluate.lab 



