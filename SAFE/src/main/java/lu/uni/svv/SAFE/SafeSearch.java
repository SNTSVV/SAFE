package lu.uni.svv.SAFE;

import lu.uni.svv.SAFE.phase1.*;
import lu.uni.svv.SAFE.phase1.search.RandomSearch;
import lu.uni.svv.SAFE.phase1.search.SteadyStateGeneticAlgorithm;
import lu.uni.svv.SAFE.task.TaskDescriptor;
import lu.uni.svv.SAFE.task.TaskDescriptors;
import lu.uni.svv.utils.GAWriter;
import lu.uni.svv.utils.Monitor;
import org.uma.jmetal.operator.CrossoverOperator;
import org.uma.jmetal.operator.MutationOperator;
import org.uma.jmetal.operator.SelectionOperator;
import org.uma.jmetal.operator.impl.selection.BinaryTournamentSelection;
import org.uma.jmetal.util.AlgorithmRunner;
import org.uma.jmetal.util.JMetalLogger;
import org.apache.commons.io.FileUtils;
import java.io.File;
import java.io.IOException;
import java.util.List;


public class SafeSearch {
	
	public static void main( String[] args ) throws Exception
	{
		TaskDescriptor[] input = Initializer.init(args);
		Integer[] priorities = TaskDescriptors.getPriorities(input);
		
		// create problem
		ArrivalsProblem problem = new ArrivalsProblem(input, priorities, Settings.TIME_MAX, Settings.SCHEDULER);
		
		// Run mode selector
		if (Settings.RUN_MAX==0){
			run(0, problem);
		}
		else if(Settings.RUN_NUM!=0){
			Settings.BASE_PATH = String.format("%s/Run%02d", Settings.BASE_PATH, Settings.RUN_NUM);
			run(Settings.RUN_NUM, problem);
		}
		else{
			String BasePath = Settings.BASE_PATH;
			for (int run = 1; run <= Settings.RUN_MAX; run++) {
				Settings.RUN_NUM = run;
				Settings.BASE_PATH = String.format("%s/Run%02d", BasePath, Settings.RUN_NUM);
				run(Settings.RUN_NUM, problem);
			}
		}
	}
	
	public static void run(int _runID, ArrivalsProblem problem){
		// Prepare working path
		File dir = new File(Settings.BASE_PATH);
		if (dir.exists()) {
			try {
				FileUtils.deleteDirectory(dir);
			} catch (IOException e) {
				System.out.println("Failed to delete results");
				e.printStackTrace();
			}
		}
		// Save experiment environment
		Initializer.printInput(null, problem.Tasks);
		
		// do experiment
		experiment(_runID, problem, Settings.GA_POPULATION, Settings.GA_ITERATION,
				Settings.GA_CROSSOVER_PROB, Settings.GA_MUTATION_PROB);
	}
	
