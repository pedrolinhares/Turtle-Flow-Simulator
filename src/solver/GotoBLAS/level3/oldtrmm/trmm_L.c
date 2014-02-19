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

const static FLOAT dp1 = 1.;

static inline void inner_trmm(BLASLONG m, BLASLONG n, FLOAT *a, BLASLONG lda, 
		       FLOAT *b, BLASLONG ldb, FLOAT *buffer){

  BLASLONG i, is, js;
  BLASLONG min_i, min_j;
  BLASLONG length;

  for (js = 0; js < n; js += TRSM_Q1){
    
    min_j = MIN(TRSM_Q1, n - js);
    
    for (is = m; is > 0; is -= TRSM_P1){
      
      min_i = MAX(is - TRSM_P1, 0);

      if (m > is){
#if   !defined(TRANSA) && !defined(TRANSB)
	GEMM_NN (m - is, min_j, MIN(is, TRSM_P1), dp1, 
		 a + is    + min_i * lda, lda,
		 b + min_i + js    * ldb, ldb,
		 b + is    + js    * ldb, ldb,
		 buffer);
#elif !defined(TRANSA) &&  defined(TRANSB)
	GEMM_NT (min_j, m - is, MIN(is, TRSM_P1), dp1, 
		 b + js    + min_i * ldb, ldb,
		 a + is    + min_i * lda, lda,
		 b + js    + is    * ldb, ldb,
		 buffer);
#elif  defined(TRANSA) && !defined(TRANSB)
	GEMM_TN (m - is, min_j, MIN(is, TRSM_P1), dp1, 
		 a + min_i + is    * lda, lda,
		 b + min_i + js    * ldb, ldb,
		 b + is    + js    * ldb, ldb,
		 buffer);
#else
	GEMM_NN (min_j, m - is, MIN(is, TRSM_P1), dp1, 
		 b + js    + min_i * ldb, ldb,
		 a + min_i + is    * lda, lda,
		 b + js    + is    * ldb, ldb,
		 buffer);
#endif
      }
      
      for (i = is - 1; i >= min_i; i--) {
#ifndef UNIT
#ifndef TRANSB
	SCAL_K(min_j, 0, 0, a[i + i * lda],
	      b + i  + js * ldb, ldb, NULL, 0, NULL, 0);
#else
	SCAL_K(min_j, 0, 0, a[i + i * lda],
	      b + js + i  * ldb, 1,   NULL, 0, NULL, 0);
#endif
#endif
	
	length = i - min_i;	  
	
#if   !defined(TRANSA) && !defined(TRANSB)
	GEMV_T(length, min_j, 0, dp1, 
	       b + min_i + js    * ldb, ldb, 
	       a + i     + min_i * lda, lda,
	       b + i     + js    * ldb, ldb, buffer);
#elif  defined(TRANSA) && !defined(TRANSB)
	GEMV_T(length, min_j, 0, dp1, 
	       b + min_i + js    * ldb, ldb,
	       a + min_i + i     * lda, 1,
	       b + i     + js    * ldb, ldb, buffer);
#elif !defined(TRANSA) &&  defined(TRANSB)
	GEMV_N(min_j, length, 0, dp1, 
	       b + js    + min_i * ldb, ldb,
	       a + i     + min_i * lda, lda,
	       b + js    + i     * ldb, 1, buffer);
#else
	GEMV_N(min_j, length, 0, dp1, 
	       b + js    + min_i * ldb, ldb,
	       a + min_i + i     * lda, 1,
	       b + js    + i     * ldb, 1, buffer);
#endif
      }

    }
  }
  return;
}

