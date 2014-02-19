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

static FLOAT dm1 = -1.;

#if 0
#undef GEMM_P
#undef GEMM_Q
#undef GEMM_R

#define GEMM_P  16
#define GEMM_Q  20
#define GEMM_R  24
#endif

#define GEMM_PQ  MAX(GEMM_P, GEMM_Q)
#define REAL_GEMM_R (GEMM_R - GEMM_PQ)

static void inner_getrf_thread(blas_arg_t *args,
			       BLASLONG *range_m, BLASLONG *range_n, FLOAT *sa, FLOAT *sb, BLASLONG mypos){

  BLASLONG is, min_i;
  BLASLONG js, min_j;
  BLASLONG jjs, min_jj;

  BLASLONG m = args -> m;
  BLASLONG n = args -> n;
  BLASLONG k = args -> k;

  BLASLONG lda = args -> lda;
  BLASLONG off = args -> ldb;

  FLOAT *b = (FLOAT *)args -> a + k * COMPSIZE;
  FLOAT *c = (FLOAT *)args -> b;
  FLOAT *d = (FLOAT *)args -> b + k * COMPSIZE;

  FLOAT *sb2 = (FLOAT *)((((BLASLONG)sb
		    + GEMM_PQ  * GEMM_Q * COMPSIZE * SIZE + GEMM_ALIGN) & ~GEMM_ALIGN)
		  + GEMM_BUFFER_B_OFFSET);

  blasint *ipiv = (blasint *)args -> c;

  if (range_n) {
    n      = range_n[1] - range_n[0];
    c     += range_n[0] * lda * COMPSIZE;
    d     += range_n[0] * lda * COMPSIZE;
  }
  
  TRSM_ILTCOPY(k, k, (FLOAT *)args -> a, lda, 0, sb);

  for (js = 0; js < n; js += REAL_GEMM_R) {
    min_j = n - js;
    if (min_j > REAL_GEMM_R) min_j = REAL_GEMM_R;

    for (jjs = js; jjs < js + min_j; jjs += GEMM_UNROLL_N){
      min_jj = js + min_j - jjs;
      if (min_jj > GEMM_UNROLL_N) min_jj = GEMM_UNROLL_N;
      
#if GEMM_UNROLL_N > 8

      LASWP_PLUS(min_jj, off + 1, off + k, ZERO, 
#ifdef COMPLEX
		 ZERO,
#endif
		 c + (- off + jjs * lda) * COMPSIZE, lda, NULL, 0, ipiv, 1);
      
      GEMM_ONCOPY (k, min_jj, c + jjs * lda * COMPSIZE, lda, sb2 + (jjs - js) * k * COMPSIZE);

#else

      LASWP_NCOPY(min_jj, off + 1, off + k, 
		  c + (- off + jjs * lda) * COMPSIZE, lda,
		  ipiv, sb2 + k * (jjs - js) * COMPSIZE);

#endif

      for (is = 0; is < k; is += GEMM_P) {
	min_i = k - is;
	if (min_i > GEMM_P) min_i = GEMM_P;
	
	TRSM_KERNEL_LT(min_i, min_jj, k, dm1,
#ifdef COMPLEX
		       ZERO,
#endif
		       sb  + k * is * COMPSIZE,
		       sb2 + (jjs - js) * k * COMPSIZE, 
		       c   + (is + jjs * lda) * COMPSIZE, lda, is);
      }
    }

    for (is = 0; is < m; is += GEMM_P){
      min_i = m - is;
      if (min_i > GEMM_P) min_i = GEMM_P;
      
      GEMM_ITCOPY (k, min_i, b + is * COMPSIZE, lda, sa);
      
      GEMM_KERNEL_N(min_i, min_j, k, dm1,
#ifdef COMPLEX
		    ZERO,
#endif
		    sa, sb2, d + (is + js * lda) * COMPSIZE, lda);
    }
  }
}

#ifndef USE_SIMPLE_THREADED_LEVEL3

#ifndef CACHE_LINE_SIZE
#define CACHE_LINE_SIZE 8
#endif

#ifndef DIVIDE_RATE
#define DIVIDE_RATE 2
#endif

typedef struct {
  volatile BLASLONG working[MAX_CPU_NUMBER][CACHE_LINE_SIZE * DIVIDE_RATE];
} job_t;

#define ICOPY_OPERATION(M, N, A, LDA, X, Y, BUFFER) GEMM_ITCOPY(M, N, (FLOAT *)(A) + ((Y) + (X) * (LDA)) * COMPSIZE, LDA, BUFFER);
#define OCOPY_OPERATION(M, N, A, LDA, X, Y, BUFFER) GEMM_ONCOPY(M, N, (FLOAT *)(A) + ((X) + (Y) * (LDA)) * COMPSIZE, LDA, BUFFER);

