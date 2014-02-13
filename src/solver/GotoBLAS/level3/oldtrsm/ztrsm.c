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
#define ERROR_NAME "XTRSM "
#elif defined(DOUBLE)
#define ERROR_NAME "ZTRSM "
#else
#define ERROR_NAME "CTRSM "
#endif

static int (*trsm[])(BLASLONG, BLASLONG, BLASLONG, FLOAT, FLOAT, FLOAT *, BLASLONG, FLOAT *, BLASLONG, FLOAT *, BLASLONG, FLOAT *, FLOAT *) = {
#ifdef XDOUBLE
    xtrsm_LNUU, xtrsm_LNUN, xtrsm_LNLU, xtrsm_LNLN,
    xtrsm_LTUU, xtrsm_LTUN, xtrsm_LTLU, xtrsm_LTLN,
    xtrsm_LRUU, xtrsm_LRUN, xtrsm_LRLU, xtrsm_LRLN,
    xtrsm_LCUU, xtrsm_LCUN, xtrsm_LCLU, xtrsm_LCLN,
    xtrsm_RNUU, xtrsm_RNUN, xtrsm_RNLU, xtrsm_RNLN, 
    xtrsm_RTUU, xtrsm_RTUN, xtrsm_RTLU, xtrsm_RTLN,
    xtrsm_RRUU, xtrsm_RRUN, xtrsm_RRLU, xtrsm_RRLN, 
    xtrsm_RCUU, xtrsm_RCUN, xtrsm_RCLU, xtrsm_RCLN,
#elif defined(DOUBLE)
    ztrsm_LNUU, ztrsm_LNUN, ztrsm_LNLU, ztrsm_LNLN,
    ztrsm_LTUU, ztrsm_LTUN, ztrsm_LTLU, ztrsm_LTLN,
    ztrsm_LRUU, ztrsm_LRUN, ztrsm_LRLU, ztrsm_LRLN,
    ztrsm_LCUU, ztrsm_LCUN, ztrsm_LCLU, ztrsm_LCLN,
    ztrsm_RNUU, ztrsm_RNUN, ztrsm_RNLU, ztrsm_RNLN, 
    ztrsm_RTUU, ztrsm_RTUN, ztrsm_RTLU, ztrsm_RTLN,
    ztrsm_RRUU, ztrsm_RRUN, ztrsm_RRLU, ztrsm_RRLN, 
    ztrsm_RCUU, ztrsm_RCUN, ztrsm_RCLU, ztrsm_RCLN,
#else
    ctrsm_LNUU, ctrsm_LNUN, ctrsm_LNLU, ctrsm_LNLN,
    ctrsm_LTUU, ctrsm_LTUN, ctrsm_LTLU, ctrsm_LTLN,
    ctrsm_LRUU, ctrsm_LRUN, ctrsm_LRLU, ctrsm_LRLN,
    ctrsm_LCUU, ctrsm_LCUN, ctrsm_LCLU, ctrsm_LCLN,
    ctrsm_RNUU, ctrsm_RNUN, ctrsm_RNLU, ctrsm_RNLN, 
    ctrsm_RTUU, ctrsm_RTUN, ctrsm_RTLU, ctrsm_RTLN,
    ctrsm_RRUU, ctrsm_RRUN, ctrsm_RRLU, ctrsm_RRLN, 
    ctrsm_RCUU, ctrsm_RCUN, ctrsm_RCLU, ctrsm_RCLN,
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
  FLOAT alpha_r = ALPHA[0];
  FLOAT alpha_i = ALPHA[1];
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
  if (trans_arg == 'R') trans = 2;
  if (trans_arg == 'C') trans = 3;

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

  if ((alpha_r != ONE) || (alpha_i != ZERO))
    GEMM_BETA(m, n, 0, alpha_r, alpha_i, NULL, 0, NULL, 0, b, ldb);

#else

#ifdef DOUBLE
  mode  =  BLAS_DOUBLE | BLAS_COMPLEX;
#else
  mode  =  BLAS_SINGLE | BLAS_COMPLEX; 
#endif  
  
  if ((alpha_r != ONE) || (alpha_i != ZERO))
    beta_thread(mode, m, n, alpha_r, alpha_i, b, ldb, (void *)GEMM_BETA);

#endif

  if ((alpha_r == ZERO) && (alpha_i == ZERO))  return 0;

#ifndef PPC440
  buffer = (FLOAT *)blas_memory_alloc(0);

  sa = (FLOAT *)((BLASLONG)buffer + GEMM_BUFFER_A_OFFSET);
  sb = (FLOAT *)(((BLASLONG)sa + ((GEMM_P * GEMM_Q * COMPSIZE * SIZE + GEMM_ALIGN) & ~GEMM_ALIGN)) + GEMM_BUFFER_B_OFFSET);
#endif

#ifndef SMP

  (trsm[(side<<4) | (trans<<2) | (uplo<<1) | unit])
    (m, n, 0, ZERO, ZERO, a, lda, NULL, 0, b, ldb, sa, sb);

#else
  mode |= (trans << BLAS_TRANSA_SHIFT);
  mode |= (side  << BLAS_RSIDE_SHIFT);

  trsm_thread(mode, m, n, ZERO, ZERO,
	      a, lda, b, ldb, 
	      (void *)trsm[(side<<4) | (trans<<2) | (uplo<<1) | unit], buffer);

#endif

#ifndef PPC440
  blas_memory_free(buffer);
#endif

  return 0;
}
