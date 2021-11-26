package lu.uni.svv.SAFE;

import lu.uni.svv.utils.PathManager;
import org.json.simple.parser.JSONParser;
import org.json.simple.JSONObject;

import lu.uni.svv.utils.ArgumentParser;
import lu.uni.svv.utils.ArgumentParser.DataType;
import org.uma.jmetal.util.JMetalLogger;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.lang.reflect.Field;
import java.util.Arrays;


public class Settings {
	public static String  INPUT_FILE          = "../res/industrial/ICS_20a.csv";
	public static String  BASE_PATH           = "../results/test";
	public static String  WORKNAME_P1         = "_phase1";
	public static String  WORKNAME_P2         = "_phase2";
	public static String  FORMULA_PATH        = "_formula";
	public static String  WORKNAME_EV         = "_roundtrip";
	public static String  WORKNAME_EX         = "";            // if set this value, output detailed data for debugging
	public static String  SCRIPT_PATH         = "scripts/R";   // the path that contains R scripts files
	public static int     RUN_NUM             = 0;
	public static int     RUN_MAX             = 0;
	
	// Scheduler
	public static String  SCHEDULER           = "SQMScheduler";
	public static String  TARGET_TASKLIST     = "";
	public static int[]   TARGET_TASKS        = null;
	public static double  TIME_QUANTA         = 0.1;
	public static int     TIME_MAX            = 3600000;
	public static boolean EXTEND_SCHEDULER    = true;
	public static int     N_CPUS              = 1;
	public static double  FD_BASE             = 2.0;
	public static double  FD_EXPONENT         = 10000.0;
	public static int     MAX_OVER_DEADLINE   = 0;
	public static boolean VERIFY_SCHEDULE     = false;
	public static boolean ALLOW_OFFSET_RANGE  = false;

	// GA
	public static int     GA_POPULATION       = 10;
	public static int     GA_ITERATION        = 1000;
	public static double  GA_CROSSOVER_PROB   = 0.7;
	public static String  GA_CROSSOVER_TYPE   = "one";
	public static double  GA_MUTATION_PROB    = 0.2;
	public static boolean SIMPLE_SEARCH       = false;
	public static String  GA_REPR_FITNESS     = "average";
	public static int     N_SAMPLE_WCET       = 20;
	
	// preprocessing
	public static boolean PRE_ONLY			  = false;
	public static boolean PRE_FEATURES        = false;
	public static boolean PRE_PRUNE           = false;
	public static boolean PRE_TEST            = false;
	public static int     N_TEST_SOLUTIONS    = 1000;
	public static int     PARTITION_ID        = 0;
	public static int     PARTITION_MAX       = 0;


	//Second phase
	public static int     N_TERMS             = 0;
	public static String  SAMPLING_METHOD     = "distance";
	public static int     N_MODEL_UPDATES     = 100;
	public static int     N_SAMPLE_SOLUTIONS  = 10;
	public static int     N_SAMPLE_CANDIDATES = 20;
	public static double  MODEL_PROB_PRECISION= 0.0001;
	
	public static String  P2_ALGORITHM        = "threshold";
	public static boolean STOP_CONDITION      = false;
	public static double  STOP_ACCEPT_RATE    = 0.0001;
	public static boolean USE_TEST_DATA       = false;
	public static String  TEST_DATA_PATH      = "";
	
	
	// special options
	public static boolean RESUME              = false;
	public static boolean DEBUG               = false;
	public static boolean REMOVE_SAMPLES	  = false;
	
	
	public Settings()
	{
	}
	