#ifndef COMPLEX
#define KERNEL_OPERATION(M, N, K, SA, SB, C, LDC, X, Y) \
	GEMM_KERNEL_N(M, N, K, dm1, SA, SB, (FLOAT *)(C) + ((X) + (Y) * LDC) * COMPSIZE, LDC)
#else
#define KERNEL_OPERATION(M, N, K, SA, SB, C, LDC, X, Y) \
	GEMM_KERNEL_N(M, N, K, dm1, ZERO, SA, SB, (FLOAT *)(C) + ((X) + (Y) * LDC) * COMPSIZE, LDC)
#endif

static int inner_thread(blas_arg_t *args, BLASLONG *range_m, BLASLONG *range_n, FLOAT *sa, FLOAT *sb, BLASLONG mypos){

  job_t *job = (job_t *)args -> common;

  BLASLONG xxx, bufferside;

  FLOAT *buffer[DIVIDE_RATE];

  BLASLONG jjs, min_jj, div_n;

  BLASLONG i, current;
  BLASLONG is, min_i;

  BLASLONG m, n_from, n_to;
  BLASLONG k = args -> k;

  BLASLONG lda = args -> lda;
  BLASLONG off = args -> ldb;

  FLOAT *a = (FLOAT *)args -> a + k * COMPSIZE;
  FLOAT *b = (FLOAT *)args -> b;
  FLOAT *c = (FLOAT *)args -> b + k * COMPSIZE;

  FLOAT *sb2 = (FLOAT *)((((BLASLONG)sb
		    + GEMM_PQ  * GEMM_Q * COMPSIZE * SIZE + GEMM_ALIGN) & ~GEMM_ALIGN)
		  + GEMM_BUFFER_B_OFFSET);

  blasint *ipiv = (blasint *)args -> c;

  m      = range_m[1] - range_m[0];
  n_from = range_n[mypos + 0];
  n_to   = range_n[mypos + 1];

  a     += range_m[0] * COMPSIZE;
  c     += range_m[0] * COMPSIZE;

  div_n = (n_to - n_from + DIVIDE_RATE - 1) / DIVIDE_RATE;
  
  buffer[0] = sb2;

  for (i = 1; i < DIVIDE_RATE; i++) {
    buffer[i] = buffer[i - 1] + GEMM_Q * ((div_n + GEMM_UNROLL_N - 1) & ~(GEMM_UNROLL_N - 1)) * COMPSIZE;
  }

  TRSM_ILTCOPY(k, k, (FLOAT *)args -> a, lda, 0, sb);

  for (xxx = n_from, bufferside = 0; xxx < n_to; xxx += div_n, bufferside ++) {
    
    for (i = 0; i < args -> nthreads; i++)
      while (job[mypos].working[i][CACHE_LINE_SIZE * bufferside]) {};
    
    for(jjs = xxx; jjs < MIN(n_to, xxx + div_n); jjs += min_jj){
      min_jj = MIN(n_to, xxx + div_n) - jjs;
      if (min_jj > GEMM_UNROLL_N) min_jj = GEMM_UNROLL_N;
      
#if GEMM_UNROLL_N > 8

      LASWP_PLUS(min_jj, off + 1, off + k, ZERO, 
#ifdef COMPLEX
		 ZERO,
#endif
		 b + (- off + jjs * lda) * COMPSIZE, lda, NULL, 0, ipiv, 1);
      
      GEMM_ONCOPY (k, min_jj, b + jjs * lda * COMPSIZE, lda, 
		   buffer[bufferside] + (jjs - xxx) * k * COMPSIZE);

#else

      LASWP_NCOPY(min_jj, off + 1, off + k, 
		  b + (- off + jjs * lda) * COMPSIZE, lda,
		  ipiv, buffer[bufferside] + (jjs - xxx) * k * COMPSIZE);

#endif

      for (is = 0; is < k; is += GEMM_P) {
	min_i = k - is;
	if (min_i > GEMM_P) min_i = GEMM_P;
	
	TRSM_KERNEL_LT(min_i, min_jj, k, dm1,
#ifdef COMPLEX
		       ZERO,
#endif
		       sb  + k * is * COMPSIZE,
		       buffer[bufferside] + (jjs - xxx) * k * COMPSIZE, 
		       b   + (is + jjs * lda) * COMPSIZE, lda, is);
      }
    }
	
    for (i = 0; i < args -> nthreads; i++)
      job[mypos].working[i][CACHE_LINE_SIZE * bufferside] = (BLASLONG)buffer[bufferside];
  }
  
  for(is = 0; is < m; is += min_i){
    min_i = m - is;
    if (min_i >= GEMM_P * 2) {
      min_i = GEMM_P;
    } else 
      if (min_i > GEMM_P) {
	min_i = ((min_i + 1) / 2 + GEMM_UNROLL_M - 1) & ~(GEMM_UNROLL_M - 1);
      }
      
      ICOPY_OPERATION(k, min_i, a, lda, 0, is, sa);
      
      current = mypos;

      do {
	
	div_n = (range_n[current + 1]  - range_n[current] + DIVIDE_RATE - 1) / DIVIDE_RATE;
	
	for (xxx = range_n[current], bufferside = 0; xxx < range_n[current + 1]; xxx += div_n, bufferside ++) {
	  
	  if ((current != mypos) && (!is)) {
	    	    while(job[current].working[mypos][CACHE_LINE_SIZE * bufferside] == 0) {};
	  }

	  KERNEL_OPERATION(min_i, MIN(range_n[current + 1] - xxx, div_n), k,
			   sa, (FLOAT *)job[current].working[mypos][CACHE_LINE_SIZE * bufferside],
			   c, lda, is, xxx);
	  
	  if (is + min_i >= m) {
	    job[current].working[mypos][CACHE_LINE_SIZE * bufferside] = 0;
	  }
	}
	
	current ++;
	if (current >= args -> nthreads) current = 0;
	
      } while (current != mypos);
  }
  
  for (i = 0; i < args -> nthreads; i++) {
    for (xxx = 0; xxx < DIVIDE_RATE; xxx++) {
      while (job[mypos].working[i][CACHE_LINE_SIZE * xxx] ) {};
    }
  }

  return 0;
}

