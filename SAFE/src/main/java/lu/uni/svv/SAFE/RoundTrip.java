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
import org.uma.jmetal.util.pseudorandom.JMetalRandom;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Conducting Round-Trip test
 *    - generate Arrivals by random
 *    - generate sample WCETs from the range of an approach result
 *    - simulate and save the results
 * Related settings:
 *    - BASE_PATH (-b): the path where had given the target folder of phase 1
 *    - N_TEST_SOLUTIONS (--nTest): number of arrival time solutions to test
 *    - N_SAMPLE_WCET (--nWCETs): number of WCET samples to test
 *    - WORKNAME_P2 (-w2): path to load data (phase2 result directory)
 *    - WORKNAME_EV (-we): output path to be stored the results and the generated samples
 *    - N_MODEL_UPDATES (--nUpdates): number of updated model in phase 2
 *    - N_CPUS (--cpus): number of cpu, input for the simulator
 *    - TIME_MAX (--max): simulation time, if it is set 0, the simulation time will be calculated from the input, it should be the same value with phase 1
 *    - TIME_QUANTA (--quanta): time tick of simulator, it should be the same value with phase 1
 *    - SCHEDULER (-s): the name of scheduler class
 *    - INPUT_FILE: user cannot decide which input will be used. input_reduced.csv or input.csv in the BASE_PATH will be used.
 *    - RESUME (--resume): if this value sets true, RoundTrip starts from the point where it stopped
 *    - PARTITION_ID (--partID): partition ID
 *    - PARTITION_MAX (--partMAX): maximum number of partitions
 * Resources:
 *    - <BASE_PATH>/input.csv or BASE_PATH/input_reduced.csv
 *    - <BASE_PATH>/<WORKNAME_P2>/workdata_model_result.csv
 * Output:
 *    - <BASE_PATH>/<WORKNAME_EV>/arrivals.list
 *    - <BASE_PATH>/<WORKNAME_EV>/WCET.csv
 *    - <BASE_PATH>/<WORKNAME_EV>/result.csv
 */
public class RoundTrip {
	
	public static String selectInput(){
		// input_file setting
		String filename = String.format("%s/input_reduced.csv",Settings.BASE_PATH);
		File inputFile = new File(filename);
		if (!inputFile.exists()){
			filename = String.format("%s/input.csv",Settings.BASE_PATH);
		}
		return filename;
	}
	
	public static void main(String[] args) throws Exception{
		// Environment Settings
		Initializer.initLogger();
		Settings.update(args);
		
		// load input
		Settings.INPUT_FILE = selectInput();
		TaskDescriptor[] input = TaskDescriptors.loadFromCSV(Settings.INPUT_FILE, Settings.TIME_MAX, Settings.TIME_QUANTA);
		
		// update dynamic settings
		Initializer.updateSettings(input);
		Initializer.verify();

		Integer[] priorities = TaskDescriptors.getPriorities(input);
		
		//run RoundTrip
		ArrivalsProblem problem = new ArrivalsProblem(input, priorities, Settings.TIME_MAX, Settings.SCHEDULER);
		RoundTrip tester = new RoundTrip(problem, input, Settings.WORKNAME_EV, Settings.WORKNAME_P2, Settings.N_MODEL_UPDATES);
		tester.run(Settings.N_TEST_SOLUTIONS, Settings.N_SAMPLE_WCET, Settings.RESUME, Settings.PARTITION_ID, Settings.PARTITION_MAX);
	}
	
	////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////
	
	public ArrivalsProblem problem;
	public TaskDescriptor[] tasks;
	public String outputDir;
	public int[] minRange;
	public int[] maxRange;
	
	public RoundTrip(ArrivalsProblem _problem, TaskDescriptor[] _input,
	                 String _outputFolder, String _inputDir, int targetUpdate) throws Exception{
		problem = _problem;
		tasks = _input;
		outputDir = _outputFolder;
		
		String filename = String.format("%s/%s/workdata_model_result.csv", Settings.BASE_PATH, _inputDir);
		setRange(filename, targetUpdate);
	}
	
	/**
	 * main procedure
	 * @param _nArrivals
	 * @param _nWCET
	 * @throws Exception
	 */
	public void run(int _nArrivals, int _nWCET, boolean _resume, int _partID, int _partMAX) throws Exception{
		JMetalLogger.logger.info("Generating arrival times...");
		List<ArrivalsSolution> solutions = generateTestData(_nArrivals, _resume);
		
		JMetalLogger.logger.info("Generating WCET samples ...");
		List<int[]> WCETs = generateWCETs(_nWCET, _resume);

		if (_partID==0) {
			roundTrip(WCETs, solutions, _resume);
		}
		else{
			roundTrip_part(WCETs, solutions, _partID, _partMAX, _resume);
		}
		JMetalLogger.logger.info("Done.");
	}
	