	public static void update(String[] args) throws Exception {
		// Setting arguments
		ArgumentParser parser = new ArgumentParser();
		parser.addOption(false,"Help", DataType.BOOLEAN, "h", "help", "Show how to use this program");
		parser.addOption(false,"SettingFile", DataType.STRING, null, "setting", "Base setting file.", "settings.json");
		parser.addOption(false,"SCRIPT_PATH", DataType.STRING, null, "scripts", "script path");
		parser.addOption(false,"INPUT_FILE", DataType.STRING, null, "data", "input data that including job information");
		parser.addOption(false,"BASE_PATH", DataType.STRING, "b", null, "Base path to save the result of experiments");
		parser.addOption(false,"WORKNAME_P1", DataType.STRING, "w1", null, "the work path for phase 1");
		parser.addOption(false,"WORKNAME_P2", DataType.STRING, "w2", null, "the work path for phase 2");
		parser.addOption(false,"WORKNAME_EV", DataType.STRING, "we", null, "the work path for evaluating");
		parser.addOption(false,"FORMULA_PATH", DataType.STRING, "wf", null, "the path for formula in second phase");
		parser.addOption(false,"RUN_NUM", DataType.INTEGER, null, "runID", "Specific run ID when you execute run separately");
		parser.addOption(false,"RUN_MAX", DataType.INTEGER, "r", null, "Maximum run times for GA");
		
		//scheduler
		parser.addOption(false,"SCHEDULER", DataType.STRING, "s", null, "Scheduler");
		parser.addOption(false,"TARGET_TASKLIST", DataType.STRING, "t", "targets","target tasks for search");
		parser.addOption(false,"TIME_QUANTA", DataType.DOUBLE, null, "quanta", "Scheduler time quanta");
		parser.addOption(false,"TIME_MAX", DataType.INTEGER, null, "max", "scheduler time max");
		parser.addOption(false,"EXTEND_SCHEDULER", DataType.BOOLEAN, null, "extendScheduler", "Scheduler extend when they finished simulation time, but the queue remains", true);
		parser.addOption(false,"FD_BASE", DataType.DOUBLE, null, "base", "base for F_D calculation");
		parser.addOption(false,"FD_EXPONENT", DataType.DOUBLE, null, "exponent", "exponent for F_D calculation");
		parser.addOption(false,"MAX_OVER_DEADLINE", DataType.INTEGER, null, "maxMissed", "The maximum value for the one execution's deadline miss(e-d)");
		parser.addOption(false,"N_CPUS", DataType.INTEGER, null, "cpus", "the number of CPUs");
		parser.addOption(false,"VERIFY_SCHEDULE", DataType.BOOLEAN, null, "verifySchedule", "Do verification process of schedule result when it set");
		parser.addOption(false,"ALLOW_OFFSET_RANGE", DataType.BOOLEAN, null, "allowOffsetRange", "Allow offset variation to the periodic tasks");
		
		// First Phase
		parser.addOption(false,"GA_POPULATION", DataType.INTEGER, "p", null, "Population for GA");
		parser.addOption(false,"GA_ITERATION", DataType.INTEGER, "i", null, "Maximum iterations for GA");
		parser.addOption(false,"GA_CROSSOVER_PROB", DataType.DOUBLE, "c", null, "Crossover rate for GA");
		parser.addOption(false,"GA_CROSSOVER_TYPE", DataType.STRING, null, "cType", "Crossover type for GA");
		parser.addOption(false,"GA_MUTATION_PROB", DataType.DOUBLE, "m", null, "Mutation rate for GA");
		parser.addOption(false,"SIMPLE_SEARCH", DataType.BOOLEAN, null, "simpleSearch", "Simple search mode, not using crossover and mutation just produce children randomly", false);
		parser.addOption(false,"GA_REPR_FITNESS", DataType.STRING, null, "reprFitness", "one type of fitness among average, maximum or minimum");
		parser.addOption(false,"N_SAMPLE_WCET", DataType.INTEGER, null, "nWCETs", "The number of samples that will extracted between minWCET and maxWCET");

		// preprocessing for phase2
		parser.addOption(false,"PRE_ONLY", DataType.BOOLEAN, null, "preOnly", "");
		parser.addOption(false,"PRE_FEATURES", DataType.BOOLEAN, null, "preFeatures", "");
		parser.addOption(false,"PRE_PRUNE", DataType.BOOLEAN, null, "prePrune", "");
		parser.addOption(false,"PRE_TEST", DataType.BOOLEAN, null, "preTest", "");
		parser.addOption(false,"N_TEST_SOLUTIONS", DataType.INTEGER, null, "nTest", "number of test data");
		parser.addOption(false,"PARTITION_ID", DataType.INTEGER, null, "partID", "partition number of generating test data");
		parser.addOption(false,"PARTITION_MAX", DataType.INTEGER, null, "partMAX", "number of partitions");
		
		//Second phase
		parser.addOption(false,"N_TERMS", DataType.INTEGER, null, "nTerms", "number of terms to select, if it is 0, we select the terms over mean importance");
		parser.addOption(false,"SAMPLING_METHOD", DataType.STRING, null, "samplingMethod", "Second phase run type {\"random\", \"distance\"}");
		parser.addOption(false,"N_MODEL_UPDATES", DataType.INTEGER, null, "nUpdates", "The iteration number to finish second phase");
		parser.addOption(false,"N_SAMPLE_SOLUTIONS", DataType.INTEGER, null, "nSamples", "The iteration number to finish second phase");
		parser.addOption(false,"N_SAMPLE_CANDIDATES", DataType.INTEGER, null, "nCandidates", "The number of sandidates to get one sample in second phase");
		parser.addOption(false,"MODEL_PROB_PRECISION", DataType.DOUBLE, null, "modelPrecision", "precision for the model line");
		
		parser.addOption(false,"P2_ALGORITHM", DataType.STRING, null, "p2", "phase 2 algorithms: refine, threshold");
		parser.addOption(false,"USE_TEST_DATA", DataType.BOOLEAN, null, "useTest", "a parameter whether use test data in phase 2", false);
		parser.addOption(false,"TEST_DATA_PATH", DataType.STRING, null, "testPath", "path of test data");
		parser.addOption(false,"STOP_CONDITION", DataType.BOOLEAN, "x", null, "Stop with stopping condition when this parameter set", false);
		parser.addOption(false,"STOP_ACCEPT_RATE", DataType.DOUBLE, null, "stopProb", "acceptance probability of second phase model");
		
		parser.addOption(false,"RESUME", DataType.BOOLEAN, null, "resume", "Option for resume", false);
		parser.addOption(false,"DEBUG", DataType.BOOLEAN, null, "debug", "Executing program for debugging", false);
		parser.addOption(false,"REMOVE_SAMPLES", DataType.BOOLEAN, null, "removeSamples", "Removing _sample directory", false);

		// parsing args;
		try{
			parser.parseArgs(args);
		}
		catch(Exception e)
		{
			System.out.println("Error: "+e.getMessage());
			System.out.println("");
			System.out.println(parser.getHelpMsg());
			System.exit(0);
		}
		
		if((Boolean)parser.getParam("Help")){
			System.out.println(parser.getHelpMsg());
			System.exit(1);
		}
		
		// Load settings from file
		String filename = (String)parser.getParam("SettingFile");
		Settings.updateSettings(filename);      //Update settings from the settings.json file.
		updateFromParser(parser);               //Update settings from the command parameters
		
		Settings.TARGET_TASKS = convertToIntArray(Settings.TARGET_TASKLIST);
		Arrays.sort(Settings.TARGET_TASKS);
	}
	
