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

#ifndef COMPLEX
#ifdef XDOUBLE
#define ERROR_NAME "QGESV  "
#elif defined(DOUBLE)
#define ERROR_NAME "DGESV  "
#else
#define ERROR_NAME "SGESV  "
#endif
#else
#ifdef XDOUBLE
#define ERROR_NAME "XGESV  "
#elif defined(DOUBLE)
#define ERROR_NAME "ZGESV  "
#else
#define ERROR_NAME "CGESV  "
#endif
#endif

int NAME(blasint *N, blasint *NRHS, FLOAT *a, blasint *ldA, blasint *ipiv,
         FLOAT *b, blasint *ldB, blasint *Info){

  blas_arg_t args;

  blasint info;
  FLOAT *buffer;
#ifdef PPC440
  extern
#endif
  FLOAT *sa, *sb;
  
  args.m    = *N;
  args.n    = *NRHS;
  args.a    = (void *)a;
  args.lda  = *ldA;
  args.b    = (void *)b;
  args.ldb  = *ldB;
  args.c    = (void *)ipiv;

  info  = 0;
  if (args.ldb < MAX(1,args.m)) info = 7;
  if (args.lda < MAX(1,args.m)) info = 4;
  if (args.n   < 0)             info = 2;
  if (args.m   < 0)             info = 1;

  if (info) {
    BLASFUNC(xerbla)(ERROR_NAME, &info, sizeof(ERROR_NAME));
    *Info = - info;
    return 0;
  }

  args.alpha = NULL;
  args.beta  = NULL;

  *Info = 0;

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
  buffer = (FLOAT *)blas_memory_alloc(1);

  sa = (FLOAT *)((BLASLONG)buffer + GEMM_BUFFER_A_OFFSET);
  sb = (FLOAT *)(((BLASLONG)sa + ((GEMM_P * GEMM_Q * COMPSIZE * SIZE + GEMM_ALIGN) & ~GEMM_ALIGN)) + GEMM_BUFFER_B_OFFSET);
#endif

#ifdef SMP
  if (blas_cpu_number == 1) {
#endif

    args.n    = *N;
    info = GETRF_SINGLE(&args, NULL, NULL, sa, sb, 0);
    
    if (info == 0){
      args.n    = *NRHS;
      GETRS_N_SINGLE(&args, NULL, NULL, sa, sb, 0);
    }
    
#ifdef SMP
  } else {

    args.n    = *N;
  info = GETRF_PARALLEL(&args, NULL, NULL, sa, sb, 0);
    
    if (info == 0){
      args.n    = *NRHS;
      GETRS_N_PARALLEL(&args, NULL, NULL, sa, sb, 0);
    }
  }
#endif

#ifndef PPC440
  blas_memory_free(buffer);
#endif

  *Info = info;

  return 0;
}
