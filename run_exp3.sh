#!/bin/bash -l
# All artifacts and R scripts should be executed in the project root folder.

# Settings
NUM_RUNS=1   # number of runs

###############################################################
## Phase 1: SafeSearch
###############################################################
# --data: 			path for the input task description of a system  (INPUT_FILE in settings.json)
# -b: 				base working directory for all process (BASE_PATH in settings.json)
# -w1: 				relative directory path for outputs of Phase 1 from the BASE_PATH (WORKNAME_P1 in settings.json)
# --cpus: 			number of  simulation time of SafeScheduler (N_CPUS in settings.json)
# --max: 			maximum simulation time of SafeScheduler (TIME_MAX in settings.json)
# --quanta: 		time unit for one tick of SafeScheduler (TIME_QUANTA in settings.json)
# -r: 				the number of runs, default: 0, if this variable is over 1, the actual BASE_PATH will be replaced "<BASE_PATH>/Run##" during running the program (RUN_MAX in settings.json)
# --runID: 			identity of the experiments, if set runID, SafeSearch do experiment only one time even if the RUN_MAX is greater than 1. (RUN_NUM in settings.json)
for ((runID=1; runID<=NUM_RUNS; runID++)); do
	runName=$(printf 'Run%02d' "${runID}")
	java -Xms1G -Xmx8G -jar artifacts/SafeSearch.jar -b results/EXP3/ADCS_SAFE/${runName} --data res/industrial/ADCS.csv --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1
done

###############################################################
# Phase 2: SafeRefinement
###############################################################
# -b: 				base working directory for all process (BASE_PATH in settings.json)
# -w1: 				relative directory path for outputs of Phase 1 from the BASE_PATH, SafeRefinement loads data from this directory (WORKNAME_P1 in settings.json)
# -w2: 				relative directory path for outputs of Phase 2 from the BASE_PATH (WORKNAME_P2 in settings.json)
# --nUpdates:		number of model updates during Phase 2 (N_MODEL_UPDATES in settings.json)
# --samplingMethod: the sampling method {distance, random} (SAMPLING_METHOD in settings.json)
# --removeSamples: 	(boolean) SafeRefinement removes temporary files after done its process (REMOVE_SAMPLES in settings.json)
for ((runID=1; runID<=NUM_RUNS; runID++)); do
	runName=$(printf 'Run%02d' "${runID}")
	java -Xms4G -Xmx8G -jar artifacts/SafeRefinement.jar -b results/EXP3/ADCS_SAFE/${runName} --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 --preFeatures --prePrune -w2 _phase2 --nUpdates 100 --samplingMethod distance --removeSamples
done

########################################################################
# Collecting results of EXP3
########################################################################
# -f: 				function name to work (merge_p2_test: collect results of phase 2):
# -b: 				base working directory (The function merge_p2_test expects this directory to have multiple runs of results named by Run##)
# -o: 				output file path of the function (if the dirs are not exists, the script will generate)
# -t:				target file to collect results (_phase2/workdata_termination_result.csv: the evaluation results by training data)
python3 scripts/tools/Collector.py -f merge_p2_test -b results/EXP3/ADCS_SAFE -o results/EXP3/_analysis/kfold_ADCS_SAFE.csv -t _phase2/workdata_termination_result.csv


# Draw graphs
# Param1: base working directory
# Param2: List of subjects with a comma(,) separated (e.g., ADCS,ICS,UAV)
Rscript scripts/graphs/DrawingRQ3.R results/EXP3/_analysis ADCS

