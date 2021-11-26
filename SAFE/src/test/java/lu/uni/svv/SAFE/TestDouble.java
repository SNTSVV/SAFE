package lu.uni.svv.SAFE;

public class TestDouble {


	public static void main(String[] args){

		System.out.println(String.format(" MIN: %.8f", Double.MIN_VALUE));
		System.out.println(String.format(" MAX: %.8f", Double.MAX_VALUE));
		System.out.println(String.format("-MAX: %.8f", -Double.MAX_VALUE));



		System.out.println(String.format("%.2f",Float.parseFloat("1+e05")));
	}
}
