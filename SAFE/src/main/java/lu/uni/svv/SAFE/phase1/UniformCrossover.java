package lu.uni.svv.SAFE.phase1;

import lu.uni.svv.SAFE.task.Arrivals;
import lu.uni.svv.SAFE.task.TaskDescriptors;
import lu.uni.svv.utils.RandomGenerator;
import org.uma.jmetal.operator.CrossoverOperator;
import org.uma.jmetal.util.JMetalException;

import java.util.ArrayList;
import java.util.List;


@SuppressWarnings("serial")
public class UniformCrossover implements CrossoverOperator<ArrivalsSolution>
{
	private double crossoverProbability;
	private double crossoverThrehold;
	private RandomGenerator randomGenerator;
	private ArrivalsProblem problem=null;
	private List<Integer> PossibleTasksIdx = null;

	/** Constructor */
	public UniformCrossover(ArrivalsProblem _problem, double crossoverProbability, Double crossoverThrehold) {
		if (crossoverProbability < 0) {
			throw new JMetalException("Crossover probability is negative: " + crossoverProbability) ;
		}
		problem = _problem;
		RandomGenerator rand = new RandomGenerator();
		rand.nextInt();
		rand.nextDouble();
		
		this.crossoverProbability = crossoverProbability;
		this.randomGenerator = new RandomGenerator();
		
		if (crossoverThrehold==null){
			this.crossoverThrehold = -1;
		}
		
		PossibleTasksIdx = TaskDescriptors.getVaryingTasksIdx(problem.Tasks);
	}
	
	/* Getter and Setter */
	public double getCrossoverProbability() {
		return crossoverProbability;
	}
	public void setCrossoverProbability(double crossoverProbability) {
		this.crossoverProbability = crossoverProbability;
	}
	@Override
	public int getNumberOfRequiredParents() {
		return 2;
	}
	@Override
	public int getNumberOfGeneratedChildren() {
		return 2;
	}

	
	/* Executing */
	@Override
	public List<ArrivalsSolution> execute(List<ArrivalsSolution> solutions)
	{
		if (solutions == null) {
			throw new JMetalException("Null parameter") ;
		} else if (solutions.size() != 2) {
			throw new JMetalException("There must be two parents instead of " + solutions.size()) ;
		}
		
		return doCrossover(crossoverProbability, solutions.get(0), solutions.get(1)) ;
	}


	/** doCrossover method */
	public List<ArrivalsSolution> doCrossover(double probability, ArrivalsSolution parent1, ArrivalsSolution parent2)
	{
		List<ArrivalsSolution> offspring = new ArrayList<ArrivalsSolution>(2);

		offspring.add((ArrivalsSolution) parent1.copy()) ;
		offspring.add((ArrivalsSolution) parent2.copy()) ;

		if (randomGenerator.nextDouble() < probability) {
			// 1. Get crossover points
			double[] crossoverPoints = new double[PossibleTasksIdx.size()];
			for(int x=0; x<PossibleTasksIdx.size(); x++){
				crossoverPoints[x] = randomGenerator.nextFloat();
			}
			
			double threshold = this.crossoverThrehold;
			if (this.crossoverThrehold<0) {
				threshold = 1 / (double) PossibleTasksIdx.size();
			}

			// 2. create offspring objects
			List<Arrivals> offspring1, offspring2;
			offspring1 = parent1.getVariables();
			offspring2 = parent2.getVariables();
			
			// 3. Exchange variables
			for (int x=0; x<PossibleTasksIdx.size(); x++){
				if(crossoverPoints[x] > threshold) continue;
				int taskIDX = PossibleTasksIdx.get(x);
				offspring.get(0).setVariableValue(taskIDX, (Arrivals)offspring2.get(taskIDX).clone());
				offspring.get(1).setVariableValue(taskIDX, (Arrivals)offspring1.get(taskIDX).clone());
			}
		}
		
		return offspring;
	}

}
