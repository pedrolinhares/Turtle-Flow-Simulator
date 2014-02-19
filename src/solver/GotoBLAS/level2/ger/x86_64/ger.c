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

#define P 4000
#define Q    8

int CNAME(BLASLONG m, BLASLONG n, BLASLONG dummy1, FLOAT alpha, 
	 FLOAT *x, BLASLONG incx,
	 FLOAT *y, BLASLONG incy,
	 FLOAT *a, BLASLONG lda, FLOAT *buffer){


  BLASLONG is, js, i, j;
  BLASLONG min_m, min_n;
  FLOAT *bufX, *bufY, *xorig;

  xorig = x;

  for (js = 0; js < n; js += Q) {
    min_n = n - js;
    if (min_n > Q) min_n = Q;
    
    bufY = y + js;
    if (incy != 1) {
      bufY = buffer + P;

      j = (min_n >> 2);
      if (j > 0) {
	do {
	  *(bufY + 0) = *y;
	  y += incy;
	  *(bufY + 1) = *y;
	  y += incy;
	  *(bufY + 2) = *y;
	  y += incy;
	  *(bufY + 3) = *y;
	  y += incy;
	  bufY += 4;
	  j --;
	} while (j > 0);
      }

      j = (min_n & 3);
      if (j > 0) {
	do {
	  *bufY = *y;
	  y += incy;
	  bufY ++;
	  j --;
	} while (j > 0);
      }

      bufY = buffer + P;
    }
      
    x = xorig;

    for (is = 0; is < m; is += P) {
      min_m = m - is;
      if (min_m > P) min_m = P;

      bufX = x + is;
      if (incx != 1){
	bufX = buffer;

	i = (min_m >> 2);
	if (i > 0) {
	  do {
	    *(bufX + 0) = *x;
	    x += incx;
	    *(bufX + 1) = *x;
	    x += incx;
	    *(bufX + 2) = *x;
	    x += incx;
	    *(bufX + 3) = *x;
	    x += incx;

	    bufX += 4;
	    i --;
	  } while (i > 0);
	}

	i = (min_m & 3);
	if (i > 0) {
	  do {
	    *bufX = *x;
	    bufX ++;
	    x += incx;
	    i --;
	  } while (i > 0);
	}

	bufX = buffer;
      }
      
      for (j = 0; j < min_n; j++) {
	AXPY_K(min_m, 0, 0, alpha * bufY[j], bufX, 1, a + is + (j + js) * lda, 1, NULL, 0);
      }
    }
  }

  return 0;
}

