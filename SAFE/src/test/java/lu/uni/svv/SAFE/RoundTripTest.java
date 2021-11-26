package lu.uni.svv.SAFE;

import junit.framework.Assert;
import junit.framework.TestCase;
import lu.uni.svv.SAFE.phase1.ArrivalsProblem;
import lu.uni.svv.SAFE.task.TaskDescriptor;
import lu.uni.svv.SAFE.task.TaskDescriptors;
import org.uma.jmetal.util.pseudorandom.JMetalRandom;

import java.io.IOException;

public class RoundTripTest extends TestCase {
	RoundTrip obj = null;
	
	public RoundTripTest() throws Exception {
		// Environment Settings
		Settings.TIME_MAX = 0;
		Settings.TIME_QUANTA = 0.01;
		Settings.SCHEDULER = "SQMScheduler";
		Settings.N_TEST_SOLUTIONS = 10;
		Settings.N_SAMPLE_WCET = 10;
		Settings.WORKNAME_P2 = "_phase2";
		Settings.WORKNAME_EV = "_roundtrip";
		Settings.BASE_PATH = "../results/TOSEM_mix/CCS_40a_RS1000/Run01";
		
		
		// load input
		Settings.INPUT_FILE = RoundTrip.selectInput();
		TaskDescriptor[] input = TaskDescriptors.loadFromCSV(Settings.INPUT_FILE, Settings.TIME_MAX, Settings.TIME_QUANTA);
		
		// update dynamic settings
		Initializer.updateSettings(input);
		Initializer.verify();
		
		Integer[] priorities = TaskDescriptors.getPriorities(input);
		
		//run RoundTrip
		ArrivalsProblem problem = new ArrivalsProblem(input, priorities, Settings.TIME_MAX, Settings.SCHEDULER);
		obj = new RoundTrip(problem, input, Settings.WORKNAME_EV, Settings.WORKNAME_P2, Settings.N_MODEL_UPDATES);
	}
	
	public void testSetRange() throws Exception {
		// define test oracles
		int[] oracleMin = new int[]{120, 300, 420, 180, 180, 120, 240, 120, 240, 180, 120};
		int[] oracleMax = new int[]{185, 422, 649, 281, 260, 196, 342, 174, 298, 291, 192};
		
		// test function
		String filename = String.format("%s/%s/workdata_model_result.csv", Settings.BASE_PATH, Settings.WORKNAME_P2);
		obj.setRange(filename, 100);
		
		
		//check result
		Assert.assertEquals(obj.problem.Tasks.length, obj.minRange.length);
		Assert.assertEquals(obj.problem.Tasks.length, obj.maxRange.length);
		
		for (int x = 0; x < obj.minRange.length; x++) {
			Assert.assertEquals(oracleMin[x], obj.minRange[x]);
		}
		for (int x = 0; x < obj.minRange.length; x++) {
			Assert.assertEquals(oracleMax[x], obj.maxRange[x]);
		}
	}
	
	public void testLoadMaxRanges() throws Exception {
		// define test oracles
		int[] oracleTasks = new int[]{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11};
		int[] oracleValues = new int[]{185, 422, 649, 281, 260, 196, 342, 174, 298, 291, 192};
		
		// test function
		String filename = String.format("%s/%s/workdata_model_result.csv", Settings.BASE_PATH, Settings.WORKNAME_P2);
		int[][] values = obj.loadMaxRanges(filename, 100);
		
		//check result
		Assert.assertEquals(2, values.length);
		
		for (int x = 0; x < values[0].length; x++) {
			Assert.assertEquals(oracleTasks[x], values[0][x]);
		}
		for (int x = 0; x < values[1].length; x++) {
			Assert.assertEquals(oracleValues[x], values[1][x]);
		}
	}
	
	public void testRandomBound() throws Exception {
		JMetalRandom random = JMetalRandom.getInstance();
		
		int maxV = 10;
		int[] list = new int[maxV+1];
		for(int x=0; x<1000; x++) {
			int v=random.nextInt(1, maxV);
			list[v] += 1;
		}
		
		// check result
		for(int x=1; x<=maxV; x++) {
			Assert.assertTrue(list[x]!=0);
			
		}
		
	}
}
	