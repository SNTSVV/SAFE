import os
import re
import math
from tqdm import tqdm
from TaskDescriptor import TaskDescriptor
import utils


class ParallelColllector():
    def __init__(self):
        pass

    ##################################################
    # Collecting the execution time of test generation
    ##################################################
    def collect_logtime(self, _filename, _output, _header, _seqBase=0):
        # load target file
        if os.path.exists(_filename) is False:
            return None
        f = open(_filename)

        # write title if it needs
        title = f.readline()  # throw

        # write data
        while True:
            line = f.readline()
            if line == '' or line is None: break
            cols = line.split("\t")
            line = '%s, %d, %s\n'%(_header, int(cols[0].strip())+_seqBase, cols[3].strip())  # seqID, time
            _output.write(line)
        f.close()
        pass

    def collect_tg_execution(self, _dirpath,  _outputname, _args):
        # parameter passing
        _pattern = _args.pattern if _args.pattern is not None else r'(\d+)-TG_ESAIL_SAFE_T(\d)_parallel.log'
        # _pattern = _args.pattern if _args.pattern is not None else r'(\d+)-TG_ESAIL_SAFE_bf(\d)_parallel.log'
        _nParition = _args.Nums if _args.Nums is not None else 5

        # listing target directories
        files = utils.loadFiles([{'path':_dirpath}], _ptn=_pattern, _sort=True)

        # output
        output = open(_outputname, "w")
        output.write("JobID,PartitionID,seq,time\n")

        # progressing

        progress = tqdm(desc='Collecting data', total=len(files), unit=' #', postfix=None)
        prev = 0
        cnt = 0
        for item in files:
            if prev==int(item[1]):
                cnt += 1
            else:
                cnt = 0
                prev = int(item[1])

            try:
                header = '%d, %s' % (item['jobID'], item[1])
                self.collect_logtime(item['path'], output, header, cnt*10)
            except Exception as e:
                print('Filed to get information: run%02d' % int(item['Run']))
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

    obj = ParallelColllector()
    getattr(obj, args.function)(args.basePath, args.outputName, args)

    print("Done.")
