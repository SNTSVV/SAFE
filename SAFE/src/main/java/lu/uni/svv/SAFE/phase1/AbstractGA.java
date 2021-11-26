package lu.uni.svv.SAFE.phase1;


import lu.uni.svv.SAFE.scheduler.Schedule;
import lu.uni.svv.SAFE.task.Arrivals;
import lu.uni.svv.utils.GAWriter;
import org.uma.jmetal.algorithm.impl.AbstractGeneticAlgorithm;
import org.uma.jmetal.operator.CrossoverOperator;
import org.uma.jmetal.operator.MutationOperator;
import org.uma.jmetal.operator.SelectionOperator;
import org.uma.jmetal.problem.Problem;
import org.uma.jmetal.solution.Solution;
import org.uma.jmetal.util.JMetalLogger;
import org.uma.jmetal.util.comparator.ObjectiveComparator.Ordering;

import java.io.File;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.logging.Level;

/**
 * @author Jaekwon Lee <jaekwon.lee@uni.lu>
 */
@SuppressWarnings("serial")
public abstract class AbstractGA<S extends Solution<?>> extends AbstractGeneticAlgorithm<S, S> {
	protected Comparator<S> comparator;
	protected int maxIterations;
	protected int iterations;
	protected GAWriter fitnessWriter;
	protected GAWriter fitnessSimpleWriter;
	protected GAWriter marginWriter;
	protected int nSamples=0;
	protected String outputPath = "";
	protected String extendPath = "";
	protected boolean opDebug = false;
	
	/**
	 * Constructor
	 */
	public AbstractGA(Problem<S> _problem,
	                  int _maxIterations,
	                  int _populationSize,
	                  CrossoverOperator<S> _crossoverOperator,
	                  MutationOperator<S> _mutationOperator,
	                  SelectionOperator<List<S>, S> _selectionOperator,
	                  int _nSamples,
	                  String _outputPath,
	                  String _extendPath,
					  boolean _opDebug) {
		super(_problem);
		setMaxPopulationSize(_populationSize);
		this.maxIterations = _maxIterations;
		this.crossoverOperator = _crossoverOperator;
		this.mutationOperator = _mutationOperator;
		this.selectionOperator = _selectionOperator;
		this.outputPath = _outputPath;
		this.extendPath = _extendPath;
		this.nSamples = _nSamples;
		this.opDebug = _opDebug;
		
		if (this.nSamples==0)
			comparator = new SolutionComparator<S>(0, Ordering.DESCENDING);
		else
			comparator = new SolutionListComparatorAvg<S>(0, Ordering.DESCENDING);
		
		printFitnessHeader();
		printMarginsHeader();
	}

	protected void close() {
		fitnessWriter.close();
		marginWriter.close();
	}
	
	@Override
	public void run() {
		List<S> offspringPopulation;
		List<S> matingPopulation;
		
		population = createInitialPopulation();
		JMetalLogger.logger.info("created initial population");
		population = evaluatePopulation(population);
		JMetalLogger.logger.info("evaluated initial population");
		initProgress();
		while (!isStoppingConditionReached()) {
			matingPopulation = selection(population);
			offspringPopulation = reproduction(matingPopulation);
			offspringPopulation = evaluatePopulation(offspringPopulation);
			population = replacement(population, offspringPopulation);
			updateProgress();
			System.gc();
		}
		
		close();
	}
	
	@Override
	protected boolean isStoppingConditionReached() {
		
		return (iterations >= maxIterations);
	}
	
	@Override
	protected List<S> replacement(List<S> population, List<S> offspringPopulation) {
		Collections.sort(population, comparator);
		int worstSolutionIndex = population.size() - 1;
		if (comparator.compare(population.get(worstSolutionIndex), offspringPopulation.get(0)) > 0) {
			population.remove(worstSolutionIndex);
			population.add(offspringPopulation.get(0));
		}
		
		return population;
	}
	
	@Override
	protected List<S> evaluatePopulation(List<S> population) {
		ArrivalsProblem problem = (ArrivalsProblem)getProblem();
		int count =0;
		for (S solution : population) {
			count += 1;
			if (nSamples==0) {
				evaluate(solution);
			} else {
				evaluateWithSampling(solution);
				if (this.extendPath!=null) saveExpendedInfo((ArrivalsSolution)solution);
			}
			JMetalLogger.logger.info("" + count + "/" + population.size()+ " evaluated population");
		}
		
		return population;
	}

	@Override
	public S getResult() {
		Collections.sort(getPopulation(), comparator);
		return getPopulation().get(0);
	}
	
	@Override
	public void initProgress() {
		iterations = 0;
		JMetalLogger.logger.info("initialized Progress");
		printFitnessLine();
		printMargins();
		if (this.extendPath!=null)
			printSolutions();
	}
	
	@Override
	public void updateProgress() {
		iterations++;
		JMetalLogger.logger.info("move to next evaluation: " + iterations);
		printFitnessLine();
		printMargins();
		if (this.extendPath!=null)
			printSolutions();
	}
	
