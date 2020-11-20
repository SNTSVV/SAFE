from utils.executor import Executor


def newdata_base():
    '''
    EXP1: Basic experiment for new data set without the uncertian task (OperationSequence)
    Executed latest: 2019-01-24 (20190124_IN0111_NoSeq_all)
       - some tasks(5 task) are killed by the system. They took too much time.
    :param data:
    :return:
    '''
    exe = Executor()
    exceptlist = []
    include = [x for x in range(1,35,1)]
    jarFile = 'StressTesting.jar'
    jobType = 'IN0111_NoSeq_all'
    parameters = '-r 10 --data res/LS_data_20190111_noSeq.csv'
    exe.create_jobs(exceptlist=exceptlist, hours=48, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)


def newdata_varying_two_uniform():
    '''
    Basic experiment for new data
    To get varying WCET information
    To calculate for probability (Approach1)
    Executed latest: 2019-01-24 (20190124_IN0111_varyWCET20_TwoUniform)
    :param data:
    :return:
    '''
    exe = Executor()
    exceptlist = []
    include = [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34]
    jarFile = 'StressTesting.jar'
    jobType = 'IN0111_VaryWCET_TwoUniform'
    parameters = '-r 1 --nSamples 20 --data res/LS_data_20190111_oldSeq_newPriority.csv'
    exe.create_jobs(exceptlist=exceptlist, hours=120, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)

def newdata_varying_two_uniform_threshold(_threshold):
    '''
    Basic experiment for new data
    To get varying WCET information
    To compare which threshold can be used.
    Executed latest: 2019-01-28 (20190124_IN0111_VaryWCET_TwoUniform_Threshold07)
    :param data:
    :return:
    '''
    exe = Executor()
    exceptlist = []
    include = [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34]
    jarFile = 'StressTesting.jar'
    jobType = 'IN0111_VaryWCET_TwoUniform_Threshold%02d'% int(_threshold*10)
    parameters = '-r 1 --nSamples 20 --A12Threshold %.1f --data res/LS_data_20190111_oldSeq_newPriority.csv' % _threshold
    exe.create_jobs(exceptlist=exceptlist, hours=120, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)


def newdata_vary_revealWCET():
    '''
    To reveal which WCET is minimum which occurs deadline miss.
    Executed latest: 2019-01-24 (Failed)
    :return:
    '''
    exe = Executor()
    exceptlist = []
    include = [34]
    jarFile = 'StressTesting.jar'
    jobType = 'IN0111_revealWCET_run'
    for run in range(20):
        parameters = '-r 1 -i 50 --nSamples 20 --data res/LS_data_20190111_oldSeq_newPriority.csv'
        exe.create_jobs(exceptlist=exceptlist,
                        hours=48,
                        jobType=jobType + str(run),
                        jar=jarFile,
                        parameters=parameters,
                        include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)


def newdata_uniform():
    '''
    To reveal probability of Deadline misses.
    We use one uniform distribution(0s, 5s) to get WCET in scheduler.
    :param data:
    :return:
    '''
    exe = Executor()
    exceptlist = []
    include = [33, 34]
    jarFile = 'StressTesting.jar'
    jobType = 'IN0111_Uniform'
    parameters = '-r 1 --nSamples 20 --uniform --data res/LS_data_20190111_uniform.csv'
    exe.create_jobs(exceptlist=exceptlist, hours=80, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)


def newdata_PDF_uniform():
    '''
    To explore PDF of Deadline misses
    We use one uniform distribution [0, 20]s to get WCET in scheduler.
    :param data:
    :return:
    '''
    exe = Executor()
    exceptlist = []
    include = [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34]
    jarFile = 'StressTesting.jar'
    jobType = 'IN0111_PDF_Uniform'
    parameters = '-r 1 --nSamples 20 --uniform --data res/LS_data_20190111_uniform_long.csv'
    exe.create_jobs(exceptlist=exceptlist, hours=80, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)


def newdata_PDF_twouniform():
    '''
    To explore PDF of Deadline misses
    We use two uniform distribution [0, 20]s to get WCET in scheduler.
    :param data:
    :return:
    '''
    exe = Executor()
    exceptlist = []
    include = [6, 7, 8, 9, 10, 17, 27, 28, 29, 30, 31, 33, 34]
    jarFile = 'StressTesting.jar'
    jobType = 'IN0111_PDF_TwoUniform'
    parameters = '-r 1 --nSamples 20 --data res/LS_data_20190111_oldSeq_newPriority.csv'
    exe.create_jobs(exceptlist=exceptlist, hours=80, jobType=jobType, jar=jarFile, parameters=parameters, include=include)

    exe.create_stop_script(jobType)
    exe.create_remove_script(jobType)


if __name__ == "__main__":

    # newdata_base()
    # newdata_varying_two_uniform()
    # newdata_vary_revealWCET()
    # newdata_varying_two_uniform_threshold()
    # newdata_uniform()
    # newdata_PDF_uniform()
    # newdata_PDF_twouniform()
    newdata_varying_two_uniform_threshold(0.5)
    newdata_varying_two_uniform_threshold(0.7)
