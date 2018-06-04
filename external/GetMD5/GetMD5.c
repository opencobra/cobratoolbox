// GetMD5.c
// GetMD5 - 128 bit MD5 checksum: file, string, array, byte stream
// This function calculates a 128 bit checksum for arrays or files.
// Digest = GetMD5(Data, Mode, Format)
// INPUT:
//   Data:   File name or array.
//   Mode:   String to declare the type of the 1st input. Not case-sensitive.
//             'File':   Data is a file name as string.
//             '8Bit':   If Data is a CHAR array, only the 8 bit ASCII part is
//                       used. Then the digest is the same as for a ASCII text
//                       file e.g. created by: FWRITE(FID, Data, 'uchar').
//                       This is ignored if Data is not of type CHAR.
//             'Binary': The MD5 sum is obtained for the contents of Data.
//                       This works for numerical, CHAR and LOGICAL arrays.
//             'Array':  Include the class and dimensions of Data in the MD5
//                       sum. This can be applied for (nested) structs, cells
//                       and sparse arrays also.
//           Optional. Default: '8Bit' for CHAR, 'Binary' otherwise.
//   Format: String, format of the output. Only the first character matters.
//           The upper/lower case matters for 'hex' only.
//             'hex':    [1 x 32] lowercase hexadecimal string.
//             'HEX':    [1 x 32] uppercase hexadecimal string.
//             'double': [1 x 16] double vector with UINT8 values.
//             'uint8':  [1 x 16] uint8 vector.
//             'base64': [1 x 22] string, encoded to base 64 (A:Z,a:z,0:9,+,/).
//                       The string is not padded to keep it short.
//           Optional, default: 'hex'.
//
// OUTPUT:
//   Digest: A 128 bit number is replied in the specified format.
//
// NOTE:
// * The M-file GetMD5_helper is called for sparse arrays, function handles,
//   java and user-defined objects .
// * This is at least 2 times faster than the Java method.
//
// EXAMPLES:
// Three methods to get the MD5 of a file:
//   1. Direct file access (recommended):
//     MD5 = GetMD5(which('GetMD5.m'), 'File')
//   2. Import the file to a CHAR array (no text mode for exact line breaks!):
//     FID = fopen(which('GetMD5.m'), 'r');
//     S   = fread(FID, inf, 'uchar=>char');
//     fclose(FID);
//     MD5 = GetMD5(S, '8bit')
//   3. Import file as a byte stream:
//     FID = fopen(which('GetMD5.m'), 'r');
//     S   = fread(FID, inf, 'uint8=>uint8');
//     fclose(FID);
//     MD5 = GetMD5(S, 'bin');  % 'bin' can be omitted here
//
//   Test data:
//     GetMD5(char(0:511), '8bit', 'HEX')      % Consider 8bit part only
//       % => F5C8E3C31C044BAE0E65569560B54332
//     GetMD5(char(0:511), 'bin')              % Matlab's CHAR are 16 bit!
//       % => 3484769D4F7EBB88BBE942BB924834CD
//     GetMD5(char(0:511), 'array')            % Consider 16 bit, type and size
//       % => b9a955ae730b25330d4f4ebb0a51e8f0
//     GetMD5('abc')                           % implicit: 8bit for CHAR input
//       % => 900150983cd24fb0d6963f7d28e17f72
//
// COMPILE:
// On demand a C-compiler must be installed at first, see: "mex -setup"
// Automatic: Call GetMD5 without inputs.
// Manually:
//   mex -O GetMD5.c
// Consider C99 comments under Linux:
//   mex -O CFLAGS="\$CFLAGS -std=c99" GetMD5.c
// Pre-compiled MEX files can be downloaded: http:\\www.n-simon.de\mex
// Run the unit-test uTest_GetMD5 after the compilation.
//
// Tested: Matlab 6.5, 7.7, 7.8, 7.13, 8.6, WinXP/32, Win7/64
//         Compiler: LCC2.4/3.8, BCC5.5, OWC1.8, MSVC2008/2010
// Assumed Compatibility: higher Matlab versions, Mac, Linux
// Author: Jan Simon, Heidelberg, (C) 2006-2016 matlab.2010(a)n(MINUS)simon.de
// License: BSD. This program is based on:
//          RFC 1321, MD5 Message-Digest Algorithm, April 1992
//          RSA Data Security, Inc. MD5 Message Digest Algorithm
//          Implementation: Alexander Peslyak
//
// See also: CalcCRC32, DataHash.
//
// Michael Kleder has published a Java call to compute the MD5 and SHA sums:
//   http://www.mathworks.com/matlabcentral/fileexchange/8944

