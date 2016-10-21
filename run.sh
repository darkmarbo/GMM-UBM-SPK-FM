#!/bin/sh +x 

if(($#<2));then
    echo "usage: $0 dir_in  out.txt "
    echo "sample: $0 KASR_test  res_out.txt"
    exit 0
fi

dir_in=$1
out=$2
top_N=30  ## 使用多少人训练 5  10 20 40  
sample=8k
dir_run=run_si

fm_txt=${dir_in}.txt
num_min=2

if [ ! -d ${dir_in} ];then
    echo "目录 ${dir_in} 不存在!"
    exit 0
fi

#### 区分男女的文件不存在时 
if [ ! -f ${fm_txt} ];then
    echo "${fm_txt} 区分男女的配置文件不存在!"

    ###  移动待处理目录到 run_si中
    rm -rf ${dir_run}/${dir_in}
    mv ${dir_in}  ${dir_run} 

    ### 独立运行 
    cd ${dir_run} && ./run.sh ${dir_in} ${out}  && cd -

    ### 拷贝结果出来 
    cp ${dir_run}/${out}.txt ./

    ### 把原始文件移出来 
    mv ${dir_run}/${dir_in} ./

else

    echo "${fm_txt} 区分男女 or 地域!!!"

    ### 类别划分list
    awk '{print $2}' ${fm_txt} |sort|uniq|while read MF
    do
        echo "处理 MF=${MF}"   ### M F A B C 

        ### 提取当前 MF 对应的所有spk 
        MF_list="${MF}_list"
        awk -v mf="${MF}" '{if("X"mf == "X"$2){print $1}}' ${fm_txt} > ${MF_list}

        ### 当前MF的 spk 个数
        num_MF=`wc -l ${MF_list}|awk '{print $1}'`
        echo "处理 num_MF=${num_MF}"    

        ###  判断这个MF的spk个数是否符合  
        if((${num_MF}<${num_min}));then
            echo " ${MF} 个数少于 ${num_min}"
        else

            ### 创建 MF 新目录
            dir_MF=${dir_in}_${MF}
            rm -rf ${dir_MF} && mkdir -p ${dir_MF}

            ### 提取 MF 对应的文件到 单独目录
            cat ${MF_list}|while read line
            do
                mv ${dir_in}/${line}  ${dir_MF}
            done

            ###  移动 dir_MF 目录到run_dir
            rm -rf ${dir_run}/${dir_MF}  && mv ${dir_MF} ${dir_run}

            ### 独立运行 
            cd ${dir_run} && ./run.sh ${dir_MF} ${out}_${MF}  && cd -

            ### 拷贝结果出来 
            mv ${dir_run}/${out}_${MF}.txt ./

            ### 把原始文件移出来 
            mv ${dir_run}/${dir_MF} ./
            mv ${dir_MF}/*  ${dir_in}  && rm -rf ${dir_MF}

        fi

        rm -rf ${MF_list}

    done

fi







