package lu.uni.svv.SAFE.phase2;

import lu.uni.svv.utils.PathManager;
import org.uma.jmetal.util.JMetalLogger;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;


public class RScriptExecutor {
	
	static String scriptPath = "";
	
	/**
	 * Check script path, if it is not exists, throws IOException
	 * @throws IOException
	 */
	public static void init(String _scriptPath) throws IOException {
		scriptPath = PathManager.mappingArtifactLocation(_scriptPath);
		
		// Check the scriptPath actually exists
		File file = new File(scriptPath);
		if (!file.exists()){
			throw new IOException("Not found script path: "+scriptPath);
		}
		JMetalLogger.logger.info("RScript path: "+scriptPath);
	}
	/**
	 * Feature reduction script
	 */
	public static boolean feature(String _targetPath, String _phase1Path, String _outputPath, int _nTerms) throws IOException {
		List<String> cmdList = new ArrayList<>();
		cmdList.add("Rscript");
		cmdList.add(String.format("%s/features.R", scriptPath));
		cmdList.add(_targetPath);
		cmdList.add(_phase1Path);
		cmdList.add(_outputPath);
		if (_nTerms>0){
			cmdList.add(String.valueOf(_nTerms));
		}
		return executeScript(cmdList, "Done.");
	}
	
	/**
	 * Pruning script
	 */
	public static boolean prune(String _targetPath, String _phase1Path, String _formulaPath) throws IOException {
		List<String> cmdList = new ArrayList<>();
		cmdList.add("Rscript");
		cmdList.add(String.format("%s/prune_input.R", scriptPath));
		cmdList.add(_targetPath);
		cmdList.add(_phase1Path);
		cmdList.add(_formulaPath);
		
		return executeScript(cmdList, "Done.");
	}
	
	/**
	 * Drawing scatter plot for the result of phase 1
	 */
	public static boolean drawing(String _targetPath, String _phase1Path) throws IOException {
		List<String> cmdList = new ArrayList<>();
		cmdList.add("Rscript");
		cmdList.add(String.format("%s/drawing.R", scriptPath));
		cmdList.add(_targetPath);
		cmdList.add(_phase1Path);
		return executeScript(cmdList, "Done.");
	}
	
	public static boolean distance_sampling(String _targetPath, String _modelPath, String _traningFile, int _nSample, int _nCandidate, double _P){
		List<String> cmdList = new ArrayList<>();
		cmdList.add("Rscript");
		cmdList.add(String.format("%s/dist_sample.R", scriptPath));
		cmdList.add(_targetPath);
		cmdList.add(_modelPath);
		cmdList.add(_traningFile);
		cmdList.add(String.valueOf(_nSample));
		cmdList.add(String.valueOf(_nCandidate));
		cmdList.add(String.valueOf(_P));
		return executeScript(cmdList, null);
	}
	
	
	public static List<String> bestSize(String _targetPath, String _modelFile, String _trainingFile, double _P) {
		List<String> cmdList = new ArrayList<>();
		cmdList.add("Rscript");
		cmdList.add(String.format("%s/best_size.R", scriptPath));
		cmdList.add(_targetPath);
		cmdList.add(_modelFile);
		cmdList.add(_trainingFile);
		cmdList.add(String.valueOf(_P));
		String ret = executeScript(cmdList);
		
		List<String> list = new ArrayList<>();
		// parse area
		String[] items = ret.split(";");
		String areaStr = items[0].split(":")[1].trim();
		if (areaStr.compareTo("NaN")==0) {
			areaStr = "as.double('X')";
		}
		list.add(areaStr);
		
		// parse points
		String values = items[1].split(":")[1].trim(); //.substring(9, items[1].length()-1);
		StringBuilder sb = new StringBuilder();
		String[] points = values.split(",");
		for (int x=0; x<points.length; x++){
			String str = points[x].trim();
			if (str.compareTo("NaN")==0) {
				str = "as.double('X')";
			}
			sb.append(str);
			if (x!=points.length-1){
				sb.append(",");
			}
		}
		list.add(sb.toString());
		return list;
	}
	
	/**
	 *   Rscript file execute
	 *     Rengine libraries have lower version of R original libraries,
	 *     So, we cannot execute some code through Rengine.
	 */
	public static boolean executeScript(List<String> _cmdList, String exitCode){
		Process process = null;
		String str = null;
		
		List<String> results = new ArrayList<>();
		
		try {
			process = new ProcessBuilder(_cmdList).redirectErrorStream(true).start();
			BufferedReader stdOut = new BufferedReader(new InputStreamReader(process.getInputStream()));
			
			while((str = stdOut.readLine()) != null) {
				System.out.println(str);
				results.add(str);
			}
		} catch (IOException e) {
			e.printStackTrace();
			return false;
		}
		if (exitCode!=null) {
			int idx = results.size();
			String line = results.get(idx - 1);
			return line.compareTo(exitCode) == 0;
		}
		return true;
	}
	
	/**
	 *   Rscript file execute
	 *     Rengine libraries have lower version of R original libraries,
	 *     So, we cannot execute some code through Rengine.
	 */
	public static String executeScript(List<String> _cmdList){
		Process process = null;
		String str = null;
		
		List<String> results = new ArrayList<>();
		
		try {
			process = new ProcessBuilder(_cmdList).redirectErrorStream(true).start();
			BufferedReader stdOut = new BufferedReader(new InputStreamReader(process.getInputStream()));
			
			while((str = stdOut.readLine()) != null) {
				System.out.println(str);
				results.add(str);
			}
		} catch (IOException e) {
			e.printStackTrace();
			return null;
		}
		int idx = results.size();
		String line = results.get(idx - 1);
		return line;
	}
	
}