static int getrf_driver(blas_arg_t *args, FLOAT *sa, FLOAT *sb, BLASLONG nthreads){

  blas_arg_t newarg;

  blas_queue_t queue[MAX_CPU_NUMBER];

  BLASLONG range_M[MAX_CPU_NUMBER + 1];
  BLASLONG range_N[MAX_CPU_NUMBER + 1];

  job_t        job[MAX_CPU_NUMBER];

  BLASLONG num_cpu_m, num_cpu_n;

  BLASLONG width, i, j, k, js;
  BLASLONG m, n;
  int  mode;

#ifndef COMPLEX
#ifdef XDOUBLE
  mode  =  BLAS_XDOUBLE | BLAS_REAL;
#elif defined(DOUBLE)
  mode  =  BLAS_DOUBLE  | BLAS_REAL;
#else
  mode  =  BLAS_SINGLE  | BLAS_REAL;
#endif  
#else
#ifdef XDOUBLE
  mode  =  BLAS_XDOUBLE | BLAS_COMPLEX;
#elif defined(DOUBLE)
  mode  =  BLAS_DOUBLE  | BLAS_COMPLEX;
#else
  mode  =  BLAS_SINGLE  | BLAS_COMPLEX;
#endif  
#endif

  newarg.m        = args -> m;
  newarg.n        = args -> n;
  newarg.k        = args -> k;
  newarg.a        = args -> a;
  newarg.b        = args -> b;
  newarg.c        = args -> c;
  newarg.lda      = args -> lda;
  newarg.ldb      = args -> ldb;
  newarg.nthreads = nthreads;
  newarg.common   = (void *)job;
   
  range_M[0] = 0;
  m          = args -> m;

  num_cpu_m  = 0;

  while (m > 0){
    
    width  = blas_quickdivide(m + nthreads - num_cpu_m - 1, nthreads - num_cpu_m);

    m -= width;
    if (m < 0) width = width + m;

    range_M[num_cpu_m + 1] = range_M[num_cpu_m] + width;

    num_cpu_m ++;
  }

  for (i = 0; i < num_cpu_m; i++) {
    queue[i].mode    = mode;
    queue[i].routine = inner_thread;
    queue[i].args    = &newarg;
    queue[i].range_m = &range_M[i];
    queue[i].range_n = &range_N[0];
    queue[i].sa      = NULL;
    queue[i].sb      = NULL;
    queue[i].next    = &queue[i + 1];
  }
  
  queue[0].sa = sa;
  queue[0].sb = sb;
  
  for(js = 0; js < args -> n; js += REAL_GEMM_R * nthreads){
    n = args -> n - js;
    if (n > REAL_GEMM_R * nthreads) n = REAL_GEMM_R * nthreads;
    
    range_N[0] = js;

    num_cpu_n  = 0;

    while (num_cpu_n < num_cpu_m){
      
      if (n > 0) {

	width  = blas_quickdivide(n + nthreads - num_cpu_n - 1, nthreads - num_cpu_n);
	
	n -= width;
	if (n < 0) width = width + n;
	
	range_N[num_cpu_n + 1] = range_N[num_cpu_n] + width;

      } else {

	range_N[num_cpu_n + 1] = 0;

      }

      num_cpu_n ++;
    }
    
    for (j = 0; j < num_cpu_m; j++) {
      for (i = 0; i < num_cpu_m; i++) {
	for (k = 0; k < DIVIDE_RATE; k++) {
	  job[j].working[i][CACHE_LINE_SIZE * k] = 0;
	}
      }
    }
    
    queue[num_cpu_m - 1].next = NULL;
    
    exec_blas(num_cpu_m, queue);
  }

  return 0;
}

