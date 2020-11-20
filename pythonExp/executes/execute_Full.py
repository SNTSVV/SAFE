import time
from utils.executor import Executor


def P1Ex02(jobName='P1', resource='', params='', runMAX=10, uniform=False, execParam=''):
    '''
     2019.07.17 Test for first phase. (population: vary, sample:5, RS and GA)
    :return:
    '''
    exe = Executor('./cmds', "iris")
    # tasklist = [23, 30, 33] #[3, 10, 14, 15, 16, 18]  #7,8,9,
    jarFile = 'artifacts/FirstPhase%s.jar' % execParam

    approachs = ['GASearch']#['RandomSearch', 'GASearch']
    for approach in approachs:
        for sample in (20,):
            for runID in range(1, runMAX+1):
                parameters = '%s -r %d --runID %d -i 1000 --nSamples %d' % (jobName, runMAX, runID, sample)
                parameters += ' --printResults --extendScheduler --data res/%s %s' % (resource, params)
                # parameters += ' -t %s' % (','.join([str(task) for task in tasklist]))
                if approach == 'RandomSearch':
                    parameters += ' --simpleSearch '
                if uniform is True:
                    parameters += ' --cType uniform'
                exe.create_job(jobName='%s_S%d_%s'%(jobName, sample, approach), jar=jarFile, parameters=parameters, runID=runID)

    exe.create_stop_script(jobName)
    exe.create_remove_script(jobName)


def Test(P1path, tasklist, nSamples, workName, runs=None, runID=0, repeats=0):
    '''
     2019.08.02 Execute :: for generating test points from Phase1
    :return:
    '''
    exe = Executor('./cmds', "iris")
    jobName = 'Test' if runID==0 else 'Test%d'%runID
    jarFile = 'artifacts/TestGenerator.jar'
    targets_txt = ','.join(['%d'%i for i in tasklist])

    runs = range(1, runs+1) if isinstance(runs, int) is True else runs
    for runID in runs:
        if isinstance(repeats, int) is True and repeats == 0:
            # parameters = '-t \"%s\"'% (targets_txt)
            parameters = ' -w %s' % (workName)
            parameters += ' --runID %d' % (runID)
            parameters += ' --exPoints %d' % (nSamples)
            exe.create_job_secondphase(targetPath=P1path, jar=jarFile, parameters=parameters,
                                   jobName='Test_%s'%P1path, taskName='Test_r%d_N%d'%(runID, nSamples))
        else:
            repeats = range(1, repeats+1) if isinstance(repeats, int) is True else repeats
            for repeat in repeats:
                # parameters = '-t \"%s\"'% (targets_txt)
                parameters = ' -w %s_run%s' % (workName, runID)
                parameters += ' --runID %d' % (runID)
                parameters += ' --exPoints %d' % (nSamples)
                parameters += ' --part %d' % (repeat)
                exe.create_job_secondphase(targetPath=P1path, jar=jarFile, parameters=parameters,
                                           jobName='Test_%s'%P1path, taskName='Test_r%d_N%d_part%d'%(runID, nSamples, repeat))


    exe.create_stop_script("%s_N%d"%(jobName, nSamples))
    exe.create_remove_script("%s_N%d"%(jobName, nSamples))


def P2Ex02(targetPath, nModelUpdates, exPoints, workName, runs=10, _approach=None, _appendix=""):
    '''
     2019.08.02 Execute Ex08  :: RQ3 execute retest  (pool with f1)
    :return:
    '''
    exe = Executor('./cmds', "iris")
    # tasklist = [23, 30, 33]  #[3, 10, 14, 15, 16, 18]
    jarFile = 'artifacts/SecondPhase.jar'
    approaches = ['distance', 'random']
    if _approach is not None:
        approaches = _approach
    for approach in approaches :
        runs = range(1, runs+1) if isinstance(runs, int) is True else runs
        for runID in runs:  #phase 1 runs
            # runID = 3
            for sample in (20,):
                iter = 1000        # first phase iteration
                parameters = '--secondRuntype %s'% (approach)
                # targets_txt = ','.join(['%d'%i for i in tasklist])
                # parameters +=' -t \"%s\"'% (targets_txt)
                parameters += ' --nSamples %d -i %d --runID %d' % (sample, iter, runID)
                parameters += ' -w %s' % (workName)
                parameters += ' --modelUpdates %d --exPoints %d' % (nModelUpdates, exPoints)
                parameters += ' --stopProbAccept %.3f' % (0.001)
                # parameters += ' --testData testdataR/testdata_N50000_run%02d.csv' % (runID)
                parameters += ' %s' % _appendix

                exe.create_job_secondphase(targetPath=targetPath, jar=jarFile, parameters=parameters,
                                           jobName=workName, taskName='%s_%s_run%d'%(workName, approach, runID))

    exe.create_stop_script('%s'%(workName))
    exe.create_remove_script('%s'%(workName))


