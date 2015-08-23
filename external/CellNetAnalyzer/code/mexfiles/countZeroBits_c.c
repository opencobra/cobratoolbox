#include "bitmatrix.h"
#include "mex.h"

/*
  binmat is a bitmatrix, numrows gives the number of valid bitrows contained.
  (its format is a number of full 32 bit rows, last row is not completely used).
  countBits should count the 0-Bits in the columns of the matrix and return 
  them as a doublematrix.
 */

void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[]) {
    int *res=NULL;
    mxArray *zeros=NULL;
    mxArray *binmat=NULL,*numrows=NULL;
    BitMatrix *m=NULL;

    if (nlhs != 1) {
          mexErrMsgTxt("Run-time Error: The function \"countZeros_c\" was called with more or less than the declared number of outputs (1).");
    }
    if (nrhs != 2) {
          mexErrMsgTxt(
            "Run-time Error: The function \"countZeros_c\" was called with m ore or less than the declared number of inputs (2).");
    }

    binmat=prhs[0];
    numrows=prhs[1];
    m=wrapMatlabMatrix(binmat,(double)*mxGetPr(numrows),-1);

    zeros=mxCreateNumericMatrix(1,m->height,mxUINT32_CLASS,mxREAL);
    res=(int*)mxGetPr(zeros);
    countRowZeros(m,res);
    unWrapMatlabMatrix(m);

    plhs[0] = zeros;
}

