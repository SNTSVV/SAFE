package lu.uni.svv.SAFE.scheduler;

import lu.uni.svv.SAFE.task.Arrivals;
import lu.uni.svv.SAFE.task.TaskDescriptor;
import lu.uni.svv.SAFE.task.TaskDescriptors;
import lu.uni.svv.SAFE.Settings;

import java.util.ArrayList;
import java.util.HashSet;

/**
 * Scheduling Policy
 * 	- Fixed-priority preemptive scheduling policy
 * 	- The two task has same priority, first arrived execution in the ready queue has higher priority to use CPU.
 *  -   In the other words, the execution that is arrived lately couldn't preempt the other executions already arrived in the ready queue.
 *
 * Deadline misses detection
 * 	- We count the number of deadline misses while the scheduling(by SIMULATION_TIME)
 * 	- And, if the ready queue has tasks after being done scheduling(after SIMULATION_TIME),
 * 			we will execute this scheduler by finishQuing all tasks in the ready queue.
 * @author jaekwon.lee
 *
 */
public class ScheduleVerify {
	enum Type{IDLE, READY, PREEMPTED, BLOCKED, RUNNINNG, MISSED};
	class Slot{
		Type type;
		int CPUID;
		public Slot(){
			type = Type.IDLE;
			CPUID = -1;
		}
		public Slot(Type _type){
			type = _type;
			CPUID = -1;
		}
		public Slot(Type _type, int _cpuID){
			type = _type;
			CPUID = _cpuID;
		}
		public void update(Type _type, int _cpuID){
			type = _type;
			CPUID = _cpuID;
		}
	}
	
	protected Schedule[][]          schedules;
	protected TaskDescriptor[]      Tasks;
	protected int                   MaxTime;
	protected Integer[]             priorities;
	protected Slot[][]               timelines;
	protected Arrivals[]            arrivals;
	protected int[]                 WCETs = null;
	protected double                timeQuanta;
	
	public ScheduleVerify(Schedule[][] _schedules, TaskDescriptor[] _tasks, double _timeQuanta, Integer[] _priorities)
	{
		this(_schedules, _tasks, _timeQuanta, _priorities, null, null);
	}
	
	public ScheduleVerify(Schedule[][] _schedules, TaskDescriptor[] _tasks,  double _timeQuanta, Integer[] _priorities, Arrivals[] _arrivals, int[] _WCETsamples)
	{
		schedules = _schedules;
		Tasks = _tasks;
		MaxTime = getMaximumExecutionTime();
		priorities = _priorities;
		arrivals = _arrivals;
		timeQuanta = _timeQuanta;
		WCETs = _WCETsamples;
		
		generateTimelines();
	}

	protected int getMaximumExecutionTime(){
		int max = 0;
		for(int x=0; x<schedules.length; x++){
			int idx = schedules[x].length-1;
			int val = schedules[x][idx].finishedTime;
			if(max<val) max = val;
		}
		return max;
	}
	
	/**
	 * generate timelines  (-2: ready state, -1: preempted,  0: Idle, N: Running (cpu number) )
	 */
	protected void generateTimelines(){
		// generate timelines
		timelines = new Slot[schedules.length][];
		for (int taskID=0; taskID<schedules.length; taskID++){
			timelines[taskID] = new Slot[MaxTime];
			for (int slot=0; slot<MaxTime; slot++){
				timelines[taskID][slot] = new Slot();
			}
		}
		
		// set ready state of task
		for (int taskID=0; taskID<schedules.length; taskID++) {
			for (int exID = 0; exID < schedules[taskID].length; exID++) {
				Schedule schedule = schedules[taskID][exID];
				for (int t = schedule.arrivalTime; t < schedule.finishedTime; t++) {
					timelines[taskID][t].type = Type.READY;
				}
			}
		}
		
		// set activated time of a task execution
		for (int taskID=0; taskID<schedules.length; taskID++) {
			for (int exID = 0; exID < schedules[taskID].length; exID++) {
				Schedule schedule = schedules[taskID][exID];
				int deadline = schedule.deadline;
				
				for(int a=0; a<schedule.activatedNum; a++){
					int start = schedule.startTime.get(a);
					int end = schedule.endTime.get(a);
					int CPU = schedule.CPUs.get(a);
					
					for(int t=start; t<end; t++) {
						if (CPU==-1)         timelines[taskID][t].type = Type.PREEMPTED;
						else if (t>deadline) timelines[taskID][t].update(Type.MISSED, CPU+1);
						else                 timelines[taskID][t].update(Type.RUNNINNG, CPU+1);
					}
					
				}
			}
		}
	}
	
	protected int[] getTaskIDsByPriority(){
		int[] taskIDs = new int[timelines.length];
		
		int x = 0;
		int max = priorities.length-1; // get maximum value
		for(int maxPriority=max; maxPriority>=0; maxPriority--){
			// find max priority idx
			int taskID = -1;
			int localMax = -1;  // higher value th
			for (int p = 0; p < priorities.length; p++) {
				if (priorities[p]>maxPriority) continue;
				if (priorities[p]<localMax) continue;
				localMax = priorities[p];
				taskID = p;
			}
			taskIDs[x++] = taskID;
		}
		return taskIDs;
	}
	
