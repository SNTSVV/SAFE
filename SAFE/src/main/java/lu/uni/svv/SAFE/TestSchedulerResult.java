package lu.uni.svv.SAFE;

import lu.uni.svv.SAFE.phase1.ArrivalsProblem;
import lu.uni.svv.SAFE.phase1.ArrivalsSolution;
import lu.uni.svv.SAFE.scheduler.RTScheduler;
import lu.uni.svv.SAFE.scheduler.Schedule;
import lu.uni.svv.SAFE.scheduler.ScheduleCalculator;
import lu.uni.svv.SAFE.task.TaskDescriptor;
import lu.uni.svv.SAFE.task.TaskDescriptors;
import lu.uni.svv.utils.GAWriter;
import org.uma.jmetal.util.JMetalLogger;
import java.io.*;
import java.util.ArrayList;
import java.util.List;


public class TestSchedulerResult{
	
	public static void main(String[] args) throws Exception{
		// Environment Settings
		Initializer.initLogger();
		Settings.update(args);
		
		// load input
		Settings.INPUT_FILE = Settings.BASE_PATH + "/input.csv";
		TaskDescriptor[] input = TaskDescriptors.loadFromCSV(Settings.INPUT_FILE, Settings.TIME_MAX, Settings.TIME_QUANTA);
		
		// update dynamic settings
		Initializer.updateSettings(input);
		Initializer.verify();
		
		Integer[] priorities = TaskDescriptors.getPriorities(input);
		
		TestSchedulerResult tester = new TestSchedulerResult();
		tester.run(input, priorities);
	}
	
	ArrivalsProblem problem = null;
	
	public TestSchedulerResult(){
	
	}
	
	public void run(TaskDescriptor[] _input, Integer[] _priorities) throws Exception{
		//create testing problem
		problem = new ArrivalsProblem(_input, _priorities, Settings.TIME_MAX, Settings.SCHEDULER);
		JMetalLogger.logger.info("Loaded problem");
		
		// load solutions
		String solutionPath = String.format("%s/_results/solutions.list", Settings.BASE_PATH);
		List<ArrivalsSolution> solutions = problem.loadSolutions(solutionPath);
		if (solutions == null) {
			throw new Exception("There are no solutions in the path:" + solutionPath);
		}
		
		// Load WCET
		String workdataPath = String.format("%s/%s/workdata_%s.csv", Settings.BASE_PATH, Settings.WORKNAME_P2, Settings.TEST_DATA_PATH);
		List<int[]> WCETs = loadWCETs(workdataPath);
		
		// calculate results
		String outputPath = String.format("%s/%s/verify_%s.txt", Settings.BASE_PATH, Settings.WORKNAME_P2, Settings.TEST_DATA_PATH);
		GAWriter writer = new GAWriter(outputPath,"WID,solutionID,Result");
		for (int w=0; w<WCETs.size(); w++) {
			for (int s = 0; s <solutions.size(); s++){
				int result = evaluate(solutions.get(s), WCETs.get(w));
				writer.info(String.format("%d, %d, %d", w, s, result));
				JMetalLogger.logger.info(String.format("%d, %d, %d", w, s, result));
			}
		}
		
	}
	/**
	 * Evaluation a sample with a TimeListSolution in Scheduler
	 * @param _solution
	 * @return
	 */
	public int evaluate(ArrivalsSolution _solution, int[] samples){
		int result = 0;
		// Create Scheduler instance
		RTScheduler scheduler = RTScheduler.createObject(problem.Tasks, problem.SIMULATION_TIME, problem.schedulerType);
		scheduler.setSamples(samples);
		scheduler.run(_solution.toArray(), problem.Priorities);
		Schedule[][] schedules = scheduler.getResult();
		
		ScheduleCalculator cals = new ScheduleCalculator(schedules, Settings.TARGET_TASKS);
		result = cals.checkDeadlineMiss();
		
		return result>0?1:0;
	}
	
	/**
	 *
	 */
	public List<int[]> loadWCETs(String _filename) throws IOException {
		List<int[]> WCETs = new ArrayList<>();
		
		// get task indexes for uncertain tasks
		int[] uncertains = problem.getUncertainTasks();
		int[] uncertainTasks = new int[uncertains.length];
		int x=0;
		for(int i=0; i<uncertains.length; i++){
			if (uncertains[i]==0) continue;
			uncertainTasks[x++] = i;
		}
		
		// load test file names
		BufferedReader reader = new BufferedReader(new FileReader(_filename));
		String line = reader.readLine();  // remove header
		while(line!=null){
			line = reader.readLine();
			if (line==null || line.trim()=="") break;
			String[] items = line.split(",");

//			int[] list = new int[items.length-1];
			// set initial WCET
			int[] list = new int[problem.Tasks.length];
			for (int c=0; c<problem.Tasks.length; c++){
				list[c] = problem.Tasks[c].WCET;
			}
			
			// set sampled WCETs
			for (int c=1; c<items.length; c++){
				int idx = uncertainTasks[c-1];
				list[idx] = Integer.parseInt(items[c]);
			}
			WCETs.add(list);
		}
		return WCETs;
	}
}
