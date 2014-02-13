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
#define SYR2K_KERNEL_U qsyr2k_kernel_U
#define SYR2K_KERNEL_L qsyr2k_kernel_L
#elif defined(DOUBLE)
#define SYR2K_KERNEL_U dsyr2k_kernel_U
#define SYR2K_KERNEL_L dsyr2k_kernel_L
#else
#define SYR2K_KERNEL_U ssyr2k_kernel_U
#define SYR2K_KERNEL_L ssyr2k_kernel_L
#endif
#else
#ifdef XDOUBLE
#define SYR2K_KERNEL_U xsyr2k_kernel_U
#define SYR2K_KERNEL_L xsyr2k_kernel_L
#elif defined(DOUBLE)
#define SYR2K_KERNEL_U zsyr2k_kernel_U
#define SYR2K_KERNEL_L zsyr2k_kernel_L
#else
#define SYR2K_KERNEL_U csyr2k_kernel_U
#define SYR2K_KERNEL_L csyr2k_kernel_L
#endif
#endif

#ifndef SWITCHING
#define SWITCHING	(GEMM_P *  2)
#define GEMM_PP		(GEMM_P *  1)
#endif

#define GEMM_RH	(GEMM_R / 2)

#ifndef COMPLEX
#define SCAL	SCAL_K
#else
#define SCAL	ZSCAL_K
#endif

static inline int syrk_beta(BLASLONG m_from, BLASLONG m_to, BLASLONG n_from, BLASLONG n_to, FLOAT *alpha, FLOAT *c, BLASLONG ldc) {

  BLASLONG i;

  c += n_from * ldc * COMPSIZE;

  for (i = n_from; i < n_to; i++){
#ifndef LOWER
    SCAL(MIN(i, m_to) + 1 - m_from, 0, 0, alpha[0],
#ifdef COMPLEX
	   alpha[1],
#endif
	   c + m_from * COMPSIZE, 1, NULL, 0, NULL, 0);
#else
    SCAL(m_to - MAX(i, m_from), 0, 0, alpha[0], 
#ifdef COMPLEX
	   alpha[1],
#endif
	   c + MAX(i, m_from) * COMPSIZE, 1, NULL, 0, NULL, 0);
#endif

    c += ldc * COMPSIZE;
  }

  return 0;
}


