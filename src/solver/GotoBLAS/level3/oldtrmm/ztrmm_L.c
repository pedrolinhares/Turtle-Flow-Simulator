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

static FLOAT dp1 =1.;

double fabs(double);

static inline void inner_trmm(BLASLONG m, BLASLONG n, FLOAT *a, BLASLONG lda, FLOAT *b, BLASLONG ldb, FLOAT *buffer){

  BLASLONG i, is, ii;
  BLASLONG j, js;
#ifndef UNIT
  FLOAT alpha_r, alpha_i;
#endif

  for (js = 0; js < n; js += TRSM_Q1){

    j = MIN(TRSM_Q1, n - js);

    for (is = m; is > 0; is -= TRSM_P1){

      ii = MAX(is - TRSM_P1, 0);

      if (m > is){
#if   (TRANSA == 1) && !defined(TRANSB)
	GEMM_NN(m - is, j, MIN(is, TRSM_P1), dp1, ZERO,
		 a + (is + ii * lda) * 2, lda,
		 b + (ii + js * ldb) * 2, ldb,
		 b + (is + js * ldb) * 2, ldb,
		 buffer);
#elif (TRANSA == 3) && !defined(TRANSB)
	GEMM_RN(m - is, j, MIN(is, TRSM_P1), dp1, ZERO,
		 a + (is + ii * lda) * 2, lda,
		 b + (ii + js * ldb) * 2, ldb,
		 b + (is + js * ldb) * 2, ldb,
		 buffer);
#elif (TRANSA == 1) &&  defined(TRANSB)
	GEMM_NT(j, m - is, MIN(is, TRSM_P1), dp1, ZERO,
		 b + (js + ii * ldb) * 2, ldb,
		 a + (is + ii * lda) * 2, lda,
		 b + (js + is * ldb) * 2, ldb,
		 buffer);
#elif (TRANSA == 3) &&  defined(TRANSB)
	GEMM_NC(j, m - is, MIN(is, TRSM_P1), dp1, ZERO,
		 b + (js + ii * ldb) * 2, ldb,
		 a + (is + ii * lda) * 2, lda,
		 b + (js + is * ldb) * 2, ldb,
		 buffer);
#elif (TRANSA == 2) && !defined(TRANSB)
	GEMM_TN(m - is, j, MIN(is, TRSM_P1), dp1, ZERO,
		 a + (ii + is * lda) * 2, lda,
		 b + (ii + js * ldb) * 2, ldb,
		 b + (is + js * ldb) * 2, ldb,
		 buffer);
#elif (TRANSA == 4) && !defined(TRANSB)
	GEMM_CN(m - is, j, MIN(is, TRSM_P1), dp1, ZERO,
		 a + (ii + is * lda) * 2, lda,
		 b + (ii + js * ldb) * 2, ldb,
		 b + (is + js * ldb) * 2, ldb,
		 buffer);
#elif (TRANSA == 2) &&  defined(TRANSB)
	GEMM_NN(j, m - is, MIN(is, TRSM_P1), dp1, ZERO,
		 b + (js + ii * ldb) * 2, ldb,
		 a + (ii + is * lda) * 2, lda,
		 b + (js + is * ldb) * 2, ldb,
		 buffer);
#elif (TRANSA == 4) &&  defined(TRANSB)
	GEMM_NR(j, m - is, MIN(is, TRSM_P1), dp1, ZERO,
		 b + (js + ii * ldb) * 2, ldb,
		 a + (ii + is * lda) * 2, lda,
		 b + (js + is * ldb) * 2, ldb,
		 buffer);
#endif
      }

      for (i = is - 1; i >= ii; i--) {
#ifndef UNIT
	alpha_r =  a[(i + i * lda) * 2 + 0];
#if TRANSA <= 2
	alpha_i =  a[(i + i * lda) * 2 + 1];
#else
	alpha_i = -a[(i + i * lda) * 2 + 1];
#endif

#ifndef TRANSB
	ZSCAL_K(j, 0, 0, alpha_r, alpha_i,
	       b + (i + js * ldb) * 2, ldb, NULL, 0, NULL, 0);
#else
	ZSCAL_K(j, 0, 0, alpha_r, alpha_i,
	       b + (i * ldb + js) * 2, 1,   NULL, 0, NULL, 0);
#endif
#endif
	
#if   (TRANSA == 1) && !defined(TRANSB)
	ZGEMV_T(i - ii, j, 0, dp1, ZERO,
		b + (ii + js * ldb) * 2, ldb, 
		a + (i  + ii * lda) * 2, lda,
		b + (i  + js * ldb) * 2, ldb, buffer);
#elif (TRANSA == 2) && !defined(TRANSB)
	ZGEMV_T(i - ii, j, 0, dp1, ZERO,
		b + (ii + js * ldb) * 2, ldb, 
		a + (ii + i  * lda) * 2, 1,
		b + (i  + js * ldb) * 2, ldb, buffer);
#elif (TRANSA == 3) && !defined(TRANSB)
	ZGEMV_U(i - ii, j, 0, dp1, ZERO,
		b + (ii + js * ldb) * 2, ldb, 
		a + (i  + ii * lda) * 2, lda,
		b + (i  + js * ldb) * 2, ldb, buffer);
#elif (TRANSA == 4) && !defined(TRANSB)
	ZGEMV_U(i - ii, j, 0, dp1, ZERO,
		b + (ii + js * ldb) * 2, ldb, 
		a + (ii + i  * lda) * 2, 1,
		b + (i  + js * ldb) * 2, ldb, buffer);
#elif (TRANSA == 1) &&  defined(TRANSB)
	ZGEMV_N(j, i - ii, 0, dp1, ZERO,
		b + (js + ii * ldb) * 2, ldb,
		a + (i  + ii * lda) * 2, lda,
		b + (js + i  * ldb) * 2, 1, buffer);
#elif (TRANSA == 2) &&  defined(TRANSB)
	ZGEMV_N(j, i - ii, 0, dp1, ZERO,
		b + (js + ii * ldb) * 2, ldb,
		a + (ii + i  * lda) * 2, 1,
		b + (js + i  * ldb) * 2, 1, buffer);
#elif (TRANSA == 3) &&  defined(TRANSB)
	ZGEMV_O(j, i - ii, 0, dp1, ZERO,
		b + (js + ii * ldb) * 2, ldb,
		a + (i  + ii * lda) * 2, lda,
		b + (js + i  * ldb) * 2, 1, buffer);
#elif (TRANSA == 4) &&  defined(TRANSB)
	ZGEMV_O(j, i - ii, 0, dp1, ZERO,
		b + (js + ii * ldb) * 2, ldb,
		a + (ii + i  * lda) * 2, 1,
		b + (js + i  * ldb) * 2, 1, buffer);
#else
#error
#endif
      }

#if 0
#if (TRANSA == 2) || (TRANSA == 4)
      if (is > TRSM_P1){
#ifndef TRANSB
#if TRANSA == 2
	GEMM_TN(TRSM_P1, j, is - TRSM_P1, dp1, ZERO,
		 a + (is - TRSM_P1) * lda * 2,       lda,
		 b + (           js * ldb) * 2, ldb,
		 b + ( is - TRSM_P1 + js * ldb) * 2, ldb,
		 buffer);
#else
	GEMM_CN(TRSM_P1, j, is - TRSM_P1, dp1, ZERO,
		 a + (is - TRSM_P1) * lda * 2,       lda,
		 b + (           js * ldb) * 2, ldb,
		 b + ( is - TRSM_P1 + js * ldb) * 2, ldb,
		 buffer);
#endif
#else
#if TRANSA == 2
	GEMM_NN(j, TRSM_P1, is - TRSM_P1, dp1, ZERO,
		b +  js                    * 2, ldb,
		a + (is - TRSM_P1) * lda * 2,        lda,
		b + (js + (is - TRSM_P1) * ldb) * 2, ldb,
		buffer);
#else
	GEMM_NR(j, TRSM_P1, is - TRSM_P1, dp1, ZERO,
		b +  js                    * 2, ldb,
		a + (is - TRSM_P1) * lda * 2,        lda,
		b + (js + (is - TRSM_P1) * ldb) * 2, ldb,
		buffer);
#endif
#endif
      }
#endif
#endif

    }
  }
  return;
}

