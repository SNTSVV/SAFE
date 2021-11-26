package lu.uni.svv.SAFE;

import lu.uni.svv.SAFE.phase1.ArrivalsProblem;
import lu.uni.svv.SAFE.phase1.ArrivalsSolution;
import lu.uni.svv.SAFE.phase2.RScriptExecutor;
import lu.uni.svv.SAFE.phase2.ModelUpdate;
import lu.uni.svv.SAFE.phase2.ModelUpdateThreshold;
import lu.uni.svv.SAFE.task.Arrivals;
import lu.uni.svv.SAFE.task.TaskDescriptor;
import lu.uni.svv.SAFE.task.TaskDescriptors;
import lu.uni.svv.utils.GAWriter;
import lu.uni.svv.utils.Monitor;
import org.renjin.eval.EvalException;
import org.uma.jmetal.util.JMetalLogger;

import javax.script.ScriptException;
import java.io.File;
import java.util.*;

/**
 * Phase2. Model refinement
 * Related settings:
 *    - BASE_PATH (-b): the path where had given the target folder of phase 1, if phase 1 runs multiple experiments, this path should be set the each run path
 *                      e.g. results/SAFE_ESAIL, results/SAFE_ESAIL/Run01
 *    - WORKNAME_P1 (-w1):  the directory name for phase 1 results
 *    - WORKNAME_P2 (-w2):  the directory name for phase 2 results
 *    - FORMULA_PATH (-wf):  the directory name for formula
 *
 *    - SAMPLING_METHOD(--samplingMethod): select one of the sampling methods among {"random", "distance"}
 *    - N_MODEL_UPDATES (--nUpdates): number of model updates WCETs for each solution
 *    - N_SAMPLE_SOLUTIONS (--nSamples): number of sample WCETs for each solution
 *    - N_SAMPLE_CANDIDATES (--nCandidates): number of sample WCETs for each solution
 *    - MODEL_PROB_PRECISION (--modelPrecision): the degree of precision for model probability (e.g. 0.0001)
 *
 *    - PRE_ONLY (--preOnly): boolean option, default false, if it sets true, SafeRefinement executes only preprocessings.
 *    - PRE_FEATURES (--preFeatures): boolean option, default false, if it sets true, SafeRefinement conducts features processing (R scripts) before going to phase 2
 *    - PRE_PRUNE (--prePrune): boolean option, default false, if it sets true, SafeRefinement conducts prune processing (R scripts) before going to phase 2
 *    - PRE_TEST (--preTest): boolean option, default false, if it sets true, SafeRefinement generates test data before going to phase 2
 *    - N_TEST_SOLUTIONS (--nTest): number of solutions to be generated for testing, if set PRE_TEST, this option should be set
 *
 *    - P2_ALGORITHM (--p2): phase 2 algorithms, select one algorithm of {"refine", "threshold"}
 *    - USE_TEST_DATA (--useTest): boolean option, default false, please set if you want to test the model with test data
 *                                 Test data should have generated before start this phase, and located _results/testdata.csv
 * 	  -	STOP_CONDITION (-x): boolean option, default false, please set if you want to stop algorithm when the probability below STOP_ACCEPT_RATE
 * 	  - STOP_ACCEPT_RATE(--stopProb): the condition to stop algorithm
 *
 *    **** related scheduler parameters (thoes items should be same with the phase 1)
 *    - TIME_MAX (--max): simulation time, if it is set 0, the simulation time will be calculated from the input, it should be the same value with phase 1
 *    - TIME_QUANTA (--quanta): time tick of the simulator, it should be the same value with phase 1

 * Resources:
 *    - <BASE_PATH>/input.csv or <BASE_PATH>/input_reduced.csv   : task descriptions for phase 2 (This will be set to INPUT_FILE)
 *    - <BASE_PATH>/<FORMULA_PATH>/formula                       : model formula after feature reduction
 *    - <BASE_PATH>/<WORKNAME_P1>/solutions.list                 : worst-case sequences of task arrivals
 *    - <BASE_PATH>/<WORKNAME_P1>/sampledata.csv                 : initial training data (it will be copied into workdata.csv)
 *    - <BASE_PATH>/<WORKNAME_P1>/testdata.csv                   : (optional) if you set USE_TEST_DATA, it will be used
 * Output:
 *    - <BASE_PATH>/<WORKNAME_P2>/workdata.csv                      : training data for phase 2
 *    - <BASE_PATH>/<WORKNAME_P2>/workdata_model_results.csv        : model results for each update
 *    - <BASE_PATH>/<WORKNAME_P2>/workdata_termination_results.csv  : stop condition comparision results for each update
 *    - <BASE_PATH>/<WORKNAME_P2>/workdata_test_results.csv         : evaluation results with test data for each update
 */

