import os
from utils.data import DataFrameDecimal
from csv import Dialect


class WCETAnalyzer():
    dialect = None
    TestName = []
    TaskList = []
    PriorityMap = {}
    root = '/Users/jaekwon.lee/SVVDrive/StressTesting/experiments/WCET/RT_28-02-2019'  # /E-SAIL-ASW-TST-74

    def __init__(self):
        self.TestName = []
        self.TestName.append({'Priority':60,'Name':'Can_InputHandlerTask'})
        self.TestName.append({'Priority':71,'Name':'obtm_SynchronizationTask'})
        self.TestName.append({'Priority':80,'Name':'TmTcSysHandlerTask'})
        self.TestName.append({'Priority':81,'Name':'Can_PeriodicTask'})
        self.TestName.append({'Priority':82,'Name':'HkGroupReportingTask'})
        self.TestName.append({'Priority':83,'Name':'TcHandlerTask'})
        self.TestName.append({'Priority':84,'Name':'TcRealtimeProcessingTask'})
        self.TestName.append({'Priority':85,'Name':'TcTransferFrameReaderTask'})
        self.TestName.append({'Priority':86,'Name':'DownlinkTask'})
        self.TestName.append({'Priority':87,'Name':'TmHandlerTask'})
        self.TestName.append({'Priority':88,'Name':'Can_DispatcherTask'})
        self.TestName.append({'Priority':89,'Name':'Can_OutputHandlerTask'})
        self.TestName.append({'Priority':90,'Name':'pus11_TheScheduler_task'})
        self.TestName.append({'Priority':100,'Name':'EpsHandlerTask'})
        self.TestName.append({'Priority':110,'Name':'AdcsHandlerTask'})
        self.TestName.append({'Priority':111,'Name':'AdcsControllerTask'})
        self.TestName.append({'Priority':120,'Name':'PPSManagementTask'})
        self.TestName.append({'Priority':130,'Name':'OBCHandlerTask'})
        self.TestName.append({'Priority':131,'Name':'TcScheduledProcessingTask'})
        self.TestName.append({'Priority':132,'Name':'PDHUHandlerTask'})
        self.TestName.append({'Priority':133,'Name':'PDDHousekeepingTask'})
        self.TestName.append({'Priority':134,'Name':'MemoryHandlerTask'})
        self.TestName.append({'Priority':140,'Name':'TcsyThermalControlTask'})
        self.TestName.append({'Priority':150,'Name':'PayloadDataDownlinkTask'})
        self.TestName.append({'Priority':151,'Name':'SwUploadProcessingTask'})
        self.TestName.append({'Priority':152,'Name':'PayloadCmdProcessingTask'})
        self.TestName.append({'Priority':160,'Name':'EGSEDebugInterfaceTask'})
        self.TestName.append({'Priority':170,'Name':'PayloadDataAcquisitionTask'})
        self.TestName.append({'Priority':171,'Name':'GPSTimeManagerTask'})
        self.TestName.append({'Priority':172,'Name':'GPSHandlerTask'})
        self.TestName.append({'Priority':173,'Name':'FDIR_RecoveryManagerTask'})
        self.TestName.append({'Priority':174,'Name':'PayloadDirectCmdTask'})
        self.TestName.append({'Priority':180,'Name':'opse_SequencesExecutionTask'})
        self.TestName.append({'Priority':200,'Name':'SoftKeepAliveTask'})
        pass

    def setDialet(self, delimiter=',', line='\n'):
        self.dialect = Dialect
        self.dialect.delimiter = delimiter
        self.dialect.lineterminator = line
        self.dialect.quoting='\''

    def load_task_info(self):
        tasksfile='/Users/jaekwon.lee/projects/StressTesting/res/LS_data_20190111_oldSeq_newPriority.csv'

        timeunit = 1000000

        data = DataFrameDecimal.from_csv(tasksfile, _header=0)
        # self.TaskList[0] = {'Period': data[0]['Period']}

        self.TaskList = []
        for x in range(data.rows):
            row = data.get(x, _row=True)
            self.TaskList.append({'Name':row[0],
                                  'Type':row[1],
                                  'Period':row[5]*timeunit,
                                  'Deadline':row[8]*timeunit,
                                  'Priority':row[2],
                                  'MinIA':row[6]*timeunit,
                                  'MaxIA':row[7]*timeunit})

        for x in range(len(self.TaskList)):
            self.PriorityMap[self.TestName[x]['Priority']] = x
        pass

    def run(self):
        self.load_task_info()
        expFolders = os.listdir(self.root)

        for name in expFolders:
            targetDir = os.path.join(self.root, name)
            if os.path.isfile(targetDir): continue

            #get GPIO information
            GPIO = self.get_GPIO_info(targetDir)

            filepath = os.path.join(targetDir, 'tasktrace.txt')
            self.setDialet('\t','\n')
            data = DataFrameDecimal.from_csv(filepath, _header=0, _dialect=self.dialect)

            print(name)
            results= {}
            for p in self.PriorityMap.keys():
                target_task = self.TaskList[self.PriorityMap[p]]
                # print("\t%s (%d):"% (task['Name'], p))
                if target_task['Type'] != 'Periodic':
                    results[p] = []
                else:
                    gpio = GPIO['GPIO'] if target_task['Priority'] in GPIO.keys() else None

                    results[p] = self.analysis(data.get(0), data.get(1), p, target_task, gpio)
            self.printout(dir, name, results)
        pass

    def analysis(self, _ticks, _tasks, _id, _task, _GPIO):
        # find starting point
        point = 0  # point X
        for x in range(point, len(_tasks)):
            # if _ticks[x] in [1,255]: continue
            if _tasks[x] != _id: continue
            point = x
            break

        # working
        items = []

        #arrival = _ticks[point]
        arrival = int(_ticks[point] / _task['Period']) * _task['Period']
        started = _ticks[point]
        ended = _ticks[point]
        WCET = 0
        deadline = arrival + _task['Deadline']
        preempted = 0
        period = _task['Period']
        checking = True
        for x in range(point+1, len(_tasks)):
            if _tasks[x] != _id:
                if checking is False: continue
                #append one item
                WCET += _ticks[x] - ended
                ended = _ticks[x]
                checking = False
                continue

            # treat preempted task
            if _ticks[x] >= arrival+period:
                items.append([arrival, started, ended, deadline, WCET, preempted])
                WCET = 0
                started = 0
                ended = 0
                preempted = 0
                arrival = arrival + period
                deadline = arrival + _task['Deadline']
            else:
                ended = _ticks[x]
                preempted += 1
                checking = True
                continue

            while _ticks[x] > deadline:
                items.append([arrival, started, ended, deadline, WCET, preempted])
                arrival = arrival + period
                deadline = arrival + _task['Deadline']
            # calculate start time.
            started = _ticks[x]
            ended = _ticks[x]
            preempted = 0
            checking = True

        # add one execution when previous for block ended up with 'checking is True'
        # We don't add execution because we don't know the finish time of this simulation
        return items

    def printout(self, path, dirname, _results):
        # printout on the screen
        # print(dirname)
        # for p in _results.keys():
        #     task = self.TaskList[self.PriorityMap[p]]
        #
        #     print("\t%s (%d):"% (task['Name'], p))
        #
        #     if task['Type'] != 'Periodic':
        #         print('\t\t Not Target:: This tasks is non-periodic.')
        #     else:
        #         print('\t\t arrival\t started\t   ended\tdeadline\tWCET(ms)\tPreempted')
        #         for exec in _results[p]:
        #             print('\t\t{:>8d}\t{:>8d}\t{:>8d}\t{:>8d}\t{:>8d}\t{:>8d}'.format(exec[0], exec[1], exec[2],exec[3], exec[4], exec[5]))

        #printout on the file
        print(dirname)
        file = open(os.path.join(path, 'tasktrace_executions.csv'), 'w')
        file.write('name,priority,arrival,started,ended,deadline,WCET,Preempted\n')

        for p in _results.keys():
            task = self.TaskList[self.PriorityMap[p]]
            if task['Type'] != 'Periodic': continue
            for arrival,started,ended,deadline,WCET,preempted in _results[p]:
                file.write('{},{:d},{:d},{:d},{:d},{:d},{:d},{:d}\n'.format(task['Name'],p,arrival,started,ended,deadline,WCET,preempted))
        file.close()


        file = open(os.path.join(path, 'tasktrace_statistics_WCET.csv'), 'w')
        file.write('name,priority,expected_executions,real_executions,WCET(min),WCET(max),WCET(mid),WCET(avg)\n')
        for p in _results.keys():
            task = self.TaskList[self.PriorityMap[p]]
            if task['Type'] != 'Periodic': continue

            WCETs = []
            expected_executions = len(_results[p])
            real_executions = 0
            for arrival,started,ended,deadline,WCET,preempted in _results[p]:
                if started != 0:
                    real_executions += 1
                    WCETs.append(WCET)

            if len(WCETs)==0:
                file.write('{},{:d},{:d},{:d},{:d},{:d},{:.4f},{:.4f}\n'.format(
                    task['Name'], p, 0, 0, 0, 0, 0.0, 0.0))
            else:
                file.write('{},{:d},{:d},{:d},{:d},{:d},{:.4f},{:.4f}\n'.format(
                    task['Name'],p,expected_executions, real_executions,
                    min(WCETs), max(WCETs),self.mid(WCETs), self.avg(WCETs)))
        file.close()
        pass

    def mid(self, _list):
        _list.sort()
        size = len(_list)
        mid = _list[int(size/2)]
        if size%2 == 0:
            a = _list[int(size/2)]
            b = _list[int(size/2)-1]
            mid = (a+b)/2
        return mid

    def avg(self, _list):
        return sum(_list) / len(_list)

    #############################################
    # GPIO
    #############################################
    def run_GPIO(self):

        self.load_task_info()
        expFolders = os.listdir(self.root)

        for name in expFolders:
            targetDir = os.path.join(self.root, name)
            if os.path.isfile(targetDir): continue

            # get GPIO information
            GPIO = self.get_GPIO_info(targetDir)

            filepath = os.path.join(targetDir, 'tasktrace.txt')
            self.setDialet('\t','\n')
            data = DataFrameDecimal.from_csv(filepath, _header=0, _dialect=self.dialect)

            print(name)
            for tID in GPIO.keys():
                tPriority = self.TaskList[tID]['Priority']
                tGPIO = GPIO[tID]['GPIO']
                task = self.TaskList[tID]

                result = self.analysis_GPIO(data.get(0), data.get(1), tPriority, task, tGPIO)
                self.printout_GPIO(targetDir, task, result)
        pass

    def get_GPIO_info(self, _targetDir):
        '''
        load information from GPIO files
        :param _targetDir:
        :return:
        '''

        # make taskname to compare
        TaskNames1 = []
        for item in self.TestName:
            name = item['Name'].lower()
            name = name.replace('_', '')
            if name.endswith('task') is True:
                name = name[:-4]
            TaskNames1.append(name)

        # make taskname to compare
        TaskNames2 = []
        for item in self.TaskList:
            name = item['Name'].lower()
            name = name.replace('_', '')
            if name.endswith('task') is True:
                name = name[:-4]
            TaskNames2.append(name)

        data = {}
        # looking for GPIO monitor results.
        files = os.listdir(_targetDir)
        for filename in files:
            fname = filename.lower()
            if fname.startswith('monitor@')is False: continue
            fname = fname.replace('_', '')
            idx = fname.find('task')
            name = fname[8:idx]

            for x in range(len(TaskNames1)):
                if name != TaskNames1[x] and TaskNames2[x] != name: continue
                filepath = os.path.join(_targetDir, filename)
                self.setDialet('\t','\n')
                items = DataFrameDecimal.from_csv(filepath, _header=0, _dialect=self.dialect)

                if len(items) == 0:
                    break

                ts = items.get(0)
                pins = items.get(2)
                unit = 1000000000
                flag = pins[0]    # started flag

                executionsGPIO = []
                started = 0
                for t in range(len(ts)):
                    if pins[t] == flag:
                        started = int(ts[t]*unit)
                    else:
                        if started == 0:
                            print("ERROR to load GPIO data from %s"%filepath)
                            break
                        ended   = int(ts[t]*unit)
                        diff = ended - started
                        executionsGPIO.append([started, ended, diff])
                        started = 0

                data[x] = {"Name":self.TaskList[x], "GPIO":executionsGPIO}
                break

        return data

    def analysis_GPIO(self, _ticks, _tasks, _id, _target, _GPIO):
        # find starting point
        point = 0  # point X
        for x in range(point, len(_tasks)):
            # if _ticks[x] in [1,255]: continue
            if _tasks[x] != _id: continue
            point = x
            break

        # working
        items = []

        #arrival = _ticks[point]
        if _target['Type'] == 'Periodic':
            arrival = int(_ticks[point] / _target['Period']) * _target['Period']
            started = _ticks[point]
            ended = _ticks[point]
            WCET = 0
            deadline = arrival + _target['Deadline']
            preempted = 0
            period = _target['Period']

        #elif (_target['Type'] != 'Periodic' and _target['MinIA'] == _target['MaxIA']):
        else:
            arrival = int(_ticks[point] / _target['MinIA']) * _target['MinIA']
            started = _ticks[point]
            ended = _ticks[point]
            WCET = 0
            deadline = arrival + _target['Deadline']
            preempted = 0
            period = _target['MinIA']

        checking = True
        for x in range(point+1, len(_tasks)):
            if _tasks[x] != _id:
                if checking is False: continue
                #append one item
                WCET += _ticks[x] - ended
                ended = _ticks[x]
                checking = False
                continue

            # treat preempted task
            if _ticks[x] >= arrival+period:
                gSTARTED, gENDED, gWCET, gPreempted = self.get_GPIO_analysis(_GPIO, started, ended)

                if gSTARTED != 0:
                    items.append([arrival, started, ended, deadline, WCET, preempted, gSTARTED, gENDED, gWCET, gPreempted])
                else:
                    items.append([arrival, started, ended, deadline, WCET, preempted])
                WCET = 0
                started = 0
                ended = 0
                preempted = 0
                arrival = arrival + period
                deadline = arrival + _target['Deadline']
            else:
                ended = _ticks[x]
                preempted += 1
                checking = True
                continue

            while _ticks[x] > deadline:
                items.append([arrival, started, ended, deadline, WCET, preempted])
                arrival = arrival + period
                deadline = arrival + _target['Deadline']
            # calculate start time.
            started = _ticks[x]
            ended = _ticks[x]
            preempted = 0
            checking = True

        # add one execution when previous for block ended up with 'checking is True'
        # We don't add execution because we don't know the finish time of this simulation
        return items

    def get_GPIO_analysis(self, _GPIO, _started, _ended):
        gWCET = 0
        gStarted=0
        gEnded = 0
        gPreempted = -1

        for x in range(len(_GPIO)):
            if _GPIO[x][0] > _ended: break
            if _started < _GPIO[x][0]:
                if gStarted == 0:
                    gStarted = _GPIO[x][0]
                gWCET += _GPIO[x][2]
                gEnded = _GPIO[x][1]
                gPreempted += 1

        return gStarted, gEnded, gWCET, gPreempted

    def printout_GPIO(self, path, _task, _results):
        tf = open(os.path.join(path, 'GPIO_%s_%s.csv'%(_task['Type'], _task['Name'])), 'w')
        tf.write('name,priority,arrival,started,ended,deadline,WCET,Preempted,GPIO_started,GPIO_ended,GPIO_WCET,GPIO_Preempted\n')
        for item in _results:
            tf.write('{},{:d},{:d},{:d},{:d},{:d},{:d},{:d}'.format(_task['Name'],_task['Priority'],item[0],item[1],item[2],item[3],item[4],item[5]))
            if len(item) > 6:
                tf.write(',{:d},{:d},{:d},{:d}\n'.format(item[6], item[7], item[8], item[9]))
            else:
                tf.write('\n')
        tf.close()
        pass





if __name__ == '__main__':
    obj = WCETAnalyzer()
    # obj.run()
    obj.run_GPIO()