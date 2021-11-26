package lu.uni.svv.SAFE.phase2;

import lu.uni.svv.SAFE.scheduler.RTScheduler;
import lu.uni.svv.SAFE.phase1.ArrivalsProblem;
import lu.uni.svv.SAFE.phase1.ArrivalsSolution;
import lu.uni.svv.SAFE.phase2.RInterface.VAR;
import lu.uni.svv.SAFE.scheduler.Schedule;
import lu.uni.svv.SAFE.scheduler.ScheduleCalculator;
import lu.uni.svv.SAFE.Settings;
import lu.uni.svv.utils.GAWriter;
import lu.uni.svv.utils.PathManager;
import org.apache.commons.io.FileUtils;
import org.renjin.eval.EvalException;
import org.uma.jmetal.util.JMetalLogger;

import javax.script.ScriptException;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.List;


public class ModelUpdate {
	
	ArrivalsProblem problem;
	List<ArrivalsSolution> solutions= null;
	
	// Objects
	RManager R = null;
	
	//Variables
	public String trainingDataPath = "";
	public String outputPath = "";
	public String formula = "";
	public String testDataPath = "";
	public boolean opDebug = false;
	
	// output files
	public String modelResultFile = null;
	public String testResultFile = null;
	public String conditionResultFile = null;
	
	public int updates; // number of model updates
	public double probability = 0.5; // Unknown

	
	public ModelUpdate(ArrivalsProblem _problem, List<ArrivalsSolution> _solutions,
	                   String _outputPath,
	                   String _samplePath, String _testDataPath, String _formulaPath,
	                   String _scriptPath,
					   boolean _opDebug) throws Exception{
		problem = _problem;
		solutions = _solutions;
		outputPath = _outputPath;
		testDataPath = _testDataPath;
		updates = 0;
		opDebug = _opDebug;
		
		// copy training data from sampled data
		trainingDataPath = String.format("%s/workdata.csv", outputPath);
		if (!copySampledata(_samplePath, trainingDataPath))
			throw new Exception("Failed to copy sample data" + _samplePath);
		JMetalLogger.logger.info(String.format("Copied training data from %s to %s", _samplePath, trainingDataPath));
		
		// Loading formula
		formula = loadFormula(_formulaPath);
		if (formula == null) {
			throw new Exception("Failed to load formula in " + _formulaPath);
		}
		
		R = new RManager();
		this.preliminary(_scriptPath);
	}
	
	////////////////////////////////////////////////////////////////////////////////
	// base algorithm
	////////////////////////////////////////////////////////////////////////////////
	/**
	 * Run the second phase
	 * @throws IOException
	 */
	public void run() throws Exception {
		initializeModel();
		initProgress();
		checkStopCondition();
		while (updates < Settings.N_MODEL_UPDATES){
			updateProgress();
			addNewSamples();
			updateModel();
			// one model update at least
			if (this.checkStopCondition() && Settings.STOP_CONDITION) break;
			System.gc();
		}
		finishProgress();
	}
	
	/**
	 * add new data instances to the training data
	 * @throws Exception
	 */
	public void addNewSamples() throws Exception {
		JMetalLogger.logger.info("Add new samples...");
		int totalSample = Settings.N_SAMPLE_SOLUTIONS * solutions.size();
		System.out.print("Sampling WCETs: ...");
		List<int[]> sampledWCETs = sampleWCET(totalSample);
		System.out.println("Done");
		System.out.print("Evaluating new samples: ");

		int[] uncertainTasks = problem.getUncertainTasks();

		// evaluation
		int sampleID = 0;
		while(sampleID<totalSample){ // for (int sampleID=0; sampleID < totalSample; sampleID++){
			for (int solID=0; solID < solutions.size(); solID++){
				int deadline = this.evaluate(solutions.get(solID), sampledWCETs.get(sampleID), sampleID);
				String line = this.makeSampleLine(deadline, uncertainTasks, sampledWCETs.get(sampleID));
				this.addTrainingData(line);
				System.out.print(deadline);
				// JMetalLogger.logger.info(String.format("New data %d/%d: %s", sampleID, totalSample, line));
				sampleID++;
			}
		}
		System.out.println("...Done.");
	}
	
