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

#include "common.h"

static FLOAT dm1 = -1.;

#ifdef CONJ
#define GEMM_KERNEL   GEMM_KERNEL_L
#else
#define GEMM_KERNEL   GEMM_KERNEL_N
#endif

#ifndef COMPLEX

static inline void solve(BLASLONG m, BLASLONG n, FLOAT *a, FLOAT *b, FLOAT *c, BLASLONG ldc) {

  FLOAT aa,  bb;

  int i, j, k;

  a += (m - 1) * m;
  b += (m - 1) * n;

  for (i = m - 1; i >= 0; i--) {

    aa = *(a + i);
    
    for (j = 0; j < n; j ++) {
      bb = *(c + i + j * ldc);
      bb *= aa;
      *b             = bb;
      *(c + i + j * ldc) = bb;
      b ++;

      for (k = 0; k < i; k ++){
	*(c + k + j * ldc) -= bb * *(a + k);
      }

    }
    a -= m;
    b -= 2 * n;
  }

}

#else

static inline void solve(BLASLONG m, BLASLONG n, FLOAT *a, FLOAT *b, FLOAT *c, BLASLONG ldc) {

  FLOAT aa1, aa2;
  FLOAT bb1, bb2;
  FLOAT cc1, cc2;

  int i, j, k;

  ldc *= 2;
  a += (m - 1) * m * 2;
  b += (m - 1) * n * 2;

  for (i = m - 1; i >= 0; i--) {

    aa1 = *(a + i * 2 + 0);
    aa2 = *(a + i * 2 + 1);
    
    for (j = 0; j < n; j ++) {
      bb1 = *(c + i * 2 + 0 + j * ldc);
      bb2 = *(c + i * 2 + 1 + j * ldc);

#ifndef CONJ
      cc1 = aa1 * bb1 - aa2 * bb2;
      cc2 = aa1 * bb2 + aa2 * bb1;
#else
      cc1 = aa1 * bb1 + aa2 * bb2;
      cc2 = aa1 * bb2 - aa2 * bb1;
#endif


      *(b + 0) = cc1;
      *(b + 1) = cc2;
      *(c + i * 2 + 0 + j * ldc) = cc1;
      *(c + i * 2 + 1 + j * ldc) = cc2;
      b += 2;

      for (k = 0; k < i; k ++){
#ifndef CONJ
	*(c + k * 2 + 0 + j * ldc) -= cc1 * *(a + k * 2 + 0) - cc2 * *(a + k * 2 + 1);
	*(c + k * 2 + 1 + j * ldc) -= cc1 * *(a + k * 2 + 1) + cc2 * *(a + k * 2 + 0);
#else
	*(c + k * 2 + 0 + j * ldc) -=   cc1 * *(a + k * 2 + 0) + cc2 * *(a + k * 2 + 1);
	*(c + k * 2 + 1 + j * ldc) -= - cc1 * *(a + k * 2 + 1) + cc2 * *(a + k * 2 + 0);
#endif
      }

    }
    a -= m * 2;
    b -= 4 * n;
  }

}

#endif


