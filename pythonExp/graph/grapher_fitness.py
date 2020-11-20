"""
"""
import os
from decimal import Decimal
from utils.Loader import Loader
from graph.drawer import Drawer
from graph.grapher import Graph
from utils import common


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
		for path, taskDir in self._loop_subpath(self.basepath):
			taskID = int(taskDir[4:taskDir.find("_")])
			nSamples = int(taskDir[taskDir.find("_")+7:])

			common.TASK_INFO = self._load_input_used(path)

			iters, values, runs, multiflied = self.load_fitness_data(path, _applyRun)

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

	def load_fitness_data(self, path, _applyRun=None):
		from utils.data import DataFrameDecimal

		runs = 0
		iters = []
		values = []
		for filepath, filename in self._loop_subfiles(path+'/results'):
			if _applyRun is not None and runs>=_applyRun:	break

			df = DataFrameDecimal.from_csv(filepath, _header=0)
			iters = df.get(0)
			values.append(df.get(1))
			runs+=1

		# organize data
		values = Loader.get_averages(values)
		values, multiflied = self._reduce_values(values, _multiflier=Decimal("1.0E+300"))

		return iters, values, runs, multiflied

	def _loop_subfiles(self, _path):
		'''
        looping folder in specific path
        It expects Task and Task number (e.g. Task01, Task10, ...)
        :param _path:
        :return:
        '''
		base = os.path.abspath(_path)
		files = os.listdir(base)
		files.sort()

		for file in files:
			path = os.path.join(base, file)
			if os.path.isdir(path) is True: continue
			yield path, file
		return True


if __name__ == "__main__":
	LimitRuns = None
	targets = {}
	basepath = '../../RTA_Expr/results/'
	targets['GA_best_sample'] = basepath + '20190529_FitnessTest_BigOrigin_fitness'

	for key, value in targets.items():
		g = InitialGraph(value, key)
		g.summary_fitness_graph(1)
