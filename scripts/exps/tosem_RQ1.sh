#!/bin/bash -l
# This scripts should be executed on the project root folder
# All artifacts and R scripts should be executed in the project root folder.

#############################################################################
# SAFE Execution
#############################################################################
# ICS - Phase 1
./scripts/HPC/exec_P1.sh --time 01:00:00 -m 8 -N 10 -r 50 -c TOSEM -t ICS_SAFE --data res/industrial/ICS_20a.csv --cpus 3 --quanta 0.01 --max 0

# ICS - Phase 2
./scripts/HPC/exec_P2.sh --time 2:00:00 -m 8 -N 10 --start  1 -r 10 -c TOSEM -t ICS_SAFE  --cpus 3 --max 0 --quanta 0.01 --preFeatures --prePrune
./scripts/HPC/exec_P2.sh --time 2:00:00 -m 8 -N 10 --start 11 -r 20 -c TOSEM -t ICS_SAFE  --cpus 3 --max 0 --quanta 0.01 --preFeatures --prePrune
./scripts/HPC/exec_P2.sh --time 2:00:00 -m 8 -N 10 --start 21 -r 30 -c TOSEM -t ICS_SAFE  --cpus 3 --max 0 --quanta 0.01 --preFeatures --prePrune
./scripts/HPC/exec_P2.sh --time 2:00:00 -m 8 -N 10 --start 31 -r 40 -c TOSEM -t ICS_SAFE  --cpus 3 --max 0 --quanta 0.01 --preFeatures --prePrune
./scripts/HPC/exec_P2.sh --time 2:00:00 -m 8 -N 10 --start 41 -r 50 -c TOSEM -t ICS_SAFE  --cpus 3 --max 0 --quanta 0.01 --preFeatures --prePrune

# UAV - Phase 1
./scripts/HPC/exec_P1.sh --time 02:00:00 -m 8 -N 10 -r 50 -c TOSEM -t UAV_SAFE --data res/industrial/UAV_50a.csv --cpus 3 --quanta 0.01 --max 0
# UAV - Phase 2
./scripts/HPC/exec_P2.sh --time 2:00:00 -m 8 -N 10 --start  1 -r 10 -c TOSEM -t UAV_SAFE  --cpus 3 --max 0 --quanta 0.01 --preFeatures --prePrune
./scripts/HPC/exec_P2.sh --time 2:00:00 -m 8 -N 10 --start 11 -r 20 -c TOSEM -t UAV_SAFE  --cpus 3 --max 0 --quanta 0.01 --preFeatures --prePrune
./scripts/HPC/exec_P2.sh --time 2:00:00 -m 8 -N 10 --start 21 -r 30 -c TOSEM -t UAV_SAFE  --cpus 3 --max 0 --quanta 0.01 --preFeatures --prePrune
./scripts/HPC/exec_P2.sh --time 2:00:00 -m 8 -N 10 --start 31 -r 40 -c TOSEM -t UAV_SAFE  --cpus 3 --max 0 --quanta 0.01 --preFeatures --prePrune
./scripts/HPC/exec_P2.sh --time 2:00:00 -m 8 -N 10 --start 41 -r 50 -c TOSEM -t UAV_SAFE  --cpus 3 --max 0 --quanta 0.01 --preFeatures --prePrune

