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

#include <stdio.h>
#include "common.h"

#undef SMP

int NAME(blasint *N, FLOAT *ALPHA, FLOAT *x, blasint *INCX){
  
  blasint n    = *N;
  blasint incx = *INCX;
  FLOAT alpha_r = *(ALPHA + 0);
#ifndef SSCAL
  FLOAT alpha_i = *(ALPHA + 1);
#else
  FLOAT alpha_i = ZERO;
#endif

#ifdef SMP
  int mode;
#endif

  if (incx <= 0 || n <= 0) return 0;

  if ((alpha_r == ONE) && (alpha_i == ZERO)) return 0;


#ifdef SMP
  if (blas_cpu_number == 0) blas_get_cpu_number();
#ifdef SMP_SERVER
  if (blas_server_avail == 0) blas_thread_init();
#endif
#endif

#ifndef SMP

  ZSCAL_K(n, 0, 0, alpha_r, alpha_i, x, incx, NULL, 0, NULL, 0);

#else

  if (blas_omp_linked) {
    ZSCAL_K(n, 0, 0, alpha_r, alpha_i, x, incx, NULL, 0, NULL, 0);
  } else {
#ifdef DOUBLE
    mode  =  BLAS_DOUBLE | BLAS_COMPLEX;
#else
    mode  =  BLAS_SINGLE | BLAS_COMPLEX;
#endif  
    
    blas_level1_thread(mode, n, 0, 0, ALPHA, 
		       x, incx, NULL, 0, NULL, 0, (void *)ZSCAL_K);
  }
#endif

  return 0;
  
}
