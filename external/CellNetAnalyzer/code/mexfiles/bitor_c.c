#include <stdio.h>
#include "mex.h"

void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[]) {
    int nl,height,width,i,j;
    double *nidx;
    int *nres,*ntableau,*cres,*cl,*ci;
    mxArray *res=NULL;
    const mxArray *tableau,*l,*idx;

    if (nlhs != 1) {
          mexErrMsgTxt("Run-time Error: File: to_bits_c Line: 1 Column: 1 The function \"to_bits_c\" was called with more or less than the declared number of outputs (1).");
    }
    if (nrhs != 3) {
          mexErrMsgTxt(
            "Run-time Error: File: to_bits_c Line: 1 Column: 1 The function \"to_bits_c\" was called with m ore or less than the declared number of inputs (3).");
    }

    tableau=prhs[0];
    l=prhs[1];
    idx=prhs[2];

    height=mxGetM(tableau);;
    width=mxGetN(idx);;

    nidx=mxGetPr(idx);
    nl=*((double*)mxGetPr(l))-1;
    ntableau=(int*)mxGetPr(tableau);
    res=mxCreateNumericMatrix(height,width,mxUINT32_CLASS,mxREAL);
    nres=(int*)mxGetPr(res);

    cl=&ntableau[nl*height];
    for(i=0;i<width;i++){
      ci=&ntableau[((int)nidx[i]-1)*height];
      cres=&nres[i*height];
      for(j=0;j<height;j++){
        cres[j]=cl[j]|ci[j];
      }
    }

    plhs[0]=res;
}

