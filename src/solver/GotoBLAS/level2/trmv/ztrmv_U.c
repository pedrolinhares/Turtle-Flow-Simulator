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

int CNAME(BLASLONG m, FLOAT *a, BLASLONG lda, FLOAT *b, BLASLONG incb, void *buffer){
  
  BLASLONG i, is, min_i;
#if (TRANSA == 2) || (TRANSA == 4)
  FLOAT temp[2];
#endif
#ifndef UNIT
  FLOAT atemp1, atemp2, btemp1, btemp2;
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

#if (TRANSA) == 1 || (TRANSA == 3)
    if (is > 0){
#if   TRANSA == 1
      ZGEMV_N(is, min_i, 0, dp1, ZERO,
	     a + is * lda * 2, lda,
	     B + is       * 2, 1,
	     B,                1, gemvbuffer);
#else
      ZGEMV_R(is, min_i, 0, dp1, ZERO,
	     a + is * lda * 2, lda,
	     B + is       * 2, 1,
	     B,                1, gemvbuffer);
#endif
    }
#endif

    for (i = 0; i < min_i; i++) {
      FLOAT *AA = a + (is + (i + is) * lda) * 2;
      FLOAT *BB = B + is * 2;

#if (TRANSA == 1) || (TRANSA == 3)
#if   TRANSA == 1
      if (i > 0) ZAXPY_K (i, 0, 0, BB[i * 2 + 0],  BB[i * 2 + 1],
			  AA, 1, BB, 1, NULL, 0);
#else
      if (i > 0) ZAXPYC_K(i, 0, 0, BB[i * 2 + 0],  BB[i * 2 + 1],
			  AA, 1, BB, 1, NULL, 0);
#endif
#endif

#ifndef UNIT
      atemp1 = AA[i * 2 + 0];
      atemp2 = AA[i * 2 + 1];

      btemp1 = BB[i * 2 + 0];
      btemp2 = BB[i * 2 + 1];

#if (TRANSA == 1) || (TRANSA == 2)
      BB[i * 2 + 0] = atemp1 * btemp1 - atemp2 * btemp2;
      BB[i * 2 + 1] = atemp1 * btemp2 + atemp2 * btemp1;
#else
      BB[i * 2 + 0] = atemp1 * btemp1 + atemp2 * btemp2;
      BB[i * 2 + 1] = atemp1 * btemp2 - atemp2 * btemp1;
#endif
#endif

#if (TRANSA == 2) || (TRANSA == 4)
      if (i < min_i - 1) {
#if TRANSA == 2
	temp[0] = ZDOTU_K(min_i - i - 1,
			  AA + (i + 1) * 2, 1,
			  BB + (i + 1) * 2, 1);
#else
	temp[0] = ZDOTC_K(min_i - i - 1,
			  AA + (i + 1) * 2, 1,
			  BB + (i + 1) * 2, 1);
#endif
      GET_IMAGE(temp[1]);

      BB[i * 2 + 0] += temp[0];
      BB[i * 2 + 1] += temp[1];
      }
#endif

    }
    
#if (TRANSA) == 2 || (TRANSA == 4)
    if (m - is > min_i){
#if TRANSA == 2
      ZGEMV_T(m - is - min_i, min_i, 0, dp1, ZERO,
	      a + (is + min_i + is * lda) * 2,  lda,
	      B + (is + min_i) * 2, 1,
	      B +  is            * 2, 1, gemvbuffer);
#else
      ZGEMV_C(m - is - min_i, min_i, 0, dp1, ZERO,
	      a + (is + min_i + is * lda) * 2,  lda,
	      B + (is + min_i) * 2, 1,
	      B +  is            * 2, 1, gemvbuffer);
#endif
    }
#endif
  }

  if (incb != 1) {
    ZCOPY_K(m, buffer, 1, b, incb);
  }

  return 0;
}

