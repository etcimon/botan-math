/**
* Low Level MPI Types
* 
* Copyright:
* (C) 1999-2007 Jack Lloyd
* (C) 2014-2015 Etienne Cimon
*
* License:
* Botan is released under the Simplified BSD License (see LICENSE.md)
*/
module botan_math.mp_types;

public import botan_math.mem_ops;

version(X86) { enum BOTAN_HAS_X86_ARCH = true; enum BOTAN_HAS_X86_64_ARCH = false; enum BOTAN_HAS_ARM_ARCH = false; }
version(X86_64) { enum BOTAN_HAS_X86_ARCH = false; enum BOTAN_HAS_X86_64_ARCH = true; enum BOTAN_HAS_ARM_ARCH = false; }
version(ARM) { enum BOTAN_HAS_X86_ARCH = false; enum BOTAN_HAS_X86_64_ARCH = false; enum BOTAN_HAS_ARM_ARCH = true; }

enum ERR_ARCH = "Cannot compile the selected module on this processor architecture.";

static if (BOTAN_HAS_X86_ARCH)
	enum BOTAN_MP_WORD_BITS = 32; 
else static if (BOTAN_HAS_X86_64_ARCH)
	enum BOTAN_MP_WORD_BITS = 64;
else static if (BOTAN_HAS_ARM_ARCH)
	enum BOTAN_MP_WORD_BITS = 32;
// todo: else static if (BOTAN_HAS_PPC_ARCH)

version(D_SIMD) enum BOTAN_HAS_SIMD = true;
else version(LDC) enum BOTAN_HAS_SIMD = true;
else            enum BOTAN_HAS_SIMD = false;

static if (BOTAN_MP_WORD_BITS == 8) {
    alias word = ubyte;
    alias dword = ushort;
    enum BOTAN_HAS_MP_DWORD = 1;
}
else static if (BOTAN_MP_WORD_BITS == 16) {
    alias word = ushort;
    alias dword = uint;
    enum BOTAN_HAS_MP_DWORD = 1;
}
else static if (BOTAN_MP_WORD_BITS == 32) {
    alias word = uint;
    alias dword = ulong;
    enum BOTAN_HAS_MP_DWORD = 1;
}
else static if (BOTAN_MP_WORD_BITS == 64) {
    alias word = ulong;

    enum BOTAN_HAS_MP_DWORD = 0;

} else
    static assert(false, "BOTAN_MP_WORD_BITS must be 8, 16, 32, or 64");


__gshared immutable word MP_WORD_MASK = ~cast(word)(0);
__gshared immutable word MP_WORD_TOP_BIT = (cast(word) 1) << (8*(word).sizeof - 1);
__gshared immutable word MP_WORD_MAX = MP_WORD_MASK;