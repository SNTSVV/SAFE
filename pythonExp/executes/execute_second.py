import time
from utils.executor import Executor

def Second_Ex01(params=''):
    '''
     2019.08.01 Execute Ex01
    :return:
    '''
    exe = Executor('./cmds', "iris")
    jobName = 'P2_Ex01'
    tasklist = [23]
    jarFile = 'artifacts/SecondCompare.jar'

    dataset = "20190722_FirstPhase_Ex30_s%d_GASearch"
    approachs = ['random', 'distance']
    bestRun = {5:{1000:9, 3000:5}, 10:{1000:5, 3000:9}, 20:{1000:2, 3000:6}, 40:{1000:10, 3000:10}}

    for taskID in tasklist:
        for approach in approachs:
            for sample in (5, 10, 20):
                targetPath = dataset % (sample) + '/Task%02d'%taskID
                for iter in (1000, 3000):  # first phase iteration
                    for iter_max in (1000, 5000):
                        for iter_update in (50, 100, 150, 200):
                            parameters = '-t %d --secondRuntype %s'% (taskID, approach)
                            parameters += ' --formulaPath formula/S%d_%d_simple --sampleData %d --bestRun %d' % (sample, iter, iter, bestRun[sample][iter])
                            parameters += ' --iterMax %d --iterUpdate %d' % (iter_max, iter_update)
                            exe.create_job_secondphase(targetPath=targetPath, jar=jarFile, parameters=parameters,
                                                       jobName=jobName, taskName='T%d_%s_S%d_%d_%d_%d'%(taskID, approach, sample, iter, iter_max, iter_update))

    exe.create_stop_script(jobName)
    exe.create_remove_script(jobName)


def Second_Ex02(params=''):
    '''
     2019.08.01 Execute Ex02
    :return:
    '''
    exe = Executor('./cmds', "iris")
    jobName = 'P2_Ex02'
    tasklist = [23]
    jarFile = 'artifacts/SecondCompare.jar'

    dataset = "20190722_FirstPhase_Ex30_s%d_GASearch"
    approachs = ['random', 'distance']
    bestRun = {5:{1000:9, 3000:5}, 10:{1000:5, 3000:9}, 20:{1000:2, 3000:6}, 40:{1000:10, 3000:10}}

    for taskID in tasklist:
        for approach in approachs:
            for sample in (5, 10, 20):
                targetPath = dataset % (sample) + '/Task%02d'%taskID
                for iter in (1000, 3000):  # first phase iteration
                    for iter_max in (1000, 5000):
                        for iter_update in (50, 100, 150, 200):
                            parameters = '-t %d --secondRuntype %s'% (taskID, approach)
                            parameters += ' --formulaPath formula/S%d_%d_simple --sampleData %d --bestRun %d' % (sample, iter, iter, bestRun[sample][iter])
                            parameters += ' --iterMax %d --iterUpdate %d --borderProb 0.01' % (iter_max, iter_update)
                            exe.create_job_secondphase(targetPath=targetPath, jar=jarFile, parameters=parameters,
                                                       jobName=jobName, taskName='T%d_%s_S%d_%d_%d_%d_0.01'%(taskID, approach, sample, iter, iter_max, iter_update))

    exe.create_stop_script(jobName)
    exe.create_remove_script(jobName)


def Second_Ex03(formulaType, probability):
    '''
     2019.08.02 Execute Ex04  :: support lionel's advice
    :return:
    '''
    exe = Executor('./cmds', "iris")
    jobName = 'P2_Ex03'
    tasklist = [23]
    jarFile = 'artifacts/SecondCompare.jar'

    dataset = "20190722_FirstPhase_Ex30_s%d_GASearch"
    approachs = ['random', 'distance']
    bestRun = {5:{1000:9, 3000:5}, 10:{1000:5, 3000:9}, 20:{1000:2, 3000:6}, 40:{1000:10, 3000:10}}

    for taskID in tasklist:
        for approach in approachs:
            for sample in (5,):
                targetPath = dataset % (sample) + '/Task%02d'%taskID
                for iter in (1000, 3000):  # first phase iteration
                    for iter_max in (1000, 5000):
                        for iter_update in (50, 100, 150, 200):
                            parameters = '-t %d --secondRuntype %s'% (taskID, approach)
                            parameters += ' --formulaPath formula/%sS%d_%d_simple --sampleData %d --bestRun %d' % (formulaType, sample, iter, iter, bestRun[sample][iter])
                            parameters += ' --iterMax %d --iterUpdate %d --borderProb %.2f' % (iter_max, iter_update, probability)
                            exe.create_job_secondphase(targetPath=targetPath, jar=jarFile, parameters=parameters,
                                                       jobName=jobName, taskName='T%d_%s_S%d_%d_%d_%d_%.2f'%(taskID, approach, sample, iter, iter_max, iter_update, probability))

    exe.create_stop_script(jobName)
    exe.create_remove_script(jobName)


