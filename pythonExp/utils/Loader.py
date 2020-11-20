"""
==============================
Plotting categorical variables
==============================

How to use categorical variables in Matplotlib.

Many times you want to create a plot that uses categorical variables
in Matplotlib. Matplotlib allows you to pass categorical variables directly to
many plotting functions, which we demonstrate below.
"""
import codecs
import os
from csv import Dialect
from decimal import Decimal
from decimal import InvalidOperation


class Loader():

    @staticmethod
    def load_csv_colbase(_filename, _types, _headline=True):
        f = codecs.open(_filename, 'r', 'utf-8')

        # read titles
        line = f.readline()
        titles = line.strip().split(',')
        if titles[-1] == "":
            del titles[-1]

        N_COLS = len(titles)
        data = [list() for y in range(N_COLS)]
        if _headline is False:
            f.seek(0)
            titles = []

        while True:
            line = f.readline().strip()
            if line is None or len(line)==0: break

            # seperate line
            cols = line.split(',')
            if cols[-1] == "":
                del cols[-1]
            if len(cols) != N_COLS: raise Exception('Not Completed File Format.')

            # convert the types
            for x in range(len(cols)):
                col_type = _types[x]
                data[x].append(col_type(cols[x]))

        return titles, data

    @staticmethod
    def load_csv_rowbase(_filename, _types, _headline=True):
        f = codecs.open(_filename, 'r', 'utf-8')

        # read titles
        line = f.readline()
        titles = line.strip().split(',')
        if titles[-1] == "":
            del titles[-1]

        N_COLS = len(titles)
        if _headline is False:
            f.seek(0)
            titles = []

        data = []
        while True:
            line = f.readline().strip()
            if line is None or len(line)==0: break

            # seperate line
            cols = line.split(',')
            if cols[-1] == "":
                del cols[-1]
            if len(cols) != N_COLS: raise Exception('Not Completed File Format.')

            # convert the types
            subdata = []
            for x in range(len(cols)):
                col_type = _types[x]
                subdata.append(col_type(cols[x]))
            data.append(subdata)
            #if len(data) > 5000: break

        return titles, data

    @staticmethod
    def load_csv(_filename, xtype, ytype):
        f = codecs.open(_filename, 'r', 'utf-8')

        line = f.readline()
        titles = line.strip().split(',')
        if titles[-1] == "":
            del titles[-1]
        xdata = []
        ydata = [list() for y in range(len(titles)-1)]

        while True:
            line = f.readline().strip()
            if line is None or len(line)==0: break

            cols = line.split(',')
            if cols[-1] == "":
                del cols[-1]

            xdata.append(xtype(cols[0]))
            for y in range(len(ydata)):
                ydata[y].append(ytype(cols[y+1]))

        return xdata, ydata

    @staticmethod
    def get_averages(data):
        if len(data) > 1:
            values = [0]*len(data[0])
            for items in data:
                for x in range(len(items)):
                    values[x] += items[x]

            for x in range(len(values)):
                values[x] = values[x] / len(data)
        else:
            values = data[0]

        return values

    @staticmethod
    def get_averages2(data):
        ''' data reduced from [[], [], [], [], []] to [x1, x2, x3, x4, x5] by averaging an array'''
        values = [Decimal()] * len(data)
        for y in range(len(data)):
            for x in range(len(data[y])):
                values[y] += Decimal(str(data[y][x]))
            values[y] = values[y] / len(data[y])

        basic_type = type(data[0][0])
        for y in range(len(values)):
            values[y] = basic_type(values[y])

        return values

    @staticmethod
    def get_mid2(data):
        ''' data reduced from [[], [], [], [], []] to [x1, x2, x3, x4, x5] by median an array'''
        values = []
        for y in range(len(data)):
            data[y].sort()
            array = data[y]

            size = len(array)
            mid = array[int(size/2)]
            if size%2==0:
                basic_type = type(array[int(size/2)])
                a = Decimal(str(array[int(size/2)]))
                b = Decimal(str(array[int(size/2)-1]))
                mid = basic_type( (a+b)/2)

            values.append(mid)
        return values


    @staticmethod
    def get_average_scala(data):
        ''' get average of an array'''
        avg = Decimal("0")
        for item in data:
            if isinstance(item, Decimal):
                avg += item
            else:
                avg += Decimal(str(item))
        avg = avg / len(data)
        return avg

    @staticmethod
    def get_variance_scala(data, avg):
        var = Decimal("0")
        for item in data:
            diff = item - avg
            var += (diff * diff)
        var = var/len(data)
        return var


    @staticmethod
    def get_median_scala(data):
        ''' get median of an array'''
        data.sort()
        size = len(data)
        mid = data[int(size/2)]
        if size%2==0:
            basic_type = type(data[int(size/2)])
            a = Decimal(str(data[int(size/2)]))
            b = Decimal(str(data[int(size/2)-1]))
            mid = basic_type( (a+b)/2)
        return mid

    @staticmethod
    def select(_titles, _data, _xColumns, _yColumns):

        # select columns
        xIdx = []
        yIdx = []
        for name in _xColumns:
            # find index in _titles
            flag = False
            for x in range(len(_titles)):
                if _titles[x] != name: continue
                xIdx.append(x)
                flag = True
            if flag is False:
                raise Exception('Not found `%s` in given titles'% name)

        for name in _yColumns:
            # find index in _titles
            flag = False
            for y in range(len(_titles)):
                if _titles[y] != name: continue
                yIdx.append(y)
                flag = True
            if flag is False:
                raise Exception('Not found `%s` in given titles'% name)

        # load data
        xData = []
        yData = []
        for x in xIdx:
            xData.append(_data[x])

        for y in yIdx:
            yData.append(_data[y])

        return xData, yData


