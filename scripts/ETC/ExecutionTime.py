############################################################################
# This code analyzes an average execution time of an experiment over multiple runs
# You just specify a log folder to be analyzed
#    Then this code finds sub folders and load the files
#    And it will finds a text that contains the time information
# This code should be executed in project main folder (Expr folder)
############################################################################
import os
import re
from datetime import datetime
from time import mktime

base_path = './logs/'

def find_timestamp(tpath):
    data = {}
    target = os.path.join(base_path, tpath)
    filelist = os.listdir(target)
    for fname in filelist:
        print(fname)
        idx = fname.find('_run')
        idx2 = idx+6 if fname[idx+5] >= '0' and fname[idx+5]<='9' else idx+5
        runID = int(fname[idx+4:idx2])

        fp = open(os.path.join(target, fname), 'r')
        ts = 0
        while True:
            line = fp.readline()
            if not line: break
            if len(line) < 54: continue
            if len(line) > 63: continue

            idx = line.find("Total execution", 25)
            if idx<0: continue
            idx2 = line.find("ms", 40)

            ts = int(line[idx+21:idx2])
        fp.close()

        if ts==0:
            print(': Error to find ts')

        data[runID] = {"Run":runID, "timestamp":ts}
        print(': %dms'%ts)

    return data


def getTS(timeStr):
    k = datetime.strptime(timeStr, "%Y-%m-%d %H:%M:%S")
    return mktime(k.timetuple())

def get_timeinfo(filepath):
    dtPattern = re.compile('\[[0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+:[0-9]+\]')

    fp = open(filepath, 'r')
    start_ts = 0
    endText = ""
    while True:
        line = fp.readline()
        if not line: break
        if line.strip()=="": continue
        if len(line) < 22: continue
        if start_ts == 0:
            r = dtPattern.match(line)
            if r is None: continue
            start_ts = getTS(r.group(0)[1:-1])
        else:
            endText = line

    if endText == "": raise Exception("error to find end ts")
    r = dtPattern.match(endText)
    if r is None: raise Exception("error to find end ts")
    end_ts = getTS(r.group(0)[1:-1])

    return end_ts - start_ts

def run(tpath):
    target = os.path.join(base_path, tpath)
    filelist = os.listdir(target)

    sumTS = 0
    count = 0
    for fname in filelist:
        if fname.endswith(".out") is False: continue
        if fname.rfind("out", 0, len(fname)-4) <0: continue
        print("%s: "%(fname), end="")    # python2 compatable
        diff = get_timeinfo(os.path.join(target, fname))
        print("%d (%dh)"%(diff, diff/3600))
        sumTS += diff
        count += 1
    avgTS = sumTS/float(count)
    print("Average all: %d (%.2f h)"%(avgTS, avgTS/3600))



run('20201026_LSDATA_SCM6_COEVOL_parallel')
run('20201026_LSDATA_SCM6_RS_parallel')
run('20201026_LSDATA_SCM6_NSGA_parallel')
#
# GAdata = find_timestamp(workname + '_GASearch')
# RSdata = find_timestamp(workname + '_RandomSearch')
#
# # printing results
# print('\n\n\tExecutionTime')
# print('RunID\tGA\tRS')
# for key, value in GAdata.items():
#     print('%d\t%d\t%d'%(key, value['timestamp'], RSdata[key]['timestamp']))

#
# def find_timestamp_RQ2(tpath, isDist=True):
#     data = {}
#     target = os.path.join(base_path, tpath)
#     filelist = os.listdir(target)
#     for fname in filelist:
#         print(fname)
#         idx = fname.find('_run')
#         idx2 = idx+6 if fname[idx+5] >= '0' and fname[idx+5]<='9' else idx+5
#         runID = int(fname[idx+4:idx2])
#
#         if (fname[idx-8:idx].startswith('distance') is not isDist):
#             continue
#
#         fp = open(os.path.join(target, fname), 'r')
#         ts = 0
#         while True:
#             line = fp.readline()
#             if not line: break
#             if len(line) < 54: continue
#             if len(line) > 63: continue
#
#             idx = line.find("Total execution", 25)
#             if idx<0: continue
#             idx2 = line.find("ms", 40)
#
#             ts = int(line[idx+21:idx2])
#         fp.close()
#
#         if ts==0:
#             print(': Error to find ts')
#
#         data[runID] = {"Run":runID, "timestamp":ts}
#         print(': %dms'%ts)
#
#     return data
#
#
# Ddata = find_timestamp_RQ2(workname, isDist=True)
# Rdata = find_timestamp_RQ2(workname, isDist=False)
#
# # printing results
# print('\n\n\tExecutionTime')
# print('RunID\tGA\tRS')
# for key, value in Ddata.items():
#     print('%d\t%d\t%d'%(key, value['timestamp'], Rdata[key]['timestamp']))