	private String getHeaderTimeline(int timeLen, int period){
		StringBuilder sb = new StringBuilder("           Timeline #");
		for (int t = 0; t < timelines[0].length; t++) {
			if (t%timeLen!=0) {
				sb.append(" ");
				continue;
			}
			if (t!=0){
				for(int x=0; x<period-1; x++){ sb.append(" ");}
				sb.append("|");
			}
			String s = String.format("%.2fms", t*timeQuanta);
			sb.append(s);
			t += s.length()-1;
		}
		return sb.toString();
	}
	private String getATimeline(int _taskID, int _splitLen, String _prefix){
		StringBuilder sb = new StringBuilder(_prefix);
		for (int t = 0; t < timelines[_taskID].length; t++) {
			Slot aSlot = timelines[_taskID][t];
			if (t!=0 && t%_splitLen==0)
				sb.append("|");
			if (aSlot.type==Type.IDLE) // idle
				sb.append("-");
			else if (aSlot.type==Type.READY) // ready
				sb.append("+");
			else if (aSlot.type==Type.PREEMPTED) // preempted, blocked
				sb.append("*");
			else if (aSlot.type==Type.RUNNINNG)
				sb.append((char)Character.toUpperCase(65+aSlot.CPUID-1));
			
			else
				sb.append((char)Character.toLowerCase(65+aSlot.CPUID-1));
		}
		return sb.toString();
	}
	private String getInfoText() {
		StringBuilder sb = new StringBuilder();
		sb.append("WCETs = [");
		if (WCETs == null) {
			for (int x = 0; x < Tasks.length; x++) {
				sb.append(String.format("%.2f", Tasks[x].WCET*timeQuanta));
				sb.append(", ");
			}
			sb.append("]");
		}
		else {
			for (int x = 0; x < WCETs.length; x++) {
				sb.append(String.format("%.2f", WCETs[x]*timeQuanta));
				sb.append(", ");
			}
		}
		sb.append("]");
		return sb.toString();
	}
	public void printTimelines(){
		int splitLen = 10;
		int period = 5;
		System.out.println(getInfoText());
		System.out.println("###########################");
		System.out.println(getHeaderTimeline(period * splitLen, period));
		int[] tasksIDs = getTaskIDsByPriority();
		for (int taskID : tasksIDs){ //int taskID=0; taskID<tasksIDs.length; taskID++) {
			String name = (Tasks[taskID].Name.length()>10)?Tasks[taskID].Name.substring(0, 10): Tasks[taskID].Name;
			String prefix = String.format("T%02d:%10s (%2d) #",taskID+1, name, priorities[taskID]);
			String line = getATimeline(taskID, splitLen, prefix);
			System.out.println(line);
		}
		System.out.println("###########################");
	}

	/////////////////////////////////////////////////////////////////
	// Verification 6 steps
	/////////////////////////////////////////////////////////////////
	/**
	 * initialize scheduler
	 */
	public boolean verify(){
		try {
			verifyArrivalTime();
			verifyStartTime();
			verifyExecutionTime();
			verifyBlocking();
			verifyCPUExecution();
			// verifyTriggers();
		}
		catch(AssertionError | Exception e){
			System.out.println(e.getMessage());
		}
		return true;
	}
	
	/**
	 * Task arrivals verification
	 * @return
	 */
	public boolean verifyArrivalTime() {
		if (arrivals==null) return true;
		
		// to except for triggered tasks.
		boolean[] exceptions = TaskDescriptors.getArrivalExceptionTasks(Tasks);
		
		for(int tIDX=0; tIDX<schedules.length; tIDX++){
			if(exceptions[tIDX+1]) continue;
			
			if (schedules[tIDX].length!=arrivals[tIDX].size()){
				throw new AssertionError("Error to verify the number of executions on task " + (tIDX+1));
			}
			for(int e=0; e< schedules[tIDX].length; e++){
				if (schedules[tIDX][e].arrivalTime != arrivals[tIDX].get(e)){
					throw new AssertionError("Error to verify arrival time on " + (e+1) + " execution of task " + (tIDX+1));
				}
			}
		}
		return true;
	}
	
	/**
	 * Tasks which are higher priority than running tasks should be the blocked or running state
	 * When a task is in the ready state, only higher priority tasks then the task should be running.
	 * [Deprecated]
	 * @return
	 */
	public boolean verifyStartTime2() {
		
		for (int x = 0; x < timelines.length; x++) {
			ArrayList<Integer> list = getHigherPriorityTaskIdxs(Tasks[x].ID - 1);
			if (list.size() == 0) {
				for (int t = 0; t < timelines[x].length; t++) {
					if (timelines[x][t].type == Type.READY) return false;
				}
			} else {
				for (int t = 0; t < timelines[x].length; t++) {
					if (timelines[x][t].CPUID >= 0) continue;
					
					for (int taskIdx : list) {
						if (timelines[taskIdx][t].type == Type.READY) return false;  // if the higher priority tasks is ready state
					}
				}
			}
		}
		return true;
	}
	
