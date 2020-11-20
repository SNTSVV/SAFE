import time
from utils.executor import Executor


def FirstPhase_SimpleSearch(params=''):
    '''
    2019.05.08 Test for new fitness. I updated fitness function to use nomalization
    This test for sampling costs
    :return:
    '''
    exe = Executor('./cmds')
    exceptlist = []
    include = [23, 34]
    jarFile = 'artifacts/StressTesting.jar'
    jobType = 'FirstPhase_SimpleSearch'
    for run in range(1, 11):
        parameters = '-r 10 --runID %d --printResults --simpleSearch --data res/LS_data_20190710_ordered_uncertianty.csv %s' % (run, params)
        exe.create_jobs(jobName=jobType, tasklist=include, jar=jarFile, parameters=parameters, runID=run)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)

def FirstPhase_GASearch(params=''):
    '''
    2019.05.08 Test for new fitness. I updated fitness function to use nomalization
    This test for sampling costs
    :return:
    '''
    exe = Executor('./cmds')
    include = [23, 34]
    jarFile = 'artifacts/StressTesting.jar'
    jobType = 'FirstPhase_GASearch'
    for run in range(1, 11):
        parameters = '-r 10 --runID %d --printResults --data res/LS_data_20190710_ordered_uncertianty.csv %s' % (run, params)
        exe.create_jobs(jobName=jobType, tasklist=include, jar=jarFile, parameters=parameters, runID=run)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)

def FirstPhase_SimpleSearch_Ex(params=''):
    '''
    2019.05.08 Test for new fitness. I updated fitness function to use nomalization
    This test for sampling costs
    :return:
    '''
    exe = Executor('./cmds')
    include = [23,30]
    jarFile = 'artifacts/StressTesting.jar'
    jobType = 'FirstPhase_RandomSearch_Ex'
    for run in range(1, 11):
        parameters = '-r 10 --runID %d --printResults --simpleSearch --data res/LS_data_20190710_ordered_uncertianty.csv %s' % (run, params)
        exe.create_jobs(jobName=jobType, tasklist=include, jar=jarFile, parameters=parameters, runID=run)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)

def FirstPhase_GASearch_Ex(params=''):
    '''
    2019.05.08 Test for new fitness. I updated fitness function to use nomalization
    This test for sampling costs
    :return:
    '''
    exe = Executor('./cmds')
    include = [23, 30]
    jarFile = 'artifacts/StressTesting.jar'
    jobType = 'FirstPhase_GASearch_Ex'
    for runID in range(1, 11):
        parameters = '-r 10 --runID %d --printResults --simpleSearch --data res/LS_data_20190710_ordered_uncertianty.csv %s' % (runID, params)
        exe.create_jobs(jobName=jobType, tasklist=include, jar=jarFile, parameters=parameters, runID=runID)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)

def compare_FirstPhase_Ex1(params=''):
    '''
    2019.07.12 Test for new fitness. I updated fitness function to use nomalization
    This test for sampling costs
    :return:
    '''
    include = [7,8,9,10]
    jarFile = 'artifacts/StressTesting.jar'

    exe = Executor('./cmds')
    jobType = 'FirstPhase_RandomSearch_Ex3'
    runMAX = 10
    for runID in range(1, runMAX+1):
        parameters = '-r %d --runID %d --simpleSearch --nSamples 40 --printResults --extendScheduler --data res/LS_data_20190710_ordered_uncertianty.csv %s' % (runMAX, runID, params)
        exe.create_jobs(jobName=jobType, tasklist=include, jar=jarFile, parameters=parameters, runID=runID)
        if runID==1:
            time.sleep(5)

    jobType = 'FirstPhase_GASearch_Ex3'
    for runID in range(1, runMAX+1):
        parameters = '-r %d --runID %d  --nSamples 40 --printResults --extendScheduler  --data res/LS_data_20190710_ordered_uncertianty.csv %s' % (runMAX, runID, params)
        exe.create_jobs(jobName=jobType, tasklist=include, jar=jarFile, parameters=parameters, runID=runID)
        if runID==1:
            time.sleep(5)

    exe.create_stop_script('compare_firstPhase_long')
    exe.create_remove_script('compare_firstPhase_long')

