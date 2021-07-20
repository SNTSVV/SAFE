import codecs
import os
from csv import Dialect
from decimal import Decimal
from decimal import InvalidOperation


class DataFrameDecimal():
    headers = []
    dtypes = []
    values = []
    rows = 0
    cols = 0

    def __init__(self, headers, values, dtypes):
        self.headers = headers
        self.values = values
        self.dtypes = dtypes
        self.rows = len(values)
        self.cols = len(self.headers)
        if self.cols == 0:
            if isinstance(values[0], list):
                self.cols = len(values[0])
        pass

    def get(self, _idx=None, _name=None, _convert=True, _row=False):
        '''
        return values in this DataFrameDecimal.
        You can get a values by column or by row

        :param _idx: index number what you want to get, it starts from 0.
        :param _name: Column name that can be matched with headers
        :param _row: If this param is True, you can get a row values
        :return:
        '''
        idx = -1
        if _idx is not None:
            idx = _idx if _idx >= 0 else -1

        if _name is not None:
            for x in range(len(self.headers)):
                if self.headers[x] == _name:
                    idx = x
                    break
        if idx < 0: return None

        # extract column values from rows
        values = []
        if _row is False:
            for row in self.values:
                value = row[idx]
                if _convert is True:
                    value = self.dtypes[idx](value)
                values.append(value)
        else:
            for x in range(len(self.values[idx])):
                value = self.values[idx][x]
                if _convert is True:
                    value = self.dtypes[x](value)
                values.append(value)
        return values

    def __len__(self):
        return self.rows

    def __str__(self): return self.to_string()

    def head(self): print(self.to_string(10))

    def to_string(self, _reprLine=0):
        if _reprLine == 0:
            _reprLine = self.rows

        nDigits = 0
        rows = self.rows
        while (rows > 0):
            rows = rows//10
            nDigits += 1

        # make column lengths
        minimum = 10
        lengths = []
        for header in self.headers:
            lengths.append(len(header) if len(header) > minimum else minimum)

        # create headers
        text = ' '*(nDigits+2)
        for x in range(len(self.headers)):
            formattext = '  {:>%ds}' % lengths[x]
            text += formattext.format(self.headers[x])
        text += '\n'

        rowIDX = 0
        rowTxt = '[%' + '%d'% nDigits + 'd]'
        reprLines = self.values[:_reprLine] if _reprLine!=len(self.values) else self.values
        for row in reprLines:
            text += rowTxt%rowIDX

            for x in range(len(row)):
                formattext = '  {:>%ds}' % lengths[x]
                text += formattext.format(row[x])
            text += '\n'

            rowIDX += 1
        text += '--[{:,d} Columns x {:,d} Rows]--'.format(self.cols, self.rows)
        return text

    def __iter__(self):
        for items in self.values:
            yield [self.dtypes[x](items[x]) for x in range(len(items))]

    def __setslice__(self, i, j, sequence):
        values = []

        for items in self.values():
            values.append(items[i:j])
        headers = self.headers[i:j]
        dtypes = self.dtypes[i:j]

        return DataFrameDecimal(values, headers, dtypes)

    def __getitem__(self, i):
        values = []
        for items in self.values:
            values.append(items[i])
        return DataFrameDecimal(self.headers[i], values, self.dtypes[i])

#################
    # Data Load
    #################
    @staticmethod
    def from_csv(_filename, _header=-1, _shallow=True, _dialect=None):
        # set basic dialect
        dialect = _dialect
        if dialect is None:
            dialect = Dialect
            dialect.delimiter = ','
            dialect.lineterminator = '\n'
            dialect.quoting='\''

        # load raw data
        f = open(_filename, 'r')
        lines = f.readlines()
        f.close()

        # get header
        headers = []
        if _header>=0:
            headers = lines[_header].split(dialect.delimiter)
            headers = [header.strip() for header in headers]
            headers[0] = headers[0].strip('\ufeff')

        values = []
        max_cols = 0
        for line in lines[_header+1:]:
            cols = line.strip().split(dialect.delimiter)
            max_cols = len(cols) if max_cols<len(cols) else max_cols
            if len(cols)==1 and cols[0] == '': continue
            values.append(cols)

        if len(values) == 0:
            return DataFrameDecimal(headers, values, [str for x in range(len(headers))])

        if len(headers) != max_cols:
            raise Exception("No match data with header.")

        dtypes = []
        if _shallow is True:
            dtypes = DataFrameDecimal.__get_datatype(values)
        else:
            dtypes = DataFrameDecimal.__get_datatype_full(headers, values)

        return DataFrameDecimal(headers, values, dtypes)

    @staticmethod
    def __get_datatype_full(_headers, _values):
        dtypes = []
        for cIdx in range(len(_headers)):
            dtype = None
            for row in _values:
                if len(row) <= cIdx:
                    raise Exception("Not incorrect the number of column.")
                result = DataFrameDecimal.__find_datatype(row[cIdx])
                if result == str:
                    dtype = str
                    break

                if dtype == Decimal and (result == float or result == int): continue
                if dtype == float and (result == int): continue
                dtype = result

            dtypes.append(dtype)
        return dtypes

    @staticmethod
    def __get_datatype(_values):
        dtypes = []
        for cIdx in range(len(_values[0])):
            dtype = DataFrameDecimal.__find_datatype(_values[0][cIdx])
            dtypes.append(dtype)
        return dtypes

    @staticmethod
    def __find_datatype(_value):
        dtype = None
        try:
            d = Decimal(_value)
            t = d.as_tuple()
            if t.exponent==0:
                dtype = int
            elif t.exponent=='F':
                dtype = Decimal
            elif len(t.digits)<=16 and t.exponent<300 and t.exponent>-300:
                dtype = float
            else:
                dtype = Decimal

        except InvalidOperation as e:
            dtype = str

        return dtype


if __name__ == "__main__":
    # df = DataFrameDecimal.from_csv('res/LS_data_20190111.csv', _header=0)
    # df = DataFrameDecimal.from_csv('results_s/20190114_Data0111_varyWCET20_newSeq/Task06/executions/run01.csv', _header=0, _shallow=True)
    #df = DataFrameDecimal.from_csv('results_s/20190114_Data0111_varyWCET20_newSeq/Task06/results/result_obj00_run01.csv', _header=0, _shallow=True)

    #    #
    df = DataFrameDecimal.from_csv('results_s/20190114_Data0111_varyWCET20_oldSeqNewPriority/Task06/deadlines/deadlines_run01.csv', _header=0, _shallow=True)
    print(df.dtypes)
    print(df)
    # print(df.get(2))
    # print(df.get(2, _row=True))
    df2 = df[1:3]
    print(df2)

    # print(df)
    # print(df.get(_name='Task Priority'))

