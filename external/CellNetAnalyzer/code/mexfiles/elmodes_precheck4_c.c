#include "bitmatrix.h"
#include "mex.h"

void preCheckRows4(int old, int comblidx, double* combzidx,BitMatrix *zeros,BitMatrix *newzeros,
		  int *remain, char *oldfirst, char *newfirst){
/* 
   Checks the first `old' rows of zeros against the rows of newzeros,
   if zeros contains the newzeros. remain is a pattern of rows in newzeros,
   that remain. 
   Before this a check of the newzeros against each other is performed.
   No rows of old must be checked. So rowSubsetCheckSimple is used for this 
   task. rowWidth of both matrices must be the same.
*/
    int i,j,jf,jidx,jidx2,rows,rowRes,rowWidth,size,full,numout,numold;
    int counter=0;

    rows=newzeros->height;
    for(i=0;i<rows;i++)
	remain[i]=1+i;
    rowWidth=newzeros->rowWidth;
    numold=zeros->height;

/* New-only check */
    for(j=0;j<rows;j++)
	if(remain[j]){
	    jidx=j*rowWidth;
            for(i=j+1;i<rows;i++){
                if(remain[i]){
			if(remain[j]){
                    		rowRes=rowSubsetCheck(&(newzeros->bits[jidx]),
                                          &(newzeros->bits[i*rowWidth]),
                                          rowWidth);
		    		remain[i]=!(rowRes & ASUBSET);
                    		remain[j]=!(rowRes & BSUBSET);
			}
			else
                    	     remain[i]=!rowSubsetCheckSimple(&(newzeros->bits[jidx]),
                                          &(newzeros->bits[i*rowWidth]),rowWidth);
                }
            }
      	    if(remain[j]){
	 		i=-1;
	 		numout=0;
	 		jf=newfirst[j];
	 		jidx2=(int) (combzidx[j]-1);   

	 		while(++i<numold && (jf>oldfirst[i] || i==comblidx-1 || i==jidx2)); 

	 		while(i<numold && !numout){ 
				numout+=rowSubsetCheckSimple(&(zeros->bits[i*rowWidth]),&(newzeros->bits[jidx]),rowWidth);
	 			while(++i<numold && (jf>oldfirst[i] || i==comblidx-1 || i==jidx2)); 
 			}
			remain[j]=!numout;
      	   }

	}
}



/* returns remaining elmodes as logical map (0/1) in an uint8 mxArray*/
void mexFunction(int nlhs, mxArray * plhs[], int nrhs,const mxArray * prhs[]) {

    mxArray *oldmodes,*combl,*combz,*zeroplaces,*newzeroplaces,*oldfirst,*newfirst;
    int old,comblidx;
    double *combzidx; 
    char *noldfirst,*nnewfirst;
    mxArray * remain=NULL,*helperle;
    int i,j,*res=NULL,height,*res2;
    BitMatrix *zeros=NULL,*newzeros=NULL;

    oldmodes=prhs[0];
    combl=prhs[1];
    combz=prhs[2];
    zeroplaces=prhs[3];
    newzeroplaces=prhs[4];
    oldfirst=prhs[5];
    newfirst=prhs[6];


    if (nlhs != 1) {
          mexErrMsgTxt("Run-time Error: The function \"elmodes_precheck4_c\" was called with more or less than the declared number of outputs (2).");
    }
    if (nrhs != 7) {
          mexErrMsgTxt(
            "Run-time Error: The function \"elmodes_precheck4_c\" was called with m ore or less than the declared number of inputs (7).");
    }

    /* BOC */
    old=(double) *mxGetPr(oldmodes);
    comblidx=(double) *mxGetPr(combl); 
    combzidx=(double *) mxGetPr(combz); 
    noldfirst=(char *) mxGetPr(oldfirst);
    nnewfirst=(char *) mxGetPr(newfirst);
    zeros=wrapMatlabMatrix(zeroplaces,-1,old);/*zeroplaces is larger than needed*/
    newzeros=wrapMatlabMatrix(newzeroplaces,-1,-1);
    
    height=newzeros->height;
    helperle=mxCreateNumericMatrix(1,height,mxINT32_CLASS,mxREAL);
    res=(int*)mxGetPr(helperle);
    preCheckRows4(old,comblidx,combzidx,zeros,newzeros,res,noldfirst,nnewfirst);
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


