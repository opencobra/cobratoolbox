#include "bitmatrix.h"
#include <string.h>


/* converts address given in x y  to x y mask, where x is reduced to 
   new x and mask */
void calcAddr(int *x, int *y, int *mask){
    *mask=1<<(*x%intBits);
    *x/=intBits;
}
/* assumes a bunch of bytes in `bits', which are 0 or 1,
   or's the set bits into the position x, y */
void orLastBits(BitMatrix *m, int x, int y,register int bits){
    register int res;
    /* Adjust to position of x in a byte unusual */
/*      printf("%d %d %d\n",x,y,m->bits[y][x]); */
    res=bits&0x000000ff;
    bits>>=byteBits-1;
    res|=bits&0x000000ff;
    bits>>=byteBits-1;
    res|=bits&0x000000ff;
    bits>>=byteBits-1;
    res|=bits&0x000000ff;
    /* Adjust to position in the dword */
    res<<=x%intBits;
    x/=intBits;
    m->bits[y*m->rowWidth+x]|=res;
/*      printf("%d %d %d\n",x,y,m->bits[y][x]); */
}

/* sets bit at x,y to 1 */
void setBit(BitMatrix *m, int x, int y){
    int mask=0;
    calcAddr(&x,&y,&mask);
    m->bits[y*m->rowWidth+x]|=mask;
    /*printf("%d %d %d\n",x,y,m->bits[y][x]);*/
}
/* sets bit at x,y in m to 0 */
void delBit(BitMatrix *m,int x,int y){
    int mask=0;
    calcAddr(&x,&y,&mask);
    m->bits[y*m->rowWidth+x]&=(~mask);
}
/* gets bit at x,y in m */
int getBit(BitMatrix *m,int x,int y){
    int mask=0;
    calcAddr(&x,&y,&mask);
    /*printf("%d %d %d",x,y,m->bits[y][x]);*/
    return (m->bits[y*m->rowWidth+x]&mask)!=0;
}

/* simple printing for debugging purposes */
void printBitRow(BitMatrix *m,int y){
    int x;
    for(x=0;x<m->width;x++){
	printf("%01d ",getBit(m,x,y));
    }
    printf("\n");
}


/* Checks the bitrows a and b for susetness 
   returns a result, `or'ed from the constants 
NOSUBSET
ASUBSET
BSUBSET
ROWEQUAL
*/
int rowSubsetCheck(int* a,int* b,int width){
    int i,
	asub,bsub,abAnd;
    asub=bsub=1;
    for(i=0;i<width;i++){
	/* Find common bits in both rows */
	abAnd=(a[i]&b[i]);
	/* Check if the rows are still equal to the common bits (subset) */
	asub&=(abAnd==a[i]);
	bsub&=(abAnd==b[i]);
	/* If both checks are negative, we can skip the rest */
	if(!(asub||bsub))
	    break;
    }
    /*
    if((asub||bsub)){
	printf("%08x\n%08x\n",a[i-1],b[i-1]);
	printf("%08x\n",abAnd);
	printf("%02x\n\n",(asub*ASUBSET)|(bsub*BSUBSET));
    }
    */
    return (asub*ASUBSET)|(bsub*BSUBSET);
}
int rowSubsetCheckSimple(int* a,int* b,int width){
    int i,asub=1;
    for(i=0;i<width;i++){
	/* Find common bits in both rows */
	asub&=((a[i]&b[i])==a[i]);
	if(!asub) break;
    }
    return asub;
}

