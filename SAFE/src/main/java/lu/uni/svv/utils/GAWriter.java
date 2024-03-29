package lu.uni.svv.utils;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.logging.Level;

public class GAWriter {
	BufferedWriter logger = null;
	Level level = Level.INFO;
	
	public GAWriter(String _filename) {
		this(_filename, null, false, Level.FINE);
	}
	
	public GAWriter(String _filename, String _title) {
		this(_filename, _title,false, Level.FINE);
	}
	
	public GAWriter(String _filename, String _title, boolean _append) {
		this(_filename, _title, _append, Level.FINE);
	}
	
	public GAWriter(String _filename,  String _title, boolean _append, Level _level) {
		this.level = _level;
		File filePath = new File(_filename);
		
		File parent = filePath.getParentFile();
		int count=0;
		while (!parent.exists()){
			if (!parent.mkdirs()) {
				System.out.print("Creating parent directory error");
				System.out.println(filePath.getAbsolutePath());
				try {
					Thread.sleep(1000);
				} catch (InterruptedException e) {
					e.printStackTrace();
					System.exit(1);
				}
				if (count > 3){
					System.out.println("Failed to create parent directory");
					System.exit(1);
				}
				count += 1;
			}
		}
		
		boolean flagTitle = _title!=null;
		if (filePath.exists() && _append) flagTitle = false;
		
		FileWriter fw = null;
		try {
			fw = new FileWriter(filePath.getAbsolutePath(), _append);
			logger = new BufferedWriter(fw);
			if (flagTitle){
				this.info(_title);
			}
		} catch (IOException e) {
			e.printStackTrace();

		} finally {
		}
	}
	
	public void close()
	{
		try {
			logger.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}		
	}
	
	public void print(String msg) {
		if (!(level==Level.INFO || level==Level.FINE)) return;
		try { 
			System.out.print(msg);
			logger.write(msg);
			logger.flush();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public void write(String msg) {
		try {
			logger.write(msg);
			logger.flush();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public void info(String msg) {
		if (!(level==Level.INFO || level==Level.FINE)) return;
		try { 
			logger.write(msg+"\n");
			logger.flush();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}	
	public void fine(String msg) {
		if (!(level==Level.FINE)) return;
		try {
			logger.write(msg+"\n");
			logger.flush();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}	


}