	public static void experiment(int run, ArrivalsProblem problem, int populationSize, int maxIterations, double crossoverProbability, double mutationProbability)
	{
		Monitor.start();
		
		// Configuration of GA algorithm
		ArrivalsSolution.initUUID();
		CrossoverOperator<ArrivalsSolution> crossoverOperator = new SimpleCrossover(problem, crossoverProbability);
		if (Settings.GA_CROSSOVER_TYPE.compareTo("uniform")==0)
			crossoverOperator = new UniformCrossover(problem, crossoverProbability, null);
		MutationOperator<ArrivalsSolution> mutationOperator = new SimpleMutation(problem, mutationProbability);
		SelectionOperator<List<ArrivalsSolution>, ArrivalsSolution> selectionOperator = new BinaryTournamentSelection<ArrivalsSolution>();

		
		JMetalLogger.logger.info("Started algorithem run "+run);
		
		String outputPath = String.format("%s/%s", Settings.BASE_PATH, Settings.WORKNAME_P1);
		String extendPath = null;
		if (Settings.WORKNAME_EX!=null && Settings.WORKNAME_EX.length()>0) {
			extendPath = String.format("%s/%s", Settings.BASE_PATH, Settings.WORKNAME_EX);
		}
		AbstractGA<ArrivalsSolution> algorithm = null;
		if (Settings.SIMPLE_SEARCH)
			algorithm = new RandomSearch<>( problem, maxIterations, populationSize,
											crossoverOperator, mutationOperator, selectionOperator,
											Settings.N_SAMPLE_WCET,
											outputPath, extendPath,
											Settings.DEBUG);
		else {
			algorithm = new SteadyStateGeneticAlgorithm<>(  problem, maxIterations, populationSize,
															crossoverOperator, mutationOperator, selectionOperator,
															Settings.N_SAMPLE_WCET,
															outputPath, extendPath,
															Settings.DEBUG);
		}
		AlgorithmRunner algorithmRunner = new AlgorithmRunner.Executor(algorithm).execute();
		
		Monitor.end();
		System.gc();
		
		// print results
		if (Settings.N_SAMPLE_WCET==0) {
			ArrivalsSolution solution = algorithm.getResult();
			printSolution(solution, 0);
			
			JMetalLogger.logger.info("Size of Solution: " + solution.getVariablesSize()) ;
		}
		else {
			List<ArrivalsSolution> solutions = algorithm.getPopulation();
			printSolutionList(solutions);
			saveExecutionResults();
			JMetalLogger.logger.info("Size of Solution: " + solutions.get(0).getVariablesSize()) ;
		}
		saveExecutionResults();
		
		// drawing graphs to see the result
//		try {
//			JMetalLogger.logger.info("Generate graphs for each a pair of two tasks...");
//      	    RScriptExecutor.init(Settings.SCRIPT_PATH);
//			RScriptExecutor script = new RScriptExecutor();
//			String resultPath = String.format("%s/%s", Settings.BASE_PATH, Settings.WORKNAME_P1);
//			if (!script.drawing(Settings.BASE_PATH, resultPath)){
//				JMetalLogger.logger.info("Error occurred during drawing results");
//			}
//			JMetalLogger.logger.info("Generate graphs for each a pair of two tasks...Done!");
//		} catch (Exception e) {
//			e.printStackTrace();
//		}
	}
	
	public static void printSolution(ArrivalsSolution _solution, int _idx) {
		GAWriter writer = new GAWriter(String.format("%s/%s/solutions.list", Settings.BASE_PATH, Settings.WORKNAME_P1),
									"idx\tsolution", true);
		writer.write(String.format("%d\t", _idx));
		writer.write(_solution.getVariablesStringInline());
		writer.write("\n");
		writer.close();
	}
	
	public static void printSolutionList(List<ArrivalsSolution> solutions) {
		JMetalLogger.logger.info("Saving populations...");
		int idx = 0;
		for(ArrivalsSolution solution: solutions) {
			printSolution(solution, idx++);
			JMetalLogger.logger.info("\t["+idx+"/"+solutions.size()+"] saved");
		}
		JMetalLogger.logger.info("Saving populations...Done");
	}
	
	/**
	 * Print out all results
	 */
	public static void saveExecutionResults()
	{
		GAWriter writer = new GAWriter(Settings.BASE_PATH + "/result.txt");
		long all = Monitor.getTime();
		writer.info(String.format("TotalExecutionTime( s): %.3f",all/1000.0));
		writer.info(String.format("InitHeap: %.1fM (%.1fG)", Monitor.heapInit/Monitor.MB, Monitor.heapInit/Monitor.GB));
		writer.info(String.format("usedHeap: %.1fM (%.1fG)", Monitor.heapUsed/Monitor.MB, Monitor.heapUsed/Monitor.GB));
		writer.info(String.format("commitHeap: %.1fM (%.1fG)", Monitor.heapCommit/Monitor.MB, Monitor.heapCommit/Monitor.GB));
		writer.info(String.format("MaxHeap: %.1fM (%.1fG)", Monitor.heapMax/Monitor.MB, Monitor.heapMax/Monitor.GB));
		writer.info(String.format("MaxNonHeap: %.1fM (%.1fG)", Monitor.nonheapUsed/Monitor.MB, Monitor.nonheapUsed/Monitor.GB));
		writer.close();
		
		JMetalLogger.logger.info("Saving population...Done");
	}
}
