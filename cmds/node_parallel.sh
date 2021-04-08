#!/bin/bash -l
#
#SBATCH -J GnuParallel
#SBATCH --time=2-00:00:00     # 1 hour
#SBATCH --mail-type=all
#SBATCH --mail-user=jaekwon.lee@uni.lu
#SBATCH --qos=normal
#SBATCH --partition=batch
#SBATCH --mem-per-cpu=4G             # Stick to maximum size of memory
#SBATCH -N 1                  # Stick to a single node
### -c, --cpus-per-task=<ncpus> if your application is using multithreading, increase the number of cpus(cores), otherwise just use 1
#SBATCH -c 1
###     /!\ Adapt '--ntasks-per-node' above accordingly
#SBATCH --ntasks-per-node 1
##SBATCH -o %x-%j.out          # Logfile: <jobname>-<jobid>.out
#


# Time-stamp: <Wed 2019-12-11 14:22 svarrette>
#############################################################################
# Slurm launcher for embarrassingly parallel problems combining srun and GNU
# parallel within a single node to runs multiple times the command ${TASK}
# within a 'tunnel' set to execute no more than ${SLURM_NTASKS} tasks in
# parallel.
#
# Resources:
# - https://www.marcc.jhu.edu/getting-started/additional-resources/distributing-tasks-with-slurm-and-gnu-parallel/
# - https://rcc.uchicago.edu/docs/tutorials/kicp-tutorials/running-jobs.html
# - https://curc.readthedocs.io/en/latest/software/GNUParallel.html
#############################################################################
############################################################
print_error_and_exit() {
  printf "\n *** ERROR *** \n$*\n\n"; exit 1;
}

usage() {
    cat <<EOF
NAME
    $(basename $0) [-n] [TASK]
    Using GNU parallel within a single node to run embarrasingly parallel
    problems, i.e. execute multiple times the command '\${TASK}' within a
    'tunnel' set to run NO MORE THAN \${SLURM_NTASKS} tasks in parallel.
    State of the execution is stored in logs/state.parallel.log and is used to
    resume the execution later on, from where it stoppped (either due to the
    fact that the slurm job has been stopped by failure or by hitting a walltime
    limit) next time you invoke this script.
    In particular, if you need to rerun this GNU Parallel job, be sure to delete
    the logfile logs/state*.parallel.log or it will think it has already
    finished!
    By default, the '${TASK} <arg>' command is executed
    with the arguments {1..8}
OPTIONS
  -d --dry-run:   dry run mode
EXAMPLES
  Within an interactive job (use --exclusive for some reason in that case)
      (access)$> si --exclusive --ntasks-per-node 4
      (node)$> $0 -t    # dry-run
      (node)$> $0
  Within a passive job
      (access)$> sbatch --ntasks-per-node 4 $0
  Within a passive job, using several cores (6) per tasks
      (access)$> sbatch --ntasks-per-socket 2 --ntasks-per-node 4 -c 6 $0
  Get the most interesting usage statistics of your jobs <JOBID> (in particular
  for each job step) with:
     sacct -j <JOBID> --format User,JobID,Jobname,partition,state,time,elapsed,MaxRss,MaxVMSize,nnodes,ncpus,nodelist,ConsumedEnergyRaw


EOF
}

start(){
  start=$(date +%s)
  cat <<EOF
################################################
### Task command   : ${TASK}
### SRUN option    : ${SRUN} -e ${LOG_OUTPUT}.{1}.out -o ${LOG_OUTPUT}.{1}.out
### Parallel option: ${PARALLEL}
### Starting timestamp (s): ${start}
################### START ######################
EOF
}

finish() {
  end=$(date +%s)
  cat <<EOF
#################### END #######################
### Ending timestamp (s): ${end}
### Elapsed time     (s): $(($end-$start))
################################################
##############################################################################
Beware that the GNU parallel option --resume makes it read the log file set by
--joblog (i.e. logs/state*.log) to figure out the last unfinished task (due to the
fact that the slurm job has been stopped due to failure or by hitting a walltime
limit) and continue from there.
In particular, if you need to rerun this GNU Parallel job, be sure to delete the
logfile logs/state*.parallel.log or it will think it has already finished!
##############################################################################

EOF
}


