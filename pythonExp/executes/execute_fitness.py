from utils.executor import Executor


def FirstPhase_Test1():
    '''
    2019.05.07 Test for double data-type for fitness. I changed BigDecimal -> double
    :return:
    '''
    exe = Executor('./cmds')
    exceptlist = []
    include = [6, 17, 27, 33, 34]# [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34]
    jarFile = 'artifacts/StressTesting.jar'
    jobType = 'IN0416_GA'
    parameters = '-r 10 --data res/LS_data_20190416_oldSeq_newPriority.csv'
    exe.create_jobs(exceptlist=exceptlist, hours=120, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)

def FirstPhase_Test2():
    '''
    2019.05.08 Test for new fitness. I updated fitness function to use nomalization
    :return:
    '''
    exe = Executor('./cmds')
    exceptlist = []
    include = [6, 17, 27, 33, 34]# [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34]
    jarFile = 'artifacts/StressTesting_double_worst_replace.jar'
    jobType = 'IN0416_GA_newfitness'
    parameters = '-r 10 --data res/LS_data_20190416_oldSeq_newPriority.csv'
    exe.create_jobs(exceptlist=exceptlist, hours=120, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)

def FirstPhase_Test3_2_best():
    '''
    2019.05.08 Test for new fitness. I updated fitness function to use nomalization
    :return:
    '''
    exe = Executor('./cmds')
    exceptlist = []
    include = [6, 17, 27, 33, 34]# [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34]
    jarFile = 'artifacts/StressTesting_double_2child.jar'
    jobType = 'IN0416_GA_double_2child'
    parameters = '-r 10 --data res/LS_data_20190416_oldSeq_newPriority.csv'
    exe.create_jobs(exceptlist=exceptlist, hours=120, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)


def FirstPhase_Test4_power():
    '''
    2019.05.13 Test for new fitness. I updated fitness function to use nomalization
    Power(Norm(x))
    :return:
    '''
    exe = Executor('./cmds')
    exceptlist = []
    include = [6, 17, 27, 33, 34]# [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34]
    jarFile = 'artifacts/StressTesting_double_power.jar'
    jobType = 'IN0416_GA_double_power'
    parameters = '-r 10 --data res/LS_data_20190416_oldSeq_newPriority.csv'
    exe.create_jobs(exceptlist=exceptlist, hours=120, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)


def FirstPhase_Test5_cut():
    '''
    2019.05.13 Test for new fitness. I updated fitness function to use nomalization
    :return:
    cut[-20, 20]
    '''
    exe = Executor('./cmds')
    exceptlist = []
    include = [6, 17, 27, 33, 34]# [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34]
    jarFile = 'artifacts/StressTesting_double_cut20.jar'
    jobType = 'IN0416_GA_double_cut20'
    parameters = '-r 10 --data res/LS_data_20190416_oldSeq_newPriority.csv'
    exe.create_jobs(exceptlist=exceptlist, hours=120, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)


def FirstPhase_Test6_log():
    '''
    2019.05.13 Test for new fitness. I updated fitness function to use nomalization
    log function
    :return:
    '''
    exe = Executor('./cmds')
    exceptlist = []
    include = [6, 17, 27, 33, 34]# [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34]
    jarFile = 'artifacts/StressTesting_double_log.jar'
    jobType = 'IN0416_GA_double_log'
    parameters = '-r 10 --data res/LS_data_20190416_oldSeq_newPriority.csv'
    exe.create_jobs(exceptlist=exceptlist, hours=120, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)

def FirstPhase_Test7_divide():
    '''
    2019.05.13 Test for new fitness. I updated fitness function to use nomalization
    log function
    :return:
    '''
    exe = Executor('./cmds')
    exceptlist = []
    include = [6, 17, 27, 33, 34]# [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34]
    jarFile = 'artifacts/StressTesting_double_divide.jar'
    jobType = 'IN0416_GA_double_divide'
    parameters = '-r 2 --data res/LS_data_20190416_oldSeq_newPriority.csv'
    exe.create_jobs(exceptlist=exceptlist, hours=120, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)


def FirstPhase_Test8_best():
    '''
    2019.05.13 Test for new fitness. I updated fitness function to use nomalization
    consider best(e-d) for fitness
    :return:
    '''
    exe = Executor('./cmds')
    exceptlist = []
    include = [6, 17, 27, 33, 34]# [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34]
    jarFile = 'artifacts/StressTesting_double_best_2child.jar'
    jobType = 'IN0416_GA_double_best_2child'
    parameters = '-r 10 --data res/LS_data_20190416_oldSeq_newPriority.csv'
    exe.create_jobs(exceptlist=exceptlist, hours=120, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)

