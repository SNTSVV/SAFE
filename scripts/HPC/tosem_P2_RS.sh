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
RUNLIST=

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
        --list) RUNLIST=$2; shift;;
        -s | --subject) SUBJECT=$2; shift;;
        -p | --cpus) N_CPUS=$2; shift;;
        -j | --jobname) JOB_NAME=$2; shift;;
        --dependency) DEPENDENCY=$2; shift;;
        *) ADDITIONAL_OPTIONS="$*"; break; ;;
    esac
    shift;
done

#echo "----------------input ---------------"
#echo "DRY_RUN             =${DRY_RUN}"
#echo "JOB_NAME            =${JOB_NAME}"
#echo "NUM_JOBS            =${NUM_JOBS}"
#echo "MEMORY              =${MEMORY}"
#echo "CODE                =${CODE}"
#echo "SUBJECT             =${SUBJECT}"
#echo "N_CPUS              =${N_CPUS}"
#echo "LOG_OUTPUT          =${LOG_OUTPUT}"
#echo "ADDITIONAL_OPTIONS  =${ADDITIONAL_OPTIONS}"
#echo "START_ID            =${START_ID}"
#echo "DEPENDENCY          =${DEPENDENCY}"
#echo "NICKNAME            =${NICKNAME}"
#echo "RUNLIST             =${RUNLIST}"


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
  JOB_NAME=BestSize${NICKNAME}_${SUBJECT}_${CODE}
fi

if [ "${RUNLIST}" == "" ]; then
  RUNLIST=""
else
  RUNLIST="--list ${RUNLIST}"
  RUN_NUMS=1
  START_ID=1
fi

# phase 2--------------------------------
TASK="~/venv/bin/python3 ./scripts/results/BestSize.py -b results/TOSEM_${CODE}/${SUBJECT}${NICKNAME} -r {1} ${ADDITIONAL_OPTIONS}"
if [ "${DEPENDENCY}" == "" ]; then
   sbatch -J ${JOB_NAME} --ntasks-per-node ${NUM_JOBS}  --mem-per-cpu=${MEMORY}G -o ${LOG_OUTPUT}.log cmds/node_parallel.sh ${DRY_RUN} ${RUNLIST} -s ${START_ID} -l ${LOG_OUTPUT} -r ${RUN_NUMS} ${TASK}
else
  sbatch -J ${JOB_NAME} --ntasks-per-node ${NUM_JOBS}  -d afterok:${DEPENDENCY} --mem-per-cpu=${MEMORY}G -o ${LOG_OUTPUT}_P2.log cmds/node_parallel.sh ${DRY_RUN} ${RUNLIST} -s ${START_ID} -l ${LOG_OUTPUT}_P2 -r ${RUN_NUMS} ${TASK}
fi
# -C skylake option make your job to be assigned nodes from 109-168