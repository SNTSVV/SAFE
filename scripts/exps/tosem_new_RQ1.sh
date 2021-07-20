#!/bin/bash -l
# All artifacts and R scripts should be executed in the project root folder.

# to compare ADCS(T30 reduced deadline) ESAIL(with large deadline)

#############################################################################
# SAFE: for ICS and UAV (CCS, GAP, HPSS not available)
#############################################################################
# Phase 1
./scripts/HPC/exec_P1.sh --time 01:00:00 --nick T -m 8 -N 10 -r 50 -c TOSEM_new -t ICS_SAFE --data res/industrial_new/ICS_20a.csv --cpus 3 --quanta 0.01 --max 0
./scripts/HPC/exec_P1.sh --time 02:00:00 --nick T -m 8 -N 10 -r 50 -c TOSEM_new -t UAV_SAFE --data res/industrial_new/UAV_50a.csv --cpus 3 --quanta 0.01 --max 0

./scripts/HPC/exec_P2.sh --time 2:00:00 --dependency 2420903 --nick T -m 8 -N 10 --start  1 -r 10 -c TOSEM_new -t ICS_SAFE  --cpus 3 --max 0 --quanta 0.01 --preFeatures --prePrune --removeSamples
./scripts/HPC/exec_P2.sh --time 2:00:00 --dependency 2420903 --nick T -m 8 -N 10 --start 11 -r 20 -c TOSEM_new -t ICS_SAFE  --cpus 3 --max 0 --quanta 0.01 --preFeatures --prePrune --removeSamples
./scripts/HPC/exec_P2.sh --time 2:00:00 --dependency 2420903 --nick T -m 8 -N 10 --start 21 -r 30 -c TOSEM_new -t ICS_SAFE  --cpus 3 --max 0 --quanta 0.01 --preFeatures --prePrune --removeSamples
./scripts/HPC/exec_P2.sh --time 2:00:00 --dependency 2420903 --nick T -m 8 -N 10 --start 31 -r 40 -c TOSEM_new -t ICS_SAFE  --cpus 3 --max 0 --quanta 0.01 --preFeatures --prePrune --removeSamples
./scripts/HPC/exec_P2.sh --time 2:00:00 --dependency 2420903 --nick T -m 8 -N 10 --start 41 -r 50 -c TOSEM_new -t ICS_SAFE  --cpus 3 --max 0 --quanta 0.01 --preFeatures --prePrune --removeSamples

./scripts/HPC/exec_P2.sh --time 2:00:00 --dependency 2420639 --nick T -m 8 -N 10 --start  1 -r 10 -c TOSEM_new -t UAV_SAFE  --cpus 3 --max 0 --quanta 0.01 --preFeatures --prePrune --removeSamples
./scripts/HPC/exec_P2.sh --time 2:00:00 --dependency 2420639 --nick T -m 8 -N 10 --start 11 -r 20 -c TOSEM_new -t UAV_SAFE  --cpus 3 --max 0 --quanta 0.01 --preFeatures --prePrune --removeSamples
./scripts/HPC/exec_P2.sh --time 2:00:00 --dependency 2420639 --nick T -m 8 -N 10 --start 21 -r 30 -c TOSEM_new -t UAV_SAFE  --cpus 3 --max 0 --quanta 0.01 --preFeatures --prePrune --removeSamples
./scripts/HPC/exec_P2.sh --time 2:00:00 --dependency 2420639 --nick T -m 8 -N 10 --start 31 -r 40 -c TOSEM_new -t UAV_SAFE  --cpus 3 --max 0 --quanta 0.01 --preFeatures --prePrune --removeSamples
./scripts/HPC/exec_P2.sh --time 2:00:00 --dependency 2420639 --nick T -m 8 -N 10 --start 41 -r 50 -c TOSEM_new -t UAV_SAFE  --cpus 3 --max 0 --quanta 0.01 --preFeatures --prePrune --removeSamples


