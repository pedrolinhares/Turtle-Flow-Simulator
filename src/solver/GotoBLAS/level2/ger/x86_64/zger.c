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

#define P 400
#define Q  88

int CNAME(BLASLONG m, BLASLONG n, BLASLONG dummy1, FLOAT alpha_r, FLOAT alpha_i,
	 FLOAT *x, BLASLONG incx,
	 FLOAT *y, BLASLONG incy,
	 FLOAT *a, BLASLONG lda, FLOAT *buffer){


  BLASLONG is, js, i, j;
  BLASLONG min_m, min_n;
  FLOAT *bufX, *bufY, *xorig;

  xorig = x;
  incx *= 2;
  incy *= 2;

  for (js = 0; js < n; js += Q) {
    min_n = n - js;
    if (min_n > Q) min_n = Q;
    
    bufY = y + js * 2;
    if (incy != 2) {
      bufY = buffer + P * 2;

      j = (min_n >> 2);
      if (j > 0) {
	do {
	  *(bufY + 0) = *(y + 0);
	  *(bufY + 1) = *(y + 1);
	  y += incy;
	  *(bufY + 2) = *(y + 0);
	  *(bufY + 3) = *(y + 1);
	  y += incy;
	  *(bufY + 4) = *(y + 0);
	  *(bufY + 5) = *(y + 1);
	  y += incy;
	  *(bufY + 6) = *(y + 0);
	  *(bufY + 7) = *(y + 1);
	  y += incy;
	  bufY += 8;
	  j --;
	} while (j > 0);
      }

      j = (min_n & 3);
      if (j > 0) {
	do {
	  *(bufY + 0) = *(y + 0);
	  *(bufY + 1) = *(y + 1);
	  y += incy;
	  bufY += 2;
	  j --;
	} while (j > 0);
      }

      bufY = buffer + P * 2;
    }
      
    x = xorig;

    for (is = 0; is < m; is += P) {
      min_m = m - is;
      if (min_m > P) min_m = P;

      bufX = x + is * 2;
      if (incx != 2){
	bufX = buffer;

	i = (min_m >> 2);
	if (i > 0) {
	  do {
	    *(bufX + 0) = *(x + 0);
	    *(bufX + 1) = *(x + 1);
	    x += incx;
	    *(bufX + 2) = *(x + 0);
	    *(bufX + 3) = *(x + 1);
	    x += incx;
	    *(bufX + 4) = *(x + 0);
	    *(bufX + 5) = *(x + 1);
	    x += incx;
	    *(bufX + 6) = *(x + 0);
	    *(bufX + 7) = *(x + 1);
	    x += incx;
	    bufX += 8;
	    i --;
	  } while (i > 0);
	}

	i = (min_m & 3);
	if (i > 0) {
	  do {
	    *(bufX + 0) = *(x + 0);
	    *(bufX + 1) = *(x + 1);
	    x += incx;
	    bufX += 2;
	    i --;
	  } while (i > 0);
	}

	bufX = buffer;
      }
      
      for (j = 0; j < min_n; j++) {
	FLOAT beta_r = bufY[j * 2 + 0];
	FLOAT beta_i = bufY[j * 2 + 1];

	ZAXPY_K(min_m, 0, 0, 
#ifndef CONJ
	        alpha_r * beta_r - alpha_i * beta_i,
	        alpha_r * beta_i + alpha_i * beta_r,
#else
	        alpha_r * beta_r + alpha_i * beta_i,
	       -alpha_r * beta_i + alpha_i * beta_r,
#endif
	       bufX, 1, a + (is + (j + js) * lda) * 2, 1, NULL, 0);
      }
    }
  }

  return 0;
}

