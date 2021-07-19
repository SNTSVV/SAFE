#!/bin/bash -l
# All artifacts and R scripts should be executed in the project root folder.

# Phase 1: SafeSearch
# --data: Task description to use (INPUT_FILE in settings.json)
# -b: base working directory for all process (BASE_PATH in settings.json)
# -w1: relative directory path for outputs of Phase 1 from the BASE_PATH (WORKNAME_P1 in settings.json)
# --cpus: number of  simulation time of SafeScheduler (N_CPUS in settings.json)
# --max: maximum simulation time of SafeScheduler (TIME_MAX in settings.json)
# --quanta: time unit for one tick of SafeScheduler (TIME_QUANTA in settings.json)
for ((runID=1; runID<=NUM_RUNS; runID++)); do
	runName=$(printf 'Run%02d' "${runID}")
	java -Xms1G -Xmx8G -jar artifacts/SafeSearch.jar -b results/SanityCheck/ADCS_SAFE/${runName} --data res/industrial/ADCS.csv --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1
done


# Phase 1: Random Search (SafeSearch with simple search option)
# --simpleSearch: (boolean) SafeSearch uses simple random search approach (SIMPLE_SEARCH in settings.json)
# -i: number of iteration of SafeSearch (GA_ITERATION in settings.json)
for ((runID=1; runID<=NUM_RUNS; runID++)); do
	runName=$(printf 'Run%02d' "${runID}")
	java -Xms1G -Xmx8G -jar artifacts/SafeSearch.jar -b results/SanityCheck/ADCS_Random/${runName} --data res/industrial/ADCS.csv --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 --simpleSearch -i 1000
done