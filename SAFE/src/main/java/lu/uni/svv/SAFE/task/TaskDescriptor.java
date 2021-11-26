package lu.uni.svv.SAFE.task;

import java.util.Arrays;
import java.util.Comparator;


public class TaskDescriptor implements Comparable<TaskDescriptor>{
	
	public static int UNIQUE_ID = 1;
	public int		ID;			// The sequence of input data (main key for ordering)
	public String	Name;		// Task Name
	public TaskType Type;		// Task type {Periodic, Aperiodic, Sporadic}
	public int      Offset;		// first execution time of a periodic task
	public int		WCET;	    // Worst case execution time
	public int		MaxWCET;	// Worst case execution time can be extended
	public int		Period;		// Time period which a task occurs, This variable is for the Periodic task
	public int 	    MinIA;		// Minimum inter-arrival time,This variable is for Aperiodic or Sporadic Task
	public int		MaxIA;		// Maximum inter-arrival time, This variable is for Aperiodic or Sporadic Task
	public int		Deadline;	// Time period which a task should be finished
	public int		Priority;	// Fixed Priority read from input data
	public TaskSeverity	Severity;	// {Hard, Soft}
	public int[]    Dependencies;	// List of resource numbers that this task depends on
	public int[]    Triggers;	    // List of task IDs that this task will trigger
	
	
	/**
	 * Create object without paramter
	 */
	public TaskDescriptor() {
		ID = TaskDescriptor.UNIQUE_ID++;
		Name 		= "";
		Type 		= TaskType.Periodic;
		Offset 	    = 0;
		WCET 	    = 0;
		MaxWCET     = 0;
		Period  	= 0;
		MinIA		= 0;
		MaxIA  		= 0;
		Deadline 	= 0;
		Priority 	= 0;
		Severity    = TaskSeverity.HARD;
		Dependencies= new int[0];
		Triggers    = new int[0];
	}
	
	/**
	 * Create object for copy
	 */
	public TaskDescriptor(TaskDescriptor _task) {
		ID          = _task.ID;
		Name 		= _task.Name;
		Type 		= _task.Type;
		Offset 	    = _task.Offset;
		WCET 	    = _task.WCET;
		MaxWCET 	= _task.MaxWCET;
		Period  	= _task.Period;
		MinIA		= _task.MinIA;
		MaxIA  		= _task.MaxIA;
		Deadline 	= _task.Deadline;
		Priority 	= _task.Priority;
		Severity    = _task.Severity;
		
		Dependencies= Arrays.copyOf(_task.Dependencies, _task.Dependencies.length);
		Triggers    = Arrays.copyOf(_task.Triggers, _task.Triggers.length);
	}

	public TaskDescriptor copy(){
		return new TaskDescriptor(this);
	}
	
	@Override
	public String toString(){
		String period = String.format("%d", Period);
		if (Type != TaskType.Periodic){
			period = String.format("[%d-%d]", MinIA, MaxIA);
		}
		String wcet = String.format("%d", WCET);
		if (WCET!=MaxWCET){
			wcet = String.format("[%d-%d]", WCET, MaxWCET);
		}
		return String.format("%s: {ID: %d, type:%s, priority:%d, period:%s, wcet:%s}, deadline:%d", Name, ID, Type, Priority, period, wcet, Deadline);
	}
	/* ********************************************************************
		Comparator
	 */
	@Override
	public int compareTo(TaskDescriptor _o) {
		if ((this.Period - _o.Period) > 0)
			return 1;
		else 
			return -1;
	}
	
	public static Comparator<TaskDescriptor> PriorityComparator = new Comparator<TaskDescriptor>() {
		@Override
		public int compare(TaskDescriptor _o1, TaskDescriptor _o2) {
			return _o2.Priority - _o1.Priority;
		}
	};
	
	public static Comparator<TaskDescriptor> PeriodComparator = new Comparator<TaskDescriptor>() {
		@Override
		public int compare(TaskDescriptor _o1, TaskDescriptor _o2) {
			return _o1.Period - _o2.Period;
		}
	};
	
	public static Comparator<TaskDescriptor> OrderComparator = new Comparator<TaskDescriptor>() {
		@Override
		public int compare(TaskDescriptor _o1, TaskDescriptor _o2) {
			return _o1.ID - _o2.ID;
		}
	};
	
	/**
	 * This comparator is for the assuming maximum fitness value
	 */
	public static Comparator<TaskDescriptor> deadlineComparator = new Comparator<TaskDescriptor>() {
		@Override
		public int compare(TaskDescriptor o1, TaskDescriptor o2) {
			int diff = o2.Deadline - o1.Deadline;
			if (diff==0){
				diff = ((o2.Type==TaskType.Periodic)?o2.Period:o2.MinIA);
				diff -= ((o1.Type==TaskType.Periodic)?o1.Period:o1.MinIA);
				if (diff == 0){
					diff = o2.MaxWCET - o1.MaxWCET;
				}
			}
			return diff;
		}
	};
}