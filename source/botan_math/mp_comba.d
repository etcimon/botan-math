/**
* Comba Multiplication / Squaring
* 
* Copyright:
* (C) 1999-2010,2014 Jack Lloyd
* (C) 2014-2015 Etienne Cimon
*      2006 Luca Piccarreta
*
* License:
* Botan is released under the Simplified BSD License (see LICENSE.md)
*/
module botan_math.mp_comba;

import botan_math.mp_word;
/*
* Comba 4x4 Squaring
*/
void bigint_comba_sqr4(ref word[8] z, const ref word[4] x)
{
	word w2 = 0, w1 = 0, w0 = 0;
	
	word3_muladd(&w2, &w1, &w0, x[ 0], x[ 0]);
	z[ 0] = w0; w0 = 0;
	
	word3_muladd_2(&w0, &w2, &w1, x[ 0], x[ 1]);
	z[ 1] = w1; w1 = 0;
	
	word3_muladd_2(&w1, &w0, &w2, x[ 0], x[ 2]);
	word3_muladd(&w1, &w0, &w2, x[ 1], x[ 1]);
	z[ 2] = w2; w2 = 0;
	
	word3_muladd_2(&w2, &w1, &w0, x[ 0], x[ 3]);
	word3_muladd_2(&w2, &w1, &w0, x[ 1], x[ 2]);
	z[ 3] = w0; w0 = 0;
	
	word3_muladd_2(&w0, &w2, &w1, x[ 1], x[ 3]);
	word3_muladd(&w0, &w2, &w1, x[ 2], x[ 2]);
	
	z[ 4] = w1; w1 = 0;
	
	word3_muladd_2(&w1, &w0, &w2, x[ 2], x[ 3]);
	z[ 5] = w2; w2 = 0;
	
	word3_muladd(&w2, &w1, &w0, x[ 3], x[ 3]);
	z[ 6] = w0;
	z[ 7] = w1;
}

/*
* Comba 4x4 Multiplication
*/
void bigint_comba_mul4(ref word[8] z, const ref word[4] x, const ref word[4] y)
{
	// issue with rw and intermittent with rsa
	version(none) {
		
		auto _x = x.ptr;
		auto _y = y.ptr;
		word* _z = z.ptr;
		// w1 : R14
		// w2 : R15
		// w0 : R13
		{
			asm pure nothrow @nogc {
				
				align 8;
				mov R8, _x;
				mov R9, _y;
				mov R10, _z;
				mov R15, 0;
				mov R13, 0;
				mov R14, 0;
				
				//1
				mov RAX, [R8];
				mov RBX, [R9];
				mul RBX;
				
				add RAX, R13;
				adc RDX, 0;
				add R14, RDX;
				mov R13, RAX;
				cmp R14, RDX;
				jnb MUL_2;
				add R15, 1;
				
			MUL_2:
				
				align 8;
				//2
				add R9, 8;
				mov [R10], R13;
				xor R13, R13;
				// R15: w2, R13: w0, R14: w1
				mov RAX, [R8];
				mov RBX, [R9];
				mul RBX;
				add RAX, R14;
				adc RDX, 0;
				add R15, RDX;
				mov R14, RAX;
				cmp R15, RDX;
				jnb MUL_3;
				add R13, 1;
			MUL_3:
				align 8;
				add R8, 8;
				sub R9, 8;
				
				mov RAX, [R8];
				mov RBX, [R9];
				mul RBX;
				add RAX, R14;
				adc RDX, 0;
				add R15, RDX;
				mov R14, RAX;
				cmp R15, RDX;
				jnb MUL_4;
				add R13, 1;
				
			MUL_4:
				align 8;
				sub R8, 8;
				add R9, 8;
				add R9, 8;
				add R10, 8;
				// R15: w2, R13: w0, R14: w1
				mov [R10], R14;
				mov R14, 0;
				
				mov RAX, [R8];
				mov RBX, [R9];
				mul RBX;
				add RAX, R15;
				adc RDX, 0;
				add R13, RDX;
				mov R15, RAX;
				cmp R13, RDX;
				jnb MUL_5;
				add R14, 1;
			MUL_5:
				align 8;
				add R8, 8;
				sub R9, 8;
				
				mov RAX, [R8];
				mov RBX, [R9];
				mul RBX;
				add RAX, R15;
				adc RDX, 0;
				add R13, RDX;
				mov R15, RAX;
				cmp R13, RDX;
				jnb MUL_6;
				add R14, 1;
				
			MUL_6:
				align 8;
				add R8, 8;
				sub R9, 8;
				
				mov RAX, [R8];
				mov RBX, [R9];
				mul RBX;
				add RAX, R15;
				adc RDX, 0;
				add R13, RDX;
				add R10, 8;
				mov R15, RAX;
				cmp R13, RDX;
				jnb MUL_7;
				add R14, 1;
				
			MUL_7:
				align 8;
				sub R8, 8;
				sub R8, 8;
				add R9, 8;
				add R9, 8;
				add R9, 8;
				mov [R10], R15;
				mov R15, 0;
				// R15: w2, R13: w0, R14: w1
				
				mov RAX, [R8];
				mov RBX, [R9];
				mul RBX;
				add RAX, R13;
				adc RDX, 0;
				add R14, RDX;
				mov R13, RAX;
				cmp R14, RDX;
				jnb MUL_8;
				add R15, 1;
				
			MUL_8:
				align 8;				
				add R8, 8;
				sub R9, 8;
				
				mov RAX, [R8];
				mov RBX, [R9];
				mul RBX;
				add RAX, R13;
				adc RDX, 0;
				add R14, RDX;
				mov R13, RAX;
				cmp R14, RDX;
				jnb MUL_9;
				add R15, 1;
			MUL_9:		
				align 8;	
				add R8, 8;
				sub R9, 8;
				// R15: w2, R13: w0, R14: w1
				
				mov RAX, [R8];
				mov RBX, [R9];
				mul RBX;
				add RAX, R13;
				adc RDX, 0;
				add R14, RDX;
				mov R13, RAX;
				cmp R14, RDX;
				jnb MUL_10;
				add R15, 1;
			MUL_10:	
				align 8;		
				add R8, 8;
				sub R9, 8;
				// R15: w2, R13: w0, R14: w1
				
				mov RAX, [R8];
				mov RBX, [R9];
				mul RBX;
				add RAX, R13;
				adc RDX, 0;
				add R14, RDX;
				mov R13, RAX;
				cmp R14, RDX;
				jnb MUL_11;
				add R15, 1;
				
			MUL_11:	
				align 8;		
				sub R8, 8;
				sub R8, 8;
				add R9, 8;
				add R9, 8;
				add R9, 8;
				add R10, 8;
				mov [R10], R13;
				mov R13, 0;
				// R15: w2, R13: w0, R14: w1
				
				mov RAX, [R8];
				mov RBX, [R9];
				mul RBX;
				add RAX, R14;
				adc RDX, 0;
				add R15, RDX;
				mov R14, RAX;
				cmp R15, RDX;
				jnb MUL_12;
				add R13, 1;
			MUL_12:		
				align 8;
				add R8, 8;
				sub R9, 8;
				// R15: w2, R13: w0, R14: w1
				
				mov RAX, [R8];
				mov RBX, [R9];
				mul RBX;
				add RAX, R14;
				adc RDX, 0;
				add R15, RDX;
				mov R14, RAX;
				cmp R15, RDX;
				jnb MUL_13;
				add R13, 1;
			MUL_13:	
				align 8;		
				add R8, 8;
				sub R9, 8;
				// R15: w2, R13: w0, R14: w1
				
				mov RAX, [R8];
				mov RBX, [R9];
				mul RBX;
				add RAX, R14;
				adc RDX, 0;
				add R15, RDX;
				mov R14, RAX;
				cmp R15, RDX;
				jnb MUL_14;
				add R13, 1;
			MUL_14:		
				align 8;
				sub R8, 8;
				add R9, 8;
				add R9, 8;
				add R10, 8;
				add [R10], R14;
				mov R14, 0;
				// R15: w2, R13: w0, R14: w1
				
				mov RAX, [R8];
				mov RBX, [R9];
				mul RBX;
				add RAX, R15;
				adc RDX, 0;
				add R13, RDX;
				mov R15, RAX;
				cmp R13, RDX;
				jnb MUL_15;
				add R14, 1;
			MUL_15:	
				align 8;		
				add R8, 8;
				sub R9, 8;
				// R15: w2, R13: w0, R14: w1
				
				mov RAX, [R8];
				mov RBX, [R9];
				mul RBX;
				add RAX, R15;
				adc RDX, 0;
				add R13, RDX;
				mov R15, RAX;
				cmp R13, RDX;
				jnb MUL_16;
				add R14, 1;
				
			MUL_16:	
				align 8;		
				add R9, 8;
				// R15: w2, R13: w0, R14: w1
				
				add R10, 8;
				mov [R10], R15;
				mov R15, 0;
				
				mov RAX, [R8];
				mov RBX, [R9];
				mul RBX;
				add RAX, R13;
				adc RDX, 0;
				add R14, RDX;
				add R10, 8;
				mov [R10], RAX;
				add R10, 8;
				mov [R10], R14;
				
			}
		}
	} else
	{
		word w2 = 0, w1 = 0, w0 = 0;
		word carry;
		{
			carry = w0;
			w0 = word_madd2(x[0], y[0], &carry);
			w1 += carry;
			w2 += (w1 < carry) ? 1 : 0;
		}
		z[ 0] = w0; w0 = 0;
		
		{ //2
			carry = w1;
			w1 = word_madd2(x[0], y[1], &carry);
			w2 += carry;
			w0 += (w2 < carry) ? 1 : 0;
		}
		{
			carry = w1;
			w1 = word_madd2(x[1], y[0], &carry);
			w2 += carry;
			w0 += (w2 < carry) ? 1 : 0;
		}
		z[ 1] = w1; w1 = 0;
		
		{ //4
			carry = w2;
			w2 = word_madd2(x[0], y[2], &carry);
			w0 += carry;
			w1 += (w0 < carry) ? 1 : 0;
		}
		{ //5
			carry = w2;
			w2 = word_madd2(x[1], y[1], &carry);
			w0 += carry;
			w1 += (w0 < carry) ? 1 : 0;
		}
		{ //6
			carry = w2;
			w2 = word_madd2(x[2], y[0], &carry);
			w0 += carry;
			w1 += (w0 < carry) ? 1 : 0;
		}
		z[ 2] = w2; w2 = 0;
		
		{ //7
			carry = w0;
			w0 = word_madd2(x[0], y[3], &carry);
			w1 += carry;
			w2 += (w1 < carry) ? 1 : 0;
		}
		{//8
			carry = w0;
			w0 = word_madd2(x[1], y[2], &carry);
			w1 += carry;
			w2 += (w1 < carry) ? 1 : 0;
		}
		{//9
			carry = w0;
			w0 = word_madd2(x[2], y[1], &carry);
			w1 += carry;
			w2 += (w1 < carry) ? 1 : 0;
		}
		{//10
			carry = w0;
			w0 = word_madd2(x[3], y[0], &carry);
			w1 += carry;
			w2 += (w1 < carry) ? 1 : 0;
		}
		z[ 3] = w0; w0 = 0;
		
		{//11
			carry = w1;
			w1 = word_madd2(x[1], y[3], &carry);
			w2 += carry;
			w0 += (w2 < carry) ? 1 : 0;
		}
		{//12
			carry = w1;
			w1 = word_madd2(x[2], y[2], &carry);
			w2 += carry;
			w0 += (w2 < carry) ? 1 : 0;
		}
		{//13
			carry = w1;
			w1 = word_madd2(x[3], y[1], &carry);
			w2 += carry;
			w0 += (w2 < carry) ? 1 : 0;
		}
		z[ 4] = w1; w1 = 0;
		
		{//14
			carry = w2;
			w2 = word_madd2(x[2], y[3], &carry);
			w0 += carry;
			w1 += (w0 < carry) ? 1 : 0;
		}
		{//15
			carry = w2;
			w2 = word_madd2(x[3], y[2], &carry);
			w0 += carry;
			w1 += (w0 < carry) ? 1 : 0;
		}
		z[ 5] = w2; w2 = 0;
		
		{//16
			carry = w0;
			w0 = word_madd2(x[3], y[3], &carry);
			w1 += carry;
			w2 += (w1 < carry) ? 1 : 0;
		}
		z[ 6] = w0;
		z[ 7] = w1;
	}
}

