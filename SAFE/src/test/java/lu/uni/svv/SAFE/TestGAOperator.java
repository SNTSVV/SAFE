package lu.uni.svv.SAFE;

import java.util.ArrayList;
import java.util.List;

import junit.framework.TestCase;
import lu.uni.svv.SAFE.phase1.SimpleCrossover;
import lu.uni.svv.SAFE.phase1.SimpleMutation;
import lu.uni.svv.SAFE.task.TaskDescriptor;
import lu.uni.svv.SAFE.phase1.ArrivalsProblem;
import lu.uni.svv.SAFE.phase1.ArrivalsSolution;
import lu.uni.svv.SAFE.task.TaskDescriptors;
import org.uma.jmetal.util.JMetalException;

public class TestGAOperator extends TestCase {
	public TestGAOperator(String testName) {
		super(testName);
		/* Apply Common Environment */
	}
	
	/**
	 * Test with Periodic tasks
	 * No deadline misses
	 */
	public void testCrossover() throws Exception {
		TaskDescriptor.UNIQUE_ID = 1;
		System.out.println("--------Test SimpleTLCrossover-------");
		
		int simulationTime = 60;
		TaskDescriptor[] input = TaskDescriptors.loadFromCSV("../res/samples/sample_aperiodic_2.csv", simulationTime, 1);
		Integer[] proirities = TaskDescriptors.getPriorities(input);
		ArrivalsProblem problem = new ArrivalsProblem(input, proirities, simulationTime, Settings.SCHEDULER);
		
		for (int x = 0; x < 10; x++) {
			List<ArrivalsSolution> parents = new ArrayList<ArrivalsSolution>();
			parents.add(new ArrivalsSolution(problem));
			parents.add(new ArrivalsSolution(problem));
			
			System.out.println("P1: " + parents.get(0).getVariablesStringInline());
			System.out.println("P2: " + parents.get(1).getVariablesStringInline());
			
			SimpleCrossover crossover = new SimpleCrossover(problem, 0.8);
			
			List<ArrivalsSolution> children = crossover.execute(parents);
			
			System.out.println("C1: " + children.get(0).getVariablesStringInline());
			System.out.println("C2: " + children.get(1).getVariablesStringInline());
			System.out.println("=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=");
		}
	}
	
	
	public void testMutation() throws Exception {
		TaskDescriptor.UNIQUE_ID = 1;
		System.out.println("--------Test SimpleTLMutation-------");
		
		int simulationTime = 60;
		TaskDescriptor[] input = TaskDescriptors.loadFromCSV("../res/samples/sample_mixed_1.csv", simulationTime, 1);
		Integer[] proirities = TaskDescriptors.getPriorities(input);
		ArrivalsProblem problem = new ArrivalsProblem(input, proirities, simulationTime, Settings.SCHEDULER);
		
		ArrivalsSolution solution = new ArrivalsSolution(problem);
		System.out.println(solution.getLineVariableValueString(100));
		System.out.println();
		
		SimpleMutation mutation = new SimpleMutation(problem, 1);
		for (int x = 0; x < 100; x++) {
			ArrivalsSolution mutated = mutation.execute(solution);
			System.out.print("(" + mutation.taskID + ", " + mutation.position + ")->" + mutation.newValue + "\t:: ");
			System.out.println(mutated.getLineVariableValueString(30));
		}
		
		System.out.print("Null test-->");
		try {
			ArrivalsSolution mutated = mutation.execute(null);
		} catch (JMetalException e) {
			System.out.print("True");
			assertTrue(true);
		}
		
	}
}