/*******************************************************************************
 * The MD5-part is based on:
 *
 * This is an OpenSSL-compatible implementation of the RSA Data Security, Inc.
 * MD5 Message-Digest Algorithm (RFC 1321).
 *
 * Homepage:
 * http://openwall.info/wiki/people/solar/software/public-domain-source-code/md5
 *
 * Author:
 * Alexander Peslyak, better known as Solar Designer <solar at openwall.com>
 *
 * This software was written by Alexander Peslyak in 2001.  No copyright is
 * claimed, and the software is hereby placed in the public domain.
 *******************************************************************************
 */
 
/*
% $JRev: R5f V:061 Sum:0K6boVfyKe5t Date:17-Oct-2017 00:06:02 $
% $License: BSD (use/copy/change/redistribute on own risk, mention the author) $
% $UnitTest: uTest_GetMD5 $
% $File: Tools\Mex\Source\GetMD5.c $
% History:
% 011: 20-Oct-2006 20:50, [16 x 1] -> [1 x 16] replied as double.
% 012: 01-Nov-2006 23:10, BUGFIX: hex output for 'Hex' input now.
% 015: 02-Oct-2008 14:47, Base64 output.
% 017: 19-Oct-2008 22:33, Accept numerical arrays as byte stream.
% 023: 15-Dec-2009 16:53, BUGFIX: UINT32 has 32 bits on 64 bit systems now.
%      Thanks to Sebastiaan Breedveld!
% 030: 17-Mar-2010 11:38, UINT8 output.
% 032: 06-Jul-2010 23:23, Indirect CONST pointer in ToHex for BCC5.5.
% 037: 14-May-2011 13:14, Default input type: char->byte.
% 042: 27-Jan-2015 23:00, 64 bit arrays, nicer error messages, 10% faster.
%      "CalcMD5" -> "GetMD5".
% 046: 16-Feb-2015 00:10, "Array" type: consider type and dimensions.
%      The "Array" type works for cells and structs also.
% 050: 09-Mar-2015 23:08, Faster hash code of Alexander Peslyak.
% 060: 04-Jun-2016 22:22, Fixed compile error on Macs.
%      Thanks to Jonas Zimmermann.
% 061: 16-Oct-2017 23:56, Compilation failed if _LITTLE_ENDIAN is undefined.
*/

#define __STDC_WANT_LIB_EXT1__ 1

// Headers:
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "mex.h"

// Assume 32 bit addressing for Matlab 6.5:
// See MEX option "compatibleArrayDims" for MEX in Matlab >= 7.7.
#ifndef MWSIZE_MAX
#  define mwSize  int32_T              // Defined in tmwtypes.h
#  define mwIndex int32_T
#  define MWSIZE_MAX MAX_int32_T
#endif

// Directive for endianess:
#if !defined(_LITTLE_ENDIAN) && !defined(_BIG_ENDIAN)
#  define _LITTLE_ENDIAN
#endif

// Safe string length for fieldnames:
#if defined _MSC_VER || \
    (defined(__STDC_LIB_EXT1__) && __STDC_WANT_LIB_EXT1__ >= 1)
#  define STRING_LENGTH(s,n) strnlen_s(s,n)
#else
#  define STRING_LENGTH(s,n) strlen(s)
#endif

// Strange objects can cause an infinite recursion and kill Matlab. So limit the
// recursion depths for a useful error message:
#define MAX_RECURSION 500
static int RecursionCount;

// MD5 part: -------------------------------------------------------------------
typedef struct {
  uint32_T lo, hi;
  uint32_T a, b, c, d;
  uchar_T  buffer[64];
  uint32_T block[16];
} MD5_CTX;

// Prototypes:
void MD5_Init(MD5_CTX *ctx);
void MD5_Update(MD5_CTX *ctx, uchar_T *data, mwSize size);
void MD5_Final(uchar_T *digest, MD5_CTX *ctx);
static uchar_T *MD5_Body(MD5_CTX *ctx, uchar_T *data, mwSize size);

/* The basic MD5 functions.
 *
 * F and G are optimized compared to their RFC 1321 definitions for
 * architectures that lack an AND-NOT instruction, just like in Colin Plumb's
 * implementation.
 */
#define F(x, y, z)  ((z) ^ ((x) & ((y) ^ (z))))
#define G(x, y, z)  ((y) ^ ((z) & ((x) ^ (y))))
#define H(x, y, z)  ((x) ^ (y) ^ (z))
#define I(x, y, z)  ((y) ^ ((x) | ~(z)))

/* The MD5 transformation for all four rounds. */
#define STEP(f, a, b, c, d, x, t, s) \
  (a) += f((b), (c), (d)) + (x) + (t); \
  (a) = (((a) << (s)) | (((a) & 0xffffffff) >> (32 - (s)))); \
  (a) += (b);

