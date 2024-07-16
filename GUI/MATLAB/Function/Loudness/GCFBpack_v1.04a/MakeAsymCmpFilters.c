/*	MakeAsymCmpFilters
	original by T. IRINO
        coded by M. UNOKI
        23 June 1997
	modified by T. IRINO
	7 July 97
	3 June 98 (abs() -> fabs())
*/

#include <math.h>
#include <matrix.h>
#include "complex.h"
#include "mex.h"

#ifndef PI
#define PI	 3.14159265358979323846
#endif
#define rfBW  	 0.107939   
#define minBW	 24.7	
#define NumFilt  4
#define NumCoef  3
#define NumCoef2 (2*NumCoef-1) 
#define NumCoef4 (2*NumFilt+1) 

struct complex Cproduct(X,Y)
struct complex X,Y;
{
   struct complex Z;

   Z.Re=X.Re*Y.Re-X.Im*Y.Im;
   Z.Im=X.Re*Y.Im+X.Im*Y.Re;
   return(Z);
}

struct complex Conjugate(Z)
struct complex Z;
{
   struct complex ZZ;

   ZZ.Re=Z.Re;
   ZZ.Im=-Z.Im;
   return(ZZ);
}

struct complex Cdiv(X,Y)
struct complex X,Y;
{
   struct complex Z;
   double A;

   A=pow(Y.Re,2.0)+pow(Y.Im,2.0);
   Z=Cproduct(X,Conjugate(Y));
   Z.Re=Z.Re/A;
   Z.Im=Z.Im/A;
   return(Z);
}

double Cabs(Z)
struct complex Z;
{
   double Re2,Im2,absval;

   Re2=pow(Z.Re,2.0);
   Im2=pow(Z.Im,2.0);
   absval=sqrt(Re2+Im2);
   return(absval);
}

/* abs() is "int abs(int x)" in c math library. Use fabs() */

void AsymCmpCoef(c,coef_r,coef_th,coef_fn) 
double c,*coef_r,*coef_th,*coef_fn;
{

   double coef0[6]={1.35, -0.19, 0.29, -0.004, 0.23, 0.0072};  
   int indx;

   for (indx=0;indx<NumFilt;indx++) {
         coef_r[indx]  = (coef0[0]+coef0[1]*fabs(c))*(double)(indx+1);
         coef_th[indx] = (coef0[2]+coef0[3]*fabs(c))*pow(2.0,(double)(indx));
         coef_fn[indx] = (coef0[4]+coef0[5]*fabs(c))*(double)(indx+1);
   }
}

void MakeAsymCmpFilters(fs,fr,n,b,c,forward,feedback)
double fs,fr,n,b,c,*forward,*feedback;
{

   double ERBw,r,th,fn,nrm;
   double *coef_r,*coef_th,*coef_fn; 
   double app[NumCoef],bzz[NumCoef];
   double an[NumFilt][NumCoef],bn[NumFilt][NumCoef];
   double a12[NumCoef2],a34[NumCoef2],b12[NumCoef2],b34[NumCoef2];
   int indx,Nfilt;
   struct complex Sum_app,Sum_bzz,vwr,vwrs[NumCoef];

   ERBw    = fr*rfBW + minBW;
   coef_r  = mxCalloc(NumFilt,sizeof(double));
   coef_th = mxCalloc(NumFilt,sizeof(double));
   coef_fn = mxCalloc(NumFilt,sizeof(double));
   AsymCmpCoef(c,coef_r,coef_th,coef_fn);

   for (Nfilt=0;Nfilt<NumFilt;Nfilt++) {
      r  = exp(-coef_r[Nfilt]*2.0*PI*b*ERBw/fs);
      th = coef_th[Nfilt]*c*b*ERBw/fr;
      fn = fr + coef_fn[Nfilt]*c*b*ERBw/n;

      app[0] =  1.0;
      app[1] = -2.0*r*cos(2.0*PI*(1.0+th)*fr/fs);
      app[2] =  pow(r,2.0);
      bzz[0] =  1.0;
      bzz[1] = -2.0*r*cos(2.0*PI*(1.0-th)*fr/fs);
      bzz[2] =  pow(r,2.0);

      vwr.Re = cos(2.0*PI*fn/fs);
      vwr.Im = sin(2.0*PI*fn/fs);
      vwrs[0].Re = 1.0;
      vwrs[0].Im = 0.0;
      vwrs[1]    = vwr;
      vwrs[2]    = Cproduct(vwr,vwr);
      Sum_app.Re = 0.0;
      Sum_app.Im = 0.0;
      Sum_bzz.Re = 0.0;
      Sum_bzz.Im = 0.0;
      for (indx=0;indx<NumCoef;indx++) {
         Sum_bzz.Re += vwrs[indx].Re*bzz[indx];
         Sum_bzz.Im += vwrs[indx].Im*bzz[indx];
         Sum_app.Re += vwrs[indx].Re*app[indx];
         Sum_app.Im += vwrs[indx].Im*app[indx];
      }
      nrm=Cabs(Cdiv(Sum_app,Sum_bzz));
      for (indx=0;indx<NumCoef;indx++) {
         bzz[indx]       = bzz[indx]*nrm;
         an[Nfilt][indx] = app[indx];
         bn[Nfilt][indx] = bzz[indx];
      }
   }
   a12[0]=an[0][0]*an[1][0];
   a12[1]=an[0][0]*an[1][1]+an[0][1]*an[1][0];
   a12[2]=an[0][0]*an[1][2]+an[0][2]*an[1][0]+an[0][1]*an[1][1];
   a12[3]=an[0][1]*an[1][2]+an[0][2]*an[1][1];
   a12[4]=an[0][2]*an[1][2];
   a34[0]=an[2][0]*an[3][0];
   a34[1]=an[2][0]*an[3][1]+an[2][1]*an[3][0];
   a34[2]=an[2][0]*an[3][2]+an[2][2]*an[3][0]+an[2][1]*an[3][1];
   a34[3]=an[2][1]*an[3][2]+an[2][2]*an[3][1];
   a34[4]=an[2][2]*an[3][2];
   b12[0]=bn[0][0]*bn[1][0];
   b12[1]=bn[0][0]*bn[1][1]+bn[0][1]*bn[1][0];
   b12[2]=bn[0][0]*bn[1][2]+bn[0][2]*bn[1][0]+bn[0][1]*bn[1][1];
   b12[3]=bn[0][1]*bn[1][2]+bn[0][2]*bn[1][1];
   b12[4]=bn[0][2]*bn[1][2];
   b34[0]=bn[2][0]*bn[3][0];
   b34[1]=bn[2][0]*bn[3][1]+bn[2][1]*bn[3][0];
   b34[2]=bn[2][0]*bn[3][2]+bn[2][2]*bn[3][0]+bn[2][1]*bn[3][1];
   b34[3]=bn[2][1]*bn[3][2]+bn[2][2]*bn[3][1];
   b34[4]=bn[2][2]*bn[3][2];

   feedback[0]=a12[0]*a34[0];
   feedback[1]=a12[0]*a34[1]+a12[1]*a34[0];
   feedback[2]=a12[0]*a34[2]+a12[2]*a34[0]+a12[1]*a34[1];
   feedback[3]=a12[0]*a34[3]+a12[3]*a34[0]+a12[1]*a34[2]+a12[2]*a34[1];
   feedback[4]=a12[0]*a34[4]+a12[4]*a34[0]+a12[1]*a34[3]+a12[3]*a34[1]+a12[2]*a34[2];
   feedback[5]=a12[1]*a34[4]+a12[4]*a34[1]+a12[2]*a34[3]+a12[3]*a34[2];
   feedback[6]=a12[2]*a34[4]+a12[4]*a34[2]+a12[3]*a34[3];
   feedback[7]=a12[3]*a34[4]+a12[4]*a34[3];
   feedback[8]=a12[4]*a34[4];

   forward[0]=b12[0]*b34[0];
   forward[1]=b12[0]*b34[1]+b12[1]*b34[0];
   forward[2]=b12[0]*b34[2]+b12[2]*b34[0]+b12[1]*b34[1];
   forward[3]=b12[0]*b34[3]+b12[3]*b34[0]+b12[1]*b34[2]+b12[2]*b34[1];
   forward[4]=b12[0]*b34[4]+b12[4]*b34[0]+b12[1]*b34[3]+b12[3]*b34[1]+b12[2]*b34[2];
   forward[5]=b12[1]*b34[4]+b12[4]*b34[1]+b12[2]*b34[3]+b12[3]*b34[2];
   forward[6]=b12[2]*b34[4]+b12[4]*b34[2]+b12[3]*b34[3];
   forward[7]=b12[3]*b34[4]+b12[4]*b34[3];
   forward[8]=b12[4]*b34[4];

   mxFree(coef_r);
   mxFree(coef_th);
   mxFree(coef_fn);
}

