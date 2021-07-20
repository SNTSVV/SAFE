#!/bin/bash -l
# All artifacts and R scripts should be executed in the project root folder.

# Settings
NUM_RUNS=1   # number of runs

###############################################################
## SAFE Approach
###############################################################
for ((runID=1; runID<=NUM_RUNS; runID++)); do
	runName=$(printf 'Run%02d' "${runID}")

	# Phase 1: SafeSearch
	# --data: 			path for the input task description of a system  (INPUT_FILE in settings.json)
	# -b: 				base working directory for all process (BASE_PATH in settings.json)
	# -w1: 				relative directory path for outputs of Phase 1 from the BASE_PATH (WORKNAME_P1 in settings.json)
	# --cpus: 			number of  simulation time of SafeScheduler (N_CPUS in settings.json)
	# --max: 			maximum simulation time of SafeScheduler (TIME_MAX in settings.json)
	# --quanta: 		time unit for one tick of SafeScheduler (TIME_QUANTA in settings.json)
	java -Xms1G -Xmx8G -jar artifacts/SafeSearch.jar -b results/EXP1/ADCS_SAFE/${runName} --data res/industrial/ADCS.csv --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1

	# Phase 2: SafeRefinement
	# -b: 				base working directory for all process (BASE_PATH in settings.json)
	# -w1: 				relative directory path for outputs of Phase 1 from the BASE_PATH, SafeRefinement loads worse-case sequences from this directory (WORKNAME_P1 in settings.json)
	# -w2: 				relative directory path for outputs of Phase 2 from the BASE_PATH (WORKNAME_P2 in settings.json)
	# --nUpdates:		number of model updates during Phase 2 (N_MODEL_UPDATES in settings.json)
	# --preFeatures: 	(boolean) SafeRefinement conducts feature reduction (PRE_FEATURES in settings.json)
	# --prePrune: 		(boolean) SafeRefinement conducts pruning to training data produced by SafeSearch if the data is imbalanced (PRE_PRUNE in settings.json)
	# --removeSamples: 	(boolean) SafeRefinement removes temporary files after done its process (REMOVE_SAMPLES in settings.json)
	java -Xms4G -Xmx8G -jar artifacts/SafeRefinement.jar -b results/EXP1/ADCS_SAFE/${runName} --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 --preFeatures --prePrune -w2 _phase2 --nUpdates 100 --samplingMethod distance --removeSamples
done

###############################################################
## Random Search Approach
###############################################################
for ((runID=1; runID<=NUM_RUNS; runID++)); do
	runName=$(printf 'Run%02d' "${runID}")

	# Phase 1: SafeSearch with simple search option
	# --simpleSearch: 	(boolean) SafeSearch does not use GA operators during search (SIMPLE_SEARCH in settings.json)
	# -i: 				number of iteration of Phase 1 (GA_ITERATION in settings.json)
	java -Xms1G -Xmx8G -jar artifacts/SafeSearch.jar -b results/EXP1/ADCS_Baseline/${runName} --data res/industrial/ADCS.csv --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 --simpleSearch -i 1500

	# Generating Phase 2 results based on the Phase 1 results (finding best task WCETs)
	# -b: 				base working directory for all process
	# -w1: 				relative directory path for outputs of Phase 1 from the BASE_PATH
	# -w2: 				relative output directory path from the BASE_PATH, BestSize.py generates the same structure of results with the Phase 2 in the SAFE
	# -u: 				number of model updates in Phase 2 (This number should be the same with --nUpdates of SafeRefinement.jar)
	# -q: 				time unit for one tick that used in the SafeScheduler for the subject (it should be the same with --quanta of SafeSearch.jar)
	python3 ./scripts/tools/BestSize.py -b results/EXP1/ADCS_Baseline/${runName} -w1 _phase1 -w2 _phase2 -u 100 -q 0.1
done

###############################################################
## RoundTrip comparing
###############################################################
# RoundTrip parameters
# --nTest:			number of test (sequences of task arrivals) (in settings.json)
# --nWCET:			number of sample WECTs for one test (in settings.json)
for ((runID=1; runID<=NUM_RUNS; runID++)); do
	runName=$(printf 'Run%02d' "${runID}")

	java -Xms1G -Xmx8G -jar artifacts/RoundTrip.jar -b results/EXP1/ADCS_SAFE/${runName}     --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200
	java -Xms1G -Xmx8G -jar artifacts/RoundTrip.jar -b results/EXP1/ADCS_Baseline/${runName} --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200
done


########################################################################
# Collecting EXP1 results
########################################################################
# Collecting results of phase 1
# -f: 			function name to work (merge_execinfo: execution information):
# -b: 			base working directory (The function merge_execinfo expects this directory to have multiple runs of results named by Run##)
# -o: 			output file path of the function (if the dirs are not exists, the script will generate)
# -t:			relative target file path to collect from base path (default: ./result.txt)
python3 scripts/tools/Collector.py -f merge_execinfo -b results/EXP1/ADCS_SAFE   -o results/EXP1/_analysis/P1_ADCS_SAFE.csv
python3 scripts/tools/Collector.py -f merge_execinfo -b results/EXP1/ADCS_RS1500 -o results/EXP1/_analysis/P1_ADCS_Baseline.csv


# Collecting results of phase 2
# -f: 			function name to work (merge_p2_model: collecting model information and best point results)
# -b: 			base working directory (The script expects this directory to have multiple runs of results named by Run##)
# -o: 			output file path of the function (if the dirs are not exists, the script will generate)
# -q: 			time quanta for the subject
python3 scripts/tools/Collector.py -f merge_p2_model -b results/EXP1/ADCS_SAFE   -o results/EXP1/_analysis/P2_ADCS_SAFE.csv     -q 0.1
python3 scripts/tools/Collector.py -f merge_p2_model -b results/EXP1/ADCS_RS1500 -o results/EXP1/_analysis/P2_ADCS_Baseline.csv -q 0.1


# Collecting results of round trip
# -f: 			function name to work (merge_p2_model: collecting model information and best point results)
# -b: 			base working directory (The script expects this directory to have multiple runs of results named by Run##)
# -o: 			output file path of the function (if the dirs are not exists, the script will generate)
# -t: 			target directory name of round trip
python3 scripts/tools/RoundTripCollector.py -f merge_roundtrip_subject -b results/EXP1/ADCS_SAFE     -o results/EXP1/_analysis/RT_ADCS_SAFE     -t _roundtrip
python3 scripts/tools/RoundTripCollector.py -f merge_roundtrip_subject -b results/EXP1/ADCS_Baseline -o results/EXP1/_analysis/RT_ADCS_Baseline -t _roundtrip

# Checking the execution results of round trip (if necessary)
#python3 scripts/tools/checkTestData.py -f check_roundtrip -b results/EXP1/ADCS_SAFE
#python3 scripts/tools/checkTestData.py -f check_roundtrip -b results/EXP1/ADCS_Baseline

# Draw graphs
# Param1: base working directory
# Param2: List of subjects with a comma(,) separated (e.g., ADCS,ICS,UAV)
Rscript scripts/graphs/DrawingBestSize.R results/EXP1/_analysis ADCS
Rscript scripts/graphs/DrawingRoundTrip.R results/EXP1/_analysis ADCS
Rscript scripts/graphs/DrawingProbability.R results/EXP1/_analysis ADCS
Rscript scripts/graphs/DrawingExecTime.R results/EXP1/_analysis ADCS