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
#define ERROR_NAME "XHERK "
#elif defined(DOUBLE)
#define ERROR_NAME "ZHERK "
#else
#define ERROR_NAME "CHERK "
#endif

static int (*herk[])(blas_arg_t *, void *, void *, FLOAT *, FLOAT *, BLASLONG) = {
#ifdef XDOUBLE
    xherk_UN, xherk_UC, xherk_LN, xherk_LC,
#elif defined(DOUBLE)
    zherk_UN, zherk_UC, zherk_LN, zherk_LC,
#else
    cherk_UN, cherk_UC, cherk_LN, cherk_LC,
#endif
};

int NAME(char *UPLO, char *TRANS,
         blasint *N, blasint *K, 
         FLOAT *alpha, FLOAT *a, blasint *ldA, 
         FLOAT *beta,  FLOAT *c, blasint *ldC){
  
  char uplo_arg  = *UPLO;
  char trans_arg = *TRANS;

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
  int uplo;
  int trans;
  int nrowa;

  args.n = *N;
  args.k = *K;

  args.a = (void *)a;
  args.c = (void *)c;

  args.lda = *ldA;
  args.ldc = *ldC;

  args.alpha = (void *)alpha;
  args.beta  = (void *)beta;

  TOUPPER(uplo_arg);
  TOUPPER(trans_arg);

  uplo  = -1;
  trans = -1;

  if (uplo_arg  == 'U') uplo  = 0;
  if (uplo_arg  == 'L') uplo  = 1;

  if (trans_arg == 'N') trans = 0;
  if (trans_arg == 'C') trans = 1;
  
  nrowa = args.n;
  if (trans & 1) nrowa = args.k;

  info = 0;

  if (args.ldc < MAX(1,args.n)) info = 10;
  if (args.lda < MAX(1,nrowa))  info =  7;
  if (args.k < 0)               info =  4;
  if (args.n < 0)               info =  3;
  if (trans < 0)                info =  2;
  if (uplo  < 0)                info =  1;

  if (info != 0) {
    BLASFUNC(xerbla)(ERROR_NAME, &info, sizeof(ERROR_NAME));
    return 0;
  }

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

  (herk[(uplo << 1) | trans ])(&args, NULL, NULL, sa, sb, 0);

#else
#ifdef XDOUBLE
  mode  =  BLAS_XDOUBLE | BLAS_COMPLEX;
#elif defined(DOUBLE)
  mode  =  BLAS_DOUBLE  | BLAS_COMPLEX;
#else
  mode  =  BLAS_SINGLE  | BLAS_COMPLEX;
#endif  

  if (!trans){
    mode |= (BLAS_TRANSA_N | BLAS_TRANSB_T);
  } else {
    mode |= (BLAS_TRANSA_T | BLAS_TRANSB_N);
  }

  mode |= (uplo  << BLAS_UPLO_SHIFT);

  syrk_thread(mode, &args, NULL, NULL, (void *)herk[(uplo<<1) | trans], sa, sb);

#endif

#ifndef PPC440
  blas_memory_free(buffer);
#endif

  return 0;
}


