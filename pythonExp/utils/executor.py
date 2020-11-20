from datetime import datetime
import subprocess
import codecs
import os


class Executor():
    IDLogs = {}
    basePath = '.'
    dateStr = ''

    cloudType = "iris"
    execute_function = None
    log_base = 'logs'
    NOTICE_EMAIL = "jaekwon.lee@uni.lu"
    MAX_WORKHOURS = 48  # 2days

    def __init__(self, _basepath='.', cloud="iris", hours=None):
        self.IDLogs = {}
        self.basePath = _basepath
        self.dateStr = datetime.now().strftime("%Y%m%d")
        self.cloudType = cloud

        if self.cloudType.startswith("gaia"):
            self.execute_function = self.execute_oarsub
        elif self.cloudType.startswith("iris"):
            self.execute_function = self.execute_slurm
        elif self.cloudType.startswith("chaos"):
            self.execute_function = self.execute_oarsub
        else:
            self.execute_function = self.execute_oarsub

        if hours is not None:
            self.MAX_WORKHOURS = hours
        pass

    def clean(self):
        self.IDLogs = {}
        pass

    def create_stop_script(self, _id):
        fname = '%s/stop_%s.sh' % (self.basePath, _id)
        f = codecs.open(fname, 'w', encoding='utf-8')
        f.write('#!/bin/bash\n\n')

        for key in self.IDLogs.keys():
            if self.cloudType.startswith("iris"):
                f.write('scancel %s\n' % key)
            else:
                f.write('oardel %s\n' % key)

        f.close()

        os.chmod(fname, 0o755)
        print('If you want to stop executions, execute ' + fname)
        pass

    def create_remove_script(self,_id):
        fname = '%s/remove_%s.sh' % (self.basePath, _id)
        f = codecs.open(fname, 'w', encoding='utf-8')
        f.write('#!/bin/bash\n\n')

        for key in self.IDLogs.keys():
            f.write('rm -f ../%s\n' % self.IDLogs[key])
        #f.write('rm -rf ../results/%s\n' % _id)
        f.close()

        os.chmod(fname, 0o755)
        print('If you want to remove logs, execute ' + fname)
        pass

    def create_jobs(self, jobName, tasklist, jar, parameters, taskAppendix=None, runID=None):
        jobName = '%s_%s' %(self.dateStr, jobName)

        #executing all jobs
        for tid in tasklist:
            taskName = 'Full' if tid==0 else 'Task%02d%s'%(tid,'' if taskAppendix is None else taskAppendix)
            cmd = '%s/node.sh %s %s -t %d %s' % (self.basePath, jar, "%s/%s"%(jobName, taskName), tid, parameters)

            print('\nCMD: %s' % (cmd))
            # execute separate run
            if runID is not None:
                taskName += '_run%02d'%runID

            ID, logpath = self.execute_function(node=1, cpu=1, core=4, workhours=self.MAX_WORKHOURS, email=self.NOTICE_EMAIL,
                                                command=cmd, jobName=jobName, taskName=taskName)
            print('[%s] OK, log:%s' % (ID, logpath))

            self.IDLogs[ID] = logpath

    def create_job(self, jobName, jar, parameters, taskAppendix=None, runID=None, shfile='node.sh', memory="20G", option=None):
        # execute separate run
        logName = jobName
        if runID is not None:
            logName += '_run%02d'%runID

        jobName = '%s_%s' %(self.dateStr, jobName)

        #executing all jobs
        cmd = '%s/%s %s %s %s' % (self.basePath, shfile, jar, memory, parameters)

        print('\nCMD: %s' % (cmd))


        ID, logpath = self.execute_function(node=1, cpu=1, core=4, workhours=self.MAX_WORKHOURS,
                                            email=self.NOTICE_EMAIL,
                                            command=cmd, jobName=jobName, taskName=logName, option=option)
        print('[%s] OK, log:%s' % (ID, logpath))

        self.IDLogs[ID] = logpath

    def create_job_secondphase(self, targetPath, jar, parameters, jobName=None, taskName=None):
        cmd = '%s/node.sh %s %s %s' % (self.basePath, jar, targetPath, parameters)
        print('\nCMD: %s' % (cmd))

        jobName = '%s_%s' %(self.dateStr, jobName)

        ID, logpath = self.execute_function(node=1, cpu=1, core=4, workhours=self.MAX_WORKHOURS, email=self.NOTICE_EMAIL,
                                            command=cmd, jobName=jobName, taskName=taskName)
        print('[%s] OK, log:%s' % (ID, logpath))

        self.IDLogs[ID] = logpath
        pass

    def execute_oarsub(self, node, cpu, core, workhours, email, command, jobName=None, taskName=None, option=None):
        # log Name setting
        logpath = self.log_base if jobName is None else '%s/%s'%(self.log_base, jobName)
        if os.path.exists(logpath) is False:
            os.makedirs(logpath)
        logfile = '%s/%s_%s.out' % (logpath, '%jobid%', '' if taskName is None else taskName)

        # create command
        timestr = "%d:00:00"%workhours
        resource_txt = 'nodes=%d/cpu=%d/core=%d,walltime=%s' % (node, cpu, core, timestr)
        cmd = ['oarsub', '-n', jobName[9:], '-O', logfile, '-E', logfile, '-l', resource_txt, '--notify', '\"mail:%s\"'%email, "\""+command+"\""]
        cmd = ' '.join(cmd)

        # create jobs and execute
        p1 = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True, executable='/bin/bash')
        output = p1.communicate()[0]
        lines = output.decode('utf-8').split('\n')

        # check execution result
        jobID = None
        for line in lines:
            if line.startswith('OAR_JOB_ID='):
                jobID = line[11:]

        if jobID is None:
            print("cmd: "+str(cmd))
            print("output: "+str(output))
            raise Exception("Cannot execute node")

        idx = logfile.find('%jobid%')
        logfile = logfile[:idx] + jobID + logfile[idx+7:]

        return jobID, logfile

    def execute_slurm(self, node, cpu, core, workhours, email, command, jobName=None, taskName=None, option=None):

        # log Name setting
        logpath = self.log_base if jobName is None else '%s/%s'%(self.log_base, jobName)
        if os.path.exists(logpath) is False:
            os.makedirs(logpath)
        logfile = '%s/%s_%s.out' % (logpath, '%j', '' if taskName is None else taskName)

        # create command
        day = int(workhours / 24)
        hours = workhours % 24
        timestr = "%d-%02d:00:00"%(day,hours)
        cmd = ['sbatch', '-J', jobName[9:], '-o', logfile, '-e', logfile, '-N', str(node), '-n', str(cpu), '-S', str(core), '-t', timestr, '--mail-type=ALL --mail-user=%s'%email]
        if option is not None:
            cmd+=option
        cmd += command.split(' ')
        cmd = ' '.join(cmd)

        # create jobs and execute
        p1 = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True, executable='/bin/bash')
        output = p1.communicate()[0]
        lines = output.decode('utf-8').split('\n')

        jobID = None
        for line in lines:
            if line.startswith('Submitted batch job'):
                jobID = line[20:]

        if jobID is None:
            print("cmd: "+str(cmd))
            print("output: "+str(output))
            raise Exception("Cannot execute node")

        idx = logfile.find('%j')
        logfile = logfile[:idx] + jobID + logfile[idx+2:]

        return jobID, logfile

    def execute_slurm_multi(self,  nTasks, nCPUperTask, workhours, email, command, nNodes=0, nTasksPerNode=0, jobName=None, logfile="", option=None, dryRun=False):
        # create command
        day = int(workhours / 24)
        hours = workhours % 24
        timestr = "%d-%02d:00:00"%(day,hours)

        cmd = ['sbatch', '-J', jobName,
               '-n', str(nTasks),  # nTasks
               '--cpus-per-task=%d'%(nCPUperTask), '-t', timestr,
               '--partition=batch', '--qos=normal',
               '-o', logfile, '-e', logfile, '--mail-type=ALL --mail-user=%s'%email]
        if isinstance(nNodes, list):
            cmd.append('--nodes=%d-%d' %(nNodes[0], nNodes[1]))
        else:
            cmd.append('--nodes=%d' %(nNodes if nNodes!=0 else nTasks))

        if nTasksPerNode != 0:
            cmd.append('--ntasks-per-node=%d'%(nTasksPerNode))

        if option is not None:
            cmd += option
        print("Batch CMD: %s (cmd)" % (cmd))

        cmd += command.split(' ')
        cmd = ' '.join(cmd)

        # create jobs and execute
        p1 = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True, executable='/bin/bash')
        output = p1.communicate()[0]
        lines = output.decode('utf-8').split('\n')

        jobID = None
        for line in lines:
            if line.startswith('Submitted batch job'):
                jobID = line[20:]

        if jobID is None:
            print("cmd: "+str(cmd))
            print("output: "+str(output))
            raise Exception("Cannot execute node")

        idx = logfile.find('%j')
        logfile = logfile[:idx] + jobID + logfile[idx+2:]

        return jobID, logfile

    def create_parallel_job(self, jobName, jar, parameters, nTasks, nStart=0, nCPU=2, nNodes=0, nTasksPerNode=0, shfile='node_parallel.sh', memory="20G", option=None, dryRun=False):
        # log Name setting
        logpath = self.log_base if jobName is None else '%s/%s_%s_parallel'%(self.log_base, self.dateStr, jobName)
        if os.path.exists(logpath) is False:
            os.makedirs(logpath)
        logfile = '%s/%s.out' % (logpath, "%j_%x")

        #executing all jobs
        cmd = '%s/%s -l %s ' % (self.basePath, shfile, logfile)
        if dryRun is True:
            cmd += '-d '
        if nStart > 1:
            cmd += '-s %d ' % (nStart)
        cmd += 'java -Xms4G -Xmx%s -jar %s %s' % (memory, jar, parameters)

        print('\nCMD: %s' % (cmd))

        ID, logpath = self.execute_slurm_multi(nTasks=nTasks, nCPUperTask=nCPU,  workhours=self.MAX_WORKHOURS,
                                                nNodes=nNodes, nTasksPerNode=nTasksPerNode,
                                                email=self.NOTICE_EMAIL, command=cmd, jobName=jobName,
                                                logfile=logfile, option=option)
        print('[%s] OK, log:%s' % (ID, logpath))

        self.IDLogs[ID] = logpath
        pass