public class SafeRefinement {
	public static GAWriter resultWriter = null;

	public static String selectInput(){
		// input_file setting
		String filename = String.format("%s/input_reduced.csv",Settings.BASE_PATH);
		File inputFile = new File(filename);
		if (!inputFile.exists()){
			filename = String.format("%s/input.csv",Settings.BASE_PATH);
		}
		return filename;
	}
	
	public static String selectSampleData(){
		// Settings working paths
		String filename = String.format("%s/%s/sampledata_reduced.csv", Settings.BASE_PATH, Settings.WORKNAME_P1);
		
		// if not exists sampledata_reduced.csv, we take sampledata.csv
		File file = new File(filename);
		if (!file.exists()) {
			filename = String.format("%s/%s/sampledata.csv", Settings.BASE_PATH, Settings.WORKNAME_P1);
		}
		return filename;
	}
	/**
	 * Start function of second phase
	 * @param args
	 */
	public static void main(String[] args) throws Exception {
		Monitor.start();
		
		// Environment Settings
		Initializer.initLogger();
		Settings.update(args);
		
		// Phase2 initialize
		RScriptExecutor.init(Settings.SCRIPT_PATH);

		// preprocessing
		if(!Settings.PRE_ONLY)
			resultWriter = new GAWriter(String.format("%s/%s/result2.txt", Settings.BASE_PATH , Settings.WORKNAME_P2));

		if(!preprocessing()){
			System.exit(1);
		}

		// load input
//		Settings.N_SAMPLE_WCET=1;   // Scheduling option:
		Settings.INPUT_FILE = selectInput();
		String sampleSourcePath = selectSampleData();
		TaskDescriptor[] input = TaskDescriptors.loadFromCSV(Settings.INPUT_FILE, Settings.TIME_MAX, Settings.TIME_QUANTA);
		Integer[] priorities = TaskDescriptors.getPriorities(input);
		
		// update dynamic settings
		Initializer.updateSettings(input);
		Initializer.verify();
		Settings.displaySettings();
		
		//load Testing Problem
		ArrivalsProblem problem = new ArrivalsProblem(input, priorities, Settings.TIME_MAX, Settings.SCHEDULER);
		String solutionPath = String.format("%s/%s/solutions.list", Settings.BASE_PATH, Settings.WORKNAME_P1);

		// preprocessing: generating Test Data
		if (Settings.PRE_TEST) {
			generateTestData(problem, solutionPath);
		}

		if(Settings.PRE_ONLY) {
			Monitor.end();
			System.exit(1);
		}

		
		boolean ret = runPhase2(problem, solutionPath, sampleSourcePath);
		Monitor.end();
		
		saveExecutionResults(ret);
		resultWriter.close();
		
	}
	
	public static boolean preprocessing() throws Exception {
		// extract formula
		if (Settings.PRE_FEATURES) {
			Monitor.start("formula", false);
			String p1Path = String.format("%s/%s", Settings.BASE_PATH, Settings.WORKNAME_P1);
			String formulaPath = String.format("%s/%s", Settings.BASE_PATH, Settings.FORMULA_PATH);
			boolean result = RScriptExecutor.feature(Settings.BASE_PATH, p1Path, formulaPath, Settings.N_TERMS);
			Monitor.end("formula", false);
			
			//record results
			double formulaTime = Monitor.getTime("formula")/1000.0;
			String status = (result)?"success":"error";
			String message = String.format("FormulaExecutionTime ( s): %.3f (%s)", formulaTime, status);
			if (resultWriter!=null)
				resultWriter.info(message);
			JMetalLogger.logger.info(message);
			
			if (!result) return false;
		}else{
			if (resultWriter!=null)
				resultWriter.info("FormulaExecutionTime ( s): 0 (passed)");
		}
		
		// pruning
		if (Settings.PRE_PRUNE) {
			Monitor.start("pruning", false);
			String p1Path = String.format("%s/%s", Settings.BASE_PATH, Settings.WORKNAME_P1);
			String formulaPath = String.format("%s/%s", Settings.BASE_PATH, Settings.FORMULA_PATH);
			boolean result = RScriptExecutor.prune(Settings.BASE_PATH, p1Path, formulaPath);
			Monitor.end("pruning", false);
			//record results
			double pruningTime = Monitor.getTime("pruning")/1000.0;
			String status = (result)?"success":"error";
			String message = String.format("PruningExecutionTime ( s): %.3f (%s)", pruningTime, status);
			if (!(resultWriter==null))
				resultWriter.info(message);
			JMetalLogger.logger.info(message);
		}
		else{
			if (resultWriter!=null)
				resultWriter.info("PruningExecutionTime ( s): 0 (passed)");
		}
		
		return true;
	}
	
