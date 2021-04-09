#!/bin/bash -l

usage() {
    cat <<EOF
NAME
    $(basename $0) -b <BASE_PATH> -t <TARGET_DIR_NAME> -l [LEVEL]
OPTIONS
  -d --dry-run:   dry run mode
  -b --base:      base path to work
  -t --target:    a name which will be removed in the base path
  -l --level [0-9]+:     a level of depth in depth of target name
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
        -l | --level) LEVEL=$2; shift;;
        -t | --target) REMOVE=$2; shift;;
    esac
    shift;
done

if [ ! -d ${BASE_PATH} ]; then
    echo "You need to give the exist directory"
    usage
    exit 1
fi

if [ ${REMOVE} == "" ]; then
    echo "You need to give the name which is removed in the base path"
    usage
    exit 1
fi

work(){
  if [ ! $# -eq 2 ]; then
    return 0;
  fi
  local aPath=$1
  local lv=$2

  if [ ${lv} -eq 0 ]; then
#    echo "Searching ${aPath}:"
    for fullPath in ${aPath}/*; do
      filename="$(basename "${fullPath}")"
      if [ ${filename} == ${REMOVE} ]; then
        echo " - Removing ${fullPath}..."
        ${CMD_PREFIX} rm -rf ${fullPath}
      fi
    done
    return 1
  fi

  for dirName in ${aPath}/*; do
    if [ -f ${dirName} ]; then
      continue
    fi
    work ${dirName} $(( ${lv}-1 ))
  done
}

echo "Start to remove ${REMOVE} in ${BASE_PATH}"
echo " - Depth level: ${LEVEL}"
work ${BASE_PATH} ${LEVEL}
echo "All work is done!"
