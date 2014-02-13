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

#ifndef KERNEL_FUNC
#ifndef LOWER
#define KERNEL_FUNC SYRK_KERNEL_U
#else
#define KERNEL_FUNC SYRK_KERNEL_L
#endif
#endif

#ifndef KERNEL_OPERATION
#ifndef COMPLEX
#define KERNEL_OPERATION(M, N, K, ALPHA, SA, SB, C, LDC, X, Y) \
	KERNEL_FUNC(M, N, K, ALPHA[0], SA, SB, (FLOAT *)(C) + ((X) + (Y) * LDC) * COMPSIZE, LDC, (X) - (Y))
#else
#define KERNEL_OPERATION(M, N, K, ALPHA, SA, SB, C, LDC, X, Y) \
	KERNEL_FUNC(M, N, K, ALPHA[0], ALPHA[1], SA, SB, (FLOAT *)(C) + ((X) + (Y) * LDC) * COMPSIZE, LDC, (X) - (Y))
#endif
#endif

#ifndef ICOPY_OPERATION
#ifndef TRANS
#define ICOPY_OPERATION(M, N, A, LDA, X, Y, BUFFER) GEMM_ITCOPY(M, N, (FLOAT *)(A) + ((Y) + (X) * (LDA)) * COMPSIZE, LDA, BUFFER);
#else
#define ICOPY_OPERATION(M, N, A, LDA, X, Y, BUFFER) GEMM_INCOPY(M, N, (FLOAT *)(A) + ((X) + (Y) * (LDA)) * COMPSIZE, LDA, BUFFER);
#endif
#endif

#ifndef OCOPY_OPERATION
#ifdef TRANS
#define OCOPY_OPERATION(M, N, A, LDA, X, Y, BUFFER) GEMM_ONCOPY(M, N, (FLOAT *)(A) + ((X) + (Y) * (LDA)) * COMPSIZE, LDA, BUFFER);
#else
#define OCOPY_OPERATION(M, N, A, LDA, X, Y, BUFFER) GEMM_OTCOPY(M, N, (FLOAT *)(A) + ((Y) + (X) * (LDA)) * COMPSIZE, LDA, BUFFER);
#endif
#endif

#ifndef M
#define M	args -> n
#endif

#ifndef N
#define N	args -> n
#endif

#ifndef K
#define K	args -> k
#endif

#ifndef A
#define A	args -> a
#endif

#ifndef C
#define C	args -> c
#endif

#ifndef LDA
#define LDA	args -> lda
#endif

#ifndef LDC
#define LDC	args -> ldc
#endif