def Second_Ex04(formulaType, probability):
    '''
     2019.08.02 Execute Ex04  :: support lionel's advice
    :return:
    '''
    exe = Executor('./cmds', "iris")
    jobName = 'P2Ex04_3000'
    tasklist = [23]
    jarFile = 'artifacts/SecondCompare.jar'

    dataset = "20190722_FirstPhase_Ex30_s%d_GASearch"
    approachs = ['random', 'distance']
    bestRun = {5:{1000:9, 3000:5}, 10:{1000:5, 3000:9}, 20:{1000:2, 3000:6}, 40:{1000:10, 3000:10}}

    for taskID in tasklist:
        for approach in approachs:
            for sample in (5,10,20):
                targetPath = dataset % (sample) + '/Task%02d'%taskID
                for iter in (3000,):#, 3000):  # first phase iteration
                    for iter_count in (10, 20):
                        iter_update = iter * sample
                        iter_max = iter_update * iter_count
                        parameters = '-t %d --secondRuntype %s'% (taskID, approach)
                        parameters += ' --formulaPath formula/%sS%d_%d --sampleData %d --bestRun %d' % (formulaType, sample, iter, iter, bestRun[sample][iter])
                        parameters += ' --iterMax %d --iterUpdate %d --borderProb %.2f' % (iter_max, iter_update, probability)
                        parameters += ' --workPath thirds'
                        exe.create_job_secondphase(targetPath=targetPath, jar=jarFile, parameters=parameters,
                                                   jobName=jobName, taskName='T%d_%s_S%d_%d_%d_%d_%.2f'%(taskID, approach, sample, iter, iter_max, iter_update, probability))

    exe.create_stop_script('%s_%s%.2f'%(jobName,formulaType,probability))
    exe.create_remove_script('%s_%s%.2f'%(jobName,formulaType,probability))


def Second_Ex05(formulaType, probability, initSize, workPath):
    '''
     2019.08.02 Execute Ex05  :: 2D  formula with specified run
    :return:
    '''
    exe = Executor('./cmds', "iris")
    jobName = 'P2Ex05'
    tasklist = [23]
    jarFile = 'artifacts/SecondCompare.jar'

    dataset = "20190722_FirstPhase_Ex30_s%d_GASearch"
    approachs = ['random', 'distance']
    bestRun = {5:{1000:9, 3000:5}, 10:{1000:5, 3000:9}, 20:{1000:2, 3000:6}, 40:{1000:10, 3000:10}}

    for taskID in tasklist:
        for approach in approachs:
            for sample in (20,):
                targetPath = dataset % (sample) + '/Task%02d'%taskID
                for iter in (1000,):#, 3000):  # first phase iteration
                    # for iter_count in (10, 20):
                    for iter_max in (50000,):# 10000):
                        for iter_update in (100,):
                            # iter_update = iter * sample
                            # iter_max = iter_update * iter_count
                            parameters = '-t %d --secondRuntype %s'% (taskID, approach)
                            parameters += ' --formulaPath formula/%sS%d_%d --sampleData %d --bestRun %d' % (formulaType, sample, iter, iter, bestRun[sample][iter])
                            parameters += ' --iterMax %d --iterUpdate %d --borderProb %.2f' % (iter_max, iter_update, probability)
                            parameters += ' --workPath %s --LRinitSize %d' % (workPath, initSize)
                            exe.create_job_secondphase(targetPath=targetPath, jar=jarFile, parameters=parameters,
                                                       jobName=jobName, taskName='T%d_%s_S%d_%d_%d_%d_%.2f'%(taskID, approach, sample, iter, iter_max, iter_update, probability))

    exe.create_stop_script('%s_%s%.2f_%s'%(jobName,formulaType,probability,workPath))
    exe.create_remove_script('%s_%s%.2f_%s'%(jobName,formulaType,probability,workPath))