	////////////////////////////////////////////////////////////////////
	// Print functions
	////////////////////////////////////////////////////////////////////
	public void printFitnessHeader(){
		fitnessWriter = new GAWriter(String.format("%s/fitness.csv", outputPath));
		fitnessSimpleWriter = new GAWriter(String.format("%s/fitness_simple.csv", outputPath));
		
		// Title
		String title = "Iterations,Fitness";
		fitnessSimpleWriter.info(title);
		
		if (this.nSamples!=0)
			title = "Iterations,SampleID,Fitness";
		fitnessWriter.info(title);
		
	}
	
	public void printFitnessLine(){
		Collections.sort(population, comparator);
		ArrivalsSolution bestSolution = (ArrivalsSolution)population.get(0);
		double fitness = bestSolution.getObjective(0);
		
		String line = String.format("%d,%f", iterations, fitness);
		fitnessSimpleWriter.info(line);
		
		if (this.nSamples!=0){
			StringBuilder sb = new StringBuilder();
			double[] list = (double[])bestSolution.getAttribute("FitnessList");
			for (int x=0; x<list.length; x++){
				sb.append((iterations));
				sb.append(",");
				sb.append(x);
				sb.append(",");
				sb.append(String.format("%f", list[x] ));
				if (x != list.length-1)
					sb.append("\n");
			}
			line = sb.toString();
		}
		fitnessWriter.info(line);
	}
	
	public void printMarginsHeader(){
		marginWriter = new GAWriter(String.format("%s/minimumMargins.csv", outputPath));
		
		StringBuilder sb = new StringBuilder();
		sb.append("Iteration");
		if (this.nSamples!=0)
			sb.append(",SampleID");
		
		for(int num=0; num<problem.getNumberOfVariables(); num++){
			sb.append(",");
			sb.append(String.format("Task%02d",num+1));
		}
		marginWriter.info(sb.toString());
	}
	
	public void printMargins() {
		StringBuilder sb = new StringBuilder();
		
		if (this.nSamples == 0) {
			int[] margins = (int[]) population.get(0).getAttribute("Margins");
			sb.append(iterations);
			for (int x = 0; x < margins.length; x++) {
				sb.append(",");
				sb.append(margins[x]);
			}
			sb.append("\n");
			
		} else {
			int[][] margins = (int[][]) population.get(0).getAttribute("Margins");
			for (int sampleID = 0; sampleID < margins.length; sampleID++) {  // samples
				sb.append(iterations);
				sb.append(",");
				sb.append(sampleID);
				for (int x = 0; x < margins[sampleID].length; x++) {
					sb.append(",");
					sb.append(margins[sampleID][x]);
				}
				sb.append("\n");
			}
		}
		
		marginWriter.write(sb.toString());
	}
	
	private void printSolutions(){
		GAWriter writer = new GAWriter(String.format("%s/solution/solutions_%04d.list", extendPath, iterations),
						"idx\tsolution");
		int idx = 0;
		for(Solution solution: population) {
			ArrivalsSolution sol = (ArrivalsSolution)solution;
			
			writer.write(String.format("%d\t", idx));
			writer.write(sol.getVariablesStringInline());
			writer.write("\n");
			idx += 1;
		}
	}
	
	private void saveExpendedInfo(ArrivalsSolution _solution)
	{
		// Save Results -->
		//     _extends/solution/{solutionID}.txt
		//     _extends/best(e-d)/{solutionID}.csv
		//     _extends/deadlines/{solutionID}.csv
		//     _extends/executions/{solutionID}.csv
		//     _extends/WCET/{solutionID}.csv
		// print out a solution info.
//		GAWriter writer = new GAWriter(String.format("%s/samples/solution/%d.json", extendPath, _solution.ID));
//		writer.info(_solution.getVariableValueString());
//		writer.close();
//
//		// best (e-d)
//		writer = new GAWriter(String.format("%s/best(e-d)/%d.csv", extendPath, _solution.ID));
//		writer.info(_solution.getByproduct());
//		writer.close();
//
//		// deadline missed
//		writer = new GAWriter(String.format("%s/deadlines/%d.csv", extendPath, _solution.ID));
//		writer.info(_solution.getDeadlines());
//		writer.close();
//
//		// executions which are best(e-d)
//		writer = new GAWriter(String.format("%s/executions/%d.csv", extendPath, _solution.ID));
//		writer.info(_solution.getDetailExecution());
//		writer.close();
//
//		// sampleing information
//		writer = new GAWriter(String.format("%s/WCET/%d.csv", extendPath, _solution.ID));
//		writer.info(_solution.getSampledWCET());
//		writer.close();
		
		// sampleing information
		GAWriter writer = new GAWriter(String.format("%s/arrivals/%d.csv", extendPath, _solution.ID));
		writer.info(makeArrivals(_solution));
		writer.close();
		
		// print fitness and number of deadlines
		double[] fitnessList = (double[])_solution.getAttribute("FitnessList");
		int[] deadlines = (int[])_solution.getAttribute("Deadlines");
		
		StringBuilder sb = new StringBuilder();
		sb.append("SampleID,Fitness,MissingDeadlines\n");
		for (int x=0; x<fitnessList.length; x++) {
			sb.append(String.format("%d,%.32e,%d\n",x, fitnessList[x], deadlines[x]));
		}
		
		writer = new GAWriter(String.format("%s/fitness/%d.csv", extendPath, _solution.ID));
		writer.info(sb.toString());
		writer.close();
	}