void mexFunction(
int nlhs, mxArray *plhs[],
int nrhs, const mxArray *prhs[])
{
   double *forward,*feedback,*bz,*ap;
   double fs,*fr,b,*c, n;
   int    NumCh,ch,LENGTH,indx, nv;

   if (nrhs!=5) {
      mexErrMsgTxt("Five input arguments are required.");
   }
   else if (nlhs>3) {
      mexErrMsgTxt("Two output vectors are allowed.");
   }
   NumCh=(int)mxGetM(prhs[1]); /* column vector size from fr */
   if (mxGetM(prhs[0])!=1 || mxGetN(prhs[0])!=1)
      mexErrMsgTxt("Parameter fs must be a scalar.");
   if (mxGetN(prhs[1])!=1)
      mexErrMsgTxt("Parameter fr must be a column vector.");
   if (mxGetM(prhs[2])!=1 || mxGetN(prhs[2])!=1)
      mexErrMsgTxt("Parameter n  must be a scalar.");
   if (mxGetM(prhs[3])!=1 || mxGetN(prhs[3])!=1)
      mexErrMsgTxt("Parameter b  must be a scalar.");
   if (mxGetM(prhs[4])!=NumCh || mxGetN(prhs[4])!=1)
      mexErrMsgTxt("Parameter c must be a column vector as is fr. ");
   fs=mxGetScalar(prhs[0]);
   fr=mxGetPr(prhs[1]);
   n =mxGetScalar(prhs[2]);
   b =mxGetScalar(prhs[3]);
   c =mxGetPr(prhs[4]);
   forward=mxCalloc(NumCoef4,sizeof(double));
   feedback=mxCalloc(NumCoef4,sizeof(double));
   LENGTH=NumCh*NumCoef4;
   bz=mxCalloc(LENGTH,sizeof(double));
   ap=mxCalloc(LENGTH,sizeof(double));
   plhs[0]=mxCreateDoubleMatrix(NumCh,NumCoef4,mxREAL);
   plhs[1]=mxCreateDoubleMatrix(NumCh,NumCoef4,mxREAL);
   for (ch=0;ch<NumCh;ch++) {
      MakeAsymCmpFilters(fs,fr[ch],n,b,c[ch],forward,feedback);
      for (indx=0; indx<NumCoef4; indx++) {
         bz[ch+NumCh*indx]=forward[indx];
         ap[ch+NumCh*indx]=feedback[indx];
      }
   }
   mxSetPr(plhs[0],bz);
   mxSetPr(plhs[1],ap); 
   mxFree(forward);
   mxFree(feedback); 
}

