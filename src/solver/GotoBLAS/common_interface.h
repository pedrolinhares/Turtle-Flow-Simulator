/*********************************************************************/
/*                                                                   */
/*             Optimized BLAS libraries                              */
/*                     By Kazushige Goto <kgoto@tacc.utexas.edu>     */
/*                                                                   */
/* Copyright (c) The University of Texas, 2005. All rights reserved. */
/* UNIVERSITY EXPRESSLY DISCLAIMS ANY AND ALL WARRANTIES CONCERNING  */
/* THIS SOFTWARE AND DOCUMENTATION, INCLUDING ANY WARRANTIES OF      */
/* MERCHANTABILITY, FITNESS FOR ANY PARTICULAR PURPOSE,              */
/* NON-INFRINGEMENT AND WARRANTIES OF PERFORMANCE, AND ANY WARRANTY  */
/* THAT MIGHT OTHERWISE ARISE FROM COURSE OF DEALING OR USAGE OF     */
/* TRADE. NO WARRANTY IS EITHER EXPRESS OR IMPLIED WITH RESPECT TO   */
/* THE USE OF THE SOFTWARE OR DOCUMENTATION.                         */
/* Under no circumstances shall University be liable for incidental, */
/* special, indirect, direct or consequential damages or loss of     */
/* profits, interruption of business, or related expenses which may  */
/* arise from use of Software or Documentation, including but not    */
/* limited to those resulting from defects in Software and/or        */
/* Documentation, or loss or inaccuracy of data of any kind.         */
/*********************************************************************/

#ifndef ASSEMBLER

int    BLASFUNC(xerbla)(char *, blasint *info, blasint);

#ifndef FLOATRET
#ifndef NEED_F2CCONV
#define FLOATRET	float
#else
#define FLOATRET	double
#endif
#endif

FLOATRET  BLASFUNC(sdot)  (blasint *, float  *, blasint *, float  *, blasint *);
FLOATRET  BLASFUNC(sdsdot)(blasint *, float  *,        float  *, blasint *, float  *, blasint *);

double BLASFUNC(dsdot) (blasint *, float  *, blasint *, float  *, blasint *);
double BLASFUNC(ddot)  (blasint *, double *, blasint *, double *, blasint *);
xdouble BLASFUNC(qdot)  (blasint *, xdouble *, blasint *, xdouble *, blasint *);

#if defined(F_INTERFACE_GFORT) && !defined(__64BIT__)
int   BLASFUNC(cdotu)  (blasint *, float  * , blasint *, float  *,  blasint *);
int   BLASFUNC(cdotc)  (blasint *, float  *,  blasint *, float  *,  blasint *);
void  BLASFUNC(zdotu)  (double *, blasint *, double  *, blasint *, double  *, blasint *);
void  BLASFUNC(zdotc)  (double *, blasint *, double  *, blasint *, double  *, blasint *);
void  BLASFUNC(xdotu)  (xdouble *, blasint *, xdouble  *, blasint *, xdouble  *, blasint *);
void  BLASFUNC(xdotc)  (xdouble *, blasint *, xdouble  *, blasint *, xdouble  *, blasint *);
#elif  defined(F_INTERFACE_F2C) || \
     defined(F_INTERFACE_PGI) || \
     defined(F_INTERFACE_GFORT) || \
    (defined(F_INTERFACE_PATHSCALE) && defined(__64BIT__))
void  BLASFUNC(cdotu)  (float *,  blasint *, float  * , blasint *, float  *,  blasint *);
void  BLASFUNC(cdotc)  (float *,  blasint *, float  *,  blasint *, float  *,  blasint *);
void  BLASFUNC(zdotu)  (double *, blasint *, double  *, blasint *, double  *, blasint *);
void  BLASFUNC(zdotc)  (double *, blasint *, double  *, blasint *, double  *, blasint *);
void  BLASFUNC(xdotu)  (xdouble *, blasint *, xdouble  *, blasint *, xdouble  *, blasint *);
void  BLASFUNC(xdotc)  (xdouble *, blasint *, xdouble  *, blasint *, xdouble  *, blasint *);
#else
FLOATRET   BLASFUNC(cdotu)  (blasint *, float  *, blasint *, float  *, blasint *);
FLOATRET   BLASFUNC(cdotc)  (blasint *, float  *, blasint *, float  *, blasint *);
double  BLASFUNC(zdotu)  (blasint *, double  *, blasint *, double  *, blasint *);
double  BLASFUNC(zdotc)  (blasint *, double  *, blasint *, double  *, blasint *);
xdouble  BLASFUNC(xdotu)  (blasint *, xdouble  *, blasint *, xdouble  *, blasint *);
xdouble  BLASFUNC(xdotc)  (blasint *, xdouble  *, blasint *, xdouble  *, blasint *);
#endif

int    BLASFUNC(saxpy) (blasint *, float  *, float  *, blasint *, float  *, blasint *);
int    BLASFUNC(daxpy) (blasint *, double *, double *, blasint *, double *, blasint *);
int    BLASFUNC(qaxpy) (blasint *, xdouble *, xdouble *, blasint *, xdouble *, blasint *);
int    BLASFUNC(caxpy) (blasint *, float  *, float  *, blasint *, float  *, blasint *);
int    BLASFUNC(zaxpy) (blasint *, double *, double *, blasint *, double *, blasint *);
int    BLASFUNC(xaxpy) (blasint *, xdouble *, xdouble *, blasint *, xdouble *, blasint *);
int    BLASFUNC(caxpyc)(blasint *, float  *, float  *, blasint *, float  *, blasint *);
int    BLASFUNC(zaxpyc)(blasint *, double *, double *, blasint *, double *, blasint *);
int    BLASFUNC(xaxpyc)(blasint *, xdouble *, xdouble *, blasint *, xdouble *, blasint *);

int    BLASFUNC(scopy) (blasint *, float  *, blasint *, float  *, blasint *);
int    BLASFUNC(dcopy) (blasint *, double *, blasint *, double *, blasint *);
int    BLASFUNC(qcopy) (blasint *, xdouble *, blasint *, xdouble *, blasint *);
int    BLASFUNC(ccopy) (blasint *, float  *, blasint *, float  *, blasint *);
int    BLASFUNC(zcopy) (blasint *, double *, blasint *, double *, blasint *);
int    BLASFUNC(xcopy) (blasint *, xdouble *, blasint *, xdouble *, blasint *);

