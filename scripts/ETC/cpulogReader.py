import os
from utils.data import DataFrameDecimal

def convertCPULOG(targetName):
    basePath = 'results/%s/testcases' % targetName
    targetPath = 'results/%s/converted' % targetName
    if os.path.exists(targetPath) is False:
        os.makedirs(targetPath)

    for testID in range(0,1000):
        print('Working with %d ..' % testID)

        res = open("%s/converted_%d.csv"%(targetPath,testID), "w")
        res.write('Time,TaskID,Started,Restarted,Finished,Missed\n')

        data = []
        f = open("%s/cpulog_%d.log"%(basePath, testID))
        while True:
            line = f.readline()
            if line== "": break

            if line.startswith("CPU") is False:
                if (line[0]==' ' or line[0]=='+' or line[0]=='*') and (line[1]>='0' and line[1] <= '9') and (line[2]>='0' and line[2] <= '9'):
                    details = ' '+ line
                else:
                    continue
            else:
                ts = int(line[4:14])
                details = line[16:]

            x=0
            while x < len(details):
                item = details[x:(x+5)]
                if len(item)<5: break

                if item.startswith(' Dead') is True:
                    break

                state = item[1]
                task = int(item[2:4])
                result = item[4]

                started = True if state == "+" else False
                restarted = True if state == "*" else False
                finished = True if result == "/" else False
                missed = True if result == '!' or result == 'x' else False

                msg = '%d,%d,%d,%d,%d,%d\n'%(ts, task, started, restarted, finished, missed)
                res.write(msg)

                ts += 1
                x+=5
            ######
        f.close()
        res.close()


if __name__ == '__main__':
    convertCPULOG('TimelineLX2')


