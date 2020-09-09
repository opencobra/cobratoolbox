#include <stdio.h>
#include <mpfr.h>
#include "gmp.h"
#include <string.h>
#include "mex.h"



void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
  double *num,*prec,*eout;
  int     mrows,ncols;
  char *input_buf;
  int   buflen,status;
  mpfr_t x;
  mp_exp_t expptr;


/*   This function accepts two arguments: */
/*     1) a scalar double which becomes the mp number */
/*     2) a precision */

  /* Check for proper number of arguments. */
  if(nrhs!=2) {
    mexErrMsgTxt("Two inputs required.");
  } else if(nlhs>2) {
    mexErrMsgTxt("Too many output arguments");
  }
  
  
  /* Set precision and initialize mpfr variables */
  prec = mxGetPr(prhs[1]);
  mpfr_set_default_prec(*prec);
  mpfr_init(x);

  mrows = mxGetM(prhs[1]);
  ncols = mxGetN(prhs[1]);
  if( !mxIsDouble(prhs[1]) || mxIsComplex(prhs[1]) ||
      !(mrows==1 && ncols==1) ) {
    mexErrMsgTxt("Input 2 must be a noncomplex scalar double.");
  }

  buflen = (mxGetM(prhs[0]) * mxGetN(prhs[0])) + 1;
  input_buf=mxCalloc(buflen, sizeof(char));
  status = mxGetString(prhs[0], input_buf, buflen);
  mpfr_set_str(x,input_buf,10,GMP_RNDN);
    
  /* Retrieve results */
  mxFree(input_buf);
  input_buf=mpfr_get_str (NULL, &expptr, 10, 0, x, GMP_RNDN);
  plhs[0] = mxCreateString(input_buf);
  plhs[1] = mxCreateDoubleMatrix(mrows,ncols, mxREAL);
  eout=mxGetPr(plhs[1]);
  *eout=expptr;
  

  mpfr_clear(x);
  mpfr_free_str(input_buf);
}
