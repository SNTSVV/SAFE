import time
from utils.executor import Executor

def P2Ex02(workPath, testFuncName, testDataType, testSize, acceptP):
    '''
     2019.08.28 Phase 2, RQ2 compare random and distance based approach
     This experiment do not stop when they meet the termination condition.
    :return:
    '''
    exe = Executor('./cmds', "iris")
    jobName = 'P2Ex02'
    tasklist = [23]  #[3, 10, 14, 15, 16, 18]
    jarFile = 'artifacts/SecondPhase.jar'

    phase1PATH = "20190828_FirstPhase_Ex30_s20_GASearch"
    outputPATH = "20190828_SecondPhase_Ex30_s20_GASearch"
    approachs = ['random', 'distance']

    sample=20
    iter=1000
    iter_P2 = 10000
    nUpdate = 100
    probability = 0.5
    for runID_P1 in range(1, 3):
        for approach in approachs:
            for runID_P2 in range(1, 11):
                targets_txt = ','.join(['%d'%i for i in tasklist])
                parameters = '-t 0 --secondRuntype %s -e results/%s --targets \"%s\"'% (approach, outputPATH, targets_txt)
                parameters += ' --formulaPath formula/2D_S%d_%d --bestRun %d' % (sample, iter, runID_P1)
                parameters += ' --iterMax %d --iterUpdate %d --borderProb %.2f' % (iter_P2, nUpdate, probability)
                parameters += ' --workPath %s --runID %d' % (workPath, runID_P2)
                parameters += ' --testProbAccept %.3f' % (acceptP)
                parameters += ' --testFuncName %s  --testDataType %s' % (testFuncName, testDataType)
                parameters += ' --testSamples %d' % (testSize)
                parameters += ' --testData testdata_T%s_N20000_run%02d.csv' % (targets_txt, runID_P1)

                exe.create_job_secondphase(targetPath=phase1PATH, jar=jarFile, parameters=parameters,
                                           jobName=jobName,
                                           taskName='%s_%s_run%d_P2run%d'%(workPath, approach, runID_P1, runID_P2))

    exe.create_stop_script('%s_%s'%(jobName,workPath))
    exe.create_remove_script('%s_%s'%(jobName,workPath))

def P2Ex03(workPath, testFuncName, testDataType, testSize, acceptP):
    '''
     2019.08.28 Phase 2, RQ3 compare prev model and current model
     We will finish this experiment when we meet termination condition
    :return:
    '''
    exe = Executor('./cmds', "iris")
    jobName = 'P2Ex03'
    tasklist = [23]  #[3, 10, 14, 15, 16, 18]
    jarFile = 'artifacts/SecondPhase.jar'

    phase1PATH = "20190828_FirstPhase_Ex30_s20_GASearch"
    outputPATH = "20190828_SecondPhase_Ex30_s20_GASearch"
    approachs = ['distance']

    sample=20
    iter=1000
    iter_P2 = 10000
    nUpdate = 100
    probability = 0.5
    for runID_P1 in range(1, 3):
        for approach in approachs:
            for runID_P2 in range(1, 11):
                targets_txt = ','.join(['%d'%i for i in tasklist])
                parameters = '-t 0 --secondRuntype %s -e results/%s --targets \"%s\"'% (approach, outputPATH, targets_txt)
                parameters += ' --formulaPath formula/2D_S%d_%d --bestRun %d' % (sample, iter, runID_P1)
                parameters += ' --iterMax %d --iterUpdate %d --borderProb %.2f' % (iter_P2, nUpdate, probability)
                parameters += ' --workPath %s --runID %d' % (workPath, runID_P2)
                parameters += ' --testProbAccept %.3f' % (acceptP)
                parameters += ' --testFuncName %s  --testDataType %s' % (testFuncName, testDataType)
                parameters += ' --testSamples %d -x' % (testSize)
                parameters += ' --testData testdata_T%s_N20000_run%02d.csv' % (targets_txt, runID_P1)

                exe.create_job_secondphase(targetPath=phase1PATH, jar=jarFile, parameters=parameters,
                                           jobName=jobName,
                                           taskName='%s_%s_run%d_P2run%d'%(workPath, approach, runID_P1, runID_P2))

    exe.create_stop_script('%s_%s'%(jobName,workPath))
    exe.create_remove_script('%s_%s'%(jobName,workPath))