/*
* Comba 6x6 Squaring
*/
void bigint_comba_sqr6(ref word[12] z, const ref word[6] x)
{
	word w2 = 0, w1 = 0, w0 = 0;
	
	word3_muladd(&w2, &w1, &w0, x[ 0], x[ 0]);
	z[ 0] = w0; w0 = 0;
	
	word3_muladd_2(&w0, &w2, &w1, x[ 0], x[ 1]);
	z[ 1] = w1; w1 = 0;
	
	word3_muladd_2(&w1, &w0, &w2, x[ 0], x[ 2]);
	word3_muladd(&w1, &w0, &w2, x[ 1], x[ 1]);
	z[ 2] = w2; w2 = 0;
	
	word3_muladd_2(&w2, &w1, &w0, x[ 0], x[ 3]);
	word3_muladd_2(&w2, &w1, &w0, x[ 1], x[ 2]);
	z[ 3] = w0; w0 = 0;
	
	word3_muladd_2(&w0, &w2, &w1, x[ 0], x[ 4]);
	word3_muladd_2(&w0, &w2, &w1, x[ 1], x[ 3]);
	word3_muladd(&w0, &w2, &w1, x[ 2], x[ 2]);
	z[ 4] = w1; w1 = 0;
	
	word3_muladd_2(&w1, &w0, &w2, x[ 0], x[ 5]);
	word3_muladd_2(&w1, &w0, &w2, x[ 1], x[ 4]);
	word3_muladd_2(&w1, &w0, &w2, x[ 2], x[ 3]);
	z[ 5] = w2; w2 = 0;
	
	word3_muladd_2(&w2, &w1, &w0, x[ 1], x[ 5]);
	word3_muladd_2(&w2, &w1, &w0, x[ 2], x[ 4]);
	word3_muladd(&w2, &w1, &w0, x[ 3], x[ 3]);
	z[ 6] = w0; w0 = 0;
	
	word3_muladd_2(&w0, &w2, &w1, x[ 2], x[ 5]);
	word3_muladd_2(&w0, &w2, &w1, x[ 3], x[ 4]);
	z[ 7] = w1; w1 = 0;
	
	word3_muladd_2(&w1, &w0, &w2, x[ 3], x[ 5]);
	word3_muladd(&w1, &w0, &w2, x[ 4], x[ 4]);
	z[ 8] = w2; w2 = 0;
	
	word3_muladd_2(&w2, &w1, &w0, x[ 4], x[ 5]);
	z[ 9] = w0; w0 = 0;
	
	word3_muladd(&w0, &w2, &w1, x[ 5], x[ 5]);
	z[10] = w1;
	z[11] = w2;
}

/*
* Comba 6x6 Multiplication
*/
void bigint_comba_mul6(ref word[12] z, const ref word[6] x, const ref word[6] y)
{
	word w2 = 0, w1 = 0, w0 = 0;
	word carry;
	{
		carry = w0;
		w0 = word_madd2(x[0], y[0], &carry);
		w1 += carry;
		w2 += (w1 < carry) ? 1 : 0;
	}
	z[ 0] = w0; w0 = 0;
	
	{
		carry = w1;
		w1 = word_madd2(x[0], y[1], &carry);
		w2 += carry;
		w0 += (w2 < carry) ? 1 : 0;
	}
	{
		carry = w1;
		w1 = word_madd2(x[1], y[0], &carry);
		w2 += carry;
		w0 += (w2 < carry) ? 1 : 0;
	}
	z[ 1] = w1; w1 = 0;
	
	{
		carry = w2;
		w2 = word_madd2(x[0], y[2], &carry);
		w0 += carry;
		w1 += (w0 < carry) ? 1 : 0;
	}
	{
		carry = w2;
		w2 = word_madd2(x[1], y[1], &carry);
		w0 += carry;
		w1 += (w0 < carry) ? 1 : 0;
	}
	{
		carry = w2;
		w2 = word_madd2(x[2], y[0], &carry);
		w0 += carry;
		w1 += (w0 < carry) ? 1 : 0;
	}
	z[ 2] = w2; w2 = 0;
	
	{
		carry = w0;
		w0 = word_madd2(x[0], y[3], &carry);
		w1 += carry;
		w2 += (w1 < carry) ? 1 : 0;
	}
	{
		carry = w0;
		w0 = word_madd2(x[1], y[2], &carry);
		w1 += carry;
		w2 += (w1 < carry) ? 1 : 0;
	}
	{
		carry = w0;
		w0 = word_madd2(x[2], y[1], &carry);
		w1 += carry;
		w2 += (w1 < carry) ? 1 : 0;
	}
	{
		carry = w0;
		w0 = word_madd2(x[3], y[0], &carry);
		w1 += carry;
		w2 += (w1 < carry) ? 1 : 0;
	}
	z[ 3] = w0; w0 = 0;
	
	{
		carry = w1;
		w1 = word_madd2(x[0], y[4], &carry);
		w2 += carry;
		w0 += (w2 < carry) ? 1 : 0;
	}
	{
		carry = w1;
		w1 = word_madd2(x[1], y[3], &carry);
		w2 += carry;
		w0 += (w2 < carry) ? 1 : 0;
	}
	{
		carry = w1;
		w1 = word_madd2(x[2], y[2], &carry);
		w2 += carry;
		w0 += (w2 < carry) ? 1 : 0;
	}
	{
		carry = w1;
		w1 = word_madd2(x[3], y[1], &carry);
		w2 += carry;
		w0 += (w2 < carry) ? 1 : 0;
	}
	{
		carry = w1;
		w1 = word_madd2(x[4], y[0], &carry);
		w2 += carry;
		w0 += (w2 < carry) ? 1 : 0;
	}
	z[ 4] = w1; w1 = 0;
	
	{
		carry = w2;
		w2 = word_madd2(x[0], y[5], &carry);
		w0 += carry;
		w1 += (w0 < carry) ? 1 : 0;
	}
	{
		carry = w2;
		w2 = word_madd2(x[1], y[4], &carry);
		w0 += carry;
		w1 += (w0 < carry) ? 1 : 0;
	}
	{
		carry = w2;
		w2 = word_madd2(x[2], y[3], &carry);
		w0 += carry;
		w1 += (w0 < carry) ? 1 : 0;
	}
	{
		carry = w2;
		w2 = word_madd2(x[3], y[2], &carry);
		w0 += carry;
		w1 += (w0 < carry) ? 1 : 0;
	}
	{
		carry = w2;
		w2 = word_madd2(x[4], y[1], &carry);
		w0 += carry;
		w1 += (w0 < carry) ? 1 : 0;
	}
	{
		carry = w2;
		w2 = word_madd2(x[5], y[0], &carry);
		w0 += carry;
		w1 += (w0 < carry) ? 1 : 0;
	}
	z[ 5] = w2; w2 = 0;
	
	{
		carry = w0;
		w0 = word_madd2(x[1], y[5], &carry);
		w1 += carry;
		w2 += (w1 < carry) ? 1 : 0;
	}
	{
		carry = w0;
		w0 = word_madd2(x[2], y[4], &carry);
		w1 += carry;
		w2 += (w1 < carry) ? 1 : 0;
	}
	{
		carry = w0;
		w0 = word_madd2(x[3], y[3], &carry);
		w1 += carry;
		w2 += (w1 < carry) ? 1 : 0;
	}
	{
		carry = w0;
		w0 = word_madd2(x[4], y[2], &carry);
		w1 += carry;
		w2 += (w1 < carry) ? 1 : 0;
	}
	{
		carry = w0;
		w0 = word_madd2(x[5], y[1], &carry);
		w1 += carry;
		w2 += (w1 < carry) ? 1 : 0;
	}
	z[ 6] = w0; w0 = 0;
	
	{
		carry = w1;
		w1 = word_madd2(x[2], y[5], &carry);
		w2 += carry;
		w0 += (w2 < carry) ? 1 : 0;
	}
	{
		carry = w1;
		w1 = word_madd2(x[3], y[4], &carry);
		w2 += carry;
		w0 += (w2 < carry) ? 1 : 0;
	}
	{
		carry = w1;
		w1 = word_madd2(x[4], y[3], &carry);
		w2 += carry;
		w0 += (w2 < carry) ? 1 : 0;
	}
	{
		carry = w1;
		w1 = word_madd2(x[5], y[2], &carry);
		w2 += carry;
		w0 += (w2 < carry) ? 1 : 0;
	}
	z[ 7] = w1; w1 = 0;
	
	{
		carry = w2;
		w2 = word_madd2(x[3], y[5], &carry);
		w0 += carry;
		w1 += (w0 < carry) ? 1 : 0;
	}
	{
		carry = w2;
		w2 = word_madd2(x[4], y[4], &carry);
		w0 += carry;
		w1 += (w0 < carry) ? 1 : 0;
	}
	{
		carry = w2;
		w2 = word_madd2(x[5], y[3], &carry);
		w0 += carry;
		w1 += (w0 < carry) ? 1 : 0;
	}
	z[ 8] = w2; w2 = 0;
	
	{
		carry = w0;
		w0 = word_madd2(x[4], y[5], &carry);
		w1 += carry;
		w2 += (w1 < carry) ? 1 : 0;
	}
	{
		carry = w0;
		w0 = word_madd2(x[5], y[4], &carry);
		w1 += carry;
		w2 += (w1 < carry) ? 1 : 0;
	}
	z[ 9] = w0; w0 = 0;
	
	{
		carry = w1;
		w1 = word_madd2(x[5], y[5], &carry);
		w2 += carry;
		w0 += (w2 < carry) ? 1 : 0;
	}
	z[10] = w1;
	z[11] = w2;
}

