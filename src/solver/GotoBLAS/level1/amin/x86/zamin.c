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

#include "common.h"
double fabs(double);

#ifdef XDOUBLE
#define RETURNTYPE xdouble
#elif defined(DOUBLE)
#define RETURNTYPE double
#else
#define RETURNTYPE FLOATRET
#endif

#ifdef F_INTERFACE
RETURNTYPE NAME(blasint *N, FLOAT *dx, blasint *INCX){

  blasint n = *N;
  blasint incx = *INCX;
#else
FLOAT CNAME(BLASLONG n, FLOAT *dx, BLASLONG incx){
#endif

  BLASLONG i;

  FLOAT dmax, d1;

  if (n < 1 || incx <= 0) return 0.;
  incx *= 2;

  dmax = fabs(dx[0]) + fabs(dx[1]);
  dx += incx;

  if (n == 1) return dmax;

  i = n - 1;

  do {
    d1 = fabs(dx[0]) + fabs(dx[1]);
    dx += incx;
    if (d1 < dmax) dmax = d1;
    i --;
  } while (i > 0);

 return dmax;
}
