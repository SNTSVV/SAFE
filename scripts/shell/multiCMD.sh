#!/bin/bash -l

usage() {
    cat <<EOF
NAME
    $(basename $0) -b <BASE_PATH> -c <COMMAND> -t <TARGET_DIR_NAME> -l [LEVEL]
OPTIONS
  -d --dry-run:   dry run mode
  -b --base:      base path to work
  -c --cmd:		  command to apply
  -t --target:    a name which will be changed in the base path
  -r --replace:   a name which will replace the target
EOF
}


CMD_PREFIX=
BASE_PATH=
COMMAND=
TARGET=
REPLACE=
LEVEL=1
# Parse the command-line argument
while [ $# -ge 1 ]; do
    case $1 in
        -h | --help) usage; exit 0;;
        -d | --noop | --dry-run) CMD_PREFIX=echo;;
        -b | --base) BASE_PATH=$2; shift;;
        -c | --cmd)  COMMAND=$2; shift;;
        -t | --target) TARGET=$2; shift;;
        -r | --replace) REPLACE=$2; shift;;
    esac
    shift;
done

echo "BASE_PATH=\"${BASE_PATH}\""
if [ -z "${BASE_PATH}" ]; then
	echo "You need to give the exist directory"
	usage
	exit 1
fi

if [ ! -d ${BASE_PATH} ]; then
    echo "You need to give the exist directory"
    usage
    exit 1
fi

if [ "${COMMAND}" == "" ]; then
    echo "You need to give the command to be executed"
    usage
    exit 1
fi

if [ "${TARGET}" == "" ]; then
    echo "You need to give the name which is removed in the base path"
    usage
    exit 1
fi


for sub in ${BASE_PATH}/*; do
	IS_FILE=TRUE
	if [ ! -f ${sub}/${TARGET} ]; then
		IS_FILE=FALSE
	fi
	IS_DIR=TRUE
	if [ ! -d ${sub}/${TARGET} ]; then
		IS_DIR=FALSE
	fi

	if [[ "${IS_FILE}" == "FALSE" && "${IS_DIR}" == "FALSE" ]]; then
		echo "Not found file or directory in ${sub}/${TARGET}"
		continue
	fi
	echo "${COMMAND} ${sub}/${TARGET} ..."

	if [[ "${COMMAND}" == "mv" ]]; then
		${CMD_PREFIX} ${COMMAND} ${sub}/${TARGET} ${sub}/${REPLACE}
	elif [[ "${COMMAND}" == "cp" ]]; then
		${CMD_PREFIX} ${COMMAND} ${sub}/${TARGET} ${sub}/${REPLACE}
	else
		${CMD_PREFIX} ${COMMAND} ${sub}/${TARGET}
	fi
done

#scripts/HPC/multiCMD.sh -c "rm -rf" -b results/TOSEM_bf2/ICS_20a_SAFE -t _phase2/_samples
#scripts/HPC/multiCMD.sh -c "rm -rf" -b results/TOSEM_bf2/UAV_50a_SAFE -t _phase2/_samples
#scripts/HPC/multiCMD.sh -c "rm -rf" -b results/TOSEM_bf2/ESAIL_SAFE 	-t _phase2/_samples

#scripts/HPC/multiCMD.sh -c "rm -rf" -b results/TOSEM_bf2/ICS_20a_SAFE -t _dist
#scripts/HPC/multiCMD.sh -c "rm -rf" -b results/TOSEM_bf2/UAV_50a_SAFE -t _dist
#scripts/HPC/multiCMD.sh -c "rm -rf" -b results/TOSEM_bf2/ESAIL_SAFE -t _dist

#scripts/HPC/multiCMD.sh -c "rm -rf" -b results/TOSEM_bf2/ICS_20a_SAFE -t _random
#scripts/HPC/multiCMD.sh -c "rm -rf" -b results/TOSEM_bf2/UAV_50a_SAFE -t _random
#scripts/HPC/multiCMD.sh -c "rm -rf" -b results/TOSEM_bf2/ESAIL_SAFE -t _random