def Test(P1path, tasklist, nSamples, workPath, runs=0, runID=0, repeats=0):
    '''
     2019.08.02 Execute Ex08  :: for generating test points
    :return:
    '''
    exe = Executor('./cmds', "iris")
    jobName = 'Test' if runID==0 else 'Test%d'%runID
    jarFile = 'artifacts/TestDataGenerator.jar'
    targets_txt = ','.join(['%d'%i for i in tasklist])

    runs = [runID] if runs==0 else range(1,runs+1)
    for runID in runs:
        repeats = [0] if repeats==0 else range(1, repeats+1)
        for repeat in repeats:
            parameters = '-t 0 --targets \"%s\"'% (targets_txt)
            parameters += ' --bestRun %d' % (runID)
            parameters += ' --iterMax %d' % (nSamples)
            parameters += ' --workPath %s' % (workPath)
            parameters += ' --runID %d' % (repeat)
            exe.create_job_secondphase(targetPath=P1path, jar=jarFile, parameters=parameters,
                                       jobName=jobName, taskName='Test_%s_N%d_run%d'%(targets_txt, nSamples, runID))
    if runID != 0:
        exe.create_stop_script("%s_%s_N%d_run%d"%(jobName,targets_txt, nSamples, runID))
        exe.create_remove_script("%s_%s_N%d_run%d"%(jobName,targets_txt, nSamples, runID))
    else:
        exe.create_stop_script("%s_%s_N%d"%(jobName,targets_txt, nSamples))
        exe.create_remove_script("%s_%s_N%d"%(jobName,targets_txt, nSamples))


def P3Ex01(acceptP, workPath, runs=5):
    '''
     2019.08.02 Execute Ex08  :: Same condition for Ex05
    :return:
    '''
    exe = Executor('./cmds', "iris")
    jobName = 'P3Ex01'
    tasklist = [23]  #[3, 10, 14, 15, 16, 18]
    jarFile = 'artifacts/SecondPhase.jar'

    dataset = "20190820_FirstPhase_Ex30_s%d_GASearch"
    outputPATH = "20190820_SecondPhase_Ex30_s%d_GASearch"
    approachs = ['distance',]# 'random']
    bestRun = {5:{1000:9, 3000:5}, 10:{1000:5, 3000:9}, 20:{1000:2, 3000:6}, 40:{1000:10, 3000:10}}

    for approach in approachs:
        for sample in (20,):
            targetPath = dataset % (sample)
            outputPath = outputPATH % (sample)
            for iter in (1000,):#, 3000):  # first phase iteration
                # for iter_count in (10, 20):
                for iter_max in (10000,):
                    for iter_update in (100,):
                        for runID in range(1, runs+1):
                            for testDataType in ("initial",):# "training", "new"):# , "pool"):
                                for testFuncName in ("pr",):# "f1", "fpr", "f1.sep", "chi"):
                                    probability = 0.5
                                    targets_txt = ','.join(['%d'%i for i in tasklist])
                                    parameters = '-t 0 --secondRuntype %s -e results/%s --targets \"%s\"'% (approach, outputPath, targets_txt)
                                    parameters += ' --formulaPath formula/2D_S%d_%d --bestRun %d' % (sample, iter, bestRun[sample][iter])
                                    parameters += ' --iterMax %d --iterUpdate %d --borderProb %.2f' % (iter_max, iter_update, probability)
                                    parameters += ' --workPath %s_%s_%s --runID %d' % (workPath, testDataType, testFuncName, runID)
                                    parameters += ' --testProbAccept %.3f' % (acceptP)
                                    parameters += ' --testFuncName %s  --testDataType %s' % (testFuncName, testDataType)
                                    exe.create_job_secondphase(targetPath=targetPath, jar=jarFile, parameters=parameters,
                                                               jobName=jobName, taskName='%s_%s_S%d_%d_%d_%d_%.2f_run%d'%(workPath, approach, sample, iter, iter_max, iter_update, probability, runID))

    exe.create_stop_script('%s_%s'%(jobName,workPath))
    exe.create_remove_script('%s_%s'%(jobName,workPath))