/*
* Comba 8x8 Squaring
*/
void bigint_comba_sqr8(ref word[16] z, const ref word[8] x)
{
	word w2 = 0, w1 = 0, w0 = 0;
	
	word3_muladd(&w2, &w1, &w0, x[ 0], x[ 0]);
	z[ 0] = w0; w0 = 0;
	
	word3_muladd_2(&w0, &w2, &w1, x[ 0], x[ 1]);
	z[ 1] = w1; w1 = 0;
	
	word3_muladd_2(&w1, &w0, &w2, x[ 0], x[ 2]);
	word3_muladd(&w1, &w0, &w2, x[ 1], x[ 1]);
	z[ 2] = w2; w2 = 0;
	
	word3_muladd_2(&w2, &w1, &w0, x[ 0], x[ 3]);
	word3_muladd_2(&w2, &w1, &w0, x[ 1], x[ 2]);
	z[ 3] = w0; w0 = 0;
	
	word3_muladd_2(&w0, &w2, &w1, x[ 0], x[ 4]);
	word3_muladd_2(&w0, &w2, &w1, x[ 1], x[ 3]);
	word3_muladd(&w0, &w2, &w1, x[ 2], x[ 2]);
	z[ 4] = w1; w1 = 0;
	
	word3_muladd_2(&w1, &w0, &w2, x[ 0], x[ 5]);
	word3_muladd_2(&w1, &w0, &w2, x[ 1], x[ 4]);
	word3_muladd_2(&w1, &w0, &w2, x[ 2], x[ 3]);
	z[ 5] = w2; w2 = 0;
	
	word3_muladd_2(&w2, &w1, &w0, x[ 0], x[ 6]);
	word3_muladd_2(&w2, &w1, &w0, x[ 1], x[ 5]);
	word3_muladd_2(&w2, &w1, &w0, x[ 2], x[ 4]);
	word3_muladd(&w2, &w1, &w0, x[ 3], x[ 3]);
	z[ 6] = w0; w0 = 0;
	
	word3_muladd_2(&w0, &w2, &w1, x[ 0], x[ 7]);
	word3_muladd_2(&w0, &w2, &w1, x[ 1], x[ 6]);
	word3_muladd_2(&w0, &w2, &w1, x[ 2], x[ 5]);
	word3_muladd_2(&w0, &w2, &w1, x[ 3], x[ 4]);
	z[ 7] = w1; w1 = 0;
	
	word3_muladd_2(&w1, &w0, &w2, x[ 1], x[ 7]);
	word3_muladd_2(&w1, &w0, &w2, x[ 2], x[ 6]);
	word3_muladd_2(&w1, &w0, &w2, x[ 3], x[ 5]);
	word3_muladd(&w1, &w0, &w2, x[ 4], x[ 4]);
	z[ 8] = w2; w2 = 0;
	
	word3_muladd_2(&w2, &w1, &w0, x[ 2], x[ 7]);
	word3_muladd_2(&w2, &w1, &w0, x[ 3], x[ 6]);
	word3_muladd_2(&w2, &w1, &w0, x[ 4], x[ 5]);
	z[ 9] = w0; w0 = 0;
	
	word3_muladd_2(&w0, &w2, &w1, x[ 3], x[ 7]);
	word3_muladd_2(&w0, &w2, &w1, x[ 4], x[ 6]);
	word3_muladd(&w0, &w2, &w1, x[ 5], x[ 5]);
	z[10] = w1; w1 = 0;
	
	word3_muladd_2(&w1, &w0, &w2, x[ 4], x[ 7]);
	word3_muladd_2(&w1, &w0, &w2, x[ 5], x[ 6]);
	z[11] = w2; w2 = 0;
	
	word3_muladd_2(&w2, &w1, &w0, x[ 5], x[ 7]);
	word3_muladd(&w2, &w1, &w0, x[ 6], x[ 6]);
	z[12] = w0; w0 = 0;
	
	word3_muladd_2(&w0, &w2, &w1, x[ 6], x[ 7]);
	z[13] = w1; w1 = 0;
	
	word3_muladd(&w1, &w0, &w2, x[ 7], x[ 7]);
	z[14] = w2;
	z[15] = w0;
}

/*
* Comba 8x8 Multiplication
*/
void bigint_comba_mul8(ref word[16] z, const ref word[8] x, const ref word[8] y)
{
	word w2 = 0, w1 = 0, w0 = 0;
	size_t carry;
	void word3_mulladd_012(size_t i, size_t j) {
		carry = w0;
		w0 = word_madd2(x.ptr[i], y.ptr[j], &carry);
		w1 += carry;
		w2 += (w1 < carry) ? 1 : 0;
	}
	
	void word3_mulladd_021(size_t i, size_t j) {
		carry = w1;
		w1 = word_madd2(x.ptr[i], y.ptr[j], &carry);
		w2 += carry;
		w0 += (w2 < carry) ? 1 : 0;
	}
	
	void word3_mulladd_102(size_t i, size_t j) {
		carry = w2;
		w2 = word_madd2(x.ptr[i], y.ptr[j], &carry);
		w0 += carry;
		w1 += (w0 < carry) ? 1 : 0;
	}
	
	void word3_mulladd_210(size_t i, size_t j) {
		carry = w0;
		w0 = word_madd2(x.ptr[i], y.ptr[j], &carry);
		w1 += carry;
		w2 += (w1 < carry) ? 1 : 0;
	}
	
	
	word3_mulladd_012(0, 0);
	
	z[ 0] = w0; w0 = 0;
	
	word3_mulladd_021(0, 1);
	word3_mulladd_021(1, 0);
	z[ 1] = w1; w1 = 0;
	
	word3_mulladd_102(0, 2);
	word3_mulladd_102(1, 1);
	word3_mulladd_102(2, 0);
	z[ 2] = w2; w2 = 0;
	
	word3_mulladd_210(0, 3);
	word3_mulladd_210(1, 2);
	word3_mulladd_210(2, 1);
	word3_mulladd_210(3, 0);
	z[ 3] = w0; w0 = 0;
	
	word3_mulladd_021(0, 4);
	word3_mulladd_021(1, 3);
	word3_mulladd_021(2, 2);
	word3_mulladd_021(3, 1);
	word3_mulladd_021(4, 0);
	z[ 4] = w1; w1 = 0;
	
	word3_mulladd_102(0, 5);
	word3_mulladd_102(1, 4);
	word3_mulladd_102(2, 3);
	word3_mulladd_102(3, 2);
	word3_mulladd_102(4, 1);
	word3_mulladd_102(5, 0);
	z[ 5] = w2; w2 = 0;
	
	word3_mulladd_210(0, 6);
	word3_mulladd_210(1, 5);
	word3_mulladd_210(2, 4);
	word3_mulladd_210(3, 3);
	word3_mulladd_210(4, 2);
	word3_mulladd_210(5, 1);
	word3_mulladd_210(6, 0);
	z[ 6] = w0; w0 = 0;
	
	word3_mulladd_021(0, 7);
	word3_mulladd_021(1, 6);
	word3_mulladd_021(2, 5);
	word3_mulladd_021(3, 4);
	word3_mulladd_021(4, 3);
	word3_mulladd_021(5, 2);
	word3_mulladd_021(6, 1);
	word3_mulladd_021(7, 0);
	z[ 7] = w1; w1 = 0;
	
	word3_mulladd_102(1, 7);
	word3_mulladd_102(2, 6);
	word3_mulladd_102(3, 5);
	word3_mulladd_102(4, 4);
	word3_mulladd_102(5, 3);
	word3_mulladd_102(6, 2);
	word3_mulladd_102(7, 1);
	z[ 8] = w2; w2 = 0;
	
	word3_mulladd_210(2, 7);
	word3_mulladd_210(3, 6);
	word3_mulladd_210(4, 5);
	word3_mulladd_210(5, 4);
	word3_mulladd_210(6, 3);
	word3_mulladd_210(7, 2);
	z[ 9] = w0; w0 = 0;
	
	word3_mulladd_021(3, 7);
	word3_mulladd_021(4, 6);
	word3_mulladd_021(5, 5);
	word3_mulladd_021(6, 4);
	word3_mulladd_021(7, 3);
	z[10] = w1; w1 = 0;
	
	word3_mulladd_102(4, 7);
	word3_mulladd_102(5, 6);
	word3_mulladd_102(6, 5);
	word3_mulladd_102(7, 4);
	z[11] = w2; w2 = 0;
	
	word3_mulladd_210(5, 7);
	word3_mulladd_210(6, 6);
	word3_mulladd_210(7, 5);
	z[12] = w0; w0 = 0;
	
	word3_mulladd_021(6, 7);
	word3_mulladd_021(7, 6);
	z[13] = w1; w1 = 0;
	
	word3_mulladd_102(7, 7);
	z[14] = w2;
	z[15] = w0;
}

