
#include "bitmatrix.h"
#include "mex.h"


void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[]) {
    const mxArray *byteMatrix;
    int i, width, height;
    BitMatrix *m=NULL;

    if (nlhs != 1) {
          mexErrMsgTxt("Run-time Error: File: to_bits_c Line: 1 Column: 1 The function \"to_bits_c\" was called with more or less than the declared number of outputs (1).");
    }
    if (nrhs != 1) {
          mexErrMsgTxt(
            "Run-time Error: File: to_bits_c Line: 1 Column: 1 The function \"to_bits_c\" was called with m ore or less than the declared number of inputs (1).");
    }
    byteMatrix=prhs[0];
    width=mxGetM(byteMatrix);
    height=mxGetN(byteMatrix);

    /* Create a new BitMatrix wrapping a Matlab uint32 */
    m=makeBitMatrix(width,height);
    /* Fill the Bytes into the bits */
    uint8ToBitMatrix(m,byteMatrix);
    /* Assign the return value */
    plhs[0]=getMatlabMatrix(m);
    /* Throw away m but */
    unWrapMatlabMatrix(m);
}

