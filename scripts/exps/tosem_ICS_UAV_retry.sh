#!/bin/bash -l
# All artifacts and R scripts should be executed in the project root folder.



########################################################################
# Collecting RQ1 results
########################################################################
# Collecting results 1

~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_mix/ICS_SAFE -o results/TOSEM_mix/_analysis3/EXP1/P1_ICS_SAFE.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_mix/ICS_Baseline -o results/TOSEM_mix/_analysis3/EXP1/P1_ICS_Baseline.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_mix/UAV_SAFE -o results/TOSEM_mix/_analysis3/EXP1/P1_UAV_SAFE.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_mix/UAV_Baseline -o results/TOSEM_mix/_analysis3/EXP1/P1_UAV_Baseline.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_mix/ESAIL_Baseline -o results/TOSEM_mix/_analysis3/EXP1/P1_ADCS_Baseline.csv
~/venv/bin/python3 scripts/tools/Collector.py -f merge_execinfo -b results/TOSEM_mix/ADCS_SAFE -o results/TOSEM_mix/_analysis3/EXP1/P1_ADCS_SAFE.csv



# Collecting results phase 2
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_model -b results/TOSEM_mix/ICS_SAFE -o results/TOSEM_mix/_analysis3/EXP1/P2_ICS_SAFE.csv -q 0.01
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_model -b results/TOSEM_mix/UAV_SAFE -o results/TOSEM_mix/_analysis3/EXP1/P2_UAV_SAFE.csv -q 0.01
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_model -b results/TOSEM_mix/ADCS_SAFE -o results/TOSEM_mix/_analysis3/EXP1/P2_ADCS_SAFE.csv -q 0.1
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_model -b results/TOSEM_mix/ICS_Baseline -o results/TOSEM_mix/_analysis3/EXP1/P2_ICS_Baseline.csv -q 0.01
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_model -b results/TOSEM_mix/UAV_Baseline -o results/TOSEM_mix/_analysis3/EXP1/P2_UAV_Baseline.csv -q 0.01
~/venv/bin/python3 scripts/tools/Collector.py -f merge_p2_model -b results/TOSEM_mix/ESAIL_Baseline -o results/TOSEM_mix/_analysis3/EXP1/P2_ADCS_Baseline.csv -q 0.1


# RoundTrip
~/venv/bin/python3 scripts/tools/RoundTripCollector.py -f merge_roundtrip_subject -b results/TOSEM_mix/ICS_SAFE -o results/TOSEM_mix/_analysis3/EXP1/RT_ICS_SAFE.csv -t _roundtrip
~/venv/bin/python3 scripts/tools/RoundTripCollector.py -f merge_roundtrip_subject -b results/TOSEM_mix/ICS_Baseline -o results/TOSEM_mix/_analysis3/EXP1/RT_ICS_Baseline.csv -t _roundtrip
~/venv/bin/python3 scripts/tools/RoundTripCollector.py -f merge_roundtrip_subject -b results/TOSEM_mix/UAV_SAFE -o results/TOSEM_mix/_analysis3/EXP1/RT_UAV_SAFE.csv -t _roundtrip
~/venv/bin/python3 scripts/tools/RoundTripCollector.py -f merge_roundtrip_subject -b results/TOSEM_mix/UAV_Baseline -o results/TOSEM_mix/_analysis3/EXP1/RT_UAV_Baseline.csv -t _roundtrip
~/venv/bin/python3 scripts/tools/RoundTripCollector.py -f merge_roundtrip_subject -b results/TOSEM_mix/ESAIL_Baseline -o results/TOSEM_mix/_analysis3/EXP1/RT_ADCS_Baseline.csv -t _roundtrip
~/venv/bin/python3 scripts/tools/RoundTripCollector.py -f merge_roundtrip_subject -b results/TOSEM_mix/ADCS_SAFE -o results/TOSEM_mix/_analysis3/EXP1/RT_ADCS_SAFE.csv -t _roundtrip


# Draw graphs
# Param1: base working directory
# Param2: List of subjects with a comma(,) separated (e.g., ADCS,ICS,UAV)
Rscript scripts/graphs/DrawingBestSize.R results/TOSEM_mix/_analysis3/EXP1 ADCS,ICS,UAV
Rscript scripts/graphs/DrawingRoundTrip.R results/TOSEM_mix/_analysis3/EXP1 ADCS,ICS,UAV
Rscript scripts/graphs/DrawingProbability.R results/TOSEM_mix/_analysis3/EXP1 ADCS,ICS,UAV
Rscript scripts/graphs/DrawingExecTime.R results/TOSEM_mix/_analysis3/EXP1 ADCS,ICS,UAV

