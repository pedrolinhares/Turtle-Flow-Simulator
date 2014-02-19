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
#include <stdlib.h>
#include "common.h"

#ifdef XDOUBLE
#ifndef COMPLEX
#define ERROR_NAME "QGEMM "
#else
#define ERROR_NAME "XGEMM "
#endif
#elif defined(DOUBLE)
#ifndef COMPLEX
#define ERROR_NAME "DGEMM "
#else
#define ERROR_NAME "ZGEMM "
#endif
#else
#ifndef COMPLEX
#define ERROR_NAME "SGEMM "
#else
#define ERROR_NAME "CGEMM "
#endif
#endif

static GEMMRETTYPE (*gemm[])(blas_arg_t *, void *, void *, FLOAT *, FLOAT *, BLASLONG) = {
#if defined(SMP) && !defined(USE_SIMPLE_THREADED_LEVEL3)
			       GEMM_THREAD_NN, GEMM_THREAD_TN, GEMM_THREAD_NT, GEMM_THREAD_TT,
#else
			       GEMM_NN, GEMM_TN, GEMM_NT, GEMM_TT,
#endif
			     };

GEMMRETTYPE NAME(char *TRANSA, char *TRANSB,
		  blasint *M, blasint *N, blasint *K,
		  FLOAT *alpha,
		  FLOAT *a, blasint *ldA,
		  FLOAT *b, blasint *ldB,
		  FLOAT *beta,
		  FLOAT *c, blasint *ldC){
  
  blas_arg_t args;

  int transa, transb, nrowa, nrowb;
  blasint info;

  char transA, transB;
  FLOAT *buffer;
#ifdef PPC440
  extern
#endif
  FLOAT *sa, *sb;

#if defined(SMP) && defined(USE_SIMPLE_THREADED_LEVEL3)
  int mode;
#endif

  args.m = *M;
  args.n = *N;
  args.k = *K;

  args.a = (void *)a;
  args.b = (void *)b;
  args.c = (void *)c;

  args.lda = *ldA;
  args.ldb = *ldB;
  args.ldc = *ldC;

  args.alpha = (void *)alpha;
  args.beta  = (void *)beta;

  transA = *TRANSA;
  transB = *TRANSB;

  TOUPPER(transA);
  TOUPPER(transB);

  transa = -1;
  transb = -1;

  if (transA == 'N') transa = 0;
  if (transA == 'T') transa = 1;
  if (transA == 'R') transa = 0;
  if (transA == 'C') transa = 1;

  if (transB == 'N') transb = 0;
  if (transB == 'T') transb = 1;
  if (transB == 'R') transb = 0;
  if (transB == 'C') transb = 1;

  nrowa = args.m;
  if (transa) nrowa = args.k;
  nrowb = args.k;
  if (transb) nrowb = args.n;

/* Test the input parameters. */
  info = 0;

  if (args.ldc < args.m) info = 13;
  if (args.ldb < nrowb)  info = 10;
  if (args.lda < nrowa)  info =  8; 
  if (args.k < 0)        info =  5;
  if (args.n < 0)        info =  4;
  if (args.m < 0)        info =  3;
  if (transb < 0)        info =  2;
  if (transa < 0)        info =  1;

  if (info){
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

  sa = (FLOAT *)((BLASLONG)buffer +GEMM_BUFFER_A_OFFSET);
  sb = (FLOAT *)(((BLASLONG)sa + ((GEMM_P * GEMM_Q * COMPSIZE * SIZE + GEMM_ALIGN) & ~GEMM_ALIGN)) + GEMM_BUFFER_B_OFFSET);
#endif

#if !defined(SMP) || !defined(USE_SIMPLE_THREADED_LEVEL3)
  (gemm[(transb << 1) | transa])(&args, NULL, NULL, sa, sb, 0);
#else

#ifdef XDOUBLE
  mode  =  BLAS_XDOUBLE | BLAS_REAL;
#elif defined(DOUBLE)
  mode  =  BLAS_DOUBLE  | BLAS_REAL;
#else
  mode  =  BLAS_SINGLE  | BLAS_REAL;
#endif  

  mode |= (transa << BLAS_TRANSA_SHIFT);
  mode |= (transb << BLAS_TRANSB_SHIFT);

  GEMM_THREAD(mode, &args, NULL, NULL,
	      (void *)gemm[(transb << 1) | transa], sa, sb, blas_cpu_number);
#endif


#ifndef PPC440
  blas_memory_free(buffer);
#endif

  return 0;
}
