#include <math.h> /* Needed for the ceil() prototype */
#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Declare variable */
    mwSize m,n;
    mwSize nzmax;
    mwIndex *irs,*jcs,j,k;
    int cmplx,isfull;
    double *pr,*pi,*si,*sr;
    double percent_sparse;
    
    /* Check for proper number of input and output arguments */
    if (nrhs != 1) {
        mexErrMsgIdAndTxt( "MATLAB:invalidNumInputs", "One input argument required.");
    }
    if(nlhs > 1){
        mexErrMsgIdAndTxt( "MATLAB:maxlhs", "Too many output arguments.");
    }
    
    /* Check data type of input argument  */
    if (!(mxIsDouble(prhs[0]))){
        mexErrMsgIdAndTxt( "MATLAB:inputNotDouble", "Input argument must be of type double.");
    }
    
    /* Get the size and pointers to input data */
    m  = mxGetM(prhs[0]);
    n  = mxGetN(prhs[0]);
    
    if (n != 1){
        mexErrMsgIdAndTxt( "MATLAB:inputNot2D", "Input argument must be of size m x 1\n");
    }
    
    pr = mxGetPr(prhs[0]);
    pi = mxGetPi(prhs[0]);
    cmplx = (pi==NULL ? 0 : 1);
    nzmax = m;
    
    plhs[0] = mxCreateSparse(m,m,nzmax,cmplx);
    sr  = mxGetPr(plhs[0]);
    si  = mxGetPi(plhs[0]);
    irs = mxGetIr(plhs[0]);
    jcs = mxGetJc(plhs[0]);
    
    /* Copy nonzeros */
    k = 0;
    for (j=0; (j<m); j++)
    {
        mwSize i;
        jcs[j] = j;
        irs[j] = j;
        sr[j] = pr[j];
        if (cmplx){
            si[j]=pi[j];
        }
    }
    jcs[m] = m;
}