#ifndef TRANSB
int CNAME(BLASLONG m, BLASLONG n, BLASLONG dummy1, FLOAT dummy2, FLOAT *a, BLASLONG lda, FLOAT *dummy3, BLASLONG dummy4, FLOAT *b, BLASLONG ldb, FLOAT *buffer){
#else
int CNAME(BLASLONG n, BLASLONG m, BLASLONG dummy1, FLOAT dummy2, FLOAT *a, BLASLONG lda, FLOAT *dummy3, BLASLONG dummy4, FLOAT *b, BLASLONG ldb, FLOAT *buffer){
#endif

#ifdef TRSM_Q2

  BLASLONG is, js;
  BLASLONG min_i, min_j;

  for (js = 0; js < n; js += TRSM_Q2){

    min_j = MIN(TRSM_Q2, n - js);

    for (is = m; is > 0; is -= TRSM_P2){
      
      min_i= MAX(is - TRSM_P2, 0);

      if (m > is){
#if   !defined(TRANSA) && !defined(TRANSB)
	GEMM_NN (m - is, min_j, MIN(is, TRSM_P2), dp1, 
		 a + is    + min_i * lda, lda,
		 b + min_i + js    * ldb, ldb,
		 b + is    + js    * ldb, ldb,
		 buffer);
#elif !defined(TRANSA) &&  defined(TRANSB)
	GEMM_NT (min_j, m - is, MIN(is, TRSM_P2), dp1, 
		 b + js    + min_i * ldb, ldb,
		 a + is    + min_i * lda, lda,
		 b + js    + is    * ldb, ldb,
		 buffer);
#elif  defined(TRANSA) && !defined(TRANSB)
	GEMM_TN (m - is, min_j, MIN(is, TRSM_P2), dp1, 
		 a + min_i + is    * lda, lda,
		 b + min_i + js    * ldb, ldb,
		 b + is    + js    * ldb, ldb,
		 buffer);
#else
	GEMM_NN (min_j, m - is, MIN(is, TRSM_P2), dp1, 
		 b + js    + min_i * ldb, ldb,
		 a + min_i + is    * lda, lda,
		 b + js    + is    * ldb, ldb,
		 buffer);
#endif
      }


#ifndef TRANSB
      inner_trmm(MIN(TRSM_P2, is), min_j, a + min_i + min_i * lda, lda,
		 b + min_i + js * ldb, ldb, buffer);
#else
      inner_trmm(MIN(TRSM_P2, is), min_j, a + min_i + min_i * lda, lda, 
		 b + js + min_i * ldb, ldb, buffer);
#endif

    }
  }

#else
  BLASLONG is, min_i;

    for (is = m; is > 0; is -= TRSM_P2){
      
      min_i= MAX(is - TRSM_P2, 0);

      if (m > is){
#if   !defined(TRANSA) && !defined(TRANSB)
	GEMM_NN (m - is, n, MIN(is, TRSM_P2), dp1, 
		 a + is    + min_i * lda, lda,
		 b + min_i              , ldb,
		 b + is                 , ldb,
		 buffer);
#elif !defined(TRANSA) &&  defined(TRANSB)
	GEMM_NT (n, m - is, MIN(is, TRSM_P2), dp1, 
		 b         + min_i * ldb, ldb,
		 a + is    + min_i * lda, lda,
		 b         + is    * ldb, ldb,
		 buffer);
#elif  defined(TRANSA) && !defined(TRANSB)
	GEMM_TN (m - is, n, MIN(is, TRSM_P2), dp1, 
		 a + min_i + is    * lda, lda,
		 b + min_i              , ldb,
		 b + is                 , ldb,
		 buffer);
#else
	GEMM_NN (n, m - is, MIN(is, TRSM_P2), dp1, 
		 b         + min_i * ldb, ldb,
		 a + min_i + is    * lda, lda,
		 b         + is    * ldb, ldb,
		 buffer);
#endif
      }

#ifndef TRANSB
      inner_trmm(MIN(TRSM_P2, is), n, a + min_i + min_i * lda, lda,
		 b + min_i, ldb, buffer);
#else
      inner_trmm(MIN(TRSM_P2, is), n, a + min_i + min_i * lda, lda, 
		 b + min_i * ldb, ldb, buffer);
#endif

    }
#endif

  return 0;
}
