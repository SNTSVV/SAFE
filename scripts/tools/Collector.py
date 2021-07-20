import os
import re
import math
from tqdm import tqdm
from TaskDescriptor import TaskDescriptor
import utils


class Colllector():
    def __init__(self):
        pass

    ##################################################
    # Collecting functions for timeinfo
    ##################################################
    def load_time(self, _filepath):
        if os.path.exists(_filepath) is False:
            return None

        f = open(_filepath)
        lines = f.readlines()
        f.close()

        rex = re.compile('[\d\.]+')
        data = {}
        for line in lines:
            items = line.split(":")
            idx = items[0].find("(")
            if idx >0:
                items[0] = items[0][:idx]

            idx = items[1].find("(")
            if idx >0:
                items[1] = items[1][:idx].strip()
            items[1] = rex.search(items[1]).group(0)

            items[0] = items[0].split(" ")[0]
            data[items[0]] = float(items[1].strip())
        return data

    def merge_execinfo(self, _dirpath, _outputname, _args):
        _pattern = _args.pattern if _args.pattern is not None else r'\d+'
        _targetName = _args.targetName if _args.targetName is not None else 'result.txt'
        _exptions = _args.exceptions

        output = open(_outputname, "w")
        output.write("Run,Total(s),InitHeap(MB),UsedHeap(MB),CommitHeap(MB),MaxHeap(MB),MaxNonHeap(MB)\n")

        targets = utils.expandDirs([{'path':_dirpath}], 'Run', _ptn=_pattern, _sort=True)
        progress = tqdm(desc='Collecting data', total=len(targets), unit=' #', postfix=None)
        for item in targets:
            if _exptions is not None and item['Run'] in _exptions:
                progress.update(1)
                progress.set_postfix_str(item['path'])
                continue

            timeInfo = self.load_time(os.path.join(item['path'], _targetName))
            if timeInfo is None:
                output.write("%d,NA, NA,NA,NA,NA,NA\n"% int(item['Run']))
            else:
                output.write("%d,%f, %f,%f,%f,%f,%f\n"% (
                    int(item['Run']),
                    timeInfo['TotalExecutionTime'],
                    timeInfo['InitHeap'],
                    timeInfo['usedHeap'],
                    timeInfo['commitHeap'],
                    timeInfo['MaxHeap'],
                    timeInfo['MaxNonHeap']
                ))
            progress.update(1)
            progress.set_postfix_str(item['path'])
        progress.close()
        output.close()

    ##################################################
    # Collecting functions for model
    ##################################################
    def load_bestpoints(self, _filepath, _targetUpdate=100):
        if os.path.exists(_filepath) is False:
            return None

        f = open(_filepath)
        lines = f.readlines()
        f.close()

        titles = lines[0].split(",")
        titles[-1] = titles[-1].strip()

        tasks = []
        for idx in range(1,len(titles)):
             if titles[idx].startswith("Px"):
                 tasks.append(int(titles[idx][4:-1]))

        flag=False
        for line in lines[1:]:
            items = line.split(",")
            update = int(float(items[0]))
            if update != _targetUpdate: continue

            nTrainingSize = int(float(items[1]))
            probability = float(items[2]) if items[2] not in ["NaN", "NULL", "NA"] else None
            bestSize = float(items[3]) if items[3] not in ["NaN", "NULL", "NA"] else None
            points=[]
            for idx in range(4,len(items)):
                if titles[idx].startswith("Px") is False: continue
                v = math.floor(float(items[idx])) if items[idx] not in ["NaN", "NULL", "NA"] else None
                points.append(v)
            flag = True
            break

        if flag is True:
            return {"Updates":update, "TrainingSize":nTrainingSize,
                         "Probability":probability,
                         "BestSize":bestSize, "Points": points, "Tasks": tasks}
        return None

    def calculate_bestsize(self, _taskInfo, _pointData, _timeQuanta, _special):
        uncertains = TaskDescriptor.getUncertainTasks(_taskInfo)
        tasks = _pointData['Tasks']
        points = _pointData['Points']

        # get min WCETs
        minDurations = []
        for tID in uncertains:
            minDurations.append(_taskInfo[tID-1].WCETmin)

        # get max range
        durations = []
        for tID in uncertains:
            if tID in tasks:
                # use sampled WCET
                d = 0
                for x in range(0, len(tasks)):
                    if tasks[x]!=tID: continue
                    d = points[x]
                if d is None:
                    d = _taskInfo[tID-1].WCETmin
                durations.append(d)
            else:
                durations.append(_taskInfo[tID-1].WCETmax)

        def product(_list, _min, _mulE=0):
            if len(_list)==0: return 0
            ret = 1
            for idx in range(0, len(_list)):
                v = (_list[idx] - _min[idx] + 1)*_timeQuanta
                ret = ret*v
                if _mulE > 0:
                    ret *= 10
                    _mulE -= 1
            return ret

        return {"Area":product(durations, minDurations, _special), "Points":durations}

    def process_onerun(self, _item, _nUpdates, _targetName, _uncertainTasks, _taskInfo, _timeQuanta, _output, _special):
        # load bestpoints and calculate bestsize
        filename = os.path.join(_item['path'], _targetName, 'workdata_model_result.csv')
        bestpoint = self.load_bestpoints(filename, _nUpdates)
        if bestpoint is not None:
            bestsize = self.calculate_bestsize(_taskInfo, bestpoint, _timeQuanta, _special)
            nTerms = len(bestpoint['Tasks'])
        else:
            bestsize = None
            nTerms = 0

        # load time info
        filename = os.path.join(_item['path'], _targetName, 'result2.txt')
        ExInfo = self.load_time(filename)
        if ExInfo is None or "TotalExecutionTime" not in ExInfo:
            exTime = "NA"
        else:
            exTime = "%f"%ExInfo["TotalExecutionTime"]

        # write result
        probStr = '%f'%bestpoint['Probability'] if bestpoint['Probability'] is not None else "NA"
        header = "%d,%s,%d,%s"%(int(_item['Run']), exTime, nTerms, probStr)
        if bestsize is None:
            pointStr = ','.join(['NA']*len(_uncertainTasks))
            _output.write("%s,NA,%s\n"% (header, pointStr))
        else:
            pointStr = ','.join(['%d'%x for x in bestsize['Points']])
            _output.write("%s,%.20f,%s\n"% (header, bestsize['Area'], pointStr))
        pass

    def merge_p2_model(self, _dirpath,  _outputname, _args):
        # parameter passing
        _pattern = _args.pattern if _args.pattern is not None else r'\d+'
        _exptions = _args.exceptions
        _targetName = _args.targetName if _args.targetName is not None else '_phase2'
        _nUpdates = _args.nUpdates if _args.nUpdates is not None else 100
        _timeQuanta = _args.timeQuanta if _args.timeQuanta is not None else 0.01
        _special = _args.special if _args.special is not None else 0

        # listing target directories
        targets = utils.expandDirs([{'path':_dirpath}], 'Run', _ptn=_pattern, _sort=True)
        taskInfo = TaskDescriptor.load_fromFile(os.path.join(targets[0]['path'], 'input.csv'), _timeQuanta)
        uncertainTasks = TaskDescriptor.getUncertainTasks(taskInfo)

        # output
        output = open(_outputname, "w")
        output.write("Run,ExecutionTime(s),nTerms,Probability,BestSize,%s\n"%(','.join(["T%d"%t for t in uncertainTasks])))

        # progressing
        progress = tqdm(desc='Collecting data', total=len(targets), unit=' #', postfix=None)
        for item in targets:
            if _exptions is not None and item['Run'] in _exptions:
                progress.update(1)
                progress.set_postfix_str(item['path'])
                continue

            try:
                self.process_onerun(item, _nUpdates, _targetName, uncertainTasks, taskInfo, _timeQuanta, output, _special)
            except Exception as e:
                print('Filed to get information: run%02d' % int(item['Run']))

            progress.update(1)
            progress.set_postfix_str(item['path'])
        progress.close()
        output.close()

    ##################################################
    # Collecting functions for model (for EXP1 and EXP2)
    ##################################################
    def collect_workfile(self, _item, _targetName, _output, _first=False):
        # load target file
        targetFile = os.path.join(_item['path'], _targetName)
        if os.path.exists(targetFile) is False:
            return None

        f = open(targetFile)

        # write title if it needs
        title = f.readline()
        if _first is True:
            _output.write(title)

        # write data
        while True:
            line = f.readline()
            if line == '' or line is None: break
            line = '%d,'% int(_item['Run']) + line
            _output.write(line)
        f.close()
        pass

    def merge_p2_test(self, _dirpath,  _outputname, _args):
        # parameter passing
        _pattern = _args.pattern if _args.pattern is not None else r'\d+'
        _exptions = _args.exceptions
        _targetName = _args.targetName if _args.targetName is not None else '_phase2/workdata_test_result.csv'

        # listing target directories
        targets = utils.expandDirs([{'path':_dirpath}], 'Run', _ptn=_pattern, _sort=True)

        # output
        output = open(_outputname, "w")
        output.write("Run,")

        # progressing
        first = True
        progress = tqdm(desc='Collecting data', total=len(targets), unit=' #', postfix=None)
        for item in targets:
            if _exptions is not None and item['Run'] in _exptions:
                progress.update(1)
                progress.set_postfix_str(item['path'])
                continue
            try:
                self.collect_workfile(item, _targetName, output, first)
            except Exception as e:
                print('Filed to get information: run%02d' % int(item['Run']))

            first = False
            progress.update(1)
            progress.set_postfix_str(item['path'])
        progress.close()
        output.close()


