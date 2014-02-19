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
#define ERROR_NAME "XGBMV "
#elif defined(DOUBLE)
#define ERROR_NAME "ZGBMV "
#else
#define ERROR_NAME "CGBMV "
#endif

static void (*gbmv[])(BLASLONG, BLASLONG, BLASLONG, BLASLONG, FLOAT, FLOAT,
		      FLOAT *, BLASLONG, FLOAT *, BLASLONG, FLOAT *, BLASLONG, void *) = {
#ifdef XDOUBLE
      xgbmv_n, xgbmv_t, xgbmv_r, xgbmv_c,
      xgbmv_o, xgbmv_u, xgbmv_s, xgbmv_d,
#elif defined(DOUBLE)
      zgbmv_n, zgbmv_t, zgbmv_r, zgbmv_c,
      zgbmv_o, zgbmv_u, zgbmv_s, zgbmv_d,
#else
      cgbmv_n, cgbmv_t, cgbmv_r, cgbmv_c,
      cgbmv_o, cgbmv_u, cgbmv_s, cgbmv_d,
#endif
};

int NAME(char *TRANS, blasint *M, blasint *N,
	 blasint *KU, blasint *KL,
	 FLOAT *ALPHA, FLOAT *a, blasint *LDA,
	 FLOAT *x, blasint *INCX,
	 FLOAT *BETA, FLOAT *y, blasint *INCY){

  char trans = *TRANS;
  blasint m = *M;
  blasint n = *N;
  blasint ku = *KU;
  blasint kl = *KL;
  blasint lda = *LDA;
  blasint incx = *INCX;
  blasint incy = *INCY;
  FLOAT *buffer;

  FLOAT alpha_r = ALPHA[0];
  FLOAT alpha_i = ALPHA[1];
  FLOAT beta_r  = BETA[0];
  FLOAT beta_i  = BETA[1];

  blasint info;
  blasint lenx, leny;
  blasint i;

  TOUPPER(trans);

  info = 0;

  i = -1;

  if (trans == 'N')  i = 0;
  if (trans == 'T')  i = 1;
  if (trans == 'R')  i = 2;
  if (trans == 'C')  i = 3;
  if (trans == 'O')  i = 4;
  if (trans == 'U')  i = 5;
  if (trans == 'S')  i = 6;
  if (trans == 'D')  i = 7;

  if (incy == 0)	 info = 13;
  if (incx == 0)	 info = 10;
  if (lda < kl + ku + 1) info = 8;
  if (kl < 0)		 info = 5;
  if (ku < 0)		 info = 4;
  if (n < 0)		 info = 3;
  if (m < 0)		 info = 2;
  if (i < 0)		 info = 1;
  
  trans = i;

  if (info != 0){
    BLASFUNC(xerbla)(ERROR_NAME, &info, sizeof(ERROR_NAME));
    return 0;
  }

  if ((m==0) || (n==0)) return 0;

  lenx = n;
  leny = m;
  if (trans) lenx = m;
  if (trans) leny = n;

  if (incx < 0) x -= (lenx - 1) * incx * 2;
  if (incy < 0) y -= (leny - 1) * incy * 2;

  if (beta_r != ONE || beta_i != ZERO)
    ZSCAL_K(leny, 0, 0, beta_r, beta_i, y, incy, NULL, 0, NULL, 0);

  if (alpha_r == ZERO && alpha_i == ZERO) return 0;
  
  buffer = (FLOAT *)blas_memory_alloc(1);

  (gbmv[(int)trans])(m, n, kl, ku, alpha_r, alpha_i,
			      a, lda, x, incx, y, incy, buffer);

  blas_memory_free(buffer);

  return 0;
}
