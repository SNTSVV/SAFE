package lu.uni.svv.SAFE.phase1;

import lu.uni.svv.SAFE.task.Arrivals;
import lu.uni.svv.SAFE.task.TaskDescriptor;
import lu.uni.svv.SAFE.task.TaskType;
import lu.uni.svv.utils.GAWriter;
import lu.uni.svv.SAFE.Settings;

import org.json.simple.JSONArray;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;
import org.uma.jmetal.solution.Solution;
import org.uma.jmetal.solution.impl.AbstractGenericSolution;
import org.uma.jmetal.util.pseudorandom.JMetalRandom;

import java.io.FileReader;
import java.io.IOException;
import java.util.*;


/**
 * Class Responsibility
 *  - A method to create a solution
 *  - A method to copy a solution
 * So, this class need to reference Problem object
 */
@SuppressWarnings("serial")
public class ArrivalsSolution extends AbstractGenericSolution<Arrivals, ArrivalsProblem> {//implements Solution<Integer>{
	public enum ARRIVAL_OPTION {RANDOM, MIN, MAX, MIDDLE, TASK, LIMIT_MIN, LIMIT_MAX, FIXED}
	
	/**
	 * Static varibles and functions
	 */
	private static long UUID = 1L;
	public static void initUUID(){ ArrivalsSolution.UUID = 1L; }
	
	/**
	 * varibles and functions
	 */
	protected JMetalRandom random;
	public long ID = 0L;

	/**
	 * Create solution following Testing problem
	 * @param _problem
	 */
	public ArrivalsSolution(ArrivalsProblem _problem)
	{
		this(_problem, ARRIVAL_OPTION.RANDOM, 0);
	}
	
	/**
	 * Create solution following Testing problem
	 * @param _problem
	 */
	public ArrivalsSolution(ArrivalsProblem _problem, ARRIVAL_OPTION _arrivalOption)
	{
		this(_problem, _arrivalOption, 0);
	}
	
	public ArrivalsSolution(ArrivalsProblem _problem, ARRIVAL_OPTION _arrivalOption, double rate)
	{
		super(_problem);
		this.random =  JMetalRandom.getInstance();
		ID = ArrivalsSolution.UUID++;
		
		//Encoding chromosomes
		for (int x = 0; x < problem.getNumberOfVariables(); x++) {
			this.setVariableValue(x, this.createRandomList(x, _arrivalOption, rate));
		}
	}
	
	public ArrivalsSolution(ArrivalsProblem _problem, List<Arrivals> _variables)
	{
		super(_problem);
		this.random =  JMetalRandom.getInstance();
		ID = ArrivalsSolution.UUID++;
		
		//Encoding chromosomes
		for(int i = 0; i < this.problem.getNumberOfVariables(); ++i) {
			this.setVariableValue(i, (Arrivals)_variables.get(i).clone());
		}
	}
	
	public ArrivalsSolution(ArrivalsProblem _problem, Arrivals[] _variables)
	{
		super(_problem);
		this.random =  JMetalRandom.getInstance();
		ID = ArrivalsSolution.UUID++;
		
		//Encoding chromosomes
		for(int i = 0; i < this.problem.getNumberOfVariables(); ++i) {
			this.setVariableValue(i, (Arrivals)_variables[i].clone());
		}
	}
	
	/**
	 * Create a Gene (a factor of Chromosomes) for each task
	 * @param _index: task index
	 * @param _option: generating option
	 * @return
	 */
	private Arrivals createRandomList(int _index, ARRIVAL_OPTION _option, double _rate) {
		
		Arrivals list = new Arrivals();
		TaskDescriptor T = problem.Tasks[_index];
		
		long arrival=0;
		long interval=0;
		
		// create arrival time table for periodic task
		if (T.Type == TaskType.Periodic) {
			// we gives phase time to arrival time at the starting point
			if (Settings.ALLOW_OFFSET_RANGE)
				arrival = this.random.nextInt(0, T.Offset);
			else
				arrival = T.Offset;
			
			interval = T.Period;
		}
		else{
			switch(_option){
				case RANDOM:  interval = this.random.nextInt(T.MinIA, T.MaxIA); break;
				case MIN:     interval = T.MinIA; break;
				case MAX:     interval = T.MaxIA; break;
				case MIDDLE:  interval = T.MinIA + (T.MaxIA - T.MinIA)/2; break;
				case TASK:    interval = this.random.nextInt(T.MinIA, T.MaxIA); break;
				case FIXED:   interval = (int)((T.MaxIA - T.MinIA) * _rate + T.MinIA); break;
				case LIMIT_MIN:
					int rateRange = (int)((T.MaxIA-T.MinIA)*_rate);
					interval = this.random.nextInt(T.MinIA, T.MinIA+rateRange);
					break;
				case LIMIT_MAX:
					rateRange = (int)((T.MaxIA-T.MinIA)*_rate);
					interval = this.random.nextInt(T.MaxIA - rateRange, T.MaxIA);
					break;
			}
			arrival = interval;
		}
		
		while(arrival <= problem.SIMULATION_TIME) {
			list.add(arrival); // Input first
			
			if (T.Type != TaskType.Periodic && _option== ARRIVAL_OPTION.RANDOM){
				interval = this.random.nextInt(T.MinIA, T.MaxIA);
			}
			arrival += interval;
		}
		
		return list;
	}
	
