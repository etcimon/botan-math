module botan_math.test;

import botan_math.mp_types;
import botan_math.mp_comba;
import botan_math.mp_monty;
import std.datetime;
import std.datetime.stopwatch : StopWatch;
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
		writeln("bigint_comba_sqr4: ", sw.peek().total!"msecs");		
	}
	void testCombaMul4() {
		word[4] x = [word.max, word.max, word.max, word.max];
		word[4] y = [word.max, word.max, word.max, word.max];
		word[8] z;word[10000] w1;
		StopWatch sw; word[1000] w;sw.start();
		foreach (i; 0 .. 1000000) {
			bigint_comba_mul4(z, x, y);
		}
		sw.stop();
		writeln("bigint_comba_mul4: ", sw.peek().total!"msecs");	
		
	}
	void testCombaSqr6() {
		word[6] x = [word.max, word.max, word.max, word.max, word.max, word.max];
		word[12] z;
		StopWatch sw; sw.start();
		foreach (i; 0 .. 1000000) {
			bigint_comba_sqr6(z, x);
		}
		sw.stop();
		writeln("bigint_comba_sqr6: ", sw.peek().total!"msecs");		
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
		writeln("bigint_comba_mul6: ", sw.peek().total!"msecs");		
	}
	void testCombaSqr8() {
		word[8] x = [word.max, word.max, word.max, word.max, word.max, word.max, word.max, word.max];
		word[16] z;
		StopWatch sw; sw.start();
		foreach (i; 0 .. 1000000) {
			bigint_comba_sqr8(z, x);
		}
		sw.stop();
		writeln("bigint_comba_sqr8: ", sw.peek().total!"msecs");		
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
		writeln("bigint_comba_mul8: ", sw.peek().total!"msecs");		
	}

	void testCombaSqr9() {
		word[9] x = [word.max, word.max, word.max, word.max, word.max, word.max, word.max, word.max, word.max];
		word[18] z;
		StopWatch sw; sw.start();
		foreach (i; 0 .. 1000000) {
			bigint_comba_sqr9(z, x);
		}
		sw.stop();
		writeln("bigint_comba_sqr9: ", sw.peek().total!"msecs");		
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
		writeln("bigint_comba_mul9: ", sw.peek().total!"msecs");		
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
		writeln("bigint_comba_sqr16: ", sw.peek().total!"msecs");		
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
		writeln("bigint_comba_mul16: ", sw.peek().total!"msecs");		
	}


	{

		word[] a = [17770583100980259918UL, 8184863349457233473UL, 6535295554996936204UL, 1465444498646341095UL, 13311159987635252387UL, 5134404283940589200UL, 1853462226638766757UL, 1124269783854338851UL, 2197254742716964892UL, 14432675262230411338UL, 17797346411615106216UL, 4282521838067492345UL, 9695195066000380879UL, 8951714592550298295UL, 6771318585111213581UL, 2571348289270658527UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL];

		word[] b = [4609703025863202499UL, 6761711583190879286UL, 18145989274302477154UL, 17111073606706710213UL, 8889548365417408578UL, 9060870991312222559UL, 12835237159094758860UL, 16404981697982096428UL, 13480788919354109744UL, 7378187050019063276UL, 5637137234707460427UL, 8933669876660147017UL, 1763560740842357387UL, 3928518027077157480UL, 6441474690281765224UL, 14352639745647514582UL];

    word[34] workspace;

		bigint_monty_redc(a.ptr, b.ptr, 16, 0, workspace.ptr);

		writeln(a[0 .. 16]);

	}
	testCombaSqr4();
	testCombaMul4();
	testCombaSqr6();
	testCombaMul6();
	testCombaSqr8();
	testCombaMul8();
	testCombaSqr9();
	testCombaMul9();
	testCombaSqr16();
	testCombaMul16();
}
