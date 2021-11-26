package lu.uni.svv.SAFE.phase1;

import lu.uni.svv.SAFE.scheduler.Schedule;
import lu.uni.svv.SAFE.scheduler.ScheduleCalculator;
import lu.uni.svv.SAFE.scheduler.RTScheduler;
import lu.uni.svv.SAFE.task.Arrivals;
import lu.uni.svv.SAFE.task.TaskDescriptor;
import lu.uni.svv.utils.RandomGenerator;
import lu.uni.svv.SAFE.Settings;
import org.uma.jmetal.problem.impl.AbstractGenericProblem;
import org.uma.jmetal.util.JMetalLogger;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;


/**
 * Class Responsibility
 *  - Definition of the problem to solve
 *  - Basic environments (This is included the definition of the problem)
 *  - An interface to create a solution
 *  - A method to evaluate a solution
 * @author jaekwon.lee
 */
@SuppressWarnings("serial")
public class ArrivalsProblem extends AbstractGenericProblem<ArrivalsSolution> {
	
	// Internal Values
	public int                  SIMULATION_TIME;    // 1 hour (ms)
	public TaskDescriptor[]     Tasks = null;		// Task information
	public Integer[]            Priorities;	        // Task Priorities
	public String               schedulerType = "";
	
	/**
	 * Constructor
	 * Load input data and setting environment of experiment with default _samplesPath
	 * @param _inputs
	 * @param _priorities
	 * @param _simulationTime
	 * @param _schedulerType
	 */
	public ArrivalsProblem(TaskDescriptor[] _inputs, Integer[] _priorities, int _simulationTime, String _schedulerType) throws NumberFormatException
	{
		// Set environment of this problem.
		this.Tasks = _inputs;
		this.Priorities = _priorities;
		this.SIMULATION_TIME = _simulationTime;
		this.schedulerType = _schedulerType;
		
		// This function updates this.Tasks value.
		this.setName("StressTesting");
		this.setNumberOfVariables(this.Tasks.length);
		this.setNumberOfObjectives(1);	//Single Objective Problem
	}
	
	/**
	 * set a list of priorities to evaluate a solution
	 * @param _priorities
	 */
	public void setPriorities(Integer[] _priorities) {
		this.Priorities = _priorities;
	}
	
	
	/**
	 * Class Responsibility :create solution interface
	 * Delegate this responsibility to Solution Class.
	 */
	@Override
	public ArrivalsSolution createSolution() {
		return new ArrivalsSolution(this);
	}
	
	public List<ArrivalsSolution> loadSolutions(String _path) throws IOException{
		List<ArrivalsSolution> solutions = new ArrayList<>();
		
		// load test file names
		BufferedReader reader = new BufferedReader(new FileReader(_path));
		String line = reader.readLine();
		while(line!=null){
			line = reader.readLine();
			if (line==null || line.trim().length()==0) break;
			String[] items = line.split("\t");
			ArrivalsSolution sol = ArrivalsSolution.loadFromJSONString(this, items[items.length-1]);
			solutions.add(sol);
//			JMetalLogger.logger.info("Loaded "+ solutions.size() + " solutions ...");
		}
		
		if (solutions.size()==0){
			return null;
		}
		JMetalLogger.logger.info("Loaded "+ solutions.size() +" solutions from "+ _path );
		return solutions;
	}

	/**
	 * Class Responsibility :evaluate solution interface
	 */
	@Override
	public void evaluate(ArrivalsSolution _solution) {
		// get required data from the solution
		int[] samples = (int[])_solution.getAttribute("Samples");
		Arrivals[] arrivals  = _solution.toArray();
		
		// simulate
		RTScheduler scheduler = RTScheduler.createObject(this.Tasks, this.SIMULATION_TIME, this.schedulerType);
		scheduler.setSamples(samples);
		scheduler.run(arrivals, this.Priorities);
		
		// calculate the simulate result
		Schedule[][] schedules = scheduler.getResult();
		ScheduleCalculator calculator = new ScheduleCalculator(schedules, Settings.TARGET_TASKS);
		double fitness = calculator.getFitnessValue();
		int nDeadlines = calculator.checkDeadlineMiss();
		int[] margins = calculator.getMaximumMarginsByTask();
		
		// set the result to the solution
		_solution.setObjective(0, fitness);
		_solution.setAttribute("Deadlines", nDeadlines);
		_solution.setAttribute("Margins", margins);

		// if set debug option, append schedules to its solution
		Object debug = _solution.getAttribute("Debug");
		if (debug != null && ((boolean)debug)){
			_solution.setAttribute("Schedules", schedules);
		}
	}
	
	public int[] getUncertainTasks(){
		int[] list = new int[Tasks.length];
		
		for(int x=0; x<Tasks.length; x++){
			if (Tasks[x].WCET == Tasks[x].MaxWCET) continue;
			list[x] = 1;
		}
		return list;
	}

	public int[] getSampleWCETs(int[] _uncertainTasks){
		int[] sampledWCETs = new int[_uncertainTasks.length];
	
		RandomGenerator randomGenerator = new RandomGenerator();
		for(int x=0; x<_uncertainTasks.length; x++){
			if (_uncertainTasks[x]==0){
				sampledWCETs[x] = Tasks[x].WCET;
			}
			else{
				sampledWCETs[x] = randomGenerator.nextInt(Tasks[x].WCET, Tasks[x].MaxWCET);
			}
		}
		
		return sampledWCETs;
	}
	
	public int[] getMinimumWCETs(){
		int[] WCETs = new int[Tasks.length];
		for(int x=0; x<Tasks.length; x++){
			WCETs[x] = Tasks[x].WCET;
		}
		return WCETs;
	}

}
