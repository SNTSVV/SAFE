#!/bin/bash -l
source ./scripts/HPC/library.sh

##############################################################################
##############################################################################
##############################################################################
# Use the UL HPC modules
if [ -f  /etc/profile ]; then
    .  /etc/profile
fi

########################################
# parameter parsing
########################################
# concatenate parameters
DRY_RUN=
JOB_NAME=""
NUM_JOBS=1
MEMORY=4
CODE=""
SUBJECT=""
N_CPUS=1
LOG_OUTPUT=""
ADDITIONAL_OPTIONS=""
START_ID=1
DEPENDENCY=
NICKNAME=

# Parse the command-line argument
while [ $# -ge 1 ]; do
    case $1 in
        -h | --help) usage; exit 0;;
        -d | --noop | --dry-run) DRY_RUN="-d";;
        -N | --jobs) NUM_JOBS=$2; shift;;
        -m | --mem) MEMORY=$2; shift;;
        -r | --runs) RUN_NUMS=$2; shift;;
        --start) START_ID=$2; shift;;
        -l | --log) LOG_OUTPUT=$2; shift;;
        -c | --code) CODE=$2; shift;;
        --nick) NICKNAME=$2; shift;;
        -s | --subject) SUBJECT=$2; shift;;
        -p | --cpus) N_CPUS=$2; shift;;
        -j | --jobname) JOB_NAME=$2; shift;;
        --dependency) DEPENDENCY=$2; shift;;
        *) ADDITIONAL_OPTIONS="$*"; break; ;;
    esac
    shift;
done
#
#echo "----------------input ---------------"
#echo ${DRY_RUN}
#echo ${JOB_NAME}
#echo ${NUM_JOBS}
#echo ${MEMORY}
#echo ${CODE}
#echo ${SUBJECT}
#echo ${N_CPUS}
#echo ${LOG_OUTPUT}
#echo ${ADDITIONAL_OPTIONS}
#echo ${START_ID}
#echo ${DEPENDENCY}
#echo ${NICKNAME}


#######################
# Create logs directory
if [[ "${LOG_OUTPUT}" == "" ]]; then
  parentPath=logs/TOSEM_${CODE}/${SUBJECT}/
  mkdir -p ${parentPath}
  LOG_OUTPUT=${parentPath}/%j-%x
else
  idx=$(rindex ${LOG_OUTPUT} "/")
  parentPath=${LOG_OUTPUT:0:$idx}
  mkdir -p ${parentPath}
fi

##
if [[ "${JOB_NAME}" == "" ]]; then
  JOB_NAME=RT_${SUBJECT}_${CODE}${NICKNAME}
fi

# phase 2--------------------------------
TASK="java -Xms4G -Xmx${MEMORY}G -jar artifacts/RoundTrip.jar -b results/TOSEM_${CODE}/${SUBJECT}${NICKNAME}/Run{1} --nTest 1000 --cpus ${N_CPUS} ${ADDITIONAL_OPTIONS}"
if [ "${DEPENDENCY}" == "" ]; then
  sbatch -J ${JOB_NAME} --ntasks-per-node ${NUM_JOBS}  --mem-per-cpu=${MEMORY}G -o ${LOG_OUTPUT}.log cmds/node_parallel.sh ${DRY_RUN} -s ${START_ID} -l ${LOG_OUTPUT} -r ${RUN_NUMS} ${TASK}
else
  sbatch -J ${JOB_NAME} --ntasks-per-node ${NUM_JOBS}  -d afterok:${DEPENDENCY} --mem-per-cpu=${MEMORY}G -o ${LOG_OUTPUT}_P2.log cmds/node_parallel.sh ${DRY_RUN} -s ${START_ID} -l ${LOG_OUTPUT}_P2 -r ${RUN_NUMS} ${TASK}
fi
# -C skylake option make your job to be assigned nodes from 109-168