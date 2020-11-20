from utils.executor import Executor

def execute_norm():
    exe = Executor('./cmds')
    exceptlist = []
    jobType = 'Norm_p10_i600'
    jarFile = 'artifacts/StressTesting.jar'
    parameters = '-p 10 -i 600 -r 20 -s RMSchedulerNorm'
    exe.create_jobs(exceptlist=exceptlist, hours=80, jobType=jobType, jar=jarFile, parameters=parameters)

def execute_range():
    exe = Executor('./cmds')
    exceptlist = [0, 24,25,26,27,28,29,30,31,32]
    jobType = 'Range10_c05'
    jarFile = 'artifacts/StressTesting.jar'
    parameters = '-p 10 -i 600 -r 20 -s RMSchedulerRange --range 1.0 -m 0.5'
    exe.create_jobs(exceptlist=exceptlist, hours=80, jobType=jobType, jar=jarFile, parameters=parameters)

def execute_range_mutate():
    exe = Executor('./cmds')
    exceptlist = [0, 24,25,26,27,28,29,30,31,32]
    jobType = 'Range10_c07'
    jarFile = 'artifacts/StressTesting.jar'
    parameters = '-p 10 -i 600 -r 20 -s RMSchedulerRange --range 1.0 -m 0.7'
    exe.create_jobs(exceptlist=exceptlist, hours=80, jobType=jobType, jar=jarFile, parameters=parameters)

def execute_range_detail():
    exe = Executor('./cmds')
    exceptlist = [0, 24,25,26,27,28,29,30,31,32]
    jobType = 'RangeDetail'
    jarFile = 'artifacts/StressTesting.jar'
    parameters = '-s RMSchedulerRange --range 1.0'
    exe.create_jobs(exceptlist=exceptlist, hours=80, jobType=jobType, jar=jarFile, parameters=parameters)

def execute_simeple_range():
    exe = Executor('./cmds')
    exceptlist = [0, 24,25,26,27,28,29,30,31,32]
    jarFile = 'artifacts/SimpleRandom.jar'
    jobType = 'RangeSimple'
    parameters = '-s RMSchedulerRange --range 1.0'
    exe.create_jobs(exceptlist=exceptlist, hours=100, jobType=jobType, jar=jarFile, parameters=parameters)

def execute_simeple_norm():
    exe = Executor('./cmds')
    exceptlist = []
    jarFile = 'artifacts/SimpleRandom.jar'
    jobType = 'NormSimple'
    parameters = '-s RMSchedulerNorm'
    exe.create_jobs(exceptlist=exceptlist, hours=100, jobType=jobType, jar=jarFile, parameters=parameters)

def execute_norm2():
    exe = Executor('./cmds')
    exceptlist = [1,2,3,4,5,6,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34]
    jarFile = 'artifacts/StressTesting.jar'
    jobType = 'NormTest2'
    parameters = '-s RMSchedulerNorm --range 1.0 --quanta 0.1 --max 3600000 -i 100'
    exe.create_jobs(exceptlist=exceptlist, hours=100, jobType=jobType, jar=jarFile, parameters=parameters)

def execute_range2():
    exe = Executor('./cmds')
    exceptlist = [0,1,2,3,4,5,6,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34]
    jarFile = 'artifacts/StressTesting.jar'
    jobType = 'RangeTest2'
    parameters = '-s RMSchedulerRange --range 1.0 --quanta 0.1 --max 3600000 -i 100'
    exe.create_jobs(exceptlist=exceptlist, hours=100, jobType=jobType, jar=jarFile, parameters=parameters)

def execute_norm3():
    exe = Executor('./cmds')
    exceptlist = [1,2,3,4,5,6,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34]
    jarFile = 'artifacts/StressTesting.jar'
    jobType = 'NormTest3'
    parameters = '-s RMSchedulerNorm --range 1.0 --quanta 0.01 --max 60000 -i 100'
    exe.create_jobs(exceptlist=exceptlist, hours=100, jobType=jobType, jar=jarFile, parameters=parameters)

def execute_range3():
    exe = Executor('./cmds')
    exceptlist = [0,1,2,3,4,5,6,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34]
    jarFile = 'artifacts/StressTesting.jar'
    jobType = 'RangeTest3'
    parameters = '-s RMSchedulerRange --range 1.0 --quanta 0.01 --max 60000 -i 100'
    exe.create_jobs(exceptlist=exceptlist, hours=100, jobType=jobType, jar=jarFile, parameters=parameters)

