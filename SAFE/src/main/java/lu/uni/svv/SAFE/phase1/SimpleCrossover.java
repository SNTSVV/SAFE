package lu.uni.svv.SAFE.phase1;

import lu.uni.svv.SAFE.task.Arrivals;
import lu.uni.svv.SAFE.task.TaskDescriptors;
import lu.uni.svv.utils.RandomGenerator;
import org.uma.jmetal.operator.CrossoverOperator;
import org.uma.jmetal.util.JMetalException;

import java.util.ArrayList;
import java.util.List;


@SuppressWarnings("serial")
public class SimpleCrossover implements CrossoverOperator<ArrivalsSolution>
{
	private double crossoverProbability;
	private RandomGenerator randomGenerator;
	private ArrivalsProblem problem=null;
	private List<Integer> PossibleTasksIdx = null;

	/** Constructor */
	public SimpleCrossover(ArrivalsProblem _problem, double crossoverProbability) {
		if (crossoverProbability < 0) {
			throw new JMetalException("Crossover probability is negative: " + crossoverProbability) ;
		}
		problem = _problem;
		RandomGenerator rand = new RandomGenerator();
		rand.nextInt();
		rand.nextDouble();
		
		this.crossoverProbability = crossoverProbability;
		this.randomGenerator = new RandomGenerator();
		
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
	public List<ArrivalsSolution> doCrossover(double _probability, ArrivalsSolution _parent1, ArrivalsSolution _parent2)
	{
		List<ArrivalsSolution> offspring = new ArrayList<>(2);

		offspring.add((ArrivalsSolution) _parent1.copy()) ;
		offspring.add((ArrivalsSolution) _parent2.copy()) ;

		if (randomGenerator.nextDouble() < _probability) {
			//System.out.println("[Debug] Executed crossover");
			
			// 1. Get the total number of bits
			int totalNumberOfVariables = _parent1.getNumberOfVariables();
			  
			// 2. Get crossover point
			int crossoverPoint = randomGenerator.nextInt(1, PossibleTasksIdx.size() - 1);
			crossoverPoint = PossibleTasksIdx.get(crossoverPoint);
			
			//System.out.println(String.format("Crossover Point: Task %d", crossoverPoint));
			
			// 3. Exchange values
			List<Arrivals> offspring1, offspring2;
			offspring1 = _parent1.getVariables();
			offspring2 = _parent2.getVariables();
			  			  
			for (int x = crossoverPoint; x < totalNumberOfVariables; x++) {
				offspring.get(0).setVariableValue(x, (Arrivals)offspring2.get(x).clone());
				offspring.get(1).setVariableValue(x, (Arrivals)offspring1.get(x).clone());
			}
		}
		
		return offspring;
	}

}