#ifndef TRANSB
int CNAME(BLASLONG m, BLASLONG n, BLASLONG dummy1, FLOAT dummy2, FLOAT dummy3, FLOAT *a, BLASLONG lda, FLOAT *dummy4, BLASLONG dummy5, FLOAT *b, BLASLONG ldb, FLOAT *buffer){
#else
int CNAME(BLASLONG n, BLASLONG m, BLASLONG dummy1, FLOAT dummy2, FLOAT dummy3, FLOAT *a, BLASLONG lda, FLOAT *dummy4, BLASLONG dummy5, FLOAT *b, BLASLONG ldb, FLOAT *buffer){
#endif

#ifdef TRSM_Q2

  BLASLONG is, j, js, ii;

  for (js = 0; js < n; js += TRSM_Q2){

    j = MIN(TRSM_Q2, n - js);

    for (is = m; is > 0; is -= TRSM_P2){

      ii = MAX(is - TRSM_P2, 0);

      if (m > is){
#if   (TRANSA == 1) && !defined(TRANSB)
	GEMM_NN(m - is, j, MIN(is, TRSM_P2), dp1, ZERO,
		 a + (is + ii * lda) * 2, lda,
		 b + (ii + js * ldb) * 2, ldb,
		 b + (is + js * ldb) * 2, ldb,
		 buffer);
#elif (TRANSA == 3) && !defined(TRANSB)
	GEMM_RN(m - is, j, MIN(is, TRSM_P2), dp1, ZERO,
		 a + (is + ii * lda) * 2, lda,
		 b + (ii + js * ldb) * 2, ldb,
		 b + (is + js * ldb) * 2, ldb,
		 buffer);
#elif (TRANSA == 1) &&  defined(TRANSB)
	GEMM_NT(j, m - is, MIN(is, TRSM_P2), dp1, ZERO,
		 b + (js + ii * ldb) * 2, ldb,
		 a + (is + ii * lda) * 2, lda,
		 b + (js + is * ldb) * 2, ldb,
		 buffer);
#elif (TRANSA == 3) &&  defined(TRANSB)
	GEMM_NC(j, m - is, MIN(is, TRSM_P2), dp1, ZERO,
		 b + (js + ii * ldb) * 2, ldb,
		 a + (is + ii * lda) * 2, lda,
		 b + (js + is * ldb) * 2, ldb,
		 buffer);
#elif (TRANSA == 2) && !defined(TRANSB)
	GEMM_TN(m - is, j, MIN(is, TRSM_P2), dp1, ZERO,
		 a + (ii + is * lda) * 2, lda,
		 b + (ii + js * ldb) * 2, ldb,
		 b + (is + js * ldb) * 2, ldb,
		 buffer);
#elif (TRANSA == 4) && !defined(TRANSB)
	GEMM_CN(m - is, j, MIN(is, TRSM_P2), dp1, ZERO,
		 a + (ii + is * lda) * 2, lda,
		 b + (ii + js * ldb) * 2, ldb,
		 b + (is + js * ldb) * 2, ldb,
		 buffer);
#elif (TRANSA == 2) &&  defined(TRANSB)
	GEMM_NN(j, m - is, MIN(is, TRSM_P2), dp1, ZERO,
		 b + (js + ii * ldb) * 2, ldb,
		 a + (ii + is * lda) * 2, lda,
		 b + (js + is * ldb) * 2, ldb,
		 buffer);
#elif (TRANSA == 4) &&  defined(TRANSB)
	GEMM_NR(j, m - is, MIN(is, TRSM_P2), dp1, ZERO,
		 b + (js + ii * ldb) * 2, ldb,
		 a + (ii + is * lda) * 2, lda,
		 b + (js + is * ldb) * 2, ldb,
		 buffer);
#endif
      }

#ifndef TRANSB
      inner_trmm(MIN(TRSM_P2, is), j, a + (ii + ii *lda) * 2, lda, 
		 b + (ii + js  * ldb) * 2, ldb, buffer);
#else
      inner_trmm(MIN(TRSM_P2, is), j, a + (ii + ii *lda) * 2, lda,
		 b + (js + ii  * ldb) * 2, ldb, buffer);
#endif

    }
  }

#else

  BLASLONG is, ii;

    for (is = m; is > 0; is -= TRSM_P2){

      ii = MAX(is - TRSM_P2, 0);

      if (m > is){
#if   (TRANSA == 1) && !defined(TRANSB)
	GEMM_NN(m - is, n, MIN(is, TRSM_P2), dp1, ZERO,
		 a + (is + ii * lda) * 2, lda,
		 b + (ii           ) * 2, ldb,
		 b + (is           ) * 2, ldb,
		 buffer);
#elif (TRANSA == 3) && !defined(TRANSB)
	GEMM_RN(m - is, n, MIN(is, TRSM_P2), dp1, ZERO,
		 a + (is + ii * lda) * 2, lda,
		 b + (ii           ) * 2, ldb,
		 b + (is           ) * 2, ldb,
		 buffer);
#elif (TRANSA == 1) &&  defined(TRANSB)
	GEMM_NT(n, m - is, MIN(is, TRSM_P2), dp1, ZERO,
		 b + (     ii * ldb) * 2, ldb,
		 a + (is + ii * lda) * 2, lda,
		 b + (     is * ldb) * 2, ldb,
		 buffer);
#elif (TRANSA == 3) &&  defined(TRANSB)
	GEMM_NC(n, m - is, MIN(is, TRSM_P2), dp1, ZERO,
		 b + (     ii * ldb) * 2, ldb,
		 a + (is + ii * lda) * 2, lda,
		 b + (     is * ldb) * 2, ldb,
		 buffer);
#elif (TRANSA == 2) && !defined(TRANSB)
	GEMM_TN(m - is, n, MIN(is, TRSM_P2), dp1, ZERO,
		 a + (ii + is * lda) * 2, lda,
		 b + (ii           ) * 2, ldb,
		 b + (is           ) * 2, ldb,
		 buffer);
#elif (TRANSA == 4) && !defined(TRANSB)
	GEMM_CN(m - is, n, MIN(is, TRSM_P2), dp1, ZERO,
		 a + (ii + is * lda) * 2, lda,
		 b + (ii           ) * 2, ldb,
		 b + (is           ) * 2, ldb,
		 buffer);
#elif (TRANSA == 2) &&  defined(TRANSB)
	GEMM_NN(n, m - is, MIN(is, TRSM_P2), dp1, ZERO,
		 b + (     ii * ldb) * 2, ldb,
		 a + (ii + is * lda) * 2, lda,
		 b + (     is * ldb) * 2, ldb,
		 buffer);
#elif (TRANSA == 4) &&  defined(TRANSB)
	GEMM_NR(n, m - is, MIN(is, TRSM_P2), dp1, ZERO,
		 b + (     ii * ldb) * 2, ldb,
		 a + (ii + is * lda) * 2, lda,
		 b + (     is * ldb) * 2, ldb,
		 buffer);
#endif
      }

#ifndef TRANSB
      inner_trmm(MIN(TRSM_P2, is), n, a + (ii + ii *lda) * 2, lda, 
		 b + ii * 2, ldb, buffer);
#else
      inner_trmm(MIN(TRSM_P2, is), n, a + (ii + ii *lda) * 2, lda,
		 b + ii * ldb * 2, ldb, buffer);
#endif

    }
#endif
  return 0;
}
