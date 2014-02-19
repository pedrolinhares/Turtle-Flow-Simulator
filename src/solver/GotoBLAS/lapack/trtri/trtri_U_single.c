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

static FLOAT dp1 =  1.;
static FLOAT dm1 = -1.;

#ifdef UNIT
#define TRTI2	TRTI2_UU
#else
#define TRTI2	TRTI2_UN
#endif

#if 0
#undef GEMM_P
#undef GEMM_Q
#undef GEMM_R

#define GEMM_P 8
#define GEMM_Q 20
#define GEMM_R 64
#endif

#define GEMM_PQ  MAX(GEMM_P, GEMM_Q)
#define REAL_GEMM_R (GEMM_R - 2 * GEMM_PQ)

blasint CNAME(blas_arg_t *args, BLASLONG *range_m, BLASLONG *range_n, FLOAT *sa, FLOAT *sb, BLASLONG myid) {

  BLASLONG  n, lda;
  FLOAT *a;

  BLASLONG i, is, min_i, start_is;
  BLASLONG ls, min_l;
  BLASLONG bk;
  BLASLONG blocking;
  BLASLONG range_N[2];

  FLOAT *sa_trsm = (FLOAT *)((BLASLONG)sb);
  FLOAT *sa_trmm = (FLOAT *)((((BLASLONG)sb
			       + GEMM_PQ * GEMM_Q * COMPSIZE * SIZE + GEMM_ALIGN) & ~GEMM_ALIGN)
			     + GEMM_BUFFER_A_OFFSET);
  FLOAT *sb_gemm = (FLOAT *)((((BLASLONG)sa_trmm
			       + GEMM_PQ * GEMM_Q * COMPSIZE * SIZE + GEMM_ALIGN) & ~GEMM_ALIGN)
			     + GEMM_BUFFER_B_OFFSET);

  n      = args -> n;
  a      = (FLOAT *)args -> a;
  lda    = args -> lda;

  if (range_n) {
    n      = range_n[1] - range_n[0];
    a     += range_n[0] * (lda + 1) * COMPSIZE;
  }

  if (n <= DTB_ENTRIES) {
    TRTI2(args, NULL, range_n, sa, sb, 0);
    return 0;
  }

  blocking = GEMM_Q;
  if (n <= 4 * GEMM_Q) blocking = (n + 3) / 4;

  for (i = 0; i < n; i += blocking) {
    bk = MIN(blocking, n - i);
    
    if (i  > 0) TRSM_OUNCOPY(bk, bk, a + (i + i * lda) * COMPSIZE, lda, 0, sa_trsm);

    if (!range_n) {
      range_N[0] = i;
      range_N[1] = i + bk;
    } else {
      range_N[0] = range_n[0] + i;
      range_N[1] = range_n[0] + i + bk;
    }

    CNAME(args, NULL, range_N, sa, sa_trmm, 0);

    if (n -bk - i > 0) {
      TRMM_IUTCOPY(bk, bk, a + (i + i * lda) * COMPSIZE, lda, 0, 0, sa_trmm);

      for (ls = i + bk; ls < n; ls += REAL_GEMM_R) {
	min_l = n - ls;
	if (min_l > REAL_GEMM_R) min_l = REAL_GEMM_R;
	
	GEMM_ONCOPY (bk, min_l, a + (i + ls * lda) * COMPSIZE, lda, sb_gemm);
	
	if (i > 0) {
	  for (is = 0; is < i; is += GEMM_P) {
	    min_i = i - is;
	    if (min_i > GEMM_P) min_i = GEMM_P;
	    
	  if (ls == i + bk) {
	    NEG_TCOPY (bk, min_i, a + (is + i * lda) * COMPSIZE, lda, sa);
	    
	    TRSM_KERNEL_RN(min_i, bk, bk, dm1, 
#ifdef COMPLEX
			   ZERO,
#endif
			   sa, sa_trsm,
			   a + (is + i * lda) * COMPSIZE, lda, 0);
	  } else {
	    GEMM_ITCOPY (bk, min_i, a + (is + i * lda) * COMPSIZE, lda, sa);
	  }
	    
	  GEMM_KERNEL_N(min_i, min_l, bk, dp1, 
#ifdef COMPLEX
			ZERO,
#endif
			sa, sb_gemm,
			a + (is + ls * lda) * COMPSIZE, lda);
	  }
	}
	
	start_is = 0;
	while (start_is < bk) start_is += GEMM_P;
	start_is -= GEMM_P;

	for (is = 0; is < bk; is += GEMM_P) {
	  min_i = bk - is;
	  if (min_i > GEMM_P) min_i = GEMM_P;
	  
	  TRMM_KERNEL_LN(min_i, min_l, bk, dp1, 
#ifdef COMPLEX
			 ZERO,
#endif
			 sa_trmm + is * bk * COMPSIZE, sb_gemm,
			 a + (i + is + ls * lda) * COMPSIZE, lda, is);
	}
      }

    } else {
      if (i > 0) {
	for (is = 0; is < i; is += GEMM_P) {
	  min_i = i - is;
	  if (min_i > GEMM_P) min_i = GEMM_P;
	  
	  NEG_TCOPY (bk, min_i, a + (is + i * lda) * COMPSIZE, lda, sa);
	  
	  TRSM_KERNEL_RN(min_i, bk, bk, dm1, 
#ifdef COMPLEX
			 ZERO,
#endif
			 sa, sa_trsm,
			 a + (is + i * lda) * COMPSIZE, lda, 0);
	}
      }
    }
  }

  return 0;
}
