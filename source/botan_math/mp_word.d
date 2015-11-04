/**
* Comba word operations
* 
* Copyright:
* (C) 1999-2010,2014 Jack Lloyd
* (C) 2014-2015 Etienne Cimon
*      2006 Luca Piccarreta
*
* License:
* Botan is released under the Simplified BSD License (see LICENSE.md)
*/
module botan_math.mp_word;

public import botan_math.mp_types;
/*
* Word Multiply/Add
*/
word word_madd2(word a, word b, word* c)
{
	static if (BOTAN_HAS_MP_DWORD) {
		const dword s = cast(dword)(a) * b + *c;
		*c = cast(word)(s >> BOTAN_MP_WORD_BITS);
		return cast(word)(s);
	} else {
		version(D_InlineAsm_X86_64) {
			word* _a = &a;
			asm pure nothrow @nogc {
				
				mov RAX, a;
				mov RBX, b;
				mul RBX;
				mov RCX, c;
				mov RBX, [RCX];
				add RAX, RBX;
				adc RDX, 0;
				mov [RCX], RDX;
				mov RBX, _a;
				mov [RBX], RAX;
			}
			return a;
		}
		else {
			static assert(BOTAN_MP_WORD_BITS == 64, "Unexpected word size");
			
			word[2] res;
			
			mul64x64_128(a, b, res);
			
			res[0] += *c;
			res[1] += (res[0] < *c); // carry?
			
			*c = res[1];
			return res[0];
		}
	}
}

/*
* Word Multiply/Add
*/
word word_madd3(word a, word b, word c, word* d)
{
	static if (BOTAN_HAS_MP_DWORD) {
		const dword s = cast(dword)(a) * b + c + *d;
		*d = cast(word)(s >> BOTAN_MP_WORD_BITS);
		return cast(word)(s);
	} else {
		version(D_InlineAsm_X86_64) {
			word* _a = &a;
			asm pure nothrow @nogc {
				mov RAX, a;
				mov RBX, b;
				mul RBX;
				mov RBX, d;
				mov RCX, c;
				add RAX, RCX;
				adc RDX, 0;
				add RAX, [RBX];
				adc RDX, 0;
				mov [RBX], RDX;
				mov RBX, _a;
				mov [RBX], RAX;
			}
			return a;
		}
		else {
			static assert(BOTAN_MP_WORD_BITS == 64, "Unexpected word size");
			
			word[2] res;
			
			mul64x64_128(a, b, res);
			
			res[0] += c;
			res[1] += (res[0] < c); // carry?
			
			res[0] += *d;
			res[1] += (res[0] < *d); // carry?
			
			*d = res[1];
			return res[0];
		}
	}
}


/*
* Word Addition
*/
word word_add(word x, word y, word* carry)
{
	word z = x + y;
	word c1 = (z < x);
	z += *carry;
	*carry = c1 | (z < *carry);
	return z;
}

/*
* Eight Word Block Addition, Two Argument
*/
word word8_add2(ref word[8] x, const ref word[8] y, word carry)
{
	void word_add_i(size_t i) {
		word z = x.ptr[i] + y.ptr[i];
		word c1 = (z < x.ptr[i]);
		z += carry;
		carry = c1 | (z < carry);
		x.ptr[i] = z;
	}
	word_add_i(0);
	word_add_i(1);
	word_add_i(2);
	word_add_i(3);
	word_add_i(4);
	word_add_i(5);
	word_add_i(6);
	word_add_i(7);
	return carry;
}

/*
* Eight Word Block Addition, Three Argument
*/
word word8_add3(ref word[8] z, const ref word[8] x, const ref word[8] y, word carry)
{
	z[0] = word_add(x[0], y[0], &carry);
	z[1] = word_add(x[1], y[1], &carry);
	z[2] = word_add(x[2], y[2], &carry);
	z[3] = word_add(x[3], y[3], &carry);
	z[4] = word_add(x[4], y[4], &carry);
	z[5] = word_add(x[5], y[5], &carry);
	z[6] = word_add(x[6], y[6], &carry);
	z[7] = word_add(x[7], y[7], &carry);
	return carry;
}