def Second_Ex06(formulaType, probability, initSize, workPath):
    '''
     2019.08.02 Execute Ex06  :: for 10 runs
    :return:
    '''
    exe = Executor('./cmds', "iris")
    jobName = 'P2Ex06_1000'
    tasklist = [23]
    jarFile = 'artifacts/SecondCompare.jar'

    dataset = "20190722_FirstPhase_Ex30_s%d_GASearch"
    approachs = ['random', 'distance']
    # bestRun = {5:{1000:9, 3000:5}, 10:{1000:5, 3000:9}, 20:{1000:2, 3000:6}, 40:{1000:10, 3000:10}}

    for taskID in tasklist:
        for approach in approachs:
            for sample in (20,):
                targetPath = dataset % (sample) + '/Task%02d'%taskID
                for iter in (1000,):#, 3000):  # first phase iteration
                    # for iter_count in (10, 20):
                    for iter_max in (10000,):
                        for iter_update in (200,):
                            for bestRun in range(1, 11):
                                # iter_update = iter * sample
                                # iter_max = iter_update * iter_count
                                parameters = '-t %d --secondRuntype %s'% (taskID, approach)
                                parameters += ' --formulaPath formula/%sS%d_%d --sampleData %d --bestRun %d' % (formulaType, sample, iter, iter, bestRun)
                                parameters += ' --iterMax %d --iterUpdate %d --borderProb %.2f' % (iter_max, iter_update, probability)
                                parameters += ' --workPath %s --LRinitSize %d' % (workPath, initSize)
                                exe.create_job_secondphase(targetPath=targetPath, jar=jarFile, parameters=parameters,
                                                           jobName=jobName, taskName='T%d_%s_S%d_%d_%d_%d_%.2f_run%d'%(taskID, approach, sample, iter, iter_max, iter_update, probability, bestRun))

    exe.create_stop_script('%s_%s%.2f_%s'%(jobName,formulaType,probability,workPath))
    exe.create_remove_script('%s_%s%.2f_%s'%(jobName,formulaType,probability,workPath))

def Second_Ex07(formulaType, probability, initSize, workPath):
    '''
     2019.08.02 Execute Ex05  :: 2D  formula with specified run
    :return:
    '''
    exe = Executor('./cmds', "iris")
    jobName = 'P2Ex07'
    tasklist = [23]
    jarFile = 'artifacts/SecondCompare.jar'

    dataset = "20190722_FirstPhase_Ex30_s%d_GASearch"
    approachs = ['random', 'distance']
    bestRun = {5:{1000:9, 3000:5}, 10:{1000:5, 3000:9}, 20:{1000:2, 3000:6}, 40:{1000:10, 3000:10}}

    for taskID in tasklist:
        for approach in approachs:
            for sample in (20,):
                targetPath = dataset % (sample) + '/Task%02d'%taskID
                for iter in (1000,):#, 3000):  # first phase iteration
                    # for iter_count in (10, 20):
                    for iter_max in (5000, 10000):
                        for iter_update in (100,): #,150): #(50, 100, 150, 200):
                            for runID in range(1, 11):
                                # iter_update = iter * sample
                                # iter_max = iter_update * iter_count
                                parameters = '-t %d --secondRuntype %s'% (taskID, approach)
                                parameters += ' --formulaPath formula/%sS%d_%d --sampleData %d --bestRun %d' % (formulaType, sample, iter, iter, bestRun[sample][iter])
                                parameters += ' --iterMax %d --iterUpdate %d --borderProb %.2f' % (iter_max, iter_update, probability)
                                parameters += ' --workPath %s --LRinitSize %d --runID %d' % (workPath, initSize,runID )
                                exe.create_job_secondphase(targetPath=targetPath, jar=jarFile, parameters=parameters,
                                                           jobName=jobName, taskName='T%d_%s_S%d_%d_%d_%d_%.2f'%(taskID, approach, sample, iter, iter_max, iter_update, probability))

    exe.create_stop_script('%s_%s%.2f_%s'%(jobName,formulaType,probability,workPath))
    exe.create_remove_script('%s_%s%.2f_%s'%(jobName,formulaType,probability,workPath))

