#!/bin/bash -l
# This scripts should be executed on the project root folder
# All artifacts and R scripts should be executed in the project root folder.

#############################################################################
# Generate test cases (ICS and UAV)
#############################################################################
# ICS
./scripts/HPC/exec_TG.sh --time 1:00:00 --nick T -m 8 -N 5 --start  1 -r 10 -c TOSEM_new -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 --nTest 50000
./scripts/HPC/exec_TG.sh --time 1:00:00 --nick T -m 8 -N 5 --start 11 -r 20 -c TOSEM_new -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 --nTest 50000
./scripts/HPC/exec_TG.sh --time 1:00:00 --nick T -m 8 -N 5 --start 21 -r 30 -c TOSEM_new -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 --nTest 50000
./scripts/HPC/exec_TG.sh --time 1:00:00 --nick T -m 8 -N 5 --start 31 -r 40 -c TOSEM_new -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 --nTest 50000
./scripts/HPC/exec_TG.sh --time 1:00:00 --nick T -m 8 -N 5 --start 41 -r 50 -c TOSEM_new -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 --nTest 50000

#UAV
./scripts/HPC/exec_TG.sh --time 3:00:00 --nick T -m 8 -N 5 --start   1 -r 10 -c TOSEM_new -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 --nTest 50000
./scripts/HPC/exec_TG.sh --time 3:00:00 --nick T -m 8 -N 5 --start  11 -r 20 -c TOSEM_new -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 --nTest 50000
./scripts/HPC/exec_TG.sh --time 3:00:00 --nick T -m 8 -N 5 --start  21 -r 30 -c TOSEM_new -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 --nTest 50000
./scripts/HPC/exec_TG.sh --time 3:00:00 --nick T -m 8 -N 5 --start  31 -r 40 -c TOSEM_new -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 --nTest 50000
./scripts/HPC/exec_TG.sh --time 3:00:00 --nick T -m 8 -N 5 --start  41 -r 50 -c TOSEM_new -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 --nTest 50000


#############################################################################
# Generate test data (ESAIL) // It requires total 50 hours, so it is better to use partition
#############################################################################
# partitioning 5 sub test data
for ((runID=1; runID<=5; runID++)); do
	./scripts/HPC/exec_TG.sh --time 15:00:00 --nick T${runID} -m 8 -N 10 --start   1 -r 10 -c TOSEM_new -t ESAIL_SAFE --runID ${runID} --cpus 1 --max 1800000 --quanta 0.1 --nTest 10000
	./scripts/HPC/exec_TG.sh --time 15:00:00 --nick T${runID} -m 8 -N 10 --start  11 -r 20 -c TOSEM_new -t ESAIL_SAFE --runID ${runID} --cpus 1 --max 1800000 --quanta 0.1 --nTest 10000
	./scripts/HPC/exec_TG.sh --time 15:00:00 --nick T${runID} -m 8 -N 10 --start  21 -r 30 -c TOSEM_new -t ESAIL_SAFE --runID ${runID} --cpus 1 --max 1800000 --quanta 0.1 --nTest 10000
	./scripts/HPC/exec_TG.sh --time 15:00:00 --nick T${runID} -m 8 -N 10 --start  31 -r 40 -c TOSEM_new -t ESAIL_SAFE --runID ${runID} --cpus 1 --max 1800000 --quanta 0.1 --nTest 10000
	./scripts/HPC/exec_TG.sh --time 15:00:00 --nick T${runID} -m 8 -N 10 --start  41 -r 50 -c TOSEM_new -t ESAIL_SAFE --runID ${runID} --cpus 1 --max 1800000 --quanta 0.1 --nTest 10000
done

# Merge the test data results
~/venv/bin/python3 scripts/tools/MergeTestData.py -f merge_testdata -b results/TOSEM_new/ESAIL_SAFE -p 5

