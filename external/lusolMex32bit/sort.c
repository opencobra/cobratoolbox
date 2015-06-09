#define NRANSI
#include "nrutil.h"
#define SWAP(a,b) temp=(a);(a)=(b);(b)=temp;
#define SWAPV(av,bv) tempv=(av);(av)=(bv);(bv)=tempv;
#define M 7
#define NSTACK 50

void sort(unsigned long n, int arr[], double val[])
{
	unsigned long i,ir=n,j,k,l=1;
	int jstack=0,*istack;
	int a,temp;
        double av,tempv;

	istack=ivector(1,NSTACK);
	for (;;) {
		if (ir-l < M) {
			for (j=l+1;j<=ir;j++) {
				a=arr[j];
				av=val[j]; 
				for (i=j-1;i>=1;i--) {
					if (arr[i] <= a) break;
					arr[i+1]=arr[i];
					val[i+1]=val[i];
				}
				arr[i+1]=a;
				val[i+1]=av; 
			}
			if (jstack == 0) break;
			ir=istack[jstack--];
			l=istack[jstack--];
		} else {
			k=(l+ir) >> 1;
			SWAP(arr[k],arr[l+1])
			SWAPV(val[k],val[l+1])
			if (arr[l+1] > arr[ir]) {
				SWAP(arr[l+1],arr[ir])
				SWAPV(val[l+1],val[ir])
			}
			if (arr[l] > arr[ir]) {
				SWAP(arr[l],arr[ir])
				SWAPV(val[l],val[ir])
			}
			if (arr[l+1] > arr[l]) {
				SWAP(arr[l+1],arr[l])
				SWAPV(val[l+1],val[l])
			}
			i=l+1;
			j=ir;
			a=arr[l];
			av=val[l];
			for (;;) {
				do i++; while (arr[i] < a);
				do j--; while (arr[j] > a);
				if (j < i) break;
				SWAP(arr[i],arr[j]);
				SWAPV(val[i],val[j]);
			}
			arr[l]=arr[j];
			val[l]=val[j];
			arr[j]=a;
			val[j]=av;
			jstack += 2;
			if (jstack > NSTACK)
			  nrerror("NSTACK too small in sort.");
			if (ir-i+1 >= j-l) {
				istack[jstack]=ir;
				istack[jstack-1]=i;
				ir=j-1;
			} else {
				istack[jstack]=j-1;
				istack[jstack-1]=l;
				l=i;
			}
		}
	}
	free_ivector(istack,1,NSTACK);

}
#undef M
#undef NSTACK
#undef SWAP
#undef NRANSI
/* (C) Copr. 1986-92 Numerical Recipes Software p%'&kH6r`2. */
