#!/bin/bash -l
# This scripts should be executed on the project root folder
# All artifacts and R scripts should be executed in the project root folder.

# phase2 대체제 다시 실행 RQ3용 (사용하진 않지만 결과로는 사용)
./scripts/HPC/exec_P2.sh --time 1:00:00 --nick D -m 8 -N 10 --start  1 -r 10 -c TOSEM_mix -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _dist3 --removeSamples
./scripts/HPC/exec_P2.sh --time 1:00:00 --nick D -m 8 -N 10 --start 11 -r 20 -c TOSEM_mix -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _dist3 --removeSamples
./scripts/HPC/exec_P2.sh --time 1:00:00 --nick D -m 8 -N 10 --start 21 -r 30 -c TOSEM_mix -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _dist3 --removeSamples
./scripts/HPC/exec_P2.sh --time 1:00:00 --nick D -m 8 -N 10 --start 31 -r 40 -c TOSEM_mix -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _dist3 --removeSamples
./scripts/HPC/exec_P2.sh --time 1:00:00 --nick D -m 8 -N 10 --start 41 -r 50 -c TOSEM_mix -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _dist3 --removeSamples

./scripts/HPC/exec_P2.sh --time 2:00:00 --nick D -m 8 -N 10 --start  1 -r 10 -c TOSEM_mix -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _dist3 --removeSamples
./scripts/HPC/exec_P2.sh --time 2:00:00 --nick D -m 8 -N 10 --start 11 -r 20 -c TOSEM_mix -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _dist3 --removeSamples
./scripts/HPC/exec_P2.sh --time 2:00:00 --nick D -m 8 -N 10 --start 21 -r 30 -c TOSEM_mix -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _dist3 --removeSamples
./scripts/HPC/exec_P2.sh --time 2:00:00 --nick D -m 8 -N 10 --start 31 -r 40 -c TOSEM_mix -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _dist3 --removeSamples
./scripts/HPC/exec_P2.sh --time 2:00:00 --nick D -m 8 -N 10 --start 41 -r 50 -c TOSEM_mix -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _dist3 --removeSamples

# ICS Round trip
./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start  1 -r 10 -c TOSEM_mix -t ICS_SAFE -w2 _dist3 -we _roundtrip3 --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start 11 -r 20 -c TOSEM_mix -t ICS_SAFE -w2 _dist3 -we _roundtrip3 --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start 21 -r 30 -c TOSEM_mix -t ICS_SAFE -w2 _dist3 -we _roundtrip3 --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start 31 -r 40 -c TOSEM_mix -t ICS_SAFE -w2 _dist3 -we _roundtrip3 --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start 41 -r 50 -c TOSEM_mix -t ICS_SAFE -w2 _dist3 -we _roundtrip3 --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200

# UAV Round trip
./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start  1 -r 10 -c TOSEM_mix -t UAV_SAFE -w2 _dist3 -we _roundtrip3 --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start 11 -r 20 -c TOSEM_mix -t UAV_SAFE -w2 _dist3 -we _roundtrip3 --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start 21 -r 30 -c TOSEM_mix -t UAV_SAFE -w2 _dist3 -we _roundtrip3 --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start 31 -r 40 -c TOSEM_mix -t UAV_SAFE -w2 _dist3 -we _roundtrip3 --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200
./scripts/HPC/exec_P3.sh --time 1:00:00 --nick T -m 8 -N 10 --start 41 -r 50 -c TOSEM_mix -t UAV_SAFE -w2 _dist3 -we _roundtrip3 --cpus 3 --max 0 --quanta 0.01 --nTest 200 --nWCETs 200


#############################################################################
# Phase 2 : SafeRefinement (Distance based sampling) // 재실행 (_dist3, _random3)
#############################################################################
#ICS
./scripts/HPC/exec_P2.sh --time 05:00:00 --nick R -m 8 -N 10 --start  1 -r 10 -c TOSEM_mix -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _random3 --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 05:00:00 --nick R -m 8 -N 10 --start 11 -r 20 -c TOSEM_mix -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _random3 --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 05:00:00 --nick R -m 8 -N 10 --start 21 -r 30 -c TOSEM_mix -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _random3 --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 05:00:00 --nick R -m 8 -N 10 --start 31 -r 40 -c TOSEM_mix -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _random3 --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 05:00:00 --nick R -m 8 -N 10 --start 41 -r 50 -c TOSEM_mix -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _random3 --samplingMethod random --useTest --removeSamples