#############################################################################
# Generate test data (ADCS) // It requires total 50 hours, so it is better to use partition
#############################################################################
for ((partID=1; partID<=5; partID++)); do
	./scripts/HPC/exec_TG.sh --time 15:00:00 --nick TG${partID} -m 8 -N 10 --start   1 -r 10 -c TOSEM_new -t ADCS_SAFE --partID ${partID} --cpus 1 --max 1800000 --quanta 0.1 --nTest 10000
	./scripts/HPC/exec_TG.sh --time 15:00:00 --nick TG${partID} -m 8 -N 10 --start  11 -r 20 -c TOSEM_new -t ADCS_SAFE --partID ${partID} --cpus 1 --max 1800000 --quanta 0.1 --nTest 10000
	./scripts/HPC/exec_TG.sh --time 15:00:00 --nick TG${partID} -m 8 -N 10 --start  21 -r 30 -c TOSEM_new -t ADCS_SAFE --partID ${partID} --cpus 1 --max 1800000 --quanta 0.1 --nTest 10000
	./scripts/HPC/exec_TG.sh --time 15:00:00 --nick TG${partID} -m 8 -N 10 --start  31 -r 40 -c TOSEM_new -t ADCS_SAFE --partID ${partID} --cpus 1 --max 1800000 --quanta 0.1 --nTest 10000
	./scripts/HPC/exec_TG.sh --time 15:00:00 --nick TG${partID} -m 8 -N 10 --start  41 -r 50 -c TOSEM_new -t ADCS_SAFE --partID ${partID} --cpus 1 --max 1800000 --quanta 0.1 --nTest 10000
done

# Merge the test data results
~/venv/bin/python3 scripts/tools/MergeTestData.py -f merge_testdata -b results/TOSEM_new/ADCS_SAFE -p 5


# Check the number of test data
~/venv/bin/python3 scripts/tools/checkTestData.py -b results/TOSEM_new/ICS_SAFE -f check_testdata -t testdata.csv
~/venv/bin/python3 scripts/tools/checkTestData.py -b results/TOSEM_new/UAV_SAFE -f check_testdata -t testdata.csv
~/venv/bin/python3 scripts/tools/checkTestData.py -b results/TOSEM_new/ESAIL_SAFE -f check_testdata -t testdata.csv
~/venv/bin/python3 scripts/tools/checkTestData.py -b results/TOSEM_new/ADCS_SAFE -f check_testdata -t testdata.csv

# Remove unnecessary files
#scripts/HPC/remove_simple.sh -b results/TOSEM_new/ADCS_SAFE -t testdata_part01.csv


#############################################################################
# Phase 2 : SafeRefinement (Distance based sampling)
#############################################################################
#ICS
./scripts/HPC/exec_P2.sh --dependency 2421037 --time 05:00:00 --nick R -m 8 -N 10 --start  1 -r 10 -c TOSEM_new -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --dependency 2421038 --time 05:00:00 --nick R -m 8 -N 10 --start 11 -r 20 -c TOSEM_new -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --dependency 2421039 --time 05:00:00 --nick R -m 8 -N 10 --start 21 -r 30 -c TOSEM_new -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --dependency 2421040 --time 05:00:00 --nick R -m 8 -N 10 --start 31 -r 40 -c TOSEM_new -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --dependency 2421041 --time 05:00:00 --nick R -m 8 -N 10 --start 41 -r 50 -c TOSEM_new -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples

./scripts/HPC/exec_P2.sh --dependency 2421037 --time 05:00:00 --nick D -m 8 -N 10 --start  1 -r 10 -c TOSEM_new -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _dist --useTest --removeSamples
./scripts/HPC/exec_P2.sh --dependency 2421038 --time 05:00:00 --nick D -m 8 -N 10 --start 11 -r 20 -c TOSEM_new -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _dist --useTest --removeSamples
./scripts/HPC/exec_P2.sh --dependency 2421039 --time 05:00:00 --nick D -m 8 -N 10 --start 21 -r 30 -c TOSEM_new -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _dist --useTest --removeSamples
./scripts/HPC/exec_P2.sh --dependency 2421040 --time 05:00:00 --nick D -m 8 -N 10 --start 31 -r 40 -c TOSEM_new -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _dist --useTest --removeSamples
./scripts/HPC/exec_P2.sh --dependency 2421041 --time 05:00:00 --nick D -m 8 -N 10 --start 41 -r 50 -c TOSEM_new -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _dist --useTest --removeSamples