/*
* Comba 9x9 Squaring
*/
void bigint_comba_sqr9(ref word[18] z, const ref word[9] x)
{
	word w2 = 0, w1 = 0, w0 = 0;
	
	word3_muladd(&w2, &w1, &w0, x[ 0], x[ 0]);
	z[ 0] = w0; w0 = 0;
	
	word3_muladd_2(&w0, &w2, &w1, x[ 0], x[ 1]);
	z[ 1] = w1; w1 = 0;
	
	word3_muladd_2(&w1, &w0, &w2, x[ 0], x[ 2]);
	word3_muladd(&w1, &w0, &w2, x[ 1], x[ 1]);
	z[ 2] = w2; w2 = 0;
	
	word3_muladd_2(&w2, &w1, &w0, x[ 0], x[ 3]);
	word3_muladd_2(&w2, &w1, &w0, x[ 1], x[ 2]);
	z[ 3] = w0; w0 = 0;
	
	word3_muladd_2(&w0, &w2, &w1, x[ 0], x[ 4]);
	word3_muladd_2(&w0, &w2, &w1, x[ 1], x[ 3]);
	word3_muladd(&w0, &w2, &w1, x[ 2], x[ 2]);
	z[ 4] = w1; w1 = 0;
	
	word3_muladd_2(&w1, &w0, &w2, x[ 0], x[ 5]);
	word3_muladd_2(&w1, &w0, &w2, x[ 1], x[ 4]);
	word3_muladd_2(&w1, &w0, &w2, x[ 2], x[ 3]);
	z[ 5] = w2; w2 = 0;
	
	word3_muladd_2(&w2, &w1, &w0, x[ 0], x[ 6]);
	word3_muladd_2(&w2, &w1, &w0, x[ 1], x[ 5]);
	word3_muladd_2(&w2, &w1, &w0, x[ 2], x[ 4]);
	word3_muladd(&w2, &w1, &w0, x[ 3], x[ 3]);
	z[ 6] = w0; w0 = 0;
	
	word3_muladd_2(&w0, &w2, &w1, x[ 0], x[ 7]);
	word3_muladd_2(&w0, &w2, &w1, x[ 1], x[ 6]);
	word3_muladd_2(&w0, &w2, &w1, x[ 2], x[ 5]);
	word3_muladd_2(&w0, &w2, &w1, x[ 3], x[ 4]);
	z[ 7] = w1; w1 = 0;
	
	word3_muladd_2(&w1, &w0, &w2, x[ 0], x[ 8]);
	word3_muladd_2(&w1, &w0, &w2, x[ 1], x[ 7]);
	word3_muladd_2(&w1, &w0, &w2, x[ 2], x[ 6]);
	word3_muladd_2(&w1, &w0, &w2, x[ 3], x[ 5]);
	word3_muladd(&w1, &w0, &w2, x[ 4], x[ 4]);
	z[ 8] = w2; w2 = 0;
	
	word3_muladd_2(&w2, &w1, &w0, x[ 1], x[ 8]);
	word3_muladd_2(&w2, &w1, &w0, x[ 2], x[ 7]);
	word3_muladd_2(&w2, &w1, &w0, x[ 3], x[ 6]);
	word3_muladd_2(&w2, &w1, &w0, x[ 4], x[ 5]);
	z[ 9] = w0; w0 = 0;
	
	word3_muladd_2(&w0, &w2, &w1, x[ 2], x[ 8]);
	word3_muladd_2(&w0, &w2, &w1, x[ 3], x[ 7]);
	word3_muladd_2(&w0, &w2, &w1, x[ 4], x[ 6]);
	word3_muladd(&w0, &w2, &w1, x[ 5], x[ 5]);
	z[10] = w1; w1 = 0;
	
	word3_muladd_2(&w1, &w0, &w2, x[ 3], x[ 8]);
	word3_muladd_2(&w1, &w0, &w2, x[ 4], x[ 7]);
	word3_muladd_2(&w1, &w0, &w2, x[ 5], x[ 6]);
	z[11] = w2; w2 = 0;
	
	word3_muladd_2(&w2, &w1, &w0, x[ 4], x[ 8]);
	word3_muladd_2(&w2, &w1, &w0, x[ 5], x[ 7]);
	word3_muladd(&w2, &w1, &w0, x[ 6], x[ 6]);
	z[12] = w0; w0 = 0;
	
	word3_muladd_2(&w0, &w2, &w1, x[ 5], x[ 8]);
	word3_muladd_2(&w0, &w2, &w1, x[ 6], x[ 7]);
	z[13] = w1; w1 = 0;
	
	word3_muladd_2(&w1, &w0, &w2, x[ 6], x[ 8]);
	word3_muladd(&w1, &w0, &w2, x[ 7], x[ 7]);
	z[14] = w2; w2 = 0;
	
	word3_muladd_2(&w2, &w1, &w0, x[ 7], x[ 8]);
	z[15] = w0; w0 = 0;
	
	word3_muladd(&w0, &w2, &w1, x[ 8], x[ 8]);
	z[16] = w1;
	z[17] = w2;
}

