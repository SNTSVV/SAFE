#!/bin/bash -l

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
TARGET=""
LOG_OUTPUT=""
ADDITIONAL_OPTIONS=""
START_ID=1
RUNLIST=
NICK=
LOCAL=0
TIME=

# Parse the command-line argument
while [ $# -ge 1 ]; do
    case $1 in
        -h | --help) usage; exit 0;;
        -d | --noop | --dry-run) DRY_RUN="-d";;
        -N | --jobs) NUM_JOBS=$2; shift;;
        -m | --mem) MEMORY=$2; shift;;
        -r | --runs) RUN_NUMS=$2; shift;;
        --start) START_ID=$2; shift;;
        --list) RUNLIST=$2; shift;;
        -l | --log) LOG_OUTPUT=$2; shift;;
        -c | --code) CODE=$2; shift;;
        -t | --target) TARGET=$2; shift;;
        -j | --jobname) JOB_NAME=$2; shift;;
        --local ) LOCAL=1;;
        --nick) NICK=$2; shift;;
        --time) TIME=$2; shift;;
        *) ADDITIONAL_OPTIONS="$*"; break; ;;
    esac
    shift;
done

#######################
# Create log directory
if [[ "${LOG_OUTPUT}" == "" ]]; then
  parentPath=logs/${CODE}/${TARGET}
  mkdir -p ${parentPath}
  LOG_OUTPUT=${parentPath}/%j-%x
else
  idx=$(rindex ${LOG_OUTPUT} "/")
  parentPath=${LOG_OUTPUT:0:$idx}
  mkdir -p ${parentPath}
fi

##
if [[ "${JOB_NAME}" == "" ]]; then
  JOB_NAME=P1_${TARGET}_${NICK}
fi

if [ "${RUNLIST}" == "" ]; then
  RUNLIST=""
else
  RUNLIST="--list ${RUNLIST}"
  RUN_NUMS=1
  START_ID=1
fi


# phase 1--------------------------------
HPCCMD="sbatch -J ${JOB_NAME} --ntasks-per-node ${NUM_JOBS} --mem-per-cpu=${MEMORY}G -o ${LOG_OUTPUT}.log"
PARALLEL_CMD="scripts/HPC/node_parallel.sh ${DRY_RUN} ${RUNLIST} -s ${START_ID} -l ${LOG_OUTPUT} -r ${RUN_NUMS}"
TASK="java -Xms1G -Xmx${MEMORY}G -jar artifacts/SafeSearch.jar -r ${RUN_NUMS} --runID {1} -b results/${CODE}/${TARGET} ${ADDITIONAL_OPTIONS}"

if [ "${TIME}" != "" ]; then
  HPCCMD="${HPCCMD} -t ${TIME}"
fi
if [ "${LOCAL}" == "1" ]; then
  HPCCMD=""
  PARALLEL_CMD=""
  if [ "${DRY_RUN}" != "" ]; then
    HPCCMD="echo"
  fi
fi
${HPCCMD} ${PARALLEL_CMD} ${TASK}

