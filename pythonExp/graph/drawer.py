"""
==============================
Plotting categorical variables
==============================

How to use categorical variables in Matplotlib.

Many times you want to create a plot that uses categorical variables
in Matplotlib. Matplotlib allows you to pass categorical variables directly to
many plotting functions, which we demonstrate below.
"""
import math
import matplotlib.pyplot as plt
import numpy as np
from utils import common


class Drawer():
	font_title = 25
	font_supertitle = 45
	font_label = 18
	font_labeltick = 15
	linewidth=4.0
	
	def __init__(self):

		pass

	###############################################################
	# Draw plot
	###############################################################
	def __do_plot(self, xdata, ydata, title, xlabel, ylabel, stress=False):
		color=None
		if stress is True:
			for item in ydata:
				if item <= 0: continue
				color = 'r'
				break

		if color is not None:
			plt.plot(xdata, ydata, '-', color=color, linewidth=self.linewidth)
		else:
			plt.plot(xdata, ydata, linewidth=self.linewidth)
		plt.title(title, fontsize=self.font_title, y=1.03)
		plt.tick_params(labelsize=self.font_labeltick)
		plt.xlabel(xlabel, fontsize=self.font_label)
		plt.ylabel(ylabel, fontsize=self.font_label)
		#plt.plot(xdata, ydata, linewidth=self.linewidth)
		plt.grid(True)
		pass

	def single_graph(self, xdata, ydata, title, xlabel, ylabel, width, height, filename, stress=False):
		plt.figure(1, figsize=(width/100, height/100))
		self.__do_plot(xdata, ydata, title, xlabel, ylabel, stress)
		plt.savefig(filename)
		plt.clf()
		plt.close()
		pass

	def multi_data_graph(self, xdata, ydata, supertitle, titles, xlabel, ylabel, width, height, filename, stress=False):
		width = int(width / 100)
		height = int(height / 100)

		plots = len(ydata)  # number of total plots
		size = int(math.sqrt(plots))
		if (size * size) < plots:
			size += 1
		if size > 5: size = 5

		# drawing plots cutting by 25
		part = 1
		start = 0
		while start < plots:
			plt.figure(1, figsize=(width*size, height*size))

			for idx in range(0, 25):
				if idx+start+1 > len(ydata): break
				plt.subplot(size, size, idx+1)
				ytitle = ylabel[idx+start] if isinstance(ylabel, list) else ylabel
				self.__do_plot(xdata, ydata[idx+start], titles[idx+start], xlabel, ytitle, stress)
				plt.subplots_adjust(hspace=0.3)

			plt.suptitle(supertitle, fontsize=self.font_supertitle)
			if plots <= 25:
				plt.savefig(filename)
			else:
				plt.savefig(filename[:-4]+'_part%d'%part+filename[-4:])
			plt.clf()
			plt.close()

			start += 25
			part += 1
		pass

	###############################################################
	# Draw Scatter
	###############################################################
	def __get_max(self, _items):
		ymax = _items[0]
		for item in _items:
			if item < ymax: continue
			ymax = item

		if ymax == 0:
			return 1.0
		inc = ymax * 1.1
		if inc>=1.0:
			return 1.0
		return inc

	def __get_max_int(self, _items):
		ymax = _items[0]
		for item in _items:
			if item < ymax: continue
			ymax = item

		if ymax == 0:
			return 5
		return int(ymax + 1.2)

	def __do_scatter(self, title, xdata, ydata, xlabel, ylabel, isTasks=False, isDetail=False, text=[], maxSet=False):
		plt.scatter(xdata, ydata, s=[2]*len(ydata), alpha=0.5, linewidth=self.linewidth)
		plt.title(title, fontsize=self.font_title, y=1.03)
		plt.tick_params(labelsize=self.font_labeltick)
		plt.xlabel(xlabel, fontsize=self.font_label)
		plt.ylabel(ylabel, fontsize=self.font_label)
		if isTasks is True:
			plt.tick_params(labelsize=self.font_labeltick*0.7)
			# plt.margins(x=0, y=-2)   # Values in (-0.5, 0.0) zooms in to center
			plt.yticks([x for x in range(1,len(common.TASK_INFO)+1,1)], [common.TASK_INFO[x] for x in range(1,len(common.TASK_INFO)+1,1)])

		if isDetail is True:
			plt.tick_params(labelsize=self.font_labeltick*0.7)
			plt.xticks([x for x in range(0,21,1)], ['%d'%x for x in range(0,21,1)])

		for txt, x, y in text:
			plt.text(x,y,txt, bbox=dict(facecolor='red', alpha=0.4))

		if maxSet is True:
			ymax = self.__get_max(ydata)
			plt.axis(ymin=0, ymax=ymax)

		plt.grid(True)
		pass

	def scatter_graph(self, xdata, ydata, title, xlabel, ylabel, width, height, filename, isTasks=False, isDetail=False, text=[], maxSet=False):
		plt.figure(1, figsize=(width/100, height/100))
		self.__do_scatter(title, xdata, ydata, xlabel, ylabel, isTasks, isDetail, text, maxSet)
		if filename is not None:
			plt.savefig(filename)
		else:
			plt.show()
		plt.clf()
		plt.close()
		pass

	def scatter_graph_multi(self, xdata, ydata, supertitle, titles, xlabel, ylabel, width, height, filename, maxSet=True):
		width = int(width / 100)
		height = int(height / 100)

		plots = len(ydata)  # number of total plots
		size = int(math.sqrt(plots))
		if (size * size) < plots:
			size += 1
		if size > 5: size = 5

		# drawing plots cutting by 25
		part = 1
		start = 0
		partition = False if plots < 25 else True
		while start < plots:
			plt.figure(1, figsize=(width*size, height*size))
			for idx in range(0, 25):
				if idx+start+1 > len(ydata): break
				plt.subplot(size, size, idx+1)
				self.__do_scatter(titles[idx+start], xdata[idx+start], ydata[idx+start], xlabel, ylabel, maxSet=True)
				plt.subplots_adjust(hspace=0.3)

			plt.suptitle(supertitle, fontsize=self.font_supertitle)
			if filename is not None:
				if partition is True:
					plt.savefig(filename[:-4]+'_part%d'%part+filename[-4:])
				else:
					plt.savefig(filename)
			else:
				plt.show()
			plt.clf()
			plt.close()

			start += 25
			part += 1
		pass


	###############################################################
	# Draw Histogram
	###############################################################
	def __get_max_fromRect(self, _data):
		ymax=int(_data[0]._height)
		for item in _data:
			if ymax > item._height: continue
			ymax = int(item._height)

		if ymax==0:
			return 5
		return int(ymax*1.2)

	def __do_histogram(self, title, data, xlabel, ylabel):
		n, bins, patches = plt.hist(data, bins=100, facecolor='g', alpha=0.75)
		ymax=self.__get_max_fromRect(patches)
		plt.title(title, fontsize=self.font_title, y=1.03)
		plt.tick_params(labelsize=self.font_labeltick)
		plt.xlabel(xlabel, fontsize=self.font_label)
		plt.ylabel(ylabel, fontsize=self.font_label)
		plt.yscale('log', nonposy='clip')
		plt.axis(ymin=0, ymax=ymax)
		plt.grid(True)
		pass

	def histogram(self, data, title, xlabel, ylabel, width, height, filename):
		plt.figure(1, figsize=(width/100, height/100))
		self.__do_histogram(title, data, xlabel, ylabel)
		if filename is not None:
			plt.savefig(filename)
		else:
			plt.show()
		plt.clf()
		plt.close()
		pass

	def histogram_multi(self, data, supertitle, titles, xlabel, ylabel, width, height, filename=None):
		width = int(width / 100)
		height = int(height / 100)

		plots = len(data)  # number of total plots
		size = int(math.sqrt(plots))
		if (size * size) < plots:
			size += 1
		if size > 5: size = 5

		# drawing plots cutting by 25
		part = 1
		start = 0
		while start < plots:
			plt.figure(1, figsize=(width*size, height*size))

			for idx in range(0, 25):
				if idx+start+1 > len(data): break
				plt.subplot(size, size, idx+1)
				self.__do_histogram(titles[idx+start], data[idx+start], xlabel, ylabel)
				plt.subplots_adjust(hspace=0.3)

			plt.suptitle(supertitle, fontsize=self.font_supertitle)
			if filename is not None:
				plt.savefig(filename[:-4]+'_part%d'%part+filename[-4:])
			else:
				plt.show()
			plt.clf()
			plt.close()

			start += 25
			part += 1
		pass

	def __do_boxplot(self, title, data, xlabel, ylabel, _ticklabel=None):
		fig, ax1 = plt.subplots(figsize=(10, 6))
		# fig.canvas.set_window_title('A Boxplot Example')
		fig.subplots_adjust(left=0.12, right=0.95, top=0.9, bottom=0.15)

		ax1.boxplot(data)

		plt.title(title, fontsize=self.font_title, y=1.03)
		plt.tick_params(labelsize=self.font_labeltick)
		if _ticklabel is not None:
			ax1.set_xticklabels(_ticklabel, rotation=45, fontsize=8)
		else:
			plt.xlabel(xlabel, fontsize=self.font_label)
		plt.ylabel(ylabel, fontsize=self.font_label)

		#plt.yscale('log', nonposy='clip')
		#plt.axis(ymin=0, ymax=ymax)
		plt.grid(True)
		pass

	def boxplots(self, data, _ticklabel, title, xlabel, ylabel, width, height, filename):
		plt.figure(1, figsize=(width/100, height/100))
		self.__do_boxplot(title, data, xlabel, ylabel, _ticklabel)
		if filename is not None:
			plt.savefig(filename)
		else:
			plt.show()
		plt.clf()
		plt.close()
		pass

	def __do_barchart(self, _title, _data, _ticklabel, xlabel, ylabel):
		index = np.arange(len(_ticklabel))
		bar_width = 0.4

		plt.bar(index, _data, bar_width, align='center', alpha=0.5, linewidth=self.linewidth)
		plt.title(_title, fontsize=self.font_title, y=1.03)
		plt.tick_params(labelsize=self.font_labeltick*0.7)
		plt.xticks(index, _ticklabel)
		plt.xlabel(xlabel, fontsize=self.font_label)
		plt.ylabel(ylabel, fontsize=self.font_label)
		#plt.grid(True)
		pass

	def barchart(self, _data, _ticklabel, title, _xlabel, _ylabel, _width, _height, filename):
		plt.figure(1, figsize=(_width / 100, _height / 100))
		self.__do_barchart(title, _data, _ticklabel, _xlabel, _ylabel,)
		if filename is not None:
			plt.savefig(filename)
		else:
			plt.show()
		plt.clf()
		plt.close()


if __name__ == "__main__":
	drawer = Drawer()
	drawer.scatter_graph([1,1,2,2,3,3,4,4,5,5,6,6,6,6], [0,2,0,2,0,2,0,2,0,2,0,2,3,4],
						 'Test', 'Generation', 'Number of best(e-d)', 800, 600, 'x')