def parse_arg():
    import argparse
    import sys
    parser = argparse.ArgumentParser(description='Paremeters')
    parser.add_argument('-b', dest='basePath', type=str, default=None, help='base path')
    parser.add_argument('-f', dest='function', type=str, default=None, help='the name of working function')
    parser.add_argument('-o', dest='outputName', type=str, default=None, help='')
    parser.add_argument('-p', dest='pattern', type=str, default=None, help='sub dir pattern')
    parser.add_argument('-e', dest='exceptions', type=str, default=None, help='except variables')
    parser.add_argument('-t', dest='targetName', type=str, default=None, help='target name')
    parser.add_argument('-q', dest='timeQuanta', type=float, default=None, help='time quanta of the system')
    parser.add_argument('-u', dest='nUpdates', type=str, default=None, help='number of updates in phase2')
    parser.add_argument('-z', dest='special', type=int, default=None, help='special point')
    parser.add_argument('-n', dest='Nums', type=int, default=None, help='Nums')

    # parameter parsing
    args = sys.argv[1:]  # remove executed file
    args = parser.parse_args(args=args)
    if args.basePath is None or len(args.basePath)==0:
        parser.print_help()
        exit(1)

    if args.outputName is None or len(args.outputName)==0:
        parser.print_help()
        exit(1)

    if args.function is None or len(args.function)==0:
        parser.print_help()
        exit(1)

    return args


if __name__ == "__main__":
    args = parse_arg()
    print("#################################")
    print("Work function: %s" % args.function)
    print("Work basepath: %s" % args.basePath)
    print("Target Name  : %s" % args.targetName)
    print("Output Path  : %s" % args.outputName)

    targetFile = os.path.abspath(args.outputName)
    parDir = os.path.dirname(targetFile)
    if os.path.exists(parDir) is False:
        os.makedirs(parDir)

    obj = Colllector()
    getattr(obj, args.function)(args.basePath, args.outputName, args)

    print("Done.")