./scripts/HPC/exec_P2.sh --time 05:00:00 --nick D -m 8 -N 10 --start  1 -r 10 -c TOSEM_mix -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _dist3 --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 05:00:00 --nick D -m 8 -N 10 --start 11 -r 20 -c TOSEM_mix -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _dist3 --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 05:00:00 --nick D -m 8 -N 10 --start 21 -r 30 -c TOSEM_mix -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _dist3 --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 05:00:00 --nick D -m 8 -N 10 --start 31 -r 40 -c TOSEM_mix -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _dist3 --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 05:00:00 --nick D -m 8 -N 10 --start 41 -r 50 -c TOSEM_mix -t ICS_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _dist3 --useTest --removeSamples

#UAV
./scripts/HPC/exec_P2.sh --time 10:00:00 --nick R -m 8 -N 10 --start  1 -r 10 -c TOSEM_mix -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _random3 --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 10:00:00 --nick R -m 8 -N 10 --start 11 -r 20 -c TOSEM_mix -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _random3 --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 10:00:00 --nick R -m 8 -N 10 --start 21 -r 30 -c TOSEM_mix -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _random3 --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 10:00:00 --nick R -m 8 -N 10 --start 31 -r 40 -c TOSEM_mix -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _random3 --samplingMethod random --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 10:00:00 --nick R -m 8 -N 10 --start 41 -r 50 -c TOSEM_mix -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _random3 --samplingMethod random --useTest --removeSamples

./scripts/HPC/exec_P2.sh --time 10:00:00 --nick D -m 8 -N 10 --start  1 -r 10 -c TOSEM_mix -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _dist3 --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 10:00:00 --nick D -m 8 -N 10 --start 11 -r 20 -c TOSEM_mix -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _dist3 --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 10:00:00 --nick D -m 8 -N 10 --start 21 -r 30 -c TOSEM_mix -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _dist3 --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 10:00:00 --nick D -m 8 -N 10 --start 31 -r 40 -c TOSEM_mix -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _dist3 --useTest --removeSamples
./scripts/HPC/exec_P2.sh --time 10:00:00 --nick D -m 8 -N 10 --start 41 -r 50 -c TOSEM_mix -t UAV_SAFE --cpus 3 --max 0 --quanta 0.01 -w1 _results -w2 _dist3 --useTest --removeSamples


~/venv/bin/python3 scripts/tools/MergeTestData.py -f merge_rt_data -b results/TOSEM_mix/ADCS_SAFE -p 8

########################################################################
# collecting results
########################################################################
#  RQ1: Collecting results of P1
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_mix/ICS_SAFE -o results/TOSEM_mix/_analysis4/EXP1/P1_ICS_SAFE.csv -t result.txt
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_mix/UAV_SAFE -o results/TOSEM_mix/_analysis4/EXP1/P1_UAV_SAFE.csv -t result.txt
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_mix/ADCS_SAFE -o results/TOSEM_mix/_analysis4/EXP1/P1_ADCS_SAFE.csv -t result.txt
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_mix/ICS_Baseline -o results/TOSEM_mix/_analysis4/EXP1/P1_ICS_Baseline.csv -t result.txt
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_mix/UAV_Baseline -o results/TOSEM_mix/_analysis4/EXP1/P1_UAV_Baseline.csv -t result.txt
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_mix/ESAIL_Baseline -o results/TOSEM_mix/_analysis4/EXP1/P1_ADCS_Baseline.csv -t result.txt