def compare_FirstPhase_Ex4(params=''):
    '''
    2019.07.12 Test for new fitness. I updated fitness function to use nomalization
    This test for sampling costs
    :return:
    '''
    include = [7,8,9,10]
    jarFile = 'artifacts/StressTesting.jar'

    exe = Executor('./cmds')
    jobType = 'FirstPhase_%s_Ex4'
    approachs = ['GASearch']#['RandomSearch', 'GASearch']
    runMAX = 5
    for approach in approachs:
        for runID in range(1, runMAX+1):
            parameters = '-r %d --runID %d -p 50 -c 0.7 -m 0.01 --nSamples 10 --printResults --extendScheduler --data res/LS_data_20190710_ordered_uncertianty.csv %s' % (runMAX, runID, params)
            if approach == 'RandomSearch':
                parameters += ' --simpleSearch'
            exe.create_jobs(jobName='%s_Pop%d_%s'%(jobType,pop,approach), tasklist=include, jar=jarFile, parameters=parameters, runID=runID)
            if runID==1:
                time.sleep(5)

    exe.create_stop_script('FirstPhase_Ex4')
    exe.create_remove_script('FirstPhase_Ex4')

def compare_FirstPhase_Ex11(params=''):
    '''
    2019.07.17 Test for first phase. (population: vary, sample:0, RS and GA - 5 runs)
    :return:
    '''
    include = [10,23] # 7,8,9,
    jarFile = 'artifacts/StressTesting.jar'

    exe = Executor('./cmds')
    jobType = 'FirstPhase_Ex11'
    approachs = ['RandomSearch', 'GASearch']
    runMAX = 5
    for approach in approachs:
        for pop in [10, 50, 100]:
            parameters = '-r %d -p %d -c 0.7 -m 0.01 --printResults --nSamples 0 --extendScheduler --data res/LS_data_20190710_ordered_uncertianty.csv %s' % (runMAX, pop, params)
            if approach == 'RandomSearch':
                parameters = '--simpleSearch ' + parameters
            exe.create_jobs(jobName='%s_Pop%d_%s'%(jobType,pop,approach), tasklist=include, jar=jarFile, parameters=parameters, runID=runID)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)

def compare_FirstPhase_Ex12(params=''):
    '''
     2019.07.17 Test for first phase. (population: vary, sample:5, RS and GA)
    :return:
    '''
    include = [10, 23]  #7,8,9,
    jarFile = 'artifacts/StressTesting.jar'

    exe = Executor('./cmds')
    jobType = 'FirstPhase_Ex14'
    approachs = ['RandomSearch', 'GASearch']
    runMAX = 5
    for approach in approachs:
        for pop in [10,50]:
            for runID in range(1, runMAX+1):
                parameters = '-r %d --runID %d -p %d -c 0.7 -m 0.01 --printResults --nSamples 5 --extendScheduler --data res/LS_data_20190710_ordered_uncertianty.csv %s' % (runMAX, runID, pop, params)
                if approach == 'RandomSearch':
                    parameters = '--simpleSearch ' + parameters
                exe.create_jobs(jobName='%s_Pop%d_%s'%(jobType,pop,approach), tasklist=include, jar=jarFile, parameters=parameters, runID=runID)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)


