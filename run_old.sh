#!/bin/sh +x 

if(($#<2));then
    echo "usage: $0 wav_dir  out.txt "
    echo "sample: $0 KASR_test  res_out.txt"
    exit 0
fi

wav_dir=$1
out=$2
top_N=30  ## 使用多少人训练 5  10 20 40  
sample=8k
dir_run=run_si

fm_txt=${wav_dir}.txt
M_list="M.list"
F_list="F.list"
dir_M=${wav_dir}_M
dir_F=${wav_dir}_F
num_min=2

#### 区分男女的文件不存在时 
if [ ! -f ${fm_txt} ];then
    echo "${fm_txt} 区分男女的配置文件不存在!"

    ###  移动待处理目录到 run_si中
    rm -rf ${dir_run}/${wav_dir}
    mv ${wav_dir}  ${dir_run} 

    ### 独立运行 
    cd ${dir_run} && ./run.sh ${wav_dir} ${out}  && cd -

    ### 拷贝结果出来 
    cp ${dir_run}/${out}.txt ./

    ### 把原始文件移出来 
    mv ${dir_run}/${wav_dir} ./

else
    #### 区分男女!!! 
    echo "${fm_txt} 区分男女!!!"
    awk '{if("XM" == "X"$2){print $1}}' ${fm_txt} > ${M_list}
    awk '{if("XF" == "X"$2){print $1}}' ${fm_txt} > ${F_list}

    num_M=`wc -l ${M_list}|awk '{print $1}'`
    num_F=`wc -l ${F_list}|awk '{print $1}'`

    if((${num_M}<${num_min}));then
        echo "男人个数少于 ${num_min}"
    else

        ### 提取 M 对应的文件到 单独目录
        rm -rf ${dir_M} && mkdir -p ${dir_M}
        cat ${M_list}|while read line
        do
            mv ${wav_dir}/${line}  ${dir_M}
        done
        echo "Male_num = ${num_M}"

        ###  移动 dir_M 目录到run_dir
        rm -rf ${dir_run}/${dir_M}  && mv ${dir_M} ${dir_run}

        ### 独立运行 
        cd ${dir_run} && ./run.sh ${dir_M} ${out}_M  && cd -

        ### 拷贝结果出来 
        mv ${dir_run}/${out}_M.txt ./

        ### 把原始文件移出来 
        mv ${dir_run}/${dir_M} ./

    fi
    
    if((${num_F}<${num_min}));then
        echo "女人个数少于 ${num_min}"
    else

        ### 提取 F 对应的文件到 单独目录
        rm -rf ${dir_F} && mkdir -p ${dir_F}
        cat ${F_list}|while read line
        do
            mv ${wav_dir}/${line}  ${dir_F}
        done
        echo "Female_num = ${num_F}"

        ###  移动 dir_F 目录到run_dir
        rm -rf ${dir_run}/${dir_F}  && mv ${dir_F} ${dir_run}

        ### 独立运行 
        cd ${dir_run} && ./run.sh ${dir_F} ${out}_F  && cd -

        ### 拷贝结果出来 
        mv ${dir_run}/${out}_F.txt ./

        ### 把原始文件移出来 
        mv ${dir_run}/${dir_F} ./

    fi
    
fi







