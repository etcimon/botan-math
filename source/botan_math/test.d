module botan_math.test;

import botan_math.mp_types;
import botan_math.mp_comba;
import std.datetime;
import std.conv;
import std.stdio : writeln;
unittest {
	void testCombaSqr4() {
		word[8] z;
		word[4] x = [word.max, word.max, word.max, word.max];
		
		StopWatch sw; sw.start();
		foreach (i; 0 .. 1000000) {
			bigint_comba_sqr4(z, x);
		}
		sw.stop();
		writeln("bigint_comba_sqr4: ", sw.peek().msecs);		
	}
	void testCombaMul4() {
		word[4] x = [word.max, word.max, word.max, word.max];
		word[4] y = [word.max, word.max, word.max, word.max];
		word[8] z;
		StopWatch sw; sw.start();
		foreach (i; 0 .. 1000000) {
			bigint_comba_mul4(z, x, y);
		}
		sw.stop();
		writeln("bigint_comba_mul4: ", sw.peek().msecs);	
		
	}
	void testCombaSqr6() {
		word[6] x = [word.max, word.max, word.max, word.max, word.max, word.max];
		word[12] z;
		StopWatch sw; sw.start();
		foreach (i; 0 .. 1000000) {
			bigint_comba_sqr6(z, x);
		}
		sw.stop();
		writeln("bigint_comba_sqr6: ", sw.peek().msecs);		
	}

	void testCombaMul6() {
		word[6] x = [word.max, word.max, word.max, word.max, word.max, word.max];
		word[6] y = [word.max, word.max, word.max, word.max, word.max, word.max];
		word[12] z;
		StopWatch sw; sw.start();
		foreach (i; 0 .. 1000000) {
			bigint_comba_mul6(z, x, y);
		}
		sw.stop();
		writeln("bigint_comba_mul6: ", sw.peek().msecs);		
	}
	void testCombaSqr8() {
		word[8] x = [word.max, word.max, word.max, word.max, word.max, word.max, word.max, word.max];
		word[16] z;
		StopWatch sw; sw.start();
		foreach (i; 0 .. 1000000) {
			bigint_comba_sqr8(z, x);
		}
		sw.stop();
		writeln("bigint_comba_sqr8: ", sw.peek().msecs);		
	}

	void testCombaMul8() {
		word[8] x = [word.max, word.max, word.max, word.max, word.max, word.max, word.max, word.max];
		word[8] y = [word.max, word.max, word.max, word.max, word.max, word.max, word.max, word.max];
		word[16] z;
		StopWatch sw; sw.start();
		foreach (i; 0 .. 1000000) {
			bigint_comba_mul8(z, x, y);
		}
		sw.stop();
		writeln("bigint_comba_mul8: ", sw.peek().msecs);		
	}

	void testCombaSqr9() {
		word[9] x = [word.max, word.max, word.max, word.max, word.max, word.max, word.max, word.max, word.max];
		word[18] z;
		StopWatch sw; sw.start();
		foreach (i; 0 .. 1000000) {
			bigint_comba_sqr9(z, x);
		}
		sw.stop();
		writeln("bigint_comba_sqr9: ", sw.peek().msecs);		
	}
	
	void testCombaMul9() {
		word[9] x = [word.max, word.max, word.max, word.max, word.max, word.max, word.max, word.max, word.max];
		word[9] y = [word.max, word.max, word.max, word.max, word.max, word.max, word.max, word.max, word.max];
		word[18] z;
		StopWatch sw; sw.start();
		foreach (i; 0 .. 1000000) {
			bigint_comba_mul9(z, x, y);
		}
		sw.stop();
		writeln("bigint_comba_mul9: ", sw.peek().msecs);		
	}

	void testCombaSqr16() {
		word[16] x = [word.max, word.max, word.max, word.max, word.max, word.max, word.max, word.max,
			word.max, word.max, word.max, word.max, word.max, word.max, word.max, word.max];
		word[32] z;
		StopWatch sw; sw.start();
		foreach (i; 0 .. 1000000) {
			bigint_comba_sqr16(z, x);
		}
		sw.stop();
		writeln("bigint_comba_sqr16: ", sw.peek().msecs);		
	}

	void testCombaMul16() {
		word[16] x = [word.max, word.max, word.max, word.max, word.max, word.max, word.max, word.max,
			word.max, word.max, word.max, word.max, word.max, word.max, word.max, word.max];
		word[16] y = [word.max, word.max, word.max, word.max, word.max, word.max, word.max, word.max,
			word.max, word.max, word.max, word.max, word.max, word.max, word.max, word.max];
		word[32] z;
		StopWatch sw; sw.start();
		foreach (i; 0 .. 1000000) {
			bigint_comba_mul16(z, x, y);
		}
		sw.stop();
		writeln("bigint_comba_sqr16: ", sw.peek().msecs);		
	}

	testCombaSqr4();
	testCombaMul4();
	testCombaSqr6();
	testCombaMul6();
	testCombaSqr9();
	testCombaMul9();
	testCombaSqr16();
	testCombaMul16();
}