/* SET reads 4 input bytes in little-endian byte order and stores them in a
 * properly aligned word in host byte order.
 *
 * The check for little-endian architectures that tolerate unaligned memory
 * accesses is just an optimization. Nothing will break if it doesn't work.
 */
#ifdef _LITTLE_ENDIAN
#  define SET(n) (*(uint32_T *)&ptr[(n) * 4])
#  define GET(n) SET(n)
#else
#  define SET(n) \
    (ctx->block[(n)] = \
       (uint32_T)ptr[(n) * 4] | \
      ((uint32_T)ptr[(n) * 4 + 1] << 8) | \
      ((uint32_T)ptr[(n) * 4 + 2] << 16) | \
      ((uint32_T)ptr[(n) * 4 + 3] << 24))
#  define GET(n) (ctx->block[(n)])
#endif

// Matlab part: ----------------------------------------------------------------
// Length of the file buffer (must be < 2^31 for 32 bit machines):
#define BUFFER_LEN 1024
static uchar_T buffer[BUFFER_LEN];

typedef enum {ASCII_m, ARRAY_m, BINARY_m, FILE_m} Method_t;

typedef struct StringRec {
    const char_T *string;
    int          index;
} StringRec;

// Error and warning messages:
#define ERR_HEAD  "*** GetMD5[mex]: "
#define ERR_ID    "JSimon:GetMD5:"
#define ERROR(id,msg) mexErrMsgIdAndTxt(ERR_ID id, ERR_HEAD msg);
#define ERROR3(id,msg,arg) mexErrMsgIdAndTxt(ERR_ID id, ERR_HEAD msg, arg);

#define WARN_HEAD "### GetMD5[mex]: "
#define WARN(id,msg) mexWarnMsgIdAndTxt(ERR_ID id, WARN_HEAD msg);

// Prototypes:
void ToHex   (const uchar_T In[16], char *Out, int LowerCase);
void ToBase64(const uchar_T In[16], char *Out);

void ProcessBin  (uchar_T *data, mwSize N, uchar_T digest[16]);
void ProcessFile (char *FileName, uchar_T digest[16]);
void ProcessChar (mxChar *data, mwSize N, uchar_T digest[16]);
void ProcessArray(const mxArray *V, uchar_T digest[16]);
void ArrayCore   (MD5_CTX *context, const mxArray *V);
void StructCore  (MD5_CTX *context, const mxArray *V, mwSize nElem);
int  CompareStringRec(const void *a, const void *b);

// =============================== FUNCTIONS ===================================

// *****************************************************************************
// ** MD5 part:
// *****************************************************************************

// MD5 initialization. Begins an MD5 operation, writing a new context:
void MD5_Init(MD5_CTX *ctx)
{
  // Load magic initialization constants:
  ctx->a  = 0x67452301;
  ctx->b  = 0xefcdab89;
  ctx->c  = 0x98badcfe;
  ctx->d  = 0x10325476;
  
  ctx->lo = 0;
  ctx->hi = 0;
}