def FirstPhase_Test8_1_best(sampling=0):
    '''
    2019.05.13 Test for new fitness. I updated fitness function to use nomalization
    consider best(e-d) for fitness
    :return:
    '''
    exe = Executor('./cmds')
    exceptlist = []
    include = [6, 17, 27, 33, 34]# [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34]
    jarFile = 'artifacts/StressTesting_double_best_2child.jar'
    jobType = 'IN0416_GA_double_best_2child_sample%d'%sampling
    parameters = '-r 10 --data res/LS_data_20190416_oldSeq_newPriority.csv --nSamples %d'%sampling
    exe.create_jobs(exceptlist=exceptlist, hours=120, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)

def FirstPhase_Test9_big_2child():
    '''
    2019.05.22
    consider BigDecimal + 2children
    :return:
    '''
    exe = Executor('./cmds')
    exceptlist = []
    include = [6, 17, 27, 33, 34]# [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34]
    jarFile = 'artifacts/StressTesting_bigDecimal_2child.jar'
    jobType = 'IN0416_GA_BigDecimal_2child'
    parameters = '-r 10 --data res/LS_data_20190416_oldSeq_newPriority.csv'
    exe.create_jobs(exceptlist=exceptlist, hours=120, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)

def FirstPhase_Test9_big_1child():
    '''
    2019.05.22
    consider BigDecimal + 1children
    :return:
    '''
    exe = Executor('./cmds')
    exceptlist = []
    include = [6, 17, 27, 33, 34]# [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34]
    jarFile = 'artifacts/StressTesting_bigDecimal.jar'
    jobType = 'IN0416_GA_BigDecimal_1child'
    parameters = '-r 10 --data res/LS_data_20190416_oldSeq_newPriority.csv'
    exe.create_jobs(exceptlist=exceptlist, hours=120, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)


def FirstPhase_Test10_big_fixed():
    '''
    2019.05.22
    consider BigDecimal + 1children
    :return:
    '''
    exe = Executor('./cmds')

    for nSamples in [0,1,2,5]:
        for nExcutions in [1,2,5,10,20,30]:
            exceptlist = []
            include = [34]# [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34]
            jarFile = 'artifacts/StressTesting_bigDecimal_fixed2.jar'
            jobType = 'IN0416_GA_BigDecimal_fixed2'
            appendix='%dSamples_%dExecutions'%(nSamples, nExcutions)
            parameters = '-r 10 --data res/LS_data_20190416_oldSeq_newPriority.csv --nExecutions %d --nSamples %d' % (nExcutions,nSamples)
            exe.create_type_jobs(exceptlist=exceptlist, hours=120, jobType=jobType, jar=jarFile, parameters=parameters, include=include, append_t=appendix)
    exe.create_stop_script('IN0416_GA_BigDecimal_fixed')
    exe.create_remove_script('IN0416_GA_BigDecimal_fixed')



def FirstPhase_Test11_double_fixed_power(_power):
    '''
    2019.05.22
    consider BigDecimal + 1children
    :return:
    '''
    exe = Executor('./cmds')

    for nSamples in [0,1,2,5]:
        for nExcutions in [1,2,5,10,20,30]:
            exceptlist = []
            include = [34]# [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34]
            jarFile = 'artifacts/StressTesting_double_fixed_power%d.jar'%_power
            jobType = 'IN0416_GA_double_fixed_power%d'%_power
            appendix='%dSamples_%dExecutions'%(nSamples, nExcutions)
            parameters = '-r 10 --data res/LS_data_20190416_oldSeq_newPriority.csv --nExecutions %d --nSamples %d' % (nExcutions,nSamples)
            exe.create_type_jobs(exceptlist=exceptlist, hours=120, jobType=jobType, jar=jarFile, parameters=parameters, include=include, append_t=appendix)
    exe.create_stop_script('IN0416_GA_double_fixed_power%d'%_power)
    exe.create_remove_script('IN0416_GA_double_fixed_power%d'%_power)

def FirstPhase_Test12_bigdecimal_nolog(_option):
    '''
    2019.05.22
    consider BigDecimal + 1children
    :return:
    '''
    exe = Executor('./cmds')

    for nSamples in [1,2,5]:
        for nExcutions in [1,2,5]:
            exceptlist = []
            include = [34]# [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34]
            jarFile = 'artifacts/StressTesting_bigDecimal_nolog%s.jar'%_option
            jobType = 'IN0416_GA_bigDecimal_nolog%s'%_option
            appendix='%dSamples_%dExecutions'%(nSamples, nExcutions)
            parameters = '-r 1 --data res/LS_data_20190416_oldSeq_newPriority.csv --nExecutions %d --nSamples %d' % (nExcutions,nSamples)
            exe.create_type_jobs(exceptlist=exceptlist, hours=120, jobType=jobType, jar=jarFile, parameters=parameters, include=include, append_t=appendix)
    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)


