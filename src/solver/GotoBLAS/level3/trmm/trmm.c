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
#define ERROR_NAME "QTRMM "
#elif defined(DOUBLE)
#define ERROR_NAME "DTRMM "
#else
#define ERROR_NAME "STRMM "
#endif

static int (*trmm[])(blas_arg_t *, void *, void *, FLOAT *, FLOAT *, BLASLONG) = {
#ifdef XDOUBLE
    qtrmm_LNUU, qtrmm_LNUN, qtrmm_LNLU, qtrmm_LNLN,
    qtrmm_LTUU, qtrmm_LTUN, qtrmm_LTLU, qtrmm_LTLN,
    qtrmm_RNUU, qtrmm_RNUN, qtrmm_RNLU, qtrmm_RNLN, 
    qtrmm_RTUU, qtrmm_RTUN, qtrmm_RTLU, qtrmm_RTLN,
#elif defined(DOUBLE)
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
	   blasint *M, blasint *N, FLOAT *alpha,
	   FLOAT *a, blasint *ldA, FLOAT *b, blasint *ldB){
  
  char side_arg  = *SIDE;
  char uplo_arg  = *UPLO;
  char trans_arg = *TRANS;
  char diag_arg  = *DIAG;
  
  blas_arg_t args;

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

  args.m = *M;
  args.n = *N;

  args.a = (void *)a;
  args.b = (void *)b;

  args.lda = *ldA;
  args.ldb = *ldB;

  args.beta = (void *)alpha;

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
  
  nrowa = args.m;
  if (side & 1) nrowa = args.n;

  info = 0;

  if (args.ldb < MAX(1,args.m)) info = 11;
  if (args.lda < MAX(1,nrowa))  info =  9;
  if (args.n < 0)               info =  6;
  if (args.m < 0)               info =  5;
  if (unit < 0)                 info =  4;
  if (trans < 0)                info =  3;
  if (uplo  < 0)                info =  2;
  if (side  < 0)                info =  1;

  if (info != 0) {
    BLASFUNC(xerbla)(ERROR_NAME, &info, sizeof(ERROR_NAME));
    return 0;
  }
  
  if ((args.m == 0) || (args.n == 0)) return 0;

#ifdef SMP
  if (blas_cpu_number == 0) blas_get_cpu_number();
#ifdef SMP_SERVER
  if (blas_server_avail == 0) blas_thread_init();
#endif

  args.common = NULL;
  args.nthreads = blas_cpu_number;
#endif

#ifndef PPC440
  buffer = (FLOAT *)blas_memory_alloc(0);

  sa = (FLOAT *)((BLASLONG)buffer + GEMM_BUFFER_A_OFFSET);
  sb = (FLOAT *)(((BLASLONG)sa + ((GEMM_P * GEMM_Q * COMPSIZE * SIZE + GEMM_ALIGN) & ~GEMM_ALIGN)) + GEMM_BUFFER_B_OFFSET);
#endif

#ifndef SMP  

  (trmm[(side<<3) | (trans<<2) | (uplo<<1) | unit])(&args, NULL, NULL, sa, sb, 0);

#else
#ifdef XDOUBLE
  mode  =  BLAS_XDOUBLE | BLAS_REAL;
#elif defined(DOUBLE)
  mode  =  BLAS_DOUBLE  | BLAS_REAL;
#else
  mode  =  BLAS_SINGLE  | BLAS_REAL;
#endif  

  mode |= (trans << BLAS_TRANSA_SHIFT);
  mode |= (side  << BLAS_RSIDE_SHIFT);

  if (!side) {
    gemm_thread_n(mode, &args, NULL, NULL, (void *)trmm[(side<<3) | (trans<<2) | (uplo<<1) | unit], sa, sb, blas_cpu_number);
  } else {
    gemm_thread_m(mode, &args, NULL, NULL, (void *)trmm[(side<<3) | (trans<<2) | (uplo<<1) | unit], sa, sb, blas_cpu_number);
  }

#endif

#ifndef PPC440
  blas_memory_free(buffer);
#endif

  return 0;
}