// This processes one or more 64-byte data blocks, but does NOT update
// the bit counters. There are no alignment requirements.
static uchar_T *MD5_Body(MD5_CTX *ctx, uchar_T *data, mwSize size)
{
  uchar_T  *ptr;
  uint32_T a, b, c, d,
           saved_a, saved_b, saved_c, saved_d;

  ptr = data;

  a = ctx->a;
  b = ctx->b;
  c = ctx->c;
  d = ctx->d;

  do {
    saved_a = a;
    saved_b = b;
    saved_c = c;
    saved_d = d;

// Round 1
    STEP(F, a, b, c, d, SET(0),  0xd76aa478,  7)
    STEP(F, d, a, b, c, SET(1),  0xe8c7b756, 12)
    STEP(F, c, d, a, b, SET(2),  0x242070db, 17)
    STEP(F, b, c, d, a, SET(3),  0xc1bdceee, 22)
    STEP(F, a, b, c, d, SET(4),  0xf57c0faf,  7)
    STEP(F, d, a, b, c, SET(5),  0x4787c62a, 12)
    STEP(F, c, d, a, b, SET(6),  0xa8304613, 17)
    STEP(F, b, c, d, a, SET(7),  0xfd469501, 22)
    STEP(F, a, b, c, d, SET(8),  0x698098d8,  7)
    STEP(F, d, a, b, c, SET(9),  0x8b44f7af, 12)
    STEP(F, c, d, a, b, SET(10), 0xffff5bb1, 17)
    STEP(F, b, c, d, a, SET(11), 0x895cd7be, 22)
    STEP(F, a, b, c, d, SET(12), 0x6b901122,  7)
    STEP(F, d, a, b, c, SET(13), 0xfd987193, 12)
    STEP(F, c, d, a, b, SET(14), 0xa679438e, 17)
    STEP(F, b, c, d, a, SET(15), 0x49b40821, 22)

// Round 2
    STEP(G, a, b, c, d, GET(1),  0xf61e2562,  5)
    STEP(G, d, a, b, c, GET(6),  0xc040b340,  9)
    STEP(G, c, d, a, b, GET(11), 0x265e5a51, 14)
    STEP(G, b, c, d, a, GET(0),  0xe9b6c7aa, 20)
    STEP(G, a, b, c, d, GET(5),  0xd62f105d,  5)
    STEP(G, d, a, b, c, GET(10), 0x02441453,  9)
    STEP(G, c, d, a, b, GET(15), 0xd8a1e681, 14)
    STEP(G, b, c, d, a, GET(4),  0xe7d3fbc8, 20)
    STEP(G, a, b, c, d, GET(9),  0x21e1cde6,  5)
    STEP(G, d, a, b, c, GET(14), 0xc33707d6,  9)
    STEP(G, c, d, a, b, GET(3),  0xf4d50d87, 14)
    STEP(G, b, c, d, a, GET(8),  0x455a14ed, 20)
    STEP(G, a, b, c, d, GET(13), 0xa9e3e905,  5)
    STEP(G, d, a, b, c, GET(2),  0xfcefa3f8,  9)
    STEP(G, c, d, a, b, GET(7),  0x676f02d9, 14)
    STEP(G, b, c, d, a, GET(12), 0x8d2a4c8a, 20)

// Round 3
    STEP(H, a, b, c, d, GET(5),  0xfffa3942,  4)
    STEP(H, d, a, b, c, GET(8),  0x8771f681, 11)
    STEP(H, c, d, a, b, GET(11), 0x6d9d6122, 16)
    STEP(H, b, c, d, a, GET(14), 0xfde5380c, 23)
    STEP(H, a, b, c, d, GET(1),  0xa4beea44,  4)
    STEP(H, d, a, b, c, GET(4),  0x4bdecfa9, 11)
    STEP(H, c, d, a, b, GET(7),  0xf6bb4b60, 16)
    STEP(H, b, c, d, a, GET(10), 0xbebfbc70, 23)
    STEP(H, a, b, c, d, GET(13), 0x289b7ec6,  4)
    STEP(H, d, a, b, c, GET(0),  0xeaa127fa, 11)
    STEP(H, c, d, a, b, GET(3),  0xd4ef3085, 16)
    STEP(H, b, c, d, a, GET(6),  0x04881d05, 23)
    STEP(H, a, b, c, d, GET(9),  0xd9d4d039,  4)
    STEP(H, d, a, b, c, GET(12), 0xe6db99e5, 11)
    STEP(H, c, d, a, b, GET(15), 0x1fa27cf8, 16)
    STEP(H, b, c, d, a, GET(2),  0xc4ac5665, 23)

// Round 4
    STEP(I, a, b, c, d, GET(0),  0xf4292244,  6)
    STEP(I, d, a, b, c, GET(7),  0x432aff97, 10)
    STEP(I, c, d, a, b, GET(14), 0xab9423a7, 15)
    STEP(I, b, c, d, a, GET(5),  0xfc93a039, 21)
    STEP(I, a, b, c, d, GET(12), 0x655b59c3,  6)
    STEP(I, d, a, b, c, GET(3),  0x8f0ccc92, 10)
    STEP(I, c, d, a, b, GET(10), 0xffeff47d, 15)
    STEP(I, b, c, d, a, GET(1),  0x85845dd1, 21)
    STEP(I, a, b, c, d, GET(8),  0x6fa87e4f,  6)
    STEP(I, d, a, b, c, GET(15), 0xfe2ce6e0, 10)
    STEP(I, c, d, a, b, GET(6),  0xa3014314, 15)
    STEP(I, b, c, d, a, GET(13), 0x4e0811a1, 21)
    STEP(I, a, b, c, d, GET(4),  0xf7537e82,  6)
    STEP(I, d, a, b, c, GET(11), 0xbd3af235, 10)
    STEP(I, c, d, a, b, GET(2),  0x2ad7d2bb, 15)
    STEP(I, b, c, d, a, GET(9),  0xeb86d391, 21)

    a += saved_a;
    b += saved_b;
    c += saved_c;
    d += saved_d;

    ptr += 64;
  } while (size -= 64);

  ctx->a = a;
  ctx->b = b;
  ctx->c = c;
  ctx->d = d;

  return ptr;
}

