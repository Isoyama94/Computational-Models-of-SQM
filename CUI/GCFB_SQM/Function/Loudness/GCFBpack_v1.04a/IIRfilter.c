/*	function [z] = IIRfilter(b,a,x,y);

	IIRfilter	: IIRfiltering in time slice
	Masashi UNOKI
	18 June 1997
	Toshio IRINO
	8 July 1997
	Modified by MU, 31 July 1997
	Modified by IT, 22 April 1998

	function [z] = IIRfilter(b,a,x,yp)
	INPUT : b	: Coefficent
		a 	: Coefficent
		x	: Input matrix
		y	: Previous z value matrix
	OUTPUT: z 	: Output of the filltering
        -------
        Mex version
*/

#include <math.h>
#include "mex.h"

void IIRfilter(b,Lb,a,La,x,Lx,y,Ly,z)
double *b,*a,*x,*y,*z;
int    Lb,La,Lx,Ly;
{
   int m;
/*    double X[Lb],Y[La-1];  */ /* It does not work for DEC C compiler. */
   double X[100],Y[100];    /* for sufficient number.  22 Apr. 98 */

   for (m=0;m<Lb-Lx;m++) 
      X[m]=0.0;
   for (m=Lb-Lx;m<Lb;m++) 
      X[m]=x[m-Lb+Lx]; 
   for (m=0;m<La-Ly;m++) 
      Y[m]=0.0;
   for (m=La-Ly-1;m<La-1;m++) {
      Y[m]=y[m-La+Ly+1]; 
   }

   z[0]=b[0]*X[Lb-1];
   for (m=1;m<Lb;m++) {
      z[0]+=b[m]*X[Lb-1-m];
   }
   for (m=1;m<La;m++) {
      z[0]-=a[m]*Y[La-1-m];
   }
   z[0]=z[0]/a[0];
}

void mexFunction(
int nlhs, mxArray *plhs[],
int nrhs, const mxArray *prhs[])
{
   double *X,*Y,*bz,*ap;
   double *x,*y,*b,*a,*z,*Z;
   int     La,Lb,Lx,Ly,NumCh,ch,m;

   if (nrhs!=4) {
      mexErrMsgTxt("Four inputs arguments are required.");
   }
   else if (nlhs>2) {
      mexErrMsgTxt("Two outputs are required.");
   }
   NumCh=(int)mxGetM(prhs[1]); 
   if (mxGetM(prhs[0])!=NumCh)
     mexErrMsgTxt("Parameter b mismatches to a.");
   if (mxGetM(prhs[2])!=NumCh)
      mexErrMsgTxt("Input x mismatches to a.");
   if (mxGetM(prhs[3])!=NumCh)
      mexErrMsgTxt("Input y mismatches to a.");
   bz=mxGetPr(prhs[0]); 
   Lb=(int)mxGetN(prhs[0]);
   ap=mxGetPr(prhs[1]); 
   La=(int)mxGetN(prhs[1]);
   X=mxGetPr(prhs[2]); 
   Lx=(int)mxGetN(prhs[2]);
   Y=mxGetPr(prhs[3]); 
   Ly=(int)mxGetN(prhs[3]);
   Z=mxCalloc(NumCh,sizeof(double));
   b=mxCalloc(Lb,sizeof(double));
   a=mxCalloc(La,sizeof(double));
   x=mxCalloc(Lx,sizeof(double));
   y=mxCalloc(Ly,sizeof(double));
   z=mxCalloc(1,sizeof(double));
   plhs[0]=mxCreateDoubleMatrix(NumCh,1,mxREAL);
   for (ch=0;ch<NumCh;ch++) {
      for (m=0;m<Lb;m++) b[m]=bz[ch+NumCh*m];
      for (m=0;m<La;m++) a[m]=ap[ch+NumCh*m];
      for (m=0;m<Lx;m++) x[m]= X[ch+NumCh*m];
      for (m=0;m<Ly;m++) y[m]= Y[ch+NumCh*m];
      IIRfilter(b,Lb,a,La,x,Lx,y,Ly,z);
      Z[ch]=z[0];
   }
   mxSetPr(plhs[0],Z);
   mxFree(b);
   mxFree(a);
   mxFree(x);
   mxFree(y);
   mxFree(z);
}