def Second_Ex08(formulaType, probability, initSize, workPath):
    '''
     2019.08.02 Execute Ex08  :: Same condition for Ex05
    :return:
    '''
    exe = Executor('./cmds', "iris")
    jobName = 'P2Ex08'
    tasklist = [23]  #[3, 10, 14, 15, 16, 18]
    jarFile = 'artifacts/SecondCompare.jar'

    dataset = "20190722_FirstPhase_Ex30_s%d_GASearch"
    approachs = ['random', 'distance']
    bestRun = {5:{1000:9, 3000:5}, 10:{1000:5, 3000:9}, 20:{1000:2, 3000:6}, 40:{1000:10, 3000:10}}

    for taskID in tasklist:
        for approach in approachs:
            for sample in (20,):
                targetPath = dataset % (sample) + '/Task%02d'%taskID
                for iter in (1000,):#, 3000):  # first phase iteration
                    # for iter_count in (10, 20):
                    for iter_max in (20000,):
                        for iter_update in (100,):
                            for probability in (0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.09, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9):
                                # iter_update = iter * sample
                                # iter_max = iter_update * iter_count
                                parameters = '-t %d --secondRuntype %s'% (taskID, approach)
                                parameters += ' --formulaPath formula/%sS%d_%d --sampleData %d --bestRun %d' % (formulaType, sample, iter, iter, bestRun[sample][iter])
                                parameters += ' --iterMax %d --iterUpdate %d --borderProb %.2f' % (iter_max, iter_update, probability)
                                parameters += ' --workPath %s --LRinitSize %d' % (workPath, initSize)
                                exe.create_job_secondphase(targetPath=targetPath, jar=jarFile, parameters=parameters,
                                                           jobName=jobName, taskName='T%d_%s_S%d_%d_%d_%d_%.2f'%(taskID, approach, sample, iter, iter_max, iter_update, probability))

    exe.create_stop_script('%s_%s%.2f_%s'%(jobName,formulaType,probability,workPath))
    exe.create_remove_script('%s_%s%.2f_%s'%(jobName,formulaType,probability,workPath))

def Second_Ex09(formulaType, minP, maxP, sDist, workPath):
    '''
     2019.08.02 Execute Ex09  :: Getting test data, with range
    :return:
    '''
    exe = Executor('./cmds', "iris")
    jobName = 'P2Ex09'
    tasklist = [23]#[3, 10, 14, 15, 16, 18, 23]
    jarFile = 'artifacts/SecondCompare.jar'

    dataset = "20190722_FirstPhase_Ex30_s%d_GASearch"
    approachs = ['range']
    probability = 0.5
    bestRun = {5:{1000:9, 3000:5}, 10:{1000:5, 3000:9}, 20:{1000:2, 3000:6}, 40:{1000:10, 3000:10}}

    for taskID in tasklist:
        for approach in approachs:
            for sample in (20,):
                targetPath = dataset % (sample) + '/Task%02d'%taskID
                for iter in (1000,):#, 3000):  # first phase iteration
                    # for iter_count in (10, 20):
                    for iter_max in (40000,):
                        for iter_update in (40000,):
                            # iter_update = iter * sample
                            # iter_max = iter_update * iter_count
                            parameters = '-t %d --secondRuntype %s'% (taskID, approach)
                            parameters += ' --formulaPath formula/%sS%d_%d --sampleData %d --bestRun %d' % (formulaType, sample, iter, iter, bestRun[sample][iter])
                            parameters += ' --iterMax %d --iterUpdate %d --borderProb %.2f' % (iter_max, iter_update, probability)
                            parameters += ' --workPath %s --minProb %.5f --maxProb %.5f --sampleDist %d' % (workPath, minP, maxP, sDist)
                            exe.create_job_secondphase(targetPath=targetPath, jar=jarFile, parameters=parameters,
                                                           jobName=jobName, taskName='T%d_%s_S%d_%d_%d_%d_%.2f'%(taskID, approach, sample, iter, iter_max, iter_update, probability))

    exe.create_stop_script('%s_%s%.2f_%s'%(jobName,formulaType,probability,workPath))
    exe.create_remove_script('%s_%s%.2f_%s'%(jobName,formulaType,probability,workPath))