/*
* Comba 9x9 Multiplication
*/
void bigint_comba_mul9(ref word[18] z, const ref word[9] x, const ref word[9] y)
{
	word w2 = 0, w1 = 0, w0 = 0;
	
	word3_muladd(&w2, &w1, &w0, x[ 0], y[ 0]);
	z[ 0] = w0; w0 = 0;
	
	word3_muladd(&w0, &w2, &w1, x[ 0], y[ 1]);
	word3_muladd(&w0, &w2, &w1, x[ 1], y[ 0]);
	z[ 1] = w1; w1 = 0;
	
	word3_muladd(&w1, &w0, &w2, x[ 0], y[ 2]);
	word3_muladd(&w1, &w0, &w2, x[ 1], y[ 1]);
	word3_muladd(&w1, &w0, &w2, x[ 2], y[ 0]);
	z[ 2] = w2; w2 = 0;
	
	word3_muladd(&w2, &w1, &w0, x[ 0], y[ 3]);
	word3_muladd(&w2, &w1, &w0, x[ 1], y[ 2]);
	word3_muladd(&w2, &w1, &w0, x[ 2], y[ 1]);
	word3_muladd(&w2, &w1, &w0, x[ 3], y[ 0]);
	z[ 3] = w0; w0 = 0;
	
	word3_muladd(&w0, &w2, &w1, x[ 0], y[ 4]);
	word3_muladd(&w0, &w2, &w1, x[ 1], y[ 3]);
	word3_muladd(&w0, &w2, &w1, x[ 2], y[ 2]);
	word3_muladd(&w0, &w2, &w1, x[ 3], y[ 1]);
	word3_muladd(&w0, &w2, &w1, x[ 4], y[ 0]);
	z[ 4] = w1; w1 = 0;
	
	word3_muladd(&w1, &w0, &w2, x[ 0], y[ 5]);
	word3_muladd(&w1, &w0, &w2, x[ 1], y[ 4]);
	word3_muladd(&w1, &w0, &w2, x[ 2], y[ 3]);
	word3_muladd(&w1, &w0, &w2, x[ 3], y[ 2]);
	word3_muladd(&w1, &w0, &w2, x[ 4], y[ 1]);
	word3_muladd(&w1, &w0, &w2, x[ 5], y[ 0]);
	z[ 5] = w2; w2 = 0;
	
	word3_muladd(&w2, &w1, &w0, x[ 0], y[ 6]);
	word3_muladd(&w2, &w1, &w0, x[ 1], y[ 5]);
	word3_muladd(&w2, &w1, &w0, x[ 2], y[ 4]);
	word3_muladd(&w2, &w1, &w0, x[ 3], y[ 3]);
	word3_muladd(&w2, &w1, &w0, x[ 4], y[ 2]);
	word3_muladd(&w2, &w1, &w0, x[ 5], y[ 1]);
	word3_muladd(&w2, &w1, &w0, x[ 6], y[ 0]);
	z[ 6] = w0; w0 = 0;
	
	word3_muladd(&w0, &w2, &w1, x[ 0], y[ 7]);
	word3_muladd(&w0, &w2, &w1, x[ 1], y[ 6]);
	word3_muladd(&w0, &w2, &w1, x[ 2], y[ 5]);
	word3_muladd(&w0, &w2, &w1, x[ 3], y[ 4]);
	word3_muladd(&w0, &w2, &w1, x[ 4], y[ 3]);
	word3_muladd(&w0, &w2, &w1, x[ 5], y[ 2]);
	word3_muladd(&w0, &w2, &w1, x[ 6], y[ 1]);
	word3_muladd(&w0, &w2, &w1, x[ 7], y[ 0]);
	z[ 7] = w1; w1 = 0;
	
	word3_muladd(&w1, &w0, &w2, x[ 0], y[ 8]);
	word3_muladd(&w1, &w0, &w2, x[ 1], y[ 7]);
	word3_muladd(&w1, &w0, &w2, x[ 2], y[ 6]);
	word3_muladd(&w1, &w0, &w2, x[ 3], y[ 5]);
	word3_muladd(&w1, &w0, &w2, x[ 4], y[ 4]);
	word3_muladd(&w1, &w0, &w2, x[ 5], y[ 3]);
	word3_muladd(&w1, &w0, &w2, x[ 6], y[ 2]);
	word3_muladd(&w1, &w0, &w2, x[ 7], y[ 1]);
	word3_muladd(&w1, &w0, &w2, x[ 8], y[ 0]);
	z[ 8] = w2; w2 = 0;
	
	word3_muladd(&w2, &w1, &w0, x[ 1], y[ 8]);
	word3_muladd(&w2, &w1, &w0, x[ 2], y[ 7]);
	word3_muladd(&w2, &w1, &w0, x[ 3], y[ 6]);
	word3_muladd(&w2, &w1, &w0, x[ 4], y[ 5]);
	word3_muladd(&w2, &w1, &w0, x[ 5], y[ 4]);
	word3_muladd(&w2, &w1, &w0, x[ 6], y[ 3]);
	word3_muladd(&w2, &w1, &w0, x[ 7], y[ 2]);
	word3_muladd(&w2, &w1, &w0, x[ 8], y[ 1]);
	z[ 9] = w0; w0 = 0;
	
	word3_muladd(&w0, &w2, &w1, x[ 2], y[ 8]);
	word3_muladd(&w0, &w2, &w1, x[ 3], y[ 7]);
	word3_muladd(&w0, &w2, &w1, x[ 4], y[ 6]);
	word3_muladd(&w0, &w2, &w1, x[ 5], y[ 5]);
	word3_muladd(&w0, &w2, &w1, x[ 6], y[ 4]);
	word3_muladd(&w0, &w2, &w1, x[ 7], y[ 3]);
	word3_muladd(&w0, &w2, &w1, x[ 8], y[ 2]);
	z[10] = w1; w1 = 0;
	
	word3_muladd(&w1, &w0, &w2, x[ 3], y[ 8]);
	word3_muladd(&w1, &w0, &w2, x[ 4], y[ 7]);
	word3_muladd(&w1, &w0, &w2, x[ 5], y[ 6]);
	word3_muladd(&w1, &w0, &w2, x[ 6], y[ 5]);
	word3_muladd(&w1, &w0, &w2, x[ 7], y[ 4]);
	word3_muladd(&w1, &w0, &w2, x[ 8], y[ 3]);
	z[11] = w2; w2 = 0;
	
	word3_muladd(&w2, &w1, &w0, x[ 4], y[ 8]);
	word3_muladd(&w2, &w1, &w0, x[ 5], y[ 7]);
	word3_muladd(&w2, &w1, &w0, x[ 6], y[ 6]);
	word3_muladd(&w2, &w1, &w0, x[ 7], y[ 5]);
	word3_muladd(&w2, &w1, &w0, x[ 8], y[ 4]);
	z[12] = w0; w0 = 0;
	
	word3_muladd(&w0, &w2, &w1, x[ 5], y[ 8]);
	word3_muladd(&w0, &w2, &w1, x[ 6], y[ 7]);
	word3_muladd(&w0, &w2, &w1, x[ 7], y[ 6]);
	word3_muladd(&w0, &w2, &w1, x[ 8], y[ 5]);
	z[13] = w1; w1 = 0;
	
	word3_muladd(&w1, &w0, &w2, x[ 6], y[ 8]);
	word3_muladd(&w1, &w0, &w2, x[ 7], y[ 7]);
	word3_muladd(&w1, &w0, &w2, x[ 8], y[ 6]);
	z[14] = w2; w2 = 0;
	
	word3_muladd(&w2, &w1, &w0, x[ 7], y[ 8]);
	word3_muladd(&w2, &w1, &w0, x[ 8], y[ 7]);
	z[15] = w0; w0 = 0;
	
	word3_muladd(&w0, &w2, &w1, x[ 8], y[ 8]);
	z[16] = w1;
	z[17] = w2;
}

