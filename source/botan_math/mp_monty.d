/**
* Monty operations
* 
* Copyright:
* (C) 1999-2010,2014 Jack Lloyd
* (C) 2014-2015 Etienne Cimon
*      2006 Luca Piccarreta
*
* License:
* Botan is released under the Simplified BSD License (see LICENSE.md)
*/
module botan_math.mp_monty;

import botan_math.mp_word;
import botan_math.mp_bigint;
import botan_math.mp_comba;
import botan_math.mp_karatsuba;
pure nothrow:
/*
* Multiplication Algorithm Dispatcher
*/
void bigint_mul(word* z, size_t z_size, word* workspace,
	in word* x, size_t x_size, size_t x_sw,
	in word* y, size_t y_size, size_t y_sw)
{
	if (x_sw == 1)
	{
		bigint_linmul3(z, y, y_sw, x[0]);
	}
	else if (y_sw == 1)
	{
		bigint_linmul3(z, x, x_sw, y[0]);
	}
	else if (x_sw <= 4 && x_size >= 4 &&
		y_sw <= 4 && y_size >= 4 && z_size >= 8)
	{
		bigint_comba_mul4(*cast(word[8]*) z, *cast(word[4]*) x, *cast(word[4]*) y);
	}
	else if (x_sw <= 6 && x_size >= 6 &&
		y_sw <= 6 && y_size >= 6 && z_size >= 12)
	{
		bigint_comba_mul6(*cast(word[12]*) z, *cast(word[6]*) x, *cast(word[6]*) y);
	}
	else if (x_sw <= 8 && x_size >= 8 &&
		y_sw <= 8 && y_size >= 8 && z_size >= 16)
	{
		bigint_comba_mul8(*cast(word[16]*) z, *cast(word[8]*) x, *cast(word[8]*) y);
	}
	else if (x_sw <= 9 && x_size >= 9 &&
		y_sw <= 9 && y_size >= 9 && z_size >= 18)
	{
		bigint_comba_mul9(*cast(word[18]*) z, *cast(word[9]*) x, *cast(word[9]*) y);
	}
	else if (x_sw <= 16 && x_size >= 16 &&
		y_sw <= 16 && y_size >= 16 && z_size >= 32)
	{
		bigint_comba_mul16(*cast(word[32]*) z, *cast(word[16]*) x, *cast(word[16]*) y);
	}
	else if (x_sw < KARATSUBA_MULTIPLY_THRESHOLD ||
		y_sw < KARATSUBA_MULTIPLY_THRESHOLD ||
		!workspace)
	{
		bigint_simple_mul(z, x, x_sw, y, y_sw);
	}
	else
	{
		const size_t N = karatsuba_size(z_size, x_size, x_sw, y_size, y_sw);
		
		if (N)
			karatsuba_mul(z, x, y, N, workspace);
		else
			bigint_simple_mul(z, x, x_sw, y, y_sw);
	}
}

/*
* Squaring Algorithm Dispatcher
*/
void bigint_sqr(word* z, size_t z_size, word* workspace,
	in word* x, size_t x_size, size_t x_sw)
{
	if (x_sw == 1)
	{
		bigint_linmul3(z, x, x_sw, x[0]);
	}
	else if (x_sw <= 4 && x_size >= 4 && z_size >= 8)
	{
		bigint_comba_sqr4(*cast(word[8]*) z, *cast(word[4]*) x);
	}
	else if (x_sw <= 6 && x_size >= 6 && z_size >= 12)
	{
		bigint_comba_sqr6(*cast(word[12]*) z, *cast(word[6]*) x);
	}
	else if (x_sw <= 8 && x_size >= 8 && z_size >= 16)
	{
		bigint_comba_sqr8(*cast(word[16]*) z, *cast(word[8]*) x);
	}
	else if (x_sw <= 9 && x_size >= 9 && z_size >= 18)
	{
		bigint_comba_sqr9(*cast(word[18]*) z, *cast(word[9]*) x);
	}
	else if (x_sw <= 16 && x_size >= 16 && z_size >= 32)
	{
		bigint_comba_sqr16(*cast(word[32]*) z, *cast(word[16]*) x);
	}
	else if (x_size < KARATSUBA_SQUARE_THRESHOLD || !workspace)
	{
		bigint_simple_sqr(z, x, x_sw);
	}
	else
	{
		const size_t N = karatsuba_size(z_size, x_size, x_sw);
		
		if (N)
			karatsuba_sqr(z, x, N, workspace);
		else
			bigint_simple_sqr(z, x, x_sw);
	}
}

/*
* Montgomery Multiplication
*/
void bigint_monty_mul(word* z, size_t z_size,
	in word* x, size_t x_size, size_t x_sw,
	in word* y, size_t y_size, size_t y_sw,
	in word* p, size_t p_size, word p_dash,
	word* ws)
{
	bigint_mul( z, z_size, ws,
		x, x_size, x_sw,
		y, y_size, y_sw);
	
	bigint_monty_redc(z, p, p_size, p_dash, ws);
}


/*
* Montgomery Squaring
*/
void bigint_monty_sqr(word* z, size_t z_size,
	in word* x, size_t x_size, size_t x_sw,
	in word* p, size_t p_size, word p_dash,
	word* ws)
{
	bigint_sqr(z, z_size, ws, x, x_size, x_sw);
	bigint_monty_redc(z, p, p_size, p_dash, ws);
}



/**
* Montgomery Reduction
* Params:
*  z = integer to reduce, of size exactly 2*(p_size+1).
              Output is in the first p_size+1 words, higher
              words are set to zero.
*  p = modulus
*  p_size = size of p
*  p_dash = Montgomery value
*  ws = workspace array of at least 2*(p_size+1) words
*/
void bigint_monty_redc(word* z, in word* p, size_t p_size, word p_dash, word* ws)
{
	const size_t z_size = 2*(p_size+1);
	const size_t blocks_of_8 = p_size - (p_size % 8);
	
	foreach (size_t i; 0 .. p_size)
	{
		word* z_i = z + i;
		
		word y = (*z_i) * p_dash;
		
		/*
        bigint_linmul3(ws, p, p_size, y);
        bigint_add2(z_i, z_size - i, ws, p_size+1);
        */
		
		word carry = 0;
		
		for (size_t j = 0; j < blocks_of_8; j += 8)
			carry = word8_madd3(*cast(word[8]*) (z_i + j), *cast(word[8]*) (p + j), y, carry);

		for (size_t j = blocks_of_8; j < p_size; j++) {
			version(D_InlineAsm_X86_64) {
				word* _x = (cast(word*)p) + j;
				word* _z = z_i + j;
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
					mov carry, RDX;
					mov [R9], RAX;
				}
			} else 
				z_i[j] = word_madd3(p[j], y, z_i[j], &carry);
		}
		word z_sum = z_i[p_size] + carry;
		carry = (z_sum < z_i[p_size]);
		z_i[p_size] = z_sum;
		
		for (size_t j = p_size + 1; carry && j != z_size - i; ++j)
		{
			++z_i[j];
			carry = !z_i[j];
		}
	}
	
	word borrow = 0;
	foreach (size_t i; 0 .. p_size)
		ws[i] = word_sub(z[p_size + i], p[i], &borrow);
	
	ws[p_size] = word_sub(z[p_size+p_size], 0, &borrow);
	
	copyMem(ws + p_size + 1, z + p_size, p_size + 1);
	
	copyMem(z, ws + borrow*(p_size+1), p_size + 1);
	clearMem(z + p_size + 1, z_size - p_size - 1);
}