/**
* Botan BigInt operations
* 
* Copyright:
* (C) 1999-2010,2014 Jack Lloyd
* (C) 2014-2015 Etienne Cimon
*      2006 Luca Piccarreta
*
* License:
* Botan is released under the Simplified BSD License (see LICENSE.md)
*/
module botan_math.mp_bigint;

import botan_math.mp_word;

/*
* The size of the word type, in bits
*/
const size_t MP_WORD_BITS = BOTAN_MP_WORD_BITS;

/**
* Two operand addition
* Params:
*  x = the first operand (and output)
*  x_size = size of x
*  y = the second operand
*  y_size = size of y (must be >= x_size)
*/
void bigint_add2(word* x, size_t x_size, in word* y, size_t y_size)
{
	if (bigint_add2_nc(x, x_size, y, y_size))
		x[x_size] += 1;
}

/**
* Three operand addition
*/
void bigint_add3(word* z, in word* x, size_t x_size,
	in word* y, size_t y_size)
{
	z[(x_size > y_size ? x_size : y_size)] += bigint_add3_nc(z, x, x_size, y, y_size);
}

/**
* Two operand addition with carry out
*/
word bigint_add2_nc(word* x, size_t x_size, in word* y, size_t y_size)
{
	word carry = 0;
	
	assert(x_size >= y_size, "Expected sizes");
	
	const size_t blocks = y_size - (y_size % 8);
	
	for (size_t i = 0; i != blocks; i += 8)
		carry = word8_add2((x + i)[0 .. 8], (y + i)[0 .. 8], carry);
	
	foreach (size_t i; blocks .. y_size)
		x[i] = word_add(x[i], y[i], &carry);
	
	foreach (size_t i; y_size .. x_size)
		x[i] = word_add(x[i], 0, &carry);
	
	return carry;
}

/**
* Three operand addition with carry out
*/
word bigint_add3_nc(word* z, in word* x, size_t x_size, in word* y, size_t y_size)
{
	if (x_size < y_size)
	{ return bigint_add3_nc(z, y, y_size, x, x_size); }
	
	word carry = 0;
	
	const size_t blocks = y_size - (y_size % 8);
	
	for (size_t i = 0; i != blocks; i += 8)
		carry = word8_add3(*cast(word[8]*) (z + i), *cast(word[8]*) (x + i), *cast(word[8]*) (y + i), carry);
	
	foreach (size_t i; blocks .. y_size)
		z[i] = word_add(x[i], y[i], &carry);
	
	foreach (size_t i; y_size .. x_size)
		z[i] = word_add(x[i], 0, &carry);
	
	return carry;
}

/**
* Two operand subtraction
*/
word bigint_sub2(word* x, size_t x_size, in word* y, size_t y_size)
{
	word borrow = 0;
	
	assert(x_size >= y_size, "Expected sizes");
	
	const size_t blocks = y_size - (y_size % 8);
	
	for (size_t i = 0; i != blocks; i += 8)
		borrow = word8_sub2(*cast(word[8]*) (x + i), *cast(word[8]*) (y + i), borrow);
	
	foreach (size_t i; blocks .. y_size)
		x[i] = word_sub(x[i], y[i], &borrow);
	
	foreach (size_t i; y_size .. x_size)
		x[i] = word_sub(x[i], 0, &borrow);
	
	return borrow;
}

/**
* Two operand subtraction, x = y - x; assumes y >= x
*/
void bigint_sub2_rev(word* x,  in word* y, size_t y_size)
{
	word borrow = 0;
	
	const size_t blocks = y_size - (y_size % 8);
	
	for (size_t i = 0; i != blocks; i += 8)
		borrow = word8_sub2_rev(*cast(word[8]*) (x + i), *cast(word[8]*) (y + i), borrow);
	
	foreach (size_t i; blocks .. y_size)
		x[i] = word_sub(y[i], x[i], &borrow);
	
	assert(!borrow, "y must be greater than x");
}

