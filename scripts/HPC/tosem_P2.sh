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
NUM_NODES=1
MEMORY=4
CODE=""
SUBJECT=""
N_CPUS=1
LOG_OUTPUT=""
ADDITIONAL_OPTIONS=""
START_ID=1
DEPENDENCY=

# Parse the command-line argument
while [ $# -ge 1 ]; do
    case $1 in
        -h | --help) usage; exit 0;;
        -d | --noop | --dry-run) DRY_RUN="-d";;
        -N | --node) NUM_NODES=$2; shift;;
        -m | --mem) MEMORY=$2; shift;;
        -r | --runs) RUN_NUMS=$2; shift;;
        --start) START_ID=$2; shift;;
        -l | --log) LOG_OUTPUT=$2; shift;;
        -c | --code) CODE=$2; shift;;
        -s | --subject) SUBJECT=$2; shift;;
        -p | --cpus) N_CPUS=$2; shift;;
        -j | --jobname) JOB_NAME=$2; shift;;
        --dependency) DEPENDENCY=$2; shift;;
        *) ADDITIONAL_OPTIONS="$*"; break; ;;
    esac
    shift;
done

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
  JOB_NAME=P2_${SUBJECT}_${CODE}
fi

# phase 2--------------------------------
TASK="java -Xms4G -Xmx${MEMORY}G -jar artifacts/SecondPhase.jar -b results/TOSEM_${CODE}/${SUBJECT}/Run{1} --nTest 1000 --cpus ${N_CPUS} ${ADDITIONAL_OPTIONS}"
if [ ${DEPENDENCY} == "" ]; then
  sbatch -C skylake -J ${JOB_NAME} -N ${NUM_NODES} --mem-per-cpu=${MEMORY}G -o ${LOG_OUTPUT}_P2.log cmds/node_parallel.sh ${DRY_RUN} -s ${START_ID} -l ${LOG_OUTPUT}_P2 -r ${RUN_NUMS} ${TASK}
else
  sbatch -C skylake -J ${JOB_NAME} -N ${NUM_NODES} -d afterok:${DEPENDENCY} --mem-per-cpu=${MEMORY}G -o ${LOG_OUTPUT}_P2.log cmds/node_parallel.sh ${DRY_RUN} -s ${START_ID} -l ${LOG_OUTPUT}_P2 -r ${RUN_NUMS} ${TASK}
fi
# -C skylake option can be assigned nodes from 109-168 to the job # requires to the second phase