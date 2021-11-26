package lu.uni.svv.utils;

import java.io.IOException;

public class PathManager {
	public static String mappingArtifactLocation(String _path) throws IOException {
		// When the script path set as a relative path and under the directory where the executable file exists,
		// add the parent directory path to the script Path
		if (!(_path.startsWith("/") || _path.startsWith(".."))) {
			// Add prefix depends on the location of the executable file (only works for the jar file)
			// String ExecPath = System.getProperty("user.dir");
			// String clsPath = System.getProperty("java.class.path");
			String javaCmd = System.getProperty("sun.java.command");
			String[] cmds = javaCmd.split(" ");
			if (cmds[0].endsWith(".jar")) {
				int idx = cmds[0].lastIndexOf('/');
				String prefix = "";
				if (idx > 0) {
					prefix = cmds[0].substring(0, idx);
				}
				if (!(prefix.length() == 0 || prefix.compareTo(".") == 0)) {
					_path = prefix + "/" + _path;
				}
			}
		}
		return _path;
	}
}