#############################################################################
# SAFE: ESAIL (Old version: T30 has a large deadline)
#############################################################################
# ESAIL Phase 1
./scripts/HPC/exec_P1.sh --time 1-15:00:00 --nick T -m 8 -N 10 --start  1 -r 10 -c TOSEM_new -t ESAIL_SAFE --data res/industrial_new/ESAIL.csv --cpus 1 --max 1800000 --quanta 0.1
./scripts/HPC/exec_P1.sh --time 1-15:00:00 --nick T -m 8 -N 10 --start 11 -r 20 -c TOSEM_new -t ESAIL_SAFE --data res/industrial_new/ESAIL.csv --cpus 1 --max 1800000 --quanta 0.1
./scripts/HPC/exec_P1.sh --time 1-15:00:00 --nick T -m 8 -N 10 --start 21 -r 30 -c TOSEM_new -t ESAIL_SAFE --data res/industrial_new/ESAIL.csv --cpus 1 --max 1800000 --quanta 0.1
./scripts/HPC/exec_P1.sh --time 1-15:00:00 --nick T -m 8 -N 10 --start 31 -r 40 -c TOSEM_new -t ESAIL_SAFE --data res/industrial_new/ESAIL.csv --cpus 1 --max 1800000 --quanta 0.1
./scripts/HPC/exec_P1.sh --time 1-15:00:00 --nick T -m 8 -N 10 --start 41 -r 50 -c TOSEM_new -t ESAIL_SAFE --data res/industrial_new/ESAIL.csv --cpus 1 --max 1800000 --quanta 0.1

# ESAIL Phase 2
./scripts/HPC/exec_P2.sh --nick T -m 8 -N 10 --start  1 -r 10 -c TOSEM_new -t ESAIL_SAFE --cpus 1 --max 1800000 --quanta 0.1 --prePrune --preFeatures --removeSamples
./scripts/HPC/exec_P2.sh --nick T -m 8 -N 10 --start 11 -r 20 -c TOSEM_new -t ESAIL_SAFE --cpus 1 --max 1800000 --quanta 0.1 --prePrune --preFeatures --removeSamples
./scripts/HPC/exec_P2.sh --nick T -m 8 -N 10 --start 21 -r 30 -c TOSEM_new -t ESAIL_SAFE --cpus 1 --max 1800000 --quanta 0.1 --prePrune --preFeatures --removeSamples
./scripts/HPC/exec_P2.sh --nick T -m 8 -N 10 --start 31 -r 40 -c TOSEM_new -t ESAIL_SAFE --cpus 1 --max 1800000 --quanta 0.1 --prePrune --preFeatures --removeSamples
./scripts/HPC/exec_P2.sh --nick T -m 8 -N 10 --start 41 -r 50 -c TOSEM_new -t ESAIL_SAFE --cpus 1 --max 1800000 --quanta 0.1 --prePrune --preFeatures --removeSamples

#############################################################################
# SAFE: ADCS (New version: T30 has a small deadline)
#############################################################################
# ADCS Phase 1
./scripts/HPC/exec_P1.sh --time 1-15:00:00 --nick T -m 8 -N 10 --start  1 -r 10 -c TOSEM_new -t ADCS_SAFE --data res/industrial_new/ADCS.csv --cpus 1 --max 1800000 --quanta 0.1
./scripts/HPC/exec_P1.sh --time 1-15:00:00 --nick T -m 8 -N 10 --start 11 -r 20 -c TOSEM_new -t ADCS_SAFE --data res/industrial_new/ADCS.csv --cpus 1 --max 1800000 --quanta 0.1
./scripts/HPC/exec_P1.sh --time 1-15:00:00 --nick T -m 8 -N 10 --start 21 -r 30 -c TOSEM_new -t ADCS_SAFE --data res/industrial_new/ADCS.csv --cpus 1 --max 1800000 --quanta 0.1
./scripts/HPC/exec_P1.sh --time 1-15:00:00 --nick T -m 8 -N 10 --start 31 -r 40 -c TOSEM_new -t ADCS_SAFE --data res/industrial_new/ADCS.csv --cpus 1 --max 1800000 --quanta 0.1
./scripts/HPC/exec_P1.sh --time 1-15:00:00 --nick T -m 8 -N 10 --start 41 -r 50 -c TOSEM_new -t ADCS_SAFE --data res/industrial_new/ADCS.csv --cpus 1 --max 1800000 --quanta 0.1