	////////////////////////////////////////////////////////////////////////////////
	// sub action functions
	////////////////////////////////////////////////////////////////////////////////
	public void preliminary(String _scriptPath) throws Exception {
		_scriptPath = PathManager.mappingArtifactLocation(_scriptPath);
		
		// load libraries
		R.loadLibrary("MASS");
		R.loadLibrary("MLmetrics");
		R.loadLibrary("nloptr");
		R.loadLibrary("stringr");
//		R.loadLibrary("magrittr");
		R.loadFile(_scriptPath+"/libs/lib_config.R");
		R.loadFile(_scriptPath+"/libs/lib_data.R");
		R.loadFile(_scriptPath+"/libs/lib_formula.R");
		R.loadFile(_scriptPath+"/libs/lib_metrics.R");
		R.loadFile(_scriptPath+"/libs/lib_evaluate.R");
		R.loadFile(_scriptPath+"/libs/lib_pruning.R");
		R.loadFile(_scriptPath+"/libs/lib_model.R");
		R.loadFile(_scriptPath+"/libs/lib_sampling.R");   // for random sampling
//		R.loadFile(_scriptPath+"/libs/lib_area.R");

		
		JMetalLogger.logger.info("Load input tasks info from " + Settings.INPUT_FILE);
		R.setVariable("TIME_QUANTA", Settings.TIME_QUANTA);
		R.setVariable("UNIT", 1);
		R.func("TASK_INFO", "load_taskInfo", Settings.INPUT_FILE, new RInterface.VAR("TIME_QUANTA"));
		
		// load training data
		JMetalLogger.logger.info("Loading training data from " + trainingDataPath);
		R.readCSV("training", trainingDataPath);
	}
	

	/**
	 * initializing code for checking progress ::
	 *      - load test data
	 *      - load test data for checking the early termination
	 *      - initialize number of updates
	 * @throws Exception
	 */
	public void initProgress() throws Exception {
		updates = 0;
	
		// preparing data for stop condition
		this.prepareTerminationData();
		
		// preparing test data
		if (Settings.USE_TEST_DATA){
			testResultFile = String.format("%s/workdata_test_result.csv", outputPath);
			this.loadTestData(testDataPath);
			this.checkByTestData();
		}
		
		// save termination results
		modelResultFile = String.format("%s/workdata_model_result.csv", outputPath);
		conditionResultFile = String.format("%s/workdata_termination_result.csv", outputPath);
	}
	
	/**
	 * check the progress
	 * @throws Exception
	 */
	public void updateProgress() throws Exception{
		// evaluate model with test data
		if (Settings.USE_TEST_DATA){
			this.checkByTestData();
		}
		R.writeNumericData("model.result", modelResultFile, updates!=0);
		updates++;
	}
	
	
	/**
	 * Initialize model
	 * @return
	 */
	public void initializeModel() throws ScriptException, EvalException{
		this.buildModel(formula);
		updateModelResult();
		probability = 0.5;
	}
	
	public void updateModel() throws ScriptException, EvalException{
		JMetalLogger.logger.info("update logistic regression " + updates + "/" + Settings.N_MODEL_UPDATES);
		
		// Learning model again with more data
		this.buildModel(formula);
		updateModelResult();
		updateTerminationData();
		probability = 0.5;
	}
	
	public boolean buildModel(String _formula) throws ScriptException, EvalException {
		int nTraining = R.getInt("nrow(training)");
		int nPositive = R.getInt("nrow(training[training$result==0,])");
		int nNegative = R.getInt("nrow(training[training$result==1,])");
		JMetalLogger.logger.info(String.format("Number of training data: %d (nPositive: %d, nNegative: %d)",nTraining, nPositive, nNegative));
		
		// learning logistic regression with simple formula
		R.func("base_model", "glm", new VAR(_formula), new VAR("family=\"binomial\""), new VAR("data=training"));

		JMetalLogger.logger.info(String.format("Model (%d/%d): %s", updates, Settings.N_MODEL_UPDATES, R.getModelText("base_model")));
		return true;
	}
	
