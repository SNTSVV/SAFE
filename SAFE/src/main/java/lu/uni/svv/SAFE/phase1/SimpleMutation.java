package lu.uni.svv.SAFE.phase1;


import lu.uni.svv.SAFE.task.Arrivals;
import lu.uni.svv.SAFE.task.TaskDescriptor;
import lu.uni.svv.SAFE.task.TaskDescriptors;
import lu.uni.svv.utils.RandomGenerator;
import org.uma.jmetal.operator.MutationOperator;
import org.uma.jmetal.util.JMetalException;
import java.util.List;

@SuppressWarnings("serial")
public class SimpleMutation implements MutationOperator<ArrivalsSolution>
{
	//This class changes only Aperiodic or Sporadic tasks that can be changeable
	private double mutationProbability;
	List<Integer> PossibleTasksIdx = null;
	RandomGenerator randomGenerator = null;
	ArrivalsProblem problem;

	public long newValue = 0;
	public int taskID = 0;
	public long position = 0;
	
	/**  Constructor */
	public SimpleMutation(ArrivalsProblem problem, double probability) throws JMetalException {

		if (probability < 0) {
			throw new JMetalException("Mutation probability is negative: " + probability) ;
		}
		if (probability > 1) {
			throw new JMetalException("Mutation probability is over 1.0: " + probability) ;
		}

		this.mutationProbability = probability ;
		this.randomGenerator = new RandomGenerator() ;
		this.problem = problem;
		PossibleTasksIdx = TaskDescriptors.getVaryingTasksIdx(problem.Tasks);
	}
	  

	/* Getters and Setters */
	public double getMutationProbability() {
		return mutationProbability;
	}
	public void setMutationProbability(double mutationProbability) {
		this.mutationProbability = mutationProbability;
	}

	/** Execute() method */
	@Override
	public ArrivalsSolution execute(ArrivalsSolution solution) throws JMetalException {
		if (null == solution) {
			throw new JMetalException("Executed SimpleTLMutation with Null parameter");
		}
		
		this.newValue = -1;
		this.position = -1;
		this.taskID = -1;
		
		
		for (int taskIDX:PossibleTasksIdx)
		{
			Arrivals variable = solution.getVariableValue(taskIDX);
			for (int a=0; a<variable.size(); a++) {
				if (randomGenerator.nextDouble() >= mutationProbability) continue;
				doMutation(variable, taskIDX, a);
			}
		}

		return solution;
	}
	
	/** Implements the mutation operation */
	private void doMutation(Arrivals _arrivals, int _taskIdx, int _position)
	{
		// execute mutation
		long curValue = _arrivals.get(_position);
		long lastValue = 0;
		if ( _position>=1 ) lastValue = _arrivals.get(_position-1);
		
		TaskDescriptor T = problem.Tasks[_taskIdx];
		
		// make a new value
		// only non-periodic tasks changes because we filtered in early stage
		long newValue = lastValue + randomGenerator.nextLong(T.MinIA, T.MaxIA);;

		// propagate changed values
		long delta = newValue - curValue;
		curValue += delta;
		_arrivals.set(_position, curValue);
		
		// modify nextValues following range constraint			
		for (int x=_position+1; x< _arrivals.size(); x++) {
			long nextValue = _arrivals.get(x);
			if ( (nextValue >= T.MinIA + curValue) && (nextValue <= T.MaxIA + curValue) )	break;
			_arrivals.set(x, nextValue+delta);
			curValue = nextValue+delta;
		}
		
		// Maximum Constraint
		// if the current value is over Maximum time quanta, remove the value
		// otherwise, save the result at the same place
		for (int x=_arrivals.size()-1; x>=0; x--) {
			if (_arrivals.get(x) <= problem.SIMULATION_TIME)
				break;
			_arrivals.remove(x);
		}
		
		// Maximum Constraint
		lastValue = _arrivals.get(_arrivals.size()-1);
		if (lastValue + T.MaxIA < problem.SIMULATION_TIME)
		{
			_arrivals.add(lastValue + randomGenerator.nextLong(T.MinIA, T.MaxIA));
		}
		
		return;
	}
}