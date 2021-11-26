package lu.uni.svv.SAFE;

import lu.uni.svv.SAFE.scheduler.*;
import lu.uni.svv.SAFE.phase1.ArrivalsProblem;
import lu.uni.svv.SAFE.phase1.ArrivalsSolution;
import lu.uni.svv.SAFE.task.Arrivals;
import lu.uni.svv.SAFE.task.TaskDescriptors;
import lu.uni.svv.SAFE.task.TaskDescriptor;
import lu.uni.svv.utils.GAWriter;

import java.io.IOException;

/**
 * This class is a simple approach that shows probability of deadline miss.
 * Basically, this class modifies WCET values from WCET-95% to WCET+100%
 * and generates random samples of task arrivals for each modified WCET
 * then calculates probability of deadline miss given scheduling results for the samples
 * Assuming we generating 10,000 random samples, the result will be like below:
 *     WCET-90%: 0.0% deadline misses (0/10000)
 *     WCET-80%: 0.4% deadline misses (40/10000)
 *        ...
 *     WCET+100% 100.0% deadline misses (10000/10000)
 *
 * Execution examples (if you put --debug option, This program will load arrival solution from the result.)
 * The program loads configuration from settings.json, and updates the configuration from the command line parameters.
 * -b results/ICS --data res/industrial/ICS.csv --cpus 3 -i 1000 --max 0 -s SQMScheduler --quanta 0.01
 * -b results/CCS --data res/industrial/CCS.csv --cpus 2 -i 1000 --max 0 -s SQMScheduler --quanta 0.01
 * -b results/UAV --data res/industrial/UAV.csv --cpus 3 -i 1000 --max 0 -s SQMScheduler --quanta 0.01
 * -b results/GAP --data res/industrial/GAP.csv --cpus 2 -i 1000 --max 0 -s SQMScheduler --quanta 0.01
 * -b results/HPSS --data res/industrial/HPSS.csv --cpus 1 -i 1000 -s SQMScheduler --quanta 0.01
 */
public class SimpleScheduleTest {
	
	public static void main( String[] args ) throws Exception
	{
		TaskDescriptor[] input = Initializer.init(args);
		Initializer.printInput(null, input);
		
		SimpleScheduleTest test = new SimpleScheduleTest();
		test.experiment(input, (int)Settings.TIME_MAX);
	}
	
	////////////////////////////////////////////////////////////////////////
	// Internal Class functions
	////////////////////////////////////////////////////////////////////////
	public void SimpleScheduleTest(){
	
	}
	
	public void experiment(TaskDescriptor[] input, int simulationTime) throws IOException {
		// Output is a list of below:
		// BASE_PATH, percentage, ....., Probability of deadline miss, Size of deadline miss on average
		
		Integer[] priorities = TaskDescriptors.getPriorities(input);
		int[] midWCETs = getWCETs(input);
		ArrivalsProblem problem = new ArrivalsProblem(input, priorities, simulationTime, Settings.SCHEDULER);
		
		for (int pcnt=-95; pcnt<100; pcnt+=5) {
			// generate sample
			int sumMissed = 0;
			int nMissed = 0;
			
			setWCETs(input, midWCETs, pcnt/100.0);
			System.out.print(String.format("%s,%.2f,",Settings.BASE_PATH.substring(8),pcnt/100.0));
			
			int point =  Settings.GA_ITERATION/20;
			for (int solutionID = 0; solutionID < Settings.GA_ITERATION; solutionID++) {
				ArrivalsSolution solution = null;
				int missed = 0;
				
				// When the debug mode is activated, load from the already generated data.
				if (Settings.DEBUG) {
					solution = ArrivalsSolution.loadFromFile(problem, String.format("%s/_arrivals/sol%d.json", Settings.BASE_PATH, solutionID));
				} else {
					solution = problem.createSolution();
				}
				
				//evaluate
				RTScheduler scheduler = RTScheduler.createObject(input, simulationTime, Settings.SCHEDULER);
				// scheduler.setSamples(samples);
				scheduler.run(solution.toArray(), priorities);
				Schedule[][] schedules = scheduler.getResult();
				// ScheduleVerify verifier = new ScheduleVerify(schedules, tasks, priorities, arrivals);
				// verifier.verify();
				missed = resultAnalysis(schedules);
				
				// To accelerate the experiment, make below line a comment.
				if (!Settings.DEBUG) saveResults(solutionID, solution, schedules, priorities);
				
				sumMissed += missed;
				if (missed != 0) nMissed += 1;
				if (solutionID%point==0)
					System.out.print(".");
			}
			System.out.println(String.format(",%.4f,%.4f", (double) nMissed / Settings.GA_ITERATION, (double) sumMissed / Settings.GA_ITERATION));
//			JMetalLogger.logger.info(String.format("Probability of deadline miss: %.2f%%, (Avg. nMissed: %.2f)", (double) nMissed / Settings.GA_ITERATION * 100, (double) sumMissed / Settings.GA_ITERATION));
		}
		
		System.gc();
	}
	
