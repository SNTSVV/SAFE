#!/bin/bash -l
# All artifacts and R scripts should be executed in the project root folder.

###############################################################
## SAFE Approach
###############################################################
# Phase 1: SafeSearch
# --data: 			path for the input task description of a system   (INPUT_FILE in settings.json)
# -b: 				base working directory for all process (BASE_PATH in settings.json)
# -w1: 				relative directory path for outputs of Phase 1 from the BASE_PATH (WORKNAME_P1 in settings.json)
# --cpus: 			number of  simulation time of SafeScheduler (N_CPUS in settings.json)
# --max: 			maximum simulation time of SafeScheduler (TIME_MAX in settings.json)
# --quanta: 		time unit for one tick of SafeScheduler (TIME_QUANTA in settings.json)
java -Xms1G -Xmx8G -jar artifacts/SafeSearch.jar -b results/ADCS_SAFE --data res/industrial/ADCS.csv --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1

# Phase 2: SafeRefinement
# -b: 				base working directory for all process (BASE_PATH in settings.json)
# -w1: 				relative directory path for outputs of Phase 1 from the BASE_PATH, SafeRefinement loads worse-case sequences from this directory (WORKNAME_P1 in settings.json)
# -w2: 				relative directory path for outputs of Phase 2 from the BASE_PATH (WORKNAME_P2 in settings.json)
# --nUpdates:		number of model updates during Phase 2 (N_MODEL_UPDATES in settings.json)
# --preFeatures: 	(boolean) SafeRefinement conducts feature reduction (PRE_FEATURES in settings.json)
# --prePrune: 		(boolean) SafeRefinement conducts pruning to training data produced by SafeSearch if the data is imbalanced (PRE_PRUNE in settings.json)
# --removeSamples: 	(boolean) SafeRefinement removes temporary files after done its process (REMOVE_SAMPLES in settings.json)
java -Xms4G -Xmx8G -jar artifacts/SafeRefinement.jar -b results/ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 --preFeatures --prePrune -w2 _phase2 --nUpdates 100 --samplingMethod distance --removeSamples