#UAV
./scripts/HPC/exec_P2.sh --dependency 2420841 --time 10:00:00 --nick RANDOM -m 8 -N 10 --start  1 -r 10 -c TOSEM_new -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --dependency 2420842 --time 10:00:00 --nick RANDOM -m 8 -N 10 --start 11 -r 20 -c TOSEM_new -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --dependency 2420843 --time 10:00:00 --nick RANDOM -m 8 -N 10 --start 21 -r 30 -c TOSEM_new -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --dependency 2420844 --time 10:00:00 --nick RANDOM -m 8 -N 10 --start 31 -r 40 -c TOSEM_new -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --dependency 2420845 --time 10:00:00 --nick RANDOM -m 8 -N 10 --start 41 -r 50 -c TOSEM_new -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples

./scripts/HPC/exec_P2.sh  --dependency 2420841 --time 10:00:00 --nick DIST -m 8 -N 10 --start  1 -r 10 -c TOSEM_new -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _dist --useTest --removeSamples
./scripts/HPC/exec_P2.sh  --dependency 2420842 --time 10:00:00 --nick DIST -m 8 -N 10 --start 11 -r 20 -c TOSEM_new -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _dist --useTest --removeSamples
./scripts/HPC/exec_P2.sh  --dependency 2420843 --time 10:00:00 --nick DIST -m 8 -N 10 --start 21 -r 30 -c TOSEM_new -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _dist --useTest --removeSamples
./scripts/HPC/exec_P2.sh  --dependency 2420844 --time 10:00:00 --nick DIST -m 8 -N 10 --start 31 -r 40 -c TOSEM_new -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _dist --useTest --removeSamples
./scripts/HPC/exec_P2.sh  --dependency 2420845 --time 10:00:00 --nick DIST -m 8 -N 10 --start 41 -r 50 -c TOSEM_new -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _phase1 -w2 _dist --useTest --removeSamples

#ESAIL
./scripts/HPC/exec_P2.sh --time 15:00:00 --nick R -m 8 -N 10 --start  1 -r 10 -c TOSEM_new -t ESAIL_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 15:00:00 --nick R -m 8 -N 10 --start 11 -r 20 -c TOSEM_new -t ESAIL_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 15:00:00 --nick R -m 8 -N 10 --start 21 -r 30 -c TOSEM_new -t ESAIL_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 15:00:00 --nick R -m 8 -N 10 --start 31 -r 40 -c TOSEM_new -t ESAIL_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 15:00:00 --nick R -m 8 -N 10 --start 41 -r 50 -c TOSEM_new -t ESAIL_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples

./scripts/HPC/exec_P2.sh --time 15:00:00 --nick D -m 8 -N 10 --start  1 -r 10 -c TOSEM_new -t ESAIL_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _dist --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 15:00:00 --nick D -m 8 -N 10 --start 11 -r 20 -c TOSEM_new -t ESAIL_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _dist --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 15:00:00 --nick D -m 8 -N 10 --start 21 -r 30 -c TOSEM_new -t ESAIL_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _dist --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 15:00:00 --nick D -m 8 -N 10 --start 31 -r 40 -c TOSEM_new -t ESAIL_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _dist --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 15:00:00 --nick D -m 8 -N 10 --start 41 -r 50 -c TOSEM_new -t ESAIL_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _dist --useTest --removeSamples

#ADCS
./scripts/HPC/exec_P2.sh --time 15:00:00 --nick R -m 8 -N 10 --start  1 -r 10 -c TOSEM_new -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 15:00:00 --nick R -m 8 -N 10 --start 11 -r 20 -c TOSEM_new -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 15:00:00 --nick R -m 8 -N 10 --start 21 -r 30 -c TOSEM_new -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 15:00:00 --nick R -m 8 -N 10 --start 31 -r 40 -c TOSEM_new -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 15:00:00 --nick R -m 8 -N 10 --start 41 -r 50 -c TOSEM_new -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _random --samplingMethod random --useTest --removeSamples