	/**
	 * make a array of min WCET, we assume that the minWCET and max WCET are the same
	 * @param _input
	 * @return
	 */
	public int[] getWCETs(TaskDescriptor[] _input){
		int[] wcets = new int[_input.length];
		for (int t=0; t<_input.length; t++){
			wcets[t] = _input[t].WCET;
		}
		return wcets;
	}
	
	public void setWCETs(TaskDescriptor[] _input, int[] _middles, double _pcnt){
		for (int t=0; t<_input.length; t++){
			_input[t].WCET = (int)Math.round(_middles[t] *(1+_pcnt));
		}
	}
	
	public Schedule[][] evaluate(TaskDescriptor[] _tasks, int _simulationTime, Arrivals[] _arrivals, Integer[] _priorities) {
		
		RTScheduler scheduler = RTScheduler.createObject(_tasks, _simulationTime, Settings.SCHEDULER);
//		scheduler.setSamples(samples);
		scheduler.run(_arrivals, _priorities);
		
		Schedule[][] schedules = scheduler.getResult();
//		ScheduleVerify verifier = new ScheduleVerify(schedules, tasks, priorities, arrivals);
//		verifier.verify();
		
		return schedules;
	}
	
	public int resultAnalysis(Schedule[][] schedules){
		ScheduleCalculator calculator = new ScheduleCalculator(schedules, Settings.TARGET_TASKS);
		double margin = calculator.distanceMargin();
		int nDeadlines = calculator.checkDeadlineMiss();
		int[] maxExecutions = calculator.getMaximumMarginsByTask();
		
		StringBuffer sb = new StringBuffer("");
		for (int x=0; x<maxExecutions.length; x++){
			sb.append(maxExecutions[x]);
			sb.append(", ");
		}

//		JMetalLogger.logger.info(String.format("distance: %.2f, nDeadlines: %d, Margins: [%s]", margin, nDeadlines, sb.toString()));
		return nDeadlines;
	}
	
	
	////////////////////////////////////////////////////////////
	// Save the results of experiments
	////////////////////////////////////////////////////////////
	public void saveResults(int _solutionID, ArrivalsSolution _solution, Schedule[][] _schedules, Integer[] _priorities){
		// Save results
		String scheduleString = Schedule.toString(_schedules);
		GAWriter writer = new GAWriter(String.format("%s/_schedules/sol%d.json", Settings.BASE_PATH, _solutionID));
		writer.write(scheduleString);
		writer.close();
		
		// arrivals
		writer = new GAWriter(String.format("%s/_arrivals/sol%d.json", Settings.BASE_PATH, _solutionID));
		writer.info(_solution.getVariablesString());
		writer.close();
		
		// store priority
		writer = new GAWriter(String.format("%s/_priorities/sol%d.json", Settings.BASE_PATH, _solutionID));
		writer.write(this.priorityToString(_priorities));
		writer.close();
		
	}
	
	/**
	 * Convert priorities to String
	 * @param priorities
	 * @return
	 */
	public String priorityToString(Integer[] priorities){
		// convert priority
		StringBuilder sb = new StringBuilder();
		sb.append("[ ");
		for (int x=0; x < priorities.length; x++) {
			sb.append(priorities[x]);
			if (x!=(priorities.length-1))
				sb.append(", ");
		}
		sb.append(" ]");
		
		return sb.toString();
	}
	
}

