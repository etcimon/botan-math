module botan_math.x86_64.mp_comba_mul;
import std.conv;
import std.array;

string mp_bigint_comba_mul(alias ROWS)() {
	// w1 : R14
	// w2 : R15
	// w0 : R13
	string start = "
	auto _x = x.ptr;
	auto _y = y.ptr;
	clearMem(z.ptr, z.length);
	word* _z = z.ptr;
    asm pure nothrow @nogc {";
	string end = "\n}\n";

	string asm_x86_64;
	size_t cnt;
	string[3] W = ["R13", "R14", "R15"];
	void shiftW_right() {
		string w0 = W[0];
		string w1 = W[1];
		string w2 = W[2];
		W[0] = w1;
		W[1] = w2;
		W[2] = w0;
	}

	//init
	asm_x86_64 ~= "
			mov RSI, _x;
			mov R9, _y;
			mov RDI, _z;
			xor R15, R15;
			xor R14, R14;
			xor R13, R13;\n";

	void word3_muladd(int i, bool reverse = false) {
		int k = reverse?0:1;
		foreach (j; 0 .. i + k) {
			cnt++;

			asm_x86_64 ~= "\nMUL_" ~ cnt.to!string ~ ": // " ~ i.to!string ~ " // " ~ j.to!string ~ " // " ~ reverse.to!string ~ "\n";
			if (j == 0) {
				if (i > 1) asm_x86_64 ~= "sub RSI, " ~ ((i-1)*8).to!string ~ ";\n";
				if (i > 0) asm_x86_64 ~= "add R9, " ~ (i*8).to!string ~ ";\n";
			}
			else {
				asm_x86_64 ~= "add RSI, 8;\n";
				asm_x86_64 ~= "sub R9, 8;\n";
			}
			// R15: w2, R13: w0, R14: w1
			// multiply
			asm_x86_64 ~= "mov RAX, [RSI]; mov RBX, [R9]; mul RBX;\n";
			// add carry
			{ 
				asm_x86_64 ~= "add RAX, ";
				asm_x86_64 ~= W[0];
				asm_x86_64 ~= ";\n";
			}
			// carry over
			{
				asm_x86_64 ~= "adc RDX, 0;\n";
				asm_x86_64 ~= "add ";
				asm_x86_64 ~= W[1];
				asm_x86_64 ~= ", RDX;\n";
			}
			// save multiplication result
			if (j <= i - 1 - (1-k)) {
				asm_x86_64 ~= "mov ";
				asm_x86_64 ~= W[0];
				asm_x86_64 ~= ", RAX;\n";
			} else { // if this is the last j
				if (i > 0) asm_x86_64 ~= "add RDI, 8;\n";
				asm_x86_64 ~= "mov [RDI], RAX;\n";
				asm_x86_64 ~= "xor ";
				asm_x86_64 ~= W[0];
				asm_x86_64 ~= ", ";
				asm_x86_64 ~= W[0];
				asm_x86_64 ~= ";\n";
			}
			// add carry carry over
			if (i > 0 && !(i == 1 && reverse)) {
				asm_x86_64 ~= "cmp ";
				asm_x86_64 ~= W[1];
				asm_x86_64 ~= ", RDX;\n";
				asm_x86_64 ~= "jnb MUL_";
				asm_x86_64 ~= (cnt+1).to!string;
				asm_x86_64 ~= ";\n";
				asm_x86_64 ~= "add ";
				asm_x86_64 ~= W[2];
				asm_x86_64 ~= ", 1;\n";
			}
		}
				
	}

	foreach (int i; 0 .. ROWS)
	{
		word3_muladd(i);
		shiftW_right();
	}
	foreach_reverse (int i; 0 .. ROWS)
	{
		word3_muladd(i, true);
		if (i > 1) shiftW_right();
	}

	// save the last carry
	asm_x86_64 ~= "add RDI, 8;\n";
	asm_x86_64 ~= "mov [RDI], " ~ W[1] ~ ";\n";
	return start ~ asm_x86_64 ~ end;
}