	public static int[] convertToIntArray(String commaSeparatedStr) {
		if (commaSeparatedStr.startsWith("["))
			commaSeparatedStr = commaSeparatedStr.substring(1);
		if (commaSeparatedStr.endsWith("]"))
			commaSeparatedStr = commaSeparatedStr.substring(0,commaSeparatedStr.length()-1);
		
		int[] result = null;
		if (commaSeparatedStr.trim().length()==0){
			result = new int[0];
		}
		else {
			String[] commaSeparatedArr = commaSeparatedStr.split("\\s*,\\s*");
			result = new int[commaSeparatedArr.length];
			for (int x = 0; x < commaSeparatedArr.length; x++) {
				result[x] = Integer.parseInt(commaSeparatedArr[x]);
			}
		}
		return result;
	}
	
	
	/**
	 * update setting information from json file
	 * @param _filepath
	 * @throws Exception
	 */
	public static void updateSettings(String _filepath) throws Exception {
		_filepath = PathManager.mappingArtifactLocation(_filepath);
		
		JMetalLogger.logger.info("Current Working Directory : "+ System.getProperty("user.dir"));
		JMetalLogger.logger.info("Loading base setting file from "+_filepath);
		
		// Parse Json
		String jsontext = readPureJsonText(_filepath);
		JSONParser parser = new JSONParser();
		JSONObject json = (JSONObject)parser.parse(jsontext);
		
		Field[] fields = Settings.class.getFields();
		for (Object key:json.keySet()) {  // for in setting file keys
			// find key in the Class fields
			Field field = findKeyField(key.toString());
			if (field == null) {
				throw new Exception("Cannot find variable \"" + key + "\" in setting Class.");
			}
			
			// set value from setting file to class
			field.setAccessible(true);
			Object type = field.getType();
			Object value = json.get(key);
			
			if (type == int.class || type == long.class) {
				field.set(Settings.class, Integer.parseInt(value.toString()));
			} else if (type == float.class || type == double.class) {
				field.set(Settings.class, Double.parseDouble(value.toString()));
			} else if (type == boolean.class) {
				field.set(Settings.class, value);
			} else if (type == int[].class) {
				if (value == null)
					field.set(Settings.class, new int[0]);
				else
					field.set(Settings.class, value);
			} else {
				field.set(Settings.class, value.toString());
			}
			field.setAccessible(false);
		}
	}
	
