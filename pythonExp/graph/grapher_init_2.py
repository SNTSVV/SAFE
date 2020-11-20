"""
"""
import codecs
import os
from decimal import Decimal
from utils.Loader import Loader
from graph.drawer import Drawer
from utils import common
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
			yield path, taskDir, taskDir
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
			taskID = 34
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
			while (values[0] != 0 and values[0] >= Decimal("%se%d" % (base, exp))):
				multifly += 1
				for x in range(len(values)):
					values[x] = values[x] * Decimal("%se%d" % (base, exp*-1))

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


class InitialGraph(Graph):
	basepath = ''
	target_base = '_charts'
	targetpath = ''
	global_appendix = ''

	def __init__(self, _basepath, appendix=''):
		super().__init__(_basepath, appendix)
		pass

	###################################################
	# Fitness behaviors
	###################################################
	def summary_fitness_graph(self, _applyRun=None):
		'''
		Draw summary graph from fitness
		:param _applyRun:
		:return:
		'''
		# Graph settings
		pre_title = 'Fitness Behaviors'
		xCaption = 'Iteration'
		yCaption = 'Fitness value'
		width = 1200
		height = 800

		# refine parameters and define variables
		min_runs = 100
		iters = []
		multi_titles = []
		multi_values = []
		multi_yTitles = []

		# draw fitness graph for each F(task X)
		for taskID, xTitle, yTitle, xValues, yValues, runs in self.make_fitness_graph(_applyRun):
			iters = xValues
			multi_titles.append('%s (%druns)' % (common.TASK_INFO[taskID], runs))
			multi_values.append(yValues)
			multi_yTitles.append(yTitle)
			if min_runs>runs: min_runs = runs

		if len(multi_values) <= 0: return 0

		# Draw summary
		print('\tSummay....', end='')
		supertitle = self._make_title(pre_title)
		filename = os.path.join(self.targetpath, 'Summary_fitness.png')
		Drawer().multi_data_graph(iters, multi_values, supertitle, multi_titles, xCaption, multi_yTitles, width, height, filename)
		print('Done.')
		return min_runs

	def load_fitness_data(self, taskID, path, _applyRun=None):
		filename = os.path.join(path, 'result_runs_obj00.csv')
		if os.path.exists(filename) is False:
			raise Exception('Not exists result_runs_obj00.csv in Task%2d'%taskID)

		# load data
		iters, values = Loader.load_csv(filename, int, Decimal)
		if _applyRun is not None:
			values = values[:_applyRun]

		# organize data
		runs = len(values)
		values = Loader.get_averages(values)
		values, multiflied = self._reduce_values(values, _multiflier=Decimal("1.0E+300"))

		return iters, values, runs, multiflied

	def make_fitness_graph(self, _applyRun=None):
		'''
		:param _basepath:
		:param _targetpath:
		:param _applyRun:
		:return:
		'''
		# Graph settings
		pre_title = 'Fitness values'
		xCaption = 'Iteration'
		yCaption = 'Fitness value'
		width = 1200
		height = 800

		# refine parameters and define variables
		objective = 'fitness'
		save_path = self._prepare_path(os.path.join(self.targetpath, objective))

		print('\tDrawring ' + objective + ' ... Task', end='')
		for path, taskDir, taskID in self._loop_task(self.basepath):
			taskID = 34
			print('%s(%d)'%(taskDir,taskID), end='')
			common.TASK_INFO = self._load_input_used(path)
			if taskDir.startswith('0') is False:
				continue
			iters, values, runs, multiflied = self.load_fitness_data(taskID, path, _applyRun)

			# Draw graph
			title 		= '%s %s %s / %s' % (common.TASK_INFO[taskID], pre_title, '(%d runs)' % (runs), self.global_appendix)
			outputpath 	= os.path.join(save_path, taskDir + '_fitness.png')
			ytitle 		= yCaption + (' (*%s)'% str(multiflied) if multiflied is not None else "")
			Drawer().single_graph(iters, values, title, xCaption, ytitle, width, height, outputpath)

			if (taskDir != 'Full'):
				yield taskID, xCaption, ytitle, iters, values, runs
			print(', ', end='')
		print('Done.')
		return

	###################################################
	# Best(e-d) behaviors
	###################################################
	def summary_bestMissed(self, _applyRun=None, _nTasks=35):
		# Graph settings
		pre_title = 'Best(e-d) Behaviors'
		xCaption = 'Iteration'
		yCaption = 'Time Quanta'
		width = 1200
		height = 800

		objective = 'minimums'
		min_runs = 0
		iters = []
		multi_titles = []
		multi_values = []

		# draw fitness graph for each F(task X)
		for taskID, xTitle, yTitle, xValues, yValues, runs in self.make_bestMissed(_applyRun, _nTasks):
			# if taskID == 34: continue
			iters = xValues
			multi_titles.append('%s (%druns)' % (common.TASK_INFO[taskID], runs))
			multi_values.append(yValues)
			if min_runs>runs: min_runs = runs

		if len(multi_values) <= 0: return 0

		# process for summary
		print('\tSummay ...', end='')
		supertitle 	= self._make_title(pre_title)
		filename 	= os.path.join(self.targetpath, 'Summary_%s.png' % (objective))
		Drawer().multi_data_graph(iters, multi_values, supertitle, multi_titles, xCaption, yCaption, width, height,filename, stress=True)
		print(' Done.')
		pass

	def make_bestMissed(self, _applyRun=None, _nTasks=35):
		'''
		produce graphs only related task's best(e-d)
		:param _applyRun:
		:param _nTasks:
		:return:
		'''
		# Graph settings
		pre_title = 'Best(e-d) Behaviors'
		xCaption = 'Iteration'
		yCaption = 'Time Quanta'
		width = 1200
		height = 800
		objective = 'minimums'

		# make path to save graph
		save_path = self._prepare_path(os.path.join(self.targetpath, objective))

		# work for each task
		print('\tDrawring Best(e-d)... Task', end='')
		for path, taskDir, taskID in self._loop_task(self.basepath):
			taskID = 34
			print('%d'%taskID, end='')
			common.TASK_INFO = self._load_input_used(path)

			xValues, yValues, runs = self.load_bestMissed_data(taskID, path, objective, _nTasks,_applyRun)

			# Draw graph
			title = self._make_title(pre_title+' (%druns)' % runs)
			filename = os.path.join(save_path, '%s_best(e-d).png' % (taskDir))
			Drawer().single_graph(xValues, yValues, title, xCaption, yCaption, width, height,filename, stress=True)

			yield taskID, xCaption, yCaption, xValues, yValues, runs
			print(', ', end='')
		print('Done.')
		return

	def make_bestMissed_vary(self, _applyRun=None, _nTasks=35):
		'''
		produce graphs only related task's best(e-d)
		:param _applyRun:
		:param _nTasks:
		:return:
		'''
		# Graph settings
		pre_title = 'Best(e-d) Behaviors'
		xCaption = 'Iteration'
		yCaption = 'Time Quanta'
		width = 1200
		height = 800
		objective = 'minimums'

		# make path to save graph
		save_path = self._prepare_path(os.path.join(self.targetpath, objective))

		# work for each task
		print('\tDrawring Best(e-d) ...', end='')
		for path, taskDir, taskID in self._loop_task(self.basepath):
			print('Task%d'%taskID, end='')
			TASK_INFO = self._load_input_used(path)

			xValues, yValues, runs = self.load_bestMissed_data(taskID, path, objective, _nTasks)

			# Draw graph
			title = self._make_title(pre_title+' (%druns)' % runs)
			filename = os.path.join(save_path, '%s_best(e-d).png' % (taskDir))
			Drawer().single_graph(xValues, yValues, title, xCaption, yCaption, width, height,filename, stress=True)

			yield taskID, xCaption, yCaption, xValues, yValues, runs
			print(', ', end='')
		print('Done.')
		return

	def load_bestMissed_data(self, taskID, path, objective, _nTasks, _applyRun,_onlyRelatedTask=True):
		# load files and make a average values
		iters=[]
		minimums= [] if _onlyRelatedTask is True else [list() for x in range(_nTasks)]

		properRuns = self._get_proper_runs(self.basepath, taskID)
		for filepath, fileIDX in self._loop_runfile(path, objective, properRuns):

			# load values and make average
			titles, data = Loader.load_csv_colbase(filepath, [int]+[float]*_nTasks, _headline=True)
			iters = data[0]
			if _onlyRelatedTask is True:
				minimums.append(data[taskID]) # select specific task information
			else:
				for x in range(1, len(data)):
					minimums[x-1].append(data[x])

		if _onlyRelatedTask is True:
			runs = len(minimums)
			runs = runs if _applyRun > runs else _applyRun
			minimums = Loader.get_averages(minimums[:runs])
		else:
			runs = len(minimums[0])
			runs = runs if _applyRun > runs else _applyRun
			for x in range(len(minimums)):
				minimums[x] = Loader.get_averages(minimums[x][:runs])

		return iters, minimums, runs

	def make_bestMissed_detail(self, _applyRun=None, _nTasks=35):
		'''
		produce graphs all tasks's best(e-d) behaviors for all executed F(Tx)
		:param _applyRun:
		:param _nTasks:
		:return:
		'''
		# Graph settings
		pre_title = 'Best(e-d) Behaviors for all tasks'
		xCaption = 'Iteration'
		yCaption = 'Time Quanta'
		width = 1200
		height = 800
		objective = 'minimums'

		# make path to save graph
		save_path = self._prepare_path(os.path.join(self.targetpath, objective+'_detail'))

		# work for each task
		print('\tDrawring Best(e-d) details...', end='')
		for path, taskDir, taskID in self._loop_task(self.basepath):
			print('Task%d'%taskID, end='')
			TASK_INFO = self._load_input_used(path)

			# load files and make a average values
			xValues, yValues, runs = self.load_bestMissed_data(taskID, path, objective, _nTasks, False)
			titles = ['%s'%(TASK_INFO[x+1]) for x in range(_nTasks)]

			#Detail graph
			supertitle = self._make_title(pre_title+ ' (%druns)'%(runs))
			filename = os.path.join(save_path, 'Detail_%s_best(e-d).png' % (taskDir))
			Drawer().multi_data_graph(xValues, yValues, supertitle, titles, xCaption, yCaption, width, height,filename, stress=True)

			print(', ', end='')
		print(' Done.')
		pass

	def make_maximum_targeted_eachrun(self, _nTasks=35):
		# Graph settings
		pre_title = 'Best(e-d) Behaviors for each Run'
		xCaption = 'Iteration'
		yCaption = 'Time Quanta'
		width = 1200
		height = 800
		objective = 'minimums'

		# make path to save graph
		save_path = self._prepare_path(os.path.join(self.targetpath, objective + '_eachrun'))

		# work for each task
		print('\tDrawring Best(e-d) for each Run...')
		for target_run in range(1, self._get_max_runs(self.basepath)+1):
			print('\t\tRun %d loading... Task' % target_run, end='')

			iters = []
			multi_titles = []
			minimums = []
			for path, taskDir, taskID in self._loop_task(self.basepath):
				print(str(taskID), end='')
				TASK_INFO = self._load_input_used(path)

				# load files and make a average values
				flag = False
				for filepath, runID in self._loop_runfile(path, objective):
					if runID != target_run: continue

					titles, data = Loader.load_csv_colbase(filepath, [int]+[float]*_nTasks, _headline=True)
					if len(iters) == 0: iters = data[0]
					if len(data[taskID]) == len(iters):
						multi_titles.append('%s (Run %d)' % (TASK_INFO[taskID], runID))
						minimums.append(data[taskID])      # select specific task information
						flag = True
					break

				print(', 'if flag is True else '!, ', end='')

			# process for summary
			if len(multi_titles) == 0: return False

			print('\tdrawing...', end='')
			if len(multi_titles) == 1:
				# Draw graph
				title = self._make_title(pre_title + ' (Run %d)'% target_run)
				filename = os.path.join(save_path, 'Task%d_minimum.png'%target_run)
				Drawer().single_graph(iters, minimums[0], title, xCaption, yCaption, width, height, filename, stress=True)
			else:
				supertitle = self._make_title(pre_title)
				filename = os.path.join(save_path, 'Summary_minimum_run%d.png' % (target_run))
				Drawer().multi_data_graph(iters, minimums, supertitle, multi_titles, xCaption, yCaption, width, height,filename, stress=True)
			print(' Done.')
		pass

	###################################################
	# Execution dots
	###################################################
	# This function create graphs that is including subplots for each Tasks.
	# The values loads from result files in `minimums` folder in each target folder.
	def make_execution_graph(self, _completedRuns=None):
		# Graph settings
		pre_title = 'Best(e-d) Distribution'
		xCaption = 'Iteration'
		yCaption = 'Execution number of best(e-d)'
		yCaptionCnt = 'Number of best(e-d) executions'
		width = 1200
		height = 800
		objective = 'executions'

		# parameters
		save_path = self._prepare_path(os.path.join(self.targetpath, objective))

		print('\tDrawing execution scatter:')
		for runID in range(1, self._get_min_runs(self.basepath, _completedRuns)+1):
			# set variables
			multi_xData = []
			multi_yData = []
			multi_titles = []

			print('\t\tRun%02d Task ' % (runID), end='')
			for path, taskDir, taskID in self._loop_task(self.basepath):
				print('%02d, ' % taskID, end='')
				TASK_INFO = self._load_input_used(path)

				targetFile = os.path.join(path, objective, 'run%02d.csv' % runID)
				titles, data = Loader.load_csv_colbase(targetFile, [int]*8, _headline=True)
				xData, yData = Loader.select(titles, data, ['Iteration'], ['ExecutionID'])

				title = self._make_title(pre_title + taskDir)
				filename = os.path.join(save_path, 'Run%02d_%s_execution.png' % (runID, taskDir))
				Drawer().scatter_graph(xData[0], yData[0], title, xCaption, yCaption, width, height, filename)

				multi_xData.append(xData[0])
				multi_yData.append(yData[0])
				multi_titles.append('%s (%s)'%(TASK_INFO[taskID], taskDir))

			print('\t\tSummay ....', end='')
			supertitle = self._make_title(pre_title)
			filename = os.path.join(self.targetpath, 'Summary_execution_run%02d.png' % (runID))
			Drawer().scatter_graph_multi(multi_xData, multi_yData, supertitle, multi_titles, xCaption, yCaptionCnt, width, height,filename)
			print('Done')
		pass

	def make_execution_counting_graph(self, _completedRuns=None):
		# Graph settings
		pre_title = 'The Count of Best(e-d)'
		xCaption = 'Iteration'
		yCaption = 'Number of best(e-d) executions'
		width = 1200
		height = 800
		objective = 'executions'

		# parameters
		save_path = self._prepare_path(os.path.join(self.targetpath, objective+'_count'))

		print('\tDrawing counting of executions...')
		for runID in range(1, self._get_min_runs(self.basepath, _completedRuns)+1):
			# set variables
			multi_xData = []
			multi_yData = []
			multi_titles = []

			print('\t\tRun%02d Task ' % (runID), end='')
			for path, taskDir, taskID in self._loop_task(self.basepath):
				print('%02d, ' % taskID, end='')
				TASK_INFO = self._load_input_used(path)

				targetFile = os.path.join(path, objective, 'run%02d.csv' % runID)
				titles, data = Loader.load_csv_colbase(targetFile, [int]*8, _headline=True)
				xData, yData = Loader.select(titles, data, ['Iteration'], ['ExecutionID'])

				iters = [num for num in range(1, 601, 1)]
				counts = [0]*600
				for x in range(len(xData[0])):
					counts[xData[0][x]-1] += 1

				title = self._make_title(pre_title + taskDir)
				filename = os.path.join(save_path, 'Run%02d_%s_counting_.png' % (runID, taskDir))
				Drawer().scatter_graph(iters, counts, title, xCaption, yCaption, width, height, filename)

				multi_xData.append(iters)
				multi_yData.append(counts)
				multi_titles.append('%s (%s)'%(TASK_INFO[taskID], taskDir))

			print('Summay ....', end='')
			supertitle = self._make_title(pre_title)
			filename = os.path.join(self.targetpath, 'Summary_counting_run%02d.png' % (runID))
			Drawer().scatter_graph_multi(multi_xData, multi_yData, supertitle, multi_titles, xCaption, yCaption, width, height, filename)
			print('Done')
		pass

	def check_deadlineMiss(self, _completedRuns=None):
		# Graph settings
		objective = 'deadlines'

		# make path to save graph
		save_path = self._prepare_path(os.path.join(self.targetpath))

		# work for each task
		count = 0
		print('\tChecking ' + objective + ' ...')
		for path, taskDir, taskID in self._loop_task(self.basepath):
			# load files and make a average values
			missed=[]
			for filepath, fileIDX in self._loop_runfile(path, objective, _completedRuns):
				# load values and make average
				titles, data = Loader.load_csv_rowbase(filepath, [int]*7, _headline=True)
				missed.append(len(data))
				if len(data) > 0:
					count += len(data)

			print('\t\tTask%02d Deadlines for each run %s'%(taskID, str(missed)))

		f = open(os.path.join(save_path, 'DeadlineMiss_%d'%count), 'w')
		f.close()
		return True

	def make_fitness_distribution(self, _completedRuns=None):
		# Graph settings
		pre_title = 'Fitness Distribution'
		xCaption = 'Iteration'
		yCaption = 'Execution number of best(e-d)'
		yCaptionCnt = 'Number of best(e-d) executions'
		width = 1200
		height = 800
		objective = 'executions'

		# parameters
		save_path = self._prepare_path(os.path.join(self.targetpath, objective))

		print('\tDrawing execution scatter:')
		for runID in range(1, self._get_min_runs(self.basepath, _completedRuns)+1):
			# set variables
			multi_xData = []
			multi_yData = []
			multi_titles = []

			print('\t\tRun%02d Task ' % (runID), end='')
			for path, taskDir, taskID in self._loop_task(self.basepath):
				print('%02d, ' % taskID, end='')
				TASK_INFO = self._load_input_used(path)

				targetFile = os.path.join(path, objective, 'run%02d.csv' % runID)
				titles, data = Loader.load_csv_colbase(targetFile, [int]*8, _headline=True)
				xData, yData = Loader.select(titles, data, ['Iteration'], ['ExecutionID'])

				title = self._make_title(pre_title + taskDir)
				filename = os.path.join(save_path, 'Run%02d_%s_execution.png' % (runID, taskDir))
				Drawer().scatter_graph(xData[0], yData[0], title, xCaption, yCaption, width, height, filename)

				multi_xData.append(xData[0])
				multi_yData.append(yData[0])
				multi_titles.append(taskDir)

			print('\t\tSummay ....', end='')
			supertitle = self._make_title(pre_title)
			filename = os.path.join(self.targetpath, 'Summary_execution_run%02d.png' % (runID))
			Drawer().scatter_graph_multi(multi_xData, multi_yData, supertitle, multi_titles, xCaption, yCaptionCnt, width, height,filename)
			print('Done')
		pass

	def update_data(self):
		'''
		When the experiment results are not compatible,
			we can use this code to fix it.
		:return:
		'''
		objective = 'minimums'
		for path, taskDir, taskID in self._loop_task(self.basepath):
			print('%02d, ' % taskID, end='')

			for filename, fileIDX in self._loop_runfile(path, objective):

				f = codecs.open(filename, 'r')
				lines = f.readlines()
				f.close()
				f = codecs.open(filename, 'w')
				cols = lines[0].strip().split(',')
				del cols[1]
				for x in range(len(cols)):
					if cols[x] == '':
						del cols[x]

				f.write(','.join(cols)+'\n')
				for line in lines[1:]:
					f.write(line)
				f.close()
		pass

