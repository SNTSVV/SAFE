package lu.uni.svv.SAFE.phase1;

import org.uma.jmetal.solution.Solution;
import org.uma.jmetal.util.JMetalException;
import org.uma.jmetal.util.comparator.ObjectiveComparator.Ordering;

import java.io.Serializable;
import java.util.Comparator;

/**
 * This class implements a comparator based on a given objective
 *
 * @author Antonio J. Nebro <antonio@lcc.uma.es>
 */
@SuppressWarnings("serial")
public class SolutionListComparatorAvg<S extends Solution<?>> implements Comparator<S>, Serializable {
	private int objectiveId;
	
	private Ordering order;
	
	/**
	 * Constructor.
	 *
	 * @param objectiveId The index of the objective to compare
	 */
	public SolutionListComparatorAvg(int objectiveId) {
		this.objectiveId = objectiveId;
		order = Ordering.ASCENDING;
	}
	
	/**
	 * Comparator.
	 * @param objectiveId The index of the objective to compare
	 * @param order Ascending or descending order
	 */
	public SolutionListComparatorAvg(int objectiveId, Ordering order) {
		this.objectiveId = objectiveId;
		this.order = order ;
	}
	
	/**
	 * Compares two solutions according to a given objective.
	 *
	 * @param solution1 The first solution
	 * @param solution2 The second solution
	 * @return -1, or 0, or 1 if solution1 is less than, equal, or greater than solution2,
	 * respectively, according to the established order
	 */
	@Override
	public int compare(S solution1, S solution2) {
		double result;
		if (solution1 == null) {
			if (solution2 == null) {
				result = 0;
			} else {
				result = 1;
			}
		} else if (solution2 == null) {
			result =  -1;
		} else if (solution1.getNumberOfObjectives() <= objectiveId) {
			throw new JMetalException("The solution1 has " + solution1.getNumberOfObjectives()+ " objectives "
					+ "and the objective to sort is " + objectiveId) ;
		} else if (solution2.getNumberOfObjectives() <= objectiveId) {
			throw new JMetalException("The solution2 has " + solution2.getNumberOfObjectives()+ " objectives "
					+ "and the objective to sort is " + objectiveId) ;
		} else {
			double objective1 = (solution1).getObjective(this.objectiveId);
			double objective2 = (solution2).getObjective(this.objectiveId);

			if (order == Ordering.ASCENDING) {
				result = objective1 - objective2;
			} else {
				result = objective2 - objective1;
			}
		}
		if (result > 0) return 1;
		else if (result < 0) return -1;
		return 0;
	}
}
