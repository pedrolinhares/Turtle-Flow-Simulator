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

int CNAME(BLASLONG m, FLOAT *a, BLASLONG lda, FLOAT *b, BLASLONG incb, void *buffer){
  
  BLASLONG i, is, min_i;
#if (TRANSA == 2) || (TRANSA == 4)
  FLOAT result[2];
#endif
#ifndef UNIT
  FLOAT ar, ai, br, bi, ratio, den;
#endif
  FLOAT *gemvbuffer = (FLOAT *)buffer;
  FLOAT *B = b;

  if (incb != 1) {
    B = buffer;
    gemvbuffer = (FLOAT *)(((BLASLONG)buffer + m * sizeof(FLOAT) * 2 + 4095) & ~4095);
    ZCOPY_K(m, b, incb, buffer, 1);
  }

  for (is =0; is < m; is += TRSV_P1){

    min_i = MIN(m - is, TRSV_P1);

#if (TRANSA == 2) || (TRANSA == 4)
    if (is > 0){
#if TRANSA == 2
      ZGEMV_T(is, min_i, 0, dm1, ZERO,
	      a + is * lda * COMPSIZE,  lda,
	      B,                 1,
	      B + is * COMPSIZE, 1, gemvbuffer);
#else
      ZGEMV_C(is, min_i, 0, dm1, ZERO,
	      a + is * lda  * COMPSIZE,  lda,
	      B,                 1,
	      B + is * COMPSIZE, 1, gemvbuffer);
#endif
    }
#endif

    for (i = 0; i < min_i; i++) {
      FLOAT *AA = a + (is + (i + is) * lda) * COMPSIZE;
      FLOAT *BB = B + is * COMPSIZE;

#if (TRANSA == 2) || (TRANSA == 4)
      if (i > 0) {
#if TRANSA == 2
      result[0] = ZDOTU_K(i, AA, 1, BB, 1);
#else
      result[0] = ZDOTC_K(i, AA, 1, BB, 1);
#endif
      GET_IMAGE(result[1]);

      BB[i * COMPSIZE + 0] -= result[0];
      BB[i * COMPSIZE + 1] -= result[1];
    }
#endif

#ifndef UNIT
      ar = AA[i * COMPSIZE + 0];
      ai = AA[i * COMPSIZE + 1];
      
      if (fabs(ar) >= fabs(ai)){
	ratio = ai / ar;
	den = 1./(ar * ( 1 + ratio * ratio));
	
	ar =  den;
#if TRANSA < 3
	ai = -ratio * den;
#else
	ai =  ratio * den;
#endif
      } else {
	ratio = ar / ai;
	den = 1./(ai * ( 1 + ratio * ratio));
	ar =  ratio * den;
#if TRANSA < 3
	ai = -den;
#else
	ai =  den;
#endif
    }

      br = BB[i * COMPSIZE + 0];
      bi = BB[i * COMPSIZE + 1];
      
      BB[i * COMPSIZE + 0] = ar*br - ai*bi;
      BB[i * COMPSIZE + 1] = ar*bi + ai*br;
#endif


#if (TRANSA == 1) || (TRANSA == 3)
      if (i < min_i - 1) {
#if TRANSA == 1
	ZAXPY_K(min_i - i  - 1 , 0, 0,
	       - BB[i * COMPSIZE + 0], - BB[i * COMPSIZE + 1],
	       AA + (i + 1) * COMPSIZE, 1, BB + (i + 1) * COMPSIZE, 1, NULL, 0);
#else
	ZAXPYC_K(min_i - i  - 1 , 0, 0,
	       - BB[i * COMPSIZE + 0], - BB[i * COMPSIZE + 1],
	       AA + (i + 1) * COMPSIZE, 1, BB + (i + 1) * COMPSIZE, 1, NULL, 0);
#endif
    }
#endif
    }

#if (TRANSA == 1) || (TRANSA == 3)
    if (m - is > min_i){
#if   TRANSA == 1
      ZGEMV_N(m - is - min_i, min_i, 0, dm1, ZERO,
	      a + (is + min_i + is * lda) * COMPSIZE, lda,
	      B + is           * COMPSIZE, 1,
	      B + (is + min_i) * COMPSIZE, 1, gemvbuffer);
#else
      ZGEMV_R(m - is - min_i, min_i, 0, dm1, ZERO,
	      a + (is + min_i + is * lda) * COMPSIZE, lda,
	      B + is           * COMPSIZE, 1,
	      B + (is + min_i) * COMPSIZE, 1, gemvbuffer);
#endif
    }
#endif
  }

  if (incb != 1) {
    ZCOPY_K(m, buffer, 1, b, incb);
  }

  return 0;
}
