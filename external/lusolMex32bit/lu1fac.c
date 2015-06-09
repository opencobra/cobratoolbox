/* lu1fac.c : written by M. J. O'Sullivan 20.1.99
This is a CMEX file that calls LU1FAC, a sparse LU factorization written in 
FORTRAN by Mike Saunders (MS). The MATLAB call is

[L, U, p, q, luparm, parmlu] = lu1fac(A, luparm, parmlu)

where A is a sparse MATLAB matrix, luparm and parmlu are LU
settings, L and U are the sparse factors, and p and q are the row
and column permutation vectors, respectively. 

07 Jul 2005: Seems to work well on rectangular matrices!

*/



#define INTEGER int

#include <string.h>
#include "mex.h"

/* Function prototype for MSVC to call LU1FAC fortran subroutine
   void _stdcall lu1fac(INTEGER * m, INTEGER * n, INTEGER * nelem, INTEGER * lena,
                        INTEGER luparm[30], double parmlu[30],
                        double * a, INTEGER * indc, INTEGER * indr, INTEGER * ip, INTEGER * iq,
                        INTEGER * lenc, INTEGER * lenr, INTEGER * locc, INTEGER * locr,
                        INTEGER * iploc, INTEGER * iqloc, INTEGER * ipinv, INTEGER * iqinv,
                        double * w, INTEGER * inform);
*/