	//////////////////////////////////////////////////////////////////////
	// implementing functions from interface
	//////////////////////////////////////////////////////////////////////
	/**
	 * copy of this solution
	 * all values of objectives are initialized by 0 (This means the solution is not evaluated)
	 */
	@Override
	public Solution<Arrivals> copy() {
		return new ArrivalsSolution(this.problem, this.getVariables());
	}
	
	@Override
	public Map<Object, Object> getAttributes() {
		return this.attributes;
	}
	
	//////////////////////////////////////////////////////////////////////
	// convert variables to string
	//////////////////////////////////////////////////////////////////////
	@Override
	@SuppressWarnings("resource")
	public String getVariableValueString(int index) {
		Arrivals aVariable = this.getVariableValue(index);
		
		StringBuilder sb = new StringBuilder();
		Formatter fmt = new Formatter(sb);
		fmt.format("[");
		for(int i=0; i< aVariable.size(); i++) {
			fmt.format("%d", aVariable.get(i));
			if ( aVariable.size() > (i+1) )
				sb.append(",");
		}
		fmt.format("]");
		
		return sb.toString();
	}
	
	public String getVariablesStringInline(){
		StringBuilder sb = new StringBuilder();
		sb.append("[");
		for (int x=0; x < this.getNumberOfVariables(); x++) {
			sb.append(this.getVariableValueString(x));
			if (x!=(this.getNumberOfVariables()-1))
				sb.append(", ");
		}
		sb.append("]");
		return sb.toString();
	}
	
	public String getVariablesString() {
		StringBuilder sb = new StringBuilder();
		sb.append("[\n");
		for (int x=0; x < this.getNumberOfVariables(); x++) {
			sb.append("\t");
			sb.append(this.getVariableValueString(x));
			if (x!=(this.getNumberOfVariables()-1))
				sb.append(",");
			sb.append("\n");
		}
		sb.append("]");
		
		return sb.toString();
	}
	
	public int[] getReprVariables() {
		int[] repr = new int[this.getNumberOfVariables()];

		for (int x=0; x < this.getNumberOfVariables(); x++) {
			if (problem.Tasks[x].Type==TaskType.Periodic)
				repr[x] = problem.Tasks[x].Period;
			else {
				double avg = 0;
				Arrivals arrivals = this.getVariableValue(x);
				long prev = 0;
				for(int t=0; t<arrivals.size(); t++){
					long val = arrivals.get(t);
					avg += (val - prev);
					prev = val;
				}
				repr[x] = (int)avg/arrivals.size(); //Math.toIntExact((Long) this.getVariableValue(x).get(0));
			}
		}
		
		return repr;
	}
	
	public String getSolutionString(int _rep_size, int[] _priorities) {
		StringBuilder sb = new StringBuilder();
		sb.append("[ \n");
		for (int x=0; x < this.getNumberOfVariables(); x++) {
			sb.append("Task");
			sb.append(this.problem.Tasks[x].ID);
			sb.append("(");
			sb.append(_priorities[x]);
			sb.append("): ");
			sb.append(this.getLineVariableValueString(x, _rep_size));
			sb.append("\n");
		}
		sb.append(" ]");
		
		return sb.toString();
	}
	
	
	/**
	 * Make a string with Variable values, this show rep_size numbers.
	 * @param index
	 * @param rep_size
	 * @return
	 */
	@SuppressWarnings("resource")
	public String getCustomVariableValueString(int index, int rep_size) {
		Arrivals aVariable = this.getVariableValue(index);
		
		StringBuilder sb = new StringBuilder();
		Formatter fmt = new Formatter(sb);
		
		fmt.format("P%02d: ", index);
		for(int i=0; i< MIN(aVariable.size(), rep_size); i++) {
			fmt.format("%d", aVariable.get(i));
			if ( aVariable.size() > (i+1) )
				sb.append(",");
		}
		
		if(aVariable.size() > rep_size )
			fmt.format("...(more %d)\n", (aVariable.size() - rep_size));
		else
			fmt.format("\n");

		return sb.toString();
	}
	
	public String getCustomVariableValueString(int rep_size) {
		StringBuilder sb = new StringBuilder();
		
		for (int x=0; x < this.getNumberOfVariables(); x++) {
			sb.append(this.getCustomVariableValueString(x, rep_size));
		}
		
		return sb.toString();
	}
	