def P3Ex02(acceptP, workPath, runs=5):
    '''
     2019.08.02 Execute Ex08  :: Same condition for Ex05
    :return:
    '''
    exe = Executor('./cmds', "iris")
    jobName = 'P3Ex02'
    tasklist = [23]  #[3, 10, 14, 15, 16, 18]
    jarFile = 'artifacts/SecondPhase.jar'

    dataset = "20190820_FirstPhase_Ex30_s%d_GASearch"
    outputPATH = "20190820_SecondPhase_Ex30_s%d_GASearch"
    approachs = ['random', 'distance']
    bestRun = {5:{1000:9, 3000:5}, 10:{1000:5, 3000:9}, 20:{1000:2, 3000:6}, 40:{1000:10, 3000:10}}

    for approach in approachs:
        for sample in (20,):
            targetPath = dataset % (sample)
            outputPath = outputPATH % (sample)
            for iter in (1000,):#, 3000):  # first phase iteration
                for initialSize in (5000, 1000, 2000, 3000, 4000):
                    # for iter_count in (10, 20):
                    for iter_max in (10000,):
                        for iter_update in (100,):
                            for runID in range(1, runs+1):
                                for testDataType in ("initial", "training", "new"):# , "pool"):
                                    for testFuncName in ("f1", "fpr", "f1.sep", "chi"):
                                        probability = 0.5
                                        targets_txt = ','.join(['%d'%i for i in tasklist])
                                        parameters = '-t 0 --secondRuntype %s -e results/%s --targets \"%s\"'% (approach, outputPath, targets_txt)
                                        parameters += ' --formulaPath formula/2D_S%d_%d --bestRun %d' % (sample, iter, bestRun[sample][iter])
                                        parameters += ' --iterMax %d --iterUpdate %d --borderProb %.2f' % (iter_max, iter_update, probability)
                                        parameters += ' --workPath %s_%s_%s --runID %d' % (workPath, testDataType, testFuncName, runID)
                                        parameters += ' --testProbAccept %.3f' % (acceptP)
                                        parameters += ' --testFuncName %s  --testDataType %s' % (testFuncName, testDataType)
                                        parameters += ' --LRinitSize %d' % (initialSize)
                                        exe.create_job_secondphase(targetPath=targetPath, jar=jarFile, parameters=parameters,
                                                                   jobName=jobName, taskName='%s_%s_S%d_%d_%d_%d_%.2f_run%d'%(workPath, approach, sample, iter, iter_max, iter_update, probability, runID))

    exe.create_stop_script('%s_%s'%(jobName,workPath))
    exe.create_remove_script('%s_%s'%(jobName,workPath))

