package lu.uni.svv.SAFE.phase2;

import org.renjin.eval.EvalException;
import org.renjin.script.RenjinScriptEngineFactory;
import org.renjin.sexp.StringVector;
import org.renjin.sexp.Vector;
import org.uma.jmetal.util.JMetalLogger;

import javax.script.ScriptEngine;
import javax.script.ScriptException;

public class RInterface {
	
	public static class VAR{
		public String name = "";
		public VAR(String _name){this.name=_name;}
	};
	
	// Variables
	ScriptEngine engine = null;
	
	public RInterface() throws ScriptException {
		// create a Renjin engine:
		RenjinScriptEngineFactory factory = new RenjinScriptEngineFactory();
		this.engine = factory.getScriptEngine();
		 this.engine.eval("Sys.setenv(\"JAVA_RUN\"=\"TRUE\")");
		JMetalLogger.logger.info("Loaded R engine");
	}
	
	public void loadLibrary(String _libname) throws EvalException, ScriptException {
		this.engine.eval(String.format("library('org.renjin.cran:%s')", _libname));
	}
	
	public void loadFile(String _filename) throws EvalException, ScriptException{
		this.engine.eval(String.format("source('%s')", _filename));
	}
	
	//////////////////////////////////////////////////////////////////////
	// Set variables
	//////////////////////////////////////////////////////////////////////
	public void setVariable(String _name, String _value) throws EvalException, ScriptException{
		this.engine.eval(String.format("%s <- \"%s\"", _name, _value));
	}
	
	public void setVariable(String _name, VAR _value) throws EvalException, ScriptException{
		this.engine.eval(String.format("%s <- %s", _name, _value.name));
	}
	
	public void setVariable(String _name, double _value) throws EvalException, ScriptException{
		this.engine.eval(String.format("%s <- %f", _name, _value));
	}
	
	public void setVariable(String _name, int _value) throws EvalException, ScriptException{
		this.engine.eval(String.format("%s <- %d", _name, _value));
	}
	//////////////////////////////////////////////////////////////////////
	// Execute function
	//////////////////////////////////////////////////////////////////////
	public int getInt(String _name) throws EvalException, ScriptException{
		Vector vector = (Vector) engine.eval(_name);
		return vector.getElementAsInt(0);
	}
	
	public double getDouble(String _name) throws EvalException, ScriptException{
		Vector vector = (Vector) engine.eval(_name);
		return vector.getElementAsDouble(0);
	}
	
	public String getString(String _name) throws EvalException, ScriptException{
		Vector vector = (Vector)engine.eval(_name);
		return vector.toString();
	}
	
	public String[] getStrings(String _name) throws EvalException, ScriptException{
		StringVector vector = (StringVector)engine.eval(_name);
		return vector.toArray();
	}
	
	public int[] getIntList(String _name) throws EvalException, ScriptException{
		int[] items = null;
		
		Vector dataVector = (Vector)engine.eval(_name);
		items = new int[dataVector.length()];
		for(int x=0; x<dataVector.length(); x++){
			items[x] = (int)dataVector.getElementAsInt(x);
		}
		return items;
	}
	
	public double[] getDoubleList(String _name) throws EvalException, ScriptException{
		double[] items = null;
		
		Vector dataVector = (Vector)engine.eval(_name);
		items = new double[dataVector.length()];
		for(int x=0; x<dataVector.length(); x++){
			items[x] = (double)dataVector.getElementAsDouble(x);
		}
		return items;
	}
	
	//////////////////////////////////////////////////////////////////////
	// Execute function
	//////////////////////////////////////////////////////////////////////
	public void func(String _retVar, String _func, Object... _params) throws EvalException, ScriptException{
		StringBuilder sb = new StringBuilder();
		if (!(_retVar==null || _retVar.length()==0)){
			sb.append(_retVar);
			sb.append(" <- ");
		}
		
		// function name
		sb.append(_func);
		sb.append("(");
		
		// passing parameters
		for (int x=0; x<_params.length; x++){
			if(_params[x] instanceof VAR) {
				sb.append(((VAR) _params[x]).name);
			}
			else if(_params[x] instanceof String){
				sb.append("\"");
				sb.append(_params[x]);
				sb.append("\"");
			}
			else if(_params[x] instanceof Double){
				sb.append(String.format("%06f", (double)_params[x]));
			}
			else{
				sb.append(_params[x]);
			}
			if (x!= _params.length-1)
				sb.append(", ");
		}
		sb.append(")");
//		System.out.println(sb.toString());
		this.engine.eval(sb.toString());
	}
}
