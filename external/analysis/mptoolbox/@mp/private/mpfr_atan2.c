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
  if(nrhs!=3) {
    mexErrMsgTxt("two inputs required.");
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

  /* Mathematical operation */
  mpfr_atan2(z,x,y,GMP_RNDN);
  
  /* Retrieve results */
  mxFree(input_buf);
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
  

  mpfr_clear(x);
  mpfr_clear(y);
  mpfr_clear(z);
  mpfr_free_str(input_buf);
  free(w1);
  free(w2);
}




/* #include <stdio.h> */
/* #include <mpfr.h> */
/* #include "gmp.h" */
/* #include "mex.h" */

/* void mpfr_atan2 (mpfr_t zi, mpfr_t xi, mpfr_t xr, mp_prec_t prec) */
/* { */

/*   mpfr_div(zi,xi,xr,GMP_RNDN); */
/*   mpfr_atan(zi,zi,GMP_RNDN); */
/*   if( mpfr_sgn(xr)<0 ) { */
/*     mpfr_const_pi(xr,GMP_RNDN); */
/*     if(mpfr_sgn(xi)>0) { */
/*       mpfr_add(zi,zi,xr,GMP_RNDN); */
/*     } else { */
/*       mpfr_sub(zi,zi,xr,GMP_RNDN); */
/*     } */
/*   } */
/* } */
