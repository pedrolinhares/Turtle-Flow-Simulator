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

#ifdef XDOUBLE
#define ERROR_NAME "XGEMV "
#elif defined(DOUBLE)
#define ERROR_NAME "ZGEMV "
#else
#define ERROR_NAME "CGEMV "
#endif

static void (*gemv[])(BLASLONG, BLASLONG, BLASLONG, FLOAT, FLOAT, FLOAT *, BLASLONG,
		     FLOAT * , BLASLONG, FLOAT *, BLASLONG, void *) = {
#ifdef XDOUBLE
      xgemv_n, xgemv_t, xgemv_r, xgemv_c,
      xgemv_o, xgemv_u, xgemv_s, xgemv_d,
#elif defined(DOUBLE)
      zgemv_n, zgemv_t, zgemv_r, zgemv_c,
      zgemv_o, zgemv_u, zgemv_s, zgemv_d,
#else
      cgemv_n, cgemv_t, cgemv_r, cgemv_c,
      cgemv_o, cgemv_u, cgemv_s, cgemv_d,
#endif
};

int NAME(char *TRANS, blasint *M, blasint *N,
	   FLOAT *ALPHA, FLOAT *a, blasint *LDA,
	   FLOAT *x, blasint *INCX,
	   FLOAT *BETA,  FLOAT *y, blasint *INCY){

  char trans = *TRANS;
  blasint m = *M;
  blasint n = *N;
  blasint lda = *LDA;
  blasint incx = *INCX;
  blasint incy = *INCY;
  FLOAT *buffer;

  blasint    info;
  blasint    lenx, leny;
  blasint    i;

#ifdef SMP
  int mode;
#endif

  FLOAT alpha_r = *(ALPHA + 0);
  FLOAT alpha_i = *(ALPHA + 1);

  FLOAT beta_r  = *(BETA + 0);
  FLOAT beta_i  = *(BETA + 1);

  TOUPPER(trans);

  info = 0;

  i    = -1;

  if (trans == 'N')  i = 0;
  if (trans == 'T')  i = 1;
  if (trans == 'R')  i = 2;
  if (trans == 'C')  i = 3;
  if (trans == 'O')  i = 4;
  if (trans == 'U')  i = 5;
  if (trans == 'S')  i = 6;
  if (trans == 'D')  i = 7;

  if (incy == 0)      info = 11;
  if (incx == 0)      info = 8;
  if (lda < MAX(1,m)) info = 6;
  if (n < 0) 	      info = 3;
  if (m < 0) 	      info = 2;
  if (i < 0)          info = 1;

  trans = i;

  if (info != 0) {
    BLASFUNC(xerbla)(ERROR_NAME, &info, sizeof(ERROR_NAME));
    return 0;
  }
  
  /*  Quick return if possible. */

  if (m == 0 || n == 0) return 0;

  lenx = n;
  leny = m;

  if (trans & 1) lenx = m;
  if (trans & 1) leny = n;

  if (incx < 0) x -= (lenx - 1) * incx * 2;
  if (incy < 0) y -= (leny - 1) * incy * 2;

#ifdef SMP
  if (blas_cpu_number == 0) blas_get_cpu_number();
#ifdef SMP_SERVER
  if (blas_server_avail == 0) blas_thread_init();
#endif
#endif

  if (beta_r != ONE || beta_i != ZERO)
    ZSCAL_K(leny, 0, 0, beta_r, beta_i, y, incy, NULL, 0, NULL, 0);

  if (alpha_r == ZERO && alpha_i == ZERO) return 0;

  buffer = (FLOAT *)blas_memory_alloc(1);

#ifndef SMP
  (gemv[(int)trans])(m, n, 0, alpha_r, alpha_i,
			      a, lda, x, incx, y, incy, buffer);
#else

  if (blas_omp_linked) {
    (gemv[(int)trans])(m, n, 0, alpha_r, alpha_i,
		       a, lda, x, incx, y, incy, buffer);
  } else {

#ifdef XDOUBLE
    mode  =  BLAS_XDOUBLE | BLAS_COMPLEX;
#elif defined(DOUBLE)
    mode  =  BLAS_DOUBLE  | BLAS_COMPLEX;
#else
    mode  =  BLAS_SINGLE  | BLAS_COMPLEX;
#endif  
  
    mode |= (trans << BLAS_TRANSA_SHIFT);

    gemv_thread(mode, m, n, (void *)ALPHA,
		a, lda, x, incx, y, incy, 
		(void *)gemv[trans], buffer);
  }

#endif

  blas_memory_free(buffer);

  return 0;
}
