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

#ifdef F_INTERFACE
blasint NAME(blasint *N, FLOAT *dx, blasint *INCX){

  blasint n = *N;
  blasint incx = *INCX;
#else
BLASLONG CNAME(BLASLONG n, FLOAT *dx, BLASLONG incx){
#endif

  BLASLONG ret_val;
  BLASLONG i;

  FLOAT d1, dmax;

  if (n < 1 || incx <= 0) return 0;

  if (n == 1) return 1;

  ret_val = 0;

  dmax = *dx;
  dx += incx;

  for (i = 1; i < n; i++){
    d1 = *dx;
    dx += incx;
    if (d1 > dmax) {
      ret_val = i;
      dmax = d1;
    }
  }

  return ret_val + 1; 
}