if __name__ == "__main__":
	LimitRuns = None
	targets = {}
	basepath = '../../RTA_Expr/results/'

	# targets['GA_big'] = basepath + '20190508_IN0416_GA_big'
	# targets['GA_newfitness'] = basepath + '20190508_IN0416_GA_newfitness'
	# targets['GA_newfitness_2Replace'] = basepath + '20190512_IN0416_GA_double_2_best'
	# targets['GA_big_10Samples'] = basepath + '20190509_IN0416_GA_big_sample10'
	# targets['GA_big_40Samples'] = basepath + '20190508_IN0416_GA_big_sample40'
	# targets['GA_newfitness_10Samples'] = basepath + '20190509_IN0416_GA_newfitness_sample10'
	# targets['GA_newfitness_40Samples'] = basepath + '20190508_IN0416_GA_newfitness_sample40'
	# targets['GA_newfitness_log'] = basepath + 'GA_double_log'
	# targets['GA_newfitness_cut20'] = basepath + 'GA_double_cut20'
	# targets['GA_newfitness_power'] = basepath + 'GA_double_power'
	targets['GA_double_fixed'] = basepath + '20190527_IN0416_GA_double_fixed_power3'
	# targets['GA_BigDecimal_1child'] = basepath + '20190522_IN0416_GA_BigDecimal_1child'
	# targets['GA_BigDecimal_2child'] = basepath + '20190522_IN0416_GA_BigDecimal_2child'

	for key, value in targets.items():
		g = InitialGraph(value, key)
		# g.update_data()
		# g.check_deadlineMiss()
		g.summary_fitness_graph(5)
		g.summary_bestMissed(_applyRun=5, _nTasks=34)
		# g.make_bestMissed_detail(_nTasks=tasks[key])
		# g.make_maximum_targeted_eachrun(tasks[key])
		# g.make_execution_graph()
		# g.make_execution_counting_graph()

	# g = InitialGraph('../results_s/HPC_20181212_ArrivalT8_Periodic0', 'ArrivalOrigin_i2000')
# 	# completedRuns = g.make_fitness_graph(_applyRun=LimitRuns)
# 	# g.make_maximum_targeted(completedRuns)
# 	# g.make_maximum_targeted_eachrun()