import os
import re
import time
from TaskDescriptor import TaskDescriptor


#######
# Best size calculator for the Ransom Search
#######
class BestSizeRandom():
    def __init__(self):
        pass

    def expandDirs(self, _dirList, _findKey='', _ptn=None, _sort=False):
        rex = None
        if _ptn is not None:
            rex = re.compile(_ptn)

        ret = []
        for dirItem in _dirList:
            data = []
            flist = os.listdir(dirItem['path'])
            for fname in flist:
                fullpath = os.path.join(dirItem['path'], fname)
                if os.path.isfile(fullpath): continue          # pass not a directory
                if fullpath.startswith(".") is True: continue  # pass hidden dir

                if rex is not None:
                    result = rex.search(fname)
                    if result == None:
                        print("\tPattern ('%s') doesn't matach: %s"%(_ptn, fullpath))
                        continue
                    fname = result.group(0)
                newItem = dirItem.copy()
                newItem[_findKey] = fname
                newItem['path'] = fullpath
                data.append(newItem)
            if _sort is True:
                def selectKey(_item):
                    return _item[_findKey]
                data.sort(key=selectKey)
            ret += data
        return ret

    ##################################################
    # Calculate best size for the Random Search
    ##################################################
    def load_samples(self, _filename):
        data = []
        f = open(_filename, 'r')
        line = f.readline()  # throw 1st line

        titles = line.split(",")
        titles[-1] = titles[-1].strip()

        tasks = []
        for idx in range(1,len(titles)):
            if titles[idx].startswith("T"):
                tasks.append(int(titles[idx][1:]))

        while True:
            line = f.readline()
            if line is None or len(line)==0: break
            cols = line.strip().split(',')
            cols = [int(x) for x in cols]
            data.append(cols)
        f.close()
        return tasks, data

    def check_under_hyperbox(self, _selected, _target):
        # the first column is the label
        for x in range(1, len(_selected)):
            if _target[x] > _selected[x]: return False
        return True

    def collect_hyperbox_points(self, _data, _run):
        availables = []
        # progress = tqdm(desc='Searching hyper-box points (Run%d)'%_run, total=len(_data), unit=' #', postfix=None)
        # selects a point
        for s in range(0, len(_data)):
            if _data[s][0] > 0: continue  # except if the s point has deadline miss

            # finds points where located inside of the s point and check it has deadline miss
            flag = True  # True means no deadline miss
            for t in range(0, len(_data)):
                if s == t: continue       # pass if the two points are the same
                if self.check_under_hyperbox(_data[s], _data[t]) is False: continue

                # makes the flag False if the t point has deadline miss and stop checking
                if _data[t][0] > 0:
                    flag = False
                    break

            # if the hyper-box by s point has no points that missed deadline, we add it the available points list
            if flag is True:
                availables.append(_data[s])
                # if (len(availables)>5): break  # for debug

            flush = True if (s%100)==0 else False
            print("Searching hyper-box points(Run%d)-%d/%d"%(_run, s+1, len(_data)), flush=flush)
            # progress.update(1)
            # progress.set_postfix_str("selected points: %d" % len(availables))
        # progress.close()
        return availables

    def calculate_area(self, _point, _targetTasks, _taskInfo):
        '''
        tasks = all tasks (some tasks has no WCET range)
                if all tasks are considered to calculate area, the result will be 0
                so, here only concerns uncertain tasks.
        uncertainTasks = tasks that have a WCET range
        targetTasks = tasks that have selected in the Phase 2
        '''
        uncertains = TaskDescriptor.getUncertainTasks(_taskInfo)

        # get min WCETs
        minDurations=[]
        for tID in uncertains:
            minDurations.append(_taskInfo[tID-1].WCETmin)

        # get max WCETs
        maxDurations = []
        for tID in uncertains:
            maxDurations.append(_taskInfo[tID-1].WCETmax)

        # update WCET values for the selected tasks
        for x in range(0, len(_point)):
            tID = _targetTasks[x]
            idx = 0
            for x in range(0, len(uncertains)):
                if uncertains[x]!=tID: continue
                idx = x
                break
            maxDurations[idx] = _point[x]

        def product(_list, _min):
            if len(_list)==0: return 0
            # the first column is the label
            ret = 1
            for idx in range(0, len(_list)):
                v = _list[idx] - _min[idx] + 1
                ret = ret*v
            return ret
        return product(maxDurations, minDurations)

    def calculate_bestsize_random(self, _points, _targetTasks, _taskInfo):
        if len(_points)!=0:
            best = 0
            bestP = 0
            for x in range(0, len(_points)):
                # calculate area without the label
                area = self.calculate_area(_points[x][1:], _targetTasks, _taskInfo)
                if best < area:
                    best = area
                    bestP = x
            return {"Area":best, "Points":_points[bestP][1:]}  # without the label
        return None

    def run(self, _dirpath,  _args):
        # parameter passing
        _pattern = _args.pattern if _args.pattern is not None else r'\d+'
        _exptions = _args.exceptions
        _targetName = _args.targetName if _args.targetName is not None else '_phase1'
        _outputName = _args.outputName if _args.outputName is not None else '_phase2'
        _nUpdates = _args.nUpdates if _args.nUpdates is not None else 100
        _timeQuanta = _args.timeQuanta if _args.timeQuanta is not None else 0.01
        _runNums = _args.runNums if _args.runNums is not None else 0
        _runSpecified = _args.runID if _args.runID is not None else 0

        # listing target directories
        if _runNums > 0:
            targets = self.expandDirs([{'path':_dirpath}], 'Run', _ptn=_pattern, _sort=True)
        else:
            targets = [{'path':_dirpath, 'Run':0}]
        taskInfo = TaskDescriptor.load_fromFile(os.path.join(targets[0]['path'], 'input.csv'), _timeQuanta)
        uncertainTasks = TaskDescriptor.getUncertainTasks(taskInfo)

        for item in targets:
            if _exptions is not None and item['Run'] in _exptions:
                continue
            run = int(item['Run'])
            if _runSpecified != 0 and run != _runSpecified: continue

            filename = os.path.join(item['path'], _targetName, 'sampledata.csv')

            # additional output
            print("Collecting data Run%02d"%run, flush=True)
            startTS = time.time()
            targetTasks, data = self.load_samples(filename)
            points = self.collect_hyperbox_points(data, run)
            bestsize = self.calculate_bestsize_random(points, targetTasks, taskInfo)
            elapsedTime = time.time() - startTS

            # Write phase2 result
            self.write_phase2_result(os.path.join(item['path'], _outputName),
                                     uncertainTasks, bestsize,
                                     _nUpdates, len(data), elapsedTime)

        #     if bestsize is None:
        #         pointStr = ','.join(['NA']*len(uncertainTasks))
        #         output.write("%d,NA,%s\n"% (int(item['Run']), pointStr))
        #     else:
        #         pointStr = ','.join(['%d'%x for x in bestsize['Points']])
        #         output.write("%d,%d,%s\n"% (int(item['Run']), bestsize['Area'], pointStr))
        #     output.flush()
        # output.close()

    def write_phase2_result(self, _path, _uncertainTasks, _bestsize, _nUpdates, _nPoints, _elapsedTime):
        # write dir
        if os.path.exists(_path) is False:
            os.makedirs(_path)

        # logging time
        f = open(os.path.join(_path, 'result2.txt'), 'w')
        f.write("TotalExecutionTime(s): %.f (success)\n"%(_elapsedTime))
        f.close()

        # write model results
        f = open(os.path.join(_path, 'workdata_model_result.csv'), 'w')
        taskStr=','.join("Px(T%d)"%t for t in _uncertainTasks)
        f.write("nUpdate,TrainingSize,Probability,BestPointArea,%s\n"%taskStr)
        if _bestsize is None:
            pointStr = ','.join(['NA']*len(_uncertainTasks))
            f.write("%d,%d,%f,NA,%s\n"% (_nUpdates, _nPoints, 0.0, pointStr))
        else:
            pointStr = ','.join(['%d'%x for x in _bestsize['Points']])
            f.write("%d,%d,%f,%f,%s\n"% (_nUpdates, _nPoints, 0.0, _bestsize['Area'], pointStr))
        f.close()


