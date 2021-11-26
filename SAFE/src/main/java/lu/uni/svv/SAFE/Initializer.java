package lu.uni.svv.SAFE;

import java.io.File;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.logging.ConsoleHandler;
import java.util.logging.LogRecord;
import java.util.logging.SimpleFormatter;
import lu.uni.svv.SAFE.scheduler.RTScheduler;
import lu.uni.svv.SAFE.task.TaskDescriptor;
import lu.uni.svv.SAFE.task.TaskDescriptors;
import lu.uni.svv.SAFE.task.TaskType;
import lu.uni.svv.utils.GAWriter;
import org.uma.jmetal.util.JMetalLogger;


public class Initializer {
	
	/**
	 * log formatter for jMetal
	 */
	public static SimpleFormatter formatter = new SimpleFormatter(){
		private static final String format = "[%1$tF %1$tT] %2$s: %3$s %n";
		
		@Override
		public synchronized String format(LogRecord lr) {
			return String.format(format,
					new Date(lr.getMillis()),
					lr.getLevel().getLocalizedName(),
					lr.getMessage()
			);
		}
	};
	
	public static TaskDescriptor[] init(String[] args ) throws Exception {
		// Environment Settings
		Initializer.initLogger();
		Settings.update(args);
		
		// load input
		TaskDescriptor[] input = TaskDescriptors.loadFromCSV(Settings.INPUT_FILE, Settings.TIME_MAX, Settings.TIME_QUANTA);
		
		// update dynamic settings
		Initializer.updateSettings(input);
		Initializer.verify();
		
		return input;
	}
	
	public static TaskDescriptor[] reinit(String[] args) throws Exception {
		// Environment Settings
		Initializer.initLogger();
		Settings.update(args);
		
		// BASE_PATH setting
		if(Settings.RUN_NUM!=0){
			Settings.BASE_PATH = String.format("%s/Run%02d", Settings.BASE_PATH, Settings.RUN_NUM);
		}
		
		// input_file setting
		File inputFile = new File(String.format("%s/input_reduced.csv",Settings.BASE_PATH));
		if (inputFile.exists()){
			Settings.INPUT_FILE = inputFile.getPath();
		}
		else {
			Settings.INPUT_FILE = String.format("%s/input.csv",Settings.BASE_PATH);
		}
		
		// load input
		TaskDescriptor[] input = TaskDescriptors.loadFromCSV(Settings.INPUT_FILE, Settings.TIME_MAX, Settings.TIME_QUANTA);
		
		// update dynamic settings
		Initializer.updateSettings(input);
		Initializer.verify();
		
		return input;
	}
	
	public static void printInput(String changed, TaskDescriptor[] _inputs){
		String settingStr = Settings.getString();
		System.out.print(settingStr);
		
		// multi run mode and single run mode with runID 1)
		GAWriter writer = new GAWriter(Settings.BASE_PATH + "/settings.txt");
		writer.info(settingStr);
		writer.close();
			
		String strInput = TaskDescriptors.convertToCSV(_inputs,Settings.TIME_QUANTA);
		writer = new GAWriter(Settings.BASE_PATH + "/input.csv");
		writer.info(strInput);
		writer.close();
		
		if (changed != null) {
			writer = new GAWriter(Settings.BASE_PATH+"/changed.txt");
			writer.print(changed);
			writer.close();
		}
	}
	
	
	
	/**
	 *  initLogger: basic setting for jMetal
	 */
	public static void initLogger(){
		JMetalLogger.logger.setUseParentHandlers(false);
		ConsoleHandler handler = new ConsoleHandler();
		handler.setFormatter(formatter);
		JMetalLogger.logger.addHandler(handler);
	}
	
	
	/**
	 * Return simulation time based on TIME_QUANTA unit
	 * @param input
	 * @return
	 */
	public static int calculateSimulationTime(TaskDescriptor[] input){
		int simulationTime = 0;
		
		if (Settings.TIME_MAX == 0) {
			// calculate simulation time for all task period (no matter the task type)
			//			long[] array = new long[input.length];
			//			for(int x=0; x<input.length; x++){
			//				array[x] = input[x].Period;
			//			}
			//			simulationTime = (int) RTScheduler.lcm(array);
			
			// Too large simulation time :: calculate different way.
			//			if (simulationTime > 100000){  // by considering time unit
			
			// Those task time information appplied TIME_QUANTA to make int type
			// calculate LCM for periodic tasks only
			List<Long> periodArray = new ArrayList<>();
			for(int x=0; x<input.length; x++){
				if (input[x].Type != TaskType.Periodic) continue;
				periodArray.add((long)(input[x].Period));
			}
			long[] array = new long[periodArray.size()];
			for(int x=0; x<periodArray.size(); x++) {
				array[x] = periodArray.get(x);
			}
			int periodicLCM = (int) RTScheduler.lcm(array);
			
			// get maximum inter arrival time among non-periodic tasks
			int maxInterArrivalTime = 0;
			for(int x=0; x<input.length; x++){
				if (input[x].Type == TaskType.Periodic) continue;
				maxInterArrivalTime = Math.max(maxInterArrivalTime, input[x].MaxIA);
			}
			
			// select max value among two simulation time
			simulationTime = Math.max(periodicLCM, maxInterArrivalTime);
		}
		else{
			simulationTime = (int) (Settings.TIME_MAX * (1/Settings.TIME_QUANTA));
		}
		
		return simulationTime;
	}
	
	
	public static void updateSettings(TaskDescriptor[] input) throws Exception{
		// update specific options
		if (Settings.GA_MUTATION_PROB==0)
			Settings.GA_MUTATION_PROB = 1.0/input.length;
		
		// Set SIMULATION_TIME
		int simulationTime = Initializer.calculateSimulationTime(input);
		if (simulationTime < 0) {
			System.out.println("Cannot calculate simulation time");
			throw new Exception("Cannot calculate simulation time");
		}
		
		Settings.TIME_MAX = simulationTime; // already applied time unit
		Settings.MAX_OVER_DEADLINE = (int)(Settings.MAX_OVER_DEADLINE * (1/Settings.TIME_QUANTA));
	}
	
	public static void verify() throws Exception {
		// Create Scheduler instance
		RTScheduler.checkClass(Settings.SCHEDULER);
	}
	
	public static long find_max_deadline(TaskDescriptor[] input){
		long max_dealine=0;
		for (TaskDescriptor task:input){
			if (task.Deadline> max_dealine)
				max_dealine = task.Deadline;
		}
		return max_dealine;
	}
}
