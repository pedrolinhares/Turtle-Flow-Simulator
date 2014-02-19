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

#ifdef DOUBLE
#define ERROR_NAME "DTRMM "
#else
#define ERROR_NAME "STRMM "
#endif

static int (*trmm[])(BLASLONG, BLASLONG, BLASLONG, FLOAT, FLOAT *, BLASLONG, FLOAT *, BLASLONG, FLOAT *, BLASLONG, FLOAT *) = {
#ifdef DOUBLE
    dtrmm_LNUU, dtrmm_LNUN, dtrmm_LNLU, dtrmm_LNLN,
    dtrmm_LTUU, dtrmm_LTUN, dtrmm_LTLU, dtrmm_LTLN,
    dtrmm_RNUU, dtrmm_RNUN, dtrmm_RNLU, dtrmm_RNLN, 
    dtrmm_RTUU, dtrmm_RTUN, dtrmm_RTLU, dtrmm_RTLN,
#else
    strmm_LNUU, strmm_LNUN, strmm_LNLU, strmm_LNLN,
    strmm_LTUU, strmm_LTUN, strmm_LTLU, strmm_LTLN,
    strmm_RNUU, strmm_RNUN, strmm_RNLU, strmm_RNLN, 
    strmm_RTUU, strmm_RTUN, strmm_RTLU, strmm_RTLN,
#endif
  };

int NAME(char *SIDE, char *UPLO, char *TRANS, char *DIAG,
	   blasint *M, blasint *N, FLOAT *ALPHA,
	   FLOAT *a, blasint *LDA, FLOAT *b, blasint *LDB){
  
  char side_arg  = *SIDE;
  char uplo_arg  = *UPLO;
  char trans_arg = *TRANS;
  char diag_arg  = *DIAG;
  
  blasint m = *M;
  blasint n = *N;
  FLOAT alpha = *ALPHA;
  blasint lda = *LDA;
  blasint ldb = *LDB;
  FLOAT *buffer;

#ifdef SMP
  int mode;
#endif

  blasint info;
  int side;
  int uplo;
  int unit;
  int trans;
  int nrowa;

#if 0
  int i, j;
  for (j = 0; j < m; j ++) {
    for (i = 0; i < m; i ++) {
      printf("A[%3d, %3d] = %16.10e\n", i, j, a[i + j * lda]);
    }
  }

  for (j = 0; j < n; j ++) {
    for (i = 0; i < m; i ++) {
      printf("B[%3d, %3d] = %16.10e\n", i, j, b[i + j * ldb]);
    }
  }

  printf("\n");
#endif

  side  = -1;
  trans = -1;
  unit  = -1;
  uplo  = -1;

  TOUPPER(side_arg);
  TOUPPER(uplo_arg);
  TOUPPER(trans_arg);
  TOUPPER(diag_arg);

  if (side_arg  == 'L') side  = 0;
  if (side_arg  == 'R') side  = 1;

  if (trans_arg == 'N') trans = 0;
  if (trans_arg == 'T') trans = 1;
  if (trans_arg == 'R') trans = 0;
  if (trans_arg == 'C') trans = 1;

  if (diag_arg  == 'U') unit  = 0;
  if (diag_arg  == 'N') unit  = 1;

  if (uplo_arg  == 'U') uplo  = 0;
  if (uplo_arg  == 'L') uplo  = 1;
  
  nrowa = m;
  if (side & 1) nrowa = n;

  info = 0;

  if (ldb < MAX(1,m))     info = 11;
  if (lda < MAX(1,nrowa)) info =  9;
  if (n < 0)              info =  6;
  if (m < 0)              info =  5;
  if (unit < 0)           info =  4;
  if (trans < 0)          info =  3;
  if (uplo  < 0)          info =  2;
  if (side  < 0)          info =  1;

  if (info != 0) {
    BLASFUNC(xerbla)(ERROR_NAME, &info, sizeof(ERROR_NAME));
      return 0;
  }
  
  if (n == 0) return 0;
  
#ifdef SMP
  if (blas_cpu_number == 0) blas_get_cpu_number();
#ifdef SMP_SERVER
  if (blas_server_avail == 0) blas_thread_init();
#endif
#endif

#ifndef SMP
  if (alpha != ONE) GEMM_BETA(m, n, 0,  alpha, NULL, 0, NULL, 0, b, ldb);
#else

#ifdef DOUBLE
  mode  =  BLAS_DOUBLE | BLAS_REAL;
#else
  mode  =  BLAS_SINGLE | BLAS_REAL;
#endif  

  if (alpha != ONE)
    beta_thread(mode, m, n, alpha, ZERO, b, ldb, (void *)GEMM_BETA);

#endif

  if (alpha == ZERO) return 0;

  buffer = (FLOAT *)blas_memory_alloc(0);

#ifndef SMP  

  (trmm[(side<<3) | (trans<<2) | (uplo<<1) | unit])
    (m, n, 0, ZERO, a, lda, NULL, 0, b, ldb, buffer);

#else
  mode |= (trans << BLAS_TRANSA_SHIFT);
  mode |= (side  << BLAS_RSIDE_SHIFT);

  trsm_thread(mode, m, n, ZERO, ZERO,
	      a, lda, b, ldb, 
	      (void *)trmm[(side<<3) | (trans<<2) | (uplo<<1) | unit], buffer);

#endif

  blas_memory_free(buffer);

  return 0;
}

