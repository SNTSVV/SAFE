#!/bin/bash -l

usage() {
    cat <<EOF
NAME
    $(basename $0) -b <BASE_PATH> -t <TARGET_DIR_NAME> -l [LEVEL]
OPTIONS
  -d --dry-run:   dry run mode
  -b --base:      base path to work
  -t --target:    a name which will be removed in the base path
EOF
}


CMD_PREFIX=
BASE_PATH=
REMOVE=
LEVEL=1
# Parse the command-line argument
while [ $# -ge 1 ]; do
    case $1 in
        -h | --help) usage; exit 0;;
        -d | --noop | --dry-run) CMD_PREFIX=echo;;
        -b | --base) BASE_PATH=$2; shift;;
        -t | --target) REMOVE=$2; shift;;
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

if [ "${REMOVE}" == "" ]; then
    echo "You need to give the name which is removed in the base path"
    usage
    exit 1
fi


for sub in ${BASE_PATH}/*; do
	IS_FILE=TRUE
	if [ ! -f ${sub}/${REMOVE} ]; then
		IS_FILE=FALSE
	fi
	IS_DIR=TRUE
	if [ ! -d ${sub}/${REMOVE} ]; then
		IS_DIR=FALSE
	fi

	if [[ "${IS_FILE}" == "FALSE" && "${IS_DIR}" == "FALSE" ]]; then
		echo "Not found file or directory in ${sub}/${REMOVE}"
		continue
	fi
	echo "removing ${sub}/${REMOVE} ..."
	${CMD_PREFIX} rm -rf ${sub}/${REMOVE}
done

#scripts/HPC/remove_simple.sh -b results/TOSEM_bf2/ICS_20a_SAFE -t _phase2/_samples
#scripts/HPC/remove_simple.sh -b results/TOSEM_bf2/UAV_50a_SAFE -t _phase2/_samples
#scripts/HPC/remove_simple.sh -b results/TOSEM_bf2/ESAIL_SAFE -t _phase2/_samples

#scripts/HPC/remove_simple.sh -b results/TOSEM_bf2/ICS_20a_SAFE -t _dist
#scripts/HPC/remove_simple.sh -b results/TOSEM_bf2/UAV_50a_SAFE -t _dist
#scripts/HPC/remove_simple.sh -b results/TOSEM_bf2/ESAIL_SAFE -t _dist

#scripts/HPC/remove_simple.sh -b results/TOSEM_bf2/ICS_20a_SAFE -t _random
#scripts/HPC/remove_simple.sh -b results/TOSEM_bf2/UAV_50a_SAFE -t _random
#scripts/HPC/remove_simple.sh -b results/TOSEM_bf2/ESAIL_SAFE -t _random