/*
* Comba 16x16 Squaring
*/
void bigint_comba_sqr16(ref word[32] z, const ref word[16] x)
{
	word w2 = 0, w1 = 0, w0 = 0;
	
	word3_muladd(&w2, &w1, &w0, x[ 0], x[ 0]);
	z[ 0] = w0; w0 = 0;
	
	word3_muladd_2(&w0, &w2, &w1, x[ 0], x[ 1]);
	z[ 1] = w1; w1 = 0;
	
	word3_muladd_2(&w1, &w0, &w2, x[ 0], x[ 2]);
	word3_muladd(&w1, &w0, &w2, x[ 1], x[ 1]);
	z[ 2] = w2; w2 = 0;
	
	word3_muladd_2(&w2, &w1, &w0, x[ 0], x[ 3]);
	word3_muladd_2(&w2, &w1, &w0, x[ 1], x[ 2]);
	z[ 3] = w0; w0 = 0;
	
	word3_muladd_2(&w0, &w2, &w1, x[ 0], x[ 4]);
	word3_muladd_2(&w0, &w2, &w1, x[ 1], x[ 3]);
	word3_muladd(&w0, &w2, &w1, x[ 2], x[ 2]);
	z[ 4] = w1; w1 = 0;
	
	word3_muladd_2(&w1, &w0, &w2, x[ 0], x[ 5]);
	word3_muladd_2(&w1, &w0, &w2, x[ 1], x[ 4]);
	word3_muladd_2(&w1, &w0, &w2, x[ 2], x[ 3]);
	z[ 5] = w2; w2 = 0;
	
	word3_muladd_2(&w2, &w1, &w0, x[ 0], x[ 6]);
	word3_muladd_2(&w2, &w1, &w0, x[ 1], x[ 5]);
	word3_muladd_2(&w2, &w1, &w0, x[ 2], x[ 4]);
	word3_muladd(&w2, &w1, &w0, x[ 3], x[ 3]);
	z[ 6] = w0; w0 = 0;
	
	word3_muladd_2(&w0, &w2, &w1, x[ 0], x[ 7]);
	word3_muladd_2(&w0, &w2, &w1, x[ 1], x[ 6]);
	word3_muladd_2(&w0, &w2, &w1, x[ 2], x[ 5]);
	word3_muladd_2(&w0, &w2, &w1, x[ 3], x[ 4]);
	z[ 7] = w1; w1 = 0;
	
	word3_muladd_2(&w1, &w0, &w2, x[ 0], x[ 8]);
	word3_muladd_2(&w1, &w0, &w2, x[ 1], x[ 7]);
	word3_muladd_2(&w1, &w0, &w2, x[ 2], x[ 6]);
	word3_muladd_2(&w1, &w0, &w2, x[ 3], x[ 5]);
	word3_muladd(&w1, &w0, &w2, x[ 4], x[ 4]);
	z[ 8] = w2; w2 = 0;
	
	word3_muladd_2(&w2, &w1, &w0, x[ 0], x[ 9]);
	word3_muladd_2(&w2, &w1, &w0, x[ 1], x[ 8]);
	word3_muladd_2(&w2, &w1, &w0, x[ 2], x[ 7]);
	word3_muladd_2(&w2, &w1, &w0, x[ 3], x[ 6]);
	word3_muladd_2(&w2, &w1, &w0, x[ 4], x[ 5]);
	z[ 9] = w0; w0 = 0;
	
	word3_muladd_2(&w0, &w2, &w1, x[ 0], x[10]);
	word3_muladd_2(&w0, &w2, &w1, x[ 1], x[ 9]);
	word3_muladd_2(&w0, &w2, &w1, x[ 2], x[ 8]);
	word3_muladd_2(&w0, &w2, &w1, x[ 3], x[ 7]);
	word3_muladd_2(&w0, &w2, &w1, x[ 4], x[ 6]);
	word3_muladd(&w0, &w2, &w1, x[ 5], x[ 5]);
	z[10] = w1; w1 = 0;
	
	word3_muladd_2(&w1, &w0, &w2, x[ 0], x[11]);
	word3_muladd_2(&w1, &w0, &w2, x[ 1], x[10]);
	word3_muladd_2(&w1, &w0, &w2, x[ 2], x[ 9]);
	word3_muladd_2(&w1, &w0, &w2, x[ 3], x[ 8]);
	word3_muladd_2(&w1, &w0, &w2, x[ 4], x[ 7]);
	word3_muladd_2(&w1, &w0, &w2, x[ 5], x[ 6]);
	z[11] = w2; w2 = 0;
	
	word3_muladd_2(&w2, &w1, &w0, x[ 0], x[12]);
	word3_muladd_2(&w2, &w1, &w0, x[ 1], x[11]);
	word3_muladd_2(&w2, &w1, &w0, x[ 2], x[10]);
	word3_muladd_2(&w2, &w1, &w0, x[ 3], x[ 9]);
	word3_muladd_2(&w2, &w1, &w0, x[ 4], x[ 8]);
	word3_muladd_2(&w2, &w1, &w0, x[ 5], x[ 7]);
	word3_muladd(&w2, &w1, &w0, x[ 6], x[ 6]);
	z[12] = w0; w0 = 0;
	
	word3_muladd_2(&w0, &w2, &w1, x[ 0], x[13]);
	word3_muladd_2(&w0, &w2, &w1, x[ 1], x[12]);
	word3_muladd_2(&w0, &w2, &w1, x[ 2], x[11]);
	word3_muladd_2(&w0, &w2, &w1, x[ 3], x[10]);
	word3_muladd_2(&w0, &w2, &w1, x[ 4], x[ 9]);
	word3_muladd_2(&w0, &w2, &w1, x[ 5], x[ 8]);
	word3_muladd_2(&w0, &w2, &w1, x[ 6], x[ 7]);
	z[13] = w1; w1 = 0;
	
	word3_muladd_2(&w1, &w0, &w2, x[ 0], x[14]);
	word3_muladd_2(&w1, &w0, &w2, x[ 1], x[13]);
	word3_muladd_2(&w1, &w0, &w2, x[ 2], x[12]);
	word3_muladd_2(&w1, &w0, &w2, x[ 3], x[11]);
	word3_muladd_2(&w1, &w0, &w2, x[ 4], x[10]);
	word3_muladd_2(&w1, &w0, &w2, x[ 5], x[ 9]);
	word3_muladd_2(&w1, &w0, &w2, x[ 6], x[ 8]);
	word3_muladd(&w1, &w0, &w2, x[ 7], x[ 7]);
	z[14] = w2; w2 = 0;
	
	word3_muladd_2(&w2, &w1, &w0, x[ 0], x[15]);
	word3_muladd_2(&w2, &w1, &w0, x[ 1], x[14]);
	word3_muladd_2(&w2, &w1, &w0, x[ 2], x[13]);
	word3_muladd_2(&w2, &w1, &w0, x[ 3], x[12]);
	word3_muladd_2(&w2, &w1, &w0, x[ 4], x[11]);
	word3_muladd_2(&w2, &w1, &w0, x[ 5], x[10]);
	word3_muladd_2(&w2, &w1, &w0, x[ 6], x[ 9]);
	word3_muladd_2(&w2, &w1, &w0, x[ 7], x[ 8]);
	z[15] = w0; w0 = 0;
	
	word3_muladd_2(&w0, &w2, &w1, x[ 1], x[15]);
	word3_muladd_2(&w0, &w2, &w1, x[ 2], x[14]);
	word3_muladd_2(&w0, &w2, &w1, x[ 3], x[13]);
	word3_muladd_2(&w0, &w2, &w1, x[ 4], x[12]);
	word3_muladd_2(&w0, &w2, &w1, x[ 5], x[11]);
	word3_muladd_2(&w0, &w2, &w1, x[ 6], x[10]);
	word3_muladd_2(&w0, &w2, &w1, x[ 7], x[ 9]);
	word3_muladd(&w0, &w2, &w1, x[ 8], x[ 8]);
	z[16] = w1; w1 = 0;
	
	word3_muladd_2(&w1, &w0, &w2, x[ 2], x[15]);
	word3_muladd_2(&w1, &w0, &w2, x[ 3], x[14]);
	word3_muladd_2(&w1, &w0, &w2, x[ 4], x[13]);
	word3_muladd_2(&w1, &w0, &w2, x[ 5], x[12]);
	word3_muladd_2(&w1, &w0, &w2, x[ 6], x[11]);
	word3_muladd_2(&w1, &w0, &w2, x[ 7], x[10]);
	word3_muladd_2(&w1, &w0, &w2, x[ 8], x[ 9]);
	z[17] = w2; w2 = 0;
	
	word3_muladd_2(&w2, &w1, &w0, x[ 3], x[15]);
	word3_muladd_2(&w2, &w1, &w0, x[ 4], x[14]);
	word3_muladd_2(&w2, &w1, &w0, x[ 5], x[13]);
	word3_muladd_2(&w2, &w1, &w0, x[ 6], x[12]);
	word3_muladd_2(&w2, &w1, &w0, x[ 7], x[11]);
	word3_muladd_2(&w2, &w1, &w0, x[ 8], x[10]);
	word3_muladd(&w2, &w1, &w0, x[ 9], x[ 9]);
	z[18] = w0; w0 = 0;
	
	word3_muladd_2(&w0, &w2, &w1, x[ 4], x[15]);
	word3_muladd_2(&w0, &w2, &w1, x[ 5], x[14]);
	word3_muladd_2(&w0, &w2, &w1, x[ 6], x[13]);
	word3_muladd_2(&w0, &w2, &w1, x[ 7], x[12]);
	word3_muladd_2(&w0, &w2, &w1, x[ 8], x[11]);
	word3_muladd_2(&w0, &w2, &w1, x[ 9], x[10]);
	z[19] = w1; w1 = 0;
	
	word3_muladd_2(&w1, &w0, &w2, x[ 5], x[15]);
	word3_muladd_2(&w1, &w0, &w2, x[ 6], x[14]);
	word3_muladd_2(&w1, &w0, &w2, x[ 7], x[13]);
	word3_muladd_2(&w1, &w0, &w2, x[ 8], x[12]);
	word3_muladd_2(&w1, &w0, &w2, x[ 9], x[11]);
	word3_muladd(&w1, &w0, &w2, x[10], x[10]);
	z[20] = w2; w2 = 0;
	
	word3_muladd_2(&w2, &w1, &w0, x[ 6], x[15]);
	word3_muladd_2(&w2, &w1, &w0, x[ 7], x[14]);
	word3_muladd_2(&w2, &w1, &w0, x[ 8], x[13]);
	word3_muladd_2(&w2, &w1, &w0, x[ 9], x[12]);
	word3_muladd_2(&w2, &w1, &w0, x[10], x[11]);
	z[21] = w0; w0 = 0;
	
	word3_muladd_2(&w0, &w2, &w1, x[ 7], x[15]);
	word3_muladd_2(&w0, &w2, &w1, x[ 8], x[14]);
	word3_muladd_2(&w0, &w2, &w1, x[ 9], x[13]);
	word3_muladd_2(&w0, &w2, &w1, x[10], x[12]);
	word3_muladd(&w0, &w2, &w1, x[11], x[11]);
	z[22] = w1; w1 = 0;
	
	word3_muladd_2(&w1, &w0, &w2, x[ 8], x[15]);
	word3_muladd_2(&w1, &w0, &w2, x[ 9], x[14]);
	word3_muladd_2(&w1, &w0, &w2, x[10], x[13]);
	word3_muladd_2(&w1, &w0, &w2, x[11], x[12]);
	z[23] = w2; w2 = 0;
	
	word3_muladd_2(&w2, &w1, &w0, x[ 9], x[15]);
	word3_muladd_2(&w2, &w1, &w0, x[10], x[14]);
	word3_muladd_2(&w2, &w1, &w0, x[11], x[13]);
	word3_muladd(&w2, &w1, &w0, x[12], x[12]);
	z[24] = w0; w0 = 0;
	
	word3_muladd_2(&w0, &w2, &w1, x[10], x[15]);
	word3_muladd_2(&w0, &w2, &w1, x[11], x[14]);
	word3_muladd_2(&w0, &w2, &w1, x[12], x[13]);
	z[25] = w1; w1 = 0;
	
	word3_muladd_2(&w1, &w0, &w2, x[11], x[15]);
	word3_muladd_2(&w1, &w0, &w2, x[12], x[14]);
	word3_muladd(&w1, &w0, &w2, x[13], x[13]);
	z[26] = w2; w2 = 0;
	
	word3_muladd_2(&w2, &w1, &w0, x[12], x[15]);
	word3_muladd_2(&w2, &w1, &w0, x[13], x[14]);
	z[27] = w0; w0 = 0;
	
	word3_muladd_2(&w0, &w2, &w1, x[13], x[15]);
	word3_muladd(&w0, &w2, &w1, x[14], x[14]);
	z[28] = w1; w1 = 0;
	
	word3_muladd_2(&w1, &w0, &w2, x[14], x[15]);
	z[29] = w2; w2 = 0;
	
	word3_muladd(&w2, &w1, &w0, x[15], x[15]);
	z[30] = w0;
	z[31] = w1;
}