	public void storeForDebug(S _solution, long sID){
		long solutionID = ((ArrivalsSolution)_solution).ID;
		String path = outputPath + "/debug";
		File fileObj = new File(path);
		if (!fileObj.exists()) fileObj.mkdirs();


		// Saving arrivals
		String filename = String.format("%s/sol%d_sample%d_arrivals.json", path, solutionID, sID);
		String arrivals = ((ArrivalsSolution) _solution).getVariablesString();
		GAWriter writer = new GAWriter(filename);
		writer.info(arrivals);
		writer.close();

		// Saving schedules
		Schedule[][] schedules = (Schedule[][])_solution.getAttribute("Schedules");
		filename = String.format("%s/sol%d_sample%d_schedules.json", path, solutionID, sID);
		writer = new GAWriter(filename);
		writer.write(Schedule.toString(schedules));
		writer.close();

		// convert priority
		Integer[] priorities = ((ArrivalsProblem) problem).Priorities;
		StringBuilder sb = new StringBuilder("[ ");
		for (int x=0; x < priorities.length; x++) {
			sb.append(priorities[x]);
			if (x!=(priorities.length-1))
				sb.append(", ");
		}
		sb.append(" ]");

		// store priority
		filename = String.format("%s/sol%d_sample%d_priorities.json", path, solutionID, sID);
		writer = new GAWriter(filename);
		writer.info(sb.toString());
		writer.close();
	}
	
	private String makeArrivals(ArrivalsSolution _solution){
		StringBuilder sb = new StringBuilder();
		sb.append("TaskID,Arrivals\n");
		List<Arrivals> timelist = _solution.getVariables();
		int tid = 1;
		for (Arrivals item : timelist){
			sb.append(tid);
			sb.append(",");
			sb.append(item.size());
			sb.append("\n");
			tid+=1;
		}
		return sb.toString();
	}
	
	
	//////////////////////////////////////////////////////////////////////////////
	// functions related to evaluating
	//////////////////////////////////////////////////////////////////////////////
	private void evaluate(S _solution) {
		int[] samples = ((ArrivalsProblem)problem).getMinimumWCETs();
		_solution.setAttribute("SampleID", 0);
		_solution.setAttribute("Samples", samples);
		_solution.setAttribute("Debug", opDebug);
		problem.evaluate(_solution);
		if (opDebug) storeForDebug(_solution, 0);
	}
	
	private void evaluateWithSampling(S _solution) {
		double[] fitnessList = new double[nSamples];
		int[] nDeadlines = new int[nSamples];
		int[][] margins = new int[nSamples][];
		int[] uncertainTasks = ((ArrivalsProblem)problem).getUncertainTasks();
		
		// Result header
		String header = this.makeSampleHeader("result", uncertainTasks);
		GAWriter dataWriter = new GAWriter(outputPath + "/sampledata.csv", header,true);
		
		// generate sample and evaluate
		for (int sampleID = 0; sampleID < nSamples; sampleID++) {
			// sampling WCETs
			int[] samples = ((ArrivalsProblem)problem).getSampleWCETs(uncertainTasks);
			_solution.setAttribute("SampleID", sampleID);
			_solution.setAttribute("Samples", samples);
			_solution.setAttribute("Debug", opDebug);
			
			// evaluate
			problem.evaluate(_solution);
			
			// calculate fitness values
			fitnessList[sampleID] = _solution.getObjective(0);
			nDeadlines[sampleID] = (int)_solution.getAttribute("Deadlines");
			margins[sampleID] = (int[]) _solution.getAttribute("Margins");
			
			// print a sample data for one copied chromosome
			int answer = (nDeadlines[sampleID]>0)? 1: 0;
			dataWriter.info(this.makeSampleLine(answer, uncertainTasks, samples));

//			JMetalLogger.logger.info(String.format("   [%d/%d] sample evaluating", sampleID+1, nSamples));
			if (opDebug) storeForDebug(_solution, sampleID);
		}
		dataWriter.close();
		
		// save result to the solution
		double fitness = AverageList(fitnessList);
		_solution.setObjective(0, fitness);
		_solution.setAttribute("FitnessList", fitnessList);
		_solution.setAttribute("Deadlines", nDeadlines);
		_solution.setAttribute("Margins", margins);
	}
	
	private String makeSampleHeader(String prefix, int[] uncertainTasks){
		StringBuilder sb = new StringBuilder();
		sb.append(prefix);
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
	
	private double AverageList(double[] list){
		double avg = 0.0;
		for (int x=0; x<list.length; x++){
			avg = avg + list[x];
		}
		avg = avg / list.length;
		return avg;
	}
}
