

class TaskDescriptor():
    ID = 0
    Name = ""
    Type = ""
    Priority = ""
    Offset = 0
    WCETmin = 0
    WCETmax = 0
    Period = 0
    IAmin = 0
    IAmax = 0
    Deadline = 0
    DeadlineType = ""
    Dependencies = []
    Triggers = []

    def convert(self, _str):
        _str = _str.strip()
        if len(_str) > 0:
            if _str in ["NaN", "NULL", "NA", "N/A"]: return -1
            return int(_str )
        return 0

    def convertTime(self, _str, _tq):
        _str = _str.strip()
        if len(_str) > 0:
            if _str in ["NaN", "NULL", "NA", "N/A"]: return -1
            return int(float(_str )*(1/_tq))
        return 0

    def convertList(self, _str):
        _str = _str.strip()
        if (len(_str)>0):
            resources = _str.split(";")
            return [int(r) for r in resources]
        return []

    def __init__(self, _line, _tq):
        items = _line.split(",")
        self.ID = self.convert(items[0])
        self.Name = items[1].strip("\"")
        self.Type = items[2].strip()
        self.Priority   = self.convert(items[3])
        self.Offset     = self.convertTime(items[4], _tq)
        self.WCETmin    = self.convertTime(items[5], _tq)
        self.WCETmax    = self.convertTime(items[6], _tq)
        self.Period     = self.convertTime(items[7], _tq)
        self.IAmin      = self.convertTime(items[8], _tq)
        self.IAmax      = self.convertTime(items[9], _tq)
        self.Deadline   = self.convertTime(items[10], _tq)
        self.DeadlineType   = items[11].strip()
        if len(items)>12:
            self.Dependencies = self.convertList(items[12])
        if len(items)>13:
            self.Triggers = self.convertList(items[13])
        pass

    @staticmethod
    def load_fromFile(_filepath, _tq):
        f = open(_filepath)
        lines = f.readlines()
        f.close()

        info = []
        for line in lines[1:]:
            line = line.strip()
            if len(line)==0: break
            task = TaskDescriptor(line, _tq)
            info.append(task)
        return info

    @staticmethod
    def getUncertainTasks(_taskInfo):
        tasks = []
        for task in _taskInfo:
            if (task.WCETmax - task.WCETmin)==0: continue
            tasks.append(task.ID)
        return tasks