def compare_FirstPhase_Ex13(params=''):
    '''
     2019.07.17 Test for first phase. (population: vary, sample:5, RS and GA)
    :return:
    '''
    include = [10, 23]  #7,8,9,
    jarFile = 'artifacts/StressTesting.jar'

    exe = Executor('./cmds')
    jobType = 'FirstPhase_Ex13'
    approachs = ['RandomSearch', 'GASearch']
    runMAX = 5
    for approach in approachs:
        for pop in [10,50]:
            for runID in range(1, runMAX+1):
                parameters = '-r %d --runID %d -p %d -c 0.7 -m 0.1 --printResults --nSamples 5 --extendScheduler --data res/LS_data_20190710_ordered_uncertianty.csv %s' % (runMAX, runID, pop, params)
                if approach == 'RandomSearch':
                    parameters = '--simpleSearch ' + parameters
                exe.create_jobs(jobName='%s_Pop%d_%s'%(jobType,pop,approach), tasklist=include, jar=jarFile, parameters=parameters, runID=runID)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)


def compare_FirstPhase_Ex14(params=''):
    '''
     2019.07.17 Test for first phase. (population: vary, sample:5, RS and GA)
    :return:
    '''
    exe = Executor('./cmds')
    jobName = 'FirstPhase_Ex14'

    tasklist = [10, 23]  #7,8,9,
    jarFile = 'artifacts/StressTesting.jar'
    approachs = ['RandomSearch', 'GASearch']
    runMAX = 5
    for approach in approachs:
        for pop in [10,50]:
            for runID in range(1, runMAX+1):
                parameters = '-r %d --runID %d -p %d -c 0.7 -m 0.2 --nSamples 5 ' % (runMAX, runID, pop)
                parameters += '--printResults --extendScheduler --data res/LS_data_20190710_ordered_uncertianty.csv %s' % (params)
                if approach == 'RandomSearch':
                    parameters = '--simpleSearch ' + parameters

                exe.create_jobs(jobName='%s_Pop%d_%s'%(jobName,pop,approach), tasklist=tasklist, jar=jarFile, parameters=parameters, runID=runID)

    exe.create_stop_script(jobName)
    exe.create_remove_script(jobName)


def compare_FirstPhase_Ex15(params=''):
    '''
     2019.07.17 Test for first phase. (population: vary, sample:5, RS and GA)
    :return:
    '''
    exe = Executor('./cmds')
    jobName = 'FirstPhase_Ex15'
    tasklist = [10, 23]  #7,8,9,
    jarFile = 'artifacts/StressTesting.jar'
    approachs = ['RandomSearch', 'GASearch']
    runMAX = 10
    for approach in approachs:
        for runID in range(1, runMAX+1):
            parameters = '-r %d --runID %d -p 10 -i 3000 -c 0.7 -m 0.2 --nSamples 5 ' % (runMAX, runID)
            parameters += '--printResults --extendScheduler --data res/LS_data_20190710_ordered_uncertianty.csv %s' % (params)
            if approach == 'RandomSearch':
                parameters = '--simpleSearch ' + parameters

            exe.create_jobs(jobName='%s_Pop10_%s'%(jobName, approach), tasklist=tasklist, jar=jarFile, parameters=parameters, runID=runID)

    exe.create_stop_script(jobName)
    exe.create_remove_script(jobName)


def compare_FirstPhase_Ex16(params=''):
    '''
    2019.07.17 Test for first phase. (population: vary, sample:0, RS and GA - 5 runs)
    :return:
    '''
    tasklist = [10,23] # 7,8,9,
    jarFile = 'artifacts/StressTesting.jar'

    exe = Executor('./cmds')
    exceptlist = []
    jobName = 'FirstPhase_Ex16'
    approachs = ['RandomSearch', 'GASearch']
    runMAX = 10
    for approach in approachs:
        for pop in [10, 50]:
            for mr in [1, 2, 3, 4, 5]:
                parameters = '-r %d -p %d -c 0.7  -m %.1f --nSamples 0 ' % (runMAX, pop, mr/10)
                parameters += '--printResults --extendScheduler --data res/LS_data_20190710_ordered_uncertianty.csv %s' % (params)
                if approach == 'RandomSearch':
                    parameters = '--simpleSearch ' + parameters

                exe.create_jobs(jobName='%s_Pop%d_m%.1f_%s'%(jobName,pop,mr/10,approach), tasklist=tasklist, jar=jarFile, parameters=parameters)

    exe.create_stop_script(jobName)
    exe.create_remove_script(jobName)