def P3Ex04(acceptP, workPath, runs=5):
    '''
     2019.08.02 Execute Ex08  :: Same condition for Ex05
    :return:
    '''
    exe = Executor('./cmds', "iris")
    jobName = 'P3Ex04'
    tasklist = [23]  #[3, 10, 14, 15, 16, 18]
    jarFile = 'artifacts/SecondPhase.jar'

    dataset = "20190820_FirstPhase_Ex30_s%d_GASearch"
    outputPATH = "20190820_SecondPhase_Ex30_s%d_GASearch"
    approachs = ['random', 'distance']
    bestRun = {5:{1000:9, 3000:5}, 10:{1000:5, 3000:9}, 20:{1000:2, 3000:6}, 40:{1000:10, 3000:10}}

    for approach in approachs:
        for sample in (20,):
            targetPath = dataset % (sample)
            outputPath = outputPATH % (sample)
            for iter in (1000,):#, 3000):  # first phase iteration
                for testSize in (2000, 4000, 10000, 20000):
                    # for iter_count in (10, 20):
                    for iter_max in (10000,):
                        for iter_update in (100,):
                            for runID in range(1, runs+1):
                                for testDataType in ("pool",):# , "pool"):
                                    for testFuncName in ("f1", "fpr", "f1.sep", "chi"):
                                        probability = 0.5
                                        targets_txt = ','.join(['%d'%i for i in tasklist])
                                        parameters = '-t 0 --secondRuntype %s -e results/%s --targets \"%s\"'% (approach, outputPath, targets_txt)
                                        parameters += ' --formulaPath formula/2D_S%d_%d --bestRun %d' % (sample, iter, bestRun[sample][iter])
                                        parameters += ' --iterMax %d --iterUpdate %d --borderProb %.2f' % (iter_max, iter_update, probability)
                                        parameters += ' --workPath %s_%s_%s --runID %d' % (workPath, testDataType, testFuncName, runID)
                                        parameters += ' --testProbAccept %.3f' % (acceptP)
                                        parameters += ' --testFuncName %s  --testDataType %s' % (testFuncName, testDataType)
                                        parameters += ' --testSamples %d' % (testSize)
                                        exe.create_job_secondphase(targetPath=targetPath, jar=jarFile, parameters=parameters,
                                                                   jobName=jobName, taskName='%s_%s_S%d_%d_%d_%d_%.2f_run%d'%(workPath, approach, sample, iter, iter_max, iter_update, probability, runID))

    exe.create_stop_script('%s_%s'%(jobName,workPath))
    exe.create_remove_script('%s_%s'%(jobName,workPath))

def P3Ex05(acceptP, workPath, runs=5):
    '''
     2019.08.02 Execute Ex08  :: Same condition for Ex05
    :return:
    '''
    exe = Executor('./cmds', "iris")
    jobName = 'P3Ex05'
    tasklist = [23]  #[3, 10, 14, 15, 16, 18]
    jarFile = 'artifacts/SecondPhase.jar'

    dataset = "20190820_FirstPhase_Ex30_s%d_GASearch"
    outputPATH = "20190820_SecondPhase_Ex30_s%d_GASearch"
    approachs = ['distance']
    bestRun = {5:{1000:9, 3000:5}, 10:{1000:5, 3000:9}, 20:{1000:2, 3000:6}, 40:{1000:10, 3000:10}}

    for approach in approachs:
        for sample in (20,):
            targetPath = dataset % (sample)
            outputPath = outputPATH % (sample)
            for iter in (1000,):#, 3000):  # first phase iteration
                # for iter_count in (10, 20):
                for iter_max in (10000,):
                    for iter_update in (100,):
                        for runID in range(1, runs+1):
                            for testDataType in ("initial",):# , "pool"):
                                for testFuncName in ("pr", "f1", "fpr", "f1.sep", "chi"):
                                    probability = 0.5
                                    targets_txt = ','.join(['%d'%i for i in tasklist])
                                    parameters = '-t 0 --secondRuntype %s -e results/%s --targets \"%s\"'% (approach, outputPath, targets_txt)
                                    parameters += ' --formulaPath formula/2D_S%d_%d --bestRun %d' % (sample, iter, runID)
                                    parameters += ' --iterMax %d --iterUpdate %d --borderProb %.2f' % (iter_max, iter_update, probability)
                                    parameters += ' --workPath %s_%s_%s' % (workPath, testDataType, testFuncName)
                                    parameters += ' --testProbAccept %.3f' % (acceptP)
                                    parameters += ' --testFuncName %s  --testDataType %s' % (testFuncName, testDataType)
                                    exe.create_job_secondphase(targetPath=targetPath, jar=jarFile, parameters=parameters,
                                                               jobName=jobName, taskName='%s_%s_%s_%s_run%d'%(workPath, approach, testFuncName, testDataType, runID))

    exe.create_stop_script('%s_%s'%(jobName,workPath))
    exe.create_remove_script('%s_%s'%(jobName,workPath))

