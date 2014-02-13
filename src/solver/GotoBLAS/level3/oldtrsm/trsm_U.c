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

const static FLOAT dm1 = -1.;

static inline void inner_trsm(BLASLONG m, BLASLONG n,  FLOAT *a, BLASLONG lda,
			      FLOAT *b, BLASLONG ldb, FLOAT *sa, FLOAT *sb){

  BLASLONG i, is;
  BLASLONG j, js;

  for (js = 0; js < n; js += TRSM_Q1){
    
    j = MIN(TRSM_Q1, n - js);

    for (is = m; is > 0; is -= TRSM_P1){

      for (i = is - 1; i >= MAX(is - TRSM_P1, 0); i--) {

#if 1
#if   !defined(TRANSA) && !defined(TRANSB)
	GEMV_T(is - i - 1, j, 0, dm1,
	       b + js * ldb + i + 1, ldb, 
	       a + i + (i + 1)*lda, lda,
	       b + js * ldb + i,     ldb, sb);
#elif  defined(TRANSA) && !defined(TRANSB)
	GEMV_T(is - i - 1, j, 0, dm1, 
	       b + js * ldb + i + 1, ldb, 
	       a + i + 1 + i*lda,  1,
	       b + js * ldb + i,     ldb, sb);
#elif !defined(TRANSA) &&  defined(TRANSB)
	GEMV_N(j, is - i - 1, 0, dm1, 
	       b + (i + 1)*ldb + js, ldb, 
	       a + i + (i + 1)*lda,  lda,
	       b +  i     *ldb + js, 1, sb);
#else
	GEMV_N(j, is - i - 1, 0, dm1, 
	       b +  (i + 1)*ldb +js, ldb, 
	       a + i + 1 + i*lda,    1,
	       b +  i     *ldb + js, 1, sb);
#endif
#endif

#ifndef UNIT
#ifndef TRANSB
	SCAL_K(j, 0, 0, 1./a[i +  i * lda],
	      b + js * ldb + i, ldb, NULL, 0, NULL, 0);
#else
	SCAL_K(j, 0, 0, 1./a[i +  i * lda], 
	      b + i*ldb + js, 1,   NULL, 0, NULL, 0);
#endif
#endif
  }
    
      if (is > TRSM_P1){
#if   !defined(TRANSA) && !defined(TRANSB)
	GEMM_NN(is - TRSM_P1, j, TRSM_P1, dm1, 
		a + (is - TRSM_P1)*lda     , lda,
		b +  is - TRSM_P1 + js*ldb , ldb,
		b            + js*ldb , ldb,
		sa, sb);
#elif !defined(TRANSA) &&  defined(TRANSB)
	GEMM_NT(j, is - TRSM_P1, TRSM_P1, dm1, 
		b + (is - TRSM_P1)*ldb + js, ldb,
		a + (is - TRSM_P1)*lda     , lda,
		b                 + js, ldb,
		sa, sb);
#elif  defined(TRANSA) && !defined(TRANSB)
	GEMM_TN(is - TRSM_P1, j, TRSM_P1, dm1, 
		a +  is - TRSM_P1          , lda,
		b +  is - TRSM_P1 + js*ldb , ldb,
		b            + js*ldb , ldb,
		sa, sb);
#else
	GEMM_NN(j, is - TRSM_P1, TRSM_P1, dm1, 
		b + (is - TRSM_P1)*ldb + js, ldb,
		a +  is - TRSM_P1          , lda,
		b                 + js, ldb,
		sa, sb);
#endif
      }
    }
  }
  return;
}

