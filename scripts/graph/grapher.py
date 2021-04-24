"""
"""
import os
from decimal import Decimal
from utils.data import DataFrameDecimal


class Graph():
    basepath = ''
    target_base = '_charts'
    targetpath = ''
    global_appendix = ''

    def __init__(self, _basepath, appendix=''):
        self.basepath = os.path.abspath(_basepath)
        self.targetpath = os.path.join(self.basepath, self.target_base)
        self.global_appendix = appendix

        print('\nWorking %s...'%self.basepath)
        pass

    ################################################
    # Private functions
    ################################################
    def _loop_task(self, _path):
        '''
        looping folder in specific path
        It expects Task and Task number (e.g. Task01, Task10, ...)
        :param _path:
        :return:
        '''
        base = os.path.abspath(_path)
        dirs = os.listdir(base)
        dirs.sort()

        for taskDir in dirs:
            path = os.path.join(base, taskDir)
            if os.path.isfile(path) is True: continue
            if taskDir.startswith('_') is True: continue  # for example, _charts, _charts2, ...
            yield path, taskDir, int(taskDir[4:])
        return True

    def _loop_subpath(self, _path):
        '''
        looping folder in specific path
        It expects Task and Task number (e.g. Task01, Task10, ...)
        :param _path:
        :return:
        '''
        base = os.path.abspath(_path)
        dirs = os.listdir(base)
        dirs.sort()

        for taskDir in dirs:
            path = os.path.join(base, taskDir)
            if os.path.isfile(path) is True: continue
            if taskDir.startswith('_') is True: continue  # for example, _charts, _charts2, ...
            yield path, taskDir
        return True

    def _loop_runfile(self, _path, _objective, _limits=None):
        '''
        looping filename in specific path
        :param _path:
        :param _objective:
        :param _limits:
        :return:
        '''
        objpath = os.path.join(_path, _objective)
        files = os.listdir(objpath)
        files.sort()
        if _limits is not None:
            files = files[:_limits]

        # load values and make average
        idx = 0
        for file in files:
            idx += 1
            yield os.path.join(objpath, file), idx
        return

    def _loop_solutionfiles(self, _path, _objective, _limits=None):
        '''
        looping filename in specific path
        :param _path:
        :param _objective:
        :param _limits:
        :return:
        '''
        objpath = os.path.join(_path, _objective)
        files = os.listdir(objpath)
        files.sort()
        if _limits is not None:
            files = files[:_limits]

        # load values and make average
        for file in files:
            yield file, int(file[:-4])
        return

    def _get_min_runs(self, _path, _limits=None):
        '''
        looping filename in specific path
        :param _path:
        :param _objective:
        :param _limits:
        :return:
        '''

        min_cnt = 1000000
        for path, taskDir, taskID in self._loop_task(_path):
            objpath = os.path.join(path, 'results')
            files = os.listdir(objpath)
            cnt = len(files)
            if min_cnt > cnt: min_cnt = cnt

        if _limits is not None and _limits < min_cnt:
            return _limits
        return min_cnt

    def _get_max_runs(self, _path):
        '''
        looping filename in specific path
        :param _path:
        :param _objective:
        :param _limits:
        :return:
        '''

        max_cnt = 0
        for path, taskDir, taskID in self._loop_task(_path):
            objpath = os.path.join(path, 'results')
            files = os.listdir(objpath)
            cnt = len(files)
            if max_cnt < cnt: max_cnt = cnt

        return max_cnt

    def _get_proper_runs(self, _path, _taskID):
        '''
        looping filename in specific path
        :param _path:
        :param _objective:
        :param _limits:
        :return:
        '''

        runs = 0
        for path, taskDir, taskID in self._loop_task(_path):
            if taskID != _taskID: continue
            objpath = os.path.join(path, 'results')
            files = os.listdir(objpath)
            runs = len(files)
            break

        return runs

    def _prepare_path(self, _path):
        if os.path.exists(_path) is False:
            os.makedirs(_path)
        return _path

    def _reduce_values(self, values, _multiflier):
        exp = _multiflier.adjusted()
        base = _multiflier.as_tuple().digits
        base = str(base[0]) + '.' + ''.join(str(x) for x in base[1:])

        # test value
        test_exp = values[0].adjusted()

        # reduce values
        multifly = 0
        if test_exp < 0:
            while (values[0] != 0 and values[0] <= Decimal("%se%d" % (base, exp*-1))):
                multifly -= 1
                for x in range(len(values)):
                    values[x] = values[x] * Decimal("%se%d" % (base, exp))
        else:
            d = values[0].as_tuple()
            multifly = 0
            diff = 0
            for x in range(len(values)):
                d = values[x].as_tuple()
                diff_temp = d.exponent - (d.exponent%exp)
                if diff_temp > diff:
                    diff = diff_temp
                    multifly = int(d.exponent / exp)

            for x in range(len(values)):
                d = values[x].as_tuple()
                digits = str(d.digits[0]) + '.' + ''.join(str(x) for x in d.digits[1:])
                exponent = d.exponent-diff
                values[x] = Decimal('%s%se%d'%('-' if d.sign == 1 else '', digits, exponent if exponent>=0 else 0))

        multifiled = None
        if multifly != 0:
            multifiled = Decimal("%se%d" % (base, exp * multifly))
        return values, multifiled

    def _reduce_group_values(self, values, _multiflier):
        exp = _multiflier.adjusted()
        base = _multiflier.as_tuple().digits
        base = str(base[0]) + '.' + ''.join(str(x) for x in base[1:])

        multifly = 0
        while (values[0][0] != 0 and values[0][0] <= Decimal("%se%d" % (base, exp * -1))):
            multifly += 1
            for y in range(len(values)):
                for x in range(len(values[y])):
                    values[y][x] = values[y][x] * Decimal("%se%d" % (base, exp))

        multifiled = None
        if multifly >= 1:
            multifiled = Decimal("%se%d" % (base, exp * multifly))
        return values, multifiled

    def _make_title(self, _title):
        title = _title
        title += (' / %s' % self.global_appendix if len(self.global_appendix) >= 0 else '')
        return title

    def _load_input_used(self, _taskPath):
        filename = os.path.join(_taskPath, 'input.csv')

        df = DataFrameDecimal.from_csv(filename, _header=0)
        titles = df.get(_name='Task Name')

        info = {}
        for x in range(len(titles)):
            info[x+1] = 'T%d: %s'%(x+1, titles[x])
        return info


if __name__ == "__main__":
    LimitRuns = None

    targets = {}
    # targets['ArrivalOrigin'] = '../results_s/HPC_20181212_ArrivalOrigin'
    # targets['ArrivalWCETPeriodic35'] = '../results_s/HPC_20181212_ArrivalWCETPeriodic35'
    # targets['ArrivalWCETPeriodic40'] = '../results_s/HPC_20181212_ArrivalWCETPeriodic40'
    # targets['ArrivalWCETPeriodic45'] = '../results_s/HPC_20181212_ArrivalWCETPeriodic45'
    # targets['ArrivalWCETAperiodic60'] = '../results_s/HPC_20181213_ArrivalWCETAperiodic60'
    # targets['ArrivalWCETAperiodic70'] = '../results_s/HPC_20181213_ArrivalWCETAperiodic70'
    # targets['ArrivalWCETPeriodic50'] = '../results_s/HPC_20181213_ArrivalWCETPeriodic50'
    # targets['ArrivalWCETPeriodic55'] = '../results_s/HPC_20181213_ArrivalWCETPeriodic55'
    targets['VaryWCET'] = '../results_s/HPC_20181218_varyWCET'