# ADCS Phase 2
./scripts/HPC/exec_P2.sh --time 1-10:00:00 --nick T -m 8 -N 10 --start  1 -r 10 -c TOSEM_new -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --prePrune --preFeatures --removeSamples
./scripts/HPC/exec_P2.sh --time 1-10:00:00 --nick T -m 8 -N 10 --start 11 -r 20 -c TOSEM_new -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --prePrune --preFeatures --removeSamples
./scripts/HPC/exec_P2.sh --time 1-10:00:00 --nick T -m 8 -N 10 --start 21 -r 30 -c TOSEM_new -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --prePrune --preFeatures --removeSamples
./scripts/HPC/exec_P2.sh --time 1-10:00:00 --nick T -m 8 -N 10 --start 31 -r 40 -c TOSEM_new -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --prePrune --preFeatures --removeSamples
./scripts/HPC/exec_P2.sh --time 1-10:00:00 --nick T -m 8 -N 10 --start 41 -r 50 -c TOSEM_new -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --prePrune --preFeatures --removeSamples

#############################################################################
# Random Search: ICS and UAV (CCS, GAP, HPSS not available)
#############################################################################
# Phase 1
./scripts/HPC/exec_P1.sh --time 01:00:00 --nick T -m 8 -N 10 -r 50 -c TOSEM_new -t ICS_Baseline --data res/industrial_new/ICS_20a.csv --cpus 3 --quanta 0.01 --simpleSearch -i 1500
./scripts/HPC/exec_P1.sh --time 02:00:00 --nick T -m 8 -N 10 -r 50 -c TOSEM_new -t UAV_Baseline --data res/industrial_new/UAV_50a.csv --cpus 3 --quanta 0.01 --simpleSearch -i 1500

# Best Size calculate (Phase2 for Random Search, Taking long time)
./scripts/HPC/exec_P2_RS.sh --time 02:00:00 --dependency 2420652 --nick T -m 8 -N 10 -r 50 -c TOSEM_new -t ICS_Baseline -u 100 -q 0.01
./scripts/HPC/exec_P2_RS.sh --time 02:00:00 --dependency 2420653 --nick T -m 8 -N 10 -r 50 -c TOSEM_new -t UAV_Baseline -u 100 -q 0.01


#############################################################################
# Random Search: ESAIL (Old version: T30 has a large deadline)
#############################################################################
# ESAIL Random Phase 1
./scripts/HPC/exec_P1.sh --time 1-15:00:00 --nick T -m 8 -N 10 --start  1 -r 10 -c TOSEM_new -t ESAIL_Baseline --data res/industrial_new/ESAIL.csv --cpus 1 --max 1800000 --quanta 0.1 --simpleSearch -i 1500
./scripts/HPC/exec_P1.sh --time 1-15:00:00 --nick T -m 8 -N 10 --start 11 -r 20 -c TOSEM_new -t ESAIL_Baseline --data res/industrial_new/ESAIL.csv --cpus 1 --max 1800000 --quanta 0.1 --simpleSearch -i 1500
./scripts/HPC/exec_P1.sh --time 1-15:00:00 --nick T -m 8 -N 10 --start 21 -r 30 -c TOSEM_new -t ESAIL_Baseline --data res/industrial_new/ESAIL.csv --cpus 1 --max 1800000 --quanta 0.1 --simpleSearch -i 1500
./scripts/HPC/exec_P1.sh --time 1-15:00:00 --nick T -m 8 -N 10 --start 31 -r 40 -c TOSEM_new -t ESAIL_Baseline --data res/industrial_new/ESAIL.csv --cpus 1 --max 1800000 --quanta 0.1 --simpleSearch -i 1500
./scripts/HPC/exec_P1.sh --time 1-15:00:00 --nick T -m 8 -N 10 --start 41 -r 50 -c TOSEM_new -t ESAIL_Baseline --data res/industrial_new/ESAIL.csv --cpus 1 --max 1800000 --quanta 0.1 --simpleSearch -i 1500

# ESAIL Random Phase 2
./scripts/HPC/exec_P2_RS.sh --time 2:00:00 --dependency 2400566 --nick T -m 8 -N 10 --start  1 -r 10 -c TOSEM_new -t ESAIL_Baseline -u 100 -q 0.1
./scripts/HPC/exec_P2_RS.sh --time 2:00:00 --dependency 2400567 --nick T -m 8 -N 10 --start 11 -r 20 -c TOSEM_new -t ESAIL_Baseline -u 100 -q 0.1
./scripts/HPC/exec_P2_RS.sh --time 2:00:00 --dependency 2400568 --nick T -m 8 -N 10 --start 21 -r 30 -c TOSEM_new -t ESAIL_Baseline -u 100 -q 0.1
./scripts/HPC/exec_P2_RS.sh --time 2:00:00 --dependency 2400569 --nick T -m 8 -N 10 --start 31 -r 40 -c TOSEM_new -t ESAIL_Baseline -u 100 -q 0.1
./scripts/HPC/exec_P2_RS.sh --time 2:00:00 --dependency 2400570 --nick T -m 8 -N 10 --start 41 -r 50 -c TOSEM_new -t ESAIL_Baseline -u 100 -q 0.1