def FirstPhase_Sampling_Test1(samples=20, param=''):
    '''
    2019.05.08 Test for new fitness. I updated fitness function to use nomalization
    This test for sampling costs
    :return:
    '''
    exe = Executor('./cmds')
    exceptlist = []
    include = [6, 17, 27, 33, 34]# [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34]
    jarFile = 'artifacts/StressTesting_double_worst_replace.jar'
    jobType = 'IN0416_GA_newfitness_sample%d%s'%(samples,param)
    parameters = '-r 1 --data res/LS_data_20190416_oldSeq_newPriority.csv --nSamples %d %s' % (samples, param)
    exe.create_jobs(exceptlist=exceptlist, hours=120, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)


def FirstPhase_Sampling_Test2(samples=20, param=''):
    '''
    2019.05.08 Test for new fitness. I updated fitness function to use nomalization
    This test for sampling costs
    :return:
    '''
    exe = Executor('./cmds')
    exceptlist = []
    include = [6, 17, 27, 33, 34]# [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34]
    jarFile = 'artifacts/StressTesting_double_executions.jar'
    jobType = 'IN0416_GA_double_executions_sample%d%s'%(samples,param)
    parameters = '-r 5 --data res/LS_data_20190416_oldSeq_newPriority.csv --nSamples %d %s' % (samples, param)
    exe.create_jobs(exceptlist=exceptlist, hours=120, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)


def FirstPhase_Big_Test():
    '''
    2019.05.08 Test for BigDecimal for calculating time
    :return:
    '''
    exe = Executor('./cmds')
    exceptlist = []
    include = [6, 17, 27, 33, 34]# [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34]
    jarFile = 'artifacts/StressTesting_bigDecimal.jar'
    jobType = 'IN0416_GA_big'
    parameters = '-r 10 --data res/LS_data_20190416_oldSeq_newPriority.csv'
    exe.create_jobs(exceptlist=exceptlist, hours=120, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)

def FirstPhase_Sampling_Big_Test1(samples=20, param=''):
    '''
    2019.05.08 Test for BigDecimal for calculating time
    :return:
    '''
    exe = Executor('./cmds')
    exceptlist = []
    include = [6, 17, 27, 33, 34]# [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34]
    jarFile = 'artifacts/StressTesting_bigDecimal.jar'
    jobType = 'IN0416_GA_big_sample%d%s'%(samples,param)
    parameters = '-r 1 --data res/LS_data_20190416_oldSeq_newPriority.csv --nSamples %d %s' % (samples, param)
    exe.create_jobs(exceptlist=exceptlist, hours=120, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)


def FitnessTest_Sampling_Origin(param=''):
    '''
    2019.05.08 Test for new fitness. I updated fitness function to use nomalization
    This test for sampling costs
    :return:
    '''
    exe = Executor('./cmds')
    exceptlist = []
    for nSamples in [0, 1, 2, 3, 4, 5, 10, 20, 30, 40]:
        include = [34]# [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34]
        jarFile = 'artifacts/FitnessTest_BigOrigin_1child_minLog_preAvg.jar'
        jobType = 'FitnessTest_BigOrigin'
        appendix = 'Task34_Sample%d'%(nSamples)
        parameters = '-r 5 --data res/LS_data_20190416_oldSeq_newPriority.csv --nSamples %d %s' % (nSamples, param)
        exe.create_type_jobs(exceptlist=exceptlist, hours=120, jobType=jobType, jar=jarFile, parameters=parameters, include=include, append_t=appendix)

    exe.create_stop_script('IN0416_GA_BigOrigin')
    exe.create_remove_script('IN0416_GA_BigOrigin')

def FitnessTest_Sampling_Fixed(executions=0, param=''):
    '''
    2019.05.08 Test for new fitness. I updated fitness function to use nomalization
    This test for sampling costs
    :return:
    '''
    exe = Executor('./cmds')
    exceptlist = []
    for nSamples in [0, 1, 2, 3, 4, 5, 10, 20, 30, 40]:
        include = [34]# [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34]
        jarFile = 'artifacts/FitnessTest_BigFixed_1child_minLog_preAvg.jar'
        jobType = 'FitnessTest_BigFixed_exec%d'%(executions)
        appendix = 'Task34_Sample%d'%(nSamples)
        parameters = '-r 5 --data res/LS_data_20190416_oldSeq_newPriority.csv --nSamples %d --nExecutions %d %s' % (nSamples, executions, param)
        exe.create_type_jobs(exceptlist=exceptlist, hours=120, jobType=jobType, jar=jarFile, parameters=parameters, include=include, append_t=appendix)

    exe.create_stop_script('IN0416_GA_BigFixed')
    exe.create_remove_script('IN0416_GA_BigFixed')

