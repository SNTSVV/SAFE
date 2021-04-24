"""
"""
import codecs
import os
from decimal import Decimal

from utils.Loader import Loader, DecimalMath
from utils.data import DataFrameDecimal
from graph.drawer import Drawer
from graph.grapher import Graph
from utils import common


class VaryingGraph(Graph):
	basepath = ''
	target_base = '_charts'
	targetpath = ''
	global_appendix = ''

	def __init__(self, _basepath, appendix=''):
		super().__init__(_basepath, appendix)
		pass

	def boxplots(self, _completedRuns=None):
		# Graph settings
		pre_title = 'Fitness Distribution'
		xCaption = 'Iteration'
		yCaption = 'Fitness value'
		width = 3000
		height = 2400
		objective = 'expended'

		save_path = self._prepare_path(os.path.join(self.targetpath, objective))

		print('\tDrawing sample\'s fitness plots:')
		ticklabels = []
		datagroup = []
		for path, taskDir, taskID in self._loop_task(self.basepath):
			print('%02d, ' % taskID, end='')
			filepath = os.path.join(path, objective, 'fitness.csv')
			df = DataFrameDecimal.from_csv(filepath, _header=0)
			ticklabels.append('Task %02d'%taskID)
			datagroup.append(df.get(3))

		filename = os.path.join(save_path, 'fitness.png')
		Drawer().boxplots(datagroup, ticklabels, pre_title, xCaption, yCaption, width, height, filename)

	def boxplots_best(self, _completedRuns=None):
		# Graph settings
		pre_title = 'Best(e-d) Distribution'
		xCaption = 'Iteration'
		yCaption = 'Best(e-d) value'
		width = 3000
		height = 2400
		objective = 'expended'

		save_path = self._prepare_path(os.path.join(self.targetpath, objective))

		print('\tDrawing sample\'s best(e-d) plots:')
		ticklabels = []
		datagroup = []
		for path, taskDir, taskID in self._loop_task(self.basepath):
			print('%02d, ' % taskID, end='')

			filepath = os.path.join(path, objective, 'best(e-d).csv')
			#df = DataFrameDecimal.from_csv(filepath, _header=0)
			titles, data = Loader.load_csv_colbase(filepath, [int]*3+[int]*35, _headline=True)
			data= data[3:]
			ticklabels.append('Task %02d'%taskID)
			datagroup.append(data[taskID-1])

		filename = os.path.join(save_path, 'best(e-d).png')
		Drawer().boxplots(datagroup, ticklabels, pre_title, xCaption, yCaption, width, height, filename)

	def deadlines_barchart(self, _completedRuns=None):
		# Graph settings
		pre_title = 'Missing Deadline Distribution'
		xCaption = 'Tasks'
		yCaption = 'Number of missing deadlines'
		width = 1000
		height = 500
		objective = 'expended'

		save_path = self._prepare_path(os.path.join(self.targetpath, objective))

		print('\tDrawing sample\'s deadlines plots:')
		ticklabels = ['%d'%(x+1) for x in range(35)]
		for path, taskDir, taskID in self._loop_task(self.basepath):
			print('%02d' % taskID, end='')

			filepath = os.path.join(path, objective, 'deadlines.csv')
			titles, data = Loader.load_csv_rowbase(filepath, [int]*9, _headline=True)
			counts = [0] * 35
			for item in data:
				counts[item[3]-1] +=1

			filename = os.path.join(save_path, 'deadlines_Task%02d.png'%taskID)
			Drawer().barchart(counts, ticklabels, pre_title, xCaption, yCaption, width, height, filename)
			print(', ', end='')
		print('Done')

	def WCET_distribution(self, _completedRuns=None):
		# Graph settings
		pre_title = 'Task35 WCET Distribution'
		xCaption = 'WCET (seconds)'
		yCaption = 'Number of WCET'
		width = 1200
		height = 800
		objective = 'expended'

		save_path = self._prepare_path(os.path.join(self.targetpath, objective))

		print('\tDrawing sample\'s WCET distribution plots:', end='')
		titlegroup = []
		datagroup = []
		for path, taskDir, taskID in self._loop_task(self.basepath):
			print('%02d' % taskID, end='')

			filepath = os.path.join(path, objective, 'description.csv')
			titles, data = Loader.load_csv_colbase(filepath, [int]*5, _headline=True)
			for x in range(len(data[4])):
				data[4][x] = data[4][x] / 10000
			titlegroup.append('Task %02d'%taskID)
			datagroup.append(data[4])
			print(', ', end='')

		filename = os.path.join(save_path, 'WCETdist.png')
		Drawer().histogram_multi(datagroup, pre_title, titlegroup, xCaption, yCaption, width, height, filename)

		print('Done')

	def varyWCET_fitness(self, _completedRuns=None):
		# Graph settings
		pre_title = 'VaryWCET(Task35) Fitness'
		xCaption = 'Iterations'
		yCaption = 'Fitness'
		width = 1200
		height = 800
		objective = 'fitness'

		save_path = self._prepare_path(os.path.join(self.targetpath, objective))

		for runID in range(1, 6, 1):
			print('\tDrawing VaryWCET fitness plots:', end='')
			titlegroup = []
			datagroup = []

			for path, taskDir, taskID in self._loop_task(self.basepath):
				print('%02d' % taskID, end='')
				common.TASK_INFO = self._load_input_used(path)

				filepath = os.path.join(path, 'results', 'result_obj00_run%02d.csv' % runID)
				titles = []
				data = []
				try:
					df = DataFrameDecimal.from_csv(filepath, _header=0)
					df.get()
					titles, data = Loader.load_csv_rowbase(filepath, [int,int,float], _headline=True)
				except:
					print('error to find file:%s' % filepath)
					continue
				fitnessGroup = []
				ticklabels=[]
				for iter, solID, fitness in df:
					if iter > len(fitnessGroup):
						fitnessGroup.append(list())
						if (iter%50) == 0:
							ticklabels.append(iter)
						else:
							ticklabels.append('')
					fitnessGroup[iter-1].append(fitness)

				# organize data
				fitnessGroup, multiflied = self._reduce_group_values(fitnessGroup, _multiflier=Decimal("1.0E+300"))
				appendix = (", applied *%s" % str(multiflied)) if multiflied is not None else ""


				size = 60
				cnt = int(len(fitnessGroup)/size)
				if len(fitnessGroup)%size > 0:
					cnt +=1

				for x in range(cnt):
					title = pre_title + ('(part%d)'%(x+1)) + appendix
					filename = os.path.join(save_path, 'fitness_Task%02d_run%02d_part%02d.png'%(taskID, runID, x+1))
					start = x*size
					end = start + size
					Drawer().boxplots(fitnessGroup[start:end], ticklabels, title, xCaption, yCaption, width, height, filename)

				titlegroup.append('Task %02d'%taskID)
				datagroup.append(fitnessGroup)
				print(', ', end='')

			# filename = os.path.join(save_path, 'WCETdist.png')
			# Drawer().boxplots_multi(datagroup, pre_title, titlegroup, xCaption, yCaption, width, height, filename)
			print('Done.\n')
		print('Done')

	def varyWCET_fitness_avg(self, _completedRuns):
		'''

		:param _completedRuns:
		:return:
		'''
		# Graph settings
		pre_title = 'VaryWCET(Task%02d) Fitness (avg. samples)'
		xCaption = 'Iterations'
		yCaption = 'Fitness'
		width = 1200
		height = 800
		objective = 'fitness_avg'

		save_path = self._prepare_path(os.path.join(self.targetpath, objective))

		iters = []
		for runID in range(1, _completedRuns+1, 1):
			print('\tDrawing VaryWCET fitness plots:', end='')
			titlegroup = []
			datagroup = []
			yTitles = []

			for path, taskDir, taskID in self._loop_task(self.basepath):
				print('%02d' % taskID, end='')
				common.TASK_INFO = self._load_input_used(path)

				filepath = os.path.join(path, 'results', 'result_obj00_run%02d.csv' % runID)

				try:
					titles, data = Loader.load_csv_rowbase(filepath, [int,int,Decimal], _headline=True)
				except:
					print('error to find file:%s' % filepath)
					continue

				fitnessGroup = []
				for iter, solID, fitness in data:
					if iter > len(fitnessGroup):
						fitnessGroup.append(list())
					fitnessGroup[iter-1].append(fitness)

				#Organize values
				values = Loader.get_averages2(fitnessGroup)
				values, multiflied = self._reduce_values(values, _multiflier=Decimal("1.0E+300"))
				appendix = (", applied *%s" % str(multiflied)) if multiflied is not None else ""

				iters = [x+1 for x in range(len(values))]
				title = pre_title%taskID + appendix
				filename = os.path.join(save_path, 'fitness_avg_Task%02d_run%02d.png'%(taskID, runID))
				yTitle = '%s%s'% (yCaption, (" (applied *%s)" % str(multiflied)) if multiflied is not None else "")
				Drawer().single_graph(iters, values, title, xCaption, yTitle, width, height, filename)

				titlegroup.append(common.TASK_INFO[taskID])
				datagroup.append(values)
				yTitles.append(yTitle)
				print(', ', end='')

			super_title = 'Fitness with varying WCET for Task35 (Run %02d, avg. samples)'% runID
			filename = os.path.join(self.targetpath, 'Fitness_avg_run%02d.png'%runID)
			Drawer().multi_data_graph(iters, datagroup, super_title, titlegroup, xCaption, yTitles, width, height, filename)
			print('Done.\n')
		print('Done')

	def varyWCET_fitness_mid(self, _completedRuns):
		'''

		:param _completedRuns:
		:return:
		'''
		# Graph settings
		pre_title = 'VaryWCET(Task%02d) Fitness (mid. samples)'
		xCaption = 'Iterations'
		yCaption = 'Fitness'
		width = 1200
		height = 800
		objective = 'fitness_mid'

		save_path = self._prepare_path(os.path.join(self.targetpath, objective))

		iters = []
		for runID in range(1, _completedRuns+1, 1):
			print('\tDrawing VaryWCET fitness plots:', end='')
			titlegroup = []
			datagroup = []
			yTitles = []

			for path, taskDir, taskID in self._loop_task(self.basepath):
				print('%02d' % taskID, end='')
				common.TASK_INFO = self._load_input_used(path)

				filepath = os.path.join(path, 'results', 'result_obj00_run%02d.csv' % runID)

				try:
					titles, data = Loader.load_csv_rowbase(filepath, [int,int,Decimal], _headline=True)
				except:
					print('error to find file:%s' % filepath)
					continue

				fitnessGroup = []
				for iter, solID, fitness in data:
					if iter > len(fitnessGroup):
						fitnessGroup.append(list())
					fitnessGroup[iter-1].append(fitness)

				#Organize values
				values = Loader.get_mid2(fitnessGroup)
				values, multiflied = self._reduce_values(values, _multiflier=Decimal("1.0E+300"))
				appendix = (", applied *%s" % str(multiflied)) if multiflied is not None else ""

				iters = [x+1 for x in range(len(values))]
				title = pre_title%taskID + appendix
				filename = os.path.join(save_path, 'fitness_mid_Task%02d_run%02d.png'%(taskID, runID))
				yTitle = '%s%s'% (yCaption, (" (applied *%s)" % str(multiflied)) if multiflied is not None else "")
				Drawer().single_graph(iters, values, title, xCaption, yTitle, width, height, filename)

				titlegroup.append(common.TASK_INFO[taskID])
				datagroup.append(values)
				yTitles.append(yTitle)
				print(', ', end='')

			super_title = 'Fitness with varying WCET for Task35 (Run %02d, mid. samples)'% runID
			filename = os.path.join(self.targetpath, 'Fitness_mid_run%02d.png'%runID)
			Drawer().multi_data_graph(iters, datagroup, super_title, titlegroup, xCaption, yTitles, width, height, filename)
			print('Done.\n')
		print('Done')

	def varyWCET_deadline_sactter(self, _completedRuns=None):
		# Graph settings
		pre_title = 'Deadline distribution with F(Task%d)'
		xCaption = 'Maximum WCET (seconds)'
		yCaption = ''
		width = 2000
		height = 800
		objective = 'deadline_dist'

		save_path = self._prepare_path(os.path.join(self.targetpath, objective))

		for path, taskDir, taskIDfile in self._loop_task(self.basepath):
			print('\tTask%02d loading' % taskIDfile, end='')
			common.TASK_INFO = self._load_input_used(path)

			WCET= {}
			Deadlines = {}
			count=0
			for filename, solutionID in self._loop_solutionfiles(path, 'samples/deadlines'):
				deadlinePath = os.path.join(path, 'samples', 'deadlines', filename)
				wcetPath = os.path.join(path, 'samples', 'WCET', filename)

				WCET[solutionID] = {}
				Deadlines[solutionID] = {}

				# load WCET
				titles, data = Loader.load_csv_rowbase(wcetPath, [int]*4, _headline=True)
				for sampleID, taskID, executionID, sampledWCET in data:
					if sampleID not in WCET[solutionID]: WCET[solutionID][sampleID] = []
					WCET[solutionID][sampleID].append(sampledWCET)

				for key in WCET[solutionID]:
					WCET[solutionID][key] = max(WCET[solutionID][key])

				# load Deadlines
				titles, data = Loader.load_csv_rowbase(deadlinePath, [int]*8, _headline=True)
				for sampleID, taskID, executionID, arrival, started, finished, deadline, misses in data:
					if sampleID not in Deadlines[solutionID]: Deadlines[solutionID][sampleID] = {}
					if taskID not in Deadlines[solutionID][sampleID]: Deadlines[solutionID][sampleID][taskID] = 0
					Deadlines[solutionID][sampleID][taskID] += 1
				count +=1
				if count%10==0:
					print('.', end='')

			print('drawing...', end='')

			minWCET = 1000000000
			minTask = 0
			# make scatter data
			#WCET[solutionID][sampleID] = sampledWCET
			xdata = []		# WCET
			ydata = []		# tasks
			for solutionID in WCET.keys():
				if solutionID not in Deadlines: continue
				for sampleID in WCET[solutionID].keys():
					if sampleID not in Deadlines[solutionID]: continue
					for taskID in Deadlines[solutionID][sampleID].keys():
						aValueWCET = WCET[solutionID][sampleID]/10000.0
						if aValueWCET < minWCET:
							minTask = taskID
							minWCET = aValueWCET
						#if aValueWCET > 20.0: continue
						ydata.append(taskID)
						xdata.append(aValueWCET)


			title = self._make_title(pre_title%taskIDfile)
			filename = os.path.join(save_path, 'deadline_distributions_Task%02d.png' % (taskIDfile))
			text = [('min(T%d)=%.4fs'%(minTask, minWCET), minWCET, 10)]
			Drawer().scatter_graph(xdata, ydata, title, xCaption, yCaption, width, height, filename, isTasks=True, isDetail=True, text=text)
			print('Done.')

	def see_fitness_dist_csv(self, _completedRuns):
		'''
		Check the distribution of fitness and evaluate which distribution they have
		:param _completedRuns:
		:return:
		'''

		filepath = self._prepare_path(self.targetpath)
		filepath = os.path.join(filepath, 'fitness_dist.csv')
		savefile = codecs.open(filepath, "w")

		# Graph settings
		avgs = []
		vars = []
		mids = []
		print("Creating analysis Average and median...", end='')
		for runID in range(1, _completedRuns+1, 1):
			savefile.write("Task, Solution, Average, Variance, Median\n")
			for path, taskDir, taskID in self._loop_task(self.basepath):
				#if taskID < 23: continue
				print("%d"%(taskID), end='')

				for filename, solutionID in self._loop_solutionfiles(path, 'samples/fitness'):

					try:
						filepath = os.path.join(path, 'samples/fitness', filename)
						titles, data = Loader.load_csv_colbase(filepath, [int, Decimal, int], _headline=True)
					except:
						print('error to find file:%s' % filepath)
						continue

					#Organize values
					avg = DecimalMath.average(data[1])
					variance = DecimalMath.variance(data[1], avg)
					mid = DecimalMath.median(data[1])
					savefile.write("%d, %d, %s, %s, %s\n" % (taskID, solutionID, avg, variance, mid))
					avgs.append(avg)
					vars.append(variance)
					mids.append(mid)
				print(", ",end='')
		savefile.close()

		# width = 1200
		# height = 800
		# yCaption = 'Counts'
		# xCaption = 'Average of fitness'
		# title = 'Histogram of fitness averages'
		# filename = os.path.join(self.targetpath, 'fitness_averages.png')
		# Drawer().histogram(avgs, title, xCaption, yCaption, width, height, filename)
		#
		# xCaption = 'Variance of fitness'
		# title = 'Histogram of fitness variance'
		# filename = os.path.join(self.targetpath, 'fitness_variance.png')
		# Drawer().histogram(vars, title, xCaption, yCaption, width, height, filename)
		#
		# xCaption = 'Median of fitness'
		# title = 'Histogram of fitness medians'
		# filename = os.path.join(self.targetpath, 'fitness_median.png')
		# Drawer().histogram(mids, title, xCaption, yCaption, width, height, filename)

		print('Done')

	def load_bestMissed_data(self, taskID, path, objective, _nTasks, _onlyRelatedTask=True):

		def get_maxdata(_list):
			line = [_list[0][0]]
			for x in range(2, len(_list[0])):
				maxValue = _list[0][x]
				for i in range(len(_list)):
					if maxValue >= _list[i][x]: continue
					maxValue = _list[i][x]
				line.append(maxValue)
			return line

		def get_reduce_data(data):

			# aggregate iter value
			aggData = []
			for x in range(len(data)):
				iter = data[x][0]
				if iter > len(aggData):
					aggData.append([])
				aggData[iter-1].append(data[x])

			new_data = []
			for x in range(len(aggData)):
				new_data.append(get_maxdata(aggData[x]))
			return new_data

		def columnize(data):
			cols = []
			for c in range(len(data[0])):
				cols.append([])
				for r in range(len(data)):
					cols[c].append(data[r][c])
			return cols

		# load files and make a average values
		iters=[]
		minimums= [] if _onlyRelatedTask is True else [list() for x in range(_nTasks)]

		properRuns = self._get_proper_runs(self.basepath, taskID)
		for filepath, fileIDX in self._loop_runfile(path, objective, properRuns):

			# load values and make average
			# titles, data = Loader.load_csv_colbase(filepath, [int,int]+[float]*_nTasks, _headline=True)
			titles, data = Loader.load_csv_rowbase(filepath, [int,int]+[float]*_nTasks, _headline=True)

			data = get_reduce_data(data)
			data = columnize(data)
			iters = data[0]

			if _onlyRelatedTask is True:
				minimums.append(data[taskID]) # select specific task information
			else:
				for x in range(1, len(data)):
					minimums[x-1].append(data[x])

		if _onlyRelatedTask is True:
			runs = len(minimums)
			minimums = Loader.get_averages(minimums)
		else:
			runs = len(minimums[0])
			for x in range(len(minimums)):
				minimums[x] = Loader.get_averages(minimums[x])

		return iters, minimums, runs

	def summary_bestMissed(self, _applyRun=None, _nTasks=34):
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

	def make_bestMissed(self, _applyRun=None, _nTasks=34):
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
			print('%d'%taskID, end='')
			common.TASK_INFO = self._load_input_used(path)

			xValues, yValues, runs = self.load_bestMissed_data(taskID, path, objective, _nTasks)

			# Draw graph
			title = self._make_title(pre_title+' (%druns)' % runs)
			filename = os.path.join(save_path, '%s_best(e-d).png' % (taskDir))
			Drawer().single_graph(xValues, yValues, title, xCaption, yCaption, width, height,filename, stress=True)

			yield taskID, xCaption, yCaption, xValues, yValues, runs
			print(', ', end='')
		print('Done.')
		return

	# def make_bestMissed_detail(self, _applyRun=None, _nTasks=34):
	# 	'''
	# 	produce graphs all tasks's best(e-d) behaviors for all executed F(Tx)
	# 	:param _applyRun:
	# 	:param _nTasks:
	# 	:return:
	# 	'''
	# 	# Graph settings
	# 	pre_title = 'Best(e-d) Behaviors for all tasks'
	# 	xCaption = 'Iteration'
	# 	yCaption = 'Time Quanta'
	# 	width = 1200
	# 	height = 800
	# 	objective = 'minimums'
	#
	# 	# make path to save graph
	# 	save_path = self._prepare_path(os.path.join(self.targetpath, objective+'_detail'))
	#
	# 	# work for each task
	# 	print('\tDrawring Best(e-d) details...', end='')
	# 	for path, taskDir, taskID in self._loop_task(self.basepath):
	# 		print('Task%d'%taskID, end='')
	# 		TASK_INFO = self._load_input_used(path)
	#
	# 		# load files and make a average values
	# 		xValues, yValues, runs = self.load_bestMissed_data(taskID, path, objective, _nTasks, True)
	# 		titles = ['%s'%(TASK_INFO[x+1]) for x in range(_nTasks)]
	#
	# 		#Detail graph
	# 		supertitle = self._make_title(pre_title+ ' (%druns)'%(runs))
	# 		filename = os.path.join(save_path, 'Detail_%s_best(e-d).png' % (taskDir))
	# 		Drawer().single_graph(xValues, yValues, titles[taskID-1], xCaption, yCaption, width, height,filename, stress=True)
	# 		#Drawer().multi_data_graph(xValues, yValues, supertitle, titles, xCaption, yCaption, width, height,filename, stress=True)
	#
	# 		print(', ', end='')
	# 	print(' Done.')
	# 	pass

	################################################################
	# Probability_dist
	################################################################
	def varyWCET_probability_dist(self, _commpletedRuns=None):
		# 특정 WCET에서 발생한 Deadline misses의 수
		# total executions
		# Graph settings

		pre_title = 'Probability of Missing Deadline'
		xCaption = 'WCET (seconds)'
		yCaption = 'Probability'
		width = 1200
		height = 800
		objective = 'DM_probability'

		print('Drawing %s ...'%pre_title)
		xValues = []
		yValues = []
		titles = []
		for path, taskDir, taskIDfile in self._loop_task(self.basepath):
			print('\tTask%02d loading...' % taskIDfile, end='', flush=True)

			# load data from all solutions
			datalist = self.load_probability_dist(path)
			common.TASK_INFO = self._load_input_used(path)

			# calculate statistics
			stat = {}
			for WCET, taskID, nDeadline, nArrivals in datalist:
				if taskIDfile != taskID: continue
				if taskID not in stat:
					stat[taskID] = {'WCET':[], 'P':[]}
				stat[taskID]['WCET'].append(WCET)
				stat[taskID]['P'].append(0 if nArrivals == 0 else nDeadline/float(nArrivals))

			# cumulative values
			stat = self.cumulate(stat, 1000)
			# stat = self.fit_unit(stat, 10000)

			if len(stat)==0:
				print('No Deadline misses.', end='', flush=True)
			else:
				print('Drawing...', end='', flush=True)
				# Draw each graph
				save_path = self._prepare_path(os.path.join(self.targetpath, objective))
				title 		= '%s (%s)' % (pre_title, common.TASK_INFO[taskIDfile])
				outputpath 	= os.path.join(save_path, '%s_F(T%d)_Task%d.png'%(objective, taskIDfile, taskIDfile))
				Drawer().scatter_graph(stat[taskIDfile]['WCET'], stat[taskIDfile]['P'],
									  title, xCaption, yCaption, width, height, outputpath, maxSet=True)

				xValues.append(stat[taskIDfile]['WCET'])
				yValues.append(stat[taskIDfile]['P'])
				titles.append(common.TASK_INFO[taskIDfile])
			print('Done.')

		supertitle = self._make_title(pre_title)
		outputpath 	= os.path.join(self.targetpath, 'Summary_%s.png'%(objective))
		Drawer().scatter_graph_multi(xValues, yValues, supertitle,
								  titles, xCaption, yCaption, width, height, outputpath, maxSet=True)
		print('Done.')
		pass

	def varyWCET_probability(self, _commpletedRuns=None, _bucketsize=100):
		# 특정 WCET에서 발생한 Deadline misses의 수
		# total executions
		# Graph settings

		pre_title = 'Probability of Missing Deadline'
		xCaption = 'WCET (seconds)'
		yCaption = 'Probability'
		width = 1200
		height = 800
		objective = 'DM_probability'

		print('Drawing %s ...'%pre_title)
		xValues_multi = []
		yValues_multi = []
		titles = []
		for path, taskDir, taskIDfile in self._loop_task(self.basepath):
			print('\tTask%02d loading...' % taskIDfile, end='', flush=True)

			# load data from all solutions
			datalist = self.load_probability_dist(path)
			common.TASK_INFO = self._load_input_used(path)

			# calculate statistics
			stat = {}
			for WCET, taskID, nDeadline, nArrivals in datalist:
				if taskIDfile != taskID: continue
				if taskID not in stat:
					stat[taskID] = {}

				if WCET > 50000: continue

				bucket = WCET//_bucketsize
				if bucket not in stat[taskID]:
					stat[taskID][bucket] = {'Deadlines':0, 'Solutions':0}

				stat[taskID][bucket]['Deadlines'] += (1 if nDeadline>0 else 0)
				stat[taskID][bucket]['Solutions'] += 1

			# cumulative values
			xValues = []
			yValues = []
			for x in stat[taskIDfile].keys():
				item = stat[taskIDfile][x]
				xValues.append(x/100)
				yValues.append(item['Deadlines']/item['Solutions'])

			# stat = self.cumulate(stat, 1000)
			# stat = self.fit_unit(stat, 10000)

			if len(stat)==0:
				print('No Deadline misses.', end='', flush=True)
			else:
				print('Drawing...', end='', flush=True)
				# Draw each graph
				save_path = self._prepare_path(os.path.join(self.targetpath, objective))
				title 		= common.TASK_INFO[taskIDfile] # '%s (%s)' % (pre_title, common.TASK_INFO[taskIDfile])
				outputpath 	= os.path.join(save_path, '%s_F(T%d)_Task%d.png'%(objective, taskIDfile, taskIDfile))
				Drawer().scatter_graph(xValues, yValues, title, xCaption, yCaption, width, height, outputpath)

				xValues_multi.append(xValues)
				yValues_multi.append(yValues)
				titles.append(common.TASK_INFO[taskIDfile])
			print('Done.')

		supertitle = pre_title
		outputpath 	= os.path.join(self.targetpath, 'Summary_%s.png'%(objective))
		Drawer().scatter_graph_multi(xValues_multi, yValues_multi, supertitle,
									 titles, xCaption, yCaption, width, height, outputpath)
		print('Done.')
		pass

	def varyWCET_probability_dist_detail(self, _commpletedRuns=None):
		# 특정 WCET에서 발생한 Deadline misses의 수
		# total executions
		# Graph settings
		pre_title = 'Probability of Missing Deadline'
		xCaption = 'WCET (seconds)'
		yCaption = 'Probability'
		width = 1200
		height = 800
		objective = 'DM_probability_detail'

		for path, taskDir, taskIDfile in self._loop_task(self.basepath):
			#if taskIDfile != 25: continue
			print('\tF(Task%02d) loading...' % taskIDfile, end='')

			# load data from all solutions
			datalist = self.load_probability_dist(path)
			common.TASK_INFO = self._load_input_used(path)

			# calculate statistics
			stat = {}
			for WCET, taskID, nDeadline, nArrivals in datalist:
				if taskID not in stat:
					stat[taskID] = {'WCET':[], 'P':[]}
				stat[taskID]['WCET'].append(WCET)
				stat[taskID]['P'].append(0 if nArrivals == 0 else nDeadline/float(nArrivals))

			# cumulative values
			stat = self.cumulate(stat, 1000)
			# stat = self.fit_unit(stat, 10000)

			# Draw each graph
			print('Drawing Task', end='', flush=True)
			save_path = self._prepare_path(os.path.join(self.targetpath, objective))
			for taskID in stat.keys():
				title 		= '%s (%s)' % (pre_title, common.TASK_INFO[taskID])
				outputpath 	= os.path.join(save_path, '%s_F(T%d)_Task%d.png'%(objective, taskIDfile, taskID))
				Drawer().scatter_graph(stat[taskID]['WCET'], stat[taskID]['P'],
									   title, xCaption, yCaption, width, height, outputpath, maxSet=True)
				print('.' , end='', flush=True)

			xValues = []
			yValues = []
			titles = []
			for taskID in stat.keys():
				xValues.append(stat[taskID]['WCET'])
				yValues.append(stat[taskID]['P'])
				titles.append(common.TASK_INFO[taskID])

			print('summary...' , end='', flush=True)
			supertitle = self._make_title(pre_title)
			outputpath 	= os.path.join(save_path, '_Summary_%s_F(T%d).png'%(objective, taskIDfile))
			Drawer().scatter_graph_multi(xValues, yValues, supertitle,
										 titles, xCaption, yCaption, width, height, outputpath, maxSet=True)
			print('Done', flush=True)
		pass

	def cumulate(self, _stat, _level):
		unit = 10000
		left_unit = float(unit / _level)
		cums = {}
		for taskID in _stat.keys():
			if taskID not in cums: cums[taskID] = {}

			for x in range(len(_stat[taskID]['WCET'])):
				WCET = int(_stat[taskID]['WCET'][x]/_level)
				p = _stat[taskID]['P'][x]
				if WCET not in cums[taskID]: cums[taskID][WCET] = 0.0
				cums[taskID][WCET] += p

		stat = {}
		for taskID in cums.keys():
			stat[taskID] = {'WCET':[], 'P':[]}
			for WCET in cums[taskID].keys():
				stat[taskID]['WCET'].append(WCET/left_unit)
				stat[taskID]['P'].append(cums[taskID][WCET])
		return stat

	def fit_unit(self, _stat, _level):
		for taskID in _stat.keys():
			for x in range(len(_stat[taskID]['WCET'])):
				_stat[taskID]['WCET'][x] = _stat[taskID]['WCET'][x]/float(_level)

		return _stat

	def load_probability_dist(self, _path, _nTasks=34):
		# list=[
		# 	(WCET[sampleID], taskID, nDeadline, arrivals), ...
		# ]

		#
		datalist = []
		for filename, solutionID in self._loop_solutionfiles(_path, 'samples/deadlines'):
			deadlinePath = os.path.join(_path, 'samples', 'deadlines', filename)
			arrivalsPath = os.path.join(_path, 'samples', 'arrivals', filename)
			wcetPath = os.path.join(_path, 'samples', 'WCET', filename)

			deadlines = self.load_deadlines(deadlinePath)
			WCET = self.load_WCET(wcetPath)
			arrivals = self.load_arrivals(arrivalsPath, solutionID)

			for sampleID in WCET.keys():
				for taskID in range(1,_nTasks+1):
					nDeadline = 0
					if sampleID in deadlines and taskID in deadlines[sampleID]:
						nDeadline = deadlines[sampleID][taskID]
					item = [WCET[sampleID], taskID, nDeadline, arrivals[taskID]]
					datalist.append(item)

		return datalist

	def load_WCET(self, _filepath):
		# returns WCET[sampleID] = WCET
		header, data = Loader.load_csv_rowbase(_filepath, [int]*8, _headline=True)
		WCET = {}
		for item in data:  # sampleID, taskID, executionID, sampledWCET
			WCET[item[0]] = item[3]
		return WCET

	def load_deadlines(self, _filepath):
		# returns deadlines[sampleID][taskID] = nDeadlines
		header, data = Loader.load_csv_rowbase(_filepath, [int]*8, _headline=True)
		deadlines = {}
		for item in data:  # sampleID,taskID,executionID,arrival,started,finished,deadline,misses
			sampleID = item[0]
			taskID = item[1]
			if sampleID not in deadlines: deadlines[sampleID] = {}
			if taskID not in deadlines[sampleID]: deadlines[sampleID][taskID] = 0
			deadlines[sampleID][taskID] += 1
		return deadlines

	# arrivals = None
	def load_arrivals(self, _filepath, _solutionID):
		header, data = Loader.load_csv_rowbase(_filepath, [int]*8, _headline=True)
		arrivavls = {}
		for taskID, count in data:  # taskID, nArrivals
			arrivavls[taskID] = count
		return arrivavls