/*
* Word Subtraction
*/
word word_sub(word x, word y, word* carry)
{
	word t0 = x - y;
	word c1 = (t0 > x);
	word z = t0 - *carry;
	*carry = c1 | (z > t0);
	return z;
}

/*
* Eight Word Block Subtraction, Two Argument
*/
word word8_sub2(ref word[8] x, const ref word[8] y, word carry)
{
	x[0] = word_sub(x[0], y[0], &carry);
	x[1] = word_sub(x[1], y[1], &carry);
	x[2] = word_sub(x[2], y[2], &carry);
	x[3] = word_sub(x[3], y[3], &carry);
	x[4] = word_sub(x[4], y[4], &carry);
	x[5] = word_sub(x[5], y[5], &carry);
	x[6] = word_sub(x[6], y[6], &carry);
	x[7] = word_sub(x[7], y[7], &carry);
	return carry;
}

/*
* Eight Word Block Subtraction, Two Argument
*/
word word8_sub2_rev(ref word[8] x, const ref word[8] y, word carry)
{
	x[0] = word_sub(y[0], x[0], &carry);
	x[1] = word_sub(y[1], x[1], &carry);
	x[2] = word_sub(y[2], x[2], &carry);
	x[3] = word_sub(y[3], x[3], &carry);
	x[4] = word_sub(y[4], x[4], &carry);
	x[5] = word_sub(y[5], x[5], &carry);
	x[6] = word_sub(y[6], x[6], &carry);
	x[7] = word_sub(y[7], x[7], &carry);
	return carry;
}

/*
* Eight Word Block Subtraction, Three Argument
*/
word word8_sub3(ref word[8] z, const ref word[8] x, const ref word[8] y, word carry)
{
	z[0] = word_sub(x[0], y[0], &carry);
	z[1] = word_sub(x[1], y[1], &carry);
	z[2] = word_sub(x[2], y[2], &carry);
	z[3] = word_sub(x[3], y[3], &carry);
	z[4] = word_sub(x[4], y[4], &carry);
	z[5] = word_sub(x[5], y[5], &carry);
	z[6] = word_sub(x[6], y[6], &carry);
	z[7] = word_sub(x[7], y[7], &carry);
	return carry;
}

/*
* Eight Word Block Linear Multiplication
*/
word word8_linmul2(ref word[8] x, word y, word carry)
{
	version(D_InlineAsm_X86_64) {
		word* _x = x.ptr;
		size_t word_size = word.sizeof;
		asm pure nothrow @nogc {
			mov R8, _x;
			mov RCX, carry;
			
			mov RAX, [R8];
			mov RBX, y;
			mul RBX;
			add RAX, RCX;
			adc RDX, 0;
			mov RCX, RDX;
			mov [R8], RAX;
			add R8, word_size;
			
			mov RAX, [R8];
			mov RBX, y;
			mul RBX;
			add RAX, RCX;
			adc RDX, 0;
			mov RCX, RDX;
			mov [R8], RAX;
			add R8, word_size;
			
			mov RAX, [R8];
			mov RBX, y;
			mul RBX;
			add RAX, RCX;
			adc RDX, 0;
			mov RCX, RDX;
			mov [R8], RAX;
			add R8, word_size;
			
			mov RAX, [R8];
			mov RBX, y;
			mul RBX;
			add RAX, RCX;
			adc RDX, 0;
			mov RCX, RDX;
			mov [R8], RAX;
			add R8, word_size;
			
			mov RAX, [R8];
			mov RBX, y;
			mul RBX;
			add RAX, RCX;
			adc RDX, 0;
			mov RCX, RDX;
			mov [R8], RAX;
			add R8, word_size;
			
			mov RAX, [R8];
			mov RBX, y;
			mul RBX;
			add RAX, RCX;
			adc RDX, 0;
			mov RCX, RDX;
			mov [R8], RAX;
			add R8, word_size;
			
			mov RAX, [R8];
			mov RBX, y;
			mul RBX;
			add RAX, RCX;
			adc RDX, 0;
			mov RCX, RDX;
			mov [R8], RAX;
			add R8, word_size;
			
			mov RAX, [R8];
			mov RBX, y;
			mul RBX;
			add RAX, RCX;
			adc RDX, 0;
			mov carry, RDX;
			mov [R8], RAX;
		}
		return carry;
	}
	else {
		x[0] = word_madd2(x[0], y, &carry);
		x[1] = word_madd2(x[1], y, &carry);
		x[2] = word_madd2(x[2], y, &carry);
		x[3] = word_madd2(x[3], y, &carry);
		x[4] = word_madd2(x[4], y, &carry);
		x[5] = word_madd2(x[5], y, &carry);
		x[6] = word_madd2(x[6], y, &carry);
		x[7] = word_madd2(x[7], y, &carry);
		return carry;
	}
}