int CNAME(blas_arg_t *args, void *range_m, void *range_n, FLOAT *sa, FLOAT *sb, BLASLONG dummy) {

  BLASLONG m_from, m_to, n_from, n_to, k;
  BLASLONG ls, is, js;
  BLASLONG min_l, min_i, min_j, min_m;
  FLOAT *alpha, *beta;

#if (GEMM_UNROLL_M == GEMM_UNROLL_N)
  FLOAT *sb2 = sb + GEMM_Q * GEMM_RH * COMPSIZE;
  FLOAT *aa;
#endif


  m_from = 0;
  m_to   = args -> n;
  n_from = 0;
  n_to   = args -> n;
  k      = args -> k;

  if (range_m) {
    m_from = *(((BLASLONG *)range_m) + 0);
    m_to   = *(((BLASLONG *)range_m) + 1);
  }

  if (range_n) {
    n_from = *(((BLASLONG *)range_n) + 0);
    n_to   = *(((BLASLONG *)range_n) + 1);
  }

  alpha = (FLOAT *)args -> alpha;
  beta  = (FLOAT *)args -> beta;

  if (beta) {
#ifndef COMPLEX
    if (beta[0] != ONE)
#else
    if ((beta[0] != ONE) || (beta[1] != ZERO))
#endif
      syrk_beta(m_from, m_to, n_from, n_to, beta, args -> c, args -> ldc);
  }

  if ((k == 0) || (alpha == NULL)) return 0;

  if ((alpha[0] == ZERO)
#ifdef COMPLEX
      && (alpha[1] == ZERO)
#endif
      ) return 0;


#if (GEMM_UNROLL_M == GEMM_UNROLL_N) && !defined(PPC440)

  for(ls = 0; ls < k; ls += min_l){
    min_l = k - ls;
    if (min_l >= GEMM_Q * 2) {
      min_l = GEMM_Q;
    } else 
      if (min_l > GEMM_Q) {
	min_l = (min_l / 2 + GEMM_UNROLL_N - 1) & ~(GEMM_UNROLL_N - 1);
      }
    
    for(js = n_from; js < n_to; js += GEMM_RH){
      min_j = n_to - js;
      if (min_j > GEMM_RH) min_j = GEMM_RH;
      
#ifndef TRANS
      GEMM_OTCOPY(min_l, min_j, (FLOAT *)args -> b + (js + ls * args -> ldb) * COMPSIZE, args -> ldb, sb);
      GEMM_OTCOPY(min_l, min_j, (FLOAT *)args -> a + (js + ls * args -> lda) * COMPSIZE, args -> lda, sb2);
#else
      GEMM_ONCOPY(min_l, min_j, (FLOAT *)args -> b + (ls + js * args -> ldb) * COMPSIZE, args -> ldb, sb);
      GEMM_ONCOPY(min_l, min_j, (FLOAT *)args -> a + (ls + js * args -> lda) * COMPSIZE, args -> lda, sb2);
#endif

#ifndef LOWER
      min_m = js + min_j;
      if (min_m > m_to) min_m = m_to;

      for(is = m_from; is < min_m; is += min_i){
	min_i = min_m - is;
#else
      min_m = m_from;
      if (m_from < js) min_m = js;

      for(is = min_m; is < m_to; is += min_i){
	min_i = m_to - is;
#endif
	    if (min_i >= GEMM_P * 2) {
	      min_i = GEMM_P;
	    } else 
	      if (min_i > GEMM_P) {
	      min_i = (min_i / 2 + GEMM_UNROLL_M - 1) & ~(GEMM_UNROLL_M - 1);
	      }
	
	if ((is >= js) && (is + min_i <= js + min_j)) {

	  aa = sb2 + min_l * (is - js) * COMPSIZE;

	} else {
#ifndef TRANS
	GEMM_ITCOPY(min_l, min_i, (FLOAT *)args -> a + (is + ls * args -> lda) * COMPSIZE, args -> lda, sa);
#else
	GEMM_INCOPY(min_l, min_i, (FLOAT *)args -> a + (ls + is * args -> lda) * COMPSIZE, args -> lda, sa);
#endif
	aa = sa;
	}
	
#ifndef LOWER
	if (js > is + min_i) {
	  GEMM_KERNEL_N(min_i, min_j, min_l,
			*((FLOAT *)(args -> alpha) + 0),
#ifdef COMPLEX
			*((FLOAT *)(args -> alpha) + 1),
#endif
			aa, sb,
			(FLOAT *)args -> c + (is + js * args -> ldc) * COMPSIZE, args -> ldc); 
	} else
	  if ( is > js + min_j) {
	    /* do nothing */
	  } else {
	    SYR2K_KERNEL_U(min_i, min_j, min_l,
			   *((FLOAT *)(args -> alpha) + 0), 
#ifdef COMPLEX
			   *((FLOAT *)(args -> alpha) + 1),
#endif
			   aa, sb, 
			   (FLOAT *)args -> c + (is + js * args -> ldc) * COMPSIZE, args -> ldc,
			   is - js, 1);
	  }
#else
	if (js > is + min_i) {
	  /* do nothing */
	} else
	  if (is > js + min_j) {
	    GEMM_KERNEL_N(min_i, min_j, min_l,
			  *((FLOAT *)(args -> alpha) + 0),
#ifdef COMPLEX
			  *((FLOAT *)(args -> alpha) + 1),
#endif
			  aa, sb,
			  (FLOAT *)args -> c + (is + js * args -> ldc) * COMPSIZE, args -> ldc); 
	  } else {
	    SYR2K_KERNEL_L(min_i, min_j, min_l,
			   *((FLOAT *)(args -> alpha) + 0), 
#ifdef COMPLEX
			   *((FLOAT *)(args -> alpha) + 1),
#endif
			   aa, sb, 
			   (FLOAT *)args -> c + (is + js * args -> ldc) * COMPSIZE, args -> ldc,
			   is - js, 1);
	  }
#endif

	if ((is >= js) && (is + min_i <= js + min_j)) {

	  aa = sb + min_l * (is - js) * COMPSIZE;

	} else {
#ifndef TRANS
	GEMM_ITCOPY(min_l, min_i, (FLOAT *)args -> b + (is + ls * args -> ldb) * COMPSIZE, args -> ldb, sa);
#else
	GEMM_INCOPY(min_l, min_i, (FLOAT *)args -> b + (ls + is * args -> ldb) * COMPSIZE, args -> ldb, sa);
#endif
	aa = sa;
	}
	
#ifndef LOWER
	if (js > is + min_i) {
	  GEMM_KERNEL_N(min_i, min_j, min_l,
			*((FLOAT *)(args -> alpha) + 0),
#ifdef COMPLEX
			*((FLOAT *)(args -> alpha) + 1),
#endif
			aa, sb2,
			(FLOAT *)args -> c + (is + js * args -> ldc) * COMPSIZE, args -> ldc); 
	} else
	  if ( is > js + min_j) {
	    /* do nothing */
	  } else {
	    SYR2K_KERNEL_U(min_i, min_j, min_l,
			   *((FLOAT *)(args -> alpha) + 0), 
#ifdef COMPLEX
			  *((FLOAT *)(args -> alpha) + 1),
#endif
			  aa, sb2, 
			  (FLOAT *)args -> c + (is + js * args -> ldc) * COMPSIZE, args -> ldc,
			  is - js, 0);
	  }
#else
	if (js > is + min_i) {
	  /* do nothing */
	} else
	  if (is > js + min_j) {
	    GEMM_KERNEL_N(min_i, min_j, min_l,
			  *((FLOAT *)(args -> alpha) + 0),
#ifdef COMPLEX
			  *((FLOAT *)(args -> alpha) + 1),
#endif
			  aa, sb2,
			  (FLOAT *)args -> c + (is + js * args -> ldc) * COMPSIZE, args -> ldc); 
	  } else {
	    SYR2K_KERNEL_L(min_i, min_j, min_l, 
			   *((FLOAT *)(args -> alpha) + 0), 
#ifdef COMPLEX
			  *((FLOAT *)(args -> alpha) + 1),
#endif
			  aa, sb2, 
			  (FLOAT *)args -> c + (is + js * args -> ldc) * COMPSIZE, args -> ldc,
			  is - js, 0);
	  }
#endif

      } /* end of ls */
    } /* end of is */
  } /* end of js */

#else
#if defined(SWITCHING)
  if (args -> n >= SWITCHING) {
#endif
  for(ls = 0; ls < k; ls += min_l){
    min_l = k - ls;
    if (min_l >= GEMM_Q * 2) {
      min_l = GEMM_Q;
    } else 
      if (min_l > GEMM_Q) {
	min_l = (min_l / 2 + GEMM_UNROLL_N - 1) & ~(GEMM_UNROLL_N - 1);
      }
    
    for(js = n_from; js < n_to; js += GEMM_R){
      min_j = n_to - js;
      if (min_j > GEMM_R) min_j = GEMM_R;
      
#ifndef TRANS
      GEMM_OTCOPY(min_l, min_j, (FLOAT *)args -> b + (js + ls * args -> ldb) * COMPSIZE, args -> ldb, sb);
#else
      GEMM_ONCOPY(min_l, min_j, (FLOAT *)args -> b + (ls + js * args -> ldb) * COMPSIZE, args -> ldb, sb);
#endif
      
#ifndef LOWER
      min_m = js + min_j;
      if (min_m > m_to) min_m = m_to;

      for(is = m_from; is < min_m ; is += min_i){
	min_i = min_m - is;
#else
      min_m = m_from;
      if (m_from < js) min_m = js;

	for(is = min_m; is < m_to; is += min_i){
	  min_i = m_to - is;
#endif
	if (min_i >= GEMM_P * 2) {
	  min_i = GEMM_P;
	} else 
	  if (min_i > GEMM_P) {
	    min_i = (min_i / 2 + GEMM_UNROLL_M - 1) & ~(GEMM_UNROLL_M - 1);
	  }
	
#ifndef TRANS
	GEMM_ITCOPY(min_l, min_i, (FLOAT *)args -> a + (is + ls * args -> lda) * COMPSIZE, args -> lda, sa);
#else
	GEMM_INCOPY(min_l, min_i, (FLOAT *)args -> a + (ls + is * args -> lda) * COMPSIZE, args -> lda, sa);
#endif
	
#ifndef LOWER
	if (js > is + min_i) {
	  GEMM_KERNEL_N(min_i, min_j, min_l,
			*((FLOAT *)(args -> alpha) + 0),
#ifdef COMPLEX
			*((FLOAT *)(args -> alpha) + 1),
#endif
			sa, sb,
			(FLOAT *)args -> c + (is + js * args -> ldc) * COMPSIZE, args -> ldc); 
	} else
	  if ( is > js + min_j) {
	    /* do nothing */
	  } else {
	    SYR2K_KERNEL_U(min_i, min_j, min_l,
			   *((FLOAT *)(args -> alpha) + 0), 
#ifdef COMPLEX
			   *((FLOAT *)(args -> alpha) + 1),
#endif
			   sa, sb, 
			   (FLOAT *)args -> c + (is + js * args -> ldc) * COMPSIZE, args -> ldc,
			  is - js, 1);
	  }
#else

	if (js > is + min_i) {
	  /* do nothing */
	} else
	  if (is > js + min_j) {
	    GEMM_KERNEL_N(min_i, min_j, min_l,
			  *((FLOAT *)(args -> alpha) + 0),
#ifdef COMPLEX
			  *((FLOAT *)(args -> alpha) + 1),
#endif
			  sa, sb, 
			  (FLOAT *)args -> c + (is + js * args -> ldc) * COMPSIZE, args -> ldc); 
	  } else {
	    SYR2K_KERNEL_L(min_i, min_j, min_l,
			   *((FLOAT *)(args -> alpha) + 0), 
#ifdef COMPLEX
			   *((FLOAT *)(args -> alpha) + 1),
#endif
			   sa, sb, 
			   (FLOAT *)args -> c + (is + js * args -> ldc) * COMPSIZE, args -> ldc,
			   is - js, 1);
	  }
#endif

      } /* end of ls */

#ifndef TRANS
      GEMM_OTCOPY(min_l, min_j, (FLOAT *)args -> a + (js + ls * args -> lda) * COMPSIZE, args -> lda, sb);
#else
      GEMM_ONCOPY(min_l, min_j, (FLOAT *)args -> a + (ls + js * args -> lda) * COMPSIZE, args -> lda, sb);
#endif
      
      for(is = m_from; is < m_to; is += GEMM_P){
	min_i = m_to - is;
	if (min_i > GEMM_P) min_i = GEMM_P;
	
#ifndef TRANS
	GEMM_ITCOPY(min_l, min_i, (FLOAT *)args -> b + (is + ls * args -> ldb) * COMPSIZE, args -> ldb, sa);
#else
	GEMM_INCOPY(min_l, min_i, (FLOAT *)args -> b + (ls + is * args -> ldb) * COMPSIZE, args -> ldb, sa);
#endif
	
#ifndef LOWER
	if (js > is + min_i) {
	  GEMM_KERNEL_N(min_i, min_j, min_l,
			*((FLOAT *)(args -> alpha) + 0),
#ifdef COMPLEX
			*((FLOAT *)(args -> alpha) + 1),
#endif
			sa, sb,
			(FLOAT *)args -> c + (is + js * args -> ldc) * COMPSIZE, args -> ldc); 
	} else
	  if ( is > js + min_j) {
	    /* do nothing */
	  } else {
	    SYR2K_KERNEL_U(min_i, min_j, min_l,
			   *((FLOAT *)(args -> alpha) + 0), 
#ifdef COMPLEX
			   *((FLOAT *)(args -> alpha) + 1),
#endif
			   sa, sb, 
			   (FLOAT *)args -> c + (is + js * args -> ldc) * COMPSIZE, args -> ldc,
			   is - js, 0);
	  }
#else

	if (js > is + min_i) {
	  /* do nothing */
	} else
	  if (is > js + min_j) {
	    GEMM_KERNEL_N(min_i, min_j, min_l,
			  *((FLOAT *)(args -> alpha) + 0),
#ifdef COMPLEX
			  *((FLOAT *)(args -> alpha) + 1),
#endif
			  sa, sb,
			  (FLOAT *)args -> c + (is + js * args -> ldc) * COMPSIZE, args -> ldc); 
	  } else {
	    SYR2K_KERNEL_L(min_i, min_j, min_l,
			   *((FLOAT *)(args -> alpha) + 0), 
#ifdef COMPLEX
			   *((FLOAT *)(args -> alpha) + 1),
#endif
			   sa, sb, 
			   (FLOAT *)args -> c + (is + js * args -> ldc) * COMPSIZE, args -> ldc,
			   is - js, 0);
	  }
#endif

      } /* end of ls */

    } /* end of is */
  } /* end of js */
#if defined(SWITCHING)
  } else {
    for(ls = 0; ls < k; ls += min_l){
      min_l = k - ls;
      if (min_l >= GEMM_Q * 2) {
	min_l = GEMM_Q;
      } else 
	if (min_l > GEMM_Q) {
	min_l = (min_l / 2 + GEMM_UNROLL_N - 1) & ~(GEMM_UNROLL_N - 1);
	}
      
      for(is = m_from; is < m_to; is += min_i){
	min_i = m_to - is;
	if (min_i > GEMM_PP) min_i = GEMM_PP;
	
#ifndef TRANS
	GEMM_ITCOPY(min_l, min_i, (FLOAT *)args -> a + (is + ls * args -> lda) * COMPSIZE, args -> lda, sa);
#else
	GEMM_INCOPY(min_l, min_i, (FLOAT *)args -> a + (ls + is * args -> lda) * COMPSIZE, args -> lda, sa);
#endif
	
	for(js = n_from; js < n_to; js += MAXMN){
	  min_j = n_to - js;
	  if (min_j > MAXMN) min_j = MAXMN;
	  
#ifndef TRANS
	  GEMM_OTCOPY(min_l, min_j, (FLOAT *)args -> b + (js + ls * args -> ldb) * COMPSIZE, args -> ldb, sb);
#else
	  GEMM_ONCOPY(min_l, min_j, (FLOAT *)args -> b + (ls + js * args -> ldb) * COMPSIZE, args -> ldb, sb);
#endif
      
#ifndef LOWER
	  if (js > is + min_i) {
	    GEMM_KERNEL_N(min_i, min_j, min_l,
			  *((FLOAT *)(args -> alpha) + 0),
#ifdef COMPLEX
			  *((FLOAT *)(args -> alpha) + 1),
#endif
			  sa, sb,
			  (FLOAT *)args -> c + (is + js * args -> ldc) * COMPSIZE, args -> ldc); 
	  } else
	    if ( is > js + min_j) {
	      /* do nothing */
	    } else {
	      SYR2K_KERNEL_U(min_i, min_j, min_l,
			     *((FLOAT *)(args -> alpha) + 0), 
#ifdef COMPLEX
			     *((FLOAT *)(args -> alpha) + 1),
#endif
			     sa, sb, 
			     (FLOAT *)args -> c + (is + js * args -> ldc) * COMPSIZE, args -> ldc,
			     is - js, 1);
	    }
#else
	  
	  if (js > is + min_i) {
	    /* do nothing */
	  } else
	    if (is > js + min_j) {
	      GEMM_KERNEL_N(min_i, min_j, min_l,
			    *((FLOAT *)(args -> alpha) + 0),
#ifdef COMPLEX
			    *((FLOAT *)(args -> alpha) + 1),
#endif
			    sa, sb,
			    (FLOAT *)args -> c + (is + js * args -> ldc) * COMPSIZE, args -> ldc); 
	    } else {
	      SYR2K_KERNEL_L(min_i, min_j, min_l,
			     *((FLOAT *)(args -> alpha) + 0), 
#ifdef COMPLEX
			     *((FLOAT *)(args -> alpha) + 1),
#endif
			     sa, sb, 
			     (FLOAT *)args -> c + (is + js * args -> ldc) * COMPSIZE, args -> ldc,
			     is - js, 1);
	    }
#endif
	  
	} /* end of is */
	
#ifndef TRANS
	GEMM_ITCOPY(min_l, min_i, (FLOAT *)args -> b + (is + ls * args -> ldb) * COMPSIZE, args -> ldb, sa);
#else
	GEMM_INCOPY(min_l, min_i, (FLOAT *)args -> b + (ls + is * args -> ldb) * COMPSIZE, args -> ldb, sa);
#endif
	
	for(js = n_from; js < n_to; js += MAXMN){
	  min_j = n_to - js;
	  if (min_j > MAXMN) min_j = MAXMN;
	  
#ifndef TRANS
	  GEMM_OTCOPY(min_l, min_j, (FLOAT *)args -> a + (js + ls * args -> lda) * COMPSIZE, args -> lda, sb);
#else
	  GEMM_ONCOPY(min_l, min_j, (FLOAT *)args -> a + (ls + js * args -> lda) * COMPSIZE, args -> lda, sb);
#endif
	
	  
#ifndef LOWER
	  if (js > is + min_i) {
	    GEMM_KERNEL_N(min_i, min_j, min_l,
			  *((FLOAT *)(args -> alpha) + 0),
#ifdef COMPLEX
			  *((FLOAT *)(args -> alpha) + 1),
#endif
			  sa, sb, 
			  (FLOAT *)args -> c + (is + js * args -> ldc) * COMPSIZE, args -> ldc); 
	  } else
	    if ( is > js + min_j) {
	      /* do nothing */
	    } else {
	      SYR2K_KERNEL_U(min_i, min_j, min_l,
			     *((FLOAT *)(args -> alpha) + 0), 
#ifdef COMPLEX
			     *((FLOAT *)(args -> alpha) + 1),
#endif
			     sa, sb, 
			     (FLOAT *)args -> c + (is + js * args -> ldc) * COMPSIZE, args -> ldc,
			     is - js, 0);
	    }
#else
	  
	  if (js > is + min_i) {
	    /* do nothing */
	  } else
	    if (is > js + min_j) {
	      GEMM_KERNEL_N(min_i, min_j, min_l,
			    *((FLOAT *)(args -> alpha) + 0),
#ifdef COMPLEX
			    *((FLOAT *)(args -> alpha) + 1),
#endif
			    sa, sb,
			    (FLOAT *)args -> c + (is + js * args -> ldc) * COMPSIZE, args -> ldc); 
	    } else {
	      SYR2K_KERNEL_L(min_i, min_j, min_l,
			     *((FLOAT *)(args -> alpha) + 0), 
#ifdef COMPLEX
			     *((FLOAT *)(args -> alpha) + 1),
#endif
			     sa, sb, 
			     (FLOAT *)args -> c + (is + js * args -> ldc) * COMPSIZE, args -> ldc,
			     is - js, 0);
	    }
#endif
	  
	} /* end of ls */
      } /* end of is */


    } /* end of js */
  }
#endif
#endif

  return 0;
}