int    BLASFUNC(sswap) (blasint *, float  *, blasint *, float  *, blasint *);
int    BLASFUNC(dswap) (blasint *, double *, blasint *, double *, blasint *);
int    BLASFUNC(qswap) (blasint *, xdouble *, blasint *, xdouble *, blasint *);
int    BLASFUNC(cswap) (blasint *, float  *, blasint *, float  *, blasint *);
int    BLASFUNC(zswap) (blasint *, double *, blasint *, double *, blasint *);
int    BLASFUNC(xswap) (blasint *, xdouble *, blasint *, xdouble *, blasint *);

FLOATRET  BLASFUNC(sasum) (blasint *, float  *, blasint *);
FLOATRET  BLASFUNC(scasum)(blasint *, float  *, blasint *);
double BLASFUNC(dasum) (blasint *, double *, blasint *);
xdouble BLASFUNC(qasum) (blasint *, xdouble *, blasint *);
double BLASFUNC(dzasum)(blasint *, double *, blasint *);
xdouble BLASFUNC(qxasum)(blasint *, xdouble *, blasint *);

blasint    BLASFUNC(isamax)(blasint *, float  *, blasint *);
blasint    BLASFUNC(idamax)(blasint *, double *, blasint *);
blasint    BLASFUNC(iqamax)(blasint *, xdouble *, blasint *);
blasint    BLASFUNC(icamax)(blasint *, float  *, blasint *);
blasint    BLASFUNC(izamax)(blasint *, double *, blasint *);
blasint    BLASFUNC(ixamax)(blasint *, xdouble *, blasint *);

blasint    BLASFUNC(ismax) (blasint *, float  *, blasint *);
blasint    BLASFUNC(idmax) (blasint *, double *, blasint *);
blasint    BLASFUNC(iqmax) (blasint *, xdouble *, blasint *);
blasint    BLASFUNC(icmax) (blasint *, float  *, blasint *);
blasint    BLASFUNC(izmax) (blasint *, double *, blasint *);
blasint    BLASFUNC(ixmax) (blasint *, xdouble *, blasint *);

blasint    BLASFUNC(isamin)(blasint *, float  *, blasint *);
blasint    BLASFUNC(idamin)(blasint *, double *, blasint *);
blasint    BLASFUNC(iqamin)(blasint *, xdouble *, blasint *);
blasint    BLASFUNC(icamin)(blasint *, float  *, blasint *);
blasint    BLASFUNC(izamin)(blasint *, double *, blasint *);
blasint    BLASFUNC(ixamin)(blasint *, xdouble *, blasint *);

blasint    BLASFUNC(ismin)(blasint *, float  *, blasint *);
blasint    BLASFUNC(idmin)(blasint *, double *, blasint *);
blasint    BLASFUNC(iqmin)(blasint *, xdouble *, blasint *);
blasint    BLASFUNC(icmin)(blasint *, float  *, blasint *);
blasint    BLASFUNC(izmin)(blasint *, double *, blasint *);
blasint    BLASFUNC(ixmin)(blasint *, xdouble *, blasint *);

FLOATRET  BLASFUNC(samax) (blasint *, float  *, blasint *);
double BLASFUNC(damax) (blasint *, double *, blasint *);
xdouble BLASFUNC(qamax) (blasint *, xdouble *, blasint *);
FLOATRET  BLASFUNC(scamax)(blasint *, float  *, blasint *);
double BLASFUNC(dzamax)(blasint *, double *, blasint *);
xdouble BLASFUNC(qxamax)(blasint *, xdouble *, blasint *);

FLOATRET  BLASFUNC(samin) (blasint *, float  *, blasint *);
double BLASFUNC(damin) (blasint *, double *, blasint *);
xdouble BLASFUNC(qamin) (blasint *, xdouble *, blasint *);
FLOATRET  BLASFUNC(scamin)(blasint *, float  *, blasint *);
double BLASFUNC(dzamin)(blasint *, double *, blasint *);
xdouble BLASFUNC(qxamin)(blasint *, xdouble *, blasint *);

FLOATRET  BLASFUNC(smax)  (blasint *, float  *, blasint *);
double BLASFUNC(dmax)  (blasint *, double *, blasint *);
xdouble BLASFUNC(qmax)  (blasint *, xdouble *, blasint *);
FLOATRET  BLASFUNC(scmax) (blasint *, float  *, blasint *);
double BLASFUNC(dzmax) (blasint *, double *, blasint *);
xdouble BLASFUNC(qxmax) (blasint *, xdouble *, blasint *);

FLOATRET  BLASFUNC(smin)  (blasint *, float  *, blasint *);
double BLASFUNC(dmin)  (blasint *, double *, blasint *);
xdouble BLASFUNC(qmin)  (blasint *, xdouble *, blasint *);
FLOATRET  BLASFUNC(scmin) (blasint *, float  *, blasint *);
double BLASFUNC(dzmin) (blasint *, double *, blasint *);
xdouble BLASFUNC(qxmin) (blasint *, xdouble *, blasint *);

int    BLASFUNC(sscal) (blasint *,  float  *, float  *, blasint *);
int    BLASFUNC(dscal) (blasint *,  double *, double *, blasint *);
int    BLASFUNC(qscal) (blasint *,  xdouble *, xdouble *, blasint *);
int    BLASFUNC(cscal) (blasint *,  float  *, float  *, blasint *);
int    BLASFUNC(zscal) (blasint *,  double *, double *, blasint *);
int    BLASFUNC(xscal) (blasint *,  xdouble *, xdouble *, blasint *);
int    BLASFUNC(csscal)(blasint *,  float  *, float  *, blasint *);
int    BLASFUNC(zdscal)(blasint *,  double *, double *, blasint *);
int    BLASFUNC(xqscal)(blasint *,  xdouble *, xdouble *, blasint *);

FLOATRET  BLASFUNC(snrm2) (blasint *, float  *, blasint *);
FLOATRET  BLASFUNC(scnrm2)(blasint *, float  *, blasint *);

double BLASFUNC(dnrm2) (blasint *, double *, blasint *);
xdouble BLASFUNC(qnrm2) (blasint *, xdouble *, blasint *);
double BLASFUNC(dznrm2)(blasint *, double *, blasint *);
double BLASFUNC(qxnrm2)(blasint *, xdouble *, blasint *);

int    BLASFUNC(srot)  (blasint *, float  *, blasint *, float  *, blasint *, float  *, float  *);
int    BLASFUNC(drot)  (blasint *, double *, blasint *, double *, blasint *, double *, double *);
int    BLASFUNC(qrot)  (blasint *, xdouble *, blasint *, xdouble *, blasint *, xdouble *, xdouble *);
int    BLASFUNC(csrot) (blasint *, float  *, blasint *, float  *, blasint *, float  *, float  *);
int    BLASFUNC(zdrot) (blasint *, double *, blasint *, double *, blasint *, double *, double *);
int    BLASFUNC(xqrot) (blasint *, xdouble *, blasint *, xdouble *, blasint *, xdouble *, xdouble *);