	/**
	 * This function returns string of values in the Variables
	 * @param rep_size
	 * @return
	 */
	public String getLineVariableValueString(int rep_size) {
		StringBuilder sb = new StringBuilder();
		sb.append("[ ");
		for (int x=0; x < this.getNumberOfVariables(); x++) {
			sb.append(this.getLineVariableValueString(x, rep_size));
			if (x!=(this.getNumberOfVariables()-1))
				sb.append(", ");
		}
		sb.append(" ]");
		
		return sb.toString();
	}
	/**
	 * This function returns string of values in a specific Variable
	 * @param index
	 * @param rep_size
	 * @return
	 */
	public String getLineVariableValueString(int index, int rep_size) {
		Arrivals aVariable = this.getVariableValue(index);
		
		StringBuilder sb = new StringBuilder();
		Formatter fmt = new Formatter(sb);
		
		fmt.format("[");
		for(int i=0; i< MIN(aVariable.size(), rep_size); i++) {
			fmt.format("%d", aVariable.get(i));
			if ( aVariable.size() > (i+1) )
				sb.append(",");
		}
		
		if(aVariable.size() > rep_size )
			fmt.format("...(more %d)]", (aVariable.size() - rep_size));
		else
			fmt.format("]");
		
		return sb.toString();
	}

	
	private final int MIN(int a, int b){
		return (a>b)? b:a;
	}
	
	
	@Override
	public String toString(){
		StringBuilder sb = new StringBuilder();
		sb.append("ArrivalsSolution{ ID(");
		sb.append(ID);
		sb.append("), Arrivals: ");
		sb.append(getVariablesSize());
		sb.append(", fitness: ");
		sb.append(getObjective(0));
		sb.append(", ");
		if (attributes.containsKey("DeadlineMiss")) {
			sb.append("DM: ");
			sb.append(attributes.get("DeadlineMiss"));
			sb.append(", ");
		}
		sb.append(attributes);
		sb.append("}");
		return sb.toString();
	}
	
	public String getVariablesSize(){
		List<Arrivals> items = getVariables();
		
		StringBuilder sb = new StringBuilder();
		sb.append("[");
		for (int x=0; x< items.size(); x++){
			if (x!=0) sb.append(",");
			sb.append(items.get(x).size());
		}
		sb.append("]");
		return sb.toString();
	}
	
	////////////////////////////////////////////////////////////////////////
	// Loading and saving ArrivalsSolution
	////////////////////////////////////////////////////////////////////////
	/**
	 * Saving arrival solution into file
	 * @param _filepath should specify full file path
	 */
	public void store(String _filepath){
		GAWriter writer = new GAWriter(_filepath);
		writer.info(this.getVariablesString());
		writer.close();
	}
	
	/**
	 * [Static] Generate ArrivalsSolution from file
	 * @param _problem
	 * @param _jsonText
	 * @return
	 */
	public static ArrivalsSolution loadFromJSONString(ArrivalsProblem _problem, String _jsonText){
		try {
			JSONParser parser = new JSONParser();
			JSONArray json = (JSONArray) parser.parse(_jsonText);
			
			return loadFromJSON(_problem, json);
		}
		catch (ParseException e){
			e.printStackTrace();
		}
		
		return null;
	}
	
	public static ArrivalsSolution loadFromFile(ArrivalsProblem _problem, String _filepath){
		FileReader reader = null;
		
		try {
			reader = new FileReader(_filepath);
			JSONParser parser = new JSONParser();
			JSONArray json = (JSONArray) parser.parse(reader);
			return loadFromJSON(_problem, json);
		}
		catch (IOException | ParseException e){
			e.printStackTrace();
		} finally {
			try {
				if (reader != null)
					reader.close();
			} catch (IOException ex) {
				ex.printStackTrace();
			}
		}
		
		return null;
	}
	
	private static ArrivalsSolution loadFromJSON(ArrivalsProblem _problem, JSONArray _json){
		List<Arrivals> variables = new ArrayList<>(_json.size());
		for (int i = 0; i < _json.size(); i++) {
			JSONArray array = (JSONArray) _json.get(i);
			
			Arrivals arrivals = new Arrivals();
			for (Object item : array) {
				arrivals.add(((Long)item).longValue());
			}
			variables.add(arrivals);
		}
		
		return new ArrivalsSolution(_problem, variables);
	}
	
	////////////////////////////////////////////////////////////////////////
	// Exchange internal variables
	////////////////////////////////////////////////////////////////////////
	/**
	 * convert to arrays
	 * @return
	 */
	public Arrivals[] toArray(){
		Arrivals[] arrivals = new Arrivals[this.getNumberOfVariables()];
		for (int y=0; y<this.getNumberOfVariables(); y++){
			arrivals[y] = this.getVariableValue(y);
		}
		return arrivals;
	}
	
	/**
	 * Convert solutions to list of arrivals
	 * @param solutions
	 * @return
	 */
	public static List<Arrivals[]> toArrays(List<ArrivalsSolution> solutions) {
		List<Arrivals[]> arrivals = new ArrayList<>();
		for(ArrivalsSolution solution: solutions){
			arrivals.add(solution.toArray());
		}
		return arrivals;
	}
	
	@Override
	protected void finalize() throws Throwable{
		for (int i=0; i<this.getNumberOfVariables(); i++)
			this.setVariableValue(i, null);
		
		this.attributes.clear();
		this.attributes = null;
		super.finalize();
//		Utils.printMemory("delete "+this.ID);
	}
}
