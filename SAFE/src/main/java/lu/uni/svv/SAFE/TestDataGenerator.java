package lu.uni.svv.SAFE;

import lu.uni.svv.SAFE.phase1.ArrivalsProblem;
import lu.uni.svv.SAFE.phase1.ArrivalsSolution;
import lu.uni.svv.SAFE.task.TaskDescriptor;
import lu.uni.svv.SAFE.task.TaskDescriptors;
import lu.uni.svv.utils.GAWriter;
import org.uma.jmetal.util.JMetalLogger;

import java.io.*;
import java.util.*;

/**
 * Generating test data for phase2 based on the solutions from phase 1
 *    - load solutions from phase 1
 *    - sample a WCET set for each solution
 *    - save the results
 * Related settings:
 *    - N_TEST_SOLUTIONS (--nTest): number of test data (it should be set as the x times the number of solutions in a population
 *    - BASE_PATH (-b): the path where had given the target folder of phase 1
 *    - WORKNAME_P1 (-w1): the path to load the solution list (also the test data will be saved this path)
 *    - RUN_NUM(--runID): the number of run, if a user wants to generate subset of test data, set this parameter over 0
 *    - TIME_MAX (--max): simulation time, if it is set 0, the simulation time will be calculated from the input, it should be the same value with phase 1
 *    - TIME_QUANTA (--quanta): time tick of simulator, it should be the same value with phase 1
 *    - INPUT_FILE: user cannot decide which input will be used. input_reduced.csv or input.csv in the BASE_PATH will be used.
 *    - RESUME (--resume): if this value sets true, TestDataGenerator starts from the point where it stopped
 *    - PARTITION_ID (--partID): to make a subset of test data
 * Resources:
 *    - <BASE_PATH>/input.csv or BASE_PATH/input_reduced.csv
 *    - <BASE_PATH>/<WORKNAME_P1>/solutions.list
 * Output:
 *    - <BASE_PATH>/testdata.csv
 *    or
 *    - <BASE_PATH>/testdata_<RUN_NUM>.csv
 */
public class TestDataGenerator {
	
	
	
	/**
	 * Start function to generate test data
	 * @param args
	 */
	public static void main(String[] args) throws Exception {
		// Environment Settings
		Initializer.initLogger();
		Settings.update(args);
		
		// setting for test data
		Settings.INPUT_FILE = selectInput();
		
		// load input
		TaskDescriptor[] input = TaskDescriptors.loadFromCSV(Settings.INPUT_FILE, Settings.TIME_MAX, Settings.TIME_QUANTA);
		Integer[] priorities = TaskDescriptors.getPriorities(input);
		
		// update dynamic settings
		Initializer.updateSettings(input);
		Initializer.verify();
		
		// Create problem
		ArrivalsProblem problem = new ArrivalsProblem(input, priorities,  Settings.TIME_MAX, Settings.SCHEDULER);
		
		// set Paths
		String solutionPath = String.format("%s/%s/solutions.list", Settings.BASE_PATH, Settings.WORKNAME_P1);

		TestDataGenerator tg =  new TestDataGenerator(problem, solutionPath, Settings.BASE_PATH, Settings.PARTITION_ID);
		tg.generate(Settings.N_TEST_SOLUTIONS, Settings.RESUME);
	}
	
	
	public static String selectInput(){
		// input_file setting
		String filename = String.format("%s/input_reduced.csv",Settings.BASE_PATH);
		File inputFile = new File(filename);
		if (!inputFile.exists()){
			filename = String.format("%s/input.csv",Settings.BASE_PATH);
		}
		return filename;
	}
	
	
	/**********************************
	 * non-static methods
	 *********************************/
	ArrivalsProblem problem;
	List<ArrivalsSolution> solutions;
	String sampleFile;
	
	public TestDataGenerator(ArrivalsProblem _problem, String _solutionPath, String _outputPath, int _partitionID) throws Exception {
		problem= _problem;
		solutions = problem.loadSolutions(_solutionPath);
		if (solutions == null) {
			throw new Exception("There are no solutions in the path:" + _solutionPath);
		}
		if (_partitionID !=0)
			sampleFile = String.format("%s/testdata_part%02d.csv", _outputPath, _partitionID);
		else
			sampleFile = String.format("%s/testdata.csv", _outputPath);
	}
	