int    BLASFUNC(srotg) (float  *, float  *, float  *, float  *);
int    BLASFUNC(drotg) (double *, double *, double *, double *);
int    BLASFUNC(qrotg) (xdouble *, xdouble *, xdouble *, xdouble *);
int    BLASFUNC(crotg) (float  *, float  *, float  *, float  *);
int    BLASFUNC(zrotg) (double *, double *, double *, double *);
int    BLASFUNC(xrotg) (xdouble *, xdouble *, xdouble *, xdouble *);

int    BLASFUNC(srotmg)(float  *, float  *, float  *, float  *, float  *);
int    BLASFUNC(drotmg)(double *, double *, double *, double *, double *);

int    BLASFUNC(srotm) (blasint *, float  *, blasint *, float  *, blasint *, float  *);
int    BLASFUNC(drotm) (blasint *, double *, blasint *, double *, blasint *, double *);
int    BLASFUNC(qrotm) (blasint *, xdouble *, blasint *, xdouble *, blasint *, xdouble *);

/* Level 2 routines */

int BLASFUNC(sger)(blasint *,    blasint *, float *,  float *, blasint *,
		   float *,  blasint *, float *,  blasint *);
int BLASFUNC(dger)(blasint *,    blasint *, double *, double *, blasint *,
		   double *, blasint *, double *, blasint *);
int BLASFUNC(qger)(blasint *,    blasint *, xdouble *, xdouble *, blasint *,
		   xdouble *, blasint *, xdouble *, blasint *);
int BLASFUNC(cgeru)(blasint *,    blasint *, float *,  float *, blasint *,
		    float *,  blasint *, float *,  blasint *);
int BLASFUNC(cgerc)(blasint *,    blasint *, float *,  float *, blasint *,
		    float *,  blasint *, float *,  blasint *);
int BLASFUNC(zgeru)(blasint *,    blasint *, double *, double *, blasint *,
		    double *, blasint *, double *, blasint *);
int BLASFUNC(zgerc)(blasint *,    blasint *, double *, double *, blasint *,
		    double *, blasint *, double *, blasint *);
int BLASFUNC(xgeru)(blasint *,    blasint *, xdouble *, xdouble *, blasint *,
		    xdouble *, blasint *, xdouble *, blasint *);
int BLASFUNC(xgerc)(blasint *,    blasint *, xdouble *, xdouble *, blasint *,
		    xdouble *, blasint *, xdouble *, blasint *);

int BLASFUNC(sgemv)(char *, blasint *, blasint *, float  *, float  *, blasint *, 
		    float  *, blasint *, float  *, float  *, blasint *);
int BLASFUNC(dgemv)(char *, blasint *, blasint *, double *, double *, blasint *, 
		    double *, blasint *, double *, double *, blasint *);
int BLASFUNC(qgemv)(char *, blasint *, blasint *, xdouble *, xdouble *, blasint *, 
		    xdouble *, blasint *, xdouble *, xdouble *, blasint *);
int BLASFUNC(cgemv)(char *, blasint *, blasint *, float  *, float  *, blasint *, 
		    float  *, blasint *, float  *, float  *, blasint *);
int BLASFUNC(zgemv)(char *, blasint *, blasint *, double *, double *, blasint *, 
		    double *, blasint *, double *, double *, blasint *);
int BLASFUNC(xgemv)(char *, blasint *, blasint *, xdouble *, xdouble *, blasint *, 
		    xdouble *, blasint *, xdouble *, xdouble *, blasint *);

int BLASFUNC(strsv) (char *, char *, char *, blasint *, float  *, blasint *,
		     float  *, blasint *);
int BLASFUNC(dtrsv) (char *, char *, char *, blasint *, double *, blasint *,
		     double *, blasint *);
int BLASFUNC(qtrsv) (char *, char *, char *, blasint *, xdouble *, blasint *,
		     xdouble *, blasint *);
int BLASFUNC(ctrsv) (char *, char *, char *, blasint *, float  *, blasint *, 
		     float  *, blasint *);
int BLASFUNC(ztrsv) (char *, char *, char *, blasint *, double *, blasint *, 
		     double *, blasint *);
int BLASFUNC(xtrsv) (char *, char *, char *, blasint *, xdouble *, blasint *, 
		     xdouble *, blasint *);

int BLASFUNC(stpsv) (char *, char *, char *, blasint *, float  *, float  *, blasint *);
int BLASFUNC(dtpsv) (char *, char *, char *, blasint *, double *, double *, blasint *);
int BLASFUNC(qtpsv) (char *, char *, char *, blasint *, xdouble *, xdouble *, blasint *);
int BLASFUNC(ctpsv) (char *, char *, char *, blasint *, float  *, float  *, blasint *);
int BLASFUNC(ztpsv) (char *, char *, char *, blasint *, double *, double *, blasint *);
int BLASFUNC(xtpsv) (char *, char *, char *, blasint *, xdouble *, xdouble *, blasint *);

int BLASFUNC(strmv) (char *, char *, char *, blasint *, float  *, blasint *,
		     float  *, blasint *);
int BLASFUNC(dtrmv) (char *, char *, char *, blasint *, double *, blasint *, 
		     double *, blasint *);
int BLASFUNC(qtrmv) (char *, char *, char *, blasint *, xdouble *, blasint *, 
		     xdouble *, blasint *);
int BLASFUNC(ctrmv) (char *, char *, char *, blasint *, float  *, blasint *, 
		     float  *, blasint *);
int BLASFUNC(ztrmv) (char *, char *, char *, blasint *, double *, blasint *, 
		     double *, blasint *);
int BLASFUNC(xtrmv) (char *, char *, char *, blasint *, xdouble *, blasint *, 
		     xdouble *, blasint *);

int BLASFUNC(stpmv) (char *, char *, char *, blasint *, float  *, float  *, blasint *);
int BLASFUNC(dtpmv) (char *, char *, char *, blasint *, double *, double *, blasint *);
int BLASFUNC(qtpmv) (char *, char *, char *, blasint *, xdouble *, xdouble *, blasint *);
int BLASFUNC(ctpmv) (char *, char *, char *, blasint *, float  *, float  *, blasint *);
int BLASFUNC(ztpmv) (char *, char *, char *, blasint *, double *, double *, blasint *);
int BLASFUNC(xtpmv) (char *, char *, char *, blasint *, xdouble *, xdouble *, blasint *);