	public static void updateFromParser(ArgumentParser _parser) throws Exception {
		Field[] fields = Settings.class.getDeclaredFields();
		for (Field field:fields){
			String fieldName = field.getName();
			Object param = _parser.getParam(fieldName);
			if (param == null) continue;
			if (fieldName.compareTo("TARGET_TASKS")==0) continue;
			
			try {
				field.setAccessible(true);
				
				if (_parser.getDataType(fieldName)==DataType.STRING)
					field.set(null, (String)param);
				else if (_parser.getDataType(fieldName)==DataType.INTEGER)
					field.setInt(null, (Integer)_parser.getParam(fieldName));
				else if (_parser.getDataType(fieldName)==DataType.BOOLEAN)
					field.setBoolean(null, (Boolean)_parser.getParam(fieldName));
				else if (_parser.getDataType(fieldName)==DataType.DOUBLE)
					field.setDouble(null, (Double)_parser.getParam(fieldName));
				else {
					throw new Exception("Undefined data type for " + fieldName);
				}
				
				field.setAccessible(false);
			} catch (IllegalAccessException e) {
				e.printStackTrace();
			}
		}
	}
	
	private static Field findKeyField(String key){
		Field[] fields = Settings.class.getFields();
		
		Field field = null;
		for (Field item : fields) {
			if (key.compareTo(item.getName()) == 0) {
				field = item;
				break;
			}
		}
		return field;
	}
	
	public static int getCommentIdx(String s) {
		int idx = -1;
		
		if (s == null && s.length() <=1) return idx;
		
		boolean string = false;
		for(int x=0; x<s.length(); x++) {
			if (!string && s.charAt(x) == '\"'){string = true;	continue;}      // string start
			if (string)
			{
				if (s.charAt(x) == '\\') {x++; continue;}                 // escape
				if (s.charAt(x) == '\"') {string = false;	continue;}      // string end
				continue;
			}
			
			if (s.charAt(x) == '/' && s.charAt(x+1) == '/'){
				idx = x;
				break;
			}
		}
		
		return idx;
	}
	
	public static String readPureJsonText(String filename) throws IOException, Exception{
		StringBuilder content = new StringBuilder();
	
		BufferedReader br = new BufferedReader(new FileReader(filename));
		while (true) {
			String line = br.readLine();
			if (line == null) break;
			
			// remove comment
			int idx = getCommentIdx(line);
			if (idx >= 0){
				line = line.substring(0, idx);
			}
			
			// append them into content
			content.append(line);
			content.append(System.lineSeparator());
		}
		
		return content.toString();
	}
	