# ADCS Phase 1 (T30 Large dealine)
./scripts/HPC/exec_P1.sh --time 1-15:00:00 -m 8 -N 10 --start  1 -r 10 -c TOSEM -t ADCS_SAFE --data res/industrial/ADCS.csv --cpus 1 --max 1800000 --quanta 0.1
./scripts/HPC/exec_P1.sh --time 1-15:00:00 -m 8 -N 10 --start 11 -r 20 -c TOSEM -t ADCS_SAFE --data res/industrial/ADCS.csv --cpus 1 --max 1800000 --quanta 0.1
./scripts/HPC/exec_P1.sh --time 1-15:00:00 -m 8 -N 10 --start 21 -r 30 -c TOSEM -t ADCS_SAFE --data res/industrial/ADCS.csv --cpus 1 --max 1800000 --quanta 0.1
./scripts/HPC/exec_P1.sh --time 1-15:00:00 -m 8 -N 10 --start 31 -r 40 -c TOSEM -t ADCS_SAFE --data res/industrial/ADCS.csv --cpus 1 --max 1800000 --quanta 0.1
./scripts/HPC/exec_P1.sh --time 1-15:00:00 -m 8 -N 10 --start 41 -r 50 -c TOSEM -t ADCS_SAFE --data res/industrial/ADCS.csv --cpus 1 --max 1800000 --quanta 0.1

# ADCS Phase 2
./scripts/HPC/exec_P2.sh --time 1-10:00:00 -m 8 -N 10 --start  1 -r 10 -c TOSEM -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --prePrune --preFeatures
./scripts/HPC/exec_P2.sh --time 1-10:00:00 -m 8 -N 10 --start 11 -r 20 -c TOSEM -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --prePrune --preFeatures
./scripts/HPC/exec_P2.sh --time 1-10:00:00 -m 8 -N 10 --start 21 -r 30 -c TOSEM -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --prePrune --preFeatures
./scripts/HPC/exec_P2.sh --time 1-10:00:00 -m 8 -N 10 --start 31 -r 40 -c TOSEM -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --prePrune --preFeatures
./scripts/HPC/exec_P2.sh --time 1-10:00:00 -m 8 -N 10 --start 41 -r 50 -c TOSEM -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --prePrune --preFeatures

#############################################################################
# Random Search
#############################################################################
# Phase 1
./scripts/HPC/exec_P1.sh --time 01:00:00 -m 8 -N 10 -r 50 -c TOSEM -t ICS_Baseline --data res/industrial/ICS_20a.csv --cpus 3 --quanta 0.01 --simpleSearch -i 1500
./scripts/HPC/exec_P1.sh --time 02:00:00 -m 8 -N 10 -r 50 -c TOSEM -t UAV_Baseline --data res/industrial/UAV_50a.csv --cpus 3 --quanta 0.01 --simpleSearch -i 1500

# Phase 2 - Best Size calculate (Phase2 for Random Search, Taking long time)
./scripts/HPC/exec_P2_RS.sh --time 5:00:00 -m 8 -N 10 -r 50 -c TOSEM -t ICS_Baseline -q 0.01
./scripts/HPC/exec_P2_RS.sh --time 5:00:00 -m 8 -N 10 -r 50 -c TOSEM -t UAV_Baseline -q 0.01

# ADCS Random Phase 1
./scripts/HPC/exec_P1.sh --time 2-00:00:00 -m 8 -N 10 --start  1 -r 10 -c TOSEM -t ADCS_Baseline --data res/industrial/ADCS.csv --cpus 1 --max 1800000 --quanta 0.1 --simpleSearch -i 1500
./scripts/HPC/exec_P1.sh --time 2-00:00:00 -m 8 -N 10 --start 11 -r 20 -c TOSEM -t ADCS_Baseline --data res/industrial/ADCS.csv --cpus 1 --max 1800000 --quanta 0.1 --simpleSearch -i 1500
./scripts/HPC/exec_P1.sh --time 2-00:00:00 -m 8 -N 10 --start 21 -r 30 -c TOSEM -t ADCS_Baseline --data res/industrial/ADCS.csv --cpus 1 --max 1800000 --quanta 0.1 --simpleSearch -i 1500
./scripts/HPC/exec_P1.sh --time 2-00:00:00 -m 8 -N 10 --start 31 -r 40 -c TOSEM -t ADCS_Baseline --data res/industrial/ADCS.csv --cpus 1 --max 1800000 --quanta 0.1 --simpleSearch -i 1500
./scripts/HPC/exec_P1.sh --time 2-00:00:00 -m 8 -N 10 --start 41 -r 50 -c TOSEM -t ADCS_Baseline --data res/industrial/ADCS.csv --cpus 1 --max 1800000 --quanta 0.1 --simpleSearch -i 1500

