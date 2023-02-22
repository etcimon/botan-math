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
pure nothrow:
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
	version(D_InlineAsm_X86_64) {		
		import botan_math.x86_64.mp_comba_mul;
		mixin(mp_bigint_comba_mul!4);
	} 
	else
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
	version(D_InlineAsm_X86_64) {

		import botan_math.x86_64.mp_comba_mul;
		mixin(mp_bigint_comba_mul!6);
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
	version(D_InlineAsm_X86_64) {		
		import botan_math.x86_64.mp_comba_mul;
		mixin(mp_bigint_comba_mul!8);
	} else
	{
		word w2 = 0, w1 = 0, w0 = 0;
		size_t carry;
		
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
		
		
		word3_mulladd_210(0, 0); //1
		
		z[ 0] = w0; w0 = 0;
		
		word3_mulladd_021(0, 1); //2
		word3_mulladd_021(1, 0); //3
		z[ 1] = w1; w1 = 0;
		
		word3_mulladd_102(0, 2); //4
		word3_mulladd_102(1, 1); //5
		word3_mulladd_102(2, 0); //6
		z[ 2] = w2; w2 = 0;
		
		word3_mulladd_210(0, 3); //7
		word3_mulladd_210(1, 2); //8
		word3_mulladd_210(2, 1); //9
		word3_mulladd_210(3, 0); //10
		z[ 3] = w0; w0 = 0;
		
		word3_mulladd_021(0, 4); //11
		word3_mulladd_021(1, 3); //12
		word3_mulladd_021(2, 2); //13
		word3_mulladd_021(3, 1); //14
		word3_mulladd_021(4, 0); //15
		z[ 4] = w1; w1 = 0;
		
		word3_mulladd_102(0, 5); //16
		word3_mulladd_102(1, 4); //17
		word3_mulladd_102(2, 3); //18
		word3_mulladd_102(3, 2); //19
		word3_mulladd_102(4, 1); //20
		word3_mulladd_102(5, 0); //21
		z[ 5] = w2; w2 = 0;
		
		word3_mulladd_210(0, 6); //22
		word3_mulladd_210(1, 5); //23
		word3_mulladd_210(2, 4); //24
		word3_mulladd_210(3, 3); //25
		word3_mulladd_210(4, 2); //26
		word3_mulladd_210(5, 1); //27
		word3_mulladd_210(6, 0); //28
		z[ 6] = w0; w0 = 0;
		
		word3_mulladd_021(0, 7); //29
		word3_mulladd_021(1, 6); //30
		word3_mulladd_021(2, 5); //31
		word3_mulladd_021(3, 4); //32
		word3_mulladd_021(4, 3); //33
		word3_mulladd_021(5, 2); //34
		word3_mulladd_021(6, 1); //35
		word3_mulladd_021(7, 0); //36
		z[ 7] = w1; w1 = 0;
		
		word3_mulladd_102(1, 7); //37
		word3_mulladd_102(2, 6); //38
		word3_mulladd_102(3, 5); //39
		word3_mulladd_102(4, 4); //40
		word3_mulladd_102(5, 3); //41
		word3_mulladd_102(6, 2); //42
		word3_mulladd_102(7, 1); //43
		z[ 8] = w2; w2 = 0;
		
		word3_mulladd_210(2, 7); //44
		word3_mulladd_210(3, 6); //45
		word3_mulladd_210(4, 5); //46
		word3_mulladd_210(5, 4); //47
		word3_mulladd_210(6, 3); //48
		word3_mulladd_210(7, 2); //49
		z[ 9] = w0; w0 = 0;
		
		word3_mulladd_021(3, 7); //50
		word3_mulladd_021(4, 6); //51
		word3_mulladd_021(5, 5); //52
		word3_mulladd_021(6, 4); //53
		word3_mulladd_021(7, 3); //54
		z[10] = w1; w1 = 0;
		
		word3_mulladd_102(4, 7); //55
		word3_mulladd_102(5, 6); //56
		word3_mulladd_102(6, 5); //57
		word3_mulladd_102(7, 4); //58
		z[11] = w2; w2 = 0;
		
		word3_mulladd_210(5, 7); //59
		word3_mulladd_210(6, 6); //60
		word3_mulladd_210(7, 5); //61
		z[12] = w0; w0 = 0;
		
		word3_mulladd_021(6, 7); //62
		word3_mulladd_021(7, 6); //63
		z[13] = w1; w1 = 0;
		
		word3_mulladd_102(7, 7); //64
		z[14] = w2;
		z[15] = w0;
	}
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
	version(D_InlineAsm_X86_64) {		
		import botan_math.x86_64.mp_comba_mul;
		mixin(mp_bigint_comba_mul!9);
	} else {
		word w2 = 0, w1 = 0, w0 = 0;
		
		word3_muladd(&w2, &w1, &w0, x[ 0], y[ 0]); //1
		z[ 0] = w0; w0 = 0;
		
		word3_muladd(&w0, &w2, &w1, x[ 0], y[ 1]); //2
		word3_muladd(&w0, &w2, &w1, x[ 1], y[ 0]); //3
		z[ 1] = w1; w1 = 0;
		
		word3_muladd(&w1, &w0, &w2, x[ 0], y[ 2]); //4
		word3_muladd(&w1, &w0, &w2, x[ 1], y[ 1]); //5
		word3_muladd(&w1, &w0, &w2, x[ 2], y[ 0]); //6
		z[ 2] = w2; w2 = 0;
		
		word3_muladd(&w2, &w1, &w0, x[ 0], y[ 3]); //7
		word3_muladd(&w2, &w1, &w0, x[ 1], y[ 2]); //8
		word3_muladd(&w2, &w1, &w0, x[ 2], y[ 1]); //9
		word3_muladd(&w2, &w1, &w0, x[ 3], y[ 0]); //10
		z[ 3] = w0; w0 = 0;
		
		word3_muladd(&w0, &w2, &w1, x[ 0], y[ 4]); //11
		word3_muladd(&w0, &w2, &w1, x[ 1], y[ 3]); //12
		word3_muladd(&w0, &w2, &w1, x[ 2], y[ 2]); //13
		word3_muladd(&w0, &w2, &w1, x[ 3], y[ 1]); //14
		word3_muladd(&w0, &w2, &w1, x[ 4], y[ 0]); //15
		z[ 4] = w1; w1 = 0;
		
		word3_muladd(&w1, &w0, &w2, x[ 0], y[ 5]); //16
		word3_muladd(&w1, &w0, &w2, x[ 1], y[ 4]); //17
		word3_muladd(&w1, &w0, &w2, x[ 2], y[ 3]); //18
		word3_muladd(&w1, &w0, &w2, x[ 3], y[ 2]); //19
		word3_muladd(&w1, &w0, &w2, x[ 4], y[ 1]); //20
		word3_muladd(&w1, &w0, &w2, x[ 5], y[ 0]); //21
		z[ 5] = w2; w2 = 0;
		
		word3_muladd(&w2, &w1, &w0, x[ 0], y[ 6]); //22
		word3_muladd(&w2, &w1, &w0, x[ 1], y[ 5]); //23
		word3_muladd(&w2, &w1, &w0, x[ 2], y[ 4]); //24
		word3_muladd(&w2, &w1, &w0, x[ 3], y[ 3]); //25
		word3_muladd(&w2, &w1, &w0, x[ 4], y[ 2]); //26
		word3_muladd(&w2, &w1, &w0, x[ 5], y[ 1]); //27
		word3_muladd(&w2, &w1, &w0, x[ 6], y[ 0]); //28
		z[ 6] = w0; w0 = 0;
		
		word3_muladd(&w0, &w2, &w1, x[ 0], y[ 7]); //29
		word3_muladd(&w0, &w2, &w1, x[ 1], y[ 6]); //30
		word3_muladd(&w0, &w2, &w1, x[ 2], y[ 5]); //31
		word3_muladd(&w0, &w2, &w1, x[ 3], y[ 4]); //32
		word3_muladd(&w0, &w2, &w1, x[ 4], y[ 3]); //33
		word3_muladd(&w0, &w2, &w1, x[ 5], y[ 2]); //34
		word3_muladd(&w0, &w2, &w1, x[ 6], y[ 1]); //35
		word3_muladd(&w0, &w2, &w1, x[ 7], y[ 0]); //36
		z[ 7] = w1; w1 = 0;
		
		word3_muladd(&w1, &w0, &w2, x[ 0], y[ 8]); //37
		word3_muladd(&w1, &w0, &w2, x[ 1], y[ 7]); //38
		word3_muladd(&w1, &w0, &w2, x[ 2], y[ 6]); //39
		word3_muladd(&w1, &w0, &w2, x[ 3], y[ 5]); //40
		word3_muladd(&w1, &w0, &w2, x[ 4], y[ 4]); //41
		word3_muladd(&w1, &w0, &w2, x[ 5], y[ 3]); //42
		word3_muladd(&w1, &w0, &w2, x[ 6], y[ 2]); //43
		word3_muladd(&w1, &w0, &w2, x[ 7], y[ 1]); //44
		word3_muladd(&w1, &w0, &w2, x[ 8], y[ 0]); //45
		z[ 8] = w2; w2 = 0;
		
		word3_muladd(&w2, &w1, &w0, x[ 1], y[ 8]); //46
		word3_muladd(&w2, &w1, &w0, x[ 2], y[ 7]); //47
		word3_muladd(&w2, &w1, &w0, x[ 3], y[ 6]); //48
		word3_muladd(&w2, &w1, &w0, x[ 4], y[ 5]); //49
		word3_muladd(&w2, &w1, &w0, x[ 5], y[ 4]); //50
		word3_muladd(&w2, &w1, &w0, x[ 6], y[ 3]); //51
		word3_muladd(&w2, &w1, &w0, x[ 7], y[ 2]); //52
		word3_muladd(&w2, &w1, &w0, x[ 8], y[ 1]); //53
		z[ 9] = w0; w0 = 0;
		
		word3_muladd(&w0, &w2, &w1, x[ 2], y[ 8]); //54
		word3_muladd(&w0, &w2, &w1, x[ 3], y[ 7]); //55
		word3_muladd(&w0, &w2, &w1, x[ 4], y[ 6]); //56
		word3_muladd(&w0, &w2, &w1, x[ 5], y[ 5]); //57
		word3_muladd(&w0, &w2, &w1, x[ 6], y[ 4]); //58
		word3_muladd(&w0, &w2, &w1, x[ 7], y[ 3]); //59
		word3_muladd(&w0, &w2, &w1, x[ 8], y[ 2]); //60
		z[10] = w1; w1 = 0;
		
		word3_muladd(&w1, &w0, &w2, x[ 3], y[ 8]); //61
		word3_muladd(&w1, &w0, &w2, x[ 4], y[ 7]); //62
		word3_muladd(&w1, &w0, &w2, x[ 5], y[ 6]); //63
		word3_muladd(&w1, &w0, &w2, x[ 6], y[ 5]); //64
		word3_muladd(&w1, &w0, &w2, x[ 7], y[ 4]); //65
		word3_muladd(&w1, &w0, &w2, x[ 8], y[ 3]); //66
		z[11] = w2; w2 = 0;
		
		word3_muladd(&w2, &w1, &w0, x[ 4], y[ 8]); //67
		word3_muladd(&w2, &w1, &w0, x[ 5], y[ 7]); //68
		word3_muladd(&w2, &w1, &w0, x[ 6], y[ 6]); //69
		word3_muladd(&w2, &w1, &w0, x[ 7], y[ 5]); //70
		word3_muladd(&w2, &w1, &w0, x[ 8], y[ 4]); //71
		z[12] = w0; w0 = 0;
		
		word3_muladd(&w0, &w2, &w1, x[ 5], y[ 8]); //72
		word3_muladd(&w0, &w2, &w1, x[ 6], y[ 7]); //73
		word3_muladd(&w0, &w2, &w1, x[ 7], y[ 6]); //74
		word3_muladd(&w0, &w2, &w1, x[ 8], y[ 5]); //75
		z[13] = w1; w1 = 0;
		
		word3_muladd(&w1, &w0, &w2, x[ 6], y[ 8]); //76
		word3_muladd(&w1, &w0, &w2, x[ 7], y[ 7]); //77
		word3_muladd(&w1, &w0, &w2, x[ 8], y[ 6]); //78
		z[14] = w2; w2 = 0;
		
		word3_muladd(&w2, &w1, &w0, x[ 7], y[ 8]); //79
		word3_muladd(&w2, &w1, &w0, x[ 8], y[ 7]); //80
		z[15] = w0; w0 = 0;
		
		word3_muladd(&w0, &w2, &w1, x[ 8], y[ 8]);
		z[16] = w1;
		z[17] = w2;
	}
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
	version(D_InlineAsm_X86_64) {		
		import botan_math.x86_64.mp_comba_mul;
		mixin(mp_bigint_comba_mul!16);
	}
	else {
		word w2 = 0, w1 = 0, w0 = 0;
		
		word3_muladd(&w2, &w1, &w0, x[ 0], y[ 0]); //1
		z[ 0] = w0; w0 = 0;
		
		word3_muladd(&w0, &w2, &w1, x[ 0], y[ 1]); //2
		word3_muladd(&w0, &w2, &w1, x[ 1], y[ 0]); //3
		z[ 1] = w1; w1 = 0;
		
		word3_muladd(&w1, &w0, &w2, x[ 0], y[ 2]); //4
		word3_muladd(&w1, &w0, &w2, x[ 1], y[ 1]); //5
		word3_muladd(&w1, &w0, &w2, x[ 2], y[ 0]); //6
		z[ 2] = w2; w2 = 0;
		
		word3_muladd(&w2, &w1, &w0, x[ 0], y[ 3]); //7
		word3_muladd(&w2, &w1, &w0, x[ 1], y[ 2]); //8
		word3_muladd(&w2, &w1, &w0, x[ 2], y[ 1]); //9
		word3_muladd(&w2, &w1, &w0, x[ 3], y[ 0]); //10
		z[ 3] = w0; w0 = 0;
		
		word3_muladd(&w0, &w2, &w1, x[ 0], y[ 4]); //11
		word3_muladd(&w0, &w2, &w1, x[ 1], y[ 3]); //12
		word3_muladd(&w0, &w2, &w1, x[ 2], y[ 2]); //13
		word3_muladd(&w0, &w2, &w1, x[ 3], y[ 1]); //14
		word3_muladd(&w0, &w2, &w1, x[ 4], y[ 0]); //15
		z[ 4] = w1; w1 = 0;
		
		word3_muladd(&w1, &w0, &w2, x[ 0], y[ 5]); //16
		word3_muladd(&w1, &w0, &w2, x[ 1], y[ 4]); //17
		word3_muladd(&w1, &w0, &w2, x[ 2], y[ 3]); //18
		word3_muladd(&w1, &w0, &w2, x[ 3], y[ 2]); //19
		word3_muladd(&w1, &w0, &w2, x[ 4], y[ 1]); //20
		word3_muladd(&w1, &w0, &w2, x[ 5], y[ 0]); //21
		z[ 5] = w2; w2 = 0;
		
		word3_muladd(&w2, &w1, &w0, x[ 0], y[ 6]); //22
		word3_muladd(&w2, &w1, &w0, x[ 1], y[ 5]); //23
		word3_muladd(&w2, &w1, &w0, x[ 2], y[ 4]); //24
		word3_muladd(&w2, &w1, &w0, x[ 3], y[ 3]); //25
		word3_muladd(&w2, &w1, &w0, x[ 4], y[ 2]); //26
		word3_muladd(&w2, &w1, &w0, x[ 5], y[ 1]); //27
		word3_muladd(&w2, &w1, &w0, x[ 6], y[ 0]); //28
		z[ 6] = w0; w0 = 0;
		
		word3_muladd(&w0, &w2, &w1, x[ 0], y[ 7]); //29
		word3_muladd(&w0, &w2, &w1, x[ 1], y[ 6]); //30
		word3_muladd(&w0, &w2, &w1, x[ 2], y[ 5]); //31
		word3_muladd(&w0, &w2, &w1, x[ 3], y[ 4]); //32
		word3_muladd(&w0, &w2, &w1, x[ 4], y[ 3]); //33
		word3_muladd(&w0, &w2, &w1, x[ 5], y[ 2]); //34
		word3_muladd(&w0, &w2, &w1, x[ 6], y[ 1]); //35
		word3_muladd(&w0, &w2, &w1, x[ 7], y[ 0]); //36
		z[ 7] = w1; w1 = 0;
		
		word3_muladd(&w1, &w0, &w2, x[ 0], y[ 8]); //37
		word3_muladd(&w1, &w0, &w2, x[ 1], y[ 7]); //38
		word3_muladd(&w1, &w0, &w2, x[ 2], y[ 6]); //39
		word3_muladd(&w1, &w0, &w2, x[ 3], y[ 5]); //40
		word3_muladd(&w1, &w0, &w2, x[ 4], y[ 4]); //41
		word3_muladd(&w1, &w0, &w2, x[ 5], y[ 3]); //42
		word3_muladd(&w1, &w0, &w2, x[ 6], y[ 2]); //43
		word3_muladd(&w1, &w0, &w2, x[ 7], y[ 1]); //44
		word3_muladd(&w1, &w0, &w2, x[ 8], y[ 0]); //45
		z[ 8] = w2; w2 = 0;
		
		word3_muladd(&w2, &w1, &w0, x[ 0], y[ 9]); //46
		word3_muladd(&w2, &w1, &w0, x[ 1], y[ 8]); //47
		word3_muladd(&w2, &w1, &w0, x[ 2], y[ 7]); //48
		word3_muladd(&w2, &w1, &w0, x[ 3], y[ 6]); //49
		word3_muladd(&w2, &w1, &w0, x[ 4], y[ 5]); //50
		word3_muladd(&w2, &w1, &w0, x[ 5], y[ 4]); //51
		word3_muladd(&w2, &w1, &w0, x[ 6], y[ 3]); //52
		word3_muladd(&w2, &w1, &w0, x[ 7], y[ 2]); //53
		word3_muladd(&w2, &w1, &w0, x[ 8], y[ 1]); //54
		word3_muladd(&w2, &w1, &w0, x[ 9], y[ 0]); //55
		z[ 9] = w0; w0 = 0;
		
		word3_muladd(&w0, &w2, &w1, x[ 0], y[10]); //56
		word3_muladd(&w0, &w2, &w1, x[ 1], y[ 9]); //57
		word3_muladd(&w0, &w2, &w1, x[ 2], y[ 8]); //58
		word3_muladd(&w0, &w2, &w1, x[ 3], y[ 7]); //59
		word3_muladd(&w0, &w2, &w1, x[ 4], y[ 6]); //60
		word3_muladd(&w0, &w2, &w1, x[ 5], y[ 5]); //61
		word3_muladd(&w0, &w2, &w1, x[ 6], y[ 4]); //62
		word3_muladd(&w0, &w2, &w1, x[ 7], y[ 3]); //63
		word3_muladd(&w0, &w2, &w1, x[ 8], y[ 2]); //64
		word3_muladd(&w0, &w2, &w1, x[ 9], y[ 1]); //65
		word3_muladd(&w0, &w2, &w1, x[10], y[ 0]); //66
		z[10] = w1; w1 = 0;
		
		word3_muladd(&w1, &w0, &w2, x[ 0], y[11]); //67
		word3_muladd(&w1, &w0, &w2, x[ 1], y[10]); //68
		word3_muladd(&w1, &w0, &w2, x[ 2], y[ 9]); //69
		word3_muladd(&w1, &w0, &w2, x[ 3], y[ 8]); //70
		word3_muladd(&w1, &w0, &w2, x[ 4], y[ 7]); //71
		word3_muladd(&w1, &w0, &w2, x[ 5], y[ 6]); //72
		word3_muladd(&w1, &w0, &w2, x[ 6], y[ 5]); //73
		word3_muladd(&w1, &w0, &w2, x[ 7], y[ 4]); //74
		word3_muladd(&w1, &w0, &w2, x[ 8], y[ 3]); //75
		word3_muladd(&w1, &w0, &w2, x[ 9], y[ 2]); //76
		word3_muladd(&w1, &w0, &w2, x[10], y[ 1]); //77
		word3_muladd(&w1, &w0, &w2, x[11], y[ 0]); //78
		z[11] = w2; w2 = 0;
		
		word3_muladd(&w2, &w1, &w0, x[ 0], y[12]); //79
		word3_muladd(&w2, &w1, &w0, x[ 1], y[11]); //80
		word3_muladd(&w2, &w1, &w0, x[ 2], y[10]); //81
		word3_muladd(&w2, &w1, &w0, x[ 3], y[ 9]); //82
		word3_muladd(&w2, &w1, &w0, x[ 4], y[ 8]); //83
		word3_muladd(&w2, &w1, &w0, x[ 5], y[ 7]); //84
		word3_muladd(&w2, &w1, &w0, x[ 6], y[ 6]); //85
		word3_muladd(&w2, &w1, &w0, x[ 7], y[ 5]); //86
		word3_muladd(&w2, &w1, &w0, x[ 8], y[ 4]); //87
		word3_muladd(&w2, &w1, &w0, x[ 9], y[ 3]); //88
		word3_muladd(&w2, &w1, &w0, x[10], y[ 2]); //89
		word3_muladd(&w2, &w1, &w0, x[11], y[ 1]); //90
		word3_muladd(&w2, &w1, &w0, x[12], y[ 0]); //91
		z[12] = w0; w0 = 0;
		
		word3_muladd(&w0, &w2, &w1, x[ 0], y[13]); //92
		word3_muladd(&w0, &w2, &w1, x[ 1], y[12]); //93
		word3_muladd(&w0, &w2, &w1, x[ 2], y[11]); //94
		word3_muladd(&w0, &w2, &w1, x[ 3], y[10]); //95
		word3_muladd(&w0, &w2, &w1, x[ 4], y[ 9]); //96
		word3_muladd(&w0, &w2, &w1, x[ 5], y[ 8]); //97
		word3_muladd(&w0, &w2, &w1, x[ 6], y[ 7]); //98
		word3_muladd(&w0, &w2, &w1, x[ 7], y[ 6]); //99
		word3_muladd(&w0, &w2, &w1, x[ 8], y[ 5]); //100
		word3_muladd(&w0, &w2, &w1, x[ 9], y[ 4]); //101
		word3_muladd(&w0, &w2, &w1, x[10], y[ 3]); //102
		word3_muladd(&w0, &w2, &w1, x[11], y[ 2]); //103
		word3_muladd(&w0, &w2, &w1, x[12], y[ 1]); //104
		word3_muladd(&w0, &w2, &w1, x[13], y[ 0]); //105
		z[13] = w1; w1 = 0;
		
		word3_muladd(&w1, &w0, &w2, x[ 0], y[14]); //106
		word3_muladd(&w1, &w0, &w2, x[ 1], y[13]); //107
		word3_muladd(&w1, &w0, &w2, x[ 2], y[12]); //108
		word3_muladd(&w1, &w0, &w2, x[ 3], y[11]); //109
		word3_muladd(&w1, &w0, &w2, x[ 4], y[10]); //110
		word3_muladd(&w1, &w0, &w2, x[ 5], y[ 9]); //111
		word3_muladd(&w1, &w0, &w2, x[ 6], y[ 8]); //112
		word3_muladd(&w1, &w0, &w2, x[ 7], y[ 7]); //113
		word3_muladd(&w1, &w0, &w2, x[ 8], y[ 6]); //114
		word3_muladd(&w1, &w0, &w2, x[ 9], y[ 5]); //115
		word3_muladd(&w1, &w0, &w2, x[10], y[ 4]); //116
		word3_muladd(&w1, &w0, &w2, x[11], y[ 3]); //117
		word3_muladd(&w1, &w0, &w2, x[12], y[ 2]); //118
		word3_muladd(&w1, &w0, &w2, x[13], y[ 1]); //119
		word3_muladd(&w1, &w0, &w2, x[14], y[ 0]); //120
		z[14] = w2; w2 = 0;
		
		word3_muladd(&w2, &w1, &w0, x[ 0], y[15]); //121
		word3_muladd(&w2, &w1, &w0, x[ 1], y[14]); //122
		word3_muladd(&w2, &w1, &w0, x[ 2], y[13]); //123
		word3_muladd(&w2, &w1, &w0, x[ 3], y[12]); //124
		word3_muladd(&w2, &w1, &w0, x[ 4], y[11]); //125
		word3_muladd(&w2, &w1, &w0, x[ 5], y[10]); //126
		word3_muladd(&w2, &w1, &w0, x[ 6], y[ 9]); //127
		word3_muladd(&w2, &w1, &w0, x[ 7], y[ 8]); //128
		word3_muladd(&w2, &w1, &w0, x[ 8], y[ 7]); //129
		word3_muladd(&w2, &w1, &w0, x[ 9], y[ 6]); //130
		word3_muladd(&w2, &w1, &w0, x[10], y[ 5]); //131 
		word3_muladd(&w2, &w1, &w0, x[11], y[ 4]); //132
		word3_muladd(&w2, &w1, &w0, x[12], y[ 3]); //133
		word3_muladd(&w2, &w1, &w0, x[13], y[ 2]); //134
		word3_muladd(&w2, &w1, &w0, x[14], y[ 1]); //135
		word3_muladd(&w2, &w1, &w0, x[15], y[ 0]); //136
		z[15] = w0; w0 = 0;
		
		word3_muladd(&w0, &w2, &w1, x[ 1], y[15]); //137
		word3_muladd(&w0, &w2, &w1, x[ 2], y[14]); //138
		word3_muladd(&w0, &w2, &w1, x[ 3], y[13]); //139
		word3_muladd(&w0, &w2, &w1, x[ 4], y[12]); //140
		word3_muladd(&w0, &w2, &w1, x[ 5], y[11]); //141
		word3_muladd(&w0, &w2, &w1, x[ 6], y[10]); //142
		word3_muladd(&w0, &w2, &w1, x[ 7], y[ 9]); //143
		word3_muladd(&w0, &w2, &w1, x[ 8], y[ 8]); //144
		word3_muladd(&w0, &w2, &w1, x[ 9], y[ 7]); //145
		word3_muladd(&w0, &w2, &w1, x[10], y[ 6]); //146
		word3_muladd(&w0, &w2, &w1, x[11], y[ 5]); //147
		word3_muladd(&w0, &w2, &w1, x[12], y[ 4]); //148
		word3_muladd(&w0, &w2, &w1, x[13], y[ 3]); //149
		word3_muladd(&w0, &w2, &w1, x[14], y[ 2]); //150
		word3_muladd(&w0, &w2, &w1, x[15], y[ 1]); //151
		z[16] = w1; w1 = 0;
		
		word3_muladd(&w1, &w0, &w2, x[ 2], y[15]); //152
		word3_muladd(&w1, &w0, &w2, x[ 3], y[14]); //153
		word3_muladd(&w1, &w0, &w2, x[ 4], y[13]); //154
		word3_muladd(&w1, &w0, &w2, x[ 5], y[12]); //155
		word3_muladd(&w1, &w0, &w2, x[ 6], y[11]); //156
		word3_muladd(&w1, &w0, &w2, x[ 7], y[10]); //157
		word3_muladd(&w1, &w0, &w2, x[ 8], y[ 9]); //158
		word3_muladd(&w1, &w0, &w2, x[ 9], y[ 8]); //159
		word3_muladd(&w1, &w0, &w2, x[10], y[ 7]); //160
		word3_muladd(&w1, &w0, &w2, x[11], y[ 6]); //161
		word3_muladd(&w1, &w0, &w2, x[12], y[ 5]); //162
		word3_muladd(&w1, &w0, &w2, x[13], y[ 4]); //163
		word3_muladd(&w1, &w0, &w2, x[14], y[ 3]); //164
		word3_muladd(&w1, &w0, &w2, x[15], y[ 2]); //165
		z[17] = w2; w2 = 0;
		
		word3_muladd(&w2, &w1, &w0, x[ 3], y[15]); //166
		word3_muladd(&w2, &w1, &w0, x[ 4], y[14]); //167
		word3_muladd(&w2, &w1, &w0, x[ 5], y[13]); //168
		word3_muladd(&w2, &w1, &w0, x[ 6], y[12]); //169
		word3_muladd(&w2, &w1, &w0, x[ 7], y[11]); //170
		word3_muladd(&w2, &w1, &w0, x[ 8], y[10]); //171
		word3_muladd(&w2, &w1, &w0, x[ 9], y[ 9]); //172
		word3_muladd(&w2, &w1, &w0, x[10], y[ 8]); //173
		word3_muladd(&w2, &w1, &w0, x[11], y[ 7]); //174
		word3_muladd(&w2, &w1, &w0, x[12], y[ 6]); //175
		word3_muladd(&w2, &w1, &w0, x[13], y[ 5]); //176
		word3_muladd(&w2, &w1, &w0, x[14], y[ 4]); //177
		word3_muladd(&w2, &w1, &w0, x[15], y[ 3]); //178
		z[18] = w0; w0 = 0;
		
		word3_muladd(&w0, &w2, &w1, x[ 4], y[15]); //179
		word3_muladd(&w0, &w2, &w1, x[ 5], y[14]); //180
		word3_muladd(&w0, &w2, &w1, x[ 6], y[13]); //181
		word3_muladd(&w0, &w2, &w1, x[ 7], y[12]); //182
		word3_muladd(&w0, &w2, &w1, x[ 8], y[11]); //183
		word3_muladd(&w0, &w2, &w1, x[ 9], y[10]); //184
		word3_muladd(&w0, &w2, &w1, x[10], y[ 9]); //185
		word3_muladd(&w0, &w2, &w1, x[11], y[ 8]); //186
		word3_muladd(&w0, &w2, &w1, x[12], y[ 7]); //187
		word3_muladd(&w0, &w2, &w1, x[13], y[ 6]); //188
		word3_muladd(&w0, &w2, &w1, x[14], y[ 5]); //189
		word3_muladd(&w0, &w2, &w1, x[15], y[ 4]); //190
		z[19] = w1; w1 = 0;
		
		word3_muladd(&w1, &w0, &w2, x[ 5], y[15]); //191
		word3_muladd(&w1, &w0, &w2, x[ 6], y[14]); //192
		word3_muladd(&w1, &w0, &w2, x[ 7], y[13]); //193
		word3_muladd(&w1, &w0, &w2, x[ 8], y[12]); //194
		word3_muladd(&w1, &w0, &w2, x[ 9], y[11]); //195
		word3_muladd(&w1, &w0, &w2, x[10], y[10]); //196
		word3_muladd(&w1, &w0, &w2, x[11], y[ 9]); //197
		word3_muladd(&w1, &w0, &w2, x[12], y[ 8]); //198
		word3_muladd(&w1, &w0, &w2, x[13], y[ 7]); //199 
		word3_muladd(&w1, &w0, &w2, x[14], y[ 6]); //200
		word3_muladd(&w1, &w0, &w2, x[15], y[ 5]); //201
		z[20] = w2; w2 = 0;
		
		word3_muladd(&w2, &w1, &w0, x[ 6], y[15]); //202
		word3_muladd(&w2, &w1, &w0, x[ 7], y[14]); //203
		word3_muladd(&w2, &w1, &w0, x[ 8], y[13]); //204
		word3_muladd(&w2, &w1, &w0, x[ 9], y[12]); //205
		word3_muladd(&w2, &w1, &w0, x[10], y[11]); //206
		word3_muladd(&w2, &w1, &w0, x[11], y[10]); //207
		word3_muladd(&w2, &w1, &w0, x[12], y[ 9]); //208
		word3_muladd(&w2, &w1, &w0, x[13], y[ 8]); //209
		word3_muladd(&w2, &w1, &w0, x[14], y[ 7]); //210
		word3_muladd(&w2, &w1, &w0, x[15], y[ 6]); //211
		z[21] = w0; w0 = 0;
		
		word3_muladd(&w0, &w2, &w1, x[ 7], y[15]); //212
		word3_muladd(&w0, &w2, &w1, x[ 8], y[14]); //213
		word3_muladd(&w0, &w2, &w1, x[ 9], y[13]); //214
		word3_muladd(&w0, &w2, &w1, x[10], y[12]); //215
		word3_muladd(&w0, &w2, &w1, x[11], y[11]); //216
		word3_muladd(&w0, &w2, &w1, x[12], y[10]); //217
		word3_muladd(&w0, &w2, &w1, x[13], y[ 9]); //218
		word3_muladd(&w0, &w2, &w1, x[14], y[ 8]); //219
		word3_muladd(&w0, &w2, &w1, x[15], y[ 7]); //220
		z[22] = w1; w1 = 0;
		
		word3_muladd(&w1, &w0, &w2, x[ 8], y[15]); //221
		word3_muladd(&w1, &w0, &w2, x[ 9], y[14]); //222
		word3_muladd(&w1, &w0, &w2, x[10], y[13]); //223
		word3_muladd(&w1, &w0, &w2, x[11], y[12]); //224
		word3_muladd(&w1, &w0, &w2, x[12], y[11]); //225
		word3_muladd(&w1, &w0, &w2, x[13], y[10]); //226
		word3_muladd(&w1, &w0, &w2, x[14], y[ 9]); //227
		word3_muladd(&w1, &w0, &w2, x[15], y[ 8]); //228
		z[23] = w2; w2 = 0;
		
		word3_muladd(&w2, &w1, &w0, x[ 9], y[15]); //229
		word3_muladd(&w2, &w1, &w0, x[10], y[14]); //230
		word3_muladd(&w2, &w1, &w0, x[11], y[13]); //231
		word3_muladd(&w2, &w1, &w0, x[12], y[12]); //232
		word3_muladd(&w2, &w1, &w0, x[13], y[11]); //233
		word3_muladd(&w2, &w1, &w0, x[14], y[10]); //234
		word3_muladd(&w2, &w1, &w0, x[15], y[ 9]); //235
		z[24] = w0; w0 = 0;
		
		word3_muladd(&w0, &w2, &w1, x[10], y[15]); //236
		word3_muladd(&w0, &w2, &w1, x[11], y[14]); //237
		word3_muladd(&w0, &w2, &w1, x[12], y[13]); //238
		word3_muladd(&w0, &w2, &w1, x[13], y[12]); //239
		word3_muladd(&w0, &w2, &w1, x[14], y[11]); //240
		word3_muladd(&w0, &w2, &w1, x[15], y[10]); //241
		z[25] = w1; w1 = 0;
		
		word3_muladd(&w1, &w0, &w2, x[11], y[15]); //242
		word3_muladd(&w1, &w0, &w2, x[12], y[14]); //243
		word3_muladd(&w1, &w0, &w2, x[13], y[13]); //244
		word3_muladd(&w1, &w0, &w2, x[14], y[12]); //245
		word3_muladd(&w1, &w0, &w2, x[15], y[11]); //246
		z[26] = w2; w2 = 0;
		
		word3_muladd(&w2, &w1, &w0, x[12], y[15]); //247
		word3_muladd(&w2, &w1, &w0, x[13], y[14]); //248
		word3_muladd(&w2, &w1, &w0, x[14], y[13]); //249
		word3_muladd(&w2, &w1, &w0, x[15], y[12]); //250
		z[27] = w0; w0 = 0;
		
		word3_muladd(&w0, &w2, &w1, x[13], y[15]); //251
		word3_muladd(&w0, &w2, &w1, x[14], y[14]); //252
		word3_muladd(&w0, &w2, &w1, x[15], y[13]); //253
		z[28] = w1; w1 = 0;
		
		word3_muladd(&w1, &w0, &w2, x[14], y[15]); //254
		word3_muladd(&w1, &w0, &w2, x[15], y[14]); //255
		z[29] = w2; w2 = 0;
		
		word3_muladd(&w2, &w1, &w0, x[15], y[15]); //256
		z[30] = w0;
		z[31] = w1;
	}
}
