#include <stdio.h>
#include <mpfr.h>
#include "gmp.h"
#include "mex.h"
#include <string.h>


void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
  double *prec,*eout;
  int     mrows,ncols;
  char *input_buf;
  char *w1,*w2;
  int   buflen,status;
  mpfr_t x,y,z;
  mp_exp_t expptr;

  /* Check for proper number of arguments. */
  if(nrhs!=1) {
    mexErrMsgTxt("1 inputs required.");
  } else if(nlhs>2) {
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
  
  /* Mathematical operation */
  mpfr_const_pi(z,GMP_RNDN);
  
  /* Retrieve results */
  input_buf=mpfr_get_str (NULL, &expptr, 10, 0, z, GMP_RNDN);
  w1=malloc(strlen(input_buf)+20);
  w2=malloc(strlen(input_buf)+20);
  if (strncmp(input_buf, "-", 1)==0){
    strcpy(w2,&input_buf[1]);
    sprintf(w1,"-.%se%i",w2,expptr);
  } else {
    strcpy(w2,&input_buf[0]);
    sprintf(w1,"+.%se%i",w2,expptr);
  }
  plhs[0] = mxCreateString(w1);
/*   plhs[1] = mxCreateDoubleMatrix(mrows,ncols, mxREAL); */
/*   eout=mxGetPr(plhs[1]); */
/*   *eout=expptr; */
  

  mpfr_clear(x);
  mpfr_clear(y);
  mpfr_clear(z);
  mpfr_free_str(input_buf);
  free(w1);
  free(w2);
}

