#!/bin/bash -l
# This scripts should be executed on the project root folder
# All artifacts and R scripts should be executed in the project root folder.

#############################################################################
# Test case Generation
#############################################################################
# ICS
./scripts/HPC/exec_TG.sh --time 1:00:00 -m 4 -N 5 --start  1 -r 10 -c TOSEM -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 --nTest 50000
./scripts/HPC/exec_TG.sh --time 1:00:00 -m 4 -N 5 --start 11 -r 20 -c TOSEM -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 --nTest 50000
./scripts/HPC/exec_TG.sh --time 1:00:00 -m 4 -N 5 --start 21 -r 30 -c TOSEM -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 --nTest 50000
./scripts/HPC/exec_TG.sh --time 1:00:00 -m 4 -N 5 --start 31 -r 40 -c TOSEM -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 --nTest 50000
./scripts/HPC/exec_TG.sh --time 1:00:00 -m 4 -N 5 --start 41 -r 50 -c TOSEM -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 --nTest 50000

#UAV
./scripts/HPC/exec_TG.sh --time 3:00:00 -m 4 -N 5 --start   1 -r 10 -c TOSEM -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 --nTest 50000
./scripts/HPC/exec_TG.sh --time 3:00:00 -m 4 -N 5 --start  11 -r 20 -c TOSEM -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 --nTest 50000
./scripts/HPC/exec_TG.sh --time 3:00:00 -m 4 -N 5 --start  21 -r 30 -c TOSEM -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 --nTest 50000
./scripts/HPC/exec_TG.sh --time 3:00:00 -m 4 -N 5 --start  31 -r 40 -c TOSEM -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 --nTest 50000
./scripts/HPC/exec_TG.sh --time 3:00:00 -m 4 -N 5 --start  41 -r 50 -c TOSEM -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 --nTest 50000

#ADCS (It requires total 50 hours, I generate it with 5 partitions and merge) // 12 hours
for ((runID=1; runID<=5; runID++)); do
	./scripts/HPC/exec_TG.sh --time 15:00:00 --nick mix${runID} -m 8 -N 10 --start   1 -r 10 -c TOSEM -t ADCS_SAFE --runID ${runID} --cpus 1 --max 1800000 --quanta 0.1 --nTest 10000
	./scripts/HPC/exec_TG.sh --time 15:00:00 --nick mix${runID} -m 8 -N 10 --start  11 -r 20 -c TOSEM -t ADCS_SAFE --runID ${runID} --cpus 1 --max 1800000 --quanta 0.1 --nTest 10000
	./scripts/HPC/exec_TG.sh --time 15:00:00 --nick mix${runID} -m 8 -N 10 --start  21 -r 30 -c TOSEM -t ADCS_SAFE --runID ${runID} --cpus 1 --max 1800000 --quanta 0.1 --nTest 10000
	./scripts/HPC/exec_TG.sh --time 15:00:00 --nick mix${runID} -m 8 -N 10 --start  31 -r 40 -c TOSEM -t ADCS_SAFE --runID ${runID} --cpus 1 --max 1800000 --quanta 0.1 --nTest 10000
	./scripts/HPC/exec_TG.sh --time 15:00:00 --nick mix${runID} -m 8 -N 10 --start  41 -r 50 -c TOSEM -t ADCS_SAFE --runID ${runID} --cpus 1 --max 1800000 --quanta 0.1 --nTest 10000
done

# Merge the test data results
~/venv/bin/python3 scripts/results/MergeTestData.py -b results/TOSEM/ADCS_SAFE -p 5

# Check the number of tastdata
~/venv/bin/python3 scripts/results/checkTestData.py -b results/TOSEM/ICS_SAFE -f check_testdata
~/venv/bin/python3 scripts/results/checkTestData.py -b results/TOSEM/UAV_SAFE -f check_testdata
~/venv/bin/python3 scripts/results/checkTestData.py -b results/TOSEM/ADCS_SAFE -f check_testdata


#############################################################################
# Phase 2 (Run Phase 2 for each run of Phase1)
#############################################################################
#ICS
./scripts/HPC/exec_P2.sh --time 01:00:00 --nick R -m 4 -N 10 --start  1 -r 10 -c TOSEM -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 01:00:00 --nick R -m 4 -N 10 --start 11 -r 20 -c TOSEM -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 01:00:00 --nick R -m 4 -N 10 --start 21 -r 30 -c TOSEM -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 01:00:00 --nick R -m 4 -N 10 --start 31 -r 40 -c TOSEM -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 01:00:00 --nick R -m 4 -N 10 --start 41 -r 50 -c TOSEM -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples

./scripts/HPC/exec_P2.sh --time 01:00:00 --nick D -m 4 -N 10 --start  1 -r 10 -c TOSEM -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _dist --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 01:00:00 --nick D -m 4 -N 10 --start 11 -r 20 -c TOSEM -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _dist --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 01:00:00 --nick D -m 4 -N 10 --start 21 -r 30 -c TOSEM -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _dist --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 01:00:00 --nick D -m 4 -N 10 --start 31 -r 40 -c TOSEM -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _dist --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 01:00:00 --nick D -m 4 -N 10 --start 41 -r 50 -c TOSEM -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _dist --useTest --removeSamples