def P4Ex01(acceptP, workPath, runs=5):
    '''
     2019.08.02 Execute Ex08  :: RQ2 execute retest
    :return:
    '''
    exe = Executor('./cmds', "iris")
    jobName = 'P4Ex01'
    tasklist = [23]  #[3, 10, 14, 15, 16, 18]
    jarFile = 'artifacts/SecondPhase.jar'

    dataset = "20190820_FirstPhase_Ex30_s%d_GASearch"
    outputPATH = "20190820_SecondPhase_Ex30_s%d_GASearch"
    approachs = ['random', 'distance']

    for approach in approachs:
        for sample in (20,):
            targetPath = dataset % (sample)
            outputPath = outputPATH % (sample)
            for iter in (1000,):#, 3000):  # first phase iteration
                # for iter_count in (10, 20):
                for iter_max in (10000,):
                    for iter_update in (100,):
                        for runID in range(1, runs+1):
                            for testDataType in ("pool",):# , "pool"):
                                for testFuncName in ("f1",):# "f1", "fpr", "f1.sep", "chi"):
                                    probability = 0.5
                                    targets_txt = ','.join(['%d'%i for i in tasklist])
                                    parameters = '-t 0 --secondRuntype %s -e results/%s --targets \"%s\"'% (approach, outputPath, targets_txt)
                                    parameters += ' --formulaPath formula/2D_S%d_%d --bestRun %d' % (sample, iter, runID)
                                    parameters += ' --iterMax %d --iterUpdate %d --borderProb %.2f' % (iter_max, iter_update, probability)
                                    parameters += ' --workPath %s_%s_%s' % (workPath, testDataType, testFuncName)
                                    parameters += ' --testProbAccept %.3f' % (acceptP)
                                    parameters += ' --testFuncName %s  --testDataType %s -x' % (testFuncName, testDataType)
                                    parameters += ' --testSamples %d -x' % (20000)
                                    exe.create_job_secondphase(targetPath=targetPath, jar=jarFile, parameters=parameters,
                                                               jobName=jobName, taskName='%s_%s_%s_%s_run%d'%(workPath, approach, testFuncName, testDataType, runID))

    exe.create_stop_script('%s_%s'%(jobName,workPath))
    exe.create_remove_script('%s_%s'%(jobName,workPath))

def P5Ex01(acceptP, workPath, runs=10):
    '''
     2019.08.02 Execute Ex08  :: RQ3 execute retest  (pool with f1)
    :return:
    '''
    exe = Executor('./cmds', "iris")
    jobName = 'P5Ex01'
    tasklist = [23]  #[3, 10, 14, 15, 16, 18]
    jarFile = 'artifacts/SecondPhase.jar'

    dataset = "20190820_FirstPhase_Ex30_s%d_GASearch"
    outputPATH = "20190820_SecondPhase_Ex30_s%d_GASearch"
    approachs = ['distance']

    for approach in approachs:
        for sample in (20,):
            targetPath = dataset % (sample)
            outputPath = outputPATH % (sample)
            for iter in (1000,):#, 3000):  # first phase iteration
                # for iter_count in (10, 20):
                for iter_max in (10000,):
                    for iter_update in (100,):
                        for runID in range(1, runs+1):
                            for testDataType in ("pool",):# , "pool"):
                                for testFuncName in ("f1.sep",):# "f1", "fpr", "f1.sep", "chi"):
                                    for testSize in (2000,):
                                        probability = 0.5
                                        targets_txt = ','.join(['%d'%i for i in tasklist])
                                        parameters = '-t 0 --secondRuntype %s -e results/%s --targets \"%s\"'% (approach, outputPath, targets_txt)
                                        parameters += ' --formulaPath formula/2D_S%d_%d --bestRun %d' % (sample, iter, runID)
                                        parameters += ' --iterMax %d --iterUpdate %d --borderProb %.2f' % (iter_max, iter_update, probability)
                                        parameters += ' --workPath %s_%s_%s' % (workPath, testDataType, testFuncName)
                                        parameters += ' --testProbAccept %.3f' % (acceptP)
                                        parameters += ' --testFuncName %s  --testDataType %s' % (testFuncName, testDataType)
                                        parameters += ' --testSamples %d -x' % (testSize)
                                        parameters += ' --testData testdata_T23_N20000_run02.csv'

                                        exe.create_job_secondphase(targetPath=targetPath, jar=jarFile, parameters=parameters,
                                                                   jobName=jobName, taskName='%s_%s_%s_%s_T%d_run%d'%(workPath, approach, testFuncName, testDataType, testSize, runID))

    exe.create_stop_script('%s_%s'%(jobName,workPath))
    exe.create_remove_script('%s_%s'%(jobName,workPath))


