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

#ifdef DOUBLE
#define ERROR_NAME "DGER  "
#else
#define ERROR_NAME "SGER  "
#endif

int NAME(blasint *M, blasint *N, FLOAT *Alpha,
	  FLOAT *x, blasint *INCX,
	  FLOAT *y, blasint *INCY,
	  FLOAT *a, blasint *LDA){

  blasint    m     = *M;
  blasint    n     = *N;
  FLOAT  alpha = *Alpha;
  blasint    incx  = *INCX;
  blasint    incy  = *INCY;
  blasint    lda   = *LDA;
  FLOAT *buffer;
#ifdef SMP
  int mode;
#endif

  blasint info;

  info = 0;

  if (lda < MAX(1,m)) info = 9;
  if (incy == 0)      info = 7;
  if (incx == 0)      info = 5;
  if (n < 0)          info = 2;
  if (m < 0)          info = 1;

  if (info){
    BLASFUNC(xerbla)(ERROR_NAME, &info, sizeof(ERROR_NAME));
    return 0;
  }
  
  /*     Quick return if possible. */
  if (m == 0 || n == 0) return 0;
  if (alpha == 0.) return 0;
  
  if (incy < 0) y -= (n - 1) * incy;
  if (incx < 0) x -= (m - 1) * incx;

#ifdef SMP
  if (blas_cpu_number == 0) blas_get_cpu_number();
#ifdef SMP_SERVER
  if (blas_server_avail == 0) blas_thread_init();
#endif
#endif

  buffer = (FLOAT *)blas_memory_alloc(1);

#ifndef SMP

  GER_K(m, n, 0, alpha, x, incx, y, incy, a, lda, buffer);

#else

  if (blas_omp_linked) {
    GER_K(m, n, 0, alpha, x, incx, y, incy, a, lda, buffer);
  } else {

#ifdef DOUBLE
    mode  =  BLAS_DOUBLE | BLAS_REAL;
#else
    mode  =  BLAS_SINGLE | BLAS_REAL;
#endif  
    
    ger_thread(mode, m, n, Alpha,
	       x, incx, y, incy, a, lda,
	       (void *)GER_K, buffer);
  }

#endif

  blas_memory_free(buffer);

  return 0;
}
