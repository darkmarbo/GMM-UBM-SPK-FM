#!/bin/sh +x

###  将in_dir内的 每个文件wav or 目录下的所有wav 
###  处理成对应目录  目录里面是每个小wav

if(($#<3));then
    echo "usage:  in_dir out_dir sample_rate "
    echo "例子:  KING_name  KING_name_pcm_8k  8k "
    echo  " dir/spk0001/*.wav > dir_out/spk0001.pcm"
    echo "同时生成 ndx/trainModel.ndx"
    exit 0
fi

in_dir=${1}
out_dir=${2}
smp=$3
size=180k
N_wav=15  ### 少于多少个的  合并后切分 

#ndx_trMdl="ndx/trainModel.ndx"
#rm -rf ${ndx_trMdl}

rm -rf ${out_dir} && mkdir ${out_dir}


ls -1 ${in_dir} | while read spk 
do
    ### spk 不是目录  
    if [ ! -d ${in_dir}/${spk} ];then
        is_wav=${spk:0-4}
        #echo ${is_wav}
        if [ x".wav" = x${is_wav} ];then

            #echo "info: process ${in_dir}/${spk} wav!!"
            name=${spk%.wav}
            wav_16_16=${name}_16k_16bit.wav
            new_name=${name}.pcm

            #### 先提取出 1通道 16k 16bit 
            sox -t wav ${in_dir}/${spk} -t wav -c 1 -r 16000 -b 16  ${wav_16_16}
            sox -t wav ${wav_16_16} -t raw -r ${smp} ${new_name}

            ###  切分语音  
            spk_dir="${out_dir}/${name}"
            rm -rf ${spk_dir} && mkdir -p ${spk_dir}
            split -b ${size} ${new_name} ${spk_dir}/${in_dir}+${name}+spl_
            rm -rf ${wav_16_16}
            rm -rf ${new_name}

            ls -1 ${spk_dir} | while read file
            do
                mv ${spk_dir}/${file}  ${out_dir}/${file}.pcm
            done
            rm -rf ${spk_dir}

        else
            echo "ERROR: ${in_dir}/${spk} not dir|wav!!"
            continue;
        fi
    else
        #### 是目录  
        #### 目录里面的所有语音  
        wav_list=`find  ${in_dir}/${spk}  -iname "*.wav"`
        #echo ${wav_list}

        #### 目录里没有 语音  
        if [ "x${wav_list}" = "x" ];then
            echo "ERROR: dir ${in_dir}/${spk} no wav!!!"
            continue;
        fi

        num_wav=`echo ${wav_list} | awk '{for(ii=1;ii<NF+1;ii++){print $ii}}' |wc -l ` 
        if((${num_wav} > ${N_wav}));then
            echo "dir[wav] > 15"
            #### 语音个数 > N_wav=15 个 
            echo ${wav_list} | awk '{for(ii=1;ii<NF+1;ii++){print $ii}}' | while read wav
            do
                echo ${wav}
                wav_name=$(basename ${wav})
                wav_name=${wav_name%.wav}
                pcm_name=${wav_name}.pcm
                sox -t wav ${wav} -t raw -r ${smp} ${out_dir}/${in_dir}+${spk}+${pcm_name}
                
            done
        else
            echo "dir[wav] < 15"
            #### 语音个数 < N_wav=15 个 
            rm -rf tmp && mkdir -p tmp
            echo ${wav_list} | awk '{for(ii=1;ii<NF+1;ii++){print $ii}}' | while read wav
            do
                echo "n_wav<15: ${wav}"
                wav_name=$(basename ${wav})
                wav_name=${wav_name%.wav}
                pcm_name=${wav_name}.pcm
                #sox -t wav ${wav} -t raw -r ${smp} tmp/${pcm_name}

                wav_16_16=${wav_name}_16k_16bit.wav
                sox -t wav ${wav} -t wav -c 1 -r 16000 -b 16  ${wav_16_16}
                sox -t wav ${wav_16_16} -t raw -r ${smp} tmp/${pcm_name}
                rm -rf ${wav_16_16}
                
            done
            ### 把这 3个pcm 合并后 切分  
            cat tmp/*.pcm > tmp.pcm  && rm -rf tmp/* 
            split -b ${size} tmp.pcm  tmp/${in_dir}+${spk}+spl_
            ls -1 tmp |while read pcm
            do
                mv tmp/${pcm}  ${out_dir}/${pcm}.pcm
            done
            rm -rf tmp/* tmp.pcm
        fi

        
    fi


done



