# SAFE
SAFE (Safe WCET Analysis method For real-time task schEdulability) is a tool for Estimating Safe Worst-Case Execution Times of Real-Time Systems Using Search and Machine Learning


### Overview
Estimating worst-case execution times (WCET) is an important activity at both early design and late development stages of real-time systems. Based on the WCET estimates, engineers make design and implementation decisions to ensure that task executions always complete before their specified deadlines. However, in practice, engineers often cannot provide precise point WCET estimates and prefer to provide plausible WCET ranges. Given a set of real-time tasks with such ranges, we provide an automated technique to determine for what WCET values the system is likely to meet its deadlines, and hence operate safely. Our approach combines a search algorithm for generating worst-case scheduling scenarios with polynomial logistic regression for inferring safe WCET ranges. We evaluated our approach by applying it to three industrial systems from different domains. Our approach efficiently and accurately estimates safe WCET ranges within which deadlines are likely to be satisfied with high confidence.


### Prerequisite
SAFE runs on the following operating systems:
- Centos Linux operating system, version 7
- MacOS 10.15.7


### SAFE requires the following tools:
- Java 1.8.0.241 (Dependencies: see the file SAFE/pom.xml)
- R 3.6.2 or above (Dependencies: see the file scripts/graphs/requirements.R)
- Python 3.6.8 or above (Dependencies: tqdm)

 
### Folders and files description
* *res*: Containing the input task description
* *SAFE*: source codes for Java executable files and scripts
* *scripts*: Containing Python and R scripts to help the EXPs and generate graphs
* *run_*.sh*: Shell scripts for executing each EXPs in the paper


### How to create OPAM executable jar files?
Given the pre-configured POM files for Maven in the *SAFE* folder, you can create jar files which are used in the shell script files. Please execute the below commands in the *SAFE* folder.
* *SafeSearch.jar*: mvn -f search.pom -DoutputJar=../artifacts package
* *SafeRefinement-Ext.jar*: mvn -f refinement.pom -DoutputJar=../artifacts package
* *RoundTrip.jar*: mvn -f roundtrip.pom -DoutputJar=../artifacts package


### How to run SAFE?
* Step 0: Extract SAFE.zip to any PATH
* Step 1: Move to PATH and run ./run_safe.sh
* Step 2: See output files in ./results/ADCS_SAFE


### How to run experiments?
Note: Due to randomness of SAFE, we repeat our experiments 50 times

##### =Sanity check=
* Step 1: Run *run_sanity_check.sh*
* Step 2: See output files in *results/SanityCheck/ADCS_SAFE and PATH/SanityCheck/results/ADCS_Baseline*


##### =EXP1=
* Step 0: Extract SAFE.zip to any PATH
* Step 1: Move to PATH and run ./run_exp1.sh
* Step 2: See output files in ./results/EXP1/ADCS_SAFE and ./results/EXP1/ADCS_Baseline

##### =EXP2=
* Step 0: Extract SAFE.zip to any PATH
* Step 1: Move to PATH and run ./run_exp2.sh
* Step 2: See output files in ./results/EXP2/ADCS_SAFE/_dist and ./results/EXP2/ADCS_SAFE/_random

##### =EXP3=
* Step 0: Extract SAFE.zip to any PATH
* Step 1: Move to PATH and run ./run_exp3.sh
* Step 2: See output files in ./results/EXP3/ADCS_SAFE