def execute_range1121():
    exe = Executor('./cmds')
    exceptlist = [0, 24,25,26,27,28,29,30,31,32]
    jarFile = 'artifacts/StressTesting.jar'
    jobType = 'RangeDetail'
    parameters = '-s RMSchedulerRange --range 1.0 --quanta 0.01 --max 60000 -i 600'
    exe.create_jobs(exceptlist=exceptlist, hours=100, jobType=jobType, jar=jarFile, parameters=parameters)

def execute_simple1121():
    exe = Executor('./cmds')
    exceptlist = [0, 24,25,26,27,28,29,30,31,32]
    jarFile = 'artifacts/SimpleRandom.jar'
    jobType = 'SimpleDetailNoReplace'
    parameters = '-s RMSchedulerRange --range 1.0 --quanta 0.01 --max 60000 -i 6000 -p 1'
    exe.create_jobs(exceptlist=exceptlist, hours=100, jobType=jobType, jar=jarFile, parameters=parameters)

def execute_simple1122():
    exe = Executor('./cmds')
    exceptlist = [0,1,2,3,4,5,6,14,15,16,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32, 34]

    jarFile = 'artifacts/SimpleRandom.jar'
    jobType = 'Simple'
    parameters = '-s RMSchedulerRange --range 1.0 -i 6000 -p 1 --data res/LS_data_1116_WCET_round.csv'
    exe.create_jobs(exceptlist=exceptlist, hours=100, jobType=jobType, jar=jarFile, parameters=parameters)

def execute_simple1122_newdata():
    exe = Executor('./cmds')
    exceptlist = [0, 1, 2, 3, 4, 5, 6, 14, 15, 16, 18, 19, 20, 21, 22, 23, 33, 34]
    jarFile = 'artifacts/SimpleRandom.jar'
    jobType = 'SimpleNewData'
    parameters = '-s RMSchedulerRange --range 1.0 -i 6000 -p 1 --data res/LS_data_1122_Removed.csv'
    exe.create_jobs(exceptlist=exceptlist, hours=100, jobType=jobType, jar=jarFile, parameters=parameters)

def execute_simple1123_newdata():
    exe = Executor('./cmds')
    exceptlist = [0, 1, 2, 3, 4, 5, 6, 14, 15, 16, 18, 19, 20, 21, 22, 23, 33, 34]
    jarFile = 'artifacts/SimpleRandom.jar'
    jobType = 'SimpleNewData'
    parameters = '-s RMSchedulerRange --range 1.0 -i 6000 -p 1 --data res/LS_data_1122_Priority.csv'
    exe.create_jobs(exceptlist=exceptlist, hours=100, jobType=jobType, jar=jarFile, parameters=parameters)

def execute_range1126_newdata():
    exe = Executor('./cmds')
    exceptlist = [0, 1, 2, 3, 4, 5, 6, 14, 15, 16, 18, 19, 20, 21, 22, 23, 33, 34]
    jarFile = 'artifacts/StressTesting.jar'
    jobType = 'RangeNewData'
    parameters = '-s RMSchedulerRange --range 1.0 -i 600 -p 10 --data res/LS_data_1122_Priority.csv'
    exe.create_jobs(exceptlist=exceptlist, hours=100, jobType=jobType, jar=jarFile, parameters=parameters)