int CNAME(blas_arg_t *args, void *range_m, void *range_n, FLOAT *sa, FLOAT *sb, BLASLONG dummy) {

  BLASLONG m_from, m_to, n_from, n_to, k, lda, ldc;
  FLOAT *a, *c, *alpha, *beta;

  BLASLONG ls, is, js;
  BLASLONG min_l, min_i, min_j;
  BLASLONG jjs, min_jj;
  BLASLONG m_start, m_end;

#if (GEMM_UNROLL_M == GEMM_UNROLL_N) && !defined(PPC440) && !defined(BARCELONA)
  FLOAT *aa;
#else
#define aa sa
#endif

  k = K;

  a = (FLOAT *)A;
  c = (FLOAT *)C;

  lda = LDA;
  ldc = LDC;

  alpha = (FLOAT *)args -> alpha;
  beta  = (FLOAT *)args -> beta;

  m_from = 0;
  m_to   = M;

  if (range_m) {
    m_from = *(((BLASLONG *)range_m) + 0);
    m_to   = *(((BLASLONG *)range_m) + 1);
  }

  n_from = 0;
  n_to   = N;

  if (range_n) {
    n_from = *(((BLASLONG *)range_n) + 0);
    n_to   = *(((BLASLONG *)range_n) + 1);
  }

  if (beta) {
#if !defined(COMPLEX) || defined(HERK)
    if (beta[0] != ONE)
#else
    if ((beta[0] != ONE) || (beta[1] != ZERO))
#endif
      syrk_beta(m_from, m_to, n_from, n_to, beta, c, ldc);
  }

  if ((k == 0) || (alpha == NULL)) return 0;

  if ((alpha[0] == ZERO)
#if !defined(COMPLEX) && !defined(HERK)
      && (alpha[1] == ZERO)
#endif
      ) return 0;

  for(js = n_from; js < n_to; js += GEMM_R){
    min_j = n_to - js;
    if (min_j > GEMM_R) min_j = GEMM_R;
    
#ifndef LOWER
    m_start = m_from;
    m_end   = js + min_j;
    if (m_end > m_to) m_end = m_to;
#else
    m_start = m_from;
    m_end   = m_to;
    if (m_start < js) m_start = js;
#endif

    for(ls = 0; ls < k; ls += min_l){
      min_l = k - ls;
      if (min_l >= GEMM_Q * 2) {
	min_l = GEMM_Q;
      } else 
	if (min_l > GEMM_Q) {
	  min_l = (min_l + 1) / 2;
	}
      
#ifndef LOWER

      min_i = m_end - m_start;
      
      if (min_i >= GEMM_P * 2) {
	min_i = GEMM_P;
      } else 
	if (min_i > GEMM_P) {
	  min_i = (min_i / 2 + MAXMN - 1) & ~(MAXMN - 1);
	}
      
#if (GEMM_UNROLL_M == GEMM_UNROLL_N) && !defined(PPC440) && !defined(BARCELONA)
      if ((m_start >= js) && (m_start + min_i <= js + min_j)) {
	aa = sb + min_l * (m_start - js) * COMPSIZE;
      } else {
	ICOPY_OPERATION(min_l, min_i, a, lda, ls, m_start, sa);
	aa = sa;
      }
#else
	ICOPY_OPERATION(min_l, min_i, a, lda, ls, m_start, sa);
#endif

      for(jjs = js; jjs < js + min_j; jjs += GEMM_P){
	min_jj = min_j + js - jjs;
	if (min_jj > GEMM_P) min_jj = GEMM_P;
	
	OCOPY_OPERATION(min_l, min_jj, a, lda, ls, jjs, sb + min_l * (jjs - js) * COMPSIZE);

	KERNEL_OPERATION(min_i, min_jj, min_l, alpha,
			 aa, sb + min_l * (jjs - js)  * COMPSIZE,
			 c, ldc, m_start, jjs);
      }

      for(is = m_start + min_i; is < m_end; is += min_i){
	min_i = m_end - is;
	if (min_i >= GEMM_P * 2) {
	  min_i = GEMM_P;
	} else 
	  if (min_i > GEMM_P) {
	    min_i = (min_i / 2 + MAXMN - 1) & ~(MAXMN - 1);
	  }
	
#if (GEMM_UNROLL_M == GEMM_UNROLL_N) && !defined(PPC440) && !defined(BARCELONA)
	if ((is >= js) && (is + min_i <= js + min_j)) {
	  aa = sb + min_l * (is - js) * COMPSIZE;
	} else {
	  ICOPY_OPERATION(min_l, min_i, a, lda, ls, is, sa);
	  aa = sa;
	}
#else
	ICOPY_OPERATION(min_l, min_i, a, lda, ls, is, sa);
#endif

	KERNEL_OPERATION(min_i, min_j, min_l, alpha,
			 aa, sb, 
			 c, ldc, is, js);
	
      } /* end of is */

#else


      BLASLONG start_is = m_start;
      while (start_is + GEMM_P < m_end) start_is += GEMM_P;

      min_i = m_end - start_is;
      
      if (min_i >= GEMM_P * 2) {
	min_i = GEMM_P;
      } else 
	if (min_i > GEMM_P) {
	  min_i = (min_i / 2 + MAXMN - 1) & ~(MAXMN - 1);
	}
      
      BLASLONG start_jjs = js;
      while (start_jjs + GEMM_P < js + min_j) start_jjs += GEMM_P;

#if (GEMM_UNROLL_M == GEMM_UNROLL_N) && !defined(PPC440) && !defined(BARCELONA)
      if ((m_start > start_jjs) && (m_start + min_i <= start_jjs + min_j)) {
	aa = sb + min_l * (m_start - start_jjs) * COMPSIZE;
      } else {
	ICOPY_OPERATION(min_l, min_i, a, lda, ls, start_is, sa);
	aa = sa;
      }
#else
	ICOPY_OPERATION(min_l, min_i, a, lda, ls, start_is, sa);
#endif      

      for(jjs = start_jjs; jjs >= js; jjs -= GEMM_P){
	min_jj = min_j + js - jjs;
	if (min_jj > GEMM_P) min_jj = GEMM_P;
	
	OCOPY_OPERATION(min_l, min_jj, a, lda, ls, jjs, sb + min_l * (jjs - js) * COMPSIZE);

	KERNEL_OPERATION(min_i, min_jj, min_l, alpha,
			 aa, sb + min_l * (jjs - js) * COMPSIZE,
			 c, ldc,
			 start_is, jjs);
      }

      for(is = m_start; is < start_is; is += min_i){
	min_i = start_is - is;
	if (min_i >= GEMM_P * 2) {
	  min_i = GEMM_P;
	} else 
	  if (min_i > GEMM_P) {
	    min_i = (min_i / 2 + MAXMN - 1) & ~(MAXMN - 1);
	  }
	
#if (GEMM_UNROLL_M == GEMM_UNROLL_N) && !defined(PPC440) && !defined(BARCELONA)
	if ((is >= js) && (is + min_i <= js + min_j)) {
	  aa = sb + min_l * (is - js) * COMPSIZE;
	} else {
	  ICOPY_OPERATION(min_l, min_i, a, lda, ls, is, sa);
	  aa = sa;
	}
#else
	  ICOPY_OPERATION(min_l, min_i, a, lda, ls, is, sa);
#endif

	KERNEL_OPERATION(min_i, min_j, min_l, alpha,
			 aa, sb, 
			 c, ldc, is, js);
	
      } /* end of is */

#endif

    } /* end of ls */
  } /* end of js */

  return 0;
}
