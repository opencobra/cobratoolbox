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
  
  /* The input must be a noncomplex scalar double.*/
  mrows = mxGetM(prhs[0]);
  ncols = mxGetN(prhs[0]);
  if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) ||
      !(mrows==1 && ncols==1) ) {
    mexErrMsgTxt("Input 1 must be a noncomplex scalar double.");
  }

  mrows = mxGetM(prhs[1]);
  ncols = mxGetN(prhs[1]);
  if( !mxIsDouble(prhs[1]) || mxIsComplex(prhs[1]) ||
      !(mrows==1 && ncols==1) ) {
    mexErrMsgTxt("Input 2 must be a noncomplex scalar double.");
  }

  /* Set precision and initialize mpfr variables */
  prec = mxGetPr(prhs[1]);
  mpfr_set_default_prec(*prec);
  num = mxGetPr(prhs[0]);
  mpfr_init_set_d (x, *num, GMP_RNDN);
    
  /* Retrieve results */
  input_buf=mpfr_get_str (NULL, &expptr, 10, 0, x, GMP_RNDN);
  plhs[0] = mxCreateString(input_buf);
  plhs[1] = mxCreateDoubleMatrix(mrows,ncols, mxREAL);
  eout=mxGetPr(plhs[1]);
  *eout=expptr;
  

  mpfr_clear(x);
  mpfr_free_str(input_buf);
}




/* void mexFunction( int nlhs, mxArray *plhs[], */
/*                   int nrhs, const mxArray *prhs[] ) */
/* { */
/*   double *num,*prec,*eout; */
/*   int     mrows,ncols; */
/*   char *input_buf; */
/*   char *w1,*w2; */
/*   int   buflen,status; */
/*   mpfr_t x; */
/*   mp_exp_t expptr; */

/* /\*   This function accepts two arguments: *\/ */
/* /\*     1) a scalar double which becomes the mp number *\/ */
/* /\*     2) a precision *\/ */

/*   /\* Check for proper number of arguments. *\/ */
/*   if(nrhs!=2) { */
/*     mexErrMsgTxt("Two inputs required."); */
/*   } else if(nlhs>1) { */
/*     mexErrMsgTxt("Too many output arguments"); */
/*   } */
  
/*   /\* The input must be a noncomplex scalar double.*\/ */
/*   mrows = mxGetM(prhs[0]); */
/*   ncols = mxGetN(prhs[0]); */
/*   if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) || */
/*       !(mrows==1 && ncols==1) ) { */
/*     mexErrMsgTxt("Input 1 must be a noncomplex scalar double."); */
/*   } */

/*   mrows = mxGetM(prhs[1]); */
/*   ncols = mxGetN(prhs[1]); */
/*   if( !mxIsDouble(prhs[1]) || mxIsComplex(prhs[1]) || */
/*       !(mrows==1 && ncols==1) ) { */
/*     mexErrMsgTxt("Input 2 must be a noncomplex scalar double."); */
/*   } */

/*   /\* Set precision and initialize mpfr variables *\/ */
/*   prec = mxGetPr(prhs[1]); */
/*   mpfr_set_default_prec(*prec); */
/*   num = mxGetPr(prhs[0]); */
/*   mpfr_init_set_d (x, *num, GMP_RNDN); */
    
/*   /\* Retrieve results *\/ */
/*   input_buf=mpfr_get_str (NULL, &expptr, 10, 0, x, GMP_RNDN); */

/*   w1=malloc(strlen(input_buf)+20); */
/*   w2=malloc(strlen(input_buf)+20); */
/*   if (strncmp(input_buf, "-", 1)==0){ */
/*     strcpy(w2,&input_buf[1]); */
/*     sprintf(w1,"-.%se%i",w2,expptr); */
/*   } else { */
/*     strcpy(w2,&input_buf[0]); */
/*     sprintf(w1,"+.%se%i",w2,expptr); */
/*   } */
  
  
/*   plhs[0] = mxCreateString(w1); */
/*   /\* plhs[1] = mxCreateDoubleMatrix(mrows,ncols, mxREAL); *\/ */
/* /\*   eout=mxGetPr(plhs[1]); *\/ */
/* /\*   *eout=expptr; *\/ */
  

/*   mpfr_clear(x); */
/*   mpfr_free_str(input_buf); */
/*   free(w1); */
/*   free(w2); */
  
/* } */