#ifndef TRANSB
int CNAME(BLASLONG m, BLASLONG n, BLASLONG dummy1, FLOAT dummy2, FLOAT *a, BLASLONG lda, FLOAT *dummy3, BLASLONG dummy4, FLOAT *b, BLASLONG ldb, FLOAT *sa, FLOAT *sb){
#else
int CNAME(BLASLONG n, BLASLONG m, BLASLONG dummy1, FLOAT dummy2, FLOAT *a, BLASLONG lda, FLOAT *dummy3, BLASLONG dummy4, FLOAT *b, BLASLONG ldb, FLOAT *sa, FLOAT *sb){
#endif

#ifdef TRSM_Q2

  BLASLONG i, is, j, js;

  for (js = 0; js < n; js += TRSM_Q2){
    
    j = MIN(TRSM_Q2, n - js);

    for (is = m; is > 0; is -= TRSM_P2){

      i = MAX(is - TRSM_P2, 0);

#ifndef TRANSB
      inner_trsm(MIN(is, TRSM_P2), j, a + i + i*lda, lda, b + i + js * ldb, ldb, sa, sb);
#else
      inner_trsm(MIN(is, TRSM_P2), j, a + i + i*lda, lda, b + js + i * ldb, ldb, sa, sb);
#endif

      if (is > TRSM_P2){
#if   !defined(TRANSA) && !defined(TRANSB)
	GEMM_NN(is - TRSM_P2, j, TRSM_P2, dm1, 
		a + (is - TRSM_P2)*lda     , lda,
		b +  is - TRSM_P2 + js*ldb , ldb,
		b            + js*ldb , ldb,
		sa, sb);
#elif !defined(TRANSA) &&  defined(TRANSB)
	GEMM_NT(j, is - TRSM_P2, TRSM_P2, dm1, 
		b + (is - TRSM_P2)*ldb + js, ldb,
		a + (is - TRSM_P2)*lda     , lda,
		b                 + js, ldb,
		sa, sb);
#elif  defined(TRANSA) && !defined(TRANSB)
	GEMM_TN(is - TRSM_P2, j, TRSM_P2, dm1, 
		a +  is - TRSM_P2          , lda,
		b +  is - TRSM_P2 + js*ldb , ldb,
		b            + js*ldb , ldb,
		sa, sb);
#else
	GEMM_NN(j, is - TRSM_P2, TRSM_P2, dm1, 
		b + (is - TRSM_P2)*ldb + js, ldb,
		a +  is - TRSM_P2          , lda,
		b                 + js, ldb,
		sa, sb);
#endif
      }
    }
  }

#else

  BLASLONG i, is;

  for (is = m; is > 0; is -= TRSM_P2){

    i = MAX(is - TRSM_P2, 0);
    
#ifndef TRANSB
    inner_trsm(MIN(is, TRSM_P2), n, a + i + i*lda, lda,  b + i      , ldb, sa, sb);
#else
    inner_trsm(MIN(is, TRSM_P2), n, a + i + i*lda, lda,  b + i * ldb, ldb, sa, sb);
#endif
    
    if (is > TRSM_P2){

#if   !defined(TRANSA) && !defined(TRANSB)
      GEMM_NN(is - TRSM_P2, n, TRSM_P2, dm1, 
	      a + (is - TRSM_P2)*lda     , lda,
	      b +  is - TRSM_P2          , ldb,
	      b                     , ldb,
	      sa, sb);
#elif !defined(TRANSA) &&  defined(TRANSB)
      GEMM_NT(n, is - TRSM_P2, TRSM_P2, dm1, 
	      b + (is - TRSM_P2)*ldb     , ldb,
	      a + (is - TRSM_P2)*lda     , lda,
	      b                     , ldb,
	      sa, sb);
#elif  defined(TRANSA) && !defined(TRANSB)
      GEMM_TN(is - TRSM_P2, n, TRSM_P2, dm1, 
	      a +  is - TRSM_P2          , lda,
	      b +  is - TRSM_P2          , ldb,
	      b                     , ldb,
	      sa, sb);
#else
      GEMM_NN(n, is - TRSM_P2, TRSM_P2, dm1, 
	      b + (is - TRSM_P2) * ldb, ldb,
	      a +  is - TRSM_P2       , lda,
	      b                  , ldb,
	      sa, sb);
#endif
    }
  }

#endif

  return 0;
}