def execute_data1203_WCET():
    exe = Executor('./cmds')
    #exceptlist = [0, 1, 2, 3, 4, 5, 6, 14, 15, 16, 18, 19, 20, 21, 22, 23, 33, 34]
    include=[7, 8]
    types = ["Periodic", "Aperiodic", "Sporadic"]
    jarFile = 'artifacts/StressTesting.jar'
    for percent in [5, 10, 15, 20, 25, 30, 35, 40, 45, 50]:
        for jtype in types:
            jobType = 'WCET%s%d' % (jtype, percent)
            parameters = '--incType %s --incRate 1.%02d' % (jtype, percent)
            exe.create_jobs(exceptlist=[], hours=100, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

def execute_1205_changepriority():
    exe = Executor('./cmds')
    exceptlist = [0, 1, 2, 3, 4, 5, 6, 14, 15, 16, 18, 19, 20, 21, 22, 23, 33, 34]
    jarFile = 'artifacts/StressTesting.jar'
    jobType = 'RangePrioity'
    parameters = '--data res/LS_data_1122_ChangePriority.csv'
    exe.create_jobs(exceptlist=exceptlist, hours=100, jobType=jobType, jar=jarFile, parameters=parameters)

def execute_data1204_WCET():
    exe = Executor('./cmds')
    exceptlist = [0, 1, 2, 3, 4, 5, 6, 14, 15, 16, 18, 19, 20, 21, 22, 23, 33, 34]
    types = ["Periodic"]#, "Aperiodic", "Sporadic"]
    jarFile = 'artifacts/StressTesting.jar'
    for percent in [30, 35]:
        for jtype in types:
            jobType = 'WCET%s%d' % (jtype, percent)
            parameters = '--incType %s --incRate 1.%02d' % (jtype, percent)
            exe.create_jobs(exceptlist=exceptlist, hours=80, jobType=jobType, jar=jarFile, parameters=parameters, include=None)

def execute_1204_Baseline():
    exe = Executor('./cmds')
    exceptlist = [0, 1, 2, 3, 4, 5, 6, 14, 15, 16, 18, 19, 20, 21, 22, 23, 33, 34]
    jarFile = 'artifacts/StressTesting.jar'
    jobType = 'RangeBaseline'
    parameters = '--data res/LS_data_1122_Priority.csv'
    exe.create_jobs(exceptlist=exceptlist, hours=80, jobType=jobType, jar=jarFile, parameters=parameters)

def execute_1206_ArrivalOriginal():
    exe = Executor('./cmds')
    exceptlist = [0, 1, 2, 3, 4, 5, 6, 14, 15, 16, 18, 19, 20, 21, 22, 23, 33, 34]
    jarFile = 'artifacts/StressTesting.jar'
    jobType = 'ArrivalOrigin'
    parameters = '--data res/LS_data_1122_Priority.csv'
    exe.create_jobs(exceptlist=exceptlist, hours=100, jobType=jobType, jar=jarFile, parameters=parameters)

def execute_1206_ArrivalWCET():
    exe = Executor('./cmds')
    exceptlist = [0, 1, 2, 3, 4, 5, 6, 14, 15, 16, 18, 19, 20, 21, 22, 23, 33, 34]
    types = ["Periodic"]#, "Aperiodic", "Sporadic"]
    jarFile = 'artifacts/StressTesting.jar'
    for percent in [25, 30, 35]:
        for jtype in types:
            jobType = 'ArrivalWCET%s%d' % (jtype, percent)
            parameters = '--incType %s --incRate 1.%02d' % (jtype, percent)
            exe.create_jobs(exceptlist=exceptlist, hours=100, jobType=jobType, jar=jarFile, parameters=parameters, include=None)

def execute_Arrival8():
    exe = Executor('./cmds')
    include = [8]
    types = ["Periodic"]#, "Aperiodic", "Sporadic"]
    jarFile = 'artifacts/StressTesting.jar'
    for percent in [0]:
        for jtype in types:
            jobType = 'ArrivalT8_%s%d' % (jtype, percent)
            parameters = '-i 2000 --incType %s --incRate 1.%02d' % (jtype, percent)
            exe.create_jobs(exceptlist=[], hours=100, jobType=jobType, jar=jarFile, parameters=parameters, include=include)
    exe.create_stop_script('ArrivalT8_2000')

def execute_ArrivalOrigin():
    exe = Executor('./cmds')
    exceptlist = [0, 1, 2, 3, 4, 5, 6, 14, 15, 16, 18, 19, 20, 21, 22, 23, 33, 34]
    jarFile = 'artifacts/StressTesting.jar'
    jobType = 'ArrivalOrigin'
    parameters = '--incType Periodic --incRate 1.00'
    exe.create_jobs(exceptlist=exceptlist, hours=48, jobType=jobType, jar=jarFile, parameters=parameters)
    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)

