#include <stdio.h>
#include <mpfr.h>
#include "gmp.h"
#include "mex.h"
#include <string.h>


void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
  double *prec,*eoutr,*eouti;
  int     mrows,ncols;
  char *input_buf;
  char *w1,*w2;
  int   buflen,status;
  mpfr_t xr,xi,yr,yi,zr,zi,temp,temp1;
  mp_exp_t expptr;
  
  /* Check for proper number of arguments. */
  if(nrhs!=5) {
    mexErrMsgTxt("5 inputs required.");
  } else if(nlhs>4) {
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
  mpfr_init(xr);  mpfr_init(xi);  
  mpfr_init(yr);  mpfr_init(yi);  
  mpfr_init(zr);  mpfr_init(zi);  
  mpfr_init(temp);  mpfr_init(temp1);
  
  /* Read the input strings into mpfr x real */
  buflen = (mxGetM(prhs[1]) * mxGetN(prhs[1])) + 1;
  input_buf=mxCalloc(buflen, sizeof(char));
  status = mxGetString(prhs[1], input_buf, buflen);
  mpfr_set_str(xr,input_buf,10,GMP_RNDN);
  /* Read the input strings into mpfr x imag */
  buflen = (mxGetM(prhs[2]) * mxGetN(prhs[2])) + 1;
  input_buf=mxCalloc(buflen, sizeof(char));
  status = mxGetString(prhs[2], input_buf, buflen);
  mpfr_set_str(xi,input_buf,10,GMP_RNDN);
  
  /* Read the input strings into mpfr y real */
  buflen = (mxGetM(prhs[3]) * mxGetN(prhs[3])) + 1;
  input_buf=mxCalloc(buflen, sizeof(char));
  status = mxGetString(prhs[3], input_buf, buflen);
  mpfr_set_str(yr,input_buf,10,GMP_RNDN);
  /* Read the input strings into mpfr y imag */
  buflen = (mxGetM(prhs[4]) * mxGetN(prhs[4])) + 1;
  input_buf=mxCalloc(buflen, sizeof(char));
  status = mxGetString(prhs[4], input_buf, buflen);
  mpfr_set_str(yi,input_buf,10,GMP_RNDN);
  
  
  /* Mathematical operation */
  /* denominator */
  mpfr_mul(temp,yr,yr,GMP_RNDN);
  mpfr_mul(temp1,yi,yi,GMP_RNDN);
  mpfr_add(temp,temp,temp1,GMP_RNDN);
  /* real part */
  mpfr_mul(temp1,xr,yr,GMP_RNDN);
  mpfr_mul(zr,xi,yi,GMP_RNDN);
  mpfr_add(zr,temp1,zr,GMP_RNDN);
  /* imag part */
  mpfr_mul(temp1,xi,yr,GMP_RNDN);
  mpfr_mul(zi,xr,yi,GMP_RNDN);
  mpfr_sub(zi,temp1,zi,GMP_RNDN);  
  /* divide by denominator */
  mpfr_div(zr,zr,temp,GMP_RNDN);  
  mpfr_div(zi,zi,temp,GMP_RNDN);  

  /* Retrieve results */
  mxFree(input_buf);
  input_buf=mpfr_get_str (NULL, &expptr, 10, 0, zr, GMP_RNDN);
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
/*   eoutr=mxGetPr(plhs[1]); */
/*   *eoutr=expptr; */

  mpfr_free_str(input_buf);
  input_buf=mpfr_get_str (NULL, &expptr, 10, 0, zi, GMP_RNDN);
  free(w1);
  free(w2);
  w1=malloc(strlen(input_buf)+20);
  w2=malloc(strlen(input_buf)+20);
  if (strncmp(input_buf, "-", 1)==0){
    strcpy(w2,&input_buf[1]);
    sprintf(w1,"-.%se%i",w2,expptr);
  } else {
    strcpy(w2,&input_buf[0]);
    sprintf(w1,"+.%se%i",w2,expptr);
  }
  plhs[1] = mxCreateString(w1);
/*   plhs[3] = mxCreateDoubleMatrix(mrows,ncols, mxREAL); */
/*   eouti=mxGetPr(plhs[3]); */
/*   *eouti=expptr; */
  

  mpfr_clear(xr);  mpfr_clear(xi);
  mpfr_clear(yr);  mpfr_clear(yi);
  mpfr_clear(zr);  mpfr_clear(zi);
  mpfr_clear(temp);  mpfr_clear(temp1);
  mpfr_free_str(input_buf);
  free(w1);
  free(w2);
}