/**
* Three operand subtraction
*/
word bigint_sub3(word* z, in word* x, size_t x_size, in word* y, size_t y_size)
{
	word borrow = 0;
	
	assert(x_size >= y_size, "Expected sizes");
	
	const size_t blocks = y_size - (y_size % 8);
	
	for (size_t i = 0; i != blocks; i += 8)
		borrow = word8_sub3(*cast(word[8]*) (z + i), *cast(word[8]*) (x + i), *cast(word[8]*) (y + i), borrow);
	
	foreach (size_t i; blocks .. y_size)
		z[i] = word_sub(x[i], y[i], &borrow);
	
	foreach (size_t i; y_size .. x_size)
		z[i] = word_sub(x[i], 0, &borrow);
	
	return borrow;
}

/*
* Shift Operations
*/

/*
* Single Operand Left Shift
*/
void bigint_shl1(word* x, size_t x_size, size_t word_shift, size_t bit_shift)
{
	if (word_shift)
	{
		copyMem(x + word_shift, x, x_size);
		clearMem(x, word_shift);
	}
	
	if (bit_shift)
	{
		word carry = 0;
		foreach (size_t j; word_shift .. (x_size + word_shift + 1))
		{
			word temp = x[j];
			x[j] = (temp << bit_shift) | carry;
			carry = (temp >> (MP_WORD_BITS - bit_shift));
		}
	}
}

/*
* Single Operand Right Shift
*/
void bigint_shr1(word* x, size_t x_size, size_t word_shift, size_t bit_shift)
{
	if (x_size < word_shift)
	{
		clearMem(x, x_size);
		return;
	}
	
	if (word_shift)
	{
		copyMem(x, x + word_shift, x_size - word_shift);
		clearMem(x + x_size - word_shift, word_shift);
	}
	
	if (bit_shift)
	{
		word carry = 0;
		
		size_t top = x_size - word_shift;
		
		while (top >= 4)
		{
			word w = x[top-1];
			x[top-1] = (w >> bit_shift) | carry;
			carry = (w << (MP_WORD_BITS - bit_shift));
			
			w = x[top-2];
			x[top-2] = (w >> bit_shift) | carry;
			carry = (w << (MP_WORD_BITS - bit_shift));
			
			w = x[top-3];
			x[top-3] = (w >> bit_shift) | carry;
			carry = (w << (MP_WORD_BITS - bit_shift));
			
			w = x[top-4];
			x[top-4] = (w >> bit_shift) | carry;
			carry = (w << (MP_WORD_BITS - bit_shift));
			
			top -= 4;
		}
		
		while (top)
		{
			word w = x[top-1];
			x[top-1] = (w >> bit_shift) | carry;
			carry = (w << (MP_WORD_BITS - bit_shift));
			
			top--;
		}
	}
}

/*
* Two Operand Left Shift
*/
void bigint_shl2(word* y, in word* x, size_t x_size, size_t word_shift, size_t bit_shift)
{
	foreach (size_t j; 0 .. x_size)
		y[j + word_shift] = x[j];
	if (bit_shift)
	{
		word carry = 0;
		foreach (size_t j; word_shift .. (x_size + word_shift + 1))
		{
			word w = y[j];
			y[j] = (w << bit_shift) | carry;
			carry = (w >> (MP_WORD_BITS - bit_shift));
		}
	}
}

/*
* Two Operand Right Shift
*/
void bigint_shr2(word* y, in word* x, size_t x_size,
	size_t word_shift, size_t bit_shift)
{
	if (x_size < word_shift) return;
	
	foreach (size_t j; 0 .. (x_size - word_shift))
		y[j] = x[j + word_shift];
	if (bit_shift)
	{
		word carry = 0;
		for (size_t j = x_size - word_shift; j > 0; --j)
		{
			word w = y[j-1];
			y[j-1] = (w >> bit_shift) | carry;
			carry = (w << (MP_WORD_BITS - bit_shift));
		}
	}
}