/*
* Eight Word Block Linear Multiplication
*/
word word8_linmul3(ref word[8] z, const ref word[8] x, word y, word carry)
{
	
	version(D_InlineAsm_X86_64) {
		word* _x = cast(word*)x.ptr;
		word* _z = z.ptr;
		size_t word_size = word.sizeof;
		asm pure nothrow @nogc {
			mov R8, _x;
			mov R9, _z;
			mov RCX, carry;
			
			mov RAX, [R8];
			mov RBX, y;
			mul RBX;
			add RAX, RCX;
			adc RDX, 0;
			mov RCX, RDX;
			mov [R9], RAX;
			add R8, word_size;
			add R9, word_size;
			
			mov RAX, [R8];
			mov RBX, y;
			mul RBX;
			add RAX, RCX;
			adc RDX, 0;
			mov RCX, RDX;
			mov [R9], RAX;
			add R8, word_size;
			add R9, word_size;
			
			mov RAX, [R8];
			mov RBX, y;
			mul RBX;
			add RAX, RCX;
			adc RDX, 0;
			mov RCX, RDX;
			mov [R9], RAX;
			add R8, word_size;
			add R9, word_size;
			
			mov RAX, [R8];
			mov RBX, y;
			mul RBX;
			add RAX, RCX;
			adc RDX, 0;
			mov RCX, RDX;
			mov [R9], RAX;
			add R8, word_size;
			add R9, word_size;
			
			mov RAX, [R8];
			mov RBX, y;
			mul RBX;
			add RAX, RCX;
			adc RDX, 0;
			mov RCX, RDX;
			mov [R9], RAX;
			add R8, word_size;
			add R9, word_size;
			
			mov RAX, [R8];
			mov RBX, y;
			mul RBX;
			add RAX, RCX;
			adc RDX, 0;
			mov RCX, RDX;
			mov [R9], RAX;
			add R8, word_size;
			add R9, word_size;
			
			mov RAX, [R8];
			mov RBX, y;
			mul RBX;
			add RAX, RCX;
			adc RDX, 0;
			mov RCX, RDX;
			mov [R9], RAX;
			add R8, word_size;
			add R9, word_size;
			
			mov RAX, [R8];
			mov RBX, y;
			mul RBX;
			add RAX, RCX;
			adc RDX, 0;
			mov carry, RDX;
			mov [R9], RAX;
		}
		return carry;
	}
	else {
		z[0] = word_madd2(x[0], y, &carry);
		z[1] = word_madd2(x[1], y, &carry);
		z[2] = word_madd2(x[2], y, &carry);
		z[3] = word_madd2(x[3], y, &carry);
		z[4] = word_madd2(x[4], y, &carry);
		z[5] = word_madd2(x[5], y, &carry);
		z[6] = word_madd2(x[6], y, &carry);
		z[7] = word_madd2(x[7], y, &carry);
		return carry;
	}
}

