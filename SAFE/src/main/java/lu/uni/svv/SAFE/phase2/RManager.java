package lu.uni.svv.SAFE.phase2;

import lu.uni.svv.utils.GAWriter;
import org.renjin.eval.EvalException;
import org.renjin.sexp.StringVector;
import org.renjin.sexp.Vector;
import javax.script.ScriptException;

public class RManager extends RInterface {
	
	public RManager() throws ScriptException{
		super();
	}
	
	//////////////////////////////////////////////////////////////////////
	// Common functions
	//////////////////////////////////////////////////////////////////////
	
	public String getModelText(String modelname) throws ScriptException, EvalException {
		StringBuilder sb = new StringBuilder();
		
		StringVector nameVector = (StringVector)engine.eval(String.format("names(%s$coefficients)", modelname));
		String[] names = nameVector.toArray();
		
		Vector dataVector = (Vector)engine.eval(modelname+"$coefficients");
		double[] coeff = new double[dataVector.length()];
		for(int x=0; x<dataVector.length(); x++){
			coeff[x] = dataVector.getElementAsDouble(x);
		}
		
		sb.append("Y = ");
		sb.append(coeff[0]);
		for(int x=1; x<names.length; x++) {
			sb.append(" + ");
			sb.append(coeff[x]);
			sb.append("*");
			sb.append(names[x]);
		}
		return sb.toString();
	}
	
	public void readCSV(String _innerVal, String _filename) throws ScriptException, EvalException{
		// load data
		String command = String.format("%s <- read.csv('%s', header=TRUE)", _innerVal, _filename);
		this.engine.eval(command);
		//		this.func(_innerVal, "read.csv", datafile, new RInterface.VAR("header=TRUE"));
	}
	
	public void writeTable(String _innerVal, String _filename) throws ScriptException, EvalException{
		this.func(null,"write.csv",
				new RInterface.VAR(_innerVal),
				_filename,
				new RInterface.VAR("append = FALSE"),
				new RInterface.VAR("row.names = FALSE"),
				new RInterface.VAR("col.names = TRUE"),
				new RInterface.VAR("na = 'NA'")
		);
	}
	
	public void writeNumericData(String _innerVal, String _filename, boolean _append) throws ScriptException, EvalException{
		// put title
		StringBuilder sb = new StringBuilder();
		String[] names = this.getStrings(String.format("colnames(%s)", _innerVal));
		if (!_append) {
			sb.append(names[0]);
			for(int x=1; x<names.length; x++) {
				sb.append(",");
				sb.append(names[x]);
			}
			sb.append("\n");
		}
		
		double[] values = this.getDoubleList(String.format("as.double(%s[1,])", _innerVal));
		sb.append(values[0]);
		for (int x=1; x<values.length; x++) {
			sb.append(",");
			sb.append(values[x]);
		}
		
		GAWriter writer = new GAWriter(_filename,null, _append);
		writer.info(sb.toString());
		writer.close();
	}
	
	public void writeCoefficients(String _modelname, String _filename) throws ScriptException, EvalException {
		StringBuilder sb = new StringBuilder();
		
		String[] names = this.getStrings(String.format("names(%s$coefficients)", _modelname));
		sb.append(names[0]);
		for(int x=1; x<names.length; x++) {
			sb.append(",");
			sb.append(names[x]);
		}
		sb.append("\n");
		
		double[] coeff = this.getDoubleList(String.format("%s$coefficients", _modelname));
		sb.append(coeff[0]);
		for(int x=1; x<coeff.length; x++) {
			sb.append(",");
			sb.append(coeff[x]);
		}
		
		GAWriter writer = new GAWriter(_filename);
		writer.info(sb.toString());
		writer.close();
		
		return;
	}
	
	public void print(String _innerVal) throws ScriptException, EvalException{
		this.engine.eval(String.format("print(%s)", _innerVal));
	}
	
	public void cat(String _innerVal) throws ScriptException, EvalException{
		this.engine.eval(String.format("cat(%s)", _innerVal));
	}
	
	public void head(String _innerVal) throws ScriptException, EvalException{
		this.engine.eval(String.format("head(%s)", _innerVal));
	}
	
	public void addRow(String _innerVal, String _item) throws ScriptException, EvalException{
		this.engine.eval(String.format("%s <- rbind(%s, %s)", _innerVal, _innerVal, _item));
	}
	
	public void ifelse(String _ret, String _cond, String _true, String _false) throws ScriptException, EvalException{
		this.engine.eval(String.format("%s <- ifelse(%s, %s, %s)", _ret, _cond, _true, _false));
	}
	
	
	
}
