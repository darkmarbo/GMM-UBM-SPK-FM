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
wav_dir_pcm=${wav_dir}_pcm
wav_dir_pcm_spk=${wav_dir_pcm}_spk
## 正确答案
lab="data/evaluate.lab" 
mkdir -p tmp 

#### 例如: KASR_137_2_200S0_100 得到 flag_N=6 
#flag_N=`echo ${wav_dir} | awk 'BEGIN{FS="_"} {print NF}'`
flag_N=`echo ${wav_dir} | awk 'BEGIN{FS="+"} {print NF}'`
flag_N=$((flag_N+1))


##### 遍历 in_dir 统计出.wav .WAV 的list 然后转换成 sample=8k 的pcm文件 
rm -rf ${wav_dir_pcm} && mkdir  ${wav_dir_pcm}
rm -rf ${wav_dir_pcm_spk} && mkdir  ${wav_dir_pcm_spk}
#./rename_sr.sh ${wav_dir} ${wav_dir_pcm} ${sample} 
./rename_large.sh ${wav_dir} ${wav_dir_pcm} ${sample} 


#####    每个说话人选取  top flag_N 个wav cat到一起做训练数据  
#####    同时 生成 ndx/trainModel.ndx   ## 如: spk_mj so_mj_201605

./ndx_trainModle_creat.sh ${wav_dir_pcm} ${wav_dir_pcm_spk} ${flag_N} ${top_N}


rm -rf data/pcm.bak   &&  mv data/pcm data/pcm.bak 
mv  ${wav_dir_pcm}       data/pcm 
cp -rf data/pcm_ubm_1000/*     data/pcm/
mv  ${wav_dir_pcm_spk}/*.pcm   data/pcm/ && rm -rf ${wav_dir_pcm_spk}

################################## 使用说明 #####################################


################################# 制作 evaluate.lab  #########################################
####  data/lab/
##        ## 标准答案的list 需要与spk对应上 
./lab_creat.sh 

##### 使用 ndx/trainModel.ndx
##### 提取出 spk  :str_add="data57 like mengjun tts_jxy tts_rjl"

spk_num=`wc -l ndx/trainModel.ndx|awk '{print $1}'`
str_add=`cat ndx/trainModel.ndx|awk -v sn="$spk_num" '{ if(NR<sn){printf $1" "} else{printf $1} }'`


########################  1---提取初步特征  ###########################################
######       in:
######           准备好pcm文件放到 data/pcm/ 中  
######       out:
######           data/prm/*.tmp.prm

####  data/data.lst
#### 包含所有需要提取特征的声音 放在data/pcm中的所有文件  
ls -1 data/pcm/|sed 's/\.pcm$//g' > data/data.lst
rm -rf data/prm/ && mkdir data/prm  
./01_RUN_feature_extraction.sh


#############################   2--a--提取 norm.prm 特征和 lbl文件 #########################
######   in:
######       # 上一步生成 data/prm/*.tmp.prm
######   out:
######       # data/prm/*.enr.tmp.prm
######       # data/lbl/*.lbl
######       # data/prm/*.norm.prm

rm -rf data/lbl && mkdir -p data/lbl
./02a_RUN_spro_front-end.sh


###########################  3--1--UBM training  #########################################
#######         in:
####### 检查固定的 UBM.lst
#######           out:
####### gmm/worldinit.gmm
####### gmm/world.gmm

rm -rf gmm/* 
####  lst/UBM.lst
#### ( ubm_*.pcm 为 训练背景模型的数据 ,使用alize的100x声音)
#### ( spk_*.pcm 为 M 个说话人数据 )
ls -1 data/pcm/|grep "^ubm"|sed 's/\.pcm$//g' > lst/UBM.lst  
echo "Train Universal Background Model by EM algorithm"
bin/TrainWorld --config cfg/TrainWorld.cfg &> log/TrainWorld.log
echo "		done, see log/TrainWorld.log for details"


###################################################################################
########              3--2--Speaker GMM model adaptation
########   in:
###            ## 修改 ndx/trainModel.ndx 记录的是 N个spk和人名的对应关系
########   out:
###            ## gmm/下的 N个说话人对应的模型

echo "Train Speaker dependent GMMs"
bin/TrainTarget --config cfg/TrainTarget.cfg &> log/TrainTarget.cfg
echo "		done, see log/TrainTarget.cfg for details"

####################################################################################
##
##
##
##################################################################################

### 生成 ndx/computetest_gmm_target-seg.ndx  测试哪些语音 使用哪些模型 

rm -rf ndx/computetest_gmm_target-seg.ndx
#ls -1 data/pcm |sed 's/\.pcm$//g' |grep "^KASR" | while read line
ls -1 data/pcm |sed 's/\.pcm$//g' |grep -v "^spk" |grep -v "^ubm" | while read line
do
   echo "$line ${str_add}" >> ndx/computetest_gmm_target-seg.ndx 

done

#################################################################################
####                 3--3--Speaker model comparison
######   in:
######   out:
            ## 生成一个测试结果 res/target-seg_gmm.res

echo "Compute Likelihood"
bin/ComputeTest --config cfg/ComputeTest_GMM.cfg &> log/ComputeTest.cfg
echo "		done, see log/ComputeTest.cfg"


#######################   final-evaluate-result  ####################################

### 统计出初步的top3识别结果 *.log文件  
python eval_sr.py res/target-seg_gmm.res ${lab} tmp/${out} $spk_num

## 挑选出可疑的spk对儿
python eval_sr_judge.py tmp/${out} tmp/${out}.tmp
sort -n -r -k2 tmp/${out}.tmp | grep -v "+xxx" | grep -v "^xxx+" > ${out}.txt

## 计算总体识别准确率 
#python eval_wer_sr.py  res/target-seg_gmm.res  ${lab}  ${out}.wer ${spk_num}