def compare_FirstPhase_Ex20(params=''):
    '''
    2019.07.17 Test for first phase. (population: vary, sample:40, RS and GA)
    :return:
    '''
    exe = Executor('./cmds')
    jobName = 'FirstPhase_Ex20'
    tasklist = [10,23]  #7,8,9,
    jarFile = 'artifacts/StressTesting.jar'
    approachs = ['RandomSearch', 'GASearch']
    runMAX = 10
    for approach in approachs:
        for pop in [10]:
            for runID in range(1, runMAX+1):
                parameters = '-r %d --runID %d -p %d -i 3000 -c 0.7 -m 0.2 --nSamples 40 ' % (runMAX, runID, pop)
                parameters += '--printResults --extendScheduler --data res/LS_data_20190710_ordered_uncertianty.csv %s' % (params)
                if approach == 'RandomSearch':
                    parameters = '--simpleSearch ' + parameters

                exe.create_jobs(jobName='%s_Pop%d_%s'%(jobName,pop,approach), tasklist=tasklist, jar=jarFile, parameters=parameters, runID=runID)

    exe.create_stop_script(jobName)
    exe.create_remove_script(jobName)

def compare_FirstPhase_Ex20_Iris(params=''):
    '''
    2019.07.17 Test for first phase. (population: vary, sample:40, RS and GA)
    :return:
    '''
    tasklist = [7,8,9]  #7,8,9,
    jarFile = 'artifacts/StressTesting.jar'

    exe = Executor('./cmds', "iris")
    exceptlist = []
    jobName = 'FirstPhase_Ex20'
    approachs = ['RandomSearch', 'GASearch']
    runMAX = 10
    for approach in approachs:
        for pop in [10]:
            for runID in range(1, runMAX+1):
                parameters = '-r %d --runID %d -p %d -i 3000 -c 0.7 -m 0.2 --nSamples 40 ' % (runMAX, runID, pop)
                parameters += '--printResults --extendScheduler --data res/LS_data_20190710_ordered_uncertianty.csv %s' % (params)
                if approach == 'RandomSearch':
                    parameters = '--simpleSearch ' + parameters

                exe.create_jobs(jobName='%s_Pop%d_%s'%(jobName,pop,approach), tasklist=tasklist, jar=jarFile, parameters=parameters, runID=runID)

    exe.create_stop_script(jobName)
    exe.create_remove_script(jobName)

def compare_FirstPhase_Ex21_Iris(params=''):
    '''
    2019.07.17 Test for first phase. (population: vary, sample:40, RS and GA)
    :return:
    '''
    exe = Executor('./cmds', "iris")
    tasklist = [10, 23]  #7,8,9,
    jarFile = 'artifacts/StressTesting.jar'
    jobName = 'FirstPhase_Ex21'

    approachs = ['RandomSearch', 'GASearch']
    runMAX = 10
    for approach in approachs:
        for pop in [10]:
            for runID in range(1, runMAX+1):
                parameters = '-r %d --runID %d -p %d -i 3000 -c 0.7 -m 0.1 --nSamples 40 ' % (runMAX, runID, pop)
                parameters += '--printResults --extendScheduler --data res/LS_data_20190710_ordered_uncertianty.csv %s' % (params)
                if approach == 'RandomSearch':
                    parameters = '--simpleSearch ' + parameters

                exe.create_jobs(jobName='%s_Pop%d_%s'%(jobName,pop,approach), tasklist=tasklist, jar=jarFile, parameters=parameters, runID=runID)

    exe.create_stop_script(jobName)
    exe.create_remove_script(jobName)

