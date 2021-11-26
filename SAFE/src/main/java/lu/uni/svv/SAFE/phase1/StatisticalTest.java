package lu.uni.svv.SAFE.phase1;

import org.apache.commons.math3.stat.inference.MannWhitneyUTest;
import java.util.*;

public class StatisticalTest {
	
	public static boolean UtestSignificance(double[] list1, double[] list2){
		// This function evaluates two-sided hypothesis
		// H0: The two populations are equal versus
		// H1: The two populations are not equal
		// if p-value < 0.05(a) : H0 is not supported == H1 is true
		// if this function's result is true, two populations are not equal.
		MannWhitneyUTest test = new MannWhitneyUTest();
		double[] double_list1 = new double[list1.length];
		double[] double_list2 = new double[list2.length];
		
		for (int x=0; x<list1.length; x++)
			double_list1[x] = list1[x]; //.doubleValue();
		for (int x=0; x<list1.length; x++)
			double_list2[x] = list2[x]; //.doubleValue();
		
		double pvalue = test.mannWhitneyUTest(double_list1, double_list2);
		
		if (pvalue < 0.05)
			return true;
		return false;
	}
	
	public static  double A12(double[] list1, double[] list2){
		double m = list1.length;
		double n = list2.length;
		double sum = rankSum1(list1, list2);
		
		return ((sum/m) - ((m+1)/2.0))/n;
	}
	
	public static Double rankSum1(double[] list1, double[] list2){
		List<Double> union = new ArrayList<Double>();
		List<Double> distinct = new ArrayList<Double>();
		Map<Double, Integer> map = new HashMap<Double, Integer>();
		
		for (int x=0; x<list1.length; x++) union.add(list1[x]);
		for (int x=0; x<list2.length; x++) union.add(list2[x]);
		Collections.sort(union);
		
		// create distinct list
		int idx = 0;
		for(int x=0; x<union.size(); x++) {
			if (distinct.size()>0 && union.get(x).compareTo(distinct.get(distinct.size() - 1)) == 0) continue;
			distinct.add(union.get(x));
			map.put(union.get(x), idx++);
		}
		
		// Count each items;
		int[] counts = new int[distinct.size()];
		double item=0.0;
		for (int x=0; x<union.size(); x++){
			item = union.get(x);
			idx = map.get(item);
			counts[idx] += 1;
		}
		
		// accumulate
		for(int x=0; x<counts.length-1; x++){
			counts[x+1] += counts[x];
		}
		
		// calculate ranks
		int prev = 1;
		int current = 1;
		double[] ranks = new double[distinct.size()];
		for(int x=0; x<counts.length; x++){
			current = counts[x];
			ranks[x] = (prev + current)/2.0;
			prev = current+1;
		}
		
		// Calculate rankSum
		double sum = 0.0;
		for(int x=0; x<list1.length; x++)
		{
			idx = map.get(list1[x]);
			sum += ranks[idx];
		}
		
		return sum;
	}
}
