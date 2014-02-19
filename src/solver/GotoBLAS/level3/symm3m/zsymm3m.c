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
#define ERROR_NAME "XSYMM3M "
#elif defined(DOUBLE)
#define ERROR_NAME "ZSYMM3M "
#else
#define ERROR_NAME "CSYMM3M "
#endif

static int (*symm3m[])(blas_arg_t *, void *, void *, FLOAT *, FLOAT *, BLASLONG) = {
#if defined(SMP) && !defined(USE_SIMPLE_THREADED_LEVEL3)
#ifdef XDOUBLE
    xsymm3m_thread_LU, xsymm3m_thread_LL, xsymm3m_thread_RU, xsymm3m_thread_RL,
#elif defined(DOUBLE)
    zsymm3m_thread_LU, zsymm3m_thread_LL, zsymm3m_thread_RU, zsymm3m_thread_RL,
#else
    csymm3m_thread_LU, csymm3m_thread_LL, csymm3m_thread_RU, csymm3m_thread_RL,
#endif
#else
#ifdef XDOUBLE
    xsymm3m_LU, xsymm3m_LL, xsymm3m_RU, xsymm3m_RL,
#elif defined(DOUBLE)
    zsymm3m_LU, zsymm3m_LL, zsymm3m_RU, zsymm3m_RL,
#else
    csymm3m_LU, csymm3m_LL, csymm3m_RU, csymm3m_RL,
#endif
#endif
};

int NAME(char *SIDE, char *UPLO, 
         blasint *M, blasint *N, 
         FLOAT *alpha, FLOAT *a, blasint *ldA, 
         FLOAT *b, blasint *ldB, 
         FLOAT *beta,  FLOAT *c, blasint *ldC){
  
  char side_arg  = *SIDE;
  char uplo_arg  = *UPLO;

  blas_arg_t args;

  FLOAT *buffer;
#ifdef PPC440
  extern
#endif
  FLOAT *sa, *sb;

#if defined(SMP) && defined(USE_SIMPLE_THREADED_LEVEL3)
  int mode;
#endif

  blasint info;
  int side;
  int uplo;

  args.alpha = (void *)alpha;
  args.beta  = (void *)beta;

  TOUPPER(side_arg);
  TOUPPER(uplo_arg);

  side  = -1;
  uplo  = -1;

  if (side_arg  == 'L') side  = 0;
  if (side_arg  == 'R') side  = 1;

  if (uplo_arg  == 'U') uplo  = 0;
  if (uplo_arg  == 'L') uplo  = 1;
  
  args.m = *M;
  args.n = *N;

  args.c = (void *)c;
  args.ldc = *ldC;
    
  info = 0;

  if (args.ldc < MAX(1, args.m)) info = 12;

  if (!side) {
    args.a = (void *)a;
    args.b = (void *)b;
    
    args.lda = *ldA;
    args.ldb = *ldB;
    
    if (args.ldb < MAX(1, args.m)) info =  9;
    if (args.lda < MAX(1, args.m)) info =  7;

  } else {
    args.a = (void *)b;
    args.b = (void *)a;
    
    args.lda = *ldB;
    args.ldb = *ldA;

  if (args.lda < MAX(1, args.m)) info =  9;
  if (args.ldb < MAX(1, args.n)) info =  7;
  }

  if (args.n   < 0)              info =  4;
  if (args.m   < 0)              info =  3;
  if (uplo     < 0)              info =  2;
  if (side     < 0)              info =  1;

  if (info != 0) {
    BLASFUNC(xerbla)(ERROR_NAME, &info, sizeof(ERROR_NAME));
    return 0;
  }
  
  if (args.m == 0 || args.n == 0) return 0;
  
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
  sb = (FLOAT *)(((BLASLONG)sa + ((GEMM3M_P * GEMM3M_Q * SIZE + GEMM_ALIGN) & ~GEMM_ALIGN)) + GEMM_BUFFER_B_OFFSET);
#endif

#if !defined(SMP) || !defined(USE_SIMPLE_THREADED_LEVEL3)
  (symm3m[(side << 1) | uplo ])(&args, NULL, NULL, sa, sb, 0);
#else
#ifdef XDOUBLE
  mode  =  BLAS_XDOUBLE | BLAS_REAL;
#elif defined(DOUBLE)
  mode  =  BLAS_DOUBLE  | BLAS_REAL;
#else
  mode  =  BLAS_SINGLE  | BLAS_REAL;
#endif  
  
  mode |= (side  << BLAS_RSIDE_SHIFT);

  GEMM_THREAD(mode, &args, NULL, NULL, (void *)symm3m[(side << 1) | uplo ], sa, sb, blas_cpu_number);

#endif

#ifndef PPC440
  blas_memory_free(buffer);
#endif

  return 0;
}
