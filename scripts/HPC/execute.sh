#!/bin/bash -l

#
#SBATCH --time=0-01:00:00
#SBATCH --mail-type=all
#SBATCH --mail-user=jaekwon.lee@uni.lu
#SBATCH --qos=normal
#SBATCH --partition=batch
#SBATCH --mem-per-cpu=4G             # Stick to maximum size of memory
#SBATCH -o logs/execute/%x-%j.out          # Logfile: <jobname>-<jobid>.out
#SBATCH -e logs/execute/%x-%j.out          # Logfile: <jobname>-<jobid>.out
#

usage() {
    cat <<EOF
NAME
    $(basename $0) -cmd <COMMAND> <PARAMETERS for COMMAND>
OPTIONS
  -d --dry-run:   dry run mode
EXAMPLES
EOF
}

CMD_PREFIX=
PARAMETERS=""
CMD=""

# Parse the command-line argument
while [ $# -ge 1 ]; do
    case $1 in
        -h | --help) usage; exit 0;;
        -d | --noop | --dry-run) CMD_PREFIX=echo;;
        --cmd) CMD=$2; shift;;
        *) PARAMETERS="$*"; break; ;;
    esac
    shift;
done

if [ "${PARAMETERS}" == "" ]; then
    uasge
    exit 1
fi

if [ "${CMD}" == "" ]; then
    uasge
    exit 1
fi

if [ "${CMD}" == "java" ]; then
  module load lang/Java/1.8.0_241
elif [ "${CMD}" == "Rscript" ]; then
  module load lang/R/3.6.2-foss-2019b-bare
elif [ "${CMD}" == "python" ]; then
  CMD=~/venv/bin/python3
elif [ "${CMD}" == "python3" ]; then
  CMD=~/venv/bin/python3
else
  usage
  exit 1
fi

# replace parameterized text
PARAMETERS=$(echo ${PARAMETERS} | sed "s/{JOB_NAME}/${SLURM_JOB_NAME}/g")
echo ${CMD} ${PARAMETERS}
${CMD_PREFIX} ${CMD} ${PARAMETERS}



