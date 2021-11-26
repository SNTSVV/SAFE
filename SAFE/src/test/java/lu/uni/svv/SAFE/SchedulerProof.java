package lu.uni.svv.SAFE;

import java.io.*;
import junit.framework.TestCase;
import lu.uni.svv.SAFE.scheduler.*;
import lu.uni.svv.SAFE.phase1.ArrivalsSolution;
import lu.uni.svv.SAFE.phase1.ArrivalsProblem;
import lu.uni.svv.SAFE.task.Arrivals;
import lu.uni.svv.SAFE.task.TaskDescriptor;
import lu.uni.svv.SAFE.task.TaskDescriptors;
import lu.uni.svv.utils.GAWriter;
import org.json.simple.JSONArray;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;
import org.uma.jmetal.util.JMetalLogger;

/**
 * Unit test for simple App.
 */
public class SchedulerProof extends TestCase
{

	public SchedulerProof( String testName )
	{
		super( testName );
		
		setEnvironment();
		// create Directory
		File dir = new File(Settings.BASE_PATH);
		if (dir.exists() == false) {
			dir.mkdirs();
		}
	}
	
	public void setEnvironment(){
		// Basic working directory is [project PATH]/StressTesting/
		System.out.println(System.getProperty("user.dir"));
		Settings.TIME_MAX = 0;
		Settings.TIME_QUANTA = 0.01;
		Settings.N_CPUS = 2;
		Settings.BASE_PATH = "../results/test/ScheduleVerify";
		Settings.INPUT_FILE = "../res/industrial_80b/CCS.csv";
	}
	
	public void testSQMScheduler() throws Exception{
		boolean LOAD = true;
		
		// load resources
		int simulationTime = Settings.TIME_MAX;
		double timeQuanta = Settings.TIME_QUANTA;
		TaskDescriptor[] input = TaskDescriptors.loadFromCSV(Settings.INPUT_FILE, simulationTime, timeQuanta);
		simulationTime = Initializer.calculateSimulationTime(input);
		Integer[] priorities = TaskDescriptors.getPriorities(input);
		
		// create arrival times solution
		ArrivalsProblem problem = new ArrivalsProblem(input, priorities, simulationTime, Settings.SCHEDULER);
		int[] uncertainTasks = problem.getUncertainTasks();
		for (int i=0; i<100; i++) {
			// make random sampling
			ArrivalsSolution solution = (LOAD)?loadArrivals(problem):problem.createSolution();
			Arrivals[] arrivals = solution.toArray();
			int[] WCETs = (LOAD)?loadWCETs():problem.getSampleWCETs(uncertainTasks);
			saveSolution(solution, WCETs);
			
			// execute scheduler
			Schedule[][] schedules = runScheduler(input, simulationTime, arrivals, WCETs, priorities);
			int deadline = checkDeadline(schedules);
			
			// verify
			ScheduleVerify verifier = new ScheduleVerify(schedules, input, Settings.TIME_QUANTA, priorities, arrivals, WCETs);
			if (deadline>0) {
				verifier.verify();
//				if (verifier.verify() == false) {
					verifier.printTimelines();
					JMetalLogger.logger.severe("Error:: not verified");
//				}
				break;
			}
		}
	}
	
	public Schedule[][] runScheduler(TaskDescriptor[] _input, int _simulationTime, Arrivals[] _arrivals, int[] WCETs, Integer[] priorities){
		SQMScheduler scheduler = new SQMScheduler(_input, _simulationTime);
		scheduler.setSamples(WCETs);
		scheduler.run(_arrivals, priorities);
		return scheduler.getResult();
		
	}
	
	public int checkDeadline(Schedule[][] _schedules){
		ScheduleCalculator calculator = new ScheduleCalculator(_schedules, new int[]{});
		int deadline = calculator.checkDeadlineMiss();
		System.out.println(String.format("Deadline Miss: %d", deadline));
		System.out.println(String.format("TaskID,exID,ArrivalTime,DiffDeadilne", deadline));
		System.out.println(calculator.getDeadlineMiss(""));
		return deadline;
	}
	
	public void saveSolution(ArrivalsSolution _solution, int[] _wcets){
		GAWriter writer = new GAWriter(Settings.BASE_PATH+"/arrivals.item");
		writer.write(_solution.getVariablesString());
		writer.close();
		
		writer = new GAWriter(Settings.BASE_PATH+"/WCETs.item");
		StringBuilder sb = new StringBuilder("[");
		for(int x=0; x<_wcets.length; x++){
			sb.append(_wcets[x]);
			sb.append(", ");
		}
		sb.append("]");
		writer.write(sb.toString());
		writer.close();
	}
	
	public ArrivalsSolution loadArrivals(ArrivalsProblem _problem){
		String filename = String.format("%s/arrivals.item", Settings.BASE_PATH);
		return ArrivalsSolution.loadFromFile(_problem, filename);
	}
	
	public int[] loadWCETs(){
		String filename = String.format("%s/WCETs.item", Settings.BASE_PATH);
		FileReader reader = null;
		int[] variables = null;
		try {
			reader = new FileReader(filename);
			JSONParser parser = new JSONParser();
			JSONArray json = (JSONArray) parser.parse(reader);
			
			variables = new int[json.size()];
			for (int i = 0; i < json.size(); i++) {
				Object item = json.get(i);
				variables[i] = ((Long)item).intValue();
			}
			
			return variables;
		}
		catch (IOException | ParseException e){
			e.printStackTrace();
		} finally {
			try {
				if (reader != null)
					reader.close();
			} catch (IOException ex) {
				ex.printStackTrace();
			}
		}
		return variables;
	}
}