# ADCS Random Phase 2
./scripts/HPC/exec_P2_RS.sh --time 2:00:00 -m 8 -N 10 --start  1 -r 10 -c TOSEM -t ADCS_Baseline -q 0.1
./scripts/HPC/exec_P2_RS.sh --time 2:00:00 -m 8 -N 10 --start 11 -r 20 -c TOSEM -t ADCS_Baseline -q 0.1
./scripts/HPC/exec_P2_RS.sh --time 2:00:00 -m 8 -N 10 --start 21 -r 30 -c TOSEM -t ADCS_Baseline -q 0.1
./scripts/HPC/exec_P2_RS.sh --time 2:00:00 -m 8 -N 10 --start 31 -r 40 -c TOSEM -t ADCS_Baseline -q 0.1
./scripts/HPC/exec_P2_RS.sh --time 2:00:00 -m 8 -N 10 --start 41 -r 50 -c TOSEM -t ADCS_Baseline -q 0.1


#############################################################################
# round Trip
#############################################################################
# ICS Round trip
./scripts/HPC/exec_P3.sh --time 1:00:00 --dependency 2400499 -m 8 -N 10 --start  1 -r 10 -c TOSEM -t ICS_SAFE   --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --dependency 2400500 -m 8 -N 10 --start 11 -r 20 -c TOSEM -t ICS_SAFE   --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --dependency 2400501 -m 8 -N 10 --start 21 -r 30 -c TOSEM -t ICS_SAFE   --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --dependency 2400502 -m 8 -N 10 --start 31 -r 40 -c TOSEM -t ICS_SAFE   --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --dependency 2400503 -m 8 -N 10 --start 41 -r 50 -c TOSEM -t ICS_SAFE   --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200

./scripts/HPC/exec_P3.sh --time 1:00:00 --dependency 2400512 -m 8 -N 10 --start  1 -r 10 -c TOSEM -t ICS_Baseline   --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --dependency 2400512 -m 8 -N 10 --start 11 -r 20 -c TOSEM -t ICS_Baseline   --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --dependency 2400512 -m 8 -N 10 --start 21 -r 30 -c TOSEM -t ICS_Baseline   --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --dependency 2400512 -m 8 -N 10 --start 31 -r 40 -c TOSEM -t ICS_Baseline   --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --dependency 2400512 -m 8 -N 10 --start 41 -r 50 -c TOSEM -t ICS_Baseline   --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200

# UAV Round trip
./scripts/HPC/exec_P3.sh --time 1:00:00 --dependency 2400514 -m 8 -N 10 --start  1 -r 10 -c TOSEM -t UAV_SAFE   --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --dependency 2400515 -m 8 -N 10 --start 11 -r 20 -c TOSEM -t UAV_SAFE   --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --dependency 2400516 -m 8 -N 10 --start 21 -r 30 -c TOSEM -t UAV_SAFE   --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --dependency 2400517 -m 8 -N 10 --start 31 -r 40 -c TOSEM -t UAV_SAFE   --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --dependency 2400518 -m 8 -N 10 --start 41 -r 50 -c TOSEM -t UAV_SAFE   --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200