#UAV
./scripts/HPC/exec_P2.sh --time 02:00:00 --nick R -m 4 -N 10 --start  1 -r 10 -c TOSEM -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 02:00:00 --nick R -m 4 -N 10 --start 11 -r 20 -c TOSEM -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 02:00:00 --nick R -m 4 -N 10 --start 21 -r 30 -c TOSEM -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 02:00:00 --nick R -m 4 -N 10 --start 31 -r 40 -c TOSEM -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 02:00:00 --nick R -m 4 -N 10 --start 41 -r 50 -c TOSEM -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples

./scripts/HPC/exec_P2.sh --time 02:00:00 --nick D -m 4 -N 10 --start  1 -r 10 -c TOSEM -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _dist --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 02:00:00 --nick D -m 4 -N 10 --start 11 -r 20 -c TOSEM -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _dist --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 02:00:00 --nick D -m 4 -N 10 --start 21 -r 30 -c TOSEM -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _dist --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 02:00:00 --nick D -m 4 -N 10 --start 31 -r 40 -c TOSEM -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _dist --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 02:00:00 --nick D -m 4 -N 10 --start 41 -r 50 -c TOSEM -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _dist --useTest --removeSamples

#ADCS
./scripts/HPC/exec_P2.sh --time 15:00:00 --nick R -m 8 -N 10 --start  1 -r 10 -c TOSEM -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 15:00:00 --nick R -m 8 -N 10 --start 11 -r 20 -c TOSEM -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 15:00:00 --nick R -m 8 -N 10 --start 21 -r 30 -c TOSEM -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 15:00:00 --nick R -m 8 -N 10 --start 31 -r 40 -c TOSEM -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 15:00:00 --nick R -m 8 -N 10 --start 41 -r 50 -c TOSEM -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples

./scripts/HPC/exec_P2.sh --time 15:00:00 --nick D -m 8 -N 10 --start  1 -r 10 -c TOSEM -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _dist --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 15:00:00 --nick D -m 8 -N 10 --start 11 -r 20 -c TOSEM -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _dist --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 15:00:00 --nick D -m 8 -N 10 --start 21 -r 30 -c TOSEM -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _dist --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 15:00:00 --nick D -m 8 -N 10 --start 31 -r 40 -c TOSEM -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _dist --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 15:00:00 --nick D -m 8 -N 10 --start 41 -r 50 -c TOSEM -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _dist --useTest --removeSamples

#script for error of Phase 2
#./scripts/HPC/exec_P2.sh --time 15:00:00 --nick mixR -m 8 -N 4 --list 34,43,45,48 -c TOSEM -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _results -w2 _random2 --samplingMethod random --useTest --removeSamples
#./scripts/HPC/exec_P2.sh --nick DIST   -m 12 -N 1 --list 16 -c TOSEM -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _results -w2 _dist --useTest
#./scripts/HPC/exec_P2.sh --nick RANDOM -m 12 -N 5 --list 4,9,10,15,13,20,21,22,26,25 -c TOSEM -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _results -w2 _random --samplingMethod random --useTest

########################################################################
# collecting results
########################################################################
# RQ2 results
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM/ICS_SAFE -o results/TOSEM/_analysis/EXP2/test_ICS_random.csv -t _random/workdata_test_result.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM/ICS_SAFE -o results/TOSEM/_analysis/EXP2/test_ICS_dist.csv -t _dist/workdata_test_result.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM/UAV_SAFE -o results/TOSEM/_analysis/EXP2/test_UAV_random.csv -t _random/workdata_test_result.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM/UAV_SAFE -o results/TOSEM/_analysis/EXP2/test_UAV_dist.csv -t _dist/workdata_test_result.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM/ADCS_SAFE -o results/TOSEM/_analysis/EXP2/test_ADCS_random.csv -t _random/workdata_test_result.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM/ADCS_SAFE -o results/TOSEM/_analysis/EXP2/test_ADCS_dist.csv -t _dist/workdata_test_result.csv

# collect RQ2 execution information
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM/ICS_SAFE -o results/TOSEM/_analysis/EXP2/exec_ICS_dist.csv -t _dist/result2.txt
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM/ICS_SAFE -o results/TOSEM/_analysis/EXP2/exec_ICS_random.csv -t _random/result2.txt
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM/UAV_SAFE -o results/TOSEM/_analysis/EXP2/exec_UAV_dist.csv -t _dist/result2.txt
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM/UAV_SAFE -o results/TOSEM/_analysis/EXP2/exec_UAV_random.csv -t _random/result2.txt
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM/ADCS_SAFE -o results/TOSEM/_analysis/EXP2/exec_ADCS_dist.csv -t _dist/result2.txt
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM/ADCS_SAFE -o results/TOSEM/_analysis/EXP2/exec_ADCS_random.csv -t _random/result2.txt
