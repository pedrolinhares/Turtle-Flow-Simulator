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
#include "param.h"

static FLOAT dm1 = -1.;

double fabs(double);

static inline void inner_trsm(BLASLONG m, BLASLONG n, FLOAT *a, BLASLONG lda, FLOAT *b, BLASLONG ldb, FLOAT *sa, FLOAT *sb){

  BLASLONG i, is;
  BLASLONG j, js;
#ifndef UNIT
  FLOAT alpha_r, alpha_i;
  FLOAT ratio, den, ar, ai;
#endif

  for (js = 0; js < n; js += TRSM_Q1){
    
    j = MIN(TRSM_Q1, n - js);

    for (is = m; is > 0; is -= TRSM_P1){

      for (i = is - 1; i >= MAX(is-TRSM_P1, 0); i--) {

#if   (TRANSA == 1) && !defined(TRANSB)
	ZGEMV_T(is - i - 1, j, 0, dm1, ZERO,
		b + (i + 1 + js * ldb) * 2, ldb, 
		a + (i + (i + 1)* lda) * 2, lda,
		b + (i +     js * ldb) * 2, ldb, sb);
#elif (TRANSA == 2) && !defined(TRANSB)
	ZGEMV_T(is - i - 1, j, 0, dm1, ZERO,       
		b + (i + 1 + js * ldb) * 2, ldb, 
		a + (i + 1 + i  * lda) * 2, 1,
		b + (i +     js * ldb) * 2, ldb, sb);
#elif (TRANSA == 3) && !defined(TRANSB)
	ZGEMV_U(is - i - 1, j, 0, dm1, ZERO,
		b + (i + 1 + js * ldb) * 2, ldb, 
		a + (i + (i + 1)* lda) * 2, lda,
		b + (i +     js * ldb) * 2, ldb, sb);
#elif (TRANSA == 4) && !defined(TRANSB)
	ZGEMV_U(is - i - 1, j, 0, dm1, ZERO,       
		b + (i + 1 + js * ldb) * 2, ldb, 
		a + (i + 1 + i  * lda) * 2, 1,
		b + (i +     js * ldb) * 2, ldb, sb);
#elif (TRANSA == 1) &&  defined(TRANSB)
	ZGEMV_N(j, is - i - 1, 0, dm1,  ZERO,
		b + (js + (i + 1) * ldb) * 2, ldb, 
		a + (i  + (i + 1) * lda) * 2, lda,
		b + (js +  i      * ldb) * 2, 1, sb);
#elif (TRANSA == 2) &&  defined(TRANSB)
	ZGEMV_N(j, is - i - 1, 0, dm1,  ZERO,    
		b + (js + (i + 1) * ldb) * 2, ldb, 
		a + (i + 1 +   i  * lda) * 2, 1,
		b + (js  +     i  * ldb) * 2, 1, sb);
#elif (TRANSA == 3) &&  defined(TRANSB)
	ZGEMV_O(j, is - i - 1, 0, dm1,  ZERO,
		b + (js + (i + 1) * ldb) * 2, ldb, 
		a + (i  + (i + 1) * lda) * 2, lda,
		b + (js +  i      * ldb) * 2, 1, sb);
#elif (TRANSA == 4) &&  defined(TRANSB)
	ZGEMV_O(j, is - i - 1, 0, dm1,  ZERO,    
		b + (js + (i + 1) * ldb) * 2, ldb, 
		a + (i + 1 +   i  * lda) * 2, 1,
		b + (js  +     i  * ldb) * 2, 1, sb);
#else
#error
#endif

#ifndef UNIT
	ar = a[(i +  i * lda) * 2 + 0];
	ai = a[(i +  i * lda) * 2 + 1];

	if (fabs(ar) >= fabs(ai)){
	  ratio = ai / ar;
	  den = 1./(ar * ( 1 + ratio * ratio));
	  alpha_r =  den;
#ifndef CONJ
	  alpha_i = -ratio * den;
#else
	  alpha_i =  ratio * den;
#endif
	} else {
	  ratio = ar / ai;
	  den = 1./(ai * ( 1 + ratio * ratio));
	  alpha_r =  ratio * den;
#ifndef CONJ
	  alpha_i = -den;
#else
	  alpha_i =  den;
#endif
	}

#ifndef TRANSB
	ZSCAL_K(j, 0, 0, alpha_r, alpha_i,
	       b + (i + js * ldb) * 2, ldb, NULL, 0, NULL, 0);
#else
	ZSCAL_K(j, 0, 0, alpha_r, alpha_i,
	       b + (i * ldb + js) * 2, 1,   NULL, 0, NULL, 0);
#endif
#endif
  }
    
      if (is > TRSM_P1){
#if   (TRANSA == 1) && !defined(TRANSB)
	GEMM_NN(is - TRSM_P1, j, TRSM_P1, dm1,  ZERO,
		 a + (is - TRSM_P1) * lda      * 2, lda,
		 b + (is - TRSM_P1 + js * ldb) * 2, ldb,
		 b            + js * ldb  * 2, ldb,
		 sa, sb);
#elif (TRANSA == 3) && !defined(TRANSB)
	GEMM_RN(is - TRSM_P1, j, TRSM_P1, dm1,  ZERO,
		 a + (is - TRSM_P1) * lda      * 2, lda,
		 b + (is - TRSM_P1 + js * ldb) * 2, ldb,
		 b            + js * ldb  * 2, ldb,
		 sa, sb);
#elif (TRANSA == 1) &&  defined(TRANSB)
	GEMM_NT(j, is - TRSM_P1, TRSM_P1, dm1,  ZERO,
		 b + ((is - TRSM_P1) * ldb + js) * 2, ldb,
		 a + ((is - TRSM_P1) * lda)      * 2, lda,
		 b                    + js  * 2, ldb,
		 sa, sb);
#elif (TRANSA == 3) &&  defined(TRANSB)
	GEMM_NC(j, is - TRSM_P1, TRSM_P1, dm1,  ZERO,
		 b + ((is - TRSM_P1) * ldb + js) * 2, ldb,
		 a + ((is - TRSM_P1) * lda)      * 2, lda,
		 b                    + js  * 2, ldb,
		 sa, sb);
#elif (TRANSA == 2) && !defined(TRANSB)
	GEMM_TN(is - TRSM_P1, j, TRSM_P1, dm1,  ZERO,
		 a + (is - TRSM_P1) * 2, lda,
		 b + (is - TRSM_P1 + js * ldb) * 2, ldb,
		 b            + js * ldb  * 2, ldb,
		 sa, sb);
#elif (TRANSA == 4) && !defined(TRANSB)
	GEMM_CN(is - TRSM_P1, j, TRSM_P1, dm1,  ZERO,
		 a + (is - TRSM_P1)            * 2, lda,
		 b + (is - TRSM_P1 + js * ldb) * 2, ldb,
		 b            + js * ldb  * 2, ldb,
		 sa, sb);
#elif (TRANSA == 2) &&  defined(TRANSB)
	GEMM_NN(j, is - TRSM_P1, TRSM_P1, dm1,  ZERO,
		 b + ((is - TRSM_P1) * ldb + js) * 2, ldb,
		 a +  (is - TRSM_P1)             * 2, lda,
		 b                    + js  * 2, ldb,
		 sa, sb);
#else
	GEMM_NR(j, is - TRSM_P1, TRSM_P1, dm1,  ZERO,
		 b + ((is - TRSM_P1) * ldb + js) * 2, ldb,
		 a +  (is - TRSM_P1)             * 2, lda,
		 b                    + js  * 2, ldb,
		 sa, sb);
#endif
      }

    }
  }
  return;
}

