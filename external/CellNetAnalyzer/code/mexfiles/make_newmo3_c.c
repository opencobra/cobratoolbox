#define ABS(a) (((a) < 0) ? -(a) : (a))
#define MALLOC mxMalloc
#define FREE mxFree
#include "mex.h"


double* calcFactors(double *tableaut,int *xv,int *yv,int numLines,int numCols){
    /* Calculates the factors for the linear combinations
       therfore factors (returned pointer) is allocated.
       Elements for the calculation are directly taken from tableaut.
       numLines is needed for address calculation.
     */
    double *factors=MALLOC(sizeof(double)*numCols);
    int k;
    for(k=0;k<numCols;k++){
	factors[k]=
	    /* Matlab indices start from 1, therefore -1 here */
	    tableaut[(xv[k]-1)*numLines]/
	    tableaut[(yv[k]-1)*numLines];
    };
    return factors;
}

/* Something similar to a gaussian combination of columns in
   mTableaut: Pivot-line is i, mXv and mYv contain column-indices of
   columns to combine.  For each pair xv[k] yv[k] either xv or yv are
   pointing to the pivot-column, regarding on the characteristics of
   the reaction (not/reversible) epsilon is used as a threshold to
   detect values that are numerically zero.  The places of this
   variables are stored in zeropl in the same layout as in
   newmo. Numeric zeros are explicitly set to 0.0.  */
void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[]) {

    const mxArray * mTableaut, *mXv, *mYv,*mEpsilon;
    int
	/* number of columns in result */
	cols,
	/* number of lines in result */
	lines,
	/* iteration index for columns to combine */
	j,
	/* iteration index for lines */
	k,
	/* C Array pointer to Matlab int array with columnindices */
	*xv,
	/* C Array pointer to Matlab int array with columnindices */
	*yv;
    double 
	/* C Array pointer to Matlab double array with result */
	*newmo,
	/* Array of factors for the linear combination */
	*factors, 
	/* C Array pointer to Matlab double array with input matrix */
	*tableaut,
	/* C Array pointer to Matlab double array with line at tableaut[xv[k]][] */
	*cxv,
	/* C Array pointer to Matlab double array with line at tableaut[yv[k]][] */
	*cyv, 
	/* C Array pointer to Matlab double array with line at newmodes[k][] */
	*cnm,
	/* C double fetched from mEpsilon */
	eps,
	/* Absolute value of the currently calculated value */
	abs,
	/* Maximum norm for one column in the result */
	norm;
    unsigned char 
	/* C Array pointer to Matlab uint8 array mZeropl (result) */
	*zeropl=NULL,
	/* C Array pointer to Matlab uint8 array with line at zeropl[k][] */
	*czp;
    /* Matlab Return value: Matrix lines x cols */
    mxArray *mNewmo=NULL;


    if (nlhs != 1) {
          mexErrMsgTxt("Run-time Error: File: to_bits_c Line: 1 Column: 1 The function \"to_bits_c\" was called with more or less than the declared number of outputs (1).");
    }
    if (nrhs != 4) {
          mexErrMsgTxt(
            "Run-time Error: File: to_bits_c Line: 1 Column: 1 The function \"to_bits_c\" was called with m ore or less than the declared number of inputs (4).");
    }

    mTableaut=prhs[0];
    mXv=prhs[1];
    mYv=prhs[2];
    mEpsilon=prhs[3];

    /* Zeilenzahl ist gegeben mit Spalten von xv */
    cols=mxGetN(mXv);
    /* Spaltenzahl ist gegeben mit Zeilen des tableaut == spalten von tableau */
    lines=mxGetM(mTableaut);;

    /* Create and assign return values */
    mNewmo=mxCreateNumericMatrix(lines,cols,mxDOUBLE_CLASS,mxREAL);

    if( cols==0 || lines==0 )
    {
    /* Bail out if one of the dimensions is 0 */
	plhs[0]=mNewmo; 
	return;
    }

    /* Cast all stuff into normal C arrays */
    tableaut=(double*)mxGetPr(mTableaut);
    xv=(int*)mxGetPr(mXv);
    yv=(int*)mxGetPr(mYv);
    newmo=(double*)mxGetPr(mNewmo);
    eps=*((double*)mxGetPr(mEpsilon));

    /* create factors vector for linear combination */
    factors=calcFactors(tableaut,xv,yv,lines,cols);
    for(k=0;k<cols;k++){
	/* Save Pointers to all columns, this saves index calc time during inner loop 
	   Matlab indices start from 1, therfore we decrement here, to reach the C form.
	 */
	cxv=&(tableaut[(xv[k]-1)*lines]);
	cyv=&(tableaut[(yv[k]-1)*lines]);
	cnm=&(newmo[k*lines]);
	czp=&(zeropl[k*lines]);
	norm=0.0;
	for(j=0;j<lines;j++){
	    /* Linear combination: tableaut(:,xv(k))-factors(k).*tableaut(:,yv[k]) */
	    cnm[j]=cxv[j]-(factors[k] * cyv[j]);
	    abs=ABS(cnm[j]);
	    if(abs>norm){
		norm=abs;
	    }
	}
        if(norm>eps){
		for(j=lines-1;j>=0;j--){
	   	 /* Normalization backwards because of caching */
	   	 cnm[j]=cnm[j]/norm;
	    	/* Zero detection */
		}
	}
    }
    /*mlfPrintMatrix(mNewmo);*/
    /* Free array allocated in calcFactors */
    FREE(factors);

    plhs[0]=mNewmo; 

}