	/**
	 * generate test Arrivals data and output the results
	 * @param _nTest
	 * @return
	 */
	public List<ArrivalsSolution> generateTestData(int _nTest, boolean _resume)throws Exception{
		String filename = String.format("%s/%s/arrivals.list", Settings.BASE_PATH, outputDir);
		if (_resume && new File(filename).exists()){
			List<ArrivalsSolution> data = problem.loadSolutions(filename);
			if (data.size()!=_nTest){
				throw new Exception("The number of test data is different");
			}
			return data;
		}
		
		String header = "ID\tArrivals";
		GAWriter writer = new GAWriter(filename, header);
		List<ArrivalsSolution> data = new ArrayList<>();
		for(int i=0; i<_nTest; i++) {
			ArrivalsSolution solution = problem.createSolution();
			data.add(solution);
			
			writer.write(String.format("%d\t", i));
			writer.write(solution.getVariablesStringInline());
			writer.write("\n");
		}
		writer.close();
		return data;
	}
	/**
	 * generate test WCET data and output the results
	 * @param _n number of samples to generate
	 * @return
	 */
	public List<int[]> generateWCETs(int _n, boolean _resume) throws Exception{
		String filename = String.format("%s/%s/WCET.csv", Settings.BASE_PATH, outputDir);
		if (_resume && new File(filename).exists()) {
			List<int[]> WCETs = loadWCETs(filename);
			if (WCETs.size() != _n) {
				throw new Exception("The number of WCET samples is different.");
			}
			JMetalLogger.logger.info("Loaded " + WCETs.size() + " WCETs from "+ filename);
			return WCETs;
		}
		
		JMetalRandom random = JMetalRandom.getInstance();
		
		// make header
		StringBuilder sb = new StringBuilder("ID");
		for(int t=0; t<problem.Tasks.length; t++){
			sb.append(",T");
			sb.append(t+1);
		}
		GAWriter writer = new GAWriter(filename, sb.toString());
		List<int[]> list = new ArrayList<>();
		
		for(int x=0; x<_n; x++){
			// sampling
			int[] values = new int[problem.Tasks.length];
			for(int t=0; t<problem.Tasks.length; t++){
				values[t] = random.nextInt(minRange[t], maxRange[t]);
			}
			list.add(values);
			
			// output into file
			saveWCET(x, values, writer);
		}
		return list;
	}
	
	public List<int[]> loadWCETs(String _filename) throws Exception{
		List<int[]> list = new ArrayList<>();
		
		// load test file names
		BufferedReader reader = new BufferedReader(new FileReader(_filename));
		String line = reader.readLine();   // throw header
		while(line!=null){
			line = reader.readLine();
			if (line==null || line.trim().length()==0) break;
			String[] items = line.trim().split(",");
			int[] WCETset = new int[items.length-1];
			for(int i=0; i<WCETset.length; i++) {
				WCETset[i] = Integer.parseInt(items[i+1]);
			}
			list.add(WCETset);
		}
		return list;
	}
	
	/**
	 * Evaluation a sample with a TimeListSolution in Scheduler
	 * @param _solution
	 * @return
	 */
	public Schedule[][] simulate(ArrivalsSolution _solution, int[] samples){
		// Create Scheduler instance
		RTScheduler scheduler = RTScheduler.createObject(problem.Tasks, problem.SIMULATION_TIME, problem.schedulerType);
		scheduler.setSamples(samples);
		scheduler.run(_solution.toArray(), problem.Priorities);
		Schedule[][] schedules = scheduler.getResult();
		
		return schedules;
	}
	
	/**
	 * Round Trip function
	 * @param _WCETs
	 * @param _solutions
	 */
	public void roundTrip(List<int[]> _WCETs, List<ArrivalsSolution> _solutions, boolean _resume) throws IOException {
		// setting file
		String filename = String.format("%s/%s/result.csv", Settings.BASE_PATH, outputDir);

		String header = makeHeader();
		int[] completed = new int[]{-1,-1};
		if(_resume){
			completed = loadLatestStatus(filename);
		}
		GAWriter writer = new GAWriter(filename, header, _resume);
		
		// evalue
		for (int wID=0; wID<_WCETs.size(); wID++){
			if (wID<completed[0]) continue;
			JMetalLogger.logger.info("evaluating " + wID + "th WCET ...");
			int[] WCET = _WCETs.get(wID);
			for (int sID=0; sID<_solutions.size(); sID++){
				if (wID==completed[0] && sID<=completed[1]) continue;
//				JMetalLogger.logger.info("evaluating " + wID + "th WCET ("+sID+")...");
				ArrivalsSolution sol = _solutions.get(sID);
				Schedule[][] schedules = simulate(sol, WCET);
				String line = makeResultLine(wID, sID, schedules);
				writer.info(line);
				if (sID%20==0) System.gc();
			}
			System.gc();
		}
		
	}

