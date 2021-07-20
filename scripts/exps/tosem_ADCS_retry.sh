#!/bin/bash -l
# All artifacts and R scripts should be executed in the project root folder.

########################################################
# ADCS Baseline Phase 2
./scripts/HPC/exec_P2_RS.sh --time 1:00:00 --nick mix -m 8 -N 10 --start  1 -r 10 -c TOSEM_mix -t ADCS_Baseline -q 0.1 -w1 _results -w2 _phase2
./scripts/HPC/exec_P2_RS.sh --time 1:00:00 --nick mix -m 8 -N 10 --start 11 -r 20 -c TOSEM_mix -t ADCS_Baseline -q 0.1 -w1 _results -w2 _phase2
./scripts/HPC/exec_P2_RS.sh --time 1:00:00 --nick mix -m 8 -N 10 --start 21 -r 30 -c TOSEM_mix -t ADCS_Baseline -q 0.1 -w1 _results -w2 _phase2
./scripts/HPC/exec_P2_RS.sh --time 1:00:00 --nick mix -m 8 -N 10 --start 31 -r 40 -c TOSEM_mix -t ADCS_Baseline -q 0.1 -w1 _results -w2 _phase2
./scripts/HPC/exec_P2_RS.sh --time 1:00:00 --nick mix -m 8 -N 10 --start 41 -r 50 -c TOSEM_mix -t ADCS_Baseline -q 0.1 -w1 _results -w2 _phase2

########################################################
# Round trip for ADCS_Baseline (will take over 48 hours, need to resume)
./scripts/HPC/exec_P3.sh --nick 5 -N 10 --mem 8 --start  1 -r 10 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 5 --partMAX 5
./scripts/HPC/exec_P3.sh --nick 5 -N 10 --mem 8 --start 11 -r 20 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 5 --partMAX 5
./scripts/HPC/exec_P3.sh --nick 5 -N 10 --mem 8 --start 21 -r 30 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 5 --partMAX 5
./scripts/HPC/exec_P3.sh --nick 5 -N 10 --mem 8 --start 31 -r 40 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 5 --partMAX 5
./scripts/HPC/exec_P3.sh --nick 5 -N 10 --mem 8 --start 41 -r 50 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 5 --partMAX 5

########################################################
# Round trip for ADCS_SAFE (8 partition)
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 1 -N 10 --mem 8 --start  1 -r 10 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --partID 1 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 1 -N 10 --mem 8 --start 11 -r 20 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --partID 1 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 1 -N 10 --mem 8 --start 21 -r 30 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --partID 1 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 1 -N 10 --mem 8 --start 31 -r 40 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --partID 1 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 1 -N 10 --mem 8 --start 41 -r 50 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --partID 1 --partMAX 8

./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 2 -N 10 --mem 8 --start  1 -r 10 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 2 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 2 -N 10 --mem 8 --start 11 -r 20 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 2 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 2 -N 10 --mem 8 --start 21 -r 30 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 2 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 2 -N 10 --mem 8 --start 31 -r 40 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 2 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 2 -N 10 --mem 8 --start 41 -r 50 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 2 --partMAX 8

./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 3 -N 10 --mem 8 --start  1 -r 10 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 3 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 3 -N 10 --mem 8 --start 11 -r 20 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 3 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 3 -N 10 --mem 8 --start 21 -r 30 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 3 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 3 -N 10 --mem 8 --start 31 -r 40 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 3 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 3 -N 10 --mem 8 --start 41 -r 50 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 3 --partMAX 8

./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 4 -N 10 --mem 8 --start  1 -r 10 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 4 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 4 -N 10 --mem 8 --start 11 -r 20 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 4 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 4 -N 10 --mem 8 --start 21 -r 30 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 4 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 4 -N 10 --mem 8 --start 31 -r 40 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 4 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 4 -N 10 --mem 8 --start 41 -r 50 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 4 --partMAX 8

./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 5 -N 10 --mem 8 --start  1 -r 10 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 5 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 5 -N 10 --mem 8 --start 11 -r 20 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 5 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 5 -N 10 --mem 8 --start 21 -r 30 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 5 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 5 -N 10 --mem 8 --start 31 -r 40 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 5 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 5 -N 10 --mem 8 --start 41 -r 50 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 5 --partMAX 8

