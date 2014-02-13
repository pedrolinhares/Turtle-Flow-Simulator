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

#undef SYMV_P
#define SYMV_P 4

int CNAME(long m, FLOAT alpha, FLOAT *a, long lda,
	  FLOAT *x, long incx, FLOAT *y, long incy, void *buffer){

  long i, is;
  FLOAT *X = buffer;
  FLOAT *Y = y;
  FLOAT *bufferY = (FLOAT *)(((long)buffer + m * sizeof(FLOAT) + 4095) & ~4095);

  FLOAT xsum1, xsum2, xsum3, xsum4;
  FLOAT atemp1, atemp2, atemp3, atemp4;
  FLOAT xtemp1, xtemp2, xtemp3, xtemp4;
  FLOAT *xx, *yy;
  FLOAT *A1, *A2, *A3, *A4;

  COPY_K(m, x, incx, X, 1);
  if (alpha != ONE) SCAL_K(m, 0, 0, alpha, X, 1, NULL, 0, NULL, 0);

  if (incy != 1) {
    Y = bufferY;
    COPY_K(m, y, incy, Y, 1);
  }

#ifndef LOWER

  is = 0;

  if (is + 4 <= m) {
    do {
      A1 = a + 0 * lda;
      A2 = a + 1 * lda;
      A3 = a + 2 * lda;
      A4 = a + 3 * lda;
      a += 4 * lda;

      atemp1 = X[is + 0];
      atemp2 = X[is + 1];
      atemp3 = X[is + 2];
      atemp4 = X[is + 3];
      
      xsum1 = ZERO; xsum2 = ZERO;
      xsum3 = ZERO; xsum4 = ZERO;
	
      xx = X;
      yy = Y;

      for (i = 0; i < is; i+= 4) {
	xtemp1 = xx[0];
	xtemp2 = xx[1];
	xtemp3 = xx[2];
	xtemp4 = xx[3];
	xx += 4;
	
	xsum1 += (xtemp1 * A1[0] + xtemp2 * A1[1]) + (xtemp3 * A1[2] + xtemp4 * A1[3]);
	xsum2 += (xtemp1 * A2[0] + xtemp2 * A2[1]) + (xtemp3 * A2[2] + xtemp4 * A2[3]);
	xsum3 += (xtemp1 * A3[0] + xtemp2 * A3[1]) + (xtemp3 * A3[2] + xtemp4 * A3[3]);
	xsum4 += (xtemp1 * A4[0] + xtemp2 * A4[1]) + (xtemp3 * A4[2] + xtemp4 * A4[3]);
	
	yy[0] += atemp1 * A1[0] + atemp2 * A2[0] + atemp3 * A3[0] + atemp4 * A4[0];
	yy[1] += atemp1 * A1[1] + atemp2 * A2[1] + atemp3 * A3[1] + atemp4 * A4[1];
	yy[2] += atemp1 * A1[2] + atemp2 * A2[2] + atemp3 * A3[2] + atemp4 * A4[2];
	yy[3] += atemp1 * A1[3] + atemp2 * A2[3] + atemp3 * A3[3] + atemp4 * A4[3];
	yy += 4;
	
	A1 += 4;
	A2 += 4;
	A3 += 4;
	A4 += 4;
      }

      xsum1 += atemp1 * A1[0] + atemp2 * A2[0] + atemp3 * A3[0] + atemp4 * A4[0];
      xsum2 += atemp1 * A2[0] + atemp2 * A2[1] + atemp3 * A3[1] + atemp4 * A4[1];
      xsum3 += atemp1 * A3[0] + atemp2 * A3[1] + atemp3 * A3[2] + atemp4 * A4[2];
      xsum4 += atemp1 * A4[0] + atemp2 * A4[1] + atemp3 * A4[2] + atemp4 * A4[3];

      Y[is + 0] += xsum1;
      Y[is + 1] += xsum2;
      Y[is + 2] += xsum3;
      Y[is + 3] += xsum4;

      is += 4;
    } while (is + 4 <= m);
  }

  if (m & 2) {

    A1 = a + 0 * lda;
    A2 = a + 1 * lda;
    a += 2 * lda;

    atemp1 = X[is + 0];
    atemp2 = X[is + 1];
    
    xsum1 = ZERO; xsum2 = ZERO;

    xx = X;
    yy = Y;

    for (i = 0; i < is; i+= 2) {
      xtemp1 = xx[0];
      xtemp2 = xx[1];
      xx += 2;
      
      xsum1 += (xtemp1 * A1[0] + xtemp2 * A1[1]);
      xsum2 += (xtemp1 * A2[0] + xtemp2 * A2[1]);
      
      yy[0] += atemp1 * A1[0] + atemp2 * A2[0];
      yy[1] += atemp1 * A1[1] + atemp2 * A2[1];
      yy += 2;
      
      A1 += 2;
      A2 += 2;
    }
    
    xsum1 += atemp1 * A1[0] + atemp2 * A2[0];
    xsum2 += atemp1 * A2[0] + atemp2 * A2[1];
    
    Y[is + 0] += xsum1;
    Y[is + 1] += xsum2;
    is += 2;
  }

  if (m & 1) {

    A1 = a + 0 * lda;
    a += lda;

    atemp1 = X[is + 0];
    
    xsum1 = ZERO;

    xx = X;
    yy = Y;

    for (i = 0; i < is; i++) {
      xtemp1 = xx[0];
      xx += 1;
      
      xsum1 += xtemp1 * A1[0];
      
      yy[0] += atemp1 * A1[0];
      yy += 1;
      
      A1 ++;
    }
    
    xsum1 += atemp1 * A1[0];
    
    Y[is + 0] += xsum1;
  }

#else

  is = 0;

  if (is + 4 <= m) {
    do {
      A1 = a + 0 * lda;
      A2 = a + 1 * lda;
      A3 = a + 2 * lda;
      A4 = a + 3 * lda;
      a += 4 + 4 * lda;

      xx = X + is;
      yy = Y + is + 4;

      atemp1 = xx[0];
      atemp2 = xx[1];
      atemp3 = xx[2];
      atemp4 = xx[3];
      xx += 4;
      
      xsum1 = atemp1 * A1[0] + atemp2 * A1[1] + atemp3 * A1[2] + atemp4 * A1[3];
      xsum2 = atemp1 * A1[1] + atemp2 * A2[1] + atemp3 * A2[2] + atemp4 * A2[3];
      xsum3 = atemp1 * A1[2] + atemp2 * A2[2] + atemp3 * A3[2] + atemp4 * A3[3];
      xsum4 = atemp1 * A1[3] + atemp2 * A2[3] + atemp3 * A3[3] + atemp4 * A4[3];
      
      A1 += 4;
      A2 += 4;
      A3 += 4;
      A4 += 4;

      i = ((m - is - 4) >> 2);
      if (i > 0) {
	do {
	  xtemp1 = xx[0];
	  xtemp2 = xx[1];
	  xtemp3 = xx[2];
	  xtemp4 = xx[3];
	  xx += 4;
	  
	  xsum1 += (xtemp1 * A1[0] + xtemp2 * A1[1]) + (xtemp3 * A1[2] + xtemp4 * A1[3]);
	  xsum2 += (xtemp1 * A2[0] + xtemp2 * A2[1]) + (xtemp3 * A2[2] + xtemp4 * A2[3]);
	  xsum3 += (xtemp1 * A3[0] + xtemp2 * A3[1]) + (xtemp3 * A3[2] + xtemp4 * A3[3]);
	  xsum4 += (xtemp1 * A4[0] + xtemp2 * A4[1]) + (xtemp3 * A4[2] + xtemp4 * A4[3]);
	  
	  yy[0] += atemp1 * A1[0] + atemp2 * A2[0] + atemp3 * A3[0] + atemp4 * A4[0];
	  yy[1] += atemp1 * A1[1] + atemp2 * A2[1] + atemp3 * A3[1] + atemp4 * A4[1];
	  yy[2] += atemp1 * A1[2] + atemp2 * A2[2] + atemp3 * A3[2] + atemp4 * A4[2];
	  yy[3] += atemp1 * A1[3] + atemp2 * A2[3] + atemp3 * A3[3] + atemp4 * A4[3];

	  yy += 4;
	  
	  A1 += 4;
	  A2 += 4;
	  A3 += 4;
	  A4 += 4;
	  i --;
	} while (i > 0);
      }

      if  (m & 2) {
	xtemp1 = xx[0];
	xtemp2 = xx[1];
	xx += 2;
	
	xsum1 += (xtemp1 * A1[0] + xtemp2 * A1[1]);
	xsum2 += (xtemp1 * A2[0] + xtemp2 * A2[1]);
	xsum3 += (xtemp1 * A3[0] + xtemp2 * A3[1]);
	xsum4 += (xtemp1 * A4[0] + xtemp2 * A4[1]);
	
	yy[0] += atemp1 * A1[0] + atemp2 * A2[0] + atemp3 * A3[0] + atemp4 * A4[0];
	yy[1] += atemp1 * A1[1] + atemp2 * A2[1] + atemp3 * A3[1] + atemp4 * A4[1];
	
	yy += 2;
	
	A1 += 2;
	A2 += 2;
	A3 += 2;
	A4 += 2;
      }

      if  (m & 1) {
	xtemp1 = xx[0];
	xx ++;
	
	xsum1 += xtemp1 * A1[0];
	xsum2 += xtemp1 * A2[0];
	xsum3 += xtemp1 * A3[0];
	xsum4 += xtemp1 * A4[0];
	
	yy[0] += atemp1 * A1[0] + atemp2 * A2[0] + atemp3 * A3[0] + atemp4 * A4[0];
	yy += 1;
	
	A1 += 1;
	A2 += 1;
	A3 += 1;
	A4 += 1;
      }

      Y[is + 0] += xsum1;
      Y[is + 1] += xsum2;
      Y[is + 2] += xsum3;
      Y[is + 3] += xsum4;

      is += 4;
    } while (is + 4 <= m);
  }

  if (m & 2) {
    A1 = a + 0 * lda;
    A2 = a + 1 * lda;
    a += 2 + 2 * lda;

    xx = X + is;
    yy = Y + is + 2;

    atemp1 = xx[0];
    atemp2 = xx[1];
    xx += 2;
      
    xsum1 = atemp1 * A1[0] + atemp2 * A1[1];
    xsum2 = atemp1 * A1[1] + atemp2 * A2[1];
      
    A1 += 2;
    A2 += 2;

    if  (m & 1) {
      xtemp1 = xx[0];
      xx ++;
      
      xsum1 += xtemp1 * A1[0];
      xsum2 += xtemp1 * A2[0];
      
      yy[0] += atemp1 * A1[0] + atemp2 * A2[0];
      yy += 1;
      
      A1 += 1;
      A2 += 1;
    }
    
    Y[is + 0] += xsum1;
    Y[is + 1] += xsum2;
    
    is += 2;
  }

  if (m & 1) {
    A1 = a + 0 * lda;
    a += 1 + 1 * lda;

    xx = X + is;
    yy = Y + is + 1;

    atemp1 = xx[0];
    xx += 1;
      
    xsum1 = atemp1 * A1[0];
      
    A1 ++;

    Y[is + 0] += xsum1;
    
    is += 1;
  }


#endif

  if (incy != 1) {
    COPY_K(m, Y, 1, y, incy);
  }

  return 0;
}

