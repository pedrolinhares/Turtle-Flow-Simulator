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

int CNAME(BLASLONG m, FLOAT alpha_r, FLOAT alpha_i,
	  FLOAT *a, BLASLONG lda, FLOAT *x, BLASLONG incx, FLOAT *y, BLASLONG incy, FLOAT *buffer){

  BLASLONG is, min_i;
  FLOAT *X = x;
  FLOAT *Y = y;
  FLOAT *symbuffer  = buffer;
  FLOAT *gemvbuffer = (FLOAT *)(((BLASLONG)buffer + SYMV_P * SYMV_P * sizeof(FLOAT) * 2 + 4095) & ~4095);
  FLOAT *bufferY    = gemvbuffer;
  FLOAT *bufferX    = gemvbuffer;

  if (incy != 1) {
    Y = bufferY;
    bufferX    = (FLOAT *)(((BLASLONG)bufferY + m * sizeof(FLOAT) * 2 + 4095) & ~4095);
    gemvbuffer = bufferX;
    ZCOPY_K(m, y, incy, Y, 1);
  }

  if (incx != 1) {
    X = bufferX;
    gemvbuffer = (FLOAT *)(((BLASLONG)bufferX + m * sizeof(FLOAT) * 2 + 4095) & ~4095);
    ZCOPY_K(m, x, incx, X, 1);
  }

  for(is = 0; is < m; is += SYMV_P){

    min_i = MIN(m - is, SYMV_P);
      
#ifndef LOWER
    if (is >0){
      ZGEMV_T(is, min_i, 0, alpha_r, alpha_i,
	      a + is * lda * COMPSIZE, lda,
	      X,                       1,
	      Y + is * COMPSIZE,       1, gemvbuffer);
      
      ZGEMV_N(is, min_i, 0, alpha_r, alpha_i,
	      a + is * lda  * COMPSIZE,  lda,
	      X + is * COMPSIZE, 1,
	      Y,                 1, gemvbuffer);
    }
#endif

#ifdef LOWER
    ZSYMCOPY_L(min_i, a + (is + is * lda) * COMPSIZE, lda, symbuffer);
#else
    ZSYMCOPY_U(min_i, a + (is + is * lda) * COMPSIZE, lda, symbuffer);
#endif
    
    ZGEMV_N(min_i, min_i, 0, alpha_r, alpha_i,
	    symbuffer, min_i,
	    X + is * COMPSIZE, 1,
	    Y + is * COMPSIZE, 1, gemvbuffer);
    

#ifdef LOWER
    if (m - is >  SYMV_P){
      ZGEMV_T(m - is - SYMV_P, min_i, 0, alpha_r, alpha_i,
	      a + ((is + SYMV_P) + is * lda) * COMPSIZE, lda,
	      X + (is + SYMV_P) * COMPSIZE, 1,
	      Y +  is           * COMPSIZE, 1, gemvbuffer);
      
      ZGEMV_N(m - is - SYMV_P, min_i, 0, alpha_r, alpha_i,
	      a + ((is + SYMV_P) + is * lda) * COMPSIZE, lda,
	      X +  is           * COMPSIZE, 1,
	      Y + (is + SYMV_P) * COMPSIZE, 1, gemvbuffer);
    }
#endif

  } /* end of is */

  if (incy != 1) {
    ZCOPY_K(m, Y, 1, y, incy);
  }

  return 0;
}