void CNAME(BLASLONG m, BLASLONG n, BLASLONG k,  FLOAT dummy1, 
#ifdef COMPLEX
	   FLOAT dummy2,
#endif
	   FLOAT *a, FLOAT *b, FLOAT *c, BLASLONG ldc, BLASLONG offset){

  BLASLONG i, j;
  FLOAT *aa, *cc;
  BLASLONG  kk;

#if 0
  fprintf(stderr, "TRSM KERNEL LN : m = %3ld  n = %3ld  k = %3ld offset = %3ld\n",
	  m, n, k, offset);
#endif

  j = (n >> GEMM_UNROLL_N_SHIFT);
  
  while (j > 0) {

    kk = m + offset;
    
    if (m & (GEMM_UNROLL_M - 1)) {
      for (i = 1; i < GEMM_UNROLL_M; i *= 2){
	if (m & i) {
	  aa = a + ((m & ~(i - 1)) - i) * k * COMPSIZE;
	  cc = c + ((m & ~(i - 1)) - i)     * COMPSIZE;
	  
	  if (k - kk > 0) {
	    GEMM_KERNEL(i, GEMM_UNROLL_N, k - kk, dm1, 
#ifdef COMPLEX
			ZERO,
#endif
			aa + i             * kk * COMPSIZE,
			b  + GEMM_UNROLL_N * kk * COMPSIZE, 
			cc,
			ldc); 
	  }

	  solve(i, GEMM_UNROLL_N, 
		aa + (kk - i) * i             * COMPSIZE, 
		b  + (kk - i) * GEMM_UNROLL_N * COMPSIZE,
		cc, ldc);
	  
	  kk -= i;
	}
      }
    }

    i = (m >> GEMM_UNROLL_M_SHIFT);
    if (i > 0) {
      aa = a + ((m & ~(GEMM_UNROLL_M - 1)) - GEMM_UNROLL_M) * k * COMPSIZE;
      cc = c + ((m & ~(GEMM_UNROLL_M - 1)) - GEMM_UNROLL_M)     * COMPSIZE;

      do {
	if (k - kk > 0) {
	  GEMM_KERNEL(GEMM_UNROLL_M, GEMM_UNROLL_N, k - kk, dm1, 
#ifdef COMPLEX
		      ZERO,
#endif
		      aa + GEMM_UNROLL_M * kk * COMPSIZE,
		      b +  GEMM_UNROLL_N * kk * COMPSIZE, 
		      cc,
		      ldc); 
	}

	solve(GEMM_UNROLL_M, GEMM_UNROLL_N, 
	      aa + (kk - GEMM_UNROLL_M) * GEMM_UNROLL_M * COMPSIZE, 
	      b  + (kk - GEMM_UNROLL_M) * GEMM_UNROLL_N * COMPSIZE,
	      cc, ldc);
	
	aa -= GEMM_UNROLL_M * k * COMPSIZE;
	cc -= GEMM_UNROLL_M     * COMPSIZE;
	kk -= GEMM_UNROLL_M;
	i --;
      } while (i > 0);
    }
    
    b += GEMM_UNROLL_N * k * COMPSIZE;
    c += GEMM_UNROLL_N * ldc * COMPSIZE;
    j --;
  }
  
  if (n & (GEMM_UNROLL_N - 1)) {

    j = (GEMM_UNROLL_N >> 1);
    while (j > 0) {
      if (n & j) {
	
	kk = m + offset;
    
	if (m & (GEMM_UNROLL_M - 1)) {
	  for (i = 1; i < GEMM_UNROLL_M; i *= 2){
	    if (m & i) {
	      aa = a + ((m & ~(i - 1)) - i) * k * COMPSIZE;
	      cc = c + ((m & ~(i - 1)) - i)     * COMPSIZE;
	      
	      if (k - kk > 0) {
		GEMM_KERNEL(i, j, k - kk, dm1, 
#ifdef COMPLEX
			    ZERO,
#endif
			    aa + i * kk * COMPSIZE,
			    b  + j * kk * COMPSIZE, 
			    cc, ldc); 
	      }

	      solve(i, j, 
		    aa + (kk - i) * i * COMPSIZE,
		    b  + (kk - i) * j * COMPSIZE,
		    cc, ldc);
	  
	      kk -= i;
	    }
	  }
	}
	
	i = (m >> GEMM_UNROLL_M_SHIFT);
	if (i > 0) {
	  aa = a + ((m & ~(GEMM_UNROLL_M - 1)) - GEMM_UNROLL_M) * k * COMPSIZE;
	  cc = c + ((m & ~(GEMM_UNROLL_M - 1)) - GEMM_UNROLL_M)     * COMPSIZE;
	  
	  do {
	    if (k - kk > 0) {
	      GEMM_KERNEL(GEMM_UNROLL_M, j, k - kk, dm1, 
#ifdef COMPLEX
			  ZERO,
#endif
			  aa + GEMM_UNROLL_M * kk * COMPSIZE,
			  b +  j             * kk * COMPSIZE, 
			  cc,
			  ldc); 
	    }

	    solve(GEMM_UNROLL_M, j, 
		  aa + (kk - GEMM_UNROLL_M) * GEMM_UNROLL_M * COMPSIZE,
		  b  + (kk - GEMM_UNROLL_M) * j             * COMPSIZE,
		  cc, ldc);
	    
	    aa -= GEMM_UNROLL_M * k * COMPSIZE;
	    cc -= GEMM_UNROLL_M     * COMPSIZE;
	    kk -= GEMM_UNROLL_M;
	    i --;
	  } while (i > 0);
	}
	
	b += j * k   * COMPSIZE;
	c += j * ldc * COMPSIZE;
      }
      j >>= 1;
    }
  }
  
    return;
}