	public void updateModelResult() throws ScriptException, EvalException{
		// keep coefficients
		R.setVariable("model.coef", new VAR("t(data.frame(base_model$coefficients))"));
		R.setVariable("colnames(model.coef)", new VAR("get_raw_names(names(base_model$coefficients))"));
		R.setVariable("model.result", new VAR(String.format("data.frame(nUpdate=%d, TrainingSize=nrow(training), model.coef)", updates)));
	}
	
	
	/**
	 * When finish phase 2 process, save all information
	 * @throws Exception
	 */
	public void finishProgress() throws Exception{
		if (Settings.USE_TEST_DATA){
			this.checkByTestData();
		}
		R.writeNumericData("model.result", modelResultFile, true);

		if (Settings.REMOVE_SAMPLES){
			try {
				FileUtils.deleteDirectory(new File(String.format("%s/_samples", outputPath)));
			} catch (IOException e) {
				System.out.println("Failed to delete results");
				e.printStackTrace();
			}
		}
		JMetalLogger.logger.info("Finished to run Phase 2");
	}
	
	////////////////////////////////////////////////////////////////////////
	// Related termination condition
	////////////////////////////////////////////////////////////////////////
	public boolean prepareTerminationData()  throws ScriptException, EvalException{
		JMetalLogger.logger.info("Preparing termination data ...");
		JMetalLogger.logger.info("Termination data is the same with training data");
		return true;
	}
	
	public boolean updateTerminationData()  throws ScriptException, EvalException{
		return true;
	}
	
	public boolean checkStopCondition() throws ScriptException, EvalException, Exception {
		R.func("cv_error", "kfoldCV", new VAR("base_model"), new VAR("training"), 10);
		R.setVariable("termination.item", new VAR(String.format("data.frame(nUpdate=%d, cv_error)", updates)));
		R.writeNumericData("termination.item", conditionResultFile, updates!=0);
		double probability = R.getDouble("1 - cv_error$CV.Precision.Sum");
		
		if (probability <= Settings.STOP_ACCEPT_RATE)
			return true;
		return false;
	}
	
	////////////////////////////////////////////////////////////////////////
	// Related test model
	////////////////////////////////////////////////////////////////////////
	/**
	 * load test data from the specified datafile
	 * @param _datafile
	 * @return
	 * @throws ScriptException
	 * @throws EvalException
	 */
	public boolean loadTestData(String _datafile)throws ScriptException, EvalException{
		R.readCSV("test.samples", _datafile);
		
		int nPositives = R.getInt("nrow(test.samples[test.samples$result==0,])");
		int nNegatives = R.getInt("nrow(test.samples[test.samples$result==1,])");
		JMetalLogger.logger.info(String.format("Loaded test data (nPositive: %d, nNegative: %d) from %s", nPositives, nNegatives, _datafile));
		
		return true;
	}
	
	/**
	 * check progress by test data
	 * @return
	 * @throws ScriptException
	 * @throws EvalException
	 */
	public boolean checkByTestData()throws ScriptException, EvalException {
		JMetalLogger.logger.info("Evaluating model by test data...");
		R.func("test.item","calculate_metrics", new VAR("base_model"), new VAR("test.samples"), probability);
		
		// record test result
		R.setVariable("test.item", new VAR(String.format("data.frame(nUpdate=%d, Probability=%f, test.item)", updates, probability)));
		R.writeNumericData("test.item", testResultFile, updates!=0);
		JMetalLogger.logger.info("Evaluating model by test data...Done.");
		return true;
	}
	

	////////////////////////////////////////////////////////////////////////
	// Sampling and evaluating
	////////////////////////////////////////////////////////////////////////
	/**
	 * Sampling WCET values
	 * @return
	 * @throws Exception
	 */
	public List<int[]> sampleWCET(int _nSample) throws Exception {
		List<int[]> samples = null;
		if (Settings.SAMPLING_METHOD.compareTo("random")==0){
			samples = samplingNewPointsRandom(_nSample);
		}
		else{
			samples = this.samplingNewPoints(_nSample, Settings.N_SAMPLE_CANDIDATES, probability);
		}
		return samples;
	}
	