#############################################################################
# Random Search: ADCS (New version: T30 has a small deadline)
#############################################################################
# ADCS Random Phase 1
./scripts/HPC/exec_P1.sh --time 1-15:00:00 --nick T -m 8 -N 10 --start  1 -r 10 -c TOSEM_new -t ADCS_Baseline --data res/industrial_new/ADCS.csv --cpus 1 --max 1800000 --quanta 0.1 --simpleSearch -i 1500
./scripts/HPC/exec_P1.sh --time 1-15:00:00 --nick T -m 8 -N 10 --start 11 -r 20 -c TOSEM_new -t ADCS_Baseline --data res/industrial_new/ADCS.csv --cpus 1 --max 1800000 --quanta 0.1 --simpleSearch -i 1500
./scripts/HPC/exec_P1.sh --time 1-15:00:00 --nick T -m 8 -N 10 --start 21 -r 30 -c TOSEM_new -t ADCS_Baseline --data res/industrial_new/ADCS.csv --cpus 1 --max 1800000 --quanta 0.1 --simpleSearch -i 1500
./scripts/HPC/exec_P1.sh --time 1-15:00:00 --nick T -m 8 -N 10 --start 31 -r 40 -c TOSEM_new -t ADCS_Baseline --data res/industrial_new/ADCS.csv --cpus 1 --max 1800000 --quanta 0.1 --simpleSearch -i 1500
./scripts/HPC/exec_P1.sh --time 1-15:00:00 --nick T -m 8 -N 10 --start 41 -r 50 -c TOSEM_new -t ADCS_Baseline --data res/industrial_new/ADCS.csv --cpus 1 --max 1800000 --quanta 0.1 --simpleSearch -i 1500

# ADCS Random Phase 2
./scripts/HPC/exec_P2_RS.sh --time 2:00:00 --dependency 2400561 --nick T -m 8 -N 10 --start  1 -r 10 -c TOSEM_new -t ADCS_Baseline -u 100 -q 0.1
./scripts/HPC/exec_P2_RS.sh --time 2:00:00 --dependency 2400562 --nick T -m 8 -N 10 --start 11 -r 20 -c TOSEM_new -t ADCS_Baseline -u 100 -q 0.1
./scripts/HPC/exec_P2_RS.sh --time 2:00:00 --dependency 2400563 --nick T -m 8 -N 10 --start 21 -r 30 -c TOSEM_new -t ADCS_Baseline -u 100 -q 0.1
./scripts/HPC/exec_P2_RS.sh --time 2:00:00 --dependency 2400564 --nick T -m 8 -N 10 --start 31 -r 40 -c TOSEM_new -t ADCS_Baseline -u 100 -q 0.1
./scripts/HPC/exec_P2_RS.sh --time 2:00:00 --dependency 2400565 --nick T -m 8 -N 10 --start 41 -r 50 -c TOSEM_new -t ADCS_Baseline -u 100 -q 0.1


#############################################################################
# Round Trip
#############################################################################
# ICS Round trip
./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start  1 -r 10 -c TOSEM_new -t ICS_SAFE     --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start 11 -r 20 -c TOSEM_new -t ICS_SAFE     --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start 21 -r 30 -c TOSEM_new -t ICS_SAFE     --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start 31 -r 40 -c TOSEM_new -t ICS_SAFE     --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start 41 -r 50 -c TOSEM_new -t ICS_SAFE     --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200

./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start  1 -r 10 -c TOSEM_new -t ICS_Baseline --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start 11 -r 20 -c TOSEM_new -t ICS_Baseline --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start 21 -r 30 -c TOSEM_new -t ICS_Baseline --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start 31 -r 40 -c TOSEM_new -t ICS_Baseline --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start 41 -r 50 -c TOSEM_new -t ICS_Baseline --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200