./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 6 -N 10 --mem 8 --start  1 -r 10 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 6 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 6 -N 10 --mem 8 --start 11 -r 20 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 6 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 6 -N 10 --mem 8 --start 21 -r 30 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 6 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 6 -N 10 --mem 8 --start 31 -r 40 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 6 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 6 -N 10 --mem 8 --start 41 -r 50 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 6 --partMAX 8

./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 7 -N 10 --mem 8 --start  1 -r 10 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 7 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 7 -N 10 --mem 8 --start 11 -r 20 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 7 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 7 -N 10 --mem 8 --start 21 -r 30 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 7 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 7 -N 10 --mem 8 --start 31 -r 40 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 7 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 7 -N 10 --mem 8 --start 41 -r 50 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 7 --partMAX 8

./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 8 -N 10 --mem 8 --start  1 -r 10 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 8 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 8 -N 10 --mem 8 --start 11 -r 20 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 8 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 8 -N 10 --mem 8 --start 21 -r 30 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 8 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 8 -N 10 --mem 8 --start 31 -r 40 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 8 --partMAX 8
./scripts/HPC/exec_P3.sh --time 12:00:00 --nick 8 -N 10 --mem 8 --start 41 -r 50 -c TOSEM_mix -t ADCS_SAFE --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume --partID 8 --partMAX 8


# conduct roundtrip very fast
for ((runID=177; runID<200; runID++)); do
	./scripts/HPC/exec_P3.sh --time 12:00:00 --nick ${runID} -N 10 --mem 8 --start 31 -r 40 -c TOSEM_mix -t ADCS_SAFE --partID ${runID} --partMAX 200 --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume
done

./scripts/HPC/exec_P3.sh --time 1:00:00 --nick 176 -N 10 --mem 8 --start 31 -r 40 -c TOSEM_mix -t ADCS_SAFE --partID 176 --partMAX 200 --cpus 1 --max 1800000 --quanta 0.1 --nTest 200 --nWCETs 200 --resume


~/venv/bin/python3 scripts/tools/MergeTestData.py -f merge_rt_data -b results/TOSEM_mix/ADCS_SAFE -p 8
~/venv/bin/python3 scripts/tools/MergeTestData.py -f merge_rt_data -b results/TOSEM_mix/ADCS_SAFE -p 200 -s 176 -o result_part08.csv -r 31,32,33,34,35,36,37,38,39,40


#scripts/shell/remove_simple.sh -b results/TOSEM_mix/ADCS_SAFE -t _roundtrip/result_part01.csv
#scripts/shell/remove_simple.sh -b results/TOSEM_mix/ADCS_SAFE -t _roundtrip/result_part02.csv
#scripts/shell/remove_simple.sh -b results/TOSEM_mix/ADCS_SAFE -t _roundtrip/result_part03.csv
#scripts/shell/remove_simple.sh -b results/TOSEM_mix/ADCS_SAFE -t _roundtrip/result_part04.csv
#scripts/shell/remove_simple.sh -b results/TOSEM_mix/ADCS_SAFE -t _roundtrip/result_part05.csv
#scripts/shell/remove_simple.sh -b results/TOSEM_mix/ADCS_SAFE -t _roundtrip/result_part06.csv
#scripts/shell/remove_simple.sh -b results/TOSEM_mix/ADCS_SAFE -t _roundtrip/result_part07.csv
#scripts/shell/remove_simple.sh -b results/TOSEM_mix/ADCS_SAFE -t _roundtrip/result_part08.csv


########################################################
# ETC
########################################################
./venv/bin/python3 checkTestData.py -f check_testdata -b results/TOSEM/ADCS_Baseline

#scripts/shell/multiCMD.sh -c "mv" -b results/TOSEM_mix/ESAIL_SAFE -t _random2 -r _random

~/venv/bin/python3 scripts/tools/checkTestData.py -f check_testdata -b results/ADCS_SAFE
~/venv/bin/python3 scripts/tools/checkTestData.py -f check_testdata -b results/TOSEM_mix/ICS_SAFE
~/venv/bin/python3 scripts/tools/checkTestData.py -f check_testdata -b results/TOSEM_mix/UAV_SAFE