./scripts/HPC/exec_P2.sh --time 15:00:00 --nick D -m 8 -N 10 --start  1 -r 10 -c TOSEM_new -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _dist --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 15:00:00 --nick D -m 8 -N 10 --start 11 -r 20 -c TOSEM_new -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _dist --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 15:00:00 --nick D -m 8 -N 10 --start 21 -r 30 -c TOSEM_new -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _dist --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 15:00:00 --nick D -m 8 -N 10 --start 31 -r 40 -c TOSEM_new -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _dist --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 15:00:00 --nick D -m 8 -N 10 --start 41 -r 50 -c TOSEM_new -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _dist --useTest --removeSamples

# execute additional when some instance has error
#./scripts/HPC/exec_P2.sh --nick R -m 12 -N 5 --list 03,07,08,14,15 -c TOSEM_new -t ESAIL_SAFE --cpus 1 --max 1800000 --quanta 0.1 -w1 _phase1 -w2 _random --samplingMethod random --useTest


########################################################################
# collecting results
########################################################################
# RQ2 results
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM_new/ICS_SAFE -o results/TOSEM_new/_analysis/EXP2/test_ICS_random.csv -t _random/workdata_test_result.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM_new/ICS_SAFE -o results/TOSEM_new/_analysis/EXP2/test_ICS_dist.csv -t _dist/workdata_test_result.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM_new/UAV_SAFE -o results/TOSEM_new/_analysis/EXP2/test_UAV_random.csv -t _random/workdata_test_result.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM_new/UAV_SAFE -o results/TOSEM_new/_analysis/EXP2/test_UAV_dist.csv -t _dist/workdata_test_result.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM_new/ESAIL_SAFE -o results/TOSEM_new/_analysis/EXP2/test_ESAIL_random.csv -t _random/workdata_test_result.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM_new/ESAIL_SAFE -o results/TOSEM_new/_analysis/EXP2/test_ESAIL_dist.csv -t _dist/workdata_test_result.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM_new/ADCS_SAFE -o results/TOSEM_new/_analysis/EXP2/test_ADCS_random.csv -t _random/workdata_test_result.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM_new/ADCS_SAFE -o results/TOSEM_new/_analysis/EXP2/test_ADCS_dist.csv -t _dist/workdata_test_result.csv


# collect RQ2 execution information
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_new/ICS_SAFE -o results/TOSEM_new/_analysis/EXP2/exec_ICS_dist.csv -t _dist/result2.txt
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_new/ICS_SAFE -o results/TOSEM_new/_analysis/EXP2/exec_ICS_random.csv -t _random/result2.txt
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_new/UAV_SAFE -o results/TOSEM_new/_analysis/EXP2/exec_UAV_dist.csv -t _dist/result2.txt
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_new/UAV_SAFE -o results/TOSEM_new/_analysis/EXP2/exec_UAV_random.csv -t _random/result2.txt
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_new/ESAIL_SAFE -o results/TOSEM_new/_analysis/EXP2/exec_ESAIL_dist.csv -t _dist/result2.txt
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_new/ESAIL_SAFE -o results/TOSEM_new/_analysis/EXP2/exec_ESAIL_random.csv -t _random/result2.txt
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_new/ADCS_SAFE  -o results/TOSEM_new/_analysis/EXP2/exec_ADCS_dist.csv -t _dist/result2.txt
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_new/ADCS_SAFE  -o results/TOSEM_new/_analysis/EXP2/exec_ADCS_random.csv -t _random/result2.txt

# Draw graphs
# Param1: base working directory
# Param2: List of subjects with a comma(,) separated (e.g., ADCS,ICS,UAV)
Rscript scripts/graphs/DrawingRQ2.R results/TOSEM_new/_analysis/EXP2 ESAIL,ADCS,ICS,UAV