	public static boolean generateTestData(ArrivalsProblem _problem, String _solutionPath) throws Exception {
		Monitor.start("testdata", false);

		TestDataGenerator tg =  new TestDataGenerator(_problem, _solutionPath, Settings.BASE_PATH, Settings.PARTITION_ID);
		tg.generate(Settings.N_TEST_SOLUTIONS, Settings.RESUME);
		
		Monitor.end("testdata", false);
		String message = "Testdata generation execution time: " + Monitor.getTime("testdata") + "ms";
		if (resultWriter!=null)
			resultWriter.info(message);
		JMetalLogger.logger.info(message);
		return true;
	}
	
	public static boolean runPhase2(ArrivalsProblem _problem, String _solutionPath, String _sampleSourcePath) throws Exception{
		// phase2 setting update
		String testPath = Settings.TEST_DATA_PATH;
		if (testPath.compareTo("")==0) {
			testPath = String.format("%s/testdata.csv", Settings.BASE_PATH);
		}
		if (Settings.USE_TEST_DATA){
			if (!new File(testPath).exists())
				throw new Exception("Cannot find test data: "+ testPath);
		}
		
		List<ArrivalsSolution> solutions = _problem.loadSolutions(_solutionPath);
		if (solutions == null) {
			resultWriter.info("Refine execution time: 0ms (no solution)");
			throw new Exception("There are no solutions in the path:" + _solutionPath);
		}
		
		//Run phase 2
		ModelUpdate phase2 = null;
		String outputPath = String.format("%s/%s", Settings.BASE_PATH, Settings.WORKNAME_P2);
		String formulaFile = String.format("%s/%s/formula", Settings.BASE_PATH, Settings.FORMULA_PATH);
		if (Settings.P2_ALGORITHM.compareTo("threshold")==0) {
			phase2 = new ModelUpdateThreshold(  _problem, solutions, outputPath,
												_sampleSourcePath, testPath, formulaFile, Settings.SCRIPT_PATH,
												Settings.DEBUG);
		}
		else{
			phase2 = new ModelUpdate(   _problem, solutions, outputPath,
										_sampleSourcePath, testPath, formulaFile, Settings.SCRIPT_PATH,
										Settings.DEBUG);
		}
		
		try {
			Monitor.start("refine", false);
			phase2.run();
			Monitor.end("refine", false);
			
			// record results
			double refineTime = Monitor.getTime("refine")/1000.0;
			String msg = String.format("RefineExecutionTime( s): %.3f (success)", refineTime);
			resultWriter.info(msg);
			JMetalLogger.logger.info(msg);
			
		} catch(ScriptException | EvalException e){
			JMetalLogger.logger.info("R Error:: " + e.getMessage());
			e.printStackTrace();
			return false;
		}
		catch(Exception e){
			JMetalLogger.logger.info("Error:: " + e.getMessage());
			e.printStackTrace();
			return false;
		}
		return true;
	}

	/**
	 * Print out all results
	 */
	public static void saveExecutionResults(boolean _finalResult)
	{
		double all = Monitor.getTime()/1000.0;
		String result = (_finalResult==true)?"success":"failed";
		String msg = String.format("TotalExecutionTime( s): %.3f (%s)", all, result);
		resultWriter.info(msg);
		JMetalLogger.logger.info(msg);
		resultWriter.info(String.format("InitHeap: %.1fM (%.1fG)", Monitor.heapInit/Monitor.MB, Monitor.heapInit/Monitor.GB));
		resultWriter.info(String.format("usedHeap: %.1fM (%.1fG)", Monitor.heapUsed/Monitor.MB, Monitor.heapUsed/Monitor.GB));
		resultWriter.info(String.format("commitHeap: %.1fM (%.1fG)", Monitor.heapCommit/Monitor.MB, Monitor.heapCommit/Monitor.GB));
		resultWriter.info(String.format("MaxHeap: %.1fM (%.1fG)", Monitor.heapMax/Monitor.MB, Monitor.heapMax/Monitor.GB));
		resultWriter.info(String.format("MaxNonHeap: %.1fM (%.1fG)", Monitor.nonheapUsed/Monitor.MB, Monitor.nonheapUsed/Monitor.GB));
	}
}