/*
* Comba 16x16 Multiplication
*/
void bigint_comba_mul16(ref word[32] z, const ref word[16] x, const ref word[16] y)
{
	word w2 = 0, w1 = 0, w0 = 0;
	
	word3_muladd(&w2, &w1, &w0, x[ 0], y[ 0]);
	z[ 0] = w0; w0 = 0;
	
	word3_muladd(&w0, &w2, &w1, x[ 0], y[ 1]);
	word3_muladd(&w0, &w2, &w1, x[ 1], y[ 0]);
	z[ 1] = w1; w1 = 0;
	
	word3_muladd(&w1, &w0, &w2, x[ 0], y[ 2]);
	word3_muladd(&w1, &w0, &w2, x[ 1], y[ 1]);
	word3_muladd(&w1, &w0, &w2, x[ 2], y[ 0]);
	z[ 2] = w2; w2 = 0;
	
	word3_muladd(&w2, &w1, &w0, x[ 0], y[ 3]);
	word3_muladd(&w2, &w1, &w0, x[ 1], y[ 2]);
	word3_muladd(&w2, &w1, &w0, x[ 2], y[ 1]);
	word3_muladd(&w2, &w1, &w0, x[ 3], y[ 0]);
	z[ 3] = w0; w0 = 0;
	
	word3_muladd(&w0, &w2, &w1, x[ 0], y[ 4]);
	word3_muladd(&w0, &w2, &w1, x[ 1], y[ 3]);
	word3_muladd(&w0, &w2, &w1, x[ 2], y[ 2]);
	word3_muladd(&w0, &w2, &w1, x[ 3], y[ 1]);
	word3_muladd(&w0, &w2, &w1, x[ 4], y[ 0]);
	z[ 4] = w1; w1 = 0;
	
	word3_muladd(&w1, &w0, &w2, x[ 0], y[ 5]);
	word3_muladd(&w1, &w0, &w2, x[ 1], y[ 4]);
	word3_muladd(&w1, &w0, &w2, x[ 2], y[ 3]);
	word3_muladd(&w1, &w0, &w2, x[ 3], y[ 2]);
	word3_muladd(&w1, &w0, &w2, x[ 4], y[ 1]);
	word3_muladd(&w1, &w0, &w2, x[ 5], y[ 0]);
	z[ 5] = w2; w2 = 0;
	
	word3_muladd(&w2, &w1, &w0, x[ 0], y[ 6]);
	word3_muladd(&w2, &w1, &w0, x[ 1], y[ 5]);
	word3_muladd(&w2, &w1, &w0, x[ 2], y[ 4]);
	word3_muladd(&w2, &w1, &w0, x[ 3], y[ 3]);
	word3_muladd(&w2, &w1, &w0, x[ 4], y[ 2]);
	word3_muladd(&w2, &w1, &w0, x[ 5], y[ 1]);
	word3_muladd(&w2, &w1, &w0, x[ 6], y[ 0]);
	z[ 6] = w0; w0 = 0;
	
	word3_muladd(&w0, &w2, &w1, x[ 0], y[ 7]);
	word3_muladd(&w0, &w2, &w1, x[ 1], y[ 6]);
	word3_muladd(&w0, &w2, &w1, x[ 2], y[ 5]);
	word3_muladd(&w0, &w2, &w1, x[ 3], y[ 4]);
	word3_muladd(&w0, &w2, &w1, x[ 4], y[ 3]);
	word3_muladd(&w0, &w2, &w1, x[ 5], y[ 2]);
	word3_muladd(&w0, &w2, &w1, x[ 6], y[ 1]);
	word3_muladd(&w0, &w2, &w1, x[ 7], y[ 0]);
	z[ 7] = w1; w1 = 0;
	
	word3_muladd(&w1, &w0, &w2, x[ 0], y[ 8]);
	word3_muladd(&w1, &w0, &w2, x[ 1], y[ 7]);
	word3_muladd(&w1, &w0, &w2, x[ 2], y[ 6]);
	word3_muladd(&w1, &w0, &w2, x[ 3], y[ 5]);
	word3_muladd(&w1, &w0, &w2, x[ 4], y[ 4]);
	word3_muladd(&w1, &w0, &w2, x[ 5], y[ 3]);
	word3_muladd(&w1, &w0, &w2, x[ 6], y[ 2]);
	word3_muladd(&w1, &w0, &w2, x[ 7], y[ 1]);
	word3_muladd(&w1, &w0, &w2, x[ 8], y[ 0]);
	z[ 8] = w2; w2 = 0;
	
	word3_muladd(&w2, &w1, &w0, x[ 0], y[ 9]);
	word3_muladd(&w2, &w1, &w0, x[ 1], y[ 8]);
	word3_muladd(&w2, &w1, &w0, x[ 2], y[ 7]);
	word3_muladd(&w2, &w1, &w0, x[ 3], y[ 6]);
	word3_muladd(&w2, &w1, &w0, x[ 4], y[ 5]);
	word3_muladd(&w2, &w1, &w0, x[ 5], y[ 4]);
	word3_muladd(&w2, &w1, &w0, x[ 6], y[ 3]);
	word3_muladd(&w2, &w1, &w0, x[ 7], y[ 2]);
	word3_muladd(&w2, &w1, &w0, x[ 8], y[ 1]);
	word3_muladd(&w2, &w1, &w0, x[ 9], y[ 0]);
	z[ 9] = w0; w0 = 0;
	
	word3_muladd(&w0, &w2, &w1, x[ 0], y[10]);
	word3_muladd(&w0, &w2, &w1, x[ 1], y[ 9]);
	word3_muladd(&w0, &w2, &w1, x[ 2], y[ 8]);
	word3_muladd(&w0, &w2, &w1, x[ 3], y[ 7]);
	word3_muladd(&w0, &w2, &w1, x[ 4], y[ 6]);
	word3_muladd(&w0, &w2, &w1, x[ 5], y[ 5]);
	word3_muladd(&w0, &w2, &w1, x[ 6], y[ 4]);
	word3_muladd(&w0, &w2, &w1, x[ 7], y[ 3]);
	word3_muladd(&w0, &w2, &w1, x[ 8], y[ 2]);
	word3_muladd(&w0, &w2, &w1, x[ 9], y[ 1]);
	word3_muladd(&w0, &w2, &w1, x[10], y[ 0]);
	z[10] = w1; w1 = 0;
	
	word3_muladd(&w1, &w0, &w2, x[ 0], y[11]);
	word3_muladd(&w1, &w0, &w2, x[ 1], y[10]);
	word3_muladd(&w1, &w0, &w2, x[ 2], y[ 9]);
	word3_muladd(&w1, &w0, &w2, x[ 3], y[ 8]);
	word3_muladd(&w1, &w0, &w2, x[ 4], y[ 7]);
	word3_muladd(&w1, &w0, &w2, x[ 5], y[ 6]);
	word3_muladd(&w1, &w0, &w2, x[ 6], y[ 5]);
	word3_muladd(&w1, &w0, &w2, x[ 7], y[ 4]);
	word3_muladd(&w1, &w0, &w2, x[ 8], y[ 3]);
	word3_muladd(&w1, &w0, &w2, x[ 9], y[ 2]);
	word3_muladd(&w1, &w0, &w2, x[10], y[ 1]);
	word3_muladd(&w1, &w0, &w2, x[11], y[ 0]);
	z[11] = w2; w2 = 0;
	
	word3_muladd(&w2, &w1, &w0, x[ 0], y[12]);
	word3_muladd(&w2, &w1, &w0, x[ 1], y[11]);
	word3_muladd(&w2, &w1, &w0, x[ 2], y[10]);
	word3_muladd(&w2, &w1, &w0, x[ 3], y[ 9]);
	word3_muladd(&w2, &w1, &w0, x[ 4], y[ 8]);
	word3_muladd(&w2, &w1, &w0, x[ 5], y[ 7]);
	word3_muladd(&w2, &w1, &w0, x[ 6], y[ 6]);
	word3_muladd(&w2, &w1, &w0, x[ 7], y[ 5]);
	word3_muladd(&w2, &w1, &w0, x[ 8], y[ 4]);
	word3_muladd(&w2, &w1, &w0, x[ 9], y[ 3]);
	word3_muladd(&w2, &w1, &w0, x[10], y[ 2]);
	word3_muladd(&w2, &w1, &w0, x[11], y[ 1]);
	word3_muladd(&w2, &w1, &w0, x[12], y[ 0]);
	z[12] = w0; w0 = 0;
	
	word3_muladd(&w0, &w2, &w1, x[ 0], y[13]);
	word3_muladd(&w0, &w2, &w1, x[ 1], y[12]);
	word3_muladd(&w0, &w2, &w1, x[ 2], y[11]);
	word3_muladd(&w0, &w2, &w1, x[ 3], y[10]);
	word3_muladd(&w0, &w2, &w1, x[ 4], y[ 9]);
	word3_muladd(&w0, &w2, &w1, x[ 5], y[ 8]);
	word3_muladd(&w0, &w2, &w1, x[ 6], y[ 7]);
	word3_muladd(&w0, &w2, &w1, x[ 7], y[ 6]);
	word3_muladd(&w0, &w2, &w1, x[ 8], y[ 5]);
	word3_muladd(&w0, &w2, &w1, x[ 9], y[ 4]);
	word3_muladd(&w0, &w2, &w1, x[10], y[ 3]);
	word3_muladd(&w0, &w2, &w1, x[11], y[ 2]);
	word3_muladd(&w0, &w2, &w1, x[12], y[ 1]);
	word3_muladd(&w0, &w2, &w1, x[13], y[ 0]);
	z[13] = w1; w1 = 0;
	
	word3_muladd(&w1, &w0, &w2, x[ 0], y[14]);
	word3_muladd(&w1, &w0, &w2, x[ 1], y[13]);
	word3_muladd(&w1, &w0, &w2, x[ 2], y[12]);
	word3_muladd(&w1, &w0, &w2, x[ 3], y[11]);
	word3_muladd(&w1, &w0, &w2, x[ 4], y[10]);
	word3_muladd(&w1, &w0, &w2, x[ 5], y[ 9]);
	word3_muladd(&w1, &w0, &w2, x[ 6], y[ 8]);
	word3_muladd(&w1, &w0, &w2, x[ 7], y[ 7]);
	word3_muladd(&w1, &w0, &w2, x[ 8], y[ 6]);
	word3_muladd(&w1, &w0, &w2, x[ 9], y[ 5]);
	word3_muladd(&w1, &w0, &w2, x[10], y[ 4]);
	word3_muladd(&w1, &w0, &w2, x[11], y[ 3]);
	word3_muladd(&w1, &w0, &w2, x[12], y[ 2]);
	word3_muladd(&w1, &w0, &w2, x[13], y[ 1]);
	word3_muladd(&w1, &w0, &w2, x[14], y[ 0]);
	z[14] = w2; w2 = 0;
	
	word3_muladd(&w2, &w1, &w0, x[ 0], y[15]);
	word3_muladd(&w2, &w1, &w0, x[ 1], y[14]);
	word3_muladd(&w2, &w1, &w0, x[ 2], y[13]);
	word3_muladd(&w2, &w1, &w0, x[ 3], y[12]);
	word3_muladd(&w2, &w1, &w0, x[ 4], y[11]);
	word3_muladd(&w2, &w1, &w0, x[ 5], y[10]);
	word3_muladd(&w2, &w1, &w0, x[ 6], y[ 9]);
	word3_muladd(&w2, &w1, &w0, x[ 7], y[ 8]);
	word3_muladd(&w2, &w1, &w0, x[ 8], y[ 7]);
	word3_muladd(&w2, &w1, &w0, x[ 9], y[ 6]);
	word3_muladd(&w2, &w1, &w0, x[10], y[ 5]);
	word3_muladd(&w2, &w1, &w0, x[11], y[ 4]);
	word3_muladd(&w2, &w1, &w0, x[12], y[ 3]);
	word3_muladd(&w2, &w1, &w0, x[13], y[ 2]);
	word3_muladd(&w2, &w1, &w0, x[14], y[ 1]);
	word3_muladd(&w2, &w1, &w0, x[15], y[ 0]);
	z[15] = w0; w0 = 0;
	
	word3_muladd(&w0, &w2, &w1, x[ 1], y[15]);
	word3_muladd(&w0, &w2, &w1, x[ 2], y[14]);
	word3_muladd(&w0, &w2, &w1, x[ 3], y[13]);
	word3_muladd(&w0, &w2, &w1, x[ 4], y[12]);
	word3_muladd(&w0, &w2, &w1, x[ 5], y[11]);
	word3_muladd(&w0, &w2, &w1, x[ 6], y[10]);
	word3_muladd(&w0, &w2, &w1, x[ 7], y[ 9]);
	word3_muladd(&w0, &w2, &w1, x[ 8], y[ 8]);
	word3_muladd(&w0, &w2, &w1, x[ 9], y[ 7]);
	word3_muladd(&w0, &w2, &w1, x[10], y[ 6]);
	word3_muladd(&w0, &w2, &w1, x[11], y[ 5]);
	word3_muladd(&w0, &w2, &w1, x[12], y[ 4]);
	word3_muladd(&w0, &w2, &w1, x[13], y[ 3]);
	word3_muladd(&w0, &w2, &w1, x[14], y[ 2]);
	word3_muladd(&w0, &w2, &w1, x[15], y[ 1]);
	z[16] = w1; w1 = 0;
	
	word3_muladd(&w1, &w0, &w2, x[ 2], y[15]);
	word3_muladd(&w1, &w0, &w2, x[ 3], y[14]);
	word3_muladd(&w1, &w0, &w2, x[ 4], y[13]);
	word3_muladd(&w1, &w0, &w2, x[ 5], y[12]);
	word3_muladd(&w1, &w0, &w2, x[ 6], y[11]);
	word3_muladd(&w1, &w0, &w2, x[ 7], y[10]);
	word3_muladd(&w1, &w0, &w2, x[ 8], y[ 9]);
	word3_muladd(&w1, &w0, &w2, x[ 9], y[ 8]);
	word3_muladd(&w1, &w0, &w2, x[10], y[ 7]);
	word3_muladd(&w1, &w0, &w2, x[11], y[ 6]);
	word3_muladd(&w1, &w0, &w2, x[12], y[ 5]);
	word3_muladd(&w1, &w0, &w2, x[13], y[ 4]);
	word3_muladd(&w1, &w0, &w2, x[14], y[ 3]);
	word3_muladd(&w1, &w0, &w2, x[15], y[ 2]);
	z[17] = w2; w2 = 0;
	
	word3_muladd(&w2, &w1, &w0, x[ 3], y[15]);
	word3_muladd(&w2, &w1, &w0, x[ 4], y[14]);
	word3_muladd(&w2, &w1, &w0, x[ 5], y[13]);
	word3_muladd(&w2, &w1, &w0, x[ 6], y[12]);
	word3_muladd(&w2, &w1, &w0, x[ 7], y[11]);
	word3_muladd(&w2, &w1, &w0, x[ 8], y[10]);
	word3_muladd(&w2, &w1, &w0, x[ 9], y[ 9]);
	word3_muladd(&w2, &w1, &w0, x[10], y[ 8]);
	word3_muladd(&w2, &w1, &w0, x[11], y[ 7]);
	word3_muladd(&w2, &w1, &w0, x[12], y[ 6]);
	word3_muladd(&w2, &w1, &w0, x[13], y[ 5]);
	word3_muladd(&w2, &w1, &w0, x[14], y[ 4]);
	word3_muladd(&w2, &w1, &w0, x[15], y[ 3]);
	z[18] = w0; w0 = 0;
	
	word3_muladd(&w0, &w2, &w1, x[ 4], y[15]);
	word3_muladd(&w0, &w2, &w1, x[ 5], y[14]);
	word3_muladd(&w0, &w2, &w1, x[ 6], y[13]);
	word3_muladd(&w0, &w2, &w1, x[ 7], y[12]);
	word3_muladd(&w0, &w2, &w1, x[ 8], y[11]);
	word3_muladd(&w0, &w2, &w1, x[ 9], y[10]);
	word3_muladd(&w0, &w2, &w1, x[10], y[ 9]);
	word3_muladd(&w0, &w2, &w1, x[11], y[ 8]);
	word3_muladd(&w0, &w2, &w1, x[12], y[ 7]);
	word3_muladd(&w0, &w2, &w1, x[13], y[ 6]);
	word3_muladd(&w0, &w2, &w1, x[14], y[ 5]);
	word3_muladd(&w0, &w2, &w1, x[15], y[ 4]);
	z[19] = w1; w1 = 0;
	
	word3_muladd(&w1, &w0, &w2, x[ 5], y[15]);
	word3_muladd(&w1, &w0, &w2, x[ 6], y[14]);
	word3_muladd(&w1, &w0, &w2, x[ 7], y[13]);
	word3_muladd(&w1, &w0, &w2, x[ 8], y[12]);
	word3_muladd(&w1, &w0, &w2, x[ 9], y[11]);
	word3_muladd(&w1, &w0, &w2, x[10], y[10]);
	word3_muladd(&w1, &w0, &w2, x[11], y[ 9]);
	word3_muladd(&w1, &w0, &w2, x[12], y[ 8]);
	word3_muladd(&w1, &w0, &w2, x[13], y[ 7]);
	word3_muladd(&w1, &w0, &w2, x[14], y[ 6]);
	word3_muladd(&w1, &w0, &w2, x[15], y[ 5]);
	z[20] = w2; w2 = 0;
	
	word3_muladd(&w2, &w1, &w0, x[ 6], y[15]);
	word3_muladd(&w2, &w1, &w0, x[ 7], y[14]);
	word3_muladd(&w2, &w1, &w0, x[ 8], y[13]);
	word3_muladd(&w2, &w1, &w0, x[ 9], y[12]);
	word3_muladd(&w2, &w1, &w0, x[10], y[11]);
	word3_muladd(&w2, &w1, &w0, x[11], y[10]);
	word3_muladd(&w2, &w1, &w0, x[12], y[ 9]);
	word3_muladd(&w2, &w1, &w0, x[13], y[ 8]);
	word3_muladd(&w2, &w1, &w0, x[14], y[ 7]);
	word3_muladd(&w2, &w1, &w0, x[15], y[ 6]);
	z[21] = w0; w0 = 0;
	
	word3_muladd(&w0, &w2, &w1, x[ 7], y[15]);
	word3_muladd(&w0, &w2, &w1, x[ 8], y[14]);
	word3_muladd(&w0, &w2, &w1, x[ 9], y[13]);
	word3_muladd(&w0, &w2, &w1, x[10], y[12]);
	word3_muladd(&w0, &w2, &w1, x[11], y[11]);
	word3_muladd(&w0, &w2, &w1, x[12], y[10]);
	word3_muladd(&w0, &w2, &w1, x[13], y[ 9]);
	word3_muladd(&w0, &w2, &w1, x[14], y[ 8]);
	word3_muladd(&w0, &w2, &w1, x[15], y[ 7]);
	z[22] = w1; w1 = 0;
	
	word3_muladd(&w1, &w0, &w2, x[ 8], y[15]);
	word3_muladd(&w1, &w0, &w2, x[ 9], y[14]);
	word3_muladd(&w1, &w0, &w2, x[10], y[13]);
	word3_muladd(&w1, &w0, &w2, x[11], y[12]);
	word3_muladd(&w1, &w0, &w2, x[12], y[11]);
	word3_muladd(&w1, &w0, &w2, x[13], y[10]);
	word3_muladd(&w1, &w0, &w2, x[14], y[ 9]);
	word3_muladd(&w1, &w0, &w2, x[15], y[ 8]);
	z[23] = w2; w2 = 0;
	
	word3_muladd(&w2, &w1, &w0, x[ 9], y[15]);
	word3_muladd(&w2, &w1, &w0, x[10], y[14]);
	word3_muladd(&w2, &w1, &w0, x[11], y[13]);
	word3_muladd(&w2, &w1, &w0, x[12], y[12]);
	word3_muladd(&w2, &w1, &w0, x[13], y[11]);
	word3_muladd(&w2, &w1, &w0, x[14], y[10]);
	word3_muladd(&w2, &w1, &w0, x[15], y[ 9]);
	z[24] = w0; w0 = 0;
	
	word3_muladd(&w0, &w2, &w1, x[10], y[15]);
	word3_muladd(&w0, &w2, &w1, x[11], y[14]);
	word3_muladd(&w0, &w2, &w1, x[12], y[13]);
	word3_muladd(&w0, &w2, &w1, x[13], y[12]);
	word3_muladd(&w0, &w2, &w1, x[14], y[11]);
	word3_muladd(&w0, &w2, &w1, x[15], y[10]);
	z[25] = w1; w1 = 0;
	
	word3_muladd(&w1, &w0, &w2, x[11], y[15]);
	word3_muladd(&w1, &w0, &w2, x[12], y[14]);
	word3_muladd(&w1, &w0, &w2, x[13], y[13]);
	word3_muladd(&w1, &w0, &w2, x[14], y[12]);
	word3_muladd(&w1, &w0, &w2, x[15], y[11]);
	z[26] = w2; w2 = 0;
	
	word3_muladd(&w2, &w1, &w0, x[12], y[15]);
	word3_muladd(&w2, &w1, &w0, x[13], y[14]);
	word3_muladd(&w2, &w1, &w0, x[14], y[13]);
	word3_muladd(&w2, &w1, &w0, x[15], y[12]);
	z[27] = w0; w0 = 0;
	
	word3_muladd(&w0, &w2, &w1, x[13], y[15]);
	word3_muladd(&w0, &w2, &w1, x[14], y[14]);
	word3_muladd(&w0, &w2, &w1, x[15], y[13]);
	z[28] = w1; w1 = 0;
	
	word3_muladd(&w1, &w0, &w2, x[14], y[15]);
	word3_muladd(&w1, &w0, &w2, x[15], y[14]);
	z[29] = w2; w2 = 0;
	
	word3_muladd(&w2, &w1, &w0, x[15], y[15]);
	z[30] = w0;
	z[31] = w1;
}
