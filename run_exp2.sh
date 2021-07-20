#!/bin/bash -l
# All artifacts and R scripts should be executed in the project root folder.

# Settings
NUM_RUNS=1   # number of runs

###############################################################
## Phase 1: SafeSearch
###############################################################
# SafeSearch parameters
# --data: 			path for the input task description of a system  (INPUT_FILE in settings.json)
# -b: 				base working directory for all process (BASE_PATH in settings.json)
# -w1: 				relative directory path for outputs of Phase 1 from the BASE_PATH (WORKNAME_P1 in settings.json)
# --cpus: 			number of  simulation time of SafeScheduler (N_CPUS in settings.json)
# --max: 			maximum simulation time of SafeScheduler (TIME_MAX in settings.json)
# --quanta: 		time unit for one tick of SafeScheduler (TIME_QUANTA in settings.json)
# -r: 				the number of runs, default: 0, if this variable is over 1, the actual BASE_PATH will be replaced "<BASE_PATH>/Run##" during running the program (RUN_MAX in settings.json)
# --runID: 			identity of the experiments, if set runID, SafeSearch do experiment only one time even if the RUN_MAX is greater than 1. (NUM_RUNS in settings.json)
for ((runID=1; runID<=NUM_RUNS; runID++)); do
	runName=$(printf 'Run%02d' "${runID}")
	java -Xms1G -Xmx8G -jar artifacts/SafeSearch.jar -b results/EXP2/ADCS_SAFE/${runName} --data res/industrial/ADCS.csv --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1
done


###############################################################
## Preprocessing of Phase 2 (Feature reduction, treating imbalanced data, and generating test data)
###############################################################
# SafeRefinement parameters
# -b: 				base working directory for all process (BASE_PATH in settings.json)
# -w1: 				relative directory path for outputs of Phase 1 from the BASE_PATH, SafeRefinement loads data from this directory (WORKNAME_P1 in settings.json)
# --preOnly: 		(boolean) SafeRefinement only conducts preprocessing (PRE_ONLY in settings.json)
# --preFeatures: 	(boolean) SafeRefinement conducts feature reduction (PRE_FEATURES in settings.json)
# --prePrune: 		(boolean) SafeRefinement conducts pruning to training data produced by SafeSearch if the data is imbalanced (PRE_PRUNE in settings.json)
# --preTest: 		(boolean) SafeRefinement generates test data into <BASE_PATH>/testdata.csv, based on the solutions that found in the SafeSearch (PRE_TEST in settings.json)
# --nTest: 			the number of test data to generate (N_TEST_SOLUTIONS in settings.json)
for ((runID=1; runID<=NUM_RUNS; runID++)); do
	runName=$(printf 'Run%02d' "${runID}")
	java -Xms4G -Xmx8G -jar artifacts/SafeRefinement.jar -b results/EXP2/ADCS_SAFE/${runName} --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 --preFeatures --prePrune --preTest --nTest 50000 --preOnly
done

# The preprocessing can be conducted separately (the execution order should be following below)
# java -Xms4G -Xmx8G -jar artifacts/SafeRefinement.jar -b results/EXP2/ADCS_SAFE/Run01 --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 --preFeatures --preOnly
# java -Xms4G -Xmx8G -jar artifacts/SafeRefinement.jar -b results/EXP2/ADCS_SAFE/Run01 --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 --prePrune --preOnly
# java -Xms4G -Xmx8G -jar artifacts/SafeRefinement.jar -b results/EXP2/ADCS_SAFE/Run01 --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 --preTest --nTest 50000 --preOnly


# Checking the number of test data (if necessary)
#python3 scripts/collect/checkTestData.py -f check_testdata -b results/EXP2/ADCS_SAFE
#python3 scripts/collect/checkTestData.py -f check_testdata -b results/EXP2/ADCS_Baseline


###############################################################
# Phase 2: SafeRefinement
###############################################################
# SafeRefinement parameters
# -b: 				base working directory for all process (BASE_PATH in settings.json)
# -w1: 				relative directory path for outputs of Phase 1 from the BASE_PATH, SafeRefinement loads data from this directory (WORKNAME_P1 in settings.json)
# -w2: 				relative directory path for outputs of Phase 2 from the BASE_PATH (WORKNAME_P2 in settings.json)
# --nUpdates:		number of model updates during Phase 2 (N_MODEL_UPDATES in settings.json)
# --samplingMethod: the sampling method {distance, random} (SAMPLING_METHOD in settings.json)
# --useTest: 		(boolean) SafeRefinement produces evaluation results of models for each update based on the <BASE_PATH>/testdata.csv (USE_TEST_DATA in settings.json)
# --removeSamples: 	(boolean) SafeRefinement removes temporary files after done its process (REMOVE_SAMPLES in settings.json)
for ((runID=1; runID<=NUM_RUNS; runID++)); do
	runName=$(printf 'Run%02d' "${runID}")
	java -Xms4G -Xmx8G -jar artifacts/SafeRefinement.jar -b results/EXP2/ADCS_SAFE/${runName} --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _random --nUpdates 100 --samplingMethod random   --useTest --removeSamples
	java -Xms4G -Xmx8G -jar artifacts/SafeRefinement.jar -b results/EXP2/ADCS_SAFE/${runName} --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _dist   --nUpdates 100 --samplingMethod distance --useTest --removeSamples
done



########################################################################
# Collecting results of EXP2
########################################################################
# -f: 			function name to work (merge_p2_test: collect results of phase 2):
# -b: 			base working directory (The function merge_p2_test expects this directory to have multiple runs of results named by Run##)
# -o: 			output file path of the function (if the dirs are not exists, the script will generate)
# -t:			relative target file path to collect results from base path (_phase2/workdata_test_result.csv: the evaluation results by test data)
python3 scripts/tools/Collector.py -f merge_p2_test -b results/EXP2/ADCS_SAFE -o results/EXP2/_analysis/test_ADCS_random.csv -t _random/workdata_test_result.csv
python3 scripts/tools/Collector.py -f merge_p2_test -b results/EXP2/ADCS_SAFE -o results/EXP2/_analysis/test_ADCS_dist.csv   -t _dist/workdata_test_result.csv

# collecting execution time information
# -f: 			function name to work (merge_execinfo: execution information):
# -b: 			base working directory (The function merge_execinfo expects this directory to have multiple runs of results named by Run##)
# -o: 			output file path of the function (if the dirs are not exists, the script will generate)
# -t:			relative target file path to collect from base path (_dist/result2.txt)
python3 scripts/tools/Collector.py -f merge_execinfo -b results/EXP2/ADCS_SAFE -o results/EXP2/_analysis/exec_ADCS_random.csv -t _random/result2.txt
python3 scripts/tools/Collector.py -f merge_execinfo -b results/EXP2/ADCS_SAFE -o results/EXP2/_analysis/exec_ADCS_dist.csv   -t _dist/result2.txt

# Draw graphs
# Param1: base working directory
# Param2: List of subjects with a comma(,) separated (e.g., ADCS,ICS,UAV)
Rscript scripts/graphs/DrawingRQ2.R results/EXP2/_analysis ADCS
