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

static FLOAT dp1 = 1.;

double fabs(double);

static inline void inner_trmm(BLASLONG m, BLASLONG n, FLOAT *a, BLASLONG lda, FLOAT *b, BLASLONG ldb, FLOAT *buffer){

  BLASLONG i, is;
  BLASLONG j, js;
  BLASLONG length;
#ifndef UNIT
  FLOAT alpha_r, alpha_i;
#endif

  for (js = 0; js < n; js += TRSM_Q1){
   
    j = MIN(TRSM_Q1, n - js);

    for (is =0; is < m; is += TRSM_P1){
      if (is >= TRSM_P1){
#if   (TRANSA == 1) && !defined(TRANSB)
	GEMM_NN(is, j, MIN(m - is, TRSM_P1), dp1, ZERO,
		 a + (    + is * lda) * 2, lda,
		 b + (is  + js * ldb) * 2, ldb,
		 b + (    + js * ldb) * 2, ldb,
		 buffer);
#elif (TRANSA == 3) && !defined(TRANSB)
	GEMM_RN(is, j, MIN(m - is, TRSM_P1), dp1, ZERO,
		 a + (    + is * lda) * 2, lda,
		 b + (is  + js * ldb) * 2, ldb,
		 b + (    + js * ldb) * 2, ldb,
		 buffer);
#elif (TRANSA == 1) &&  defined(TRANSB)
	GEMM_NT(j, is, MIN(m - is, TRSM_P1), dp1, ZERO,
		 b + (js  + is * ldb) * 2, ldb,
		 a + (    + is * lda) * 2, lda,
		 b + (js            ) * 2, ldb,
		 buffer);
#elif (TRANSA == 3) &&  defined(TRANSB)
	GEMM_NC(j, is, MIN(m - is, TRSM_P1), dp1, ZERO,
		 b + (js  + is * ldb) * 2, ldb,
		 a + (    + is * lda) * 2, lda,
		 b + (js            ) * 2, ldb,
		 buffer);
#elif (TRANSA == 2) && !defined(TRANSB)
	GEMM_TN(is, j, MIN(m - is, TRSM_P1),  dp1, ZERO,
		 a + (is            ) * 2, lda,
		 b + (is  + js * ldb) * 2, ldb,
		 b + (    + js * ldb) * 2, ldb,
		 buffer);
#elif (TRANSA == 4) && !defined(TRANSB)
	GEMM_CN(is, j, MIN(m - is, TRSM_P1), dp1, ZERO,
		 a + (is            ) * 2, lda,
		 b + (is  + js * ldb) * 2, ldb,
		 b + (    + js * ldb) * 2, ldb,
		 buffer);
#elif (TRANSA == 2) &&  defined(TRANSB)
	GEMM_NN(j, is, MIN(m - is, TRSM_P1), dp1, ZERO,
		 b + (js  + is * ldb) * 2, ldb,
		 a + (is            ) * 2, lda,
		 b + (js            ) * 2, ldb,
		 buffer);
#elif (TRANSA == 4) &&  defined(TRANSB)
	GEMM_NR(j, is, MIN(m - is, TRSM_P1), dp1, ZERO,
		 b + (js  + is * ldb) * 2, ldb,
		 a + (is            ) * 2, lda,
		 b + (js            ) * 2, ldb,
		 buffer);
#endif
      }

      for (i = is; i < MIN(is+TRSM_P1, m); i++) {

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

	length = MIN(is + TRSM_P1, m) - i - 1;

#if   (TRANSA == 1) && !defined(TRANSB)
	ZGEMV_T(length, j, 0, dp1, ZERO,
		b + ((i + 1) + js * ldb) * 2, ldb, 
		a +  (i + (i + 1) * lda) * 2, lda,
		b +  (i      + js * ldb) * 2, ldb, buffer);
#elif (TRANSA == 2) && !defined(TRANSB)
	ZGEMV_T(length, j, 0, dp1, ZERO,
		b + ((i + 1) + js * ldb) * 2, ldb, 
		a + (i + 1  + i  * lda)  * 2, 1,
		b + (i      + js * ldb)  * 2, ldb, buffer);
#elif (TRANSA == 3) && !defined(TRANSB)
	ZGEMV_U(length, j, 0, dp1, ZERO,
		b + ((i + 1) + js * ldb) * 2, ldb, 
		a +  (i + (i + 1) * lda) * 2, lda,
		b +  (i      + js * ldb) * 2, ldb, buffer);
#elif (TRANSA == 4) && !defined(TRANSB)
	ZGEMV_U(length, j, 0, dp1, ZERO,
		b + ((i + 1) + js * ldb) * 2, ldb, 
		a + (i + 1  + i  * lda)  * 2, 1,
		b + (i      + js * ldb)  * 2, ldb, buffer);
#elif (TRANSA == 1) &&  defined(TRANSB)
	ZGEMV_N(j, length, 0, dp1,ZERO,
		b + ((i + 1)*ldb + js) * 2, ldb, 
		a + (i + (i + 1)*lda) * 2,  lda,
		b + (i     *ldb + js) * 2, 1, buffer);
#elif (TRANSA == 2) &&  defined(TRANSB)
	ZGEMV_N(j, length, 0, dp1, ZERO,
		b + ((i + 1)*ldb +js) * 2, ldb, 
		a + (i + 1 + i * lda) * 2, 1,
		b + (i     *ldb + js) * 2, 1, buffer);
#elif (TRANSA == 3) &&  defined(TRANSB)
	ZGEMV_O(j, length, 0, dp1,ZERO,
		b + ((i + 1)*ldb + js) * 2, ldb, 
		a + (i + (i + 1)*lda) * 2,  lda,
		b + (i     *ldb + js) * 2, 1, buffer);
#elif (TRANSA == 4) &&  defined(TRANSB)
	ZGEMV_O(j, length, 0, dp1, ZERO,
		b + ((i + 1)*ldb +js) * 2, ldb, 
		a + (i + 1 + i * lda) * 2, 1,
		b + (i     *ldb + js) * 2, 1, buffer);
#else
#error
#endif
      }

#if 0
#if (TRANSA == 2) || (TRANSA == 4)
      if (m - is > TRSM_P1){
#ifndef TRANSB
#if TRANSA == 2
	GEMM_TN(TRSM_P1, j, m - is - TRSM_P1, dp1, ZERO,
		 a + (is + TRSM_P1 + is*lda) * 2, lda,
		 b + (is + TRSM_P1 + js*ldb) * 2, ldb,
		 b + (is      + js*ldb) * 2 ,ldb,
		 buffer);
#else
	GEMM_CN(TRSM_P1, j, m - is - TRSM_P1, dp1, ZERO,
		 a + (is + TRSM_P1 + is*lda) * 2, lda,
		 b + (is + TRSM_P1 + js*ldb) * 2, ldb,
		 b + (is      + js*ldb) * 2 ,ldb,
		 buffer);
#endif
#else
#if TRANSA == 2
	GEMM_NN(j, TRSM_P1, m - is - TRSM_P1, dp1, ZERO,
		 b + (js + (is + TRSM_P1)*ldb) * 2, ldb,
		 a + (is + TRSM_P1 + is  *lda) * 2, lda,
		 b + (js      + is  *ldb) * 2, ldb,
		 buffer);
#else
	GEMM_NR(j, TRSM_P1, m - is - TRSM_P1, dp1, ZERO,
		 b + (js + (is + TRSM_P1)*ldb) * 2, ldb,
		 a + (is + TRSM_P1 + is  *lda) * 2, lda,
		 b + (js      + is  *ldb) * 2, ldb,
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

  BLASLONG is, j, js;

  for (js = 0; js < n; js += TRSM_Q2){
    
    j = MIN(TRSM_Q2, n - js);

    for (is =0; is < m; is += TRSM_P2){

      if (is >= TRSM_P1){
#if   (TRANSA == 1) && !defined(TRANSB)
	GEMM_NN(is, j, MIN(m - is, TRSM_P2), dp1, ZERO,
		 a + (    + is * lda) * 2, lda,
		 b + (is  + js * ldb) * 2, ldb,
		 b + (    + js * ldb) * 2, ldb,
		 buffer);
#elif (TRANSA == 3) && !defined(TRANSB)
	GEMM_RN(is, j, MIN(m - is, TRSM_P2), dp1, ZERO,
		 a + (    + is * lda) * 2, lda,
		 b + (is  + js * ldb) * 2, ldb,
		 b + (    + js * ldb) * 2, ldb,
		 buffer);
#elif (TRANSA == 1) &&  defined(TRANSB)
	GEMM_NT(j, is, MIN(m - is, TRSM_P2), dp1, ZERO,
		 b + (js  + is * ldb) * 2, ldb,
		 a + (    + is * lda) * 2, lda,
		 b + (js            ) * 2, ldb,
		 buffer);
#elif (TRANSA == 3) &&  defined(TRANSB)
	GEMM_NC(j, is, MIN(m - is, TRSM_P2), dp1, ZERO,
		 b + (js  + is * ldb) * 2, ldb,
		 a + (    + is * lda) * 2, lda,
		 b + (js            ) * 2, ldb,
		 buffer);
#elif (TRANSA == 2) && !defined(TRANSB)
	GEMM_TN(is, j, MIN(m - is, TRSM_P2),  dp1, ZERO,
		 a + (is            ) * 2, lda,
		 b + (is  + js * ldb) * 2, ldb,
		 b + (    + js * ldb) * 2, ldb,
		 buffer);
#elif (TRANSA == 4) && !defined(TRANSB)
	GEMM_CN(is, j, MIN(m - is, TRSM_P2), dp1, ZERO,
		 a + (is            ) * 2, lda,
		 b + (is  + js * ldb) * 2, ldb,
		 b + (    + js * ldb) * 2, ldb,
		 buffer);
#elif (TRANSA == 2) &&  defined(TRANSB)
	GEMM_NN(j, is, MIN(m - is, TRSM_P2), dp1, ZERO,
		 b + (js  + is * ldb) * 2, ldb,
		 a + (is            ) * 2, lda,
		 b + (js            ) * 2, ldb,
		 buffer);
#elif (TRANSA == 4) &&  defined(TRANSB)
	GEMM_NR(j, is, MIN(m - is, TRSM_P2), dp1, ZERO,
		 b + (js  + is * ldb) * 2, ldb,
		 a + (is            ) * 2, lda,
		 b + (js            ) * 2, ldb,
		 buffer);
#endif
      }

#ifndef TRANSB
      inner_trmm(MIN(TRSM_P2, m-is), j, a + (is + is*lda) * 2, lda, 
		 b + (is + js*ldb) * 2, ldb, buffer);
#else
      inner_trmm(MIN(TRSM_P2, m-is), j, a + (is + is*lda) * 2, lda,
		 b + (js + is*ldb) * 2, ldb, buffer);
#endif
    }
  }

#else

  BLASLONG is;

    for (is =0; is < m; is += TRSM_P2){

      if (is >= TRSM_P1){
#if   (TRANSA == 1) && !defined(TRANSB)
	GEMM_NN(is, n, MIN(m - is, TRSM_P2), dp1, ZERO,
		 a + (is * lda) * 2, lda,
		 b + (is      ) * 2, ldb,
		 b                 , ldb,
		 buffer);
#elif (TRANSA == 3) && !defined(TRANSB)
	GEMM_RN(is, n, MIN(m - is, TRSM_P2), dp1, ZERO,
		 a + (is * lda) * 2, lda,
		 b + (is      ) * 2, ldb,
		 b                 , ldb,
		 buffer);
#elif (TRANSA == 1) &&  defined(TRANSB)
	GEMM_NT(n, is, MIN(m - is, TRSM_P2), dp1, ZERO,
		 b + (is * ldb) * 2, ldb,
		 a + (is * lda) * 2, lda,
		 b                 , ldb,
		 buffer);
#elif (TRANSA == 3) &&  defined(TRANSB)
	GEMM_NC(n, is, MIN(m - is, TRSM_P2), dp1, ZERO,
		 b + (is * ldb) * 2, ldb,
		 a + (is * lda) * 2, lda,
		 b                 , ldb,
		 buffer);
#elif (TRANSA == 2) && !defined(TRANSB)
	GEMM_TN(is, n, MIN(m - is, TRSM_P2),  dp1, ZERO,
		 a + (is      ) * 2, lda,
		 b + (is      ) * 2, ldb,
		 b                 , ldb,
		 buffer);
#elif (TRANSA == 4) && !defined(TRANSB)
	GEMM_CN(is, n, MIN(m - is, TRSM_P2), dp1, ZERO,
		 a + (is      ) * 2, lda,
		 b + (is      ) * 2, ldb,
		 b                 , ldb,
		 buffer);
#elif (TRANSA == 2) &&  defined(TRANSB)
	GEMM_NN(n, is, MIN(m - is, TRSM_P2), dp1, ZERO,
		 b + (is * ldb) * 2, ldb,
		 a + (is      ) * 2, lda,
		 b                 , ldb,
		 buffer);
#elif (TRANSA == 4) &&  defined(TRANSB)
	GEMM_NR(n, is, MIN(m - is, TRSM_P2), dp1, ZERO,
		 b + (is * ldb) * 2, ldb,
		 a + (is      ) * 2, lda,
		 b                 , ldb,
		 buffer);
#endif
      }

#ifndef TRANSB
      inner_trmm(MIN(TRSM_P2, m-is), n, a + (is + is * lda) * 2, lda, 
		 b + is * 2, ldb, buffer);
#else
      inner_trmm(MIN(TRSM_P2, m-is), n, a + (is + is * lda) * 2, lda,
		 b + is * ldb * 2, ldb, buffer);
#endif
    }

#endif

  return 0;
}