def Second_Ex10(formulaType, minP, maxP, sDist, workPath):
    '''
     2019.08.02 Execute Ex10  :: Getting test data, with range (for each run of phase 1)
    :return:
    '''
    exe = Executor('./cmds', "iris")
    jobName = 'P2Ex10'
    tasklist = [23]#[3, 10, 14, 15, 16, 18, 23]
    jarFile = 'artifacts/SecondCompare.jar'

    dataset = "20190722_FirstPhase_Ex30_s%d_GASearch"
    approachs = ['range']
    probability = 0.5


    for taskID in tasklist:
        for approach in approachs:
            for sample in (20,):
                targetPath = dataset % (sample) + '/Task%02d'%taskID
                for iter in (1000,):#, 3000):  # first phase iteration
                    # for iter_count in (10, 20):
                    for iter_max in (20000,):
                        for iter_update in (20000,):
                            for runID in range(1, 11):
                                # iter_update = iter * sample
                                # iter_max = iter_update * iter_count
                                parameters = '-t %d --secondRuntype %s'% (taskID, approach)
                                parameters += ' --formulaPath formula/%sS%d_%d --sampleData %d --bestRun %d' % (formulaType, sample, iter, iter, runID)
                                parameters += ' --iterMax %d --iterUpdate %d --borderProb %.2f' % (iter_max, iter_update, probability)
                                parameters += ' --workPath %s --minProb %.5f --maxProb %.5f --sampleDist %d' % (workPath, minP, maxP, sDist)
                                exe.create_job_secondphase(targetPath=targetPath, jar=jarFile, parameters=parameters,
                                                           jobName=jobName, taskName='T%d_%s_S%d_%d_%d_%d_%.2f'%(taskID, approach, sample, iter, iter_max, iter_update, probability))

    exe.create_stop_script('%s_%s%.2f_%s'%(jobName,formulaType,probability,workPath))
    exe.create_remove_script('%s_%s%.2f_%s'%(jobName,formulaType,probability,workPath))

def Second_Ex11(formulaType, probability, initSize, workPath):
    '''
     2019.08.02 Execute Ex05  :: 2D  formula with specified run
    :return:
    '''
    exe = Executor('./cmds', "iris")
    jobName = 'P2Ex11'
    tasklist = [23]
    jarFile = 'artifacts/SecondCompare.jar'

    dataset = "20190828_FirstPhase_Ex30_s%d_GASearch"
    approachs = ['random', 'distance']
    bestRun = {5:{1000:9, 3000:5}, 10:{1000:5, 3000:9}, 20:{1000:2, 3000:6}, 40:{1000:10, 3000:10}}

    for taskID in tasklist:
        for approach in approachs:
            for sample in (20,):
                targetPath = dataset % (sample) + '/Task%02d'%taskID
                for iter in (1000,):#, 3000):  # first phase iteration
                    for iter_max in (5000,):# 10000):
                        for iter_update in (100,):
                            bestRun = 2
                            parameters = '-t %d --secondRuntype %s'% (taskID, approach)
                            parameters += ' --formulaPath formula/%sS%d_%d --bestRun %d' % (formulaType, sample, iter, bestRun)
                            parameters += ' --iterMax %d --iterUpdate %d --borderProb %.2f' % (iter_max, iter_update, probability)
                            parameters += ' --workPath %s --LRinitSize %d' % (workPath, initSize)
                            exe.create_job_secondphase(targetPath=targetPath, jar=jarFile, parameters=parameters,
                                                       jobName=jobName, taskName='T%d_%s_S%d_%d_%d_%d_%.2f'%(taskID, approach, sample, iter, iter_max, iter_update, probability))

    exe.create_stop_script('%s_%s%.2f_%s'%(jobName,formulaType,probability,workPath))
    exe.create_remove_script('%s_%s%.2f_%s'%(jobName,formulaType,probability,workPath))

