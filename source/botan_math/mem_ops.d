module botan_math.mem_ops;

import core.stdc.string : memset, memmove;
pure nothrow:
/**
* Zeroise memory
* Params:
*  ptr = a pointer to an array
*  n = the number of Ts pointed to by ptr
*/
void clearMem(T)(T* ptr, size_t n)
{
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