void MD5_Update(MD5_CTX *ctx, uchar_T *data, mwSize size)
{
  uint32_T saved_lo;
  mwSize   used, free;

  // Update number of bytes:
  saved_lo = ctx->lo;
  if ((ctx->lo = (saved_lo + size) & 0x1fffffff) < saved_lo) {
    ctx->hi++;
  }
  ctx->hi += (uint32_T) (size >> 29);

  // Process blocks with less than 64 bytes:
  used = (saved_lo & 0x3f);
  if (used) {
    free = 64 - used;
    if (size < free) {
      memcpy(&ctx->buffer[used], data, size);
      return;
    }

    memcpy(&ctx->buffer[used], data, free);
    data  = data + free;
    size -= free;
    MD5_Body(ctx, ctx->buffer, 64);
  }
  
  // Process the rest of the data in 64 byte blocks:
  if (size >= 64) {
    data  = MD5_Body(ctx, data, size & ~(mwSize)0x3f);
    size &= 0x3f;
  }
  
  // Copy remaining bytes to the buffer:
  memcpy(ctx->buffer, data, size);
}

void MD5_Final(uchar_T *result, MD5_CTX *ctx)
{
  mwSize used, free;

  // Padding:
  used = ctx->lo & 0x3f;
  ctx->buffer[used++] = 0x80;
  free = 64 - used;
  if (free < 8) {
    memset(&ctx->buffer[used], 0, free);
    MD5_Body(ctx, ctx->buffer, 64);
    used = 0;
    free = 64;
  }
  
  memset(&ctx->buffer[used], 0, free - 8);
  
  // Encode number of bits:
  ctx->lo       <<= 3;
  ctx->buffer[56] = ctx->lo;
  ctx->buffer[57] = ctx->lo >> 8;
  ctx->buffer[58] = ctx->lo >> 16;
  ctx->buffer[59] = ctx->lo >> 24;
  ctx->buffer[60] = ctx->hi;
  ctx->buffer[61] = ctx->hi >> 8;
  ctx->buffer[62] = ctx->hi >> 16;
  ctx->buffer[63] = ctx->hi >> 24;

  MD5_Body(ctx, ctx->buffer, 64);
  
  // Copy hash to the output:
  result[0]  = ctx->a;
  result[1]  = ctx->a >> 8;
  result[2]  = ctx->a >> 16;
  result[3]  = ctx->a >> 24;
  result[4]  = ctx->b;
  result[5]  = ctx->b >> 8;
  result[6]  = ctx->b >> 16;
  result[7]  = ctx->b >> 24;
  result[8]  = ctx->c;
  result[9]  = ctx->c >> 8;
  result[10] = ctx->c >> 16;
  result[11] = ctx->c >> 24;
  result[12] = ctx->d;
  result[13] = ctx->d >> 8;
  result[14] = ctx->d >> 16;
  result[15] = ctx->d >> 24;
  
  // Clean up sensitive data:
  memset(ctx, 0, sizeof(*ctx));
}

// *****************************************************************************
// ** Matlab part:
// *****************************************************************************

// 8Bit ASCII part of CHAR: ====================================================
void ProcessChar(mxChar *array, mwSize inputLen, uchar_T digest[16])
{
  // Process string: Matlab stores strings as mxChar, which are 2 bytes per
  // character. This function considers the first byte of each CHAR only, which
  // is equivalent to calculate the sum after a conversion to a ASCII uchar_T
  // string.
  MD5_CTX context;
  mwSize  Chunk;
  uchar_T *bufferP, *bufferEnd = buffer + BUFFER_LEN, *arrayP;
  
  arrayP = (uchar_T *) array;  // uchar_T *, not mxChar *!
  
  MD5_Init(&context);
  
  // Copy chunks of input data - only the first byte of each mxChar:
  Chunk = inputLen / BUFFER_LEN;
  while (Chunk--) {
     bufferP = buffer;
     while (bufferP < bufferEnd) {
        *bufferP++ = *arrayP;
        arrayP    += 2;
     }
     
     MD5_Update(&context, buffer, (mwSize) BUFFER_LEN);
  }
  
  // Last chunk:
  Chunk = inputLen % BUFFER_LEN;
  if (Chunk != 0) {
     bufferEnd = buffer + Chunk;
     bufferP   = buffer;
     while (bufferP < bufferEnd) {
        *bufferP++ = *arrayP;
        arrayP    += 2;
     }
     
     MD5_Update(&context, buffer, Chunk);
  }
  
  MD5_Final(digest, &context);
}

