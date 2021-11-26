package lu.uni.svv.SAFE.phase2;

import lu.uni.svv.SAFE.phase1.ArrivalsProblem;
import lu.uni.svv.SAFE.phase1.ArrivalsSolution;
import lu.uni.svv.SAFE.Settings;
import lu.uni.svv.SAFE.phase2.RInterface.VAR;
import org.renjin.eval.EvalException;
import org.uma.jmetal.util.JMetalLogger;

import javax.script.ScriptException;
import java.io.File;
import java.util.List;


public class ModelUpdateThreshold extends ModelUpdate {
	
	
	public ModelUpdateThreshold(ArrivalsProblem _problem, List<ArrivalsSolution> _solutions,
	                            String _outputPath, String _samplePath,
	                            String _testDataPath, String _formulaPath,
	                            String _scriptPath, boolean _opDebug) throws Exception {
		super(_problem, _solutions, _outputPath, _samplePath, _testDataPath, _formulaPath, _scriptPath, _opDebug);
	}
	
	/**
	 * Initialize model
	 * @return
	 */
	public void initializeModel() throws ScriptException, EvalException{
		this.buildModel(formula);
		updateProbability();
		probability = R.getDouble("borderProbability");
	}
	
	public void updateModel() throws ScriptException, EvalException{
		JMetalLogger.logger.info("update logistic regression " + updates + "/" + Settings.N_MODEL_UPDATES);
		
		// Learning model again with more data
		this.buildModel(formula);
		updateProbability();
		probability = R.getDouble("borderProbability");
		
		updateTerminationData();
	}
	
	
	public void updateProbability() throws ScriptException, EvalException{
		
		// update borderProbability and area
		R.func("uncertainIDs", "get_base_names",
				new VAR("names(base_model$coefficients)"), new VAR("isNum=TRUE")); //c(30, 33)
		
		R.func("borderProbability", "find_noFPR",
				new VAR("base_model"), new VAR("training"), Settings.MODEL_PROB_PRECISION);
		R.ifelse("borderProbability", "borderProbability==0", String.valueOf(Settings.MODEL_PROB_PRECISION),"borderProbability");
		double P = R.getDouble("borderProbability");
		JMetalLogger.logger.info(String.format("Model noFPR probability: %.6f", P));
		
		R.func("areaMC", "integrateMC",
				new VAR("TASK_INFO"),	10000,
				new VAR("base_model"), new VAR("uncertainIDs"), new VAR("borderProbability"));

		List<String> bestSize = getBestSize();
		R.setVariable("BestArea", new VAR(bestSize.get(0)));
		R.setVariable("BestPoints", new VAR(String.format("data.frame(t(c(%s)))", bestSize.get(1))));
		R.setVariable("colnames(BestPoints)", new VAR("sprintf('Px(T%d)',uncertainIDs)"));
		
		// keep coefficients
		R.setVariable("model.coef", new VAR("t(data.frame(base_model$coefficients))"));
		R.setVariable("colnames(model.coef)", new VAR("get_raw_names(names(base_model$coefficients))"));
		R.setVariable("model.result", new VAR(String.format("data.frame(nUpdate=%d, TrainingSize=nrow(training), " +
						"Probability=borderProbability, BestPointArea=BestArea, BestPoints, Area=areaMC, model.coef)",
						updates)));
	}
	
	private List<String> getBestSize() throws ScriptException, EvalException {
		// generate file path
		String modelpath = String.format("%s/_samples/sample_best_size_%03d.md", outputPath, updates);
		File parent = new File(modelpath).getParentFile();
		if (!parent.exists()) parent.mkdirs();
		
		// write model into file
		R.writeCoefficients("base_model", modelpath);
		
		// find best size
		double P = R.getDouble("borderProbability");
		List<String> bestSize = RScriptExecutor.bestSize(Settings.BASE_PATH, modelpath, trainingDataPath, P);
		return bestSize;
	}
}