def FitnessTest_Sampling_best(param=''):
    '''
    2019.05.08 Test for new fitness. I updated fitness function to use nomalization
    This test for sampling costs
    :return:
    '''
    exe = Executor('./cmds')
    exceptlist = []
    for nSamples in [2, 3, 4, 5, 10, 20, 30, 40]:
        include = [34]# [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34]
        jarFile = 'artifacts/FitnessTest_best_1child_minLog_preAvg.jar'
        jobType = 'FitnessTest_best'
        appendix = 'Task34_Sample%d'%(nSamples)
        parameters = '-r 5 --data res/LS_data_20190416_oldSeq_newPriority.csv --nSamples %d %s' % (nSamples, param)
        exe.create_type_jobs(exceptlist=exceptlist, hours=120, jobType=jobType, jar=jarFile, parameters=parameters, include=include, append_t=appendix)

    exe.create_stop_script('IN0416_GA_best')
    exe.create_remove_script('IN0416_GA_best')

def FitnessTest_Sampling_BigOrigin_fitness(param=''):
    '''
    2019.05.08 Test for new fitness. I updated fitness function to use nomalization
    This test for sampling costs
    :return:
    '''
    exe = Executor('./cmds')
    exceptlist = []
    for nSamples in [2, 3, 4, 5]:
        include = [34]# [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34]
        jarFile = 'artifacts/FitnessTest_BigOrigin_fitness.jar'
        jobType = 'FitnessTest_BigOrigin_fitness'
        appendix = 'Task34_Sample%d'%(nSamples)
        parameters = '-r 1 --data res/LS_data_20190416_oldSeq_newPriority.csv --nSamples %d %s' % (nSamples, param)
        exe.create_type_jobs(exceptlist=exceptlist, hours=120, jobType=jobType, jar=jarFile, parameters=parameters, include=include, append_t=appendix)

    exe.create_stop_script('IN0416_BigOrigin_fitness')
    exe.create_remove_script('IN0416_BigOrigin_fitness')

if __name__ == "__main__":

    # # # obj.test()
    # obj.newdata()
    # FirstPhase_Test4_power()
    # FirstPhase_Test5_cut()
    # FirstPhase_Test6_log()
    # FirstPhase_Test7_divide()
    # FirstPhase_Test8_best()
    # FirstPhase_Test9_big_2child()
    # FirstPhase_Sampling_Test2(10)
    # FirstPhase_Sampling_Test2(20)
    # FirstPhase_Test9_big_1child()
    # FirstPhase_Test9_big_2child()
    # FirstPhase_Test10_big_fixed()
    # FirstPhase_Test11_double_fixed_power(2)
    # FirstPhase_Test11_double_fixed_power(3)
    # FirstPhase_Test8_1_best(1)
    # FirstPhase_Test8_1_best(2)
    # FirstPhase_Test8_1_best(5)
    # FirstPhase_Test12_bigdecimal_nolog('_nodivide')
    # FirstPhase_Test12_bigdecimal_nolog('')

    # FitnessTest_Sampling_Origin()
    # FitnessTest_Sampling_Fixed(5)
    # FitnessTest_Sampling_Fixed(10)
    # FitnessTest_Sampling_Fixed(30)
    # FitnessTest_Sampling_best()
    FitnessTest_Sampling_BigOrigin_fitness()






    # FirstPhase_Test3_2_best()       # double / new fitness / 2 best / single / 10런이라 늦음
    # FirstPhase_Test2()              # double / new fitness / single / 10 run이라 늦음
    # FirstPhase_Big_Test()           # Big    / old fitness / single / 10 run인데 완료....뭐지..?
    # FirstPhase_Sampling_Test1(10)   # double / new fitness / sample 10
    # FirstPhase_Sampling_Big_Test1(10)# big   / old fitness / sample 10
    # FirstPhase_Sampling_Test1(10, "--printSamples")       # double / new fitness / sample 10  (print용)
    # FirstPhase_Sampling_Big_Test1(10, "--printSamples")   # double / new fitness / sample 10 (print용)
    # FirstPhase_Sampling_Test1(40)
    # FirstPhase_Sampling_Big_Test1(40)