// Array of any type: ==========================================================
void ProcessArray(const mxArray *V, uchar_T digest[16])
{
  // The type, dimension and contents of the array are considered. This works
  // for cells and structs also.
  // Here only the initialization and finalization of the context is performed,
  // while the actual processing is done in ArrayCore, which allows recursion
  // for cells and structs.
  MD5_CTX context;

  RecursionCount = 0;  // Reset global recursion counter
  
  MD5_Init(&context);
  ArrayCore(&context, V);
  MD5_Final(digest, &context);
}

// -----------------------------------------------------------------------------
void ArrayCore(MD5_CTX *context, const mxArray *V)
{
  // Process an array considering the type and dimensions. Cells and Structs
  // call this function recursively for each cell element or field.
  // The header before the data block is: [ClassName, nDim, Dims]. The ClassName
  // is a string, because the ClassID number has been changed during different
  // Matlab versions in the past.
  // Sparse arrays, function handles, java- and user-defined classes are
  // forwarded to the M-function GetMD5_helper, where the user can defined how
  // the data is converted to a byte stream.
  
  uchar_T      *dataReal, *dataImag;
  mxClassID    ClassID;
  const mwSize *Dim, nullDim[2] = {0,0};
  mwSize       nDim, nElem, iElem, i, lenHeader;
  int64_T      *header;
  size_t       ElemSize, Len;
  int          nField, iField, ok;
  mxArray      *Arg[1];
  const char   *FieldName, *ClassName;
          
  // Get header information of the array:
  if (V != NULL) {
     nDim      = mxGetNumberOfDimensions(V);
     nElem     = mxGetNumberOfElements(V);
     ClassID   = mxGetClassID(V);
     ClassName = mxGetClassName(V);
     ElemSize  = mxGetElementSize(V);
     Dim       = mxGetDimensions(V);
     dataReal  = (uchar_T *) mxGetData(V);
     dataImag  = (uchar_T *) mxGetImagData(V);
     
  } else {  // NULL pointer is equivalent to [0 x 0] double matrix:
     nDim      = 2;
     nElem     = 0;
     ClassID   = mxDOUBLE_CLASS;
     ClassName = "double";
     ElemSize  = sizeof(double);
     Dim       = nullDim;
     dataReal  = (uchar_T *) NULL;
     dataImag  = (uchar_T *) NULL;
  }
  
  // Consider class as name, not as ClassID, because the later might change with
  // the Matlab version:
  Len = strlen(ClassName);
  MD5_Update(context, (uchar_T *) ClassName, Len * sizeof(char));
  
  // Encode dimensions as [nDim, Dim]:
  // Convert values to int64_T to get the same hash under 32 and 64 bit systems:
  lenHeader = 1 + nDim;
  header    = (int64_T *) mxCalloc(lenHeader, sizeof(int64_T));
  header[0] = (int64_T) nDim;
  for (i = 0; i < nDim; i++) {
     header[i + 1] = (int64_T) Dim[i];
  }
  MD5_Update(context, (uchar_T *) header, lenHeader * sizeof(int64_T));
  mxFree(header);
  
  // Forward sparse arrays to M-helper function:
  if (mxIsSparse(V)) {
     ClassID = mxUNKNOWN_CLASS;
  }
  
  // Include the contents of the array:
  switch (ClassID) {
     case mxLOGICAL_CLASS:   // Elementary array: ------------------------------
     case mxCHAR_CLASS:
     case mxDOUBLE_CLASS:
     case mxSINGLE_CLASS:
     case mxINT8_CLASS:
     case mxUINT8_CLASS:
     case mxINT16_CLASS:
     case mxUINT16_CLASS:
     case mxINT32_CLASS:
     case mxUINT32_CLASS:
     case mxINT64_CLASS:
     case mxUINT64_CLASS:
        MD5_Update(context, dataReal, nElem * ElemSize);
        if (mxIsComplex(V)) {
           MD5_Update(context, dataImag, nElem * ElemSize);
        }
        break;
        
     case mxCELL_CLASS:    // Cell array - recursion: --------------------------
        for (iElem = 0; iElem < nElem; iElem++) {
           ArrayCore(context, mxGetCell(V, iElem));
        }
        break;
        
     case mxSTRUCT_CLASS:  // Struct array: Fieldnames + recursion: ------------
        StructCore(context, V, nElem);
        break;
        
     default:  // mxFUNCTION_CLASS, mxVOID_CLASS, mxUNKNOWN_CLASS: -------------
        // Treat deep recursion as an error:
        if (++RecursionCount > MAX_RECURSION) {
           ERROR("DeepRecursion", "Cannot serialize recursive data type.\n"
                 "Try:  GetMD5(getByteStreamFromArray(Data))");
        }
                
        // Call the M-helper function to be more flexible:
        ok = mexCallMATLAB(1, Arg, 1, &V, "GetMD5_helper");
        if (ok != 0) {
           ERROR("HelperFailed", "Calling GetMD5_helper failed.");
        }
        
        // Get hash for array replied by the helper:
        ArrayCore(context, Arg[0]);
        
        // Clean up:
        if (Arg[0] != NULL) {
           mxDestroyArray(Arg[0]);
        }
  }
}

