package lu.uni.svv.StressTesting.scheduler;

import lu.uni.svv.StressTesting.datatype.Task;
import lu.uni.svv.StressTesting.search.model.TestingProblem;
import lu.uni.svv.StressTesting.utils.Settings;

import java.util.Arrays;


/**
 * Scheduling Policy
 * 	- We use Fixed Priority to schedule tasks.
 * 	- The two task has same priority, first arrived task in the ready queue has more high priority.
 * 
 * Deadline misses detection
 * 	- We count the number of deadline misses while the scheduling(by MAX_TIMEQUANTA)
 * 	- And, if the ready queue has tasks after being done scheduling(after MAX_TIMEQUANTA),
 * 			we will execute this scheduler by finishing all tasks in the ready queue.
 * @author jaekwon.lee
 *
 */
public class RMSchedulerMax extends RMScheduler{
	
	protected int[] maximumMissed;
	
	public RMSchedulerMax(TestingProblem _problem, int[] _targetTasks) {
		super(_problem, _targetTasks);
		
		maximumMissed = new int[_problem.Tasks.length];
		Arrays.fill(maximumMissed, (int)_problem.QUANTA_LENGTH * -1);
	}
	
	@Override
	protected double evaluateDeadlineMiss(Task _T, int _missed) {
		if (_missed > maximumMissed[_T.ID-1]) maximumMissed[_T.ID-1] = _missed;
		
		if (!isTargetTask(_T.ID)) return 0.0;
		return _missed;
	}
	
	@Override
	public double getEvaluatedValue() {
		double result = 0.0;
		for (int x=0; x<maximumMissed.length; x ++) {
			int ID = x + 1;
			if (isTargetTask(ID)) {
				double a = (maximumMissed[x] > 0) ? 2: 0.5;
				result = result + Math.pow(a, Math.abs(maximumMissed[x]));
			}
		}
		return result;
	}
	
	@Override
	public String getByproduct() {
		StringBuilder sb = new StringBuilder();
		if (maximumMissed.length>=1) {
			int x=0;
			for (; x < maximumMissed.length - 1; x++) {
				sb.append(maximumMissed[x]);
				sb.append(',');
			}
			sb.append(maximumMissed[x]);
		}
		return sb.toString();
	}
}