void checkRows(BitMatrix *m,int *remain,int old){
/* Checks the rows of m if they contain each other.
   This is the case if one row is equal to a bitwise `and'
   with another row. Then the other row is deleted.
   Tests are performed bidirectional: Both lines may be
   removed as a result of the test.
   First Test step is to check new modes against new modes
   (i,j=oldmodes..newmodes). Second step is to check the 
   remaining new modes against the old ones.
   The result is delivered in *remain which is a byte array with 0 or 1.
*/
    int i,j,rows,rowRes,rowWidth;
    rows=m->height;
    rowWidth=m->rowWidth;
    for(i=0;i<rows;i++)
	remain[i]=1;
/* New-only check */
    for(i=old;i<rows;i++)
	if(remain[i]){
      	    for(j=i+1;j<rows;j++){   
		if(remain[j]){
		    rowRes=rowSubsetCheck(&(m->bits[i*rowWidth]),
					  &(m->bits[j*rowWidth]),
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
/* New vs old check */
    for(i=0;i<old;i++)
/*  	if(remain[i]){ */
    	    for(j=old;j<rows;j++){  
		if(remain[j]){
		    rowRes=rowSubsetCheck(&(m->bits[i*rowWidth]),
					  &(m->bits[j*rowWidth]),
					  rowWidth);
/* order of <if> and <elseif> changed by Steffen */ 
		    if((rowRes&ASUBSET)!=0){
			remain[j]=0;
		    } else if((rowRes&BSUBSET)!=0){
			remain[i]=0;
			/*break*/
			/* Dont break here, its slower !*/
		    }
/* end of change */
		}
	    }
/*  	} */
}
void preCheckRows(int old,BitMatrix *zeros,BitMatrix *newzeros,
		  int *remain){
/* 
   Checks the first `old' rows of zeros against the rows of newzeros,
   if zeros contains the newzeros. remain is a pattern of rows in newzeros,
   that remain. 
   Before this a check of the newzeros against each other is performed.
   No rows of old must be checked. So rowSubsetCheckSimple is used for this 
   task. rowWidth of both matrices must be the same.
*/
    int i,j,j1,rows,rowRes,rowWidth,size,full;
    rows=newzeros->height;
    /*
    for(i=0;i<rows;i++)
	remain[i]=1;
    */
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
    size=0;full=0;
    for(j=rows-1;j>=0;j--){
	/*printf("%d\n",remain[j]);*/
	if(!remain[j]){
	    if((!full)&&size) full=j+1;
	}else{
	    if(full){
		/*printf("moving mem %d <- %d : %d %d\n",j+1,full,size,rows);*/
		memmove(&(remain[j+1]),&(remain[full]),size*sizeof(int));
		memmove(&(newzeros->bits[(j+1)*rowWidth]),
			&(newzeros->bits[full*rowWidth]),
			size*sizeof(int)*rowWidth);
		full=0;
	    }
	    size++;
	}}
    if(full){
	/*printf("moving mem %d <- %d : %d %d\n",0,full,size,rows);*/
	memmove(&(remain[0]),&(remain[full]),size*sizeof(int));
	memmove(&(newzeros->bits[0]),
		&(newzeros->bits[full*rowWidth]),
		size*sizeof(int)*rowWidth);
	full=0;
    }
/* New vs old check */
    for(i=0;i<zeros->height;i++)
/*  	if(remain[i]){ */
    	    for(j=0;j<size;j++){  
		if(remain[j] && 
		   rowSubsetCheckSimple(&(zeros->bits[i*rowWidth]),
					&(newzeros->bits[j*rowWidth]),
					rowWidth))
		/*
		if(rowSubsetCheckSimple(&(zeros->bits[i*rowWidth]),
					&(newzeros->bits[j*rowWidth]),
					rowWidth))
		*/		
		remain[j]=0;

	    }
/*  	} */
    if(size==rows) return;
    memset(&(remain[size]),0,sizeof(int)*(rows-size));
    for(j=size-1;j>=0;j--){
	if(remain[j]) {
	    /*printf("%d ",remain[j]-1);*/
	    full=remain[j]-1;
	    remain[j]=0;
	    remain[full]=1;
	}
    }
}

BitMatrix* uint8ToBitMatrix(BitMatrix *m,const mxArray *zeroplaces){
/* Converts a matlab uint8 byte matrix into a uint32 bit matrix
 by sucessively grabbing 4 bytes and converting the possible 1s with
 the function orLastBits() which does some bitshifting.
 The result is written into a linearily seeming array of a matlab-matrix.
*/
    int i,j,intsOnLine,width;
    byte *zmatrix=(byte*)mxGetPr(zeroplaces);
    /* reduce to a mutiple of 4 */
    intsOnLine=(m->width/4)*4;
    width=m->width;
    for(j=0;j<m->height;j++){
	/* Do most of the line with steps of 4 */
	for(i=0;i<intsOnLine;i+=4)
	    orLastBits(m,i,j,*((int*)(zmatrix+j*width+i)));
	/* Do the last (at most) 3 bytes */
	for(;i<m->width;i++){
	    if(zmatrix[j*width+i]==1)
		setBit(m,i,j);
	}
/*    	printBitRow(m,j);printf("\n"); */
    };
    return m;
}
BitMatrix* doubleToBitMatrix(BitMatrix *m,mxArray *zeroplaces){
/*
  Converts a matlab double matrix to bits in 32 bit integers.
  uses matlab mlf-Accessors, but is very slow.
 */
    int i,j,width;
    double zeroPlace;
    width=m->width;

    for(j=0;j<m->height;j++){
	for(i=0;i<width;i++){
	    zeroPlace= ((double*)mxGetPr(zeroplaces))[j*width+i];
	    /*printf("%f ",*(double*)mxGetPr(zeroPlace));*/
	    if(zeroPlace==1.0){
		setBit(m,i,j);
	    }
	    /*printf("%01d ",getBit(m,i,j));*/
	};
	/*printf("\n");*/
    };
    return m;
}

BitMatrix* toBitMatrix(BitMatrix *m,mxArray *zeroplaces){
/*
  Dispatcher for converting matlab matrices to bitmatrix.
  Calls the two functions above, depending on the type of
  matlab matrix
 */
    if(mxIsUint8(zeroplaces)){
	/*printf("using bytes\n");*/
	return uint8ToBitMatrix(m,zeroplaces);
    }else{
	/*printf("using doubles\n");*/
	return doubleToBitMatrix(m,zeroplaces);
    }
}

mxArray* getMatlabMatrix(BitMatrix *m){
    /*Returns the matlab-data that contains the data of m*/
    return m->mMatrix;
}

BitMatrix* allocBitMatrix(int width,int height){
    /*Allocates only the data structure for the bitmatrix structure,
      without the space needed for the bits.
     */
    BitMatrix* m=MALLOC(sizeof(BitMatrix));
    m->width=width;
    m->height=height;
    m->rowWidth=(width/intBits);
    if(width%intBits)
	m->rowWidth++;
    return m;
}

void deallocBitMatrix(BitMatrix *m){
    /*Frees only the bitmatrix structure of m, not the matlabmatrix*/
    FREE(m);
}

BitMatrix* makeBitMatrix(int width,int height){
    /*Allocates a bitMatrix and the according matlab matrix storage for the 
      bits*/
    BitMatrix* m=allocBitMatrix(width,height);
    m->mMatrix=mxCreateNumericMatrix(m->rowWidth,height,mxUINT32_CLASS,mxREAL);
    m->bits=(int*)mxGetPr(m->mMatrix);
    return m;
}

void destroyBitMatrix(BitMatrix *m){
    /*Frees the bitmatrix completely*/
    mxDestroyArray(m->mMatrix);
    deallocBitMatrix(m);
}

mxArray* unWrapMatlabMatrix(BitMatrix *m){
    /*frees the wrapping bitmatrix and returns the matlab data storage of 
      the bits*/
    mxArray *ret=getMatlabMatrix(m);
    deallocBitMatrix(m);
    return ret;
}

BitMatrix* wrapMatlabMatrix(mxArray *AMMatrix,int width,int height){
    /*allocates a bitmatrix wrapping structure for AMMatrix which is a
     matlab matrix containing the bits. height may contain the number of 
    bits that are really in each row of the matrix. If height is -1 then the 
    size of the matlab matrix is used.*/
    mxArray *dim=NULL;
    double *dimPr=NULL;
    BitMatrix *m=NULL;
    if(width==-1)
	width=mxGetM(AMMatrix)*intBits;
    if(height==-1)
	height=mxGetN(AMMatrix);
    m=allocBitMatrix(width,height);
    m->mMatrix=AMMatrix;
    m->bits=(int*)mxGetPr(m->mMatrix);
    return m;
}

static int bitsTab[256]={
0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4,
3, 4, 4, 5, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 4, 5, 5, 6, 5, 6, 6, 7, 5, 6, 6, 7, 6, 7, 7, 8
};



int numBits(int word){
    int i,res=0,mask=1;
    for(i=0;i<intBits;i++){
	res+=word&mask;
	word>>=1;
    }
    return res;
}

void initBitsTab(){
    int i;
    for(i=0;i<256;i++){
	bitsTab[i]=numBits(i);
	printf("%d, ",bitsTab[i]);
    }
}

int countBitsRow(int *row,int rowWidth){
    static unsigned int mask=0x000000ff;
    int field;
    int i,res=0;
    /*
    int j;
    */
    for(i=0;i<rowWidth;i++){
	field=row[i];
	res+=bitsTab[field&mask];
	field>>=8;
	res+=bitsTab[field&mask];
	field>>=8;
	res+=bitsTab[field&mask];
	field>>=8;
	res+=bitsTab[field&mask];
	/*
	  Slower!
	for(j=intBits;j>=0;j--){
	    res+=field&1;field>>=1;
	}
	*/
    }
    return res;
}

int *countRowZeros(BitMatrix *m,int* res){
    int i,ir=0,rowWidth;
    if(res == NULL)
       res=MALLOC(sizeof(int)*m->height);
    rowWidth=m->rowWidth;
    /*initBitsTab();*/
    for(i=0;i<m->height;i++){
	/*printBitRow(m,i);*/
	res[i]=m->width-countBitsRow(&m->bits[ir],rowWidth);
	/*printf("%d ",m->bits[ir]);*/
	ir+=rowWidth;
    }
    return res;
}