// Core function to process structs: ===========================================
void StructCore(MD5_CTX *context, const mxArray *V, mwSize nElem)
{
  // Sort field names alphabetically to avoid effects of teh order of fields.
  const char *FieldName;
  int        nField, iField, FieldIndex;
  mwSize     iElem;
  size_t     FieldNameLen;
  StringRec  *FieldList;
          
  // Create list of field names and a handle array, which points to this list.
  // Then sorting the handles allows to get the sorting index:
  nField    = mxGetNumberOfFields(V);
  FieldList = (StringRec *) mxMalloc(nField * sizeof(StringRec));
  for (iField = 0; iField < nField; iField++) {
     FieldList[iField].string = mxGetFieldNameByNumber(V, iField);
     FieldList[iField].index  = iField;
  }
  
  // Sort the strings:
  // (Sorting must not be stable, because the fieldnames are unique)
  qsort(FieldList, nField, sizeof(StringRec), CompareStringRec);
  
  // Loop over fields:
  for (iField = 0; iField < nField; iField++) {
     // Encode field name:
     FieldName    = FieldList[iField].string;
     FieldIndex   = FieldList[iField].index;
     FieldNameLen = STRING_LENGTH(FieldName, 63);
     MD5_Update(context, (uchar_T *) FieldName, FieldNameLen);
     
     // Loop over struct array:
     for (iElem = 0; iElem < nElem; iElem++) {
        ArrayCore(context, mxGetFieldByNumber(V, iElem, FieldIndex));
     }
  }
  
  // Release memory:
  mxFree(FieldList);
}

// Comparison for qsort(): =====================================================
int CompareStringRec(const void *va, const void *vb)
{
   const StringRec *a = (const StringRec *)va,
                   *b = (const StringRec *)vb;
   return strcmp(a->string, b->string);
}

// Elementary array as byte stream: ============================================
void ProcessBin(uchar_T *array, mwSize inputLen, uchar_T digest[16])
{
  // Only the contents of the array is considered. Therefore double(0) and
  // single([0,0]) reply the same hash. This works for numeric, char and logical
  // arrays only, neitehr cells nor structs.
  MD5_CTX context;
  
  MD5_Init(&context);
  MD5_Update(&context, array, inputLen);
  MD5_Final(digest, &context);
}

// File as byte stream: ========================================================
void ProcessFile(char *filename, uchar_T digest[16])
{
  FILE    *FID;
  MD5_CTX context;
  mwSize  len;
  
  // Open the file in binary mode:
  if ((FID = fopen(filename, "rb")) == NULL) {
     ERROR3("MissFile", "Cannot open file: [%s]", filename);
  }
  
  MD5_Init(&context);
  while ((len = fread(buffer, 1, BUFFER_LEN, FID)) != 0) {
     MD5_Update(&context, buffer, len);
  }
  MD5_Final(digest, &context);

  fclose(FID);
}

// Output of 16 uchar_Ts as 32 character hexadecimals: ===========================
void ToHex(const uchar_T digest[16], char *output, int LowerCase)
{
  char *outputEnd, *Fmt;
  const uchar_T *s = digest;
  
  Fmt = LowerCase ? "%02x" : "%02X";
  
  for (outputEnd = output + 32; output < outputEnd; output += 2) {
     sprintf(output, Fmt, *(s++));
  }
}

// BASE64 encoded output: ======================================================
void ToBase64(const uchar_T In[16], char *Out)
{
   // The base64 encoded string is shorter than the hex string.
   // Needed length: ((len + 2) / 3 * 4) + 1, here fixed to 22+1 (trailing 0!).
   static const uchar_T B64[] =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

   int   i;
   char  *p;
   const uchar_T *s;
   
   p = Out;
   s = In;
   for (i = 0; i < 5; i++) {
      *p++ = B64[(*s >> 2) & 0x3F];
      *p++ = B64[((*s & 0x3) << 4)   | ((s[1] & 0xF0) >> 4)];
      *p++ = B64[((s[1] & 0xF) << 2) | ((s[2] & 0xC0) >> 6)];
      *p++ = B64[s[2] & 0x3F];
      s   += 3;
   }
   
   *p++ = B64[(*s >> 2) & 0x3F];
   *p++ = B64[((*s & 0x3) << 4)];
   *p   = '\0';
}