#ifndef TRANSB
int CNAME(BLASLONG m, BLASLONG n, BLASLONG dummy1, FLOAT dummy2, FLOAT dummy3, FLOAT *a, BLASLONG lda, FLOAT *dummy4, BLASLONG dummy5, FLOAT *b, BLASLONG ldb, FLOAT *sa, FLOAT *sb){
#else
int CNAME(BLASLONG n, BLASLONG m, BLASLONG dummy1, FLOAT dummy2, FLOAT dummy3, FLOAT *a, BLASLONG lda, FLOAT *dummy4, BLASLONG dummy5, FLOAT *b, BLASLONG ldb, FLOAT *sa, FLOAT *sb){
#endif

#ifdef TRSM_Q2

  BLASLONG i, is, j, js;

  for (js = 0; js < n; js += TRSM_Q2){
    
    j = MIN(TRSM_Q2, n - js);

    for (is = m; is > 0; is -= TRSM_P2){

      i = MAX(is - TRSM_P2, 0);

#ifndef TRANSB
      inner_trsm(MIN(is, TRSM_P2), j, a + (i + i * lda) * 2, lda,
		 b + (i  + js * ldb) * 2, ldb, sa, sb);
#else
      inner_trsm(MIN(is, TRSM_P2), j, a + (i + i * lda) * 2, lda,
		 b + (js + i  * ldb) * 2, ldb, sa, sb);
#endif

      if (is > TRSM_P2){
#if   (TRANSA == 1) && !defined(TRANSB)
	GEMM_NN(is - TRSM_P2, j, TRSM_P2, dm1,  ZERO,
		 a + (is - TRSM_P2) * lda      * 2, lda,
		 b + (is - TRSM_P2 + js * ldb) * 2, ldb,
		 b            + js * ldb  * 2, ldb,
		 sa, sb);
#elif (TRANSA == 3) && !defined(TRANSB)
	GEMM_RN(is - TRSM_P2, j, TRSM_P2, dm1,  ZERO,
		 a + (is - TRSM_P2) * lda      * 2, lda,
		 b + (is - TRSM_P2 + js * ldb) * 2, ldb,
		 b            + js * ldb  * 2, ldb,
		 sa, sb);
#elif (TRANSA == 1) &&  defined(TRANSB)
	GEMM_NT(j, is - TRSM_P2, TRSM_P2, dm1,  ZERO,
		 b + ((is - TRSM_P2) * ldb + js) * 2, ldb,
		 a + ((is - TRSM_P2) * lda)      * 2, lda,
		 b                    + js  * 2, ldb,
		 sa, sb);
#elif (TRANSA == 3) &&  defined(TRANSB)
	GEMM_NC(j, is - TRSM_P2, TRSM_P2, dm1,  ZERO,
		 b + ((is - TRSM_P2) * ldb + js) * 2, ldb,
		 a + ((is - TRSM_P2) * lda)      * 2, lda,
		 b                    + js  * 2, ldb,
		 sa, sb);
#elif (TRANSA == 2) && !defined(TRANSB)
	GEMM_TN(is - TRSM_P2, j, TRSM_P2, dm1,  ZERO,
		 a + (is - TRSM_P2) * 2, lda,
		 b + (is - TRSM_P2 + js * ldb) * 2, ldb,
		 b            + js * ldb  * 2, ldb,
		 sa, sb);
#elif (TRANSA == 4) && !defined(TRANSB)
	GEMM_CN(is - TRSM_P2, j, TRSM_P2, dm1,  ZERO,
		 a + (is - TRSM_P2)            * 2, lda,
		 b + (is - TRSM_P2 + js * ldb) * 2, ldb,
		 b            + js * ldb  * 2, ldb,
		 sa, sb);
#elif (TRANSA == 2) &&  defined(TRANSB)
	GEMM_NN(j, is - TRSM_P2, TRSM_P2, dm1,  ZERO,
		 b + ((is - TRSM_P2) * ldb + js) * 2, ldb,
		 a +  (is - TRSM_P2)             * 2, lda,
		 b                    + js  * 2, ldb,
		 sa, sb);
#else
	GEMM_NR(j, is - TRSM_P2, TRSM_P2, dm1,  ZERO,
		 b + ((is - TRSM_P2) * ldb + js) * 2, ldb,
		 a +  (is - TRSM_P2)             * 2, lda,
		 b                    + js  * 2, ldb,
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
    inner_trsm(MIN(is, TRSM_P2), n, a + (i + i * lda) * 2, lda,
	       b + i       * 2, ldb, sa, sb);
#else
    inner_trsm(MIN(is, TRSM_P2), n, a + (i + i * lda) * 2, lda,
	       b + i * ldb * 2, ldb, sa, sb);
#endif

      if (is > TRSM_P2){
#if   (TRANSA == 1) && !defined(TRANSB)
	GEMM_NN(is - TRSM_P2, n, TRSM_P2, dm1,  ZERO,
		 a + (is - TRSM_P2) * lda * 2, lda,
		 b + (is - TRSM_P2)       * 2, ldb,
		 b                      , ldb,
		 sa, sb);
#elif (TRANSA == 3) && !defined(TRANSB)
	GEMM_RN(is - TRSM_P2, n, TRSM_P2, dm1,  ZERO,
		 a + (is - TRSM_P2) * lda * 2, lda,
		 b + (is - TRSM_P2)       * 2, ldb,
		 b                      , ldb,
		 sa, sb);
#elif (TRANSA == 1) &&  defined(TRANSB)
	GEMM_NT(n, is - TRSM_P2, TRSM_P2, dm1,  ZERO,
		 b + (is - TRSM_P2) * ldb  * 2, ldb,
		 a + (is - TRSM_P2) * lda  * 2, lda,
		 b                       , ldb,
		 sa, sb);
#elif (TRANSA == 3) &&  defined(TRANSB)
	GEMM_NC(n, is - TRSM_P2, TRSM_P2, dm1,  ZERO,
		 b + (is - TRSM_P2) * ldb * 2, ldb,
		 a + (is - TRSM_P2) * lda * 2, lda,
		 b                      , ldb,
		 sa, sb);
#elif (TRANSA == 2) && !defined(TRANSB)
	GEMM_TN(is - TRSM_P2, n, TRSM_P2, dm1,  ZERO,
		 a + (is - TRSM_P2)       * 2, lda,
		 b + (is - TRSM_P2)       * 2, ldb,
		 b                      , ldb,
		 sa, sb);
#elif (TRANSA == 4) && !defined(TRANSB)
	GEMM_CN(is - TRSM_P2, n, TRSM_P2, dm1,  ZERO,
		 a + (is - TRSM_P2)       * 2, lda,
		 b + (is - TRSM_P2)       * 2, ldb,
		 b                      , ldb,
		 sa, sb);
#elif (TRANSA == 2) &&  defined(TRANSB)
	GEMM_NN(n, is - TRSM_P2, TRSM_P2, dm1,  ZERO,
		 b + (is - TRSM_P2) * ldb * 2, ldb,
		 a + (is - TRSM_P2)       * 2, lda,
		 b                      , ldb,
		 sa, sb);
#else
	GEMM_NR(n, is - TRSM_P2, TRSM_P2, dm1,  ZERO,
		 b + (is - TRSM_P2) * ldb * 2, ldb,
		 a + (is - TRSM_P2)       * 2, lda,
		 b                      , ldb,
		 sa, sb);
#endif
      }
  }

#endif

  return 0;
}
