import os
from tqdm import tqdm
import utils


class RoundTripColllector():
    def __init__(self):
        pass

    ##################################################
    # Collecting round-trip result
    ##################################################
    def load_roundtrip_summary(self, _filename, _cntCol, _startCol=0):
        if os.path.exists(_filename) is False:
            return None

        data = {"title":[], "body":[]}
        _endCol =  _startCol + _cntCol
        f = open(_filename)
        title = f.readline()
        titles = title.split(",")
        data['title'] = titles[_startCol:_endCol]

        body = []
        while True:
            line = f.readline().strip()
            if line is None: break
            line = line.strip()
            if len(line)==0: break

            cols = line.split(",")
            items = [0]*_cntCol
            for x in range(_startCol, _endCol):
                items[x] = int(cols[x])
            body.append(items)
            # break
        f.close()
        data['body'] = body
        return data

    def init_output_files(self, _outputname):
        parent = os.path.dirname(_outputname)
        if os.path.exists(parent) is False:
            os.makedirs(parent)

        filename, ext = os.path.splitext(_outputname)

        # create output Main
        output = open('%s%s'%(filename, ext), "w")
        output.write("Run,countDM,numSol,ratioDM\n")
        output.close()

        # create output Tasks
        output = open('%s.numTask%s'%(filename, ext), "w")
        output.write("Run,numTasks\n")
        output.close()

        # create output Execs
        output = open('%s.numExecs%s'%(filename, ext), "w")
        output.write("Run,numExecs\n")
        output.close()

        # create output SizeDM
        output = open('%s.sumSizeDM%s'%(filename, ext), "w")
        output.write("Run,sumSizeDM\n")
        output.close()
        pass

    def save_roundtrip_summary(self, _outputname, _run, _countDM, _allSolutions, _numTasks, _numExecutions, _sumSizeDM):

        # create output Main
        filename, ext = os.path.splitext(_outputname)
        output = open('%s%s'%(filename, ext), "a")
        ratioDM = _countDM/_allSolutions
        output.write("%d,%d,%d,%.20f\n"%(_run, _countDM, _allSolutions, ratioDM))
        output.close()

        # create output Tasks
        output = open('%s.numTask%s'%(filename, ext), "a")
        for value in _numTasks:
            output.write("%d,%d\n"%(_run, value))
        output.close()

        # create output Execs
        output = open('%s.numExecs%s'%(filename, ext), "a")
        for value in _numExecutions:
            output.write("%d,%d\n"%(_run, value))
        output.close()

        # create output SizeDM
        output = open('%s.sumSizeDM%s'%(filename, ext), "a")
        for value in _sumSizeDM:
            output.write("%d,%d\n"%(_run, value))
        output.close()
        pass

    def merge_roundtrip_subject(self, _dirpath,  _outputname, _args):
        # parameter passing
        _pattern = _args.pattern if _args.pattern is not None else r'\d+'
        _exptions = _args.exceptions
        _targetName = _args.targetName if _args.targetName is not None else '_roundtrip'
        _nUpdates = _args.nUpdates if _args.nUpdates is not None else 100
        _timeQuanta = _args.timeQuanta if _args.timeQuanta is not None else 0.01
        _special = _args.special if _args.special is not None else 0

        # listing target directories
        targets = utils.expandDirs([{'path':_dirpath}], 'Run', _ptn=_pattern, _sort=True)
        self.init_output_files(_outputname)

        # progressing
        progress = tqdm(desc='Collecting data', total=len(targets), unit=' #', postfix=None)
        for item in targets:
            if _exptions is not None and item['Run'] in _exptions:
                progress.update(1)
                progress.set_postfix_str(item['path'])
                continue
            run = int(item['Run'])

            filename = '%s/%s/result.csv'%(item['path'], _targetName)
            data = self.load_roundtrip_summary(filename, 6, _startCol=0) # load 0:5 columns from the file
            if data is None:
                print("No file of %s"%(filename))
                continue

            results = data['body']
            countDM=0
            numTasks=[]
            numExecutions=[]
            sumSizeDM=[]
            for x in range(0, len(results)):
                # WID(0), solutionID(1), DM(2), numTasks(3), numExecutions(4), sumSizeDM(5)
                line = results[x]
                if line[2]==0: continue
                countDM+=1
                numTasks.append(line[3])
                numExecutions.append(line[4])
                sumSizeDM.append(line[5])

            if countDM==0:
                numTasks.append(0)
                numExecutions.append(0)
                sumSizeDM.append(0)

            self.save_roundtrip_summary(_outputname, run,
                                        countDM, len(results), numTasks, numExecutions, sumSizeDM)

            progress.update(1)
            progress.set_postfix_str(item['path'])
        progress.close()
        pass

    def merge_roundtrip(self, _dirpath,  _outputname, _args):
        # parameter passing
        _pattern = _args.pattern if _args.pattern is not None else r'\d+'
        _exptions = _args.exceptions
        _targetName = _args.targetName if _args.targetName is not None else '_roundtrip'
        _nUpdates = _args.nUpdates if _args.nUpdates is not None else 100
        _timeQuanta = _args.timeQuanta if _args.timeQuanta is not None else 0.01
        _special = _args.special if _args.special is not None else 0

        # listing target directories
        targets = utils.expandDirs([{'path':_dirpath}], 'Variable', _exceptionPtn=r'^_\w+')
        targets = utils.expandDirs(targets, 'Run', _ptn=_pattern, _sort=True)
        self.init_output_files(_outputname)

        # progressing
        progress = tqdm(desc='Collecting data', total=len(targets), unit=' #', postfix=None)
        for item in targets:
            if _exptions is not None and item['Run'] in _exptions:
                progress.update(1)
                progress.set_postfix_str(item['path'])
                continue
            codes = item['Variable'].split("_")
            subject = codes[0]
            approach = codes[2] if len(codes)>2 else codes[1]
            run = int(item['Run'])

            filename = '%s/%s/result.csv'%(item['path'], _targetName)
            data = self.load_roundtrip_summary(filename, 6, _startCol=0) # load 0:5 columns from the file
            if data is None:
                print("No file of %s"%(filename))
                continue

            results = data['body']
            countDM=0
            numTasks=[]
            numExecutions=[]
            sumSizeDM=[]
            for x in range(0, len(results)):
                # WID(0), solutionID(1), DM(2), numTasks(3), numExecutions(4), sumSizeDM(5)
                line = results[x]
                if line[2]==0: continue
                countDM+=1
                numTasks.append(line[3])
                numExecutions.append(line[4])
                sumSizeDM.append(line[5])

            if countDM==0:
                numTasks.append(0)
                numExecutions.append(0)
                sumSizeDM.append(0)

            self.save_roundtrip_summary(_outputname, subject, approach, run,
                                        countDM, len(results), numTasks, numExecutions, sumSizeDM)

            progress.update(1)
            progress.set_postfix_str(item['path'])
        progress.close()
        pass


def parse_arg():
    import argparse
    import sys
    parser = argparse.ArgumentParser(description='Parameters')
    parser.add_argument('-b', dest='basePath', type=str, default=None, help='base path')
    parser.add_argument('-f', dest='function', type=str, default=None, help='the name of working function')
    parser.add_argument('-o', dest='outputName', type=str, default=None, help='')
    parser.add_argument('-p', dest='pattern', type=str, default=None, help='sub dir pattern')
    parser.add_argument('-e', dest='exceptions', type=str, default=None, help='except variables')
    parser.add_argument('-t', dest='targetName', type=str, default=None, help='target name')
    parser.add_argument('-q', dest='timeQuanta', type=float, default=None, help='time quanta of the system')
    parser.add_argument('-u', dest='nUpdates', type=str, default=None, help='number of updates in phase2')
    parser.add_argument('-z', dest='special', type=int, default=None, help='special point')

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
    print("Output Path  : %s" % args.outputName)

    obj = RoundTripColllector()
    getattr(obj, args.function)(args.basePath, args.outputName, args)

    print("Done.")