# RQ1:  Collecting results phase 2
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_model -b results/TOSEM_mix/ICS_SAFE -o results/TOSEM_mix/_analysis4/EXP1/P2_ICS_SAFE.csv -q 0.01 -t _phase2
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_model -b results/TOSEM_mix/UAV_SAFE -o results/TOSEM_mix/_analysis4/EXP1/P2_UAV_SAFE.csv -q 0.01 -t _phase2
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_model -b results/TOSEM_mix/ADCS_SAFE -o results/TOSEM_mix/_analysis4/EXP1/P2_ADCS_SAFE.csv -q 0.1 -t _phase2
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_model -b results/TOSEM_mix/ICS_Baseline -o results/TOSEM_mix/_analysis4/EXP1/P2_ICS_Baseline.csv -q 0.01 -t _phase2
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_model -b results/TOSEM_mix/UAV_Baseline -o results/TOSEM_mix/_analysis4/EXP1/P2_UAV_Baseline.csv -q 0.01 -t _phase2
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_model -b results/TOSEM_mix/ESAIL_Baseline -o results/TOSEM_mix/_analysis4/EXP1/P2_ADCS_Baseline.csv -q 0.1 -t _phase2

# RQ1: collecting RT results
~/venv/bin/python3 scripts/tools/RoundTripCollector.py -f merge_roundtrip_subject -b results/TOSEM_mix/ICS_SAFE -o results/TOSEM_mix/_analysis4/EXP1/RT_ICS_SAFE.csv -t _roundtrip
~/venv/bin/python3 scripts/tools/RoundTripCollector.py -f merge_roundtrip_subject -b results/TOSEM_mix/UAV_SAFE -o results/TOSEM_mix/_analysis4/EXP1/RT_UAV_SAFE.csv -t _roundtrip
~/venv/bin/python3 scripts/tools/RoundTripCollector.py -f merge_roundtrip_subject -b results/TOSEM_mix/ICS_Baseline -o results/TOSEM_mix/_analysis4/EXP1/RT_ICS_Baseline.csv -t _roundtrip
~/venv/bin/python3 scripts/tools/RoundTripCollector.py -f merge_roundtrip_subject -b results/TOSEM_mix/UAV_Baseline -o results/TOSEM_mix/_analysis4/EXP1/RT_UAV_Baseline.csv -t _roundtrip
~/venv/bin/python3 scripts/tools/RoundTripCollector.py -f merge_roundtrip_subject -b results/TOSEM_mix/ADCS_SAFE -o results/TOSEM_mix/_analysis4/EXP1/RT_ADCS_SAFE.csv -t _roundtrip
~/venv/bin/python3 scripts/tools/RoundTripCollector.py -f merge_roundtrip_subject -b results/TOSEM_mix/ESAIL_Baseline -o results/TOSEM_mix/_analysis4/EXP1/RT_ADCS_Baseline.csv -t _roundtrip

#################################################
# RQ2 results
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM_mix/ICS_SAFE -o results/TOSEM_mix/_analysis4/EXP2/test_ICS_random.csv -t _random/workdata_test_result.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM_mix/ICS_SAFE -o results/TOSEM_mix/_analysis4/EXP2/test_ICS_dist.csv -t _dist/workdata_test_result.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM_mix/UAV_SAFE -o results/TOSEM_mix/_analysis4/EXP2/test_UAV_random.csv -t _random/workdata_test_result.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM_mix/UAV_SAFE -o results/TOSEM_mix/_analysis4/EXP2/test_UAV_dist.csv -t _dist/workdata_test_result.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM_mix/ADCS_SAFE -o results/TOSEM_mix/_analysis4/EXP2/test_ADCS_random.csv -t _random/workdata_test_result.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM_mix/ADCS_SAFE -o results/TOSEM_mix/_analysis4/EXP2/test_ADCS_dist.csv -t _dist/workdata_test_result.csv

# RQ2 exec time
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_mix/ICS_SAFE -o results/TOSEM_mix/_analysis4/EXP2/exec_ICS_random.csv -t _random/result2.txt
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_mix/ICS_SAFE -o results/TOSEM_mix/_analysis4/EXP2/exec_ICS_dist.csv -t _dist/result2.txt
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_mix/UAV_SAFE -o results/TOSEM_mix/_analysis4/EXP2/exec_UAV_random.csv -t _random/result2.txt
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_mix/UAV_SAFE -o results/TOSEM_mix/_analysis4/EXP2/exec_UAV_dist.csv -t _dist/result2.txt
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_mix/ADCS_SAFE -o results/TOSEM_mix/_analysis4/EXP2/exec_ADCS_random.csv -t _random/result2.txt
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_mix/ADCS_SAFE -o results/TOSEM_mix/_analysis4/EXP2/exec_ADCS_dist.csv -t _dist/result2.txt

