#!/bin/bash -l

################################################################
# Show usages
if [ $# -le 2 ]; then
    printf "\n\n[Usages]\n%s <Jar FileName> <BasePath> <TaskList> [jar parameters]\n\n" $0
    exit 0
fi

################################################################
# Analysis parameters
cmd=$1
basePath=$(echo "results/$2");

if [ "$3" = "all" ]; then
    list="1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34"
else
    list=$3
fi

# concatenate parameters
params=""
flag=0
for var in "$@"
do
    let flag++
    if [ $flag -le 3 ]; then
        continue
    fi
    params="$params $var"
done


################################################################
# set configuration
module load lang/Java/1.8.0_162
java -version

################################################################
# execute commands
IFS=',' read -ra TaskIDs <<< "$list"
for tid in "${TaskIDs[@]}"; do
    resultPath="$(printf "%s/Task%02d\n" $basePath $tid)"
    echo "java -jar $cmd -b $resultPath -t $tid $params"
    java -jar $cmd -b $resultPath -t $tid $params &
done

################################################################
# wait all executions done
wait
echo "all processes complete"