/* Function prototype for the sorting function */
void sort(unsigned long n, int arr[], double val[]);

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

  /* Inputs for LU1FAC */
  INTEGER m, n, nelem, lena;
  INTEGER luparm[30];
  double  parmlu[30], *a, *w;
  INTEGER *indc, *indr, *ip, *iq, *lenc, *lenr, *iploc, *iqloc, *ipinv, *iqinv;
  INTEGER *locc, *locr;
  INTEGER inform;

  /* Local variables */
  mxArray *mp;
  double  *pr;
  int     *cnt, col, i, *inz, *ir, j, *jc, k, k1, l, l1, len, nz, start, stop;

  if (nrhs == 3) {

    m  = mxGetM(prhs[0]);
    n  = mxGetN(prhs[0]);
    pr = mxGetPr(prhs[0]);
    ir = mxGetIr(prhs[0]);
    jc = mxGetJc(prhs[0]);

    nelem = *(jc + n);
    /* mexPrintf("The matrix has dimensions (%d, %d), and %d elements.\n",
       m, n, nelem); */

    /* lena > max(2 * nelem, 10 * m, 10 * n, 500000) */
    lena = 1000000;
    if (lena < 10 * nelem) lena = 10 * nelem;
    /*lena = 500000;
    if (lena <  2 * nelem) lena = 2 * nelem;*/
    if (lena < 10 * m    ) lena = 10 * m;
    if (lena < 10 * n    ) lena = 10 * n;
    lena = lena + 1;
    /* mexPrintf("The length of a is %d.\n", lena); */

    /* Allocate all the LU1FAC arrays */
    a     = (double  *)calloc(lena, sizeof(double ));
    indc  = (INTEGER *)calloc(lena, sizeof(INTEGER));
    indr  = (INTEGER *)calloc(lena, sizeof(INTEGER));
    ip    = (INTEGER *)calloc(m   , sizeof(INTEGER));
    iq    = (INTEGER *)calloc(n   , sizeof(INTEGER));
    
    lenc  = (INTEGER *)calloc(n   , sizeof(INTEGER));
    lenr  = (INTEGER *)calloc(m   , sizeof(INTEGER));
    locc  = (INTEGER *)calloc(n   , sizeof(INTEGER));
    locr  = (INTEGER *)calloc(m   , sizeof(INTEGER));
    
    iploc = (INTEGER *)calloc(n   , sizeof(INTEGER));
    iqloc = (INTEGER *)calloc(m   , sizeof(INTEGER));
    ipinv = (INTEGER *)calloc(m   , sizeof(INTEGER));
    iqinv = (INTEGER *)calloc(n   , sizeof(INTEGER));
    w     = (double  *)calloc(n   , sizeof(double ));

    /* Check if the allocations were successful */
    if (a && indc && indr && ip && iq && lenc && lenr && locc && locr &&
	iploc && iqloc && ipinv && iqinv && w) {

      /* Read the MATLAB matrix   into the LU1FAC arrays */
      memcpy(a, (double *)pr, nelem * sizeof(double));
      nz = 0;
      for (i = 0; i < n; i++) {
	start = jc[i];
	stop  = jc[i + 1];
	if (start != stop)
	  for (j = start; j < stop; j++) {
	    indc[nz] = ir[j] + 1;
	    indr[nz] = i + 1;
	    nz++;
	  }
      }

      /* Extract luparm and parmlu */
      pr = mxGetPr(prhs[1]);
      for (i = 0; i < 30; i++)
	luparm[i] = (INTEGER)pr[i];

      pr = mxGetPr(prhs[2]);
      memcpy(parmlu, (double *)pr, 30 * sizeof(double));

      /* mexPrintf("Calling   MINOS lu1fac.\n");*/
      /* Call lu1fac */
      /* For MSVC, the above function prototype is needed,
         and the trailing _ must be deleted. */
      lu1fac_(&m, &n, &nelem, &lena, luparm, parmlu,
	      a, indc, indr, ip, iq,
	      lenc, lenr, locc, locr,
	      iploc, iqloc, ipinv, iqinv, w, &inform);

      if (inform <= 1) {

	if (luparm[7] > 0) {
	  /* Extract L from a, diagonal is 1 (omitted from a)
	     and there are luparm[20] non-zeros in a for luparm[20] + m
	     non-zeros in total */
	  mp = mxCreateSparse(m, m, luparm[20] + m, mxREAL);
	  pr = mxGetPr(mp);
	  ir = mxGetIr(mp);
	  jc = mxGetJc(mp);
	  jc[0] = 0;
	  for (k = 1; k <= m; k++) {
	    /* Add the one on the diagonal */
	    jc[k] = jc[k - 1] + 1;
	    pr[jc[k] - 1] = 1.0;
	    ir[jc[k] - 1] = k - 1;
	    /* Start at the first initial column */
	    k1 = 0;
	    /* Move to the first element in that column */
	    l1 = lena - lenc[k1];
	    /* While still looking at initial columns and
	       the (permuted) initial column is not the current column */
	    while ( (k1 < luparm[19]) && (k != indr[l1]) )
	      /* Shift to the next initial column,
	         then move to the first element of that column */
	      l1 -= lenc[++k1];
	    if (k1 < luparm[19]) {
	      /* The column is one of the initial columns */
	      for (i=0; i<lenc[k1]; i++) {/* Loop over the elements in this column */
		jc[k]++; /* Increase the number of elements in the Matlab column */
		pr[jc[k] - 1] = -a[l1 + i];
		ir[jc[k] - 1] = indc[l1 + i] - 1;
	      }
	    } else {
	      /* The column is in the remaining a */
	      l1--; /* Move to the first remaining a element */
	      for (i=0; i<luparm[22]-luparm[20]; i++) {
		/* Check if this element belongs to the column */
		if (k == indr[l1]) {
		  jc[k]++; /* Increase the number of elements in the Matlab column */
		  pr[jc[k]] = -a[l1];
		  ir[jc[k]] = indc[l1] - 1;
		}
	      }
	    }
	    /* Numerical recipes quicksort sorts arr[1..n], so pass the
	       address of the element before the start of the array
	       - MJKO. 02-03-99    */
	    sort(jc[k] - jc[k - 1], &ir[jc[k - 1] - 1], &pr[jc[k - 1] - 1]);
	  }
	  /* Replace the current L with the new one */
	  mxDestroyArray(plhs[0]);
	  plhs[0] = mp;

	  /* Extract U from a */
	  mp  = mxCreateSparse(m, n, luparm[21], mxREAL);
	  pr  = mxGetPr(mp);
	  ir  = mxGetIr(mp);
	  jc  = mxGetJc(mp);
	  inz = (int *)calloc(m, sizeof(int));
	  if (!inz) mexErrMsgTxt("Couldn't allocate memory");
	  jc[0] = 0;
	  for (k = 0; k < luparm[15]; k++) {
	    i   = ip[k];
	    inz[i - 1] = 1;
	    for (j = locr[i - 1]; j < (locr[i - 1] + lenr[i - 1]); j++)
	      jc[indr[j - 1]]++;
	  }
	  for (k = 0; k < n; k++) jc[k + 1] += jc[k];

	  cnt = (int *)calloc(n, sizeof(int));
	  if (!cnt) mexErrMsgTxt("Couldn't allocate memory");
	  for (k = 0; k < m; k++)
	    if (inz[k]) {
	      for (j = locr[k]; j < (locr[k] + lenr[k]); j++) {
		col = indr[j - 1] - 1;
		pr[jc[col] + cnt[col]] = a[j - 1];
		ir[jc[col] + cnt[col]++] = k;
	      }
	    }
	  /* Replace the current U with the new one */
	  mxDestroyArray(plhs[1]);
	  plhs[1] = mp;
	  /* Free temporary pointers */
	  free((void *)inz);
	  free((void *)cnt);
	} /* End if keepLU */

	mp = mxCreateDoubleMatrix(1, m, mxREAL); /* Extract p */
	pr = mxGetPr(mp);
	for (i = 0; i < m; i++)
	  pr[i] = ip[i];
	/* Replace the current matrix with the new one */
	mxDestroyArray(plhs[2]);
	plhs[2] = mp;

	mp = mxCreateDoubleMatrix(1, n, mxREAL); /* Extract q */
	pr = mxGetPr(mp);
	for (i = 0; i < n; i++)
	  pr[i] = iq[i];
	/* Replace the current matrix with the new one */
	mxDestroyArray(plhs[3]);
	plhs[3] = mp;

	mp = mxCreateDoubleMatrix(1, 30, mxREAL); /* Return luparm */
	pr = mxGetPr(mp);
	for (i = 0; i < 30; i++)
	  pr[i] = (double)luparm[i];
	/* Replace the current matrix with the new one */
	mxDestroyArray(plhs[4]);
	plhs[4] = mp;

	mp = mxCreateDoubleMatrix(1, 30, mxREAL); /* Return parmlu */
	pr = mxGetPr(mp);
	memcpy(pr, (double *)parmlu, 30 * sizeof(double));
	/* Replace the current matrix with the new one */
	mxDestroyArray(plhs[5]);
	plhs[5] = mp;

      }
      else {
	mexPrintf("Inform returned from lu1fac = %d.\n", inform);
	if (inform == 7)
	  mexPrintf("Minimum value for lena   should be %d.\n", luparm[12]);
	mexErrMsgTxt("LU1FAC returned a error");
      }
    }
    else mexErrMsgTxt("Couldn't allocate memory");

    /* Free all the LU1FAC variables */
    free((void *)a);
    free((void *)indc);
    free((void *)indr);
    free((void *)ip);
    free((void *)iq);
    free((void *)lenc);
    free((void *)lenr);
    free((void *)locc);
    free((void *)locr);
    free((void *)iploc);
    free((void *)iqloc);
    free((void *)ipinv);
    free((void *)iqinv);
    free((void *)w);
  }
  else mexErrMsgTxt("Invalid number of inputs");

} /* End of lu1fac mex-function */
