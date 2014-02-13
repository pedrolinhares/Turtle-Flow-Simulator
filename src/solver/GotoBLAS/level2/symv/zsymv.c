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
#include <ctype.h>
#include "common.h"

#ifdef XDOUBLE
#define ERROR_NAME "XSYMV "
#elif defined(DOUBLE)
#define ERROR_NAME "ZSYMV "
#else
#define ERROR_NAME "CSYMV "
#endif

static  int (*symv[])(BLASLONG, FLOAT, FLOAT, FLOAT *, BLASLONG, FLOAT *, BLASLONG, FLOAT *, BLASLONG, FLOAT *) = {
#ifdef XDOUBLE
  xsymv_U, xsymv_L,
#elif defined(DOUBLE)
  zsymv_U, zsymv_L,
#else
  csymv_U, csymv_L,
#endif
};

int NAME(char *UPLO, blasint *N, FLOAT  *ALPHA, FLOAT *a, blasint *LDA, 
            FLOAT  *b, blasint *INCX, FLOAT *BETA, FLOAT *c, blasint *INCY){

  char uplo_arg = *UPLO;
  blasint n		= *N;
  FLOAT alpha_r	= ALPHA[0];
  FLOAT alpha_i	= ALPHA[1];
  blasint lda	= *LDA;
  blasint incx	= *INCX;
  FLOAT beta_r	= BETA[0];
  FLOAT beta_i	= BETA[1];
  blasint incy	= *INCY;

  blasint info;
  int uplo;
  FLOAT *buffer;

  TOUPPER(uplo_arg);
  uplo  = -1;

  if (uplo_arg  == 'U') uplo  = 0;
  if (uplo_arg  == 'L') uplo  = 1;
 
  info = 0;

  if (incy == 0)          info = 10;
  if (incx == 0)          info =  7;
  if (lda  < MAX(1, n))   info =  5;
  if (n < 0)              info =  2;
  if (uplo  < 0)          info =  1;

  if (info != 0) {
    BLASFUNC(xerbla)(ERROR_NAME, &info, sizeof(ERROR_NAME));
    return 0;
  }
  
  if (n == 0) return 0;

  if ((beta_r != ONE) || (beta_i != ZERO)) ZSCAL_K(n, 0, 0, beta_r, beta_i, c, abs(incy), NULL, 0, NULL, 0);

  if (incx < 0 ) b -= (n - 1) * incx * COMPSIZE;
  if (incy < 0 ) c -= (n - 1) * incy * COMPSIZE;

  if ((alpha_r == ZERO) && (alpha_i == ZERO)) return 0;

  buffer = (FLOAT *)blas_memory_alloc(1);

  (symv[uplo])(n, alpha_r, alpha_i, a, lda, b, incx, c, incy, buffer);

  blas_memory_free(buffer);
  return 0;
}