def parse_arg():
    import argparse
    import sys
    parser = argparse.ArgumentParser(description='Parameters')
    parser.add_argument('-b', dest='basePath', type=str, default=None, help='base path')
    parser.add_argument('-p', dest='pattern', type=str, default=None, help='sub dir pattern')
    parser.add_argument('-e', dest='exceptions', type=str, default=None, help='except variables')
    parser.add_argument('-w1', dest='targetName', type=str, default=None, help='target name')
    parser.add_argument('-w2', dest='outputName', type=str, default=None, help='output name')
    parser.add_argument('-q', dest='timeQuanta', type=float, default=None, help='time quanta of the system')
    parser.add_argument('-u', dest='nUpdates', type=int, default=None, help='number of updates for Phase2')
    parser.add_argument('-n', dest='runNums', type=int, default=0, help='number of runs of Phase1')
    parser.add_argument('-r', dest='runID', type=int, default=0, help='Specify a run')

    # parameter parsing
    args = sys.argv[1:]  # remove executed file
    args = parser.parse_args(args=args)
    if args.basePath is None or len(args.basePath)==0:
        parser.print_help()
        exit(1)

    return args


if __name__ == "__main__":
    args = parse_arg()
    print("#################################")
    print("Work basepath: %s" % args.basePath)

    obj = BestSizeRandom()
    obj.run(args.basePath, args)
    print("Done.")
