#include <stdio.h>
#include <mpfr.h>
#include "gmp.h"
#include <string.h>
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
    mexErrMsgTxt("Three input required.");
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
  
  /* Read the input strings into mpfr x and y */
  buflen = (mxGetM(prhs[1]) * mxGetN(prhs[1])) + 1;
  input_buf=mxCalloc(buflen, sizeof(char));
  status = mxGetString(prhs[1], input_buf, buflen);
  mpfr_set_str(x,input_buf,10,GMP_RNDN);
  buflen = (mxGetM(prhs[2]) * mxGetN(prhs[2])) + 1;
  input_buf=mxCalloc(buflen, sizeof(char));
  status = mxGetString(prhs[2], input_buf, buflen);
  mpfr_set_str(y,input_buf,10,GMP_RNDN);
  
  /* Mathematical operation */
  mpfr_mul(z,x,y,GMP_RNDN);
  
  /* Retrieve results */
  input_buf=mpfr_get_str (NULL, &expptr, 10, 0, z, GMP_RNDN);
  plhs[0] = mxCreateString(input_buf);
  plhs[1] = mxCreateDoubleMatrix(mrows,ncols, mxREAL);
  eout=mxGetPr(plhs[1]);
  *eout=expptr;
  

  mpfr_clear(x);
  mpfr_clear(y);
  mpfr_clear(z);


}
/* [ss1,ss2]=gmp_mult(x,s1,s2) */

/* mex gmp_mult.c -lmpfr -lgmp */
/* x=200,s1='023e1',s2='-.002e-1' */
/* [ss,y]=gmp_mult(x,s1,s2) */



/* void mexFunction( int nlhs, mxArray *plhs[], */
/*                   int nrhs, const mxArray *prhs[] ) */
/* { */
/*   double *x,*y; */
/*   int     mrows,ncols; */
/*   char *input_buf, *str1, *str2; */
/*   int   buflen,status; */
  
/*   /\* Check for proper number of arguments. *\/ */
/*   if(nrhs!=3) { */
/*     mexErrMsgTxt("Three input required."); */
/*   } else if(nlhs>3) { */
/*     mexErrMsgTxt("Too many output arguments"); */
/*   } */
  
/*   /\* The input must be a noncomplex scalar double.*\/ */
/*   mrows = mxGetM(prhs[0]); */
/*   ncols = mxGetN(prhs[0]); */
/*   if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) || */
/*       !(mrows==1 && ncols==1) ) { */
/*     mexErrMsgTxt("Input must be a noncomplex scalar double."); */
/*   } */

/*   buflen = (mxGetM(prhs[1]) * mxGetN(prhs[1])) + 1; */
/*   input_buf=mxCalloc(buflen, sizeof(char)); */
/*   str1=mxCalloc(buflen, sizeof(char)); */
/*   status = mxGetString(prhs[1], input_buf, buflen); */
/*   revord(input_buf, buflen, str1); */
/*   plhs[1] = mxCreateString(str1); */

/*   buflen = (mxGetM(prhs[2]) * mxGetN(prhs[2])) + 1; */
/*   input_buf=mxCalloc(buflen, sizeof(char)); */
/*   str2=mxCalloc(buflen, sizeof(char)); */
/*   status = mxGetString(prhs[2], input_buf, buflen); */
/*   revord(input_buf, buflen, str2); */
/*   plhs[2] = mxCreateString(str2); */

  
/*   /\* Create matrix for the return argument. *\/ */
/*   plhs[0] = mxCreateDoubleMatrix(mrows,ncols, mxREAL); */
  
/*   /\* Assign pointers to each input and output. *\/ */
/*   x = mxGetPr(prhs[0]); */
/*   y = mxGetPr(plhs[0]); */
  
/*   /\* Call the timestwo subroutine. *\/ */
/*   timestwo(y,x); */
/* } */