./scripts/HPC/exec_P3.sh --time 1:00:00 --dependency 2400513 -m 8 -N 10 --start  1 -r 10 -c TOSEM -t UAV_Baseline --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --dependency 2400513 -m 8 -N 10 --start 11 -r 20 -c TOSEM -t UAV_Baseline --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --dependency 2400513 -m 8 -N 10 --start 21 -r 30 -c TOSEM -t UAV_Baseline --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --dependency 2400513 -m 8 -N 10 --start 31 -r 40 -c TOSEM -t UAV_Baseline --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --dependency 2400513 -m 8 -N 10 --start 41 -r 50 -c TOSEM -t UAV_Baseline --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200

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
	./scripts/HPC/exec_P3.sh --time 12:00:00 --nick ${partID} -N 10 --mem 8 --start  1 -r 10 -c TOSEM -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 ${RESUME} --partID ${partID} --partMAX ${PartMAX}
	./scripts/HPC/exec_P3.sh --time 12:00:00 --nick ${partID} -N 10 --mem 8 --start 11 -r 20 -c TOSEM -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 ${RESUME} --partID ${partID} --partMAX ${PartMAX}
	./scripts/HPC/exec_P3.sh --time 12:00:00 --nick ${partID} -N 10 --mem 8 --start 21 -r 30 -c TOSEM -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 ${RESUME} --partID ${partID} --partMAX ${PartMAX}
	./scripts/HPC/exec_P3.sh --time 12:00:00 --nick ${partID} -N 10 --mem 8 --start 31 -r 40 -c TOSEM -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 ${RESUME} --partID ${partID} --partMAX ${PartMAX}
	./scripts/HPC/exec_P3.sh --time 12:00:00 --nick ${partID} -N 10 --mem 8 --start 41 -r 50 -c TOSEM -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 ${RESUME} --partID ${partID} --partMAX ${PartMAX}
done


# Round trip for ADCS (Normal parallel work, it will take over 48 hours)
./scripts/HPC/exec_P3.sh -N 10 --mem 8 --start  1 -r 10 -c TOSEM -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume
./scripts/HPC/exec_P3.sh -N 10 --mem 8 --start 11 -r 20 -c TOSEM -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume
./scripts/HPC/exec_P3.sh -N 10 --mem 8 --start 21 -r 30 -c TOSEM -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume
./scripts/HPC/exec_P3.sh -N 10 --mem 8 --start 31 -r 40 -c TOSEM -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume
./scripts/HPC/exec_P3.sh -N 10 --mem 8 --start 41 -r 50 -c TOSEM -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume

./scripts/HPC/exec_P3.sh -N 10 --mem 8 --start  1 -r 10 -c TOSEM -t ADCS_Baseline --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume
./scripts/HPC/exec_P3.sh -N 10 --mem 8 --start 11 -r 20 -c TOSEM -t ADCS_Baseline --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume
./scripts/HPC/exec_P3.sh -N 10 --mem 8 --start 21 -r 30 -c TOSEM -t ADCS_Baseline --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume
./scripts/HPC/exec_P3.sh -N 10 --mem 8 --start 31 -r 40 -c TOSEM -t ADCS_Baseline --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume
./scripts/HPC/exec_P3.sh -N 10 --mem 8 --start 41 -r 50 -c TOSEM -t ADCS_Baseline --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume

## resume example (set --resume over 1)
#./scripts/HPC/exec_P3.sh --nick mix -N 10 --mem 8 --list 09,12 -c TOSEM -t ADCS_Baseline --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume
#./scripts/HPC/exec_P3.sh --nick mix -N 10 --mem 8 --list 09,12 -c TOSEM -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume



# Check validity of the round trip results (The commands show the number of results)
~/venv/bin/python3 scripts/tools/checkTestData.py -b results/TOSEM/ADCS_SAFE -f check_roundtrip -t _roundtrip/result.csv
~/venv/bin/python3 scripts/tools/checkTestData.py -b results/TOSEM/ADCS_Baseline -f check_roundtrip -t _roundtrip/result.csv


########################################################################
# Collecting RQ1 results
########################################################################
# Collecting results of P1
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM/ICS_SAFE   -o results/TOSEM/_analysis/EXP1/P1_ICS_SAFE.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM/ICS_Baseline -o results/TOSEM/_analysis/EXP1/P1_ICS_Baseline.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM/UAV_SAFE   -o results/TOSEM/_analysis/EXP1/P1_UAV_SAFE.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM/UAV_Baseline -o results/TOSEM/_analysis/EXP1/P1_UAV_Baseline.csv