	/**
	 * Round Trip function
	 * @param _WCETs
	 * @param _solutions
	 */
	public void roundTrip_part(List<int[]> _WCETs, List<ArrivalsSolution> _solutions, int _partID, int _partMAX, boolean _resume) throws IOException {
		// setting file
		String filename = String.format("%s/%s/result_part%02d.csv", Settings.BASE_PATH, outputDir, _partID);
		int[] completed = new int[]{-1,-1};
		if(_resume){
			completed = loadLatestStatus(filename);
		}

		String header = makeHeader();
		GAWriter writer = new GAWriter(filename, header, _resume);

		int numMax= _WCETs.size() * _solutions.size();
		int size = numMax/_partMAX;
		int startNum = size * (_partID-1);
		int endNum = startNum + size;

		// evalue
		int wIDprev = -1;
		for (int cnt=startNum; cnt < endNum; cnt++){
			int wID = cnt/_solutions.size();
			int sID = cnt%_solutions.size();

			if (wID<completed[0]) continue;
			if (wID==completed[0] && sID<=completed[1]) continue;

			if (wID != wIDprev) {
				JMetalLogger.logger.info("evaluating " + wID + "th WCET with ...");
				wIDprev = wID;
			}

			int[] WCET = _WCETs.get(wID);
			ArrivalsSolution sol = _solutions.get(sID);

			Schedule[][] schedules = simulate(sol, WCET);
			String line = makeResultLine(wID, sID, schedules);
			writer.info(line);
			if (sID%20==0) System.gc();
		}
	}
	