def compare_FirstPhase_Ex22_m01(params=''):
    '''
    2019.07.17 Test for first phase. (population: vary, sample:40, RS and GA)
    :return:
    '''
    exe = Executor('./cmds')
    tasklist = [10, 23]  #7,8,9,
    jarFile = 'artifacts/StressTesting_uniform.jar'
    jobName = 'FirstPhase_Ex22_i3000_s5_m0.1'

    approachs = ['RandomSearch', 'GASearch']
    runMAX = 10
    for approach in approachs:
        for runID in range(1, runMAX+1):
            parameters = '-r %d --runID %d -p 10 -i 3000 -c 0.7 -m 0.1 --nSamples 5' % (runMAX, runID)
            parameters += ' --printResults --extendScheduler --data res/LS_data_20190710_ordered_uncertianty.csv %s' % (params)
            if approach == 'RandomSearch':
                parameters = '--simpleSearch ' + parameters

            exe.create_jobs(jobName='%s_%s'%(jobName,approach), tasklist=tasklist, jar=jarFile, parameters=parameters, runID=runID)

    exe.create_stop_script(jobName)
    exe.create_remove_script(jobName)

def compare_FirstPhase_Ex22_m02(params=''):
    '''
    2019.07.17 Test for first phase. (population: vary, sample:40, RS and GA)
    :return:
    '''
    exe = Executor('./cmds', "iris")
    tasklist = [10, 23]  #7,8,9,
    jarFile = 'artifacts/StressTesting_uniform.jar'
    jobName = 'FirstPhase_Ex22_i3000_s5_m0.2'

    approachs = ['RandomSearch', 'GASearch']
    runMAX = 10
    for approach in approachs:
        for runID in range(1, runMAX+1):
            parameters = '-r %d --runID %d -p 10 -i 3000 -c 0.7 -m 0.2 --nSamples 5' % (runMAX, runID)
            parameters += ' --printResults --extendScheduler --data res/LS_data_20190710_ordered_uncertianty.csv %s' % (params)
            if approach == 'RandomSearch':
                parameters = '--simpleSearch ' + parameters

            exe.create_jobs(jobName='%s_%s'%(jobName,approach), tasklist=tasklist, jar=jarFile, parameters=parameters, runID=runID)

    exe.create_stop_script(jobName)
    exe.create_remove_script(jobName)

def compare_FirstPhase_Ex15_Iris(params=''):
    '''
     2019.07.17 Test for first phase. (population: vary, sample:5, RS and GA)
    :return:
    '''
    exe = Executor('./cmds')
    jobName = 'FirstPhase_Ex15'
    tasklist = [10, 23]  #7,8,9,
    jarFile = 'artifacts/StressTesting.jar'

    approachs = ['RandomSearch', 'GASearch']
    runMAX = 10
    for approach in approachs:
        for pop in [10]:
            for runID in range(1, runMAX+1):
                parameters = '-r %d --runID %d -p %d -i 3000 -c 0.7 -m 0.1 --nSamples 5' % (runMAX, runID, pop)
                parameters += '--printResults --extendScheduler --data res/LS_data_20190710_ordered_uncertianty.csv %s' % (params)
                if approach == 'RandomSearch':
                    parameters = '--simpleSearch ' + parameters
                exe.create_jobs(jobName='%s_Pop%d_%s'%(jobName,pop,approach), tasklist=tasklist, jar=jarFile, parameters=parameters, runID=runID)

    exe.create_stop_script(jobName)
    exe.create_remove_script(jobName)