# Collecting results phase 2
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_model -b results/TOSEM/ICS_SAFE -o results/TOSEM/_analysis/EXP1/P2_ICS_SAFE.csv -q 0.01
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_model -b results/TOSEM/UAV_SAFE -o results/TOSEM/_analysis/EXP1/P2_UAV_SAFE.csv -q 0.01
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_model -b results/TOSEM/ADCS_SAFE -o results/TOSEM/_analysis/EXP1/P2_ADCS_SAFE.csv -q 0.1
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_model -b results/TOSEM/ICS_Baseline -o results/TOSEM/_analysis/EXP1/P2_ICS_Baseline.csv -q 0.01
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_model -b results/TOSEM/UAV_Baseline -o results/TOSEM/_analysis/EXP1/P2_UAV_Baseline.csv -q 0.01
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_model -b results/TOSEM/ADCS_Baseline -o results/TOSEM/_analysis/EXP1/P2_ADCS_Baseline.csv -q 0.1


# collecting RT results
~/venv/bin/python3 scripts/tools/RoundTripCollector.py -f merge_roundtrip_subject -b results/TOSEM/ICS_SAFE   -o results/TOSEM/_analysis/EXP1/RT_ICS_SAFE.csv     -t _roundtrip
~/venv/bin/python3 scripts/tools/RoundTripCollector.py -f merge_roundtrip_subject -b results/TOSEM/ICS_Baseline -o results/TOSEM/_analysis/EXP1/RT_ICS_Baseline.csv -t _roundtrip
~/venv/bin/python3 scripts/tools/RoundTripCollector.py -f merge_roundtrip_subject -b results/TOSEM/UAV_SAFE   -o results/TOSEM/_analysis/EXP1/RT_UAV_SAFE.csv     -t _roundtrip
~/venv/bin/python3 scripts/tools/RoundTripCollector.py -f merge_roundtrip_subject -b results/TOSEM/UAV_Baseline -o results/TOSEM/_analysis/EXP1/RT_UAV_Baseline.csv -t _roundtrip
~/venv/bin/python3 scripts/tools/RoundTripCollector.py -f merge_roundtrip_subject -b results/TOSEM/ADCS_SAFE   -o results/TOSEM/_analysis/EXP1/RT_ADCS_SAFE.csv     -t _roundtrip
~/venv/bin/python3 scripts/tools/RoundTripCollector.py -f merge_roundtrip_subject -b results/TOSEM/ADCS_Baseline -o results/TOSEM/_analysis/EXP1/RT_ADCS_Baseline.csv -t _roundtrip


# RQ3 results ( This data from the RQ1 results)
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM/ICS_SAFE -o results/TOSEM/_analysis/EXP3/kfold_ICS_SAFE.csv -t _phase2/workdata_termination_result.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM/UAV_SAFE -o results/TOSEM/_analysis/EXP3/kfold_UAV_SAFE.csv -t _phase2/workdata_termination_result.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM/ADCS_SAFE -o results/TOSEM/_analysis/EXP3/kfold_ADCS_SAFE.csv -t _phase2/workdata_termination_result.csv


# Draw graphs
# Param1: base working directory
# Param2: List of subjects with a comma(,) separated (e.g., ADCS,ICS,UAV)
Rscript scripts/graphs/DrawingBestSize.R results/TOSEM/_analysis/EXP1 ADCS,ICS,UAV
Rscript scripts/graphs/DrawingRoundTrip.R results/TOSEM/_analysis/EXP1 ADCS,ICS,UAV
Rscript scripts/graphs/DrawingProbability.R results/TOSEM/_analysis/EXP1 ADCS,ICS,UAV

Rscript scripts/graphs/DrawingExecTime.R results/TOSEM/_analysis/EXP1 ADCS,ICS,UAV
Rscript scripts/graphs/DrawingRQ3.R results/TOSEM/_analysis/EXP3 ADCS,ICS,UAV