// Main function: ==============================================================
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  // Mex interface:
  // - Define default values of optional arguments.
  // - Forward input data to different calculators according to the input type.
  // - Convert digest to output format.
  
  char     *FileName, outString[33];
  uchar_T  digest[16], *digestP, OutType = 'h';
  double   *outP, *outEnd;
  Method_t Method = BINARY_m;
  mwSize   nByte;
  
  // Check number of inputs and outputs: ---------------------------------------
  if (nrhs == 0 || nrhs > 3) {
     ERROR("BadNInput", "1 to 3 inputs required.");
  }
  if (nlhs > 1) {
     ERROR("BadNOutput", "Too many output arguments.");
  }
  
  // Check type of inputs:
  if (mxIsChar(prhs[0])) {
     Method = ASCII_m;  // Default for CHAR arrays
  }
  
  // Evaluate 1st character of 2nd input:
  if (nrhs >= 2 && mxGetNumberOfElements(prhs[1]) > 0) {
     if (mxIsChar(prhs[1]) == 0) {
        ERROR("BadTypeInput2", "2nd input [Method] must be a string.");
     }
     
     switch (*(uchar_T *) mxGetData(prhs[1])) {
        case '8':
           if (!mxIsChar(prhs[0])) {
              WARN("NoASCII", "ASCII Mode ignored: Data is no CHAR.");
              Method = BINARY_m;
           }
           break;
        case 'b':
        case 'B':  Method = BINARY_m;  break;
        case 'a':
        case 'A':  Method = ARRAY_m;   break;
        case 'f':
        case 'F':  Method = FILE_m;    break;
        default:   ERROR("BadInput2", "Mode not recognized.");
     }
  }
  
  // Output type - default: hex:
  if (nrhs == 3 && !mxIsEmpty(prhs[2])) {
     if (mxIsChar(prhs[2]) == 0) {
        ERROR("BadTypeInput3", "3rd input must be a string.");
     }
     
     OutType = *(uchar_T *) mxGetData(prhs[2]);  // Just 1st character
  }
  
  // Calculate check sum: ------------------------------------------------------
  switch (Method) {
     case FILE_m:    // Input is a file name:
        if ((FileName = mxArrayToString(prhs[0])) == NULL) {
           ERROR("StringFail", "Cannot get file name as string.");
        }
        ProcessFile(FileName, digest);
        mxFree(FileName);
        break;
  
     case ARRAY_m:   // Type, dimensions and contents of the array:
        ProcessArray(prhs[0], digest);
        break;
     
     case ASCII_m:   // Consider ASCII part of 16-bit mxChar only:
        ProcessChar((mxChar *) mxGetData(prhs[0]),
                    mxGetNumberOfElements(prhs[0]), digest);
        break;
     
     case BINARY_m:  // Contents of the variable:
        if (!(mxIsNumeric(prhs[0]) || mxIsChar(prhs[0]) || mxIsLogical(prhs[0]))
             || mxIsComplex(prhs[0]) || mxIsSparse(prhs[0])) {
           ERROR("BadDataType",
               "Binary mode requires: non-sparse, real, numeric or CHAR data.");
        }
        nByte = mxGetNumberOfElements(prhs[0]) * mxGetElementSize(prhs[0]);
        ProcessBin((uchar_T *) mxGetData(prhs[0]), nByte, digest);
        break;
     
     default:
        ERROR("BadSwitch", "Programming error: Unknown switch case?!");
  }
  
  // Create output: ------------------------------------------------------------
  switch (OutType) {
     case 'H':
     case 'h':  // Hexadecimal upper/lower case:
        ToHex(digest, outString, OutType == 'h');
        plhs[0] = mxCreateString(outString);
        break;
        
     case 'D':
     case 'd':  // DOUBLE with integer values:
        plhs[0] = mxCreateDoubleMatrix(1, 16, mxREAL);
        outP    = mxGetPr(plhs[0]);
        digestP = digest;
        for (outEnd = outP + 16; outP < outEnd; outP++) {
           *outP = (double) *digestP++;
        }
        break;
        
     case 'B':
     case 'b':  // Base64:
        ToBase64(digest, outString);            // Locally implemented
        plhs[0] = mxCreateString(outString);
        break;
        
     case 'U':
     case 'u':  // UINT8:
        plhs[0] = mxCreateNumericMatrix(1, 16, mxUINT8_CLASS, mxREAL);
        memcpy(mxGetData(plhs[0]), digest, 16 * sizeof(uchar_T));
        break;
        
     default:
        ERROR("BadOutputType", "Unknown output type.");
  }
  
  return;
}