int BLASFUNC(stbmv) (char *, char *, char *, blasint *, blasint *, float  *, blasint *, float  *, blasint *);
int BLASFUNC(dtbmv) (char *, char *, char *, blasint *, blasint *, double *, blasint *, double *, blasint *);
int BLASFUNC(qtbmv) (char *, char *, char *, blasint *, blasint *, xdouble *, blasint *, xdouble *, blasint *);
int BLASFUNC(ctbmv) (char *, char *, char *, blasint *, blasint *, float  *, blasint *, float  *, blasint *);
int BLASFUNC(ztbmv) (char *, char *, char *, blasint *, blasint *, double *, blasint *, double *, blasint *);
int BLASFUNC(xtbmv) (char *, char *, char *, blasint *, blasint *, xdouble *, blasint *, xdouble *, blasint *);

int BLASFUNC(stbsv) (char *, char *, char *, blasint *, blasint *, float  *, blasint *, float  *, blasint *);
int BLASFUNC(dtbsv) (char *, char *, char *, blasint *, blasint *, double *, blasint *, double *, blasint *);
int BLASFUNC(qtbsv) (char *, char *, char *, blasint *, blasint *, xdouble *, blasint *, xdouble *, blasint *);
int BLASFUNC(ctbsv) (char *, char *, char *, blasint *, blasint *, float  *, blasint *, float  *, blasint *);
int BLASFUNC(ztbsv) (char *, char *, char *, blasint *, blasint *, double *, blasint *, double *, blasint *);
int BLASFUNC(xtbsv) (char *, char *, char *, blasint *, blasint *, xdouble *, blasint *, xdouble *, blasint *);

int BLASFUNC(ssymv) (char *, blasint *, float  *, float *, blasint *, 
		     float  *, blasint *, float *, float *, blasint *);
int BLASFUNC(dsymv) (char *, blasint *, double  *, double *, blasint *, 
		     double  *, blasint *, double *, double *, blasint *);
int BLASFUNC(qsymv) (char *, blasint *, xdouble  *, xdouble *, blasint *, 
		     xdouble  *, blasint *, xdouble *, xdouble *, blasint *);
int BLASFUNC(csymv) (char *, blasint *, float  *, float *, blasint *, 
		     float  *, blasint *, float *, float *, blasint *);
int BLASFUNC(zsymv) (char *, blasint *, double  *, double *, blasint *, 
		     double  *, blasint *, double *, double *, blasint *);
int BLASFUNC(xsymv) (char *, blasint *, xdouble  *, xdouble *, blasint *, 
		     xdouble  *, blasint *, xdouble *, xdouble *, blasint *);

int BLASFUNC(sspmv) (char *, blasint *, float  *, float *,
		     float  *, blasint *, float *, float *, blasint *);
int BLASFUNC(dspmv) (char *, blasint *, double  *, double *, 
		     double  *, blasint *, double *, double *, blasint *);
int BLASFUNC(qspmv) (char *, blasint *, xdouble  *, xdouble *, 
		     xdouble  *, blasint *, xdouble *, xdouble *, blasint *);
int BLASFUNC(cspmv) (char *, blasint *, float  *, float *,
		     float  *, blasint *, float *, float *, blasint *);
int BLASFUNC(zspmv) (char *, blasint *, double  *, double *,
		     double  *, blasint *, double *, double *, blasint *);
int BLASFUNC(xspmv) (char *, blasint *, xdouble  *, xdouble *,
		     xdouble  *, blasint *, xdouble *, xdouble *, blasint *);

int BLASFUNC(ssyr) (char *, blasint *, float   *, float  *, blasint *,
		    float  *, blasint *);
int BLASFUNC(dsyr) (char *, blasint *, double  *, double *, blasint *,
		    double *, blasint *);
int BLASFUNC(qsyr) (char *, blasint *, xdouble  *, xdouble *, blasint *,
		    xdouble *, blasint *);
int BLASFUNC(csyr) (char *, blasint *, float   *, float  *, blasint *,
		    float  *, blasint *);
int BLASFUNC(zsyr) (char *, blasint *, double  *, double *, blasint *,
		    double *, blasint *);
int BLASFUNC(xsyr) (char *, blasint *, xdouble  *, xdouble *, blasint *,
		    xdouble *, blasint *);

int BLASFUNC(ssyr2) (char *, blasint *, float   *, 
		     float  *, blasint *, float  *, blasint *, float  *, blasint *);
int BLASFUNC(dsyr2) (char *, blasint *, double  *, 
		     double *, blasint *, double *, blasint *, double *, blasint *);
int BLASFUNC(qsyr2) (char *, blasint *, xdouble  *, 
		     xdouble *, blasint *, xdouble *, blasint *, xdouble *, blasint *);
int BLASFUNC(csyr2) (char *, blasint *, float   *, 
		     float  *, blasint *, float  *, blasint *, float  *, blasint *);
int BLASFUNC(zsyr2) (char *, blasint *, double  *, 
		     double *, blasint *, double *, blasint *, double *, blasint *);
int BLASFUNC(xsyr2) (char *, blasint *, xdouble  *, 
		     xdouble *, blasint *, xdouble *, blasint *, xdouble *, blasint *);

int BLASFUNC(sspr) (char *, blasint *, float   *, float  *, blasint *,
		    float  *);
int BLASFUNC(dspr) (char *, blasint *, double  *, double *, blasint *,
		    double *);
int BLASFUNC(qspr) (char *, blasint *, xdouble  *, xdouble *, blasint *,
		    xdouble *);
int BLASFUNC(cspr) (char *, blasint *, float   *, float  *, blasint *,
		    float  *);
int BLASFUNC(zspr) (char *, blasint *, double  *, double *, blasint *,
		    double *);
int BLASFUNC(xspr) (char *, blasint *, xdouble  *, xdouble *, blasint *,
		    xdouble *);

int BLASFUNC(sspr2) (char *, blasint *, float   *, 
		     float  *, blasint *, float  *, blasint *, float  *);
int BLASFUNC(dspr2) (char *, blasint *, double  *, 
		     double *, blasint *, double *, blasint *, double *);
int BLASFUNC(qspr2) (char *, blasint *, xdouble  *, 
		     xdouble *, blasint *, xdouble *, blasint *, xdouble *);
int BLASFUNC(cspr2) (char *, blasint *, float   *, 
		     float  *, blasint *, float  *, blasint *, float  *);
int BLASFUNC(zspr2) (char *, blasint *, double  *, 
		     double *, blasint *, double *, blasint *, double *);
int BLASFUNC(xspr2) (char *, blasint *, xdouble  *, 
		     xdouble *, blasint *, xdouble *, blasint *, xdouble *);