	/**
	 * Sample new points based on euclidean distance
	 * @param nSample
	 * @param nCandidate
	 * @param P
	 * @return
	 */
	public List<int[]> samplingNewPoints(int nSample, int nCandidate, double P) throws Exception {
		String modelFile = String.format("%s/_samples/sample_%04d.md", outputPath, updates);
		File parent = new File(modelFile).getParentFile();
		if (!parent.exists()) parent.mkdirs();

		//save model info and sample
		R.writeCoefficients("base_model", modelFile);
		RScriptExecutor.distance_sampling(Settings.BASE_PATH, modelFile, trainingDataPath, nSample, nCandidate, P);

		// load data
		String datafile = String.format("%s.data", modelFile);
		return loadDataFromCSV(datafile);
	}

	/**
	 * Sample new points based on euclidean distance
	 *    execute R scripts inside of Java program via Renjin, but it occures error in the generate_samples_by_distance
	 *    currently this function is not using
	 * @param nSamples
	 * @param nCandidates
	 * @param P
	 * @return
	 */
	public List<int[]> samplingNewPoints_IN(int nSamples, int nCandidates, double P) throws Exception {
		List<int[]> samples = new ArrayList<>();

		//# execute sampling
		R.func("targetIDs", "get_base_names", new VAR("names(base_model$coefficients)"), new VAR("isNum=TRUE"));
		int[] targetIDs = R.getIntList("targetIDs");
		if (targetIDs.length>=2) {
			R.setVariable("yID", new VAR("targetIDs[length(targetIDs)]"));
			R.setVariable("XID", new VAR("targetIDs[1:(length(targetIDs)-1)]"));
		}
		else{
			R.setVariable("yID", new VAR("targetIDs[length(targetIDs)]"));
			R.setVariable("XID", new VAR("c()"));
		}

		R.func("fx", "generate_line_function",
				new VAR("base_model"), P, new VAR("yID"),
				new VAR("TASK_INFO$WCET.MIN[yID]"), new VAR("TASK_INFO$WCET.MAX[yID]"));

		R.func("sampled_data", "generate_samples_by_distance",
				new VAR("TASK_INFO"), new VAR("fx"),
				new VAR("yID"), new VAR("XID"), nSamples, nCandidates);

		for(int x=1; x<=nSamples; x++) {
			samples.add(R.getIntList(String.format("sampled_data[%d,]", x)));
		}
		return samples;
	}

	public List<int[]> loadDataFromCSV(String _filepath) throws Exception {
		List<int[]> rows = new ArrayList<>();
		
		File file = new File(_filepath);
		
		BufferedReader br = new BufferedReader(new FileReader(file));
		
		long lineCnt=0;
		String data;
		while ((data = br.readLine()) != null) {
			lineCnt++;
			if (lineCnt==1) continue;   // Remove CSV file header
			if (data.trim().length()==0) continue;
			
			String[] cols = data.split(",");
			int maxCOL = problem.getNumberOfVariables();
			int[] samples = new int[maxCOL];
			for(int c=0; c<maxCOL; c++){
				samples[c] = Integer.parseInt(cols[c]);
			}
			rows.add(samples);
		}
		// after loop, close reader
		br.close();
		
		return rows;
	}
	
	
	/**
	 * Sample new points by random
	 * @param nSample
	 * @return
	 */
	public List<int[]> samplingNewPointsRandom(int nSample) throws ScriptException, EvalException{
		List<int[]> samples = new ArrayList<>();
		R.func("sampled_data", "sample_by_random", nSample, new VAR("TASK_INFO"));
		for(int x=1; x<=nSample; x++) {
 			samples.add(R.getIntList(String.format("sampled_data[%d,]", x)));
		}
		return samples;
	}
	
