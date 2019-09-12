/**
 * Copyright 2009 B. Schauerte. All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions are 
 * met:
 * 
 *    1. Redistributions of source code must retain the above copyright 
 *       notice, this list of conditions and the following disclaimer.
 * 
 *    2. Redistributions in binary form must reproduce the above copyright 
 *       notice, this list of conditions and the following disclaimer in 
 *       the documentation and/or other materials provided with the 
 *       distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY B. SCHAUERTE ''AS IS'' AND ANY EXPRESS OR 
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
 * DISCLAIMED. IN NO EVENT SHALL B. SCHAUERTE OR CONTRIBUTORS BE LIABLE 
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
 * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *  
 * The views and conclusions contained in the software and documentation
 * are those of the authors and should not be interpreted as representing 
 * official policies, either expressed or implied, of B. Schauerte.
 */

/**
 * chi_square_statistics_fast
 *
 * Fast C/C++ calculation of the chi-square statistics (compatible with pdist).
 * (cf. "The Earth Movers' Distance as a Metric for Image Retrieval",
 *       Y. Rubner, C. Tomasi, L.J. Guibas, 2000)
 *
 * @author: B. Schauerte
 * @date:   2009
 * @url:    http://cvhci.anthropomatik.kit.edu/~bschauer/
 */
#include "mex.h"

#define SQR(x) ((x)*(x))

void
mexFunction (int nlhs, mxArray* plhs[], 
	int nrhs, const mxArray* prhs[])
{
  mwSize i = 0, j = 0; /* variables for for-loops */
  
  /* Check number of input parameters */
	if (nrhs != 2) 
  {
  	mexErrMsgTxt("Two inputs required.");
  } 
  else 
		if (nlhs > 1) 
	  {
  		mexErrMsgTxt("Wrong number of output arguments.");
	  }    

  /* Check type of input parameters */
	if (!mxIsDouble(prhs[0]) || !mxIsDouble(prhs[1])) 
		mexErrMsgTxt("Input should be double.\n");
	
	/* Input data */
	const mxArray* XI = prhs[0];
	const mxArray* XJ = prhs[1];
	const double* XI_data = mxGetPr(XI);
	const double* XJ_data = mxGetPr(XJ);
	/* some helper variables */
	const mwSize m = mxGetM(XJ); /* number of samples of p */
  const mwSize p = mxGetN(XI); /* dimension of samples */
	if (p != mxGetN(XJ)) 
		mexErrMsgTxt("Dimension mismatch (1).\n");
	if (1 != mxGetM(XI)) 
		mexErrMsgTxt("Dimension mismatch. XI has to be an (1,n) vector.\n");
	/* Output data */
	mxArray* OUT = mxCreateNumericMatrix (m, 1, mxDOUBLE_CLASS, mxREAL);
	plhs[0] = OUT;
	double* out_data = mxGetPr(OUT);
	
	for (i = 0; i < m; i++) /* initialize output array */
		out_data[i] = 0;

	for (j = 0; j < p; j++)
	{
		const double xi = XI_data[j];
		for (i = 0; i < m; i++)
		{
			const double mean = (xi + *XJ_data++) / 2.0;
			if (mean != 0)
				out_data[i] += SQR(xi - mean) / mean;
		}
	}
	
	return;
}
