#!/bin/bash -l

module load lang/Java/1.8.0_162
module load swenv/default-env/latest
module load swenv/default-env/v1.1-20180716-production
module load lang/R/3.4.4-intel-2018a-X11-20180131-bare
java -version
R --version | grep "^R version"

# concatenate parameters
params=""
flag=0
for var in "$@"
do
    let flag++
    if [ $flag -le 2 ]; then
        continue
    fi
    params="$params $var"
done

cmd=$1
path=$(echo "results/$2");
pwd
echo "java -Xms4G -Xmx10G -jar $cmd -b $path $params"
java -jar $cmd -b $path $params

