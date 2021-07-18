import os
import utils


class Colllector():
    def __init__(self):
        pass

    ##################################################
    # Collecting functions for timeinfo
    ##################################################
    def load_testdata(self, _filepath):
        if os.path.exists(_filepath) is False:
            return None

        positive = 0
        negative = 0
        f = open(_filepath)
        lines = f.readlines()
        f.close()

        for line in lines:
            if line[0]== "0": positive += 1
            if line[0]== "1": negative += 1
        return {"positive": positive, "negative":negative}

    def check_testdata(self, _dirpath, _args):
        _pattern = _args.pattern if _args.pattern is not None else r'\d+'
        _targetName = _args.targetName if _args.targetName is not None else r'testdata.csv'

        targets = utils.expandDirs([{'path':_dirpath}], 'Run', _ptn=_pattern, _sort=True)
        for item in targets:
            ret = self.load_testdata(os.path.join(item['path'], _targetName))
            if ret is None:
                print('%s Run %02d: Not found the test data'%(_dirpath, int(item['Run'])))
            else:
                sumNum = ret['positive'] + ret['negative']
                print("%s Run %02d: %d testdata (positive: %d, negative: %d)"%(_dirpath, int(item['Run']), sumNum, ret['positive'], ret['negative']))

    ##################################################
    # Collecting functions for timeinfo
    ##################################################
    def load_rtdata(self, _filepath):
        if os.path.exists(_filepath) is False:
            return None

        f = open(_filepath)
        lines = f.readlines()
        f.close()
        if (lines[0].startswith('WID')==False):
            return {'title': False, 'count':len(lines), 'ratio':0}

        ratio = 0.0
        for line in lines[1:]:
            cols = line.split(",")
            nDM = int(cols[2])
            if (nDM>0):
                ratio += 1
        ratio = ratio/(len(lines)-1)
        return {'title': True, 'count':len(lines)-1, 'ratio':ratio}

    def check_roundtrip(self, _dirpath, _args):
        _pattern = _args.pattern if _args.pattern is not None else r'\d+'
        _targetName = _args.targetName if _args.targetName is not None else r'_roundtrip/result.csv'

        targets = utils.expandDirs([{'path':_dirpath}], 'Run', _ptn=_pattern, _sort=True)
        for item in targets:
            ret = self.load_rtdata(os.path.join(item['path'], _targetName))
            if ret is None or ret['title'] is False:
                print('%s Run %02d: Not found the roundtrip result'%(_dirpath, int(item['Run'])))
            else:
                print("%s Run %02d: %d result (ratio: %.4f)"%(_dirpath, int(item['Run']), ret['count'], ret['ratio']))


def parse_arg():
    import argparse
    import sys
    parser = argparse.ArgumentParser(description='Paremeters')
    parser.add_argument('-b', dest='basePath', type=str, default=None, help='base path')
    parser.add_argument('-f', dest='function', type=str, default=None, help='the name of working function')
    parser.add_argument('-p', dest='pattern', type=str, default=None, help='sub dir pattern')
    parser.add_argument('-t', dest='targetName', type=str, default=None, help='sub dir pattern')

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
    print("Work function: %s" % args.function)
    print("Work basepath: %s" % args.basePath)

    obj = Colllector()
    getattr(obj, args.function)(args.basePath, args)

    print("Done.")
