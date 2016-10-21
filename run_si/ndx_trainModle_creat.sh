#!/bin/sh

##  KASR_137_2_200S0_Speaker0167_Session0_142.pcm

if(($#<4));then
    echo "usage:$0 in_dir_pcm out_dir_pcm_spk  flag_N top_N "
    echo "sample:$0 dir_pcm dir_pcm_spk  5 10 "
    echo "生成 spk训练数据对应的pcm 同时生成ndx/trainModel.ndx "
    echo "根据 in_dir_pcm 目录中每个pcm的结构: KASR_137+2_200S0_Speaker0015+Session0_1.pcm "
    echo " 提取出 Speaker0015 作为一个说话人  并且将前 20 个文件作为gmm训练"
    exit 0
fi

in_dir=$1
out_dir=$2
flag_N=$3  ### KASR_137_2_200S0_Speaker0015_Session0_100.pcm 中的 Speaker0015 为5  
top_N=$4

rm -rf ${out_dir} && mkdir ${out_dir}
file_out="ndx/trainModel.ndx"  ## 输出spk--> file.pcm list
rm -rf $file_out 

spk_now="hehe"
num_cat=0
flag_cat=0
spk_name="haha"

export str_cat
str_cat=""
export last_name
last_name="xxx"

num_line=`ls -1 ${in_dir} | wc -l`
ii=0

ls -1 $in_dir | while read line
do
    ii=$((ii+1))
    #spk_name=`echo $line|awk -F"_" -v n="${flag_N}" '{print $n}'`
    spk_name=`echo $line|awk -F"+" -v n="${flag_N}" '{print $n}'`
    export last_name=${spk_name}
    #echo "reading $spk_name  ..."

    if [ w"${spk_name}" != w"${spk_now}" -a ${flag_cat} -ne 0 ];then
        #echo "start speaker $spk_name  !"
        ## 上一个spk 过滤完毕  开始输出   

        echo "cat $str_cat > ${out_dir}/spk_${spk_now}.pcm"
        cd ${in_dir} && cat $str_cat > ../${out_dir}/spk_${spk_now}.pcm && cd -
        echo "${spk_now} spk_${spk_now}" >> $file_out
        spk_now=${spk_name}
        num_cat=1;

        str_cat="${line}"
    elif [ ${flag_cat} -eq 0 ];then
        ### 第一行 
        num_cat=1
        spk_now=${spk_name}
        str_cat="${line}"
        
    elif [ ${num_cat} -lt ${top_N} ];then
        ### num_cat 还不够 就一直+
        str_cat="${str_cat} ${line}"
        num_cat=$((num_cat+1));
    fi

    flag_cat=1;

    ### 最后一个spk
    if ((${num_line} == ${ii}));then
        echo "cat $str_cat > ${out_dir}/spk_${spk_name}.pcm"
        cd ${in_dir} && cat $str_cat > ../${out_dir}/spk_${spk_name}.pcm && cd -
        echo "${spk_name} spk_${spk_name}" >> $file_out
    fi


done




