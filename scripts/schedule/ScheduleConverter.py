import os
from tqdm import tqdm
from data.ResultFileLoader import ResultFileLoader


class ScheduleConverter(ResultFileLoader):
    formatOutput = 'draws/intermediate_%d_%d.csv'

    def __init__(self):
        super(ResultFileLoader, self).__init__()
        pass

    def convert(self, output, schedules, priorities):
        # output title
        lineTitle = "TaskID,ExecutionID,Type,Started,Finished,Priority,CPU\n"
        linePattern = "%d,%d,%s,%d,%d,%d,%d\n"
        output.write(lineTitle)

        # convert schedule data
        cnt = sum(len(item) for item in schedules)
        progress = tqdm(desc='converting schedules...', total=cnt, unit=' #', postfix=None)
        nTasks = len(schedules)
        for taskID in range(0,nTasks):

            nExecs = len(schedules[taskID])
            for execID in range(0,nExecs):
                schedule = schedules[taskID][execID]

                arrival  = schedule[0]
                deadline = schedule[1]
                finished = schedule[2]
                executes = schedule[5]
                arrivalType = "MissedArrival" if finished > deadline else "Arrival"

                output.write(linePattern % (taskID+1, execID+1, arrivalType, arrival, deadline, priorities[taskID], -1))

                # add executions
                for active in executes:
                    start = active[0]
                    end = active[1]
                    cpu = active[2] if len(active) > 2 else 0

                    if start>=deadline:
                        output.write(linePattern % (taskID+1, execID+1,  "Missed", start, end, priorities[taskID], cpu))

                    elif start<deadline:
                        if end <= deadline:
                            output.write(linePattern % (taskID+1, execID+1,  "Execution", start, end, priorities[taskID], cpu))
                        else:
                            output.write(linePattern % (taskID+1, execID+1,  "Execution", start, deadline, priorities[taskID], cpu))
                            output.write(linePattern % (taskID+1, execID+1,  "Missed", deadline, end, priorities[taskID], cpu))

                output.write(linePattern % (taskID+1, execID+1,  "Ended", finished, finished, priorities[taskID], -1))
                progress.update(1)
        output.close()
        progress.close()

    # def run(self, _filepath, _solutionID, _priorityIDX):
    #     #load data
    #     fpath = os.path.join(_filepath, '_schedules2/ext_sol%d_arr%d.json'%(_solutionID, _priorityIDX))
    #     schedules = self.load_schedules(fpath)
    #     fpath = os.path.join(_filepath, '_priorities2/ext_sol%d_arr%d.json'%(_solutionID, _priorityIDX))
    #     priorities = self.load_priorities(fpath)
    #     # schedules = self.load_schedules_param(_filepath, _solutionID, _priorityIDX)
    #     # priorities = self.load_priorities_param(_filepath, _solutionID, _priorityIDX)
    #
    #     # generate parent dir
    #     outputFile = os.path.join(_filepath, self.formatOutput%(_solutionID, _priorityIDX))
    #     parent = os.path.dirname(outputFile)
    #     if not os.path.exists(parent):
    #         os.makedirs(parent)
    #
    #     # write title
    #     output = open(outputFile, "w")
    #     self.convert(output, schedules, priorities)
    #     output.close()
    #     pass

    def run(self, _filepath, _solutionID, _sampleID):
        #load data
        fpath = os.path.join(_filepath, '_phase1/debug/sol%d_sample%d_schedules.json'%(_solutionID, _sampleID))
        schedules = self.load_schedules(fpath)

        fpath = os.path.join(_filepath, '_phase1/debug/sol%d_sample%d_priorities.json'%(_solutionID, _sampleID))
        priorities = self.load_priorities(fpath)

        # generate parent dir
        outputFile = os.path.join(_filepath, self.formatOutput%(_solutionID, _sampleID))
        parent = os.path.dirname(outputFile)
        if not os.path.exists(parent):
            os.makedirs(parent)

        # write title
        output = open(outputFile, "w")
        self.convert(output, schedules, priorities)
        output.close()
        pass


if __name__ == "__main__":
    # for solID in range(1, 10):
    ScheduleConverter().run('results/Test/ICS2', _solutionID=1, _sampleID=0)