/*
* Simple O(N^2) Multiplication and Squaring
*/
void bigint_simple_mul(word* z, in word* x, size_t x_size, in word* y, size_t y_size)
{
	const size_t x_size_8 = x_size - (x_size % 8);
	
	clearMem(z, x_size + y_size);
	
	foreach (size_t i; 0 .. y_size)
	{
		const word y_i = y[i];
		
		word carry = 0;
		
		for (size_t j = 0; j != x_size_8; j += 8)
			carry = word8_madd3(*cast(word[8]*) (z + i + j), *cast(word[8]*) (x + j), y_i, carry);
		
		foreach (size_t j; x_size_8 .. x_size)
			z[i+j] = word_madd3(x[j], y_i, z[i+j], &carry);
		
		z[x_size+i] = carry;
	}
}

/*
* Simple O(N^2) Squaring
*
* This is exactly the same algorithm as bigint_simple_mul, however
* because C/C++ compilers suck at alias analysis it is good to have
* the version where the compiler knows that x == y
*
* There is an O(n^1.5) squaring algorithm specified in Handbook of
* Applied Cryptography, chapter 14
*
*/
void bigint_simple_sqr(word* z, in word* x, size_t x_size)
{
	const size_t x_size_8 = x_size - (x_size % 8);
	
	clearMem(z, 2*x_size);
	
	foreach (size_t i; 0 .. x_size)
	{
		const word x_i = x[i];
		word carry = 0;
		
		for (size_t j = 0; j != x_size_8; j += 8)
			carry = word8_madd3(*cast(word[8]*) (z + i + j), *cast(word[8]*) (x + j), x_i, carry);
		
		foreach (size_t j; x_size_8 .. x_size)
			z[i+j] = word_madd3(x[j], x_i, z[i+j], &carry);
		
		z[x_size+i] = carry;
	}
}


/*
* Linear Multiply
*/
/*
* Two Operand Linear Multiply
*/
void bigint_linmul2(word* x, size_t x_size, word y)
{
	const size_t blocks = x_size - (x_size % 8);
	
	word carry = 0;
	
	for (size_t i = 0; i != blocks; i += 8)
		carry = word8_linmul2(*cast(word[8]*) (x + i), y, carry);
	
	foreach (size_t i; blocks .. x_size) {
		x[i] = word_madd2(x[i], y, &carry);
	}
	x[x_size] = carry;
}

/*
* Three Operand Linear Multiply
*/
void bigint_linmul3(word* z, in word* x, size_t x_size, word y)
{
	const size_t blocks = x_size - (x_size % 8);
	
	word carry = 0;
	
	for (size_t i = 0; i != blocks; i += 8)
		carry = word8_linmul3(*cast(word[8]*) (z + i), *cast(word[8]*) (x + i), y, carry);
	
	foreach (size_t i; blocks .. x_size)
		z[i] = word_madd2(x[i], y, &carry);
	
	z[x_size] = carry;
}



/**
* Compare x and y
*/
int bigint_cmp(in word* x, size_t x_size,
	in word* y, size_t y_size)
{
	if (x_size < y_size) { return (-bigint_cmp(y, y_size, x, x_size)); }
	
	while (x_size > y_size)
	{
		if (x[x_size-1])
			return 1;
		x_size--;
	}
	
	for (size_t i = x_size; i > 0; --i)
	{
		if (x[i-1] > y[i-1])
			return 1;
		if (x[i-1] < y[i-1])
			return -1;
	}
	
	return 0;
}

/**
* Compute ((n1<<bits) + n0) / d
*/
word bigint_divop(word n1, word n0, word d)
{
	word high = n1 % d, quotient = 0;
	
	foreach (size_t i; 0 .. MP_WORD_BITS)
	{
		word high_top_bit = (high & MP_WORD_TOP_BIT);
		
		high <<= 1;
		high |= (n0 >> (MP_WORD_BITS-1-i)) & 1;
		quotient <<= 1;
		
		if (high_top_bit || high >= d)
		{
			high -= d;
			quotient |= 1;
		}
	}
	
	return quotient;
}

/**
* Compute ((n1<<bits) + n0) % d
*/
word bigint_modop(word n1, word n0, word d)
{
	word z = bigint_divop(n1, n0, d);
	word dummy = 0;
	z = word_madd2(z, d, &dummy);
	return (n0-z);
}