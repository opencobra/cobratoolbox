#include <stdio.h>
#include <mpfr.h>
#include "gmp.h"
#include "mex.h"


void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
  double *prec,*eout;
  int     mrows,ncols;
  char *input_buf;
  int   buflen,status;
  mpfr_t x,y,z;
  mp_exp_t expptr;

  /* Check for proper number of arguments. */
  if(nrhs!=3) {
    mexErrMsgTxt("Three inputs required.");
  } else if(nlhs>1) {
    mexErrMsgTxt("Too many output arguments");
  }
  
  /* The input must be a noncomplex scalar double.*/
  mrows = mxGetM(prhs[0]);
  ncols = mxGetN(prhs[0]);
  if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) ||
      !(mrows==1 && ncols==1) ) {
    mexErrMsgTxt("Input must be a noncomplex scalar double.");
  }

  /* Set precision and initialize mpfr variables */
  prec = mxGetPr(prhs[0]);
  mpfr_set_default_prec(*prec);
  mpfr_init(x);  mpfr_init(y);  mpfr_init(z);
  
  /* Read the input strings into mpfr x and y */
  buflen = (mxGetM(prhs[1]) * mxGetN(prhs[1])) + 1;
  input_buf=mxCalloc(buflen, sizeof(char));
  status = mxGetString(prhs[1], input_buf, buflen);
  mpfr_set_str(x,input_buf,10,GMP_RNDN);

  buflen = (mxGetM(prhs[2]) * mxGetN(prhs[2])) + 1;
  input_buf=mxCalloc(buflen, sizeof(char));
  status = mxGetString(prhs[2], input_buf, buflen);
  mpfr_set_str(y,input_buf,10,GMP_RNDN);
  
  
  /* Retrieve results */
  mxFree(input_buf);
  plhs[0] = mxCreateDoubleMatrix(mrows,ncols, mxREAL);
  eout=mxGetPr(plhs[0]);
  *eout=(double)mpfr_less_p(x,y);
  

  mpfr_clear(x);
  mpfr_clear(y);
  mpfr_clear(z);
}