if __name__ == "__main__":
    # for RQ2
    # P2Ex02("RQ2_N2000_pool_f1.sep", testFuncName="f1.sep", testDataType="pool", testSize=2000, acceptP=0.001)
    # for RQ3
    # P2Ex03("RQ3_N2000_pool_f1.sep", testFuncName="f1.sep", testDataType="pool", testSize=2000, acceptP=0.001)

    # P4Ex01(acceptP=0.001, workPath="RQ2_R10_U100", runs=10) # first phase run
    # P5Ex01(acceptP=0.001, workPath="RQ3_R10_U100", runs=10) # first phase run

    # Executed
    # Test('20190828_FirstPhase_Ex30_s20_GASearch', [23], 200, 'testdata_even1', runID=1, repeats=50)
    # Test('20190828_FirstPhase_Ex30_s20_GASearch', [23], 200, 'testdata_even1', runID=2, repeats=50)
    # Test('20190828_FirstPhase_Ex30_s20_GASearch', [23], 200, 'testdata_even1', runID=3, repeats=50)
    # Test('20190828_FirstPhase_Ex30_s20_GASearch', [23], 200, 'testdata_even1', runID=4, repeats=50)
    # Test('20190828_FirstPhase_Ex30_s20_GASearch', [23], 200, 'testdata_even1', runID=5, repeats=50)
    # Test('20190828_FirstPhase_Ex30_s20_GASearch', [23], 200, 'testdata_even1', runID=6, repeats=50)
    # Test('20190828_FirstPhase_Ex30_s20_GASearch', [23], 200, 'testdata_even1', runID=7, repeats=50)
    # Executing


    # Will be executed
    Test('20190828_FirstPhase_Ex30_s20_GASearch', [23], 200, 'testdata_even1', runID=8, repeats=50)
    # Test('20190828_FirstPhase_Ex30_s20_GASearch', [23], 200, 'testdata_even1', runID=9, repeats=50)
    # Test('20190828_FirstPhase_Ex30_s20_GASearch', [23], 200, 'testdata_even1', runID=10, repeats=50)

    # T.B.A
    # Test('20190820_FirstPhase_Ex30_s20_GASearch', [23], 200, 'testdata', runID=2, repeats=50)
    # Test('20190820_FirstPhase_Ex30_s20_GASearch', [23], 1000, 'testdata', runs=10)
    # Test('20190820_FirstPhase_Ex30_s20_GASearch', [23], 10000, 'testdata', runs=10)
    # Test('20190820_FirstPhase_Ex30_s20_GASearch', [3,14,15,16,18], 100, 'testdata', runs=10)
    # Test('20190820_FirstPhase_Ex30_s20_GASearch', [3,14,15,16,18], 1000, 'testdata', runs=10)
    # Test('20190820_FirstPhase_Ex30_s20_GASearch', [3,14,15,16,18], 10000, 'testdata', runs=10)
    # Test('20190820_FirstPhase_Ex30_s20_GASearch', [3,10,14,15,16,18,23], 100, 'testdata', runs=10)
    # Test('20190820_FirstPhase_Ex30_s20_GASearch', [3,10,14,15,16,18,23], 1000, 'testdata', runs=10)
    # Test('20190820_FirstPhase_Ex30_s20_GASearch', [3,10,14,15,16,18,23], 10000, 'testdata', runs=10)

