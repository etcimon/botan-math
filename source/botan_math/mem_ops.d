module botan_math.mem_ops;

import std.c.string : memset, memmove;

/**
* Zeroise memory
* Params:
*  ptr = a pointer to an array
*  n = the number of Ts pointed to by ptr
*/
pragma(inline, true)
void clearMem(T)(T* ptr, size_t n)
{
	pragma(inline, true);
	memset(ptr, 0, T.sizeof*n);
}

/**
* Copy memory
* Params:
*  output = the destination array
*  input = the source array
*  n = the number of elements of in/out
*/
void copyMem(T)(T* output, in T* input, in size_t n)
{
	memmove(output, input, T.sizeof*n);
}