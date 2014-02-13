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
#define ERROR_NAME "ZTRMM "
#else
#define ERROR_NAME "CTRMM "
#endif

static int (*trmm[])(BLASLONG, BLASLONG, BLASLONG, FLOAT, FLOAT, FLOAT *, BLASLONG, FLOAT *, BLASLONG, FLOAT *, BLASLONG, FLOAT *) = {
#ifdef DOUBLE
    ztrmm_LNUU, ztrmm_LNUN, ztrmm_LNLU, ztrmm_LNLN,
    ztrmm_LTUU, ztrmm_LTUN, ztrmm_LTLU, ztrmm_LTLN,
    ztrmm_LRUU, ztrmm_LRUN, ztrmm_LRLU, ztrmm_LRLN,
    ztrmm_LCUU, ztrmm_LCUN, ztrmm_LCLU, ztrmm_LCLN,
    ztrmm_RNUU, ztrmm_RNUN, ztrmm_RNLU, ztrmm_RNLN, 
    ztrmm_RTUU, ztrmm_RTUN, ztrmm_RTLU, ztrmm_RTLN,
    ztrmm_RRUU, ztrmm_RRUN, ztrmm_RRLU, ztrmm_RRLN, 
    ztrmm_RCUU, ztrmm_RCUN, ztrmm_RCLU, ztrmm_RCLN,
#else
    ctrmm_LNUU, ctrmm_LNUN, ctrmm_LNLU, ctrmm_LNLN,
    ctrmm_LTUU, ctrmm_LTUN, ctrmm_LTLU, ctrmm_LTLN,
    ctrmm_LRUU, ctrmm_LRUN, ctrmm_LRLU, ctrmm_LRLN,
    ctrmm_LCUU, ctrmm_LCUN, ctrmm_LCLU, ctrmm_LCLN,
    ctrmm_RNUU, ctrmm_RNUN, ctrmm_RNLU, ctrmm_RNLN, 
    ctrmm_RTUU, ctrmm_RTUN, ctrmm_RTLU, ctrmm_RTLN,
    ctrmm_RRUU, ctrmm_RRUN, ctrmm_RRLU, ctrmm_RRLN, 
    ctrmm_RCUU, ctrmm_RCUN, ctrmm_RCLU, ctrmm_RCLN,
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

#ifdef SMP
  int  mode;
#endif

  blasint info;
  int side;
  int uplo;
  int unit;
  int trans;
  int nrowa;

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

  buffer = (FLOAT *)blas_memory_alloc(0);

#ifndef SMP

  (trmm[(side<<4) | (trans<<2) | (uplo<<1) | unit])
    (m, n, 0, ZERO, ZERO, a, lda, NULL, 0, b, ldb, buffer);

#else
  mode |= (trans << BLAS_TRANSA_SHIFT);
  mode |= (side  << BLAS_RSIDE_SHIFT);

  trsm_thread(mode, m, n, ZERO, ZERO,
	      a, lda, b, ldb, 
	      (void *)trmm[(side<<4) | (trans<<2) | (uplo<<1) | unit], buffer);

#endif

  blas_memory_free(buffer);

  return 0;
}