	private int[] loadLatestStatus(String _filename) throws IOException{
		int[] IDs = new int[]{-1,-1};
		
		List<String> lines = new ArrayList<>();
		// load from last line
		RandomAccessFile randomAccessFile = null;
		
		try {
			File file = new File(_filename);
			randomAccessFile = new RandomAccessFile(file, "rw");
			long fileLength = file.length() - 1;
			long pointer = fileLength;
			while (lines.size()<2) {
				String line = readLastLine(randomAccessFile, pointer);
				pointer = pointer - line.length() - 1;
				lines.add(line);
			}

			// Get ID
			String line = lines.get(1);
			String[] items = line.split(",");
			IDs[0] = Integer.parseInt(items[0]);
			IDs[1] = Integer.parseInt(items[1]);
			
			if (lines.get(0).length()!=0) {  //if the last line is not '\n', remove the line
				removeLastLine(randomAccessFile, fileLength);
			}
			
		}finally{
			if(randomAccessFile != null){
				try {
					randomAccessFile.close();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		}
		return IDs;
	}

	private String readLastLine(RandomAccessFile file, long startPoint) throws IOException{
		StringBuilder builder = new StringBuilder();
		long pointer = startPoint;
		for (; pointer >= 0; pointer--) {
			file.seek(pointer);
			// read from the last one char at the time
			char c =  (char) file.read();
			// break when end of the line
			if (c == '\n') {
				// Since line is read from the last so it
				break;
			}
			builder.append(c);
		}
		
		return builder.reverse().toString();
	}
	
	private void removeLastLine(RandomAccessFile file, long startPoint) throws IOException{
		long pointer = startPoint;
		for (; pointer >= 0; pointer--) {
			file.seek(pointer);
			// read from the last one char at the time
			char c = (char) file.read();
			// break when end of the line
			if (c == '\n') {
				break;
			}
		}
		file.setLength(pointer+1);
	}
	
	private String makeHeader(){
		StringBuilder sb = new StringBuilder("WID,solutionID,DM,numTasks,numExecutions,sumSizeDM");
		for(int tID=0; tID<tasks.length; tID++){
			sb.append(",");
			sb.append("T");
			sb.append(tID+1);
			sb.append("num");
		}
		for(int tID=0; tID<tasks.length; tID++){
			sb.append(",");
			sb.append("T");
			sb.append(tID+1);
			sb.append("size");
		}
		return sb.toString();
	}
	
	private String makeResultLine(int _wID, int _sID, Schedule[][] _schedules){
		//get info to save
		ScheduleCalculator cals = new ScheduleCalculator(_schedules, Settings.TARGET_TASKS);
		int[] countDMs = cals.countDeadlineMissByTask();
		int[] sizeDMs = cals.sumDeadlineMissSizeByTask();
		
		int countTasks = 0;
		int countExecs = 0;
		int sumDM = 0;
		for(int x=0; x<sizeDMs.length; x++){
			countTasks += (sizeDMs[x]>0)?1:0;
			countExecs += countDMs[x];
			sumDM += sizeDMs[x];
		}
		int DM = countTasks>0?1:0;
	
		// write result
		String prefix =  String.format("%d,%d,%d,%d,%d,%d", _wID, _sID, DM, countTasks, countExecs, sumDM);
		StringBuilder sb = new StringBuilder(prefix);
		
		for(int x=0; x<countDMs.length; x++){
			sb.append(",");
			sb.append(countDMs[x]);
		}
		for(int x=0; x<sizeDMs.length; x++){
			sb.append(",");
			sb.append(sizeDMs[x]);
		}
		return sb.toString();
	}
	/**
	 * Convert list to string with ',' delimiter
	 * This function is for the dependency and triggering list
	 * @return
	 */
	public void saveWCET(int _wID, int[] _values, GAWriter _writer){
		// convert to text
		StringBuilder sb = new StringBuilder();
		sb.append(_wID);
		for (int i=0; i<_values.length; i++){
			sb.append(",");
			sb.append(_values[i]);
		}
		// write into a file
		_writer.info(sb.toString());
	}
	
	/**
	 * Set WCET ranges to sample
	 *      update member variables minRange and maxRange
	 * @param _nUpdates
	 */
	public void setRange(String _loadFile, int _nUpdates) throws Exception{
		// load max values from the model line
		int[][] maxValues = loadMaxRanges(_loadFile, _nUpdates);
		
		// Set min range and max Range
		minRange = new int[tasks.length];
		maxRange = new int[tasks.length];
		for (int t=0; t<tasks.length; t++){ minRange[t] = tasks[t].WCET; }
		for (int t=0; t<tasks.length; t++){ maxRange[t] = tasks[t].MaxWCET; }
		
		// update max WCET values
		for (int x=0; x<maxValues[0].length; x++){
			int tID = maxValues[0][x];
			maxRange[tID-1] = maxValues[1][x];
		}
	}
	private List<Integer> findTaskIndexes(String[] _titles){
		List<Integer> indexes = new ArrayList<>();
		for (int idx=0; idx<_titles.length; idx++){
			if (!_titles[idx].startsWith("Px")) continue;
			indexes.add(idx);
		}
		return indexes;
	}
	private int[] getTaskIDs(String[] _titles, List<Integer> _idxs){
		int[] IDs = new int[_idxs.size()];
		for (int x=0; x<_idxs.size(); x++){
			int idx = _idxs.get(x);
			String idStr = _titles[idx].substring(4, _titles[idx].length()-1);
			IDs[x] = Integer.parseInt(idStr);
		}
		return IDs;
	}
	private int[] getMax(String[] _cols, List<Integer> _idxs){
		int[] values = new int[_idxs.size()];
		for(int x=0; x<_idxs.size(); x++){
			String cv = _cols[_idxs.get(x)];
			if (cv.contains("NaN") || cv.contains("NULL") || cv.contains("NA")){
				values[x] = -1;
			}
			else{
				values[x] = (int) Math.floor(Double.parseDouble(cv));;
			}
		}
		return values;
	}
	public int[][] loadMaxRanges(String _filename, int _targetUpdate) throws Exception {
		int[][] results = null;
		BufferedReader br = new BufferedReader(new FileReader(new File(_filename)));
		
		// find task IDs
		String title = br.readLine();
		String[] titles = title.split(",");
		titles[titles.length-1] = titles[titles.length-1].trim();
		
		List<Integer> indexes = findTaskIndexes(titles);
		int[] taskIDs = getTaskIDs(titles, indexes);
		int[] maxWCET = null;
		
		// get max WCET values at _targetUpdate
		while (true) {
			String line = br.readLine();
			if (line == null || line.length() == 0) break;
			
			String[] cols = line.split(",");
			int update=(int)Double.parseDouble(cols[0]);
			if (update != _targetUpdate) continue;
			
			maxWCET = getMax(cols, indexes);
			break;
		}
		
		// mix the results
		if (!(maxWCET==null)){
			// check error
			for (int wcet : maxWCET) {
				if (wcet == -1) {
					throw new Exception("Invalid WCET values (NaN, NULL, or NA) on the model result: " + _filename);
				}
			}
			
			results = new int[2][];
			results[0] = taskIDs;
			results[1] = maxWCET;
		}
		return results;
	}
	
}