if __name__ == "__main__":
    # P1
    # P1Ex02("P1_C20_soft", "LS_data_201testdata90710_ordered_uncertianty_soft.csv", "-m 0.2")
    # P1Ex02("P1_P50", "LS_data_20190710_ordered_uncertianty.csv",  "-p 50 -m 0.2 -c 0.7", runMAX=50)
    # P1Ex02("P1_REDUCED_4000", "LS_data_20190710_ordered_uncertianty_reduced.csv",  "-p 10 -m 0.2 -c 0.7", runMAX=50)
    # P1Ex02("P1_REDUCED_1500", "LS_data_20191204_SCM_max_80.csv",  "-p 10 -m 0.2 -c 0.7", runMAX=50)

    # Test Data
    # Test('20191216_P1_REDUCED_1000_S20_GASearch', [], 25000, 'testdata', runs=50, repeats=2)
    # Test('20191206_P1_REDUCED_1000_GASearch', [], 25000, 'testdata', runs=[20, 43, 44], repeats=[2])
    # Test('20191222_P1_REDUCED_1000_S20_GASearch', [], 25000, 'testdata', runs=50, repeats=2)
    # Test('20191222_P1_REDUCED_1000_S20_RandomSearch', [], 25000, 'testdata', runs=50, repeats=2)
    # Test('20191223_P1_REDUCED_1500_S20_GASearch', [], 25000, 'testdata', runs=50, repeats=2)

    # exceptions = set([22])
    # targets = [22] + list(range(41, 51))
    # targets = [1, 45, 49]
    # P2Ex02(targetPath="20191222_P1_REDUCED_1000_S20_GASearch", nModelUpdates=100, exPoints=100, workName='RQ2_100_100_LAST', runs=50, _appendix="--modelPrecision 0.0001")
    # P2Ex02(targetPath="20191223_P1_REDUCED_1500_S20_GASearch", nModelUpdates=50, exPoints=100, workName='RQ2_50_100_wide2', runs=50, _appendix="--modelPrecision 0.001")
    # P2Ex02(targetPath="20191222_P1_REDUCED_1000_S20_GASearch", nModelUpdates=400, exPoints=100, workName='RQ2_400_100_wide2', runs=50, _approach=['distance'], _appendix="--modelPrecision 0.001")
    # P2Ex02(targetPath="20191223_P1_REDUCED_1500_S20_GASearch", nModelUpdates=400, exPoints=100, workName='RQ2_400_100_wide2', runs=50, _approach=['distance'], _appendix="--modelPrecision 0.001")
    # P2Ex02(targetPath="20191223_P1_REDUCED_1500_S20_GASearch", nModelUpdates=100, exPoints=100, workName='RQ2_100_100', runs=50)
    # P2Ex02(targetPath="20191223_P1_REDUCED_1500_S20_GASearch", nModelUpdates=200, exPoints=100, workName='RQ2_200_100', runs=50)
    # P2Ex02(targetPath="20191223_P1_REDUCED_1500_S20_GASearch", nModelUpdates=400, exPoints=100, workName='RQ2_400_100', runs=50)
    # P2Ex02(targetPath="20191204_P1_FULL_S20_GASearch", nModelUpdates=200, exPoints=100, workName='RQ2_200_100', runs=10)
    # P2Ex02(targetPath="20191130_P1_FULL_S20_GASearch", nModelUpdates=50, exPoints=100, workName='RQ2_50_100_test2', runs=10)
    # P2Ex02(targetPath="20191130_P1_FULL_S20_GASearch", nModelUpdates=200, exPoints=100, workName='RQ2_200_100_test2', runs=10)
    # P2Ex02(targetPath="20191129_P1_C20_S20_GASearch", nModelUpdates=50, exPoints=100, workName='RQ2_50_100_test2', runs=10)
    # P2Ex02(targetPath="20191216_P1_REDUCED_1000_S20_GASearch", nModelUpdates=400, exPoints=100, workName='RQ2_400_100_ev2', runs=50)

    P1Ex02("20200515_P1", "LS_ISSTA_20200201_ordered_uncertianty.csv",  "-p 10 -m 0.2 -c 0.7", runMAX=10)
    P1Ex02("20200515_P1_sub", "LS_ISSTA_20200201_ordered_uncertianty_sub.csv",  "-p 10 -m 0.2 -c 0.7", runMAX=10)

    # '-p 10 -m 0.2 -c 0.7 -r 10 --runID 1 -i 1000 --nSamples 10 --printResults --extendScheduler --data res/LS_ISSTA_20200201_ordered_uncertianty.csv'
    # P2Ex02(targetPath="20191222_P1_REDUCED_1000_S20_GASearch", nModelUpdates=100, exPoints=100, workName='RQ2_100_100_LAST', runs=50, _appendix="--modelPrecision 0.0001")

