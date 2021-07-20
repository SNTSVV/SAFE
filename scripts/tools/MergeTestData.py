import os
from tqdm import tqdm
import utils


class MergeTestData():
    def __init__(self):
        pass

    ##################################################
    # Collecting functions for timeinfo
    ##################################################
    def load_data(self, _filepath):
        if os.path.exists(_filepath) is False:
            return None, None

        f = open(_filepath)
        lines = f.readlines()
        f.close()
        return lines[0], lines[1:]

    def merge_testdata(self, _dirpath, _args):
        _parts = _args.numParts

        targets = utils.expandDirs([{'path':_dirpath}], 'Run', _ptn=r'\d+', _sort=True)
        progress = tqdm(desc='Collecting data', total=len(targets), unit=' #', postfix=None)
        for item in targets:
            output = open(os.path.join(item['path'], "testdata.csv"), "w")
            for partID in range(1, _parts+1):
                datafile = os.path.join(item['path'], 'testdata_part%02d.csv'%partID)
                title, lines = self.load_data(datafile)
                if title is None:
                    print("Not found the file: "+ datafile)

                # data lines contain '\n'
                if partID==1:
                    output.write(title)
                for line in lines:
                    output.write(line)
            output.close()
            progress.update(1)
            progress.set_postfix_str(item['path'])
        progress.close()

    ##################################################
    # Collecting functions for timeinfo
    ##################################################
    def load_rt_data(self, _filepath):
        if os.path.exists(_filepath) is False:
            return None, None

        f = open(_filepath)
        lines = f.readlines()
        f.close()
        return lines[0], lines[1:]

    def merge_rt_data(self, _dirpath, _args):
        _nParts = _args.numParts
        _targetName = _args.targetName if _args.targetName is not None else '_roundtrip'
        _startNum = _args.startNum if _args.startNum is not None else 1
        _outputName = _args.outputName if _args.outputName is not None else 'result.csv'
        _selected = _args.selectedRuns

        selectedRuns = None
        if _selected is not None:
            selectedRuns = _selected.split(',')
            selectedRuns = [int(var) for var in selectedRuns]

        targets = utils.expandDirs([{'path':_dirpath}], 'Run', _ptn=r'\d+', _sort=True)
        progress = tqdm(desc='Collecting roundtrip data', total=len(targets), unit=' #', postfix=None)
        for item in targets:
            if selectedRuns is not None and int(item['Run']) not in selectedRuns:
                progress.update(1)
                progress.set_postfix_str(item['path'])
                continue

            numLines = 0
            outputname = os.path.join(item['path'], "%s/%s"%(_targetName,_outputName))
            output = open(outputname, "w")
            for partID in range(_startNum, _nParts+1):
                datafile = os.path.join(item['path'], '%s/result_part%02d.csv'%(_targetName, partID))
                title, lines = self.load_data(datafile)
                if title is None:
                    print("Not found the file: "+ datafile)

                # data lines contain '\n'
                if partID == _startNum:
                    output.write(title)
                for line in lines:
                    output.write(line)
                numLines += len(lines)
            output.close()

            if numLines<40000:
                print("Not enough number of results: "+outputname)

            progress.update(1)
            progress.set_postfix_str(item['path'])
        progress.close()


def parse_arg():
    import argparse
    import sys
    parser = argparse.ArgumentParser(description='Parameters')
    parser.add_argument('-b', dest='basePath', type=str, default=None, help='base path')
    parser.add_argument('-f', dest='function', type=str, default=None, help='function name')
    parser.add_argument('-p', dest='numParts', type=int, default=0, help='number of parts')
    parser.add_argument('-t', dest='targetName', type=str, default=None, help='target Folder')
    parser.add_argument('-o', dest='outputName', type=str, default=None, help='output filename')
    parser.add_argument('-s', dest='startNum', type=int, default=1, help='start number')
    parser.add_argument('-r', dest='selectedRuns', type=str, default=None, help='selected runs')



    # parameter parsing
    args = sys.argv[1:]  # remove executed file
    args = parser.parse_args(args=args)
    if args.basePath is None or len(args.basePath)==0:
        parser.print_help()
        exit(1)
    if args.function is None or len(args.function)==0:
        parser.print_help()
        exit(1)
    return args


if __name__ == "__main__":
    args = parse_arg()
    print("#################################")
    print("Work basepath: %s" % args.basePath)
    print("function Name: %s" % args.function)
    print("Num of parts : %d" % args.numParts)
    print("Target Name  : %s" % args.targetName)
    print("Output Name  : %s" % args.outputName)
    print("Start Num    : %d" % args.startNum)

    obj = MergeTestData()
    getattr(obj, args.function)(args.basePath, args)
    print("Done.")