int BLASFUNC(cher) (char *, blasint *, float   *, float  *, blasint *,
		    float  *, blasint *);
int BLASFUNC(zher) (char *, blasint *, double  *, double *, blasint *,
		    double *, blasint *);
int BLASFUNC(xher) (char *, blasint *, xdouble  *, xdouble *, blasint *,
		    xdouble *, blasint *);

int BLASFUNC(chpr) (char *, blasint *, float   *, float  *, blasint *, float  *);
int BLASFUNC(zhpr) (char *, blasint *, double  *, double *, blasint *, double *);
int BLASFUNC(xhpr) (char *, blasint *, xdouble  *, xdouble *, blasint *, xdouble *);

int BLASFUNC(cher2) (char *, blasint *, float   *, 
		     float  *, blasint *, float  *, blasint *, float  *, blasint *);
int BLASFUNC(zher2) (char *, blasint *, double  *, 
		     double *, blasint *, double *, blasint *, double *, blasint *);
int BLASFUNC(xher2) (char *, blasint *, xdouble  *, 
		     xdouble *, blasint *, xdouble *, blasint *, xdouble *, blasint *);

int BLASFUNC(chpr2) (char *, blasint *, float   *, 
		     float  *, blasint *, float  *, blasint *, float  *);
int BLASFUNC(zhpr2) (char *, blasint *, double  *, 
		     double *, blasint *, double *, blasint *, double *);
int BLASFUNC(xhpr2) (char *, blasint *, xdouble  *, 
		     xdouble *, blasint *, xdouble *, blasint *, xdouble *);

int BLASFUNC(chemv) (char *, blasint *, float  *, float *, blasint *, 
		     float  *, blasint *, float *, float *, blasint *);
int BLASFUNC(zhemv) (char *, blasint *, double  *, double *, blasint *, 
		     double  *, blasint *, double *, double *, blasint *);
int BLASFUNC(xhemv) (char *, blasint *, xdouble  *, xdouble *, blasint *, 
		     xdouble  *, blasint *, xdouble *, xdouble *, blasint *);

int BLASFUNC(chpmv) (char *, blasint *, float  *, float *,
		     float  *, blasint *, float *, float *, blasint *);
int BLASFUNC(zhpmv) (char *, blasint *, double  *, double *,
		     double  *, blasint *, double *, double *, blasint *);
int BLASFUNC(xhpmv) (char *, blasint *, xdouble  *, xdouble *,
		     xdouble  *, blasint *, xdouble *, xdouble *, blasint *);

int BLASFUNC(snorm)(char *, blasint *, blasint *, float  *, blasint *);
int BLASFUNC(dnorm)(char *, blasint *, blasint *, double *, blasint *);
int BLASFUNC(cnorm)(char *, blasint *, blasint *, float  *, blasint *);
int BLASFUNC(znorm)(char *, blasint *, blasint *, double *, blasint *);

int BLASFUNC(sgbmv)(char *, blasint *, blasint *, blasint *, blasint *, float  *, float  *, blasint *, 
		    float  *, blasint *, float  *, float  *, blasint *);
int BLASFUNC(dgbmv)(char *, blasint *, blasint *, blasint *, blasint *, double *, double *, blasint *, 
		    double *, blasint *, double *, double *, blasint *);
int BLASFUNC(qgbmv)(char *, blasint *, blasint *, blasint *, blasint *, xdouble *, xdouble *, blasint *, 
		    xdouble *, blasint *, xdouble *, xdouble *, blasint *);
int BLASFUNC(cgbmv)(char *, blasint *, blasint *, blasint *, blasint *, float  *, float  *, blasint *, 
		    float  *, blasint *, float  *, float  *, blasint *);
int BLASFUNC(zgbmv)(char *, blasint *, blasint *, blasint *, blasint *, double *, double *, blasint *, 
		    double *, blasint *, double *, double *, blasint *);
int BLASFUNC(xgbmv)(char *, blasint *, blasint *, blasint *, blasint *, xdouble *, xdouble *, blasint *, 
		    xdouble *, blasint *, xdouble *, xdouble *, blasint *);

int BLASFUNC(ssbmv)(char *, blasint *, blasint *, float  *, float  *, blasint *, 
		    float  *, blasint *, float  *, float  *, blasint *);
int BLASFUNC(dsbmv)(char *, blasint *, blasint *, double *, double *, blasint *, 
		    double *, blasint *, double *, double *, blasint *);
int BLASFUNC(qsbmv)(char *, blasint *, blasint *, xdouble *, xdouble *, blasint *, 
		    xdouble *, blasint *, xdouble *, xdouble *, blasint *);
int BLASFUNC(csbmv)(char *, blasint *, blasint *, float  *, float  *, blasint *, 
		    float  *, blasint *, float  *, float  *, blasint *);
int BLASFUNC(zsbmv)(char *, blasint *, blasint *, double *, double *, blasint *, 
		    double *, blasint *, double *, double *, blasint *);
int BLASFUNC(xsbmv)(char *, blasint *, blasint *, xdouble *, xdouble *, blasint *, 
		    xdouble *, blasint *, xdouble *, xdouble *, blasint *);

int BLASFUNC(chbmv)(char *, blasint *, blasint *, float  *, float  *, blasint *, 
		    float  *, blasint *, float  *, float  *, blasint *);
int BLASFUNC(zhbmv)(char *, blasint *, blasint *, double *, double *, blasint *, 
		    double *, blasint *, double *, double *, blasint *);
int BLASFUNC(xhbmv)(char *, blasint *, blasint *, xdouble *, xdouble *, blasint *, 
		    xdouble *, blasint *, xdouble *, xdouble *, blasint *);

/* Level 3 routines */

GEMMRETTYPE BLASFUNC(sgemm)(char *, char *, blasint *, blasint *, blasint *, float *,
	   float  *, blasint *, float  *, blasint *, float  *, float  *, blasint *);
GEMMRETTYPE BLASFUNC(dgemm)(char *, char *, blasint *, blasint *, blasint *, double *,
	   double *, blasint *, double *, blasint *, double *, double *, blasint *);
GEMMRETTYPE BLASFUNC(qgemm)(char *, char *, blasint *, blasint *, blasint *, xdouble *,
	   xdouble *, blasint *, xdouble *, blasint *, xdouble *, xdouble *, blasint *);
GEMMRETTYPE BLASFUNC(cgemm)(char *, char *, blasint *, blasint *, blasint *, float *,
	   float  *, blasint *, float  *, blasint *, float  *, float  *, blasint *);