/*
* Eight Word Block Multiply/Add
*/
word word8_madd3(ref word[8] z, const ref word[8] x, word y, word carry)
{
	version(D_InlineAsm_X86_64) {
		auto _x = x.ptr;
		word* _z = z.ptr;
		size_t word_size = word.sizeof;
		asm pure nothrow @nogc {
			mov R8, _x;
			mov R9, _z;
			mov RCX, carry;
			
			mov RAX, [R8];
			mov RBX, y;
			mul RBX;
			add RAX, [R9];
			adc RDX, 0;
			add RAX, RCX;
			adc RDX, 0;
			mov RCX, RDX;
			mov [R9], RAX;
			add R8, word_size;
			add R9, word_size;
			
			mov RAX, [R8];
			mov RBX, y;
			mul RBX;
			add RAX, [R9];
			adc RDX, 0;
			add RAX, RCX;
			adc RDX, 0;
			mov RCX, RDX;
			mov [R9], RAX;
			add R8, word_size;
			add R9, word_size;
			
			mov RAX, [R8];
			mov RBX, y;
			mul RBX;
			add RAX, [R9];
			adc RDX, 0;
			add RAX, RCX;
			adc RDX, 0;
			mov RCX, RDX;
			mov [R9], RAX;
			add R8, word_size;
			add R9, word_size;
			
			mov RAX, [R8];
			mov RBX, y;
			mul RBX;
			add RAX, [R9];
			adc RDX, 0;
			add RAX, RCX;
			adc RDX, 0;
			mov RCX, RDX;
			mov [R9], RAX;
			add R8, word_size;
			add R9, word_size;
			
			mov RAX, [R8];
			mov RBX, y;
			mul RBX;
			add RAX, [R9];
			adc RDX, 0;
			add RAX, RCX;
			adc RDX, 0;
			mov RCX, RDX;
			mov [R9], RAX;
			add R8, word_size;
			add R9, word_size;
			
			mov RAX, [R8];
			mov RBX, y;
			mul RBX;
			add RAX, [R9];
			adc RDX, 0;
			add RAX, RCX;
			adc RDX, 0;
			mov RCX, RDX;
			mov [R9], RAX;
			add R8, word_size;
			add R9, word_size;
			
			mov RAX, [R8];
			mov RBX, y;
			mul RBX;
			add RAX, [R9];
			adc RDX, 0;
			add RAX, RCX;
			adc RDX, 0;
			mov RCX, RDX;
			mov [R9], RAX;
			add R8, word_size;
			add R9, word_size;
			
			mov RAX, [R8];
			mov RBX, y;
			mul RBX;
			add RAX, [R9];
			adc RDX, 0;
			add RAX, RCX;
			adc RDX, 0;
			mov carry, RDX;
			mov [R9], RAX;
		}
		return carry;
	} else {
		z[0] = word_madd3(x[0], y, z[0], &carry);
		z[1] = word_madd3(x[1], y, z[1], &carry);
		z[2] = word_madd3(x[2], y, z[2], &carry);
		z[3] = word_madd3(x[3], y, z[3], &carry);
		z[4] = word_madd3(x[4], y, z[4], &carry);
		z[5] = word_madd3(x[5], y, z[5], &carry);
		z[6] = word_madd3(x[6], y, z[6], &carry);
		z[7] = word_madd3(x[7], y, z[7], &carry);
		return carry;
	}
}

/*
* Multiply-Add Accumulator
*/
void word3_muladd(word* w2, word* w1, word* w0, word a, word b)
{
	word carry = *w0;
	*w0 = word_madd2(a, b, &carry);
	*w1 += carry;
	*w2 += (*w1 < carry) ? 1 : 0;
}

/*
* Multiply-Add Accumulator
*/
void word3_muladd_2(word* w2, word* w1, word* w0, word a, word b)
{
	word carry = 0;
	a = word_madd2(a, b, &carry);
	b = carry;
	
	word top = (b >> (BOTAN_MP_WORD_BITS-1));
	b <<= 1;
	b |= (a >> (BOTAN_MP_WORD_BITS-1));
	a <<= 1;
	
	carry = 0;
	*w0 = word_add(*w0, a, &carry);
	*w1 = word_add(*w1, b, &carry);
	*w2 = word_add(*w2, top, &carry);
}