	/**
	 * Run the second phase
	 * @throws IOException
	 */
	public void generate(int nPoints, boolean _resume) throws IOException {
		// Creating test data
		int cnt = 0;
		int solID = 0;
		int cntDeadline = 0;
		int cntNoDeadline = 0;
		int[] uncertainTasks = problem.getUncertainTasks();
		
		if (_resume){
			cnt = loadLatestStatus(this.sampleFile);
			JMetalLogger.logger.info(String.format("Restart from %d-th test data", cnt+1));
		}
		
		GAWriter outputWriter = new GAWriter(this.sampleFile, makeSampleHeader(uncertainTasks), _resume);
		while (cnt < nPoints) {
			int[] samples = problem.getSampleWCETs(uncertainTasks);
			
			ArrivalsSolution solution = solutions.get(solID);
			solution.setAttribute("Samples", samples);
			problem.evaluate(solution);
			
			int deadline = (int)solution.getAttribute("Deadlines");
			if (deadline>0) {
				cntDeadline += 1;
			}else{
				cntNoDeadline += 1;
			}

			String txt = makeSampleLine((deadline>0)?1:0, uncertainTasks, samples);
			outputWriter.info(txt);

			// Increase count
			cnt += 1;
			JMetalLogger.logger.info(String.format("Evaluated data %d (P: %d, N: %d) with sol %d - %s", cnt, cntNoDeadline, cntDeadline, solID, txt));
			solID = (solID + 1) % solutions.size();
			if(cnt%100==0){
				System.gc();
			}
		}
		JMetalLogger.logger.info(String.format("Finished to generate %d test points", cnt));
//		printExecutionResults();
	}
	
	
	private String makeSampleHeader( int[] uncertainTasks){
		StringBuilder sb = new StringBuilder();
		sb.append("result");
		for(int x=0; x<uncertainTasks.length; x++){
			if (uncertainTasks[x]==0) continue;
			sb.append(",T");
			sb.append(x+1);
		}
		return sb.toString();
	}
	
	private String makeSampleLine(int _answer, int[] _uncertainTasks, int[] _samples) {
		StringBuilder sb = new StringBuilder();
		sb.append(_answer);
		for(int x=0; x<_uncertainTasks.length; x++){
			if (_uncertainTasks[x]==0) continue;
			sb.append(",");
			sb.append(_samples[x]);
		}
		return sb.toString();
	}
	
	/**
	 * resume function
	 * @param _filename
	 * @return
	 * @throws IOException
	 */
	private int loadLatestStatus(String _filename) throws IOException{
		RandomAccessFile file = new RandomAccessFile(new File(_filename), "rw");
		byte[] buffer= new byte[128];
		int size=0;
		int cnt=0;
		boolean normalExit = true;
		while(true) {
			size = file.read(buffer);
			if (size<=0) break;
			for (int x = 0; x < size; x++) {
				if (buffer[x] == '\n') cnt++;
			}
			normalExit = buffer[size-1]=='\n';
		}

		// Not count the title line
		cnt--;

		if(!normalExit){
			removeLastLine(file);
		}
		file.close();
		return cnt;
	}
	
	private void removeLastLine(RandomAccessFile _file) throws IOException{
		// find cut point
		long fileLength = _file.length() - 1;
		long pointer = fileLength;
		for (; pointer >= 0; pointer--) {
			_file.seek(pointer);
			// read from the last one char at the time
			char c =  (char) _file.read();
			// break when end of the line
			if (c == '\n') {
				break;
			}
		}
		// cur file
		_file.setLength(pointer+1);
	}

//	/**
//	 * Print out all results
//	 */
//	public static void printExecutionResults()
//	{
//		long all = Monitor.getTime();
//		System.out.println(String.format("TotalExecutionTime( s): %.3f",all/1000.0));
//		System.out.println(String.format("InitHeap: %.1fM (%.1fG)", Monitor.heapInit/Monitor.MB, Monitor.heapInit/Monitor.GB));
//		System.out.println(String.format("usedHeap: %.1fM (%.1fG)", Monitor.heapUsed/Monitor.MB, Monitor.heapUsed/Monitor.GB));
//		System.out.println(String.format("commitHeap: %.1fM (%.1fG)", Monitor.heapCommit/Monitor.MB, Monitor.heapCommit/Monitor.GB));
//		System.out.println(String.format("MaxHeap: %.1fM (%.1fG)", Monitor.heapMax/Monitor.MB, Monitor.heapMax/Monitor.GB));
//		System.out.println(String.format("MaxNonHeap: %.1fM (%.1fG)", Monitor.nonheapUsed/Monitor.MB, Monitor.nonheapUsed/Monitor.GB));
//
//		JMetalLogger.logger.info("Saving population...Done");
//	}
}