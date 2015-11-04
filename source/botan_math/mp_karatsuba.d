/**
* Karatsuba operations
* 
* Copyright:
* (C) 1999-2010,2014 Jack Lloyd
* (C) 2014-2015 Etienne Cimon
*      2006 Luca Piccarreta
*
* License:
* Botan is released under the Simplified BSD License (see LICENSE.md)
*/
module botan_math.mp_karatsuba;

import botan_math.mp_types;
import botan_math.mp_bigint;
import botan_math.mp_comba;

__gshared immutable size_t KARATSUBA_MULTIPLY_THRESHOLD = 32;
__gshared immutable size_t KARATSUBA_SQUARE_THRESHOLD = 32;

/*
* Karatsuba Multiplication Operation
*/
void karatsuba_mul(word* z, in word* x, in word* y, size_t N, word* workspace)
{
	if (N < KARATSUBA_MULTIPLY_THRESHOLD || N % 2)
	{
		if (N == 6)
			return bigint_comba_mul6(*cast(word[12]*) z, *cast(word[6]*) x, *cast(word[6]*) y);
		else if (N == 8)
			return bigint_comba_mul8(*cast(word[16]*) z, *cast(word[8]*) x, *cast(word[8]*) y);
		else if (N == 16)
			return bigint_comba_mul16(*cast(word[32]*) z, *cast(word[16]*) x, *cast(word[16]*) y);
		else
			return bigint_simple_mul(z, x, N, y, N);
	}
	
	const size_t N2 = N / 2;
	
	const word* x0 = x;
	const word* x1 = x + N2;
	const word* y0 = y;
	const word* y1 = y + N2;
	word* z0 = z;
	word* z1 = z + N;
	
	const int cmp0 = bigint_cmp(x0, N2, x1, N2);
	const int cmp1 = bigint_cmp(y1, N2, y0, N2);
	
	clearMem(workspace, 2*N);
	
	//if (cmp0 && cmp1)
	{
		if (cmp0 > 0)
			bigint_sub3(z0, x0, N2, x1, N2);
		else
			bigint_sub3(z0, x1, N2, x0, N2);
		
		if (cmp1 > 0)
			bigint_sub3(z1, y1, N2, y0, N2);
		else
			bigint_sub3(z1, y0, N2, y1, N2);
		
		karatsuba_mul(workspace, z0, z1, N2, workspace+N);
	}
	
	karatsuba_mul(z0, x0, y0, N2, workspace+N);
	karatsuba_mul(z1, x1, y1, N2, workspace+N);
	
	const word ws_carry = bigint_add3_nc(workspace + N, z0, N, z1, N);
	word z_carry = bigint_add2_nc(z + N2, N, workspace + N, N);
	
	z_carry += bigint_add2_nc(z + N + N2, N2, &ws_carry, 1);
	bigint_add2_nc(z + N + N2, N2, &z_carry, 1);
	
	if ((cmp0 == cmp1) || (cmp0 == 0) || (cmp1 == 0))
		bigint_add2(z + N2, 2*N-N2, workspace, N);
	else
		bigint_sub2(z + N2, 2*N-N2, workspace, N);
}

/*
* Karatsuba Squaring Operation
*/
void karatsuba_sqr(word* z, in word* x, size_t N, word* workspace)
{
	if (N < KARATSUBA_SQUARE_THRESHOLD || N % 2)
	{
		if (N == 6)
			return bigint_comba_sqr6(*cast(word[12]*) z, *cast(word[6]*) x);
		else if (N == 8)
			return bigint_comba_sqr8(*cast(word[16]*) z, *cast(word[8]*) x);
		else if (N == 16)
			return bigint_comba_sqr16(*cast(word[32]*) z, *cast(word[16]*) x);
		else
			return bigint_simple_sqr(z, x, N);
	}
	
	const size_t N2 = N / 2;
	
	const word* x0 = x;
	const word* x1 = x + N2;
	word* z0 = z;
	word* z1 = z + N;
	
	const int cmp = bigint_cmp(x0, N2, x1, N2);
	
	clearMem(workspace, 2*N);
	
	//if (cmp)
	{
		if (cmp > 0)
			bigint_sub3(z0, x0, N2, x1, N2);
		else
			bigint_sub3(z0, x1, N2, x0, N2);
		
		karatsuba_sqr(workspace, z0, N2, workspace+N);
	}
	
	karatsuba_sqr(z0, x0, N2, workspace+N);
	karatsuba_sqr(z1, x1, N2, workspace+N);
	
	const word ws_carry = bigint_add3_nc(workspace + N, z0, N, z1, N);
	word z_carry = bigint_add2_nc(z + N2, N, workspace + N, N);
	
	z_carry += bigint_add2_nc(z + N + N2, N2, &ws_carry, 1);
	bigint_add2_nc(z + N + N2, N2, &z_carry, 1);
	
	/*
    * This is only actually required if cmp is != 0, however
    * if cmp==0 then workspace[0:N] == 0 and avoiding the jump
    * hides a timing channel.
    */
	bigint_sub2(z + N2, 2*N-N2, workspace, N);
}

/*
* Pick a good size for the Karatsuba multiply
*/
size_t karatsuba_size(size_t z_size,
	size_t x_size, size_t x_sw,
	size_t y_size, size_t y_sw)
{
	if (x_sw > x_size || x_sw > y_size || y_sw > x_size || y_sw > y_size)
		return 0;
	
	if (((x_size == x_sw) && (x_size % 2)) ||
		((y_size == y_sw) && (y_size % 2)))
		return 0;
	
	const size_t start = (x_sw > y_sw) ? x_sw : y_sw;
	const size_t end = (x_size < y_size) ? x_size : y_size;
	
	if (start == end)
	{
		if (start % 2)
			return 0;
		return start;
	}
	
	for (size_t j = start; j <= end; ++j)
	{
		if (j % 2)
			continue;
		
		if (2*j > z_size)
			return 0;
		
		if (x_sw <= j && j <= x_size && y_sw <= j && j <= y_size)
		{
			if (j % 4 == 2 &&
				(j+2) <= x_size && (j+2) <= y_size && 2*(j+2) <= z_size)
				return j+2;
			return j;
		}
	}
	
	return 0;
}

/*
* Pick a good size for the Karatsuba squaring
*/
size_t karatsuba_size(size_t z_size, size_t x_size, size_t x_sw)
{
	if (x_sw == x_size)
	{
		if (x_sw % 2)
			return 0;
		return x_sw;
	}
	
	for (size_t j = x_sw; j <= x_size; ++j)
	{
		if (j % 2)
			continue;
		
		if (2*j > z_size)
			return 0;
		
		if (j % 4 == 2 && (j+2) <= x_size && 2*(j+2) <= z_size)
			return j+2;
		return j;
	}
	
	return 0;
}