	public static String getString(){
		Field[] fields = Settings.class.getFields();
		
		StringBuilder sb = new StringBuilder();
		sb.append("---------------------Settings----------------------\n");
		for (Field field:fields){
			sb.append(String.format("%-20s: ",field.getName()));
			
			field.setAccessible(true);
			Object value;
			try {
				value = field.get(Settings.class);
			}catch(IllegalAccessException e){
				value = "";
			}
			if (value instanceof Integer) sb.append((Integer)value);
			if (value instanceof Double) sb.append((Double)value);
			if (value instanceof Boolean) sb.append((Boolean)value);
			if (value instanceof String){
				sb.append("\"");
				sb.append((String)value);
				sb.append("\"");
			}
			if (value instanceof int[]){
				sb.append("[");
				for (int x=0; x<((int[]) value).length; x++){
					if (x!=0) sb.append(", ");
					sb.append(((int[])value)[x]);
				}
				sb.append("]");
			}
			
			sb.append("\n");
		}
		sb.append("---------------------------------------------------\n\n");
		
		return sb.toString();
	}
	
	public static void displaySettings(){
		JMetalLogger.logger.info("[CommonVariables]");
		JMetalLogger.logger.info("INPUT_FILE          : "+ Settings.INPUT_FILE);
		JMetalLogger.logger.info("BASE_PATH           : "+ Settings.BASE_PATH);
		JMetalLogger.logger.info("WORKNAME_P1         : "+ Settings.WORKNAME_P1);
		JMetalLogger.logger.info("WORKNAME_P2         : "+ Settings.WORKNAME_P2);
		JMetalLogger.logger.info("FORMULA_PATH        : "+ Settings.FORMULA_PATH);
		JMetalLogger.logger.info("WORKNAME_EV         : "+ Settings.WORKNAME_EV);
		JMetalLogger.logger.info("WORKNAME_EX         : "+ Settings.WORKNAME_EX);
		JMetalLogger.logger.info("RUN_MAX             : "+ Settings.RUN_MAX);
		JMetalLogger.logger.info("RUN_NUM             : "+ Settings.RUN_NUM);
		JMetalLogger.logger.info("");
		// Scheduler variables
		JMetalLogger.logger.info("");
		JMetalLogger.logger.info("[Scheduler]");
		JMetalLogger.logger.info("SCHEDULER           : "+  Settings.SCHEDULER);
		JMetalLogger.logger.info("TARGET_TASKS        : "+  Settings.TARGET_TASKLIST);
		JMetalLogger.logger.info("N_CPUS              : "+  Settings.N_CPUS);
		JMetalLogger.logger.info("TIME_QUANTA         : "+  Settings.TIME_QUANTA);;
		JMetalLogger.logger.info("TIME_MAX            : "+  Settings.TIME_MAX);
		JMetalLogger.logger.info("EXTEND_SCHEDULER    : "+  Settings.EXTEND_SCHEDULER);
		JMetalLogger.logger.info("FD_BASE             : "+  Settings.FD_BASE);
		JMetalLogger.logger.info("FD_EXPONENT         : "+  Settings.FD_EXPONENT);
		JMetalLogger.logger.info("");
		// Phase2 variables
		JMetalLogger.logger.info("[Phase 2]");
		JMetalLogger.logger.info("N_MODEL_UPDATES     : "+ Settings.N_MODEL_UPDATES);
		JMetalLogger.logger.info("N_SAMPLE_WCET       : "+ Settings.N_SAMPLE_WCET);
		JMetalLogger.logger.info("N_SAMPLE_CANDIDATES : "+ Settings.N_SAMPLE_CANDIDATES);
		JMetalLogger.logger.info("MODEL_PROB_PRECISION: "+ Settings.MODEL_PROB_PRECISION);
		JMetalLogger.logger.info("");
		JMetalLogger.logger.info("P2_ALGORITHM        : "+ Settings.P2_ALGORITHM);
		JMetalLogger.logger.info("USE_TEST_DATA       : "+ Settings.USE_TEST_DATA);
		JMetalLogger.logger.info("TEST_DATA_PATH      : "+ Settings.TEST_DATA_PATH);
		JMetalLogger.logger.info("STOP_CONDITION      : "+ Settings.STOP_CONDITION);
		JMetalLogger.logger.info("STOP_ACCEPT_RATE    : " + Settings.STOP_ACCEPT_RATE);
		JMetalLogger.logger.info("");
	}
}
