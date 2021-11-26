package lu.uni.svv.SAFE.phase1.search;

import lu.uni.svv.SAFE.phase1.AbstractGA;
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
public class RandomSearch<S extends Solution<?>> extends AbstractGA<S> {

	/**
	 * Constructor
	 */
	public RandomSearch(Problem<S> _problem,
	                    int _maxIterations,
	                    int _populationSize,
	                    CrossoverOperator<S> _crossoverOperator,
	                    MutationOperator<S> _mutationOperator,
	                    SelectionOperator<List<S>, S> _selectionOperator,
	                    int _nSamples,
	                    String _outputPath,
	                    String _extendPath,
						boolean _opDebug) {
		super(_problem, _maxIterations, _populationSize, null,null,null,
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
		List<S> offsprings = new ArrayList<S>(1);
		S solution = problem.createSolution();
		offsprings.add(solution);
		return offsprings;
	}
	
	@Override
	protected List<S> selection(List<S> population) {
		return null;
	}
	
	@Override
	public String getName() {
		return "RandomSearch";
	}
	
	@Override
	public String getDescription() {
		return "Random Steady-State Search Algorithm";
	}
}