def execute_ArrivalWCET():
    exe = Executor('./cmds')
    # exceptlist = [0, 1, 2, 3, 4, 5, 6, 14, 15, 16, 18, 19, 20, 21, 22, 23, 33, 34]
    exceptlist = []
    include = [24,25]
    types = ["Periodic"]
    jarFile = 'artifacts/StressTesting.jar'
    for percent in [45]:
        for jtype in types:
            jobType = 'ArrivalWCET%s%d' % (jtype, percent)
            parameters = '-r 20 --incType %s --incRate 1.%02d' % (jtype, percent)
            exe.create_jobs(exceptlist=exceptlist, hours=60, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script('ArrivalWCET_P45R20')
    exe.create_remove_script('ArrivalWCET_P45R20')

def execute_varyWCET():
    exe = Executor('./cmds')
    exceptlist = [0, 1, 2, 3, 4, 5, 6, 14, 15, 16, 18, 19, 20, 21, 22, 23, 33, 34]
    include = None
    jarFile = 'artifacts/StressTesting.jar'
    jobType = 'varyWCET'
    parameters = '-r 1 --nSamples 20'
    exe.create_jobs(exceptlist=exceptlist, hours=80, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script('varyWCET2')
    exe.create_remove_script('varyWCET2')

def execute_varyExecutionsWCET(samples=20):
    exe = Executor('./cmds')
    exceptlist = [0, 1, 2, 3, 4, 5, 6, 14, 15, 16, 18, 19, 20, 21, 22, 23, 33, 34]
    include = None #[35]
    jarFile = 'artifacts/StressTesting.jar'
    jobType = 'varyExecutionsWCET%d' % samples
    parameters = '--nSamples %d -r 1' % samples
    exe.create_jobs(exceptlist=exceptlist, hours=120, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)

def test():
    exe = Executor('./cmds')
    exceptlist = []
    include = [6]
    jarFile = 'artifacts/StressTesting.jar'
    jobType = 'Data0111'
    parameters = '-r 2 -i 2 -p 2 --data res/LS_data_20190111_noSeq.csv'
    exe.create_jobs(exceptlist=exceptlist, hours=120, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)


def newdata():
    exe = Executor('./cmds')
    exceptlist = []
    include = [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34]
    jarFile = 'artifacts/StressTesting.jar'
    jobType = 'IN0111_OS_Origin'
    parameters = '-r 10'
    exe.create_jobs(exceptlist=exceptlist, hours=48, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)

    exe = Executor('./cmds')
    jobType = 'IN0111_OS'
    parameters = '-r 10 --data res/LS_data_20190111_oldSeq_newPriority.csv'
    exe.create_jobs(exceptlist=exceptlist, hours=48, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)

    exe = Executor('./cmds')
    include = [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31]
    jobType = 'IN0111_NoOS'
    parameters = '-r 10 --data res/LS_data_20190111_noSeq.csv'
    exe.create_jobs(exceptlist=exceptlist, hours=48, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)


def newdata_varyWCET(samples=20):
    exe = Executor('./cmds')
    exceptlist = []
    include = [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34]
    jarFile = 'artifacts/StressTesting.jar'
    jobType = 'IN0111_varyWCET%d_Origin' % samples
    parameters = '--nSamples %d -r 1' % samples
    exe.create_jobs(exceptlist=exceptlist, hours=120, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)

def newdata_varyWCET_T07(samples=20):
    exe = Executor('./cmds')
    exceptlist = []
    include = [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34]
    jarFile = 'artifacts/StressTesting.jar'
    jobType = 'IN0111_varyWCET%d_Origin_T0.7' % samples
    parameters = '--nSamples %d -r 1 --A12Threshold 0.7 --data res/LS_data_20190111_oldSeq_newPriority.csv' % samples
    exe.create_jobs(exceptlist=exceptlist, hours=120, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)

def newdata_specificWCET(threshold=0.5, data=''):
    exe = Executor('./cmds')
    exceptlist = []
    include = [6, 33, 34]
    jarFile = 'artifacts/StressTesting.jar'
    jobType = 'IN0111_specificWCET%s_A12%.1f' %(data[-7:-4],threshold)
    parameters = '-r 10 --A12Threshold %.1f --data res/%s' % (threshold, data)
    exe.create_jobs(exceptlist=exceptlist, hours=120, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)

def newdata_base(data=''):
    exe = Executor('./cmds')
    exceptlist = [0]
    include = None
    jarFile = 'artifacts/StressTesting.jar'
    jobType = 'IN0111_NoSeq_all'
    parameters = '-r 10 --data res/%s' % (data)
    exe.create_jobs(exceptlist=exceptlist, hours=48, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)

def SearchSafearea(data=''):
    exe = Executor('./cmds')
    exceptlist = [0]
    include = [34]
    jarFile = 'artifacts/StressTesting.jar'
    jobType = 'IN0321_1Uncertain'
    for nSamples in [10, 20, 30, 40]:
        parameters = '-r 1 --data res/%s --nSamples %d' % (data, nSamples)
        exe.create_jobs(exceptlist=exceptlist, hours=80,
                        jobType=jobType, jar=jarFile,
                        parameters=parameters, include=include,
                        append_t = '_Sample%s'%nSamples
                        )

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)

def SearchSafearea2(data=''):
    exe = Executor('./cmds')
    exceptlist = [0]
    include = [34]
    jarFile = 'artifacts/StressTesting.jar'
    jobType = 'IN0416_2Uncertain_Time'
    for nSamples in [2]:
        parameters = '-r 1 -i 50 -p 2 --data res/%s --nSamples %d' % (data, nSamples)
        exe.create_jobs(exceptlist=exceptlist, hours=120,
                        jobType=jobType, jar=jarFile,
                        parameters=parameters, include=include,
                        append_t = '_Sample%s'%nSamples
                        )

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)

