#include "bitmatrix.h"
#include "mex.h"

void preCheckRows3(int old,BitMatrix *zeros,BitMatrix *newzeros,
		  int *remain){
/* 
   Checks the first `old' rows of zeros against the rows of newzeros,
   if zeros contains the newzeros. remain is a pattern of rows in newzeros,
   that remain. 
   Before this a check of the newzeros against each other is performed.
   No rows of old must be checked. So rowSubsetCheckSimple is used for this 
   task. rowWidth of both matrices must be the same.
*/
    int i,j,j1,rows,rowRes,rowWidth,size,full,numout;
    rows=newzeros->height;
    for(i=0;i<rows;i++)
	remain[i]=1+i;
    rowWidth=newzeros->rowWidth;
/* New-only check */
    for(i=0;i<rows;i++)
	if(remain[i]){
      	    for(j=i+1;j<rows;j++){   
		if(remain[j]){
		    rowRes=rowSubsetCheck(&(newzeros->bits[i*rowWidth]),
					  &(newzeros->bits[j*rowWidth]),
					  rowWidth);
		    if((rowRes & BSUBSET)!=0){
			remain[i]=0;
			/*break*/
			/* Dont break here, its slower !*/
		    }else if((rowRes & ASUBSET)!=0){
			remain[j]=0;
		    }
		}
	    }
	}
    /* Compress newzeros */


/* New vs old check */
    for(j=0;j<rows;j++){  
	 numout=0;
	 i=0;
	 while(remain[j] && i<zeros->height && numout<3){ 
		numout+=rowSubsetCheckSimple(&(zeros->bits[i*rowWidth]),
					&(newzeros->bits[j*rowWidth]),
					rowWidth);
   	 	i++;
			
	 }
	 
	 if(numout>2)
	 	remain[j]=0;
    }

}



/* returns remaining elmodes as logical map (0/1) in an uint8 mxArray*/
void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[]) {

    mxArray *oldmodes, *zeroplaces,*newzeroplaces;
    int old,height,i,j;
    mxArray * remain=NULL,*helperle;
    int *res=NULL,*res2=NULL;
    BitMatrix *zeros=NULL,*newzeros=NULL;

    if (nlhs != 1) {
          mexErrMsgTxt("Run-time Error: The function \"elmodes_precheck3_c\" was called with more or less than the declared number of outputs (2).");
    }
    if (nrhs != 3) {
          mexErrMsgTxt(
            "Run-time Error: The function \"elmodes_precheck3_c\" was called with m ore or less than the declared number of inputs (3).");
    }


    oldmodes=prhs[0];
    zeroplaces=prhs[1];
    newzeroplaces=prhs[2];

    /* BOC */
    old=(double) *mxGetPr(oldmodes);
    zeros=wrapMatlabMatrix(zeroplaces,-1,old);/*zeroplaces is larger than needed*/
    newzeros=wrapMatlabMatrix(newzeroplaces,-1,-1);

    height=newzeros->height;
    helperle=mxCreateNumericMatrix(1,height,mxINT32_CLASS,mxREAL);
    res=(int*)mxGetPr(helperle);
    preCheckRows3(old,zeros,newzeros,res);
    unWrapMatlabMatrix(zeros);
    unWrapMatlabMatrix(newzeros);

    j=0;
    for(i=0;i<height;i++)
	if(res[i]){
		res[j]=i+1;
		j++;
	}

    remain=mxCreateNumericMatrix(1,j,mxINT32_CLASS,mxREAL);
    res2=(int*)mxGetPr(remain);

    for(i=0;i<j;i++)
	res2[i]=res[i];

    mxDestroyArray(helperle);
    plhs[0]=remain;
}