if __name__ == "__main__":
	LimitRuns = None
	basepath = '../../StressTesting/results/'
	targets = {}

	# folders = [ #'../results_s/20190114_Data0111_varyWCET20_newSeq',
	# 	#'../results_s/20190114_Data0111_varyWCET20_oldSeq']
	# 	#'20190124_IN0111_revealWCET_run']
	# 	'20190124_IN0111_varyWCET20_TwoUniform']
	# names = [#'VaryWCET_newSeq',
	# 	#'VaryWCET_oldSeq']
	# 	#'revealWCET']
	# 	'Probability']

	targets['GA_big_10Samples'] = basepath + '20190509_IN0416_GA_big_sample10'
	# targets['GA_big_40Samples'] = basepath + '20190508_IN0416_GA_big_sample40'
	targets['GA_newfitness_10Samples'] = basepath + '20190509_IN0416_GA_newfitness_sample10'
	# targets['GA_newfitness_40Samples'] = basepath + '20190508_IN0416_GA_newfitness_sample40'


	for name, folder in targets.items(): #range(len(folders)):
		g=VaryingGraph(folder, name)
		# g.varyWCET_fitness_avg(1)
		g.summary_bestMissed(1)
		# g.varyWCET_fitness_mid(1)
		# g.varyWCET_deadline_sactter()
		# g.see_fitness_dist_csv(1)
		# g.varyWCET_probability_dist_detail()
		# g.varyWCET_probability()

		# for run in range(20):
			# g=VaryingGraph(basepath + folders[x]+str(run), names[x])
			# g.varyWCET_fitness_avg(1)
			# g.varyWCET_fitness_mid(1)
			# g.varyWCET_deadline_sactter()
			# g.varyWCET_probability_dist_detail()