##############################################################################
##############################################################################
##############################################################################
# Use the UL HPC modules
if [ -f  /etc/profile ]; then
    .  /etc/profile
fi

module purge || print_error_and_exit "Unable to find the module command - you're NOT on a computing node"
# module load [...]
#module load lang/Java/1.8.0_162
#module load swenv/default-env/latest
#module load swenv/default-env/v1.1-20180716-production
#module load lang/R/3.4.4-intel-2018a-X11-20180131-bare
module load lang/Java/1.8.0_241

#if [ ${SLURMD_NODENAME:5} -gt 108 ]; then
#  echo "R_LIBS_USER=~/R/3.6-intel/" > ~/.Renviron
#  module load lang/R/3.6.2-intel-2019b-bare
#else
#  echo "R_LIBS_USER=~/R/3.6/" > ~/.Renviron
#  module load lang/R/3.6.2-foss-2019b-bare
#fi
#module load lang/R/3.6.2-intel-2019b-bare   # Error to install cubature
module load lang/R/3.6.2-foss-2019b-bare


##############################################################################
##############################################################################
##############################################################################
####################### Let's go ##############################

CMD_PREFIX=
TASK="stress --cpu ${SLURM_CPUS_PER_TASK:=1} --timeout 60s --vm-hang"  ## Test code
RUN_NUMS=1
START_RUN_ID=1
# Parse the command-line argument
while [ $# -ge 1 ]; do
    case $1 in
        -h | --help) usage; exit 0;;
        -d | --noop | --dry-run) CMD_PREFIX=echo;;
        -s | --start) START_RUN_ID=$2; shift;;
        -r | --runNum) RUN_NUMS=$2; shift;;
        -l | --log) LOG_OUTPUT=$2; shift;;
        *) TASK="$*"; break; ;;
    esac
    shift;
done


# the --exclusive to srun makes srun use distinct CPUs for each job step
# -N1 -n1 allocates a single core to each task - Adapt accordingly
SRUN="srun --exclusive -N1 -n1 --cpus-per-task=${SLURM_CPUS_PER_TASK:=1} --cpu-bind=cores "

### GNU Parallel options
# --delay .2 prevents overloading the controlling node
# -j is the number of tasks parallel runs so we set it to $SLURM_NTASKS
# --joblog makes parallel create a log of tasks that it has already run
# --resume makes parallel use the joblog to resume from where it has left off
#   the combination of --joblog and --resume allow jobs to be resubmitted if
#   necessary and continue from where they left off
LOG_OUTPUT=${LOG_OUTPUT//%j/${SLURM_JOB_ID}}
LOG_OUTPUT=${LOG_OUTPUT//%x/${SLURM_JOB_NAME}}
PARALLEL="parallel --delay .2 -j ${SLURM_NTASKS} --joblog ${LOG_OUTPUT}_parallel.log" # --resume"


# this runs the parallel command you want, i.e. running the
# script ${TASK} within a 'tunnel' set to run no more than ${SLURM_NTASKS} tasks
# in parallel
# See 'man parallel'
# - Reader's guide: https://www.gnu.org/software/parallel/parallel_tutorial.html
# - Numerous (easier) tutorials are available online. Ex:
#   http://www.shakthimaan.com/posts/2014/11/27/gnu-parallel/news.html
#

# create a list of run IDs (list of string with delimiter ' ')
# if we use variable in PARALLEL command, it doesn't work with {x..y} notation
#END_RUN_ID=`expr $START_RUN_ID + $SLURM_NTASKS - 1`   # set END run ID
RUN_IDS=""
for ((runID=$START_RUN_ID; runID<=${RUN_NUMS}; runID++)); do
  var=$(printf '%02d' "${runID}")
  RUN_IDS="${RUN_IDS} ${var}"
done

# Execute parallel works!
start
${CMD_PREFIX} ${PARALLEL} "${SRUN} -e ${LOG_OUTPUT}.{1}.out -o ${LOG_OUTPUT}.{1}.out ${TASK}" ::: ${RUN_IDS}
finish