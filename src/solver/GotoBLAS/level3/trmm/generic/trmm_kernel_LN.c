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

static FLOAT dp1 = ONE;

#ifdef CONJ
#define GEMM_KERNEL   GEMM_KERNEL_L
#else
#define GEMM_KERNEL   GEMM_KERNEL_N
#endif

void CNAME(BLASLONG m, BLASLONG n, BLASLONG k, FLOAT dummy1,
#ifdef COMPLEX
	   FLOAT dummy2,
#endif
			FLOAT *a, FLOAT *b, FLOAT *c, BLASLONG ldc, BLASLONG offset){

  BLASLONG i, j;
  FLOAT *aa, *cc;
  BLASLONG  newoffset;
  
  
  GEMM_BETA(m, n, 0, ZERO, 
#ifdef COMPLEX
	    ZERO,
#endif
	    NULL, 0, NULL, 0, c, ldc);

  j = (n >> GEMM_UNROLL_N_SHIFT);
  
  while (j > 0) {

    newoffset = offset;
    aa = a;
    cc = c;
    
    i = (m >> GEMM_UNROLL_M_SHIFT);
    
    while (i > 0) {
      GEMM_KERNEL(GEMM_UNROLL_M, GEMM_UNROLL_N, k - newoffset, dp1, 
#ifdef COMPLEX
		  ZERO,
#endif
		  aa + GEMM_UNROLL_M * newoffset * COMPSIZE,
		  b +  GEMM_UNROLL_N * newoffset * COMPSIZE, 
		  cc,
		  ldc); 
      
      aa += GEMM_UNROLL_M * k * COMPSIZE;
      cc += GEMM_UNROLL_M * COMPSIZE;
      newoffset += GEMM_UNROLL_M;
      i --;
    }
    
    if (m & (GEMM_UNROLL_M - 1)) {
      i = (GEMM_UNROLL_M >> 1);
      while (i > 0) {
	if (m & i) {
	  GEMM_KERNEL(i, GEMM_UNROLL_N, k - newoffset, dp1, 
#ifdef COMPLEX
			  ZERO,
#endif
		      aa + i * newoffset * COMPSIZE,
			  b  +  GEMM_UNROLL_N * newoffset * COMPSIZE, 
		      cc,
		      ldc); 
	  aa += i * k * COMPSIZE;
	  cc += i * COMPSIZE;
	  newoffset += i;
	}
	i >>= 1;
      }
    }
    
    b += GEMM_UNROLL_N * k * COMPSIZE;
    c += GEMM_UNROLL_N * ldc * COMPSIZE;
      j --;
  }
  
  
  if (n & (GEMM_UNROLL_N - 1)) {
    j = (GEMM_UNROLL_N >> 1);
    while (j > 0) {
      if (n & j) {
	
	newoffset = offset;
	aa = a;
	cc = c;
	
	i = (m >> GEMM_UNROLL_M_SHIFT);
	
	while (i > 0) {
	  GEMM_KERNEL(GEMM_UNROLL_M, j, k - newoffset, dp1, 
#ifdef COMPLEX
		      ZERO,
#endif
		      aa + GEMM_UNROLL_M * newoffset * COMPSIZE,
		      b +  j * newoffset * COMPSIZE, 
		      cc,
		      ldc); 
	  
	  aa += GEMM_UNROLL_M * k * COMPSIZE;
	  cc += GEMM_UNROLL_M * COMPSIZE;
	  newoffset += GEMM_UNROLL_M;
	  i --;
	}
	
	if (m & (GEMM_UNROLL_M - 1)) {
	  i = (GEMM_UNROLL_M >> 1);
	  while (i > 0) {
	    if (m & i) {
	      GEMM_KERNEL(i, j, k - newoffset, dp1, 
#ifdef COMPLEX
			  ZERO,
#endif
			  aa + i * newoffset * COMPSIZE,
			  b +  j * newoffset * COMPSIZE, 
			  cc,
			  ldc); 
	      
	      aa += i * k * COMPSIZE;
	      cc += i * COMPSIZE;
	      newoffset += i;
	    }
	    i >>= 1;
	  }
	}
	
	b += j * k * COMPSIZE;
	c += j * ldc * COMPSIZE;
      }
      j >>= 1;
    }
  }

    return;
}