GEMMRETTYPE BLASFUNC(zgemm)(char *, char *, blasint *, blasint *, blasint *, double *,
	   double *, blasint *, double *, blasint *, double *, double *, blasint *);
GEMMRETTYPE BLASFUNC(xgemm)(char *, char *, blasint *, blasint *, blasint *, xdouble *,
	   xdouble *, blasint *, xdouble *, blasint *, xdouble *, xdouble *, blasint *);

GEMMRETTYPE BLASFUNC(cgemm3m)(char *, char *, blasint *, blasint *, blasint *, float *,
	   float  *, blasint *, float  *, blasint *, float  *, float  *, blasint *);
GEMMRETTYPE BLASFUNC(zgemm3m)(char *, char *, blasint *, blasint *, blasint *, double *,
	   double *, blasint *, double *, blasint *, double *, double *, blasint *);
GEMMRETTYPE BLASFUNC(xgemm3m)(char *, char *, blasint *, blasint *, blasint *, xdouble *,
	   xdouble *, blasint *, xdouble *, blasint *, xdouble *, xdouble *, blasint *);

int BLASFUNC(sge2mm)(char *, char *, char *, blasint *, blasint *,
		     float *, float  *, blasint *, float  *, blasint *,
		     float *, float  *, blasint *);
int BLASFUNC(dge2mm)(char *, char *, char *, blasint *, blasint *,
		     double *, double  *, blasint *, double  *, blasint *,
		     double *, double  *, blasint *);
int BLASFUNC(cge2mm)(char *, char *, char *, blasint *, blasint *,
		     float *, float  *, blasint *, float  *, blasint *,
		     float *, float  *, blasint *);
int BLASFUNC(zge2mm)(char *, char *, char *, blasint *, blasint *,
		     double *, double  *, blasint *, double  *, blasint *,
		     double *, double  *, blasint *);

int BLASFUNC(strsm)(char *, char *, char *, char *, blasint *, blasint *,
	   float *,  float *, blasint *, float *, blasint *);
int BLASFUNC(dtrsm)(char *, char *, char *, char *, blasint *, blasint *,
	   double *,  double *, blasint *, double *, blasint *);
int BLASFUNC(qtrsm)(char *, char *, char *, char *, blasint *, blasint *,
	   xdouble *,  xdouble *, blasint *, xdouble *, blasint *);
int BLASFUNC(ctrsm)(char *, char *, char *, char *, blasint *, blasint *,
	   float *,  float *, blasint *, float *, blasint *);
int BLASFUNC(ztrsm)(char *, char *, char *, char *, blasint *, blasint *,
	   double *,  double *, blasint *, double *, blasint *);
int BLASFUNC(xtrsm)(char *, char *, char *, char *, blasint *, blasint *,
	   xdouble *,  xdouble *, blasint *, xdouble *, blasint *);

int BLASFUNC(strmm)(char *, char *, char *, char *, blasint *, blasint *,
	   float *,  float *, blasint *, float *, blasint *);
int BLASFUNC(dtrmm)(char *, char *, char *, char *, blasint *, blasint *,
	   double *,  double *, blasint *, double *, blasint *);
int BLASFUNC(qtrmm)(char *, char *, char *, char *, blasint *, blasint *,
	   xdouble *,  xdouble *, blasint *, xdouble *, blasint *);
int BLASFUNC(ctrmm)(char *, char *, char *, char *, blasint *, blasint *,
	   float *,  float *, blasint *, float *, blasint *);
int BLASFUNC(ztrmm)(char *, char *, char *, char *, blasint *, blasint *,
	   double *,  double *, blasint *, double *, blasint *);
int BLASFUNC(xtrmm)(char *, char *, char *, char *, blasint *, blasint *,
	   xdouble *,  xdouble *, blasint *, xdouble *, blasint *);

int BLASFUNC(ssymm)(char *, char *, blasint *, blasint *, float  *, float  *, blasint *,
	   float  *, blasint *, float  *, float  *, blasint *);
int BLASFUNC(dsymm)(char *, char *, blasint *, blasint *, double *, double *, blasint *,
	   double *, blasint *, double *, double *, blasint *);
int BLASFUNC(qsymm)(char *, char *, blasint *, blasint *, xdouble *, xdouble *, blasint *,
	   xdouble *, blasint *, xdouble *, xdouble *, blasint *);
int BLASFUNC(csymm)(char *, char *, blasint *, blasint *, float  *, float  *, blasint *,
	   float  *, blasint *, float  *, float  *, blasint *);
int BLASFUNC(zsymm)(char *, char *, blasint *, blasint *, double *, double *, blasint *,
	   double *, blasint *, double *, double *, blasint *);
int BLASFUNC(xsymm)(char *, char *, blasint *, blasint *, xdouble *, xdouble *, blasint *,
	   xdouble *, blasint *, xdouble *, xdouble *, blasint *);

int BLASFUNC(csymm3m)(char *, char *, blasint *, blasint *, float  *, float  *, blasint *,
	   float  *, blasint *, float  *, float  *, blasint *);
int BLASFUNC(zsymm3m)(char *, char *, blasint *, blasint *, double *, double *, blasint *,
	   double *, blasint *, double *, double *, blasint *);
int BLASFUNC(xsymm3m)(char *, char *, blasint *, blasint *, xdouble *, xdouble *, blasint *,
	   xdouble *, blasint *, xdouble *, xdouble *, blasint *);

int BLASFUNC(ssyrk)(char *, char *, blasint *, blasint *, float  *, float  *, blasint *,
	   float  *, float  *, blasint *);
int BLASFUNC(dsyrk)(char *, char *, blasint *, blasint *, double *, double *, blasint *,
	   double *, double *, blasint *);
int BLASFUNC(qsyrk)(char *, char *, blasint *, blasint *, xdouble *, xdouble *, blasint *,
	   xdouble *, xdouble *, blasint *);
int BLASFUNC(csyrk)(char *, char *, blasint *, blasint *, float  *, float  *, blasint *,
	   float  *, float  *, blasint *);
int BLASFUNC(zsyrk)(char *, char *, blasint *, blasint *, double *, double *, blasint *,
	   double *, double *, blasint *);
int BLASFUNC(xsyrk)(char *, char *, blasint *, blasint *, xdouble *, xdouble *, blasint *,
	   xdouble *, xdouble *, blasint *);

int BLASFUNC(ssyr2k)(char *, char *, blasint *, blasint *, float  *, float  *, blasint *,
	   float *, blasint *, float  *, float  *, blasint *);
int BLASFUNC(dsyr2k)(char *, char *, blasint *, blasint *, double *, double *, blasint *,
	   double*, blasint *, double *, double *, blasint *);
