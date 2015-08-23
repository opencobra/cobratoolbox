
#include "bitmatrix.h"
#include "mex.h"
#include <stdio.h>

void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[]) {
    mxArray *remain;
    const mxArray * tableau, *l, *idx,*numrows,*min0;

    mxArray *bitres=NULL,*helperle;
    BitMatrix *newzeros;
    int nl,height,width,i,j,vmin0,rowWidth,rowRes;
    double *nidx;
    int *nres,*ntableau,*cres,*cl,*ci;
    int *rem,*rem2;

    if (nlhs != 2) {
          mexErrMsgTxt("Run-time Error: The function \"elmodes_combine_c\" was called with more or less than the declared number of outputs (2).");
    }
    if (nrhs != 5) {
          mexErrMsgTxt(
            "Run-time Error: The function \"elmodes_combine_c\" was called with m ore or less than the declared number of inputs (5).");
    }

    tableau=prhs[0];
    l=prhs[1];
    idx=prhs[2];
    numrows=prhs[3];
    min0=prhs[4];

    height=mxGetM(tableau);
    width=mxGetN(idx);
    nidx=mxGetPr(idx);

    nl=*((double*)mxGetPr(l))-1;
    ntableau=(int*)mxGetPr(tableau);
    bitres=mxCreateNumericMatrix(height,width,mxUINT32_CLASS,mxREAL);
    nres=(int*)mxGetPr(bitres);

    cl=&ntableau[nl*height];
    for(i=0;i<width;i++){
      ci=&ntableau[((int)nidx[i]-1)*height];
      cres=&nres[i*height];
      for(j=0;j<height;j++){
        cres[j]=cl[j]|ci[j];
      }
    }
 
 /***** Finding out those with to less zeros *******/
  
    helperle=mxCreateNumericMatrix(1,width,mxINT32_CLASS,mxREAL);
    rem=(int*)mxGetPr(helperle);
    j=0;

    newzeros=wrapMatlabMatrix(bitres,(double)*mxGetPr(numrows),-1);
    vmin0=(int)*mxGetPr(min0);
    countRowZeros(newzeros,rem);
    for(i=0;i<width;i++)
	if(rem[i]>=vmin0){
      		rem[j]=i+1;
		j=j+1;
	}

    remain=mxCreateNumericMatrix(1,j,mxINT32_CLASS,mxREAL);
    rem2=(int*)mxGetPr(remain);
    for(i=0;i<j;i++)
	rem2[i]=rem[i];

    mxDestroyArray(helperle); 

    unWrapMatlabMatrix(newzeros);

    plhs[0] = bitres;
    plhs[1] = remain;
}


