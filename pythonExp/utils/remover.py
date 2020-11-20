import os
import re
import shutil

def remove(basepath='', pattern=''):
    '''
    2019.05.08 Test for new fitness. I updated fitness function to use nomalization
    This test for sampling costs
    :return:
    '''

    dirs = os.listdir(basepath)

    for dir in dirs:
        newpath=os.path.join(basepath, dir)
        result = re.findall(pattern, dir)
        if len(result)>0:
            shutil.rmtree(newpath,True)
            print('Removed:%s'%newpath)
            continue

        if os.path.isdir(newpath) is True:
            remove(newpath, pattern)

    pass


if __name__ == "__main__":

    remove(basepath='./results/parameters/', pattern='minimums')