	/**
	 * When a task is in the ready state, only higher priority tasks then the task should be running.
	 * @return
	 */
	public boolean verifyStartTime() throws Exception{
		// timeline
		ArrayList<Integer> list = new ArrayList<>();
		for (int t = 0; t < MaxTime; t++) {
			list.clear();
			
			int maxPriority = -1;
			for (int tIdx = 0; tIdx < timelines.length; tIdx++) {
				if(timelines[tIdx][t].type == Type.READY){  // get max priority task among READY state tasks
					if (priorities[tIdx]>maxPriority) maxPriority = priorities[tIdx];
				}
				else if(timelines[tIdx][t].CPUID >= 0){   // get a list of executing tasks
					list.add(priorities[tIdx]);
				}
			}
			if (maxPriority == -1) continue;  // if there is no READY tasks, no need to check
			
			for(int priority:list) {
				if (priority < maxPriority)  // if the READY task is higher priority than currently executing tasks,
					throw new AssertionError("Error to verify start time at "+t+" time.");
			}
		}
		
		return true;
	}
	
	
	protected ArrayList<Integer> getHigherPriorityTaskIdxs(int taskIdx){
		ArrayList<Integer> list = new ArrayList<>();
		int priorityT = priorities[taskIdx];
		for (int x=0; x<priorities.length; x++){
			if (priorities[x]<priorityT) list.add(x);
		}
		return list;
	}
	
	
	/**
	 * All task executions have the same execution time of their WCET
	 * @return
	 */
	public boolean verifyExecutionTime(){
		for (int x=0; x<schedules.length; x++) {
			for (int i = 0; i < schedules[x].length; i++) {
				if (WCETs==null) {
					if (Tasks[x].WCET != schedules[x][i].executedTime)
						throw new AssertionError("Error to verify execution time");
				}
				else {
					if (WCETs[x] != schedules[x][i].executedTime)
						throw new AssertionError("Error to verify execution time");
				}
			}
		}
		return true;
	}
	
	/**
	 * Tasks are depends each other should not be executed at the same time unit
	 *
	 * @return
	 */
	public boolean verifyBlocking(){
		// find max number of resources;
		int maxResource = TaskDescriptors.getMaxNumResources(Tasks);
		
		// build resource relationship matrix by task index
		// Resource 1  => B, C
		// Resource 2  => A, D
		HashSet<Integer>[] resources = new HashSet[maxResource];
		for (int tIDX=0; tIDX<Tasks.length; tIDX++) {
			for (int d=0; d<Tasks[tIDX].Dependencies.length; d++){
				int rIDX = Tasks[tIDX].Dependencies[d]-1;
				if (resources[rIDX]==null)
					resources[rIDX] = new HashSet<>();
				resources[rIDX].add(tIDX);
			}
		}
		
		// check tasks that have dependency are executed at the same time unit
		for(int rIDX=0; rIDX<resources.length; rIDX++){
			if (resources[rIDX].size()==0) continue;
			
			for (int t=0; t<MaxTime; t++) {
				int cnt = 0;
				for (Integer tIDX : resources[rIDX]) {
					if (timelines[tIDX][t].CPUID > 0) cnt +=1;   // if a task is executing
				}
				if (cnt>1) throw new AssertionError(String.format("Error to verify exclusive access to resources (resID: %d, time: %d, cnt: %d)", rIDX, t, cnt));
			}
		}
		return true;
	}
	
	/**
	 * Task executions at one time unit should be less than the number of CPUs
	 * When a CPU is idle, no tasks are ready (some tasks can be blocked state)
	 * @return
	 */
	public boolean verifyCPUExecution(){
		for (int t=0; t<MaxTime; t++) {
			int cntRunning = 0;
			int cntReady = 0;
			for (int x=0; x<timelines.length; x++){
				if (timelines[x][t].CPUID >= 0) cntRunning +=1;        // if a task is runnning
				if (timelines[x][t].type == Type.READY) cntReady +=1;
			}
			if (cntRunning>Settings.N_CPUS) throw new AssertionError("Error to verify the number of CPU are executing");
			if (cntRunning==0 && cntReady>0) throw new AssertionError("Error to verify the CPU idle state");
		}
		return true;
	}

	/**
	 * Task executions at one time unit should be less than the number of CPUs
	 * When a CPU is idle, no tasks are ready (some tasks can be blocked state)
	 * @return
	 */
	public boolean verifyTriggers(){
		for (int x=0; x<schedules.length; x++) {
			for (int i = 0; i < schedules[x].length; i++) {
				if (Tasks[x].WCET == schedules[x][i].executedTime)
					throw new AssertionError("Error to verify triggers");
			}
		}
		return true;
	}
}