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
#define ERROR_NAME "QTRSM "
#elif defined(DOUBLE)
#define ERROR_NAME "DTRSM "
#else
#define ERROR_NAME "STRSM "
#endif

static int (*trsm[])(BLASLONG, BLASLONG, BLASLONG, FLOAT, FLOAT *, BLASLONG, FLOAT *, BLASLONG, FLOAT *, BLASLONG, FLOAT *, FLOAT *) = {
#ifdef XDOUBLE
    qtrsm_LNUU, qtrsm_LNUN, qtrsm_LNLU, qtrsm_LNLN,
    qtrsm_LTUU, qtrsm_LTUN, qtrsm_LTLU, qtrsm_LTLN,
    qtrsm_RNUU, qtrsm_RNUN, qtrsm_RNLU, qtrsm_RNLN, 
    qtrsm_RTUU, qtrsm_RTUN, qtrsm_RTLU, qtrsm_RTLN,
#elif defined(DOUBLE)
    dtrsm_LNUU, dtrsm_LNUN, dtrsm_LNLU, dtrsm_LNLN,
    dtrsm_LTUU, dtrsm_LTUN, dtrsm_LTLU, dtrsm_LTLN,
    dtrsm_RNUU, dtrsm_RNUN, dtrsm_RNLU, dtrsm_RNLN, 
    dtrsm_RTUU, dtrsm_RTUN, dtrsm_RTLU, dtrsm_RTLN,
#else
    strsm_LNUU, strsm_LNUN, strsm_LNLU, strsm_LNLN,
    strsm_LTUU, strsm_LTUN, strsm_LTLU, strsm_LTLN,
    strsm_RNUU, strsm_RNUN, strsm_RNLU, strsm_RNLN, 
    strsm_RTUU, strsm_RTUN, strsm_RTLU, strsm_RTLN,
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
#ifdef PPC440
  extern
#endif
  FLOAT *sa, *sb;

#ifdef SMP
  int mode;
#endif

  blasint info;
  int side;
  int uplo;
  int unit;
  int trans;
  int nrowa;

  TOUPPER(side_arg);
  TOUPPER(uplo_arg);
  TOUPPER(trans_arg);
  TOUPPER(diag_arg);

  side  = -1;
  trans = -1;
  unit  = -1;
  uplo  = -1;

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
  
  if ((m == 0) || (n == 0)) return 0;

#ifdef SMP
  if (blas_cpu_number == 0) blas_get_cpu_number();
#ifdef SMP_SERVER
  if (blas_server_avail == 0) blas_thread_init();
#endif
#endif

#ifndef SMP
  if (alpha != ONE) GEMM_BETA(m, n, 0,  alpha, NULL, 0, NULL, 0, b, ldb);
#else

#ifdef XDOUBLE
  mode  =  BLAS_XDOUBLE | BLAS_REAL;
#elif defined(DOUBLE)
  mode  =  BLAS_DOUBLE  | BLAS_REAL;
#else
  mode  =  BLAS_SINGLE  | BLAS_REAL;
#endif  

  if (alpha != ONE)
    beta_thread(mode, m, n, alpha, ZERO, b, ldb, (void *)GEMM_BETA);

#endif

  if (alpha == ZERO) return 0;
  
#ifndef PPC440
  buffer = (FLOAT *)blas_memory_alloc(0);

  sa = (FLOAT *)((BLASLONG)buffer + GEMM_BUFFER_A_OFFSET);
  sb = (FLOAT *)(((BLASLONG)sa + ((GEMM_P * GEMM_Q * COMPSIZE * SIZE + GEMM_ALIGN) & ~GEMM_ALIGN)) + GEMM_BUFFER_B_OFFSET);
#endif

#ifndef SMP

  (trsm[(side<<3) | (trans<<2) | (uplo<<1) | unit])
    (m, n, 0, ZERO, a, lda, NULL, 0, b, ldb, sa, sb);

#else
  mode |= (trans << BLAS_TRANSA_SHIFT);
  mode |= (side  << BLAS_RSIDE_SHIFT);

  trsm_thread(mode, m, n, ZERO, ZERO,
	      a, lda, b, ldb, 
	      (void *)trsm[(side<<3) | (trans<<2) | (uplo<<1) | unit], buffer);

#endif

#ifndef PPC440
  blas_memory_free(buffer);
#endif

  return 0;
}

