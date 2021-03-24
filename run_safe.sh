#!/bin/bash -l
# All artifacts and R scripts should be executed in the project root folder.

# Examples of Phase 1
# -r: RUN_MAX in settings.json, the number of experiments
# --runID: RUN_NUM in settings.json, Identity of the experiments, if set runID, P1-StressTesting.jar do experiment only one time even if the RUN_MAX is greater than 1.
# -b: BASE_PATH in settings.json, Output path of the Phase 1
java -Xms4G -Xmx10G -jar artifacts/P1-SAFESearch.jar -b results/SAFE_GASearch


# Feature reduction and treating imbalanced data
# features.R <BASE_PATH of P1>
# This code generate logistic regression model and save the formula into <BASE_PATH>/_formula/formula
Rscript scripts/Phase2/features.R results/SAFE_GASearch _results _formula


# prune_input.R <BASE_PATH of P1> <Output path of this script>
Rscript scripts/Phase2/prune_input.R results/SAFE_GASearch _results _formula


# Examples of Phase 2
# -b: BASE_PATH in settings.json, Output path of the Phase 1
# --samplingMethod: the sampling method [distance, random]
java -Xms4G -Xmx10G -jar artifacts/P2-Refinements.jar -b results/SAFE_GASearch --samplingMethod distance