#endif


blasint CNAME(blas_arg_t *args, BLASLONG *range_m, BLASLONG *range_n, FLOAT *sa, FLOAT *sb, BLASLONG myid) {

  BLASLONG m, n, mn, lda, offset, blocking;
  blasint *ipiv, iinfo, info;
  BLASLONG i, bk, range_N[2];
  int mode;
  blas_arg_t newarg;
  FLOAT *a;
  FLOAT dummyalpha[2] = {ZERO, ZERO};

#ifndef COMPLEX
#ifdef XDOUBLE
  mode  =  BLAS_XDOUBLE | BLAS_REAL;
#elif defined(DOUBLE)
  mode  =  BLAS_DOUBLE  | BLAS_REAL;
#else
  mode  =  BLAS_SINGLE  | BLAS_REAL;
#endif  
#else
#ifdef XDOUBLE
  mode  =  BLAS_XDOUBLE | BLAS_COMPLEX;
#elif defined(DOUBLE)
  mode  =  BLAS_DOUBLE  | BLAS_COMPLEX;
#else
  mode  =  BLAS_SINGLE  | BLAS_COMPLEX;
#endif  
#endif

  m    = args -> m;
  n    = args -> n;
  a    = (FLOAT *)args -> a;
  lda  = args -> lda;
  ipiv = (blasint *)args -> c;
  offset = 0;

  if (range_n) {
    m     -= range_n[0];
    n      = range_n[1] - range_n[0];
    offset = range_n[0];
    a     += range_n[0] * (lda + 1) * COMPSIZE;
  }

  if (m <= 0 || n <= 0) return 0;
  
  info = 0;

  if (n <= GEMM_UNROLL_N * 2) {
    info = GETF2(args, NULL, range_n, sa, sb, 0);
    return info;
  }
  
  newarg.c   = ipiv;
  newarg.lda = lda;
  newarg.common = NULL;
  newarg.nthreads = blas_cpu_number;

  blocking = GEMM_Q;
  if (n <= 2 * GEMM_Q) blocking = (n + 1) / 2;
 
  mn = MIN(m, n);

  for (i = 0; i < mn; i += blocking) {
    bk = mn - i;
    if (bk > blocking) bk = blocking;

    range_N[0] = offset + i;
    range_N[1] = offset + i + bk;

    iinfo   = CNAME(args, NULL, range_N, sa, sb, 0);

    if (iinfo && !info) info = iinfo + i;
    
    newarg.a   = a + (i +  i       * lda) * COMPSIZE;
    newarg.b   = a + (i + (i + bk) * lda) * COMPSIZE;
    newarg.m   = m - bk - i;
    newarg.n   = n - bk - i;
    newarg.k   = bk;
    newarg.ldb = i + offset;

#ifdef USE_SIMPLE_THREADED_LEVEL3
    gemm_thread_n(mode, &newarg, NULL, NULL, (void *)inner_getrf_thread, sa, sb, blas_cpu_number);
#else
    if (newarg.m >= blas_cpu_number * 4) {
      getrf_driver (&newarg, sa, sb, blas_cpu_number);
    } else {
      inner_getrf_thread(&newarg, NULL, NULL, sa, sb, 0);
    }
#endif

  }
  
  for (i = 0; i < mn; i += blocking) {
    bk = mn - i;
    if (bk > blocking) bk = blocking;
    
    blas_level1_thread(mode, bk, i + bk + offset + 1, mn + offset, (void *)dummyalpha, 
		       a + (- offset + i * lda) * COMPSIZE, lda, NULL, 0,
		       ipiv, 1, (void *)LASWP_PLUS);

  }

  return info;
}
