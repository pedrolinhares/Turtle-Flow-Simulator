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

static inline void inner_trsm(BLASLONG m, BLASLONG n, FLOAT *a, BLASLONG lda,
		       FLOAT *b, BLASLONG ldb, FLOAT *sa, FLOAT *sb){

  BLASLONG i, is;
  BLASLONG j, js;

  for (js = 0; js < n; js += TRSM_Q1){

    j = MIN(TRSM_Q1, n - js);

    for (is =0; is < m; is += TRSM_P1){

      for (i = is; i < MIN(is+TRSM_P1, m); i++) {

#if   !defined(TRANSA) && !defined(TRANSB)
	GEMV_T(i - is, j, 0, dm1, 
	       b + js * ldb + is, ldb, 
	       a + i +  is*lda, lda,
	       b + js * ldb + i,  ldb, sb);
#elif  defined(TRANSA) && !defined(TRANSB)
	GEMV_T(i - is, j, 0, dm1,
	       b + js * ldb + is, ldb, 
	       a + is + i *lda, 1,
	       b + js * ldb + i,  ldb, sb);
#elif !defined(TRANSA) &&  defined(TRANSB)
	GEMV_N(j, i - is, 0, dm1, 
	       b + is*ldb + js, ldb, 
	       a + i +  is*lda, lda, 
	       b + i *ldb + js, 1, sb);
#else
	GEMV_N(j, i - is, 0, dm1, 
	       b + is*ldb + js, ldb, 
	       a + i*lda + is,  1,
	       b + i *ldb + js, 1, sb);
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

      if (m - is > TRSM_P1){
#if   !defined(TRANSA) && !defined(TRANSB)
	GEMM_NN(m - is - TRSM_P1, j, TRSM_P1, dm1, 
		a + is + TRSM_P1 + is * lda, lda,
		b + js * ldb + is,      ldb,
		b + js * ldb + is + TRSM_P1, ldb,
		sa, sb);
#elif !defined(TRANSA) &&  defined(TRANSB)
	GEMM_NT(j, m - is - TRSM_P1, TRSM_P1, dm1, 
		b + js      + is * ldb, ldb,
		a + is + TRSM_P1 + is * lda, lda,
		b + js + (is + TRSM_P1)*ldb, ldb,
		sa, sb);
#elif  defined(TRANSA) && !defined(TRANSB)
	GEMM_TN(m - is - TRSM_P1, j, TRSM_P1, dm1, 
		a + is + (is + TRSM_P1) * lda, lda,
		b + js * ldb + is,      ldb,
		b + js * ldb + is + TRSM_P1, ldb,
		sa, sb);
#else
	GEMM_NN(j, m - is - TRSM_P1, TRSM_P1, dm1, 
		b + js      + is * ldb, ldb,
		a + is + (is + TRSM_P1) * lda, lda,
		b + js + (is + TRSM_P1)*ldb, ldb,
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

  BLASLONG is, j, js;

  for (js = 0; js < n; js += TRSM_Q2){

    j = MIN(TRSM_Q2, n - js);

    for (is =0; is < m; is += TRSM_P2){

#ifndef TRANSB
      inner_trsm(MIN(TRSM_P2, m-is), j, a + is + is*lda, lda, 
		 b + is + js*ldb, ldb, sa, sb);
#else
      inner_trsm(MIN(TRSM_P2, m-is), j, a + is + is*lda, lda, 
		 b + js + is*ldb, ldb, sa, sb);
#endif

      if (m - is > TRSM_P2){
#if   !defined(TRANSA) && !defined(TRANSB)
	GEMM_NN(m - is - TRSM_P2, j, TRSM_P2, dm1, 
		a + is + TRSM_P2 + is * lda, lda,
		b + js * ldb + is,      ldb,
		b + js * ldb + is + TRSM_P2, ldb,
		sa, sb);
#elif !defined(TRANSA) &&  defined(TRANSB)
	GEMM_NT(j, m - is - TRSM_P2, TRSM_P2, dm1, 
		b + js      + is * ldb, ldb,
		a + is + TRSM_P2 + is * lda, lda,
		b + js + (is + TRSM_P2)*ldb, ldb,
		sa, sb);
#elif  defined(TRANSA) && !defined(TRANSB)
	GEMM_TN(m - is - TRSM_P2, j, TRSM_P2, dm1, 
		a + is + (is + TRSM_P2) * lda, lda,
		b + js * ldb + is,      ldb,
		b + js * ldb + is + TRSM_P2, ldb,
		sa, sb);
#else
	GEMM_NN(j, m - is - TRSM_P2, TRSM_P2, dm1, 
		b + js      + is * ldb, ldb,
		a + is + (is + TRSM_P2) * lda, lda,
		b + js + (is + TRSM_P2)*ldb, ldb,
		sa, sb);
#endif
      }
    }
  }

#else

  BLASLONG is;

  for (is =0; is < m; is += TRSM_P2){
    
#ifndef TRANSB
    inner_trsm(MIN(TRSM_P2, m-is), n, a + is + is*lda, lda, b + is, ldb, sa, sb);
#else
    inner_trsm(MIN(TRSM_P2, m-is), n, a + is + is*lda, lda, b + is * ldb, ldb, sa, sb);
#endif
    
    if (m - is > TRSM_P2){
#if   !defined(TRANSA) && !defined(TRANSB)
      GEMM_NN(m - is - TRSM_P2, n, TRSM_P2, dm1, 
	      a + is + TRSM_P2 + is * lda, lda,
	      b + is,      ldb,
	      b + is + TRSM_P2, ldb,
	      sa, sb);
#elif !defined(TRANSA) &&  defined(TRANSB)
      GEMM_NT(n, m - is - TRSM_P2, TRSM_P2, dm1, 
	      b + is * ldb, ldb,
	      a +  is + TRSM_P2 + is * lda, lda,
	      b + (is + TRSM_P2)*ldb, ldb,
	      sa, sb);
#elif  defined(TRANSA) && !defined(TRANSB)
      GEMM_TN(m - is - TRSM_P2, n, TRSM_P2, dm1, 
	      a + is + (is + TRSM_P2) * lda, lda,
	      b + is,      ldb,
	      b + is + TRSM_P2, ldb,
	      sa, sb);
#else
      GEMM_NN(n, m - is - TRSM_P2, TRSM_P2, dm1, 
	      b      + is * ldb, ldb,
	      a + is + (is + TRSM_P2) * lda, lda,
		b + (is + TRSM_P2)*ldb, ldb,
	      sa, sb);
#endif
    }
  }


#endif

  return 0;
}