#################################################
#RQ3
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM_mix/ICS_SAFE -o results/TOSEM_mix/_analysis4/EXP3/kfold_ICS_SAFE.csv -t _phase2/workdata_termination_result.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM_mix/UAV_SAFE -o results/TOSEM_mix/_analysis4/EXP3/kfold_UAV_SAFE.csv -t _phase2/workdata_termination_result.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_test -b results/TOSEM_mix/ADCS_SAFE -o results/TOSEM_mix/_analysis4/EXP3/kfold_ADCS_SAFE.csv -t _phase2/workdata_termination_result.csv


# Draw graphs
# Param1: base working directory
# Param2: List of subjects with a comma(,) separated (e.g., ADCS,ICS,UAV)
Rscript scripts/graphs/DrawingBestSize.R results/TOSEM_mix/_analysis4/EXP1 ADCS,ICS,UAV
Rscript scripts/graphs/DrawingRoundTrip.R results/TOSEM_mix/_analysis4/EXP1 ADCS,ICS,UAV
Rscript scripts/graphs/DrawingProbability.R results/TOSEM_mix/_analysis4/EXP1 ADCS,ICS,UAV
Rscript scripts/graphs/DrawingExecTime.R results/TOSEM_mix/_analysis4/EXP1 ADCS,ICS,UAV

Rscript scripts/graphs/DrawingRQ2.R results/TOSEM_mix/_analysis4/EXP2 ADCS,ICS,UAV
Rscript scripts/graphs/DrawingRQ3.R results/TOSEM_mix/_analysis4/EXP3 ADCS,ICS,UAV

Rscript scripts/graphs/DrawingTable.R results/TOSEM_mix/_analysis4/EXP1 ADCS,ICS,UAV

Rscript scripts/graphs/DrawingTable.R results/TOSEM_mix/_analysis/EXP1 ADCS,ICS,UAV
Rscript scripts/graphs/DrawingRQ2.R results/TOSEM_mix/_analysis/EXP2 ADCS,ICS,UAV

tar -czf raw_paper_20210719/ADCS_Baseline.tar.gz ADCS_Baseline
tar -czf raw_paper_20210719/ICS_Baseline.tar.gz ICS_Baseline
tar -czf raw_paper_20210719/UAV_Baseline.tar.gz UAV_Baseline
tar -czf raw_paper_20210719/ADCS_SAFE.tar.gz ADCS_SAFE
tar -czf raw_paper_20210719/ICS_SAFE.tar.gz ICS_SAFE
tar -czf raw_paper_20210719/UAV_SAFE.tar.gz UAV_SAFE



# ADCS old data 정리 코드
#~/venv/bin/python3 scripts/tools/mergeSolutions.py -f convertP2Test -b results/TOSEM_mix/ADCS_SAFE -t _dist/workdata_test_result.csv -n 50
#~/venv/bin/python3 scripts/tools/mergeSolutions.py -f convertP2Test -b results/TOSEM_mix/ADCS_SAFE -t _random/workdata_test_result.csv -n 50
#~/venv/bin/python3 scripts/tools/mergeSolutions.py -f convertP2Test -b results/TOSEM_mix/ADCS_SAFE -t _phase2/workdata_test_result.csv -n 50
#
#
#~/venv/bin/python3 scripts/tools/mergeSolutions.py -f convertP2Termi -b results/TOSEM_mix/ADCS_SAFE -t _dist/workdata_termination_result.csv -n 50
#~/venv/bin/python3 scripts/tools/mergeSolutions.py -f convertP2Termi -b results/TOSEM_mix/ADCS_SAFE -t _random/workdata_termination_result.csv -n 50
#~/venv/bin/python3 scripts/tools/mergeSolutions.py -f convertP2Termi -b results/TOSEM_mix/ADCS_SAFE -t _phase2/workdata_termination_result.csv -n 50