# UAV Round trip
./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start  1 -r 10 -c TOSEM_new -t UAV_SAFE     --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start 11 -r 20 -c TOSEM_new -t UAV_SAFE     --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start 21 -r 30 -c TOSEM_new -t UAV_SAFE     --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start 31 -r 40 -c TOSEM_new -t UAV_SAFE     --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start 41 -r 50 -c TOSEM_new -t UAV_SAFE     --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200

./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start  1 -r 10 -c TOSEM_new -t UAV_Baseline --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start 11 -r 20 -c TOSEM_new -t UAV_Baseline --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start 21 -r 30 -c TOSEM_new -t UAV_Baseline --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start 31 -r 40 -c TOSEM_new -t UAV_Baseline --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start 41 -r 50 -c TOSEM_new -t UAV_Baseline --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200

# Round trip for ADCS
# To reduce execution time, Roundtrip supports partitioning
# TODO: be careful to use this code, from the second partitions, they should be started after the first partition produced the arrivals and WCETs.
PartMAX=5
for ((partID=1; partID<=PartMAX; partID++)); do
	if [ "${partID}" -eq "1" ]; then
		RESUME=''
	else
		RESUME='--resume'
	fi
	./scripts/HPC/exec_P3.sh --time 12:00:00 --nick ${partID} -N 10 --mem 8 --start  1 -r 10 -c TOSEM_new -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 ${RESUME} --partID ${partID} --partMAX ${PartMAX}
	./scripts/HPC/exec_P3.sh --time 12:00:00 --nick ${partID} -N 10 --mem 8 --start 11 -r 20 -c TOSEM_new -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 ${RESUME} --partID ${partID} --partMAX ${PartMAX}
	./scripts/HPC/exec_P3.sh --time 12:00:00 --nick ${partID} -N 10 --mem 8 --start 21 -r 30 -c TOSEM_new -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 ${RESUME} --partID ${partID} --partMAX ${PartMAX}
	./scripts/HPC/exec_P3.sh --time 12:00:00 --nick ${partID} -N 10 --mem 8 --start 31 -r 40 -c TOSEM_new -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 ${RESUME} --partID ${partID} --partMAX ${PartMAX}
	./scripts/HPC/exec_P3.sh --time 12:00:00 --nick ${partID} -N 10 --mem 8 --start 41 -r 50 -c TOSEM_new -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 ${RESUME} --partID ${partID} --partMAX ${PartMAX}
done
# Merge the rt results
~/venv/bin/python3 scripts/tools/MergeTestData.py -f merge_rt_data -b results/TOSEM_new/ADCS_SAFE -p 5


# Below codes are the normal one (it will take over 2 days)
./scripts/HPC/exec_P3.sh --nick T -N 10 --mem 8 --start  1 -r 10 -c TOSEM_new -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume
./scripts/HPC/exec_P3.sh --nick T -N 10 --mem 8 --start 11 -r 20 -c TOSEM_new -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume
./scripts/HPC/exec_P3.sh --nick T -N 10 --mem 8 --start 21 -r 30 -c TOSEM_new -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume
./scripts/HPC/exec_P3.sh --nick T -N 10 --mem 8 --start 31 -r 40 -c TOSEM_new -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume
./scripts/HPC/exec_P3.sh --nick T -N 10 --mem 8 --start 41 -r 50 -c TOSEM_new -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume

./scripts/HPC/exec_P3.sh --nick T -N 10 --mem 8 --start  1 -r 10 -c TOSEM_new -t ADCS_Baseline --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume
./scripts/HPC/exec_P3.sh --nick T -N 10 --mem 8 --start 11 -r 20 -c TOSEM_new -t ADCS_Baseline --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume
./scripts/HPC/exec_P3.sh --nick T -N 10 --mem 8 --start 21 -r 30 -c TOSEM_new -t ADCS_Baseline --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume
./scripts/HPC/exec_P3.sh --nick T -N 10 --mem 8 --start 31 -r 40 -c TOSEM_new -t ADCS_Baseline --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume
./scripts/HPC/exec_P3.sh --nick T -N 10 --mem 8 --start 41 -r 50 -c TOSEM_new -t ADCS_Baseline --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume

