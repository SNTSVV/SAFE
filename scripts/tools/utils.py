import os
import re
from tqdm import tqdm


def expandDirs(_dirList, _findKey='', _ptn=None, _sort=False,_exceptionPtn=None):
    rex = None
    if _ptn is not None:
        rex = re.compile(_ptn)
    rexEx = None
    if _exceptionPtn is not None:
        rexEx = re.compile(_exceptionPtn)

    ret = []
    for dirItem in _dirList:
        data = []
        flist = os.listdir(dirItem['path'])
        for fname in flist:
            fullpath = os.path.join(dirItem['path'], fname)
            if os.path.isfile(fullpath): continue          # pass not a directory
            if fullpath.startswith(".") is True: continue  # pass hidden dir
            if rexEx is not None and rexEx.search(fname) != None: continue  # if the name is an exception

            if rex is not None:
                result = rex.search(fname)
                if result == None:
                    print("\tPattern ('%s') doesn't matach: %s"%(_ptn, fullpath))
                    continue
                fname = result.group(0)
            newItem = dirItem.copy()
            newItem[_findKey] = fname
            newItem['path'] = fullpath
            data.append(newItem)
        if _sort is True:
            def selectKey(_item):
                return _item[_findKey]
            data.sort(key=selectKey)
        ret += data
    return ret


def loadFiles(_dirList, _ptn=None, _sort=False, _exceptionPtn=None):
    rex = None
    if _ptn is not None:
        rex = re.compile(_ptn)
    rexEx = None
    if _exceptionPtn is not None:
        rexEx = re.compile(_exceptionPtn)

    data = []

    for item in _dirList:
        flist = os.listdir(item['path'])
        progress = tqdm(desc='Collecting files from %s'%item['path'], total=len(flist), unit=' #', postfix=None)
        for fname in flist:
            progress.update(1)
            fullpath = os.path.join(item['path'], fname)
            if not os.path.isfile(fullpath): continue          # pass not a file
            if fname.startswith(".") is True: continue  # pass hidden file
            if rexEx is not None and rexEx.search(fname) != None: continue  # if the name is an exception

            if rex is not None:
                result = rex.search(fname)
                if result is None:
                    # print("\tPattern ('%s') doesn't matach: %s"%(_ptn, fullpath))
                    continue
                matchedList = result.groups()
                newItem = {'path':fullpath, "jobID":int(matchedList[0])}
                for x in range(1, len(matchedList)):
                    newItem[x] = matchedList[x]
                data.append(newItem)
            else:
                data.append({'path':fullpath, "jobID":None})
            progress.set_postfix_str("cnt:%d"%len(data))
        progress.close()
    if _sort is True:
        def selectKey(_item):
            return _item['jobID']
        data.sort(key=selectKey)
    return data
