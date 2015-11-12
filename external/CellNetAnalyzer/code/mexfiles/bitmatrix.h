#include "mex.h"

#define MALLOC mxMalloc
#define FREE mxFree


typedef unsigned char byte;
#define byteBits 8
#define intBits (sizeof(int)*byteBits)
#define intBytes (sizeof(int)/sizeof(byte))

#define NOSUBSET 0x0
#define ASUBSET  0x1
#define BSUBSET  0x2
#define ROWEQUAL 0x3

typedef struct {
    int rowWidth;
    int width;
    int height;
    mxArray* mMatrix;
    unsigned int *bits;
}BitMatrix;

extern void calcAddr(int *x, int *y, int *mask);
extern void orLastBits(BitMatrix *m, int x, int y,register int bits);
extern void setBit(BitMatrix *m, int x, int y);
extern void delBit(BitMatrix *m,int x,int y);
extern int getBit(BitMatrix *m,int x,int y);
extern void printBitRow(BitMatrix *m,int y);
extern BitMatrix* makeBitMatrix(int width,int height);
extern BitMatrix* wrapMatlabMatrix(mxArray *AMMatrix,int width,int height);
extern void destroyBitMatrix(BitMatrix *m);
extern mxArray* unWrapMatlabMatrix(BitMatrix *m);
extern int rowSubsetCheck(int* a,int* b,int width);
extern void checkRows(BitMatrix *m,int *remain,int old);
extern void preCheckRows(int old,BitMatrix *zeros,BitMatrix *newzeros,
			 int *remain);

extern BitMatrix* uint8ToBitMatrix(BitMatrix *m,const mxArray *zeroplaces);
extern BitMatrix* doubleToBitMatrix(BitMatrix *m,mxArray *zeroplaces);
extern BitMatrix* toBitMatrix(BitMatrix *m,mxArray *zeroplaces);
extern mxArray* getMatlabMatrix(BitMatrix *m);
extern int* countRowZeros(BitMatrix *m,int *res);
