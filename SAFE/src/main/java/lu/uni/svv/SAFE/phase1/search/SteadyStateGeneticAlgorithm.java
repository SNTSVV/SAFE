package lu.uni.svv.SAFE.phase1.search;

import lu.uni.svv.SAFE.phase1.AbstractGA;
import lu.uni.svv.SAFE.phase1.ArrivalsSolution;
import org.uma.jmetal.operator.CrossoverOperator;
import org.uma.jmetal.operator.MutationOperator;
import org.uma.jmetal.operator.SelectionOperator;
import org.uma.jmetal.problem.Problem;
import org.uma.jmetal.solution.Solution;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;


/**
 * @author Jaekwon Lee <jaekwon.lee@uni.lu>
 */
@SuppressWarnings("serial")
public class SteadyStateGeneticAlgorithm<S extends Solution<?>> extends AbstractGA<S> {

	/**
	 * Constructor
	 */
	public SteadyStateGeneticAlgorithm(Problem<S> _problem,
	                                   int _maxIterations,
	                                   int _populationSize,
	                                   CrossoverOperator<S> _crossoverOperator,
	                                   MutationOperator<S> _mutationOperator,
	                                   SelectionOperator<List<S>, S> _selectionOperator,
	                                   int _nSamples,
	                                   String _outputPath,
	                                   String _extendPath,
									   boolean _opDebug) {
		super(_problem, _maxIterations, _populationSize, _crossoverOperator, _mutationOperator, _selectionOperator,
				_nSamples, _outputPath, _extendPath, _opDebug);
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
	protected List<S> reproduction(List<S> matingPopulation) {
		List<S> parents = new ArrayList<S>(2);
		parents.add(matingPopulation.get(0));
		parents.add(matingPopulation.get(1));
		
		List<S> offspring = crossoverOperator.execute(parents);
		mutationOperator.execute(offspring.get(0));
		
		List<S> offspringPopulation = new ArrayList<S>(1);
		offspringPopulation.add(offspring.get(0));
		return offspringPopulation;
	}

	@Override
	protected List<S> selection(List<S> population) {
		List<S> matingPopulation = new ArrayList<S>(2);
		int i=0;
		long prev_id = -1;
		while (i<2){
			S solution = selectionOperator.execute(population);
			long id = ((ArrivalsSolution)solution).ID;
			if (prev_id==id) continue;
			prev_id = id;
			matingPopulation.add(solution);
			i += 1;
		}
		
		return matingPopulation;
	}

	@Override
	public String getName() {
		return "ssGA";
	}
	
	@Override
	public String getDescription() {
		return "Steady-State Genetic Algorithm";
	}
}
