#!/bin/sh

#### rename file 
#ii=0
#ls -1 $1 | while read line
#do
#    ii=$((ii+1))
#    echo $ii
#    new_name="ubm_${ii}.pcm"
#    echo $new_name
#    cp $1/${line} $2/${new_name}
#done



ls -1 $1 | while read line
do
    new_name="${line}.pcm"
    echo $new_name
    mv $1/${line} $1/${new_name}
done