# Round trip for ESAIL (will take over 48 hours, need to resume)
./scripts/HPC/exec_P3.sh --nick T -N 10 --mem 8 --start  1 -r 10 -c TOSEM_new -t ESAIL_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume
./scripts/HPC/exec_P3.sh --nick T -N 10 --mem 8 --start 11 -r 20 -c TOSEM_new -t ESAIL_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume
./scripts/HPC/exec_P3.sh --nick T -N 10 --mem 8 --start 21 -r 30 -c TOSEM_new -t ESAIL_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume
./scripts/HPC/exec_P3.sh --nick T -N 10 --mem 8 --start 31 -r 40 -c TOSEM_new -t ESAIL_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume
./scripts/HPC/exec_P3.sh --nick T -N 10 --mem 8 --start 41 -r 50 -c TOSEM_new -t ESAIL_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume

./scripts/HPC/exec_P3.sh --nick T -N 10 --mem 8 --start  1 -r 10 -c TOSEM_new -t ESAIL_Baseline --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume
./scripts/HPC/exec_P3.sh --nick T -N 10 --mem 8 --start 11 -r 20 -c TOSEM_new -t ESAIL_Baseline --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume
./scripts/HPC/exec_P3.sh --nick T -N 10 --mem 8 --start 21 -r 30 -c TOSEM_new -t ESAIL_Baseline --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume
./scripts/HPC/exec_P3.sh --nick T -N 10 --mem 8 --start 31 -r 40 -c TOSEM_new -t ESAIL_Baseline --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume
./scripts/HPC/exec_P3.sh --nick T -N 10 --mem 8 --start 41 -r 50 -c TOSEM_new -t ESAIL_Baseline --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume


# Check validity of the round trip results (The commands show the number of results)
~/venv/bin/python3 scripts/tools/checkTestData.py -b results/TOSEM_new/ESAIL_SAFE -f check_roundtrip -t _roundtrip/result.csv
~/venv/bin/python3 scripts/tools/checkTestData.py -b results/TOSEM_new/ADCS_SAFE -f check_roundtrip -t _roundtrip/result.csv
~/venv/bin/python3 scripts/tools/checkTestData.py -b results/TOSEM_new/ESAIL_Baseline -f check_roundtrip -t _roundtrip/result.csv
~/venv/bin/python3 scripts/tools/checkTestData.py -b results/TOSEM_new/ADCS_Baseline -f check_roundtrip -t _roundtrip/result.csv


########################################################################
# Collecting RQ1 results
########################################################################
# Collecting results of P1
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_new/ICS_SAFE   -o results/TOSEM_new/_analysis/EXP1/P1_ICS_SAFE.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_new/ICS_Baseline -o results/TOSEM_new/_analysis/EXP1/P1_ICS_Baseline.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_new/UAV_SAFE   -o results/TOSEM_new/_analysis/EXP1/P1_UAV_SAFE.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_new/UAV_Baseline -o results/TOSEM_new/_analysis/EXP1/P1_UAV_Baseline.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_new/ADCS_SAFE   -o results/TOSEM_new/_analysis/EXP1/P1_ADCS_SAFE.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_new/ADCS_Baseline -o results/TOSEM_new/_analysis/EXP1/P1_ADCS_Baseline.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_new/ESAIL_SAFE   -o results/TOSEM_new/_analysis/EXP1/P1_ESAIL_SAFE.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_new/ESAIL_Baseline -o results/TOSEM_new/_analysis/EXP1/P1_ESAIL_Baseline.csv

# Collecting results phase 2
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_model -b results/TOSEM_new/ICS_SAFE -o results/TOSEM_new/_analysis/EXP1/P2_ICS_SAFE.csv -q 0.01
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_model -b results/TOSEM_new/UAV_SAFE -o results/TOSEM_new/_analysis/EXP1/P2_UAV_SAFE.csv -q 0.01
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_model -b results/TOSEM_new/ESAIL_SAFE -o results/TOSEM_new/_analysis/EXP1/P2_ESAIL_SAFE.csv -q 0.1
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_model -b results/TOSEM_new/ADCS_SAFE -o results/TOSEM_new/_analysis/EXP1/P2_ADCS_SAFE.csv -q 0.1