if __name__ == "__main__":
    # Second_Ex05('2D_', 0.5, 0, "Sec5_2D_full")    # 1% Probability
    # Second_Ex05('2D_', 0.01, 0, "Sec5_2D_full")    # 50% Probability
    # Second_Ex05('2D_', 0.5, 5000, "Sec5_2D_5000")    # 1% Probability
    # Second_Ex05('2D_', 0.01, 5000, "Sec5_2D_5000")    # 50% Probability
    # Second_Ex05('2D_', 0.5, 1000, "Sec5_2D_1000")    # 1% Probability
    # Second_Ex05('2D_', 0.01, 1000, "Sec5_2D_1000")    # 50% Probability
    # Second_Ex05('2D_', 0.5, 2000, "Sec5_2D_2000")    # 1% Probability
    # Second_Ex05('2D_', 0.01, 2000, "Sec5_2D_2000")    # 50% Probability
    # Second_Ex05('2D_', 0.5, 3000, "Sec5_2D_3000")    # 1% Probability
    # Second_Ex05('2D_', 0.01, 3000, "Sec5_2D_3000")    # 50% Probability
    # Second_Ex05('2D_', 0.5, 0, "Sec5_2D_full_long")    # 1% Probability
    # Second_Ex07('2D_', 0.5, 1000, "Sec7_2D_init1000")    # 50% Probability
    Second_Ex11('2D_', 0.5, 0, "Sec11_2D_full")    # 50% Probability
    # Second_Ex06('', 0.01)    # simple reduced, 1% Probability
    # Second_Ex06('PREComplex_', 0.01)    # simple reduced, 1% Probability
    # Second_Ex06('2D_', 0.01, 0, "Sec6_2D_eval0.01")    # simple reduced, 50% Probability
    # Second_Ex06('2D_', 0.5, 0, "Sec6_2D_eval0.5")    # simple reduced, 50% Probability

    # Second_Ex06('2D_', 0.01, 1000, "Sec6_2D_init1000")    # simple reduced, 50% Probability
    # Second_Ex06('2D_', 0.5, 1000, "Sec6_2D_init1000")    # simple reduced, 50% Probability
    # Second_Ex06('2D_', 0.01, 2000, "Sec6_2D_init2000")    # simple reduced, 50% Probability
    # Second_Ex06('2D_', 0.5, 2000, "Sec6_2D_init2000")    # simple reduced, 50% Probability
    # Second_Ex06('2D_', 0.01, 3000, "Sec6_2D_init3000")    # simple reduced, 50% Probability
    # Second_Ex06('2D_', 0.5, 3000, "Sec6_2D_init3000")    # simple reduced, 50% Probability

    # Second_Ex08('2D_', 0, initSize=0, workPath="Sec8_2D_full")    # 1% Probability
    # Second_Ex09('2D_', minP=0.001, maxP=0.999, sDist=0, workPath="2D_eval_range0.001")    # 1% Probability
    # Second_Ex09('2D_', minP=0.0001, maxP=0.9999, sDist=0, workPath="2D_eval_range0.0001")    # 1% Probability
    # Second_Ex09('2D_', minP=0.001, maxP=0.999, sDist=1000, workPath="2D_eval_range0.001_d1000")    # 1% Probability
    # Second_Ex09('2D_', minP=0.0001, maxP=0.9999, sDist=1000, workPath="2D_eval_range0.0001_d1000")    # 1% Probability
    #
    # Second_Ex10('2D_', minP=0.001, maxP=0.999, sDist=0, workPath="2D_eval_multi_range0.001")    # 1% Probability
    # Second_Ex10('2D_', minP=0.0001, maxP=0.9999, sDist=0, workPath="2D_eval_multi_range0.0001")    # 1% Probability
    # Second_Ex10('2D_', minP=0.001, maxP=0.999, sDist=1000, workPath="2D_eval_multi_range0.001_d1000")    # 1% Probability
    # Second_Ex10('2D_', minP=0.0001, maxP=0.9999, sDist=1000, workPath="2D_eval_multi_range0.0001_d1000")    # 1% Probability