def compare_FirstPhase_Ex30_Iris(params=''):
    '''
     2019.07.17 Test for first phase. (population: vary, sample:5, RS and GA)
    :return:
    '''
    exe = Executor('./cmds', "iris")
    jobName = 'FirstPhase_Ex30'
    tasklist = [ 3, 14, 15, 16, 18]  #7,8,9,
    jarFile = 'artifacts/StressTesting.jar'

    approachs = ['RandomSearch', 'GASearch']
    runMAX = 10
    for approach in approachs:
        for sample in (20,):
            for runID in range(1, runMAX+1):
                parameters = '-r %d --runID %d -p 10 -i 1000 -c 0.7 -m 0.2 --nSamples %d' % (runMAX, runID, sample)
                parameters += ' --printResults --extendScheduler --data res/LS_data_20190710_ordered_uncertianty.csv %s' % (params)
                if approach == 'RandomSearch':
                    parameters = '--simpleSearch ' + parameters
                exe.create_jobs(jobName='%s_s%d_%s'%(jobName, sample, approach), tasklist=tasklist, jar=jarFile, parameters=parameters, runID=runID)

    exe.create_stop_script(jobName)
    exe.create_remove_script(jobName)


def compare_FirstPhase_Ex32_Iris(params=''):
    '''
     2019.07.17 Ex 31, 32 (sample 5-40 compare) - ex31(task 6, 7), ex32(task 5)
    :return:
    '''
    exe = Executor('./cmds', "iris")
    jobName = 'Ex32'
    tasklist = [5,6,7]  #7,8,9,
    jarFile = 'artifacts/StressTesting.jar'

    approachs = ['RandomSearch', 'GASearch']
    runMAX = 10
    for approach in approachs:
        for sample in (5, 10, 20):
            for runID in range(1, runMAX+1):
                parameters = '-r %d --runID %d -p 10 -i 3000 -c 0.7 -m 0.2 --nSamples %d' % (runMAX, runID, sample)
                parameters += ' --printResults --extendScheduler --data res/LS_data_20190710_ordered_uncertianty.csv %s' % (params)
                if approach == 'RandomSearch':
                    parameters = '--simpleSearch ' + parameters
                exe.create_jobs(jobName='%s_s%d_%s'%(jobName, sample, approach), tasklist=tasklist, jar=jarFile, parameters=parameters, runID=runID)

    exe.create_stop_script(jobName)
    exe.create_remove_script(jobName)


def compare_FirstPhase_Ex31_Iris(params=''):
    '''
     2019.07.17 Execute again Ex31 for task 7  first exeperiment was lost 3 executions.
    :return:
    '''
    exe = Executor('./cmds', "iris")
    jobName = 'Ex31'
    tasklist = [7]  #7,8,9,
    jarFile = 'artifacts/StressTesting.jar'

    approachs = ['RandomSearch', 'GASearch']
    runMAX = 10
    for approach in approachs:
        for sample in (20,):
            for runID in range(1, runMAX+1):
                parameters = '-r %d --runID %d -p 10 -i 3000 -c 0.7 -m 0.2 --nSamples %d' % (runMAX, runID, sample)
                parameters += ' --printResults --extendScheduler --data res/LS_data_20190710_ordered_uncertianty.csv %s' % (params)
                if approach == 'RandomSearch':
                    parameters = '--simpleSearch ' + parameters
                exe.create_jobs(jobName='%s_s%d_%s'%(jobName, sample, approach), tasklist=tasklist, jar=jarFile, parameters=parameters, runID=runID)

    exe.create_stop_script(jobName)
    exe.create_remove_script(jobName)

if __name__ == "__main__":

    # # # obj.test()
    # obj.newdata()
    # FirstPhase_SimpleSearch()
    # FirstPhase_GASearch()
    # FirstPhase_SimpleSearch_Ex('--extendScheduler')
    # FirstPhase_GASearch_Ex('--extendScheduler')
    # compare_FirstPhase_Ex4()
    # compare_FirstPhase_Ex6()
    # compare_FirstPhase_Ex11()
    # compare_FirstPhase_Ex15()
    # compare_FirstPhase_Ex20()
    # compare_FirstPhase_Ex15()
    # compare_FirstPhase_Ex15_Iris()
    compare_FirstPhase_Ex30_Iris()




