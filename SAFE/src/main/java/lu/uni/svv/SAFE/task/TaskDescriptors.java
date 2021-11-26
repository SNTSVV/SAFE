package lu.uni.svv.SAFE.task;

import lu.uni.svv.SAFE.Settings;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class TaskDescriptors {
	/* **********************************************************
	 *  Functions to deal with multiple task descriptions
	 */
	/**
	 * copy an array of task descriptors
	 * @param _tasks
	 * @return
	 */
	public static TaskDescriptor[] copyArray(TaskDescriptor[] _tasks){
		TaskDescriptor[] tasks = new TaskDescriptor[_tasks.length];
		for (int i=0; i< _tasks.length; i++){
			tasks[i] = _tasks[i].copy();
		}
		return tasks;
	}

	/**
	 * verify tasks
	 * @return
	 * @throws NumberFormatException
	 * @throws IOException
	 */
	public static void verifyTasks(TaskDescriptor[] input) throws Exception {
		
		for(TaskDescriptor task:input){
			if (task.WCET == 0) throw new Exception(String.format("Task %s does not have WCET value, Please check the input file or time quanta ", task.Name));
		}
	}
	

	/**
	 * Generates masks for each task that is not arrived by its period due to the triggering tasks
	 * @param _tasks
	 * @return
	 */
	public static boolean[] getArrivalExceptionTasks(TaskDescriptor[] _tasks){
		boolean[] list = new boolean[_tasks.length+1];
		for(int taskID=0; taskID<_tasks.length; taskID++){
			for(int i=0; i<_tasks[taskID].Triggers.length; i++){
				list[_tasks[taskID].Triggers[i]] = true;
			}
		}
		return list;
	}
	
	/**
	 * Finds the maximum number of resources from task descriptions
	 * @param _tasks
	 * @return
	 */
	public static int getMaxNumResources(TaskDescriptor[] _tasks){
		// find max number of resources;
		int maxResource = 0;
		for (int tIDX=0; tIDX<_tasks.length; tIDX++) {
			for (int r=0; r<_tasks[tIDX].Dependencies.length; r++){
				if (_tasks[tIDX].Dependencies[r] > maxResource)
					maxResource = _tasks[tIDX].Dependencies[r];
			}
		}
		return maxResource;
	}
	
	
	/**
	 * Get aperiodic tasks which inter-arrival times are different
	 * @return
	 */
	public static List<Integer> getVaryingTasksIdx(TaskDescriptor[] _tasks){
		List<Integer> list = new ArrayList<Integer>();
		
		for(int x=0; x< _tasks.length; x++){
			if (_tasks[x].Type != TaskType.Periodic && _tasks[x].MinIA != _tasks[x].MaxIA)
				list.add(x);
		}
//		for(TaskDescriptor task : _tasks){
//			if (task.Type != TaskType.Periodic && task.MinIA != task.MaxIA)
//				list.add(task.ID);
//		}
		return list;
	}
	
	/**
	 * Get a number of aperiodic tasks
	 * @return
	 */
	public static int getNumberOfAperiodics(TaskDescriptor[] _tasks){
		int count=0;
		for (TaskDescriptor task:_tasks){
			if (task.Type == TaskType.Aperiodic)
				count+=1;
		}
		return count;
	}
	
	/**
	 * Find maximum deadline among an array of task descriptors
	 * @param _tasks
	 * @return
	 */
	public static int findMaximumDeadline(TaskDescriptor[] _tasks){
		int max_dealine=0;
		for (TaskDescriptor task:_tasks){
			if (task.Deadline> max_dealine)
				max_dealine = task.Deadline;
		}
		return max_dealine;
	}
	
	/**
	 * Get minimim fitness value (not exact)
	 * @param _tasks
	 * @param simulationTime
	 * @return
	 */
	public static double getMinFitness(TaskDescriptor[]  _tasks, long simulationTime){
		double fitness = 0.0;
		for (TaskDescriptor task: _tasks){
			int period = (task.Type== TaskType.Periodic)?task.Period:task.MaxIA;
			int nArrivals = (int)Math.ceil(simulationTime / (double)period);
			int diff = task.WCET - task.Deadline;
			fitness += Math.pow(Settings.FD_BASE, diff/Settings.FD_EXPONENT) * nArrivals;
		}
		return fitness;
	}
	
	/**
	 * Get maximum fitness value order by deadline and calculate cumulated WCET
	 * This assumes the maximum fitness value (not exact)
	 * @param _tasks
	 * @param simulationTime
	 * @return
	 */
	public static double getMaxFitness(TaskDescriptor[] _tasks, long simulationTime){
		TaskDescriptor[] tasks = TaskDescriptors.copyArray(_tasks);
		Arrays.sort(tasks,TaskDescriptor.deadlineComparator);
		
		double fitness = 0.0;
		int WCET = 0;
		for (TaskDescriptor task: tasks){
			int period = (task.Type == TaskType.Periodic)?task.Period:task.MinIA;
			int nArrivals = (int)Math.ceil(simulationTime / (double)period);
			WCET = WCET + task.MaxWCET;
			int diff = WCET - task.Deadline;
			double fitItem = Math.pow(Settings.FD_BASE, diff/Settings.FD_EXPONENT);
			if (fitItem == Double.NEGATIVE_INFINITY) fitItem = 0;
			if (fitItem == Double.POSITIVE_INFINITY) fitItem = Double.MAX_VALUE;
			fitness += fitItem * nArrivals;
		}
		return fitness;
	}
	

	///////////////////////////////////////////////////////////////////////////////////////////////////
	// Loading function from CSV file and auxiliary functions
	///////////////////////////////////////////////////////////////////////////////////////////////////
	/**
	 * load from CSV file  (Time unit is TIME_QUANTA )
	 * @param _filepath
	 * @param _maximumTime
	 * @param _timeQuanta
	 * @return
	 * @throws NumberFormatException
	 * @throws IOException
	 */
	public static TaskDescriptor[] loadFromCSV(String _filepath, double _maximumTime, double _timeQuanta) throws Exception {
		List<TaskDescriptor> listJobs = new ArrayList<>();
		
		File file = new File(_filepath);
		
		BufferedReader br = new BufferedReader(new FileReader(file));
		
		long lineCnt=0;
		String data;
		while ((data = br.readLine()) != null) {
			lineCnt++;
			if (lineCnt==1) continue;   // Remove CSV file header
			if (data.trim().length()==0) continue;
			
			String[] cols = data.split(",");
			
			TaskDescriptor aJob = new TaskDescriptor();
			aJob.Name 		= value(cols[1]);	// Name
			aJob.Type 		= getTypeFromString(value(cols[2]));
			aJob.Priority 	= getValueFromString(value(cols[3]), 10000);
			aJob.Offset     = getTimeFromString(value(cols[4]), 0, _maximumTime, _timeQuanta);
			aJob.WCET 	    = getTimeFromString(value(cols[5]), 0, _maximumTime, _timeQuanta);
			aJob.MaxWCET 	= getTimeFromString(value(cols[6]), 0, _maximumTime,_timeQuanta);
			aJob.Period 	= getTimeFromString(value(cols[7]), _maximumTime, _maximumTime, _timeQuanta);
			aJob.MinIA 		= getTimeFromString(value(cols[8]), 0, _maximumTime,_timeQuanta);
			aJob.MaxIA		= getTimeFromString(value(cols[9]), _maximumTime, _maximumTime, _timeQuanta);
			aJob.Deadline 	= getTimeFromString(value(cols[10]), _maximumTime, _maximumTime, _timeQuanta);
			aJob.Severity 	= getSeverityFromString(value(cols[11]));	// Severity type
			if (cols.length>12) {
				aJob.Dependencies = getListFromString(value(cols[12]));
			}
			if (cols.length>13) {
				aJob.Triggers 	= getListFromString(value(cols[13]));
			}
			
			listJobs.add(aJob);
		}
		// after loop, close reader
		br.close();
		
		// Return loaded data
		TaskDescriptor[] tasks = new TaskDescriptor[listJobs.size()];
		listJobs.toArray(tasks);
		TaskDescriptors.verifyTasks(tasks);
		
		return tasks;
	}

	public static String value(String _text){
		_text = _text.trim();
		if (_text.startsWith("\"")){
			_text = _text.substring(1, _text.length()-1);
			_text = _text.trim();
		}
		if (_text.compareTo("NA")==0){
			_text = "";
		}
		return _text;
	}
	
	public static TaskType getTypeFromString(String _text) {
		
		if (_text.toLowerCase().compareTo("sporadic")==0)
			return TaskType.Sporadic;
		else if (_text.toLowerCase().compareTo("aperiodic")==0)
			return TaskType.Aperiodic;
		else
			return TaskType.Periodic;
	}
	
	public static TaskSeverity getSeverityFromString(String _text) {
		
		if (_text.toLowerCase().compareTo("soft")==0)
			return TaskSeverity.SOFT;
		else
			return TaskSeverity.HARD;
	}
	
	public static int getValueFromString(String _text, int _default) {
		
		if (_text.compareTo("")==0 || _text.compareTo("N/A")==0)
			return _default;
		else
			return (int)(Double.parseDouble(_text));
	}
	
	public static int getTimeFromString(String _text, double _default, double _max, double _timeQuanta) {
		double value = 0.0;
		if (_text.compareTo("")==0 || _text.compareTo("N/A")==0)
			value = _default;
		else {
			value = Double.parseDouble(_text);
			if (_max !=0 && value > _max) value =  _max;
		}
		return (int)(value * (1 / _timeQuanta));
	}
	
	public static int[] getListFromString(String _text) {
		String[] texts = _text.split(";");
		int[] items = new int[texts.length];
		int cnt=0;
		for ( int i=0; i< texts.length; i++){
			texts[i] = texts[i].trim();
			if(texts[i].length()==0) continue;
			items[i] =  Integer.parseInt(texts[i]);
			cnt++;
		}
		
		if (cnt==0){
			return new int[0];
		}
		return items;
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////
	// Storing list to CSV file and auxiliary functions
	///////////////////////////////////////////////////////////////////////////////////////////////////
	/**
	 * converting to string to store an array of task descriptors
	 * @param _tasks
	 * @param _timeQuanta
	 * @return
	 */
	public static String convertToCSV(TaskDescriptor[] _tasks, double _timeQuanta){
		StringBuilder sb = new StringBuilder();
		
		sb.append("Task ID, Task Name,Task Type,Task Priority,Offset,WCET min,WCET max,Task Period (ms),Minimum interarrival-time (ms),Maximum Interarrival time,Task Deadline, Deadline Type, Dependencies, Triggers\n");
		for(TaskDescriptor task:_tasks)
		{
			sb.append(String.format("%d,\"%s\",%s,%d,%f,%f,%f,%f",
					task.ID,
					task.Name, task.Type.toString(), task.Priority, task.Offset* _timeQuanta,
					task.WCET * _timeQuanta, task.MaxWCET* _timeQuanta,
					task.Period * _timeQuanta));
			
			if (task.Type==TaskType.Periodic) {
				sb.append(",,");
			}
			else{
				sb.append(String.format(",%f,%f", task.MinIA* _timeQuanta, task.MaxIA* _timeQuanta));
			}
			sb.append(String.format(",%f,%s,%s,%s\n",
					task.Deadline* _timeQuanta, task.Severity,
					listToString(task.Dependencies), listToString(task.Triggers)));
		}
		return sb.toString();
	}
	/**
	 * Convert list to string with ';' delimiter
	 * This function is for the dependency and triggering list
	 * @param _items
	 * @return
	 */
	public static String listToString(int[] _items){
		StringBuilder sb = new StringBuilder();
		for (int x=0; x<_items.length; x++){
			if (x!=0) sb.append(';');
			sb.append(_items[x]);
		}
		return sb.toString();
	}
	
	
	///////////////////////////////////////////////////////////////////////////////////////////////////
	// get List of Priorities form TaskDescriptor[]
	///////////////////////////////////////////////////////////////////////////////////////////////////
	/**
	 * generate initial priorities from input
	 * the order of priorities following task IDs
	 * @param input
	 * @return
	 */
	public static Integer[] getPriorities(TaskDescriptor[] input) {
		Integer[] priorities = new Integer[input.length];
		int[] assigned = new int[input.length];
		Arrays.fill(assigned, 0);
		
		// assign priority level (from highest to lowest)
		for(int priority=input.length-1; priority>=0;priority--) {
			int maxTaskIdx = 0;
			int maxPriority = -1;
			for (int x = 0; x < input.length; x++) {
				if (assigned[x]==1) continue;
				
				if (input[x].Priority > maxPriority) {
					maxTaskIdx = x;
					maxPriority = input[x].Priority;
				}
			}
			
			priorities[maxTaskIdx] = priority;
			assigned[maxTaskIdx]=1;
		}
		
		return priorities;
	}
}