int BLASFUNC(qsyr2k)(char *, char *, blasint *, blasint *, xdouble *, xdouble *, blasint *,
	   xdouble*, blasint *, xdouble *, xdouble *, blasint *);
int BLASFUNC(csyr2k)(char *, char *, blasint *, blasint *, float  *, float  *, blasint *,
	   float *, blasint *, float  *, float  *, blasint *);
int BLASFUNC(zsyr2k)(char *, char *, blasint *, blasint *, double *, double *, blasint *,
	   double*, blasint *, double *, double *, blasint *);
int BLASFUNC(xsyr2k)(char *, char *, blasint *, blasint *, xdouble *, xdouble *, blasint *,
	   xdouble*, blasint *, xdouble *, xdouble *, blasint *);

int BLASFUNC(chemm)(char *, char *, blasint *, blasint *, float  *, float  *, blasint *,
	   float  *, blasint *, float  *, float  *, blasint *);
int BLASFUNC(zhemm)(char *, char *, blasint *, blasint *, double *, double *, blasint *,
	   double *, blasint *, double *, double *, blasint *);
int BLASFUNC(xhemm)(char *, char *, blasint *, blasint *, xdouble *, xdouble *, blasint *,
	   xdouble *, blasint *, xdouble *, xdouble *, blasint *);

int BLASFUNC(chemm3m)(char *, char *, blasint *, blasint *, float  *, float  *, blasint *,
	   float  *, blasint *, float  *, float  *, blasint *);
int BLASFUNC(zhemm3m)(char *, char *, blasint *, blasint *, double *, double *, blasint *,
	   double *, blasint *, double *, double *, blasint *);
int BLASFUNC(xhemm3m)(char *, char *, blasint *, blasint *, xdouble *, xdouble *, blasint *,
	   xdouble *, blasint *, xdouble *, xdouble *, blasint *);

int BLASFUNC(cherk)(char *, char *, blasint *, blasint *, float  *, float  *, blasint *,
	   float  *, float  *, blasint *);
int BLASFUNC(zherk)(char *, char *, blasint *, blasint *, double *, double *, blasint *,
	   double *, double *, blasint *);
int BLASFUNC(xherk)(char *, char *, blasint *, blasint *, xdouble *, xdouble *, blasint *,
	   xdouble *, xdouble *, blasint *);

int BLASFUNC(cher2k)(char *, char *, blasint *, blasint *, float  *, float  *, blasint *,
	   float *, blasint *, float  *, float  *, blasint *);
int BLASFUNC(zher2k)(char *, char *, blasint *, blasint *, double *, double *, blasint *,
	   double*, blasint *, double *, double *, blasint *);
int BLASFUNC(xher2k)(char *, char *, blasint *, blasint *, xdouble *, xdouble *, blasint *,
	   xdouble*, blasint *, xdouble *, xdouble *, blasint *);
int BLASFUNC(cher2m)(char *, char *, char *, blasint *, blasint *, float  *, float  *, blasint *,
	   float *, blasint *, float  *, float  *, blasint *);
int BLASFUNC(zher2m)(char *, char *, char *, blasint *, blasint *, double *, double *, blasint *,
	   double*, blasint *, double *, double *, blasint *);
int BLASFUNC(xher2m)(char *, char *, char *, blasint *, blasint *, xdouble *, xdouble *, blasint *,
	   xdouble*, blasint *, xdouble *, xdouble *, blasint *);

int BLASFUNC(sgemt)(char *, blasint *, blasint *, float  *, float  *, blasint *,
		    float  *, blasint *);
int BLASFUNC(dgemt)(char *, blasint *, blasint *, double *, double *, blasint *,
		    double *, blasint *);
int BLASFUNC(cgemt)(char *, blasint *, blasint *, float  *, float  *, blasint *, 
		    float  *, blasint *);
int BLASFUNC(zgemt)(char *, blasint *, blasint *, double *, double *, blasint *,
		    double *, blasint *);

int BLASFUNC(sgema)(char *, char *, blasint *, blasint *, float  *, 
		    float  *, blasint *, float *, float  *, blasint *, float *, blasint *);
int BLASFUNC(dgema)(char *, char *, blasint *, blasint *, double *,
		    double *, blasint *, double*, double *, blasint *, double*, blasint *);
int BLASFUNC(cgema)(char *, char *, blasint *, blasint *, float  *,
		    float  *, blasint *, float *, float  *, blasint *, float *, blasint *);
int BLASFUNC(zgema)(char *, char *, blasint *, blasint *, double *, 
		    double *, blasint *, double*, double *, blasint *, double*, blasint *);

int BLASFUNC(sgems)(char *, char *, blasint *, blasint *, float  *,
		    float  *, blasint *, float *, float  *, blasint *, float *, blasint *);
int BLASFUNC(dgems)(char *, char *, blasint *, blasint *, double *,
		    double *, blasint *, double*, double *, blasint *, double*, blasint *);
int BLASFUNC(cgems)(char *, char *, blasint *, blasint *, float  *,
		    float  *, blasint *, float *, float  *, blasint *, float *, blasint *);
int BLASFUNC(zgems)(char *, char *, blasint *, blasint *, double *,
		    double *, blasint *, double*, double *, blasint *, double*, blasint *);

int BLASFUNC(sgetf2)(blasint *, blasint *, float  *, blasint *, blasint *, blasint *);
int BLASFUNC(dgetf2)(blasint *, blasint *, double *, blasint *, blasint *, blasint *);
int BLASFUNC(qgetf2)(blasint *, blasint *, xdouble *, blasint *, blasint *, blasint *);
int BLASFUNC(cgetf2)(blasint *, blasint *, float  *, blasint *, blasint *, blasint *);
int BLASFUNC(zgetf2)(blasint *, blasint *, double *, blasint *, blasint *, blasint *);
int BLASFUNC(xgetf2)(blasint *, blasint *, xdouble *, blasint *, blasint *, blasint *);

int BLASFUNC(sgetrf)(blasint *, blasint *, float  *, blasint *, blasint *, blasint *);
int BLASFUNC(dgetrf)(blasint *, blasint *, double *, blasint *, blasint *, blasint *);
int BLASFUNC(qgetrf)(blasint *, blasint *, xdouble *, blasint *, blasint *, blasint *);
int BLASFUNC(cgetrf)(blasint *, blasint *, float  *, blasint *, blasint *, blasint *);
int BLASFUNC(zgetrf)(blasint *, blasint *, double *, blasint *, blasint *, blasint *);
int BLASFUNC(xgetrf)(blasint *, blasint *, xdouble *, blasint *, blasint *, blasint *);