~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_model -b results/TOSEM_new/ICS_Baseline -o results/TOSEM_new/_analysis/EXP1/P2_ICS_Baseline.csv -q 0.01
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_model -b results/TOSEM_new/UAV_Baseline -o results/TOSEM_new/_analysis/EXP1/P2_UAV_Baseline.csv -q 0.01
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_model -b results/TOSEM_new/ESAIL_Baseline -o results/TOSEM_new/_analysis/EXP1/P2_ESAIL_Baseline.csv -q 0.1
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_model -b results/TOSEM_new/ADCS_Baseline -o results/TOSEM_new/_analysis/EXP1/P2_ADCS_Baseline.csv -q 0.1

# collecting RT results
~/venv/bin/python3 scripts/tools/RoundTripCollector.py -f merge_roundtrip_subject -b results/TOSEM_new/ICS_SAFE   -o results/TOSEM_new/_analysis/EXP1/RT_ICS_SAFE.csv     -t _roundtrip
~/venv/bin/python3 scripts/tools/RoundTripCollector.py -f merge_roundtrip_subject -b results/TOSEM_new/ICS_Baseline -o results/TOSEM_new/_analysis/EXP1/RT_ICS_Baseline.csv -t _roundtrip
~/venv/bin/python3 scripts/tools/RoundTripCollector.py -f merge_roundtrip_subject -b results/TOSEM_new/UAV_SAFE   -o results/TOSEM_new/_analysis/EXP1/RT_UAV_SAFE.csv     -t _roundtrip
~/venv/bin/python3 scripts/tools/RoundTripCollector.py -f merge_roundtrip_subject -b results/TOSEM_new/UAV_Baseline -o results/TOSEM_new/_analysis/EXP1/RT_UAV_Baseline.csv -t _roundtrip

~/venv/bin/python3 scripts/tools/RoundTripCollector.py -f merge_roundtrip_subject -b results/TOSEM_new/ADCS_SAFE   -o results/TOSEM_new/_analysis/EXP1/RT_ADCS_SAFE.csv     -t _roundtrip
~/venv/bin/python3 scripts/tools/RoundTripCollector.py -f merge_roundtrip_subject -b results/TOSEM_new/ADCS_Baseline -o results/TOSEM_new/_analysis/EXP1/RT_ADCS_Baseline.csv -t _roundtrip
~/venv/bin/python3 scripts/tools/RoundTripCollector.py -f merge_roundtrip_subject -b results/TOSEM_new/ESAIL_SAFE   -o results/TOSEM_new/_analysis/EXP1/RT_ESAIL_SAFE.csv     -t _roundtrip
~/venv/bin/python3 scripts/tools/RoundTripCollector.py -f merge_roundtrip_subject -b results/TOSEM_new/ESAIL_Baseline -o results/TOSEM_new/_analysis/EXP1/RT_ESAIL_Baseline.csv -t _roundtrip


# RQ3 results ( This data from the RQ1 results)
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM_new/ICS_SAFE -o results/TOSEM_new/_analysis/EXP3/kfold_ICS_SAFE.csv -t _phase2/workdata_termination_result.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM_new/UAV_SAFE -o results/TOSEM_new/_analysis/EXP3/kfold_UAV_SAFE.csv -t _phase2/workdata_termination_result.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM_new/ESAIL_SAFE -o results/TOSEM_new/_analysis/EXP3/kfold_ESAIL_SAFE.csv -t _phase2/workdata_termination_result.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM_new/ADCS_SAFE -o results/TOSEM_new/_analysis/EXP3/kfold_ADCS_SAFE.csv -t _phase2/workdata_termination_result.csv


# Draw graphs
# Param1: base working directory
# Param2: List of subjects with a comma(,) separated (e.g., ADCS,ICS,UAV)
Rscript scripts/graphs/DrawingBestSize.R results/TOSEM_new/_analysis/EXP1 ADCS,ESAIL,ICS,UAV
Rscript scripts/graphs/DrawingRoundTrip.R results/TOSEM_new/_analysis/EXP1 ADCS,ESAIL,ICS,UAV
Rscript scripts/graphs/DrawingProbability.R results/TOSEM_new/_analysis/EXP1 ADCS,ESAIL,ICS,UAV
Rscript scripts/graphs/DrawingExecTime.R results/TOSEM_new/_analysis/EXP1 ADCS,ESAIL,ICS,UAV

Rscript scripts/graphs/DrawingRQ3.R results/TOSEM_new/_analysis/EXP3 ADCS,ESAIL,ICS,UAV

Rscript scripts/graphs/DrawingTable.R results/TOSEM_mix/_analysis4/EXP1 ADCS,ICS,UAV