class DecimalMath():


    @staticmethod
    def average(data):
        ''' get average of an array'''
        avg = Decimal("0")
        for item in data:
            if isinstance(item, Decimal):
                avg += item
            else:
                avg += Decimal(str(item))
        avg = avg / len(data)
        return avg

    @staticmethod
    def variance(data, avg):
        var = Decimal("0")
        for item in data:
            diff = item - avg
            var += (diff * diff)
        var = var/len(data)
        return var

    @staticmethod
    def median(data):
        ''' get median of an array'''
        data.sort()
        size = len(data)
        mid = data[int(size/2)]
        if size%2==0:
            basic_type = type(data[int(size/2)])
            a = Decimal(str(data[int(size/2)]))
            b = Decimal(str(data[int(size/2)-1]))
            mid = basic_type( (a+b)/2)
        return mid

    @staticmethod
    def get_averages(data):
        if len(data) > 1:
            values = [0]*len(data[0])
            for items in data:
                for x in range(len(items)):
                    values[x] += items[x]

            for x in range(len(values)):
                values[x] = values[x] / len(data)
        else:
            values = data[0]

        return values


    @staticmethod
    def averages(data):
        '''
        get averages of each array in data
        :param data: 2-demensional array [[], [], ..., []]
        :return: [avg(data[1]), avg(data[2]), ..., avg(data[n])]
        '''
        values = [0] * len(data)
        for y in range(len(data)):
            values[y] = DecimalMath.average(data[y])

        basic_type = type(data[0][0])
        for y in range(len(values)):
            values[y] = basic_type(values[y])

        return values

    @staticmethod
    def medians(data):
        '''
        get medians of each array in data
        :param data: 2-demensional array [[], [], ..., []]
        :return: [median(data[1]), median(data[2]), ..., median(data[n])]
        '''
        values = [0] * len(data)
        for y in range(len(data)):
            values[y] = DecimalMath.median(data[y])

        return values


if __name__ == "__main__":
    # LimitRuns = None
    #
    # titles, data = Loader.load_csv_colbase('../results/HPC_20181206_ArrivalOrigin/Task07/result_runs_obj00.csv',[int]+[float]*10, _headline=True)
    # print(titles)  # First row
    titles, data = Loader.load_csv_rowbase('../results/HPC_20181206_ArrivalOrigin/Task07/result_runs_obj00.csv',[str]+[float]*600, _headline=True)
    print(titles)  # first Row