	/**
	 * Evaluation a sample with a TimeListSolution in Scheduler
	 * @param _solution
	 * @param _sample
	 * @return
	 */
	public int evaluate(ArrivalsSolution _solution, int[] _sample, int sampleID){
		int result = 0;
		
		RTScheduler scheduler = RTScheduler.createObject(problem.Tasks, problem.SIMULATION_TIME, problem.schedulerType);
		scheduler.setSamples(_sample);
		scheduler.run(_solution.toArray(), problem.Priorities);
		
		// calculate fitness values
		Schedule[][] schedules = scheduler.getResult();
		ScheduleCalculator calculator = new ScheduleCalculator(schedules, Settings.TARGET_TASKS);
		int nDeadlines  = calculator.checkDeadlineMiss();
		result = (nDeadlines>0)?1:0;

		if (opDebug) storeForDebug(_solution, schedules, sampleID);
		return result;
	}
	
	/**
	 * append evaluated data into data file and R engine
	 * @param _itemText
	 */
	public void addTrainingData(String _itemText) throws Exception {
		// write into a file
		GAWriter writer = new GAWriter(trainingDataPath,null,true);
		writer.info(_itemText);
		writer.close();
		
		// update training data
		R.setVariable("training.item", new VAR(String.format("data.frame(t(c(%s)))", _itemText)));
		R.setVariable("colnames(training.item)", new VAR("colnames(training)"));
		R.addRow("training", "training.item");
	}

	public String makeSampleLine(int _answer, int[] _uncertainTasks, int[] _samples) {
		StringBuilder sb = new StringBuilder();
		sb.append(_answer);
		for(int x=0; x<_uncertainTasks.length; x++){
			if (_uncertainTasks[x]==0) continue;
			sb.append(",");
			sb.append(_samples[x]);
		}
		return sb.toString();
	}
	
	
	//////////////////////////////////////////////////////////////////////
	// Util functions
	//////////////////////////////////////////////////////////////////////
	
	public String loadFormula(String _formulaPath) {
		String formula = "";
		try {
			formula = new String(Files.readAllBytes(Paths.get(_formulaPath)), StandardCharsets.UTF_8).trim();
			JMetalLogger.logger.info("Loaded formula from " + _formulaPath);
		} catch (IOException e) {
			e.printStackTrace();
			return null;
		}
		return formula;
	}
	
	public static boolean copySampledata(String _sourcePath, String _targetPath)	{
		
		Path targetFile = Paths.get(_targetPath );
		File file = targetFile.toFile();
		if (!file.getParentFile().exists())
			file.getParentFile().mkdirs();
		
		Path sourceFile = Paths.get(_sourcePath);
		try {
			Files.copy(sourceFile, targetFile, StandardCopyOption.REPLACE_EXISTING);
		} catch (IOException e) {
			e.printStackTrace();
			return false;
		}
		
		return true;
	}

	public void storeForDebug(ArrivalsSolution _solution, Schedule[][] _schedules, long sID){
		String path = outputPath + "/debug";
		File fileObj = new File(path);
		if (!fileObj.exists()) fileObj.mkdirs();


		// Saving arrivals
		String filename = String.format("%s/sol%d_sample%d_arrivals.json", path, _solution.ID, sID);
		String arrivals = _solution.getVariablesString();
		GAWriter writer = new GAWriter(filename);
		writer.info(arrivals);
		writer.close();

		// Saving schedules
		filename = String.format("%s/sol%d_sample%d_schedules.json", path, _solution.ID, sID);
		writer = new GAWriter(filename);
		writer.write(Schedule.toString(_schedules));
		writer.close();

		// convert priority
		Integer[] priorities = problem.Priorities;
		StringBuilder sb = new StringBuilder("[ ");
		for (int x=0; x < priorities.length; x++) {
			sb.append(priorities[x]);
			if (x!=(priorities.length-1))
				sb.append(", ");
		}
		sb.append(" ]");

		// store priority
		filename = String.format("%s/sol%d_sample%d_priorities.json", path, _solution.ID, sID);
		writer = new GAWriter(filename);
		writer.info(sb.toString());
		writer.close();
	}

}