def SearchSafearea_statistic(data=''):
    exe = Executor('./cmds')
    exceptlist = [0]
    include = [34]
    jarFile = 'artifacts/StressTesting.jar'
    jobType = 'IN0416_2Uncertain_Time2'
    for nSamples in [2, 5, 10, 20]:
        parameters = '-r 1 -i 50 --data res/%s --nSamples %d' % (data, nSamples)
        exe.create_jobs(exceptlist=exceptlist, hours=120,
                        jobType=jobType, jar=jarFile,
                        parameters=parameters, include=include,
                        append_t = '_Sample%s'%nSamples
                        )

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)


def SecondPhase(_targetPath, _nSample=40):
    exe = Executor('./cmds')
    exceptlist = [0]
    include = [34]
    jarFile = 'artifacts/SecondPhase.jar'

    parameters = '--iterMax 1000 --iterUpdate 10 --borderProb 0.5 --sampleCandidates 20 --nSamples %d' % _nSample
    exe.create_second_jobs(exceptlist=exceptlist, hours=120,
                           jobPath=_targetPath, jar=jarFile,
                           parameters=parameters, include=include, append_t="_Sample%d"%_nSample)

    exe.create_stop_script(_targetPath)
    exe.create_remove_script(_targetPath)


if __name__ == "__main__":

    # # # obj.test()
    # obj.newdata()
    # FirstPhase_Test4_power()
    # FirstPhase_Test5_cut()
    # FirstPhase_Test6_log()
    # FirstPhase_Test7_divide()
    # FirstPhase_Test8_best()
    FirstPhase_Sampling_Test2(10)
    FirstPhase_Sampling_Test2(20)
    # print('Hello!')
    # print('Hello!')

    # FirstPhase_Test3_2_best()       # double / new fitness / 2 best / single / 10런이라 늦음
    # FirstPhase_Test2()              # double / new fitness / single / 10 run이라 늦음
    # FirstPhase_Big_Test()           # Big    / old fitness / single / 10 run인데 완료....뭐지..?
    # FirstPhase_Sampling_Test1(10)   # double / new fitness / sample 10
    # FirstPhase_Sampling_Big_Test1(10)# big   / old fitness / sample 10
    # FirstPhase_Sampling_Test1(10, "--printSamples")       # double / new fitness / sample 10  (print용)
    # FirstPhase_Sampling_Big_Test1(10, "--printSamples")   # double / new fitness / sample 10 (print용)
    # FirstPhase_Sampling_Test1(40)
    # FirstPhase_Sampling_Big_Test1(40)

    # SearchSafearea_statistic('LS_data_20190416_oldSeq_newPriority.csv')
    # SecondPhase('20190327_IN0327_2Uncertain')
    # SecondPhase('20190426_IN0416_2Uncertain', _nSample=10)

    # obj.newdata_specificWCET(0.5, 'LS_data_20190111_Seq4.csv')
    # obj.newdata_specificWCET(0.5, 'LS_data_20190111_Seq3.7.csv')
    # obj.newdata_specificWCET(0.7, 'LS_data_20190111_Seq4.2.csv')
    # obj.newdata_specificWCET(0.7, 'LS_data_20190111_Seq4.csv')
    # obj.newdata_specificWCET(0.7, 'LS_data_20190111_Seq3.7.csv')
    # # obj.execute_varyExecutionsWCET(20)
    # # obj.execute_varyExecutionsWCET(30)
    # # obj.execute_varyExecutionsWCET(50)

    # obj = Executor('./cmds')
    # obj.make_arrivals('NewData2','20190116_Data0111_varyWCET20_oldSeqNewPriority', [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34], 5)
    # obj.make_arrivals('NewData2','20190116_Data0111_varyWCET20_oldSeqNewPriority', [33], 5)
    # obj.make_arrivals('OldSeqNewPriority','20190114_Data0111_varyWCET20_oldSeqNewPriority', [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 34], 5)
    # obj.make_arrivals('OldSeq','20190114_Data0111_varyWCET20_oldSeq', [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 34], 5)
    # obj.make_arrivals('OldSeqNewPriority','20190114_Data0111_varyWCET20_oldSeqNewPriority', [5], 5)
    # obj.make_arrivals('Test', '20190111_Data0111_varyWCET20_oldSeq', [6])
    # obj.make_arrivals('Test', '20190111_Data0111_varyWCET20_oldSeqNewPriority', [6])
    # obj.make_arrivals('Test', '20190111_Data0111_varyWCET20_newSeq', [6])