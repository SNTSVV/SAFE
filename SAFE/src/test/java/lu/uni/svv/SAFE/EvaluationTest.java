package lu.uni.svv.SAFE;

import junit.framework.TestCase;
import lu.uni.svv.SAFE.scheduler.RTScheduler;
import lu.uni.svv.SAFE.phase1.ArrivalsProblem;
import lu.uni.svv.SAFE.phase1.ArrivalsSolution;
import lu.uni.svv.SAFE.scheduler.SQMScheduler;
import lu.uni.svv.SAFE.scheduler.Schedule;
import lu.uni.svv.SAFE.scheduler.ScheduleCalculator;
import lu.uni.svv.SAFE.task.TaskDescriptor;
import lu.uni.svv.SAFE.task.TaskDescriptors;


public class EvaluationTest extends TestCase {
	
	public EvaluationTest( String testName )
	{
		super( testName );
	}
	
	/**
	 * Test with Periodic tasks
	 * No deadline misses 
	 */
	public void testPeriodic_1() throws Exception
	{
		System.out.println("-----------periodic Test1----------------");
		
		// Load tasks
		int simulationTime = 60;
		TaskDescriptor[] input = TaskDescriptors.loadFromCSV("../res/samples/sample_periodic_1.csv", simulationTime, 1);
		Integer[] proirities = TaskDescriptors.getPriorities(input);
		ArrivalsProblem problem = new ArrivalsProblem(input, proirities, simulationTime, Settings.SCHEDULER);
		
		OneExecution(problem, 5);
	}
	
	/**
	 * Test with Periodic tasks
	 * No deadline misses 
	 */
	public void testAperiodic_4() throws Exception
	{
		System.out.println("-----------aperiodic Test4----------------");
		int simulationTime = 60;
		TaskDescriptor[] input = TaskDescriptors.loadFromCSV("../res/samples/sample_aperiodic_4.csv", simulationTime, 1);
		Integer[] proirities = TaskDescriptors.getPriorities(input);
		ArrivalsProblem problem = new ArrivalsProblem(input, proirities, simulationTime, Settings.SCHEDULER);
		
		OneExecution(problem,5);
	}
	
	private void OneExecution(ArrivalsProblem _problem, int _testNum) {
		RTScheduler scheduler = new SQMScheduler(_problem.Tasks, _problem.SIMULATION_TIME);
		
		for (int x=0; x<_testNum; x++) {
			ArrivalsSolution solution = new ArrivalsSolution(_problem);
			scheduler.run(solution.toArray(), _problem.Priorities);
			
			Schedule[][] schedules = scheduler.getResult();
			ScheduleCalculator calculator = new ScheduleCalculator(schedules, Settings.TARGET_TASKS);
			double value = calculator.getFitnessValue();
			
			System.out.println(String.format("%.32e - Chromosome: %s", value, solution.getVariablesStringInline()));

		}
	}
	
}