int BLASFUNC(slaswp)(blasint *, float  *, blasint *, blasint *, blasint *, blasint *, blasint *);
int BLASFUNC(dlaswp)(blasint *, double *, blasint *, blasint *, blasint *, blasint *, blasint *);
int BLASFUNC(qlaswp)(blasint *, xdouble *, blasint *, blasint *, blasint *, blasint *, blasint *);
int BLASFUNC(claswp)(blasint *, float  *, blasint *, blasint *, blasint *, blasint *, blasint *);
int BLASFUNC(zlaswp)(blasint *, double *, blasint *, blasint *, blasint *, blasint *, blasint *);
int BLASFUNC(xlaswp)(blasint *, xdouble *, blasint *, blasint *, blasint *, blasint *, blasint *);

int BLASFUNC(sgetrs)(char *, blasint *, blasint *, float  *, blasint *, blasint *, float  *, blasint *, blasint *);
int BLASFUNC(dgetrs)(char *, blasint *, blasint *, double *, blasint *, blasint *, double *, blasint *, blasint *);
int BLASFUNC(qgetrs)(char *, blasint *, blasint *, xdouble *, blasint *, blasint *, xdouble *, blasint *, blasint *);
int BLASFUNC(cgetrs)(char *, blasint *, blasint *, float  *, blasint *, blasint *, float  *, blasint *, blasint *);
int BLASFUNC(zgetrs)(char *, blasint *, blasint *, double *, blasint *, blasint *, double *, blasint *, blasint *);
int BLASFUNC(xgetrs)(char *, blasint *, blasint *, xdouble *, blasint *, blasint *, xdouble *, blasint *, blasint *);

int BLASFUNC(sgesv)(blasint *, blasint *, float  *, blasint *, blasint *, float *, blasint *, blasint *);
int BLASFUNC(dgesv)(blasint *, blasint *, double *, blasint *, blasint *, double*, blasint *, blasint *);
int BLASFUNC(qgesv)(blasint *, blasint *, xdouble *, blasint *, blasint *, xdouble*, blasint *, blasint *);
int BLASFUNC(cgesv)(blasint *, blasint *, float  *, blasint *, blasint *, float *, blasint *, blasint *);
int BLASFUNC(zgesv)(blasint *, blasint *, double *, blasint *, blasint *, double*, blasint *, blasint *);
int BLASFUNC(xgesv)(blasint *, blasint *, xdouble *, blasint *, blasint *, xdouble*, blasint *, blasint *);

int BLASFUNC(spotf2)(char *, blasint *, float  *, blasint *, blasint *);
int BLASFUNC(dpotf2)(char *, blasint *, double *, blasint *, blasint *);
int BLASFUNC(qpotf2)(char *, blasint *, xdouble *, blasint *, blasint *);
int BLASFUNC(cpotf2)(char *, blasint *, float  *, blasint *, blasint *);
int BLASFUNC(zpotf2)(char *, blasint *, double *, blasint *, blasint *);
int BLASFUNC(xpotf2)(char *, blasint *, xdouble *, blasint *, blasint *);

int BLASFUNC(spotrf)(char *, blasint *, float  *, blasint *, blasint *);
int BLASFUNC(dpotrf)(char *, blasint *, double *, blasint *, blasint *);
int BLASFUNC(qpotrf)(char *, blasint *, xdouble *, blasint *, blasint *);
int BLASFUNC(cpotrf)(char *, blasint *, float  *, blasint *, blasint *);
int BLASFUNC(zpotrf)(char *, blasint *, double *, blasint *, blasint *);
int BLASFUNC(xpotrf)(char *, blasint *, xdouble *, blasint *, blasint *);

int BLASFUNC(slauu2)(char *, blasint *, float  *, blasint *, blasint *);
int BLASFUNC(dlauu2)(char *, blasint *, double *, blasint *, blasint *);
int BLASFUNC(qlauu2)(char *, blasint *, xdouble *, blasint *, blasint *);
int BLASFUNC(clauu2)(char *, blasint *, float  *, blasint *, blasint *);
int BLASFUNC(zlauu2)(char *, blasint *, double *, blasint *, blasint *);
int BLASFUNC(xlauu2)(char *, blasint *, xdouble *, blasint *, blasint *);

int BLASFUNC(slauum)(char *, blasint *, float  *, blasint *, blasint *);
int BLASFUNC(dlauum)(char *, blasint *, double *, blasint *, blasint *);
int BLASFUNC(qlauum)(char *, blasint *, xdouble *, blasint *, blasint *);
int BLASFUNC(clauum)(char *, blasint *, float  *, blasint *, blasint *);
int BLASFUNC(zlauum)(char *, blasint *, double *, blasint *, blasint *);
int BLASFUNC(xlauum)(char *, blasint *, xdouble *, blasint *, blasint *);

int BLASFUNC(strti2)(char *, char *, blasint *, float  *, blasint *, blasint *);
int BLASFUNC(dtrti2)(char *, char *, blasint *, double *, blasint *, blasint *);
int BLASFUNC(qtrti2)(char *, char *, blasint *, xdouble *, blasint *, blasint *);
int BLASFUNC(ctrti2)(char *, char *, blasint *, float  *, blasint *, blasint *);
int BLASFUNC(ztrti2)(char *, char *, blasint *, double *, blasint *, blasint *);
int BLASFUNC(xtrti2)(char *, char *, blasint *, xdouble *, blasint *, blasint *);

int BLASFUNC(strtri)(char *, char *, blasint *, float  *, blasint *, blasint *);
int BLASFUNC(dtrtri)(char *, char *, blasint *, double *, blasint *, blasint *);
int BLASFUNC(qtrtri)(char *, char *, blasint *, xdouble *, blasint *, blasint *);
int BLASFUNC(ctrtri)(char *, char *, blasint *, float  *, blasint *, blasint *);
int BLASFUNC(ztrtri)(char *, char *, blasint *, double *, blasint *, blasint *);
int BLASFUNC(xtrtri)(char *, char *, blasint *, xdouble *, blasint *, blasint *);

int BLASFUNC(spotri)(char *, blasint *, float  *, blasint *, blasint *);
int BLASFUNC(dpotri)(char *, blasint *, double *, blasint *, blasint *);
int BLASFUNC(qpotri)(char *, blasint *, xdouble *, blasint *, blasint *);
int BLASFUNC(cpotri)(char *, blasint *, float  *, blasint *, blasint *);
int BLASFUNC(zpotri)(char *, blasint *, double *, blasint *, blasint *);
int BLASFUNC(xpotri)(char *, blasint *, xdouble *, blasint *, blasint *);

#endif
