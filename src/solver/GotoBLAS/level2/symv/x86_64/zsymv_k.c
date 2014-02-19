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

int CNAME(long m, FLOAT alpha_r, FLOAT alpha_i, 
	  FLOAT *a, long lda,
	  FLOAT *x, long incx, FLOAT *y, long incy, void *buffer){

  long i, is;
  FLOAT *X = buffer;
  FLOAT *Y = y;
  FLOAT *bufferY = (FLOAT *)(((long)buffer + 4 * m * sizeof(FLOAT) + 4095) & ~4095);

  FLOAT xsum1, xsum2, xsum3, xsum4;
  FLOAT atemp1, atemp2, atemp3, atemp4;
  FLOAT atemp5, atemp6, atemp7, atemp8;
  FLOAT xtemp1, xtemp2, xtemp3, xtemp4;
  FLOAT xtemp5, xtemp6, xtemp7, xtemp8;
  FLOAT *xx, *yy;
  FLOAT *A1, *A2;

  xx = X;

  for (i = 0; i < m; i++) {
    xtemp1 = x[0];
    xtemp2 = x[1];
    x += incx * 2;
    
    xtemp3 = alpha_r * xtemp1 - alpha_i * xtemp2;
    xtemp4 = alpha_i * xtemp1 + alpha_r * xtemp2;

    xx[0] =  xtemp3;
    xx[1] =  xtemp4;
    xx[2] = -xtemp4;
    xx[3] =  xtemp3;
    xx += 4;
  }

  if (incy != 1) {
    Y = bufferY;
    ZCOPY_K(m, y, incy, Y, 1);
  }

  lda *= 2;

#ifndef LOWER

  is = 0;

  if (is + 2 <= m) {
    do {
      
      A1 = a + 0 * lda;
      A2 = a + 1 * lda;
      a += 2 * lda;
      
      atemp1 = X[is * 4 + 0];
      atemp2 = X[is * 4 + 1];
      atemp3 = X[is * 4 + 2];
      atemp4 = X[is * 4 + 3];
      atemp5 = X[is * 4 + 4];
      atemp6 = X[is * 4 + 5];
      atemp7 = X[is * 4 + 6];
      atemp8 = X[is * 4 + 7];
      
      xsum1 = ZERO; xsum2 = ZERO;
      xsum3 = ZERO; xsum4 = ZERO;
      
      xx = X;
      yy = Y;
      
      for (i = 0; i < is; i+= 2) {
	xtemp1 = xx[0];
	xtemp2 = xx[1];
	xtemp3 = xx[2];
	xtemp4 = xx[3];
	xtemp5 = xx[4];
	xtemp6 = xx[5];
	xtemp7 = xx[6];
	xtemp8 = xx[7];
	xx += 8;
	
	xsum1 += xtemp1 * A1[0] + xtemp3 * A1[1] + xtemp5 * A1[2] + xtemp7 * A1[3];
	xsum2 += xtemp2 * A1[0] + xtemp4 * A1[1] + xtemp6 * A1[2] + xtemp8 * A1[3];
	xsum3 += xtemp1 * A2[0] + xtemp3 * A2[1] + xtemp5 * A2[2] + xtemp7 * A2[3];
	xsum4 += xtemp2 * A2[0] + xtemp4 * A2[1] + xtemp6 * A2[2] + xtemp8 * A2[3];
	
	yy[0] += atemp1 * A1[0] + atemp3 * A1[1] + atemp5 * A2[0] + atemp7 * A2[1];
	yy[1] += atemp4 * A1[1] + atemp2 * A1[0] + atemp8 * A2[1] + atemp6 * A2[0] ;
	yy[2] += atemp1 * A1[2] + atemp3 * A1[3] + atemp5 * A2[2] + atemp7 * A2[3];
	yy[3] += atemp4 * A1[3] + atemp2 * A1[2] + atemp8 * A2[3] + atemp6 * A2[2];

	yy += 4;
	A1 += 4;
	A2 += 4;
      }
      
      xsum1 += atemp1 * A1[0] + atemp3 * A1[1] + atemp5 * A2[0] + atemp7 * A2[1];
      xsum2 += atemp2 * A1[0] + atemp4 * A1[1] + atemp6 * A2[0] + atemp8 * A2[1];
      xsum3 += atemp1 * A2[0] + atemp3 * A2[1] + atemp5 * A2[2] + atemp7 * A2[3];
      xsum4 += atemp2 * A2[0] + atemp4 * A2[1] + atemp6 * A2[2] + atemp8 * A2[3];
      
      Y[is * 2 + 0] += xsum1;
      Y[is * 2 + 1] += xsum2;
      Y[is * 2 + 2] += xsum3;
      Y[is * 2 + 3] += xsum4;

      is += 2;
      
    } while (is + 2 <= m);
  }
  
  if (m & 1) {

    A1 = a + 0 * lda;
    a += lda;

    atemp1 = X[is * 4 + 0];
    atemp2 = X[is * 4 + 1];
    atemp3 = X[is * 4 + 2];
    atemp4 = X[is * 4 + 3];
    
    xsum1 = ZERO;
    xsum2 = ZERO;

    xx = X;
    yy = Y;

    xtemp1 = ZERO;
    xtemp2 = ZERO;
    xtemp3 = ZERO;
    xtemp4 = ZERO;

    for (i = 0; i < is; i++) {
      xtemp1 = xx[0];
      xtemp2 = xx[1];
      xtemp3 = xx[2];
      xtemp4 = xx[3];
      xx += 4;
      
      xsum1 += xtemp1 * A1[0] + xtemp3 * A1[1];
      xsum2 += xtemp2 * A1[0] + xtemp4 * A1[1];
      
      yy[0] += atemp1 * A1[0] + atemp3 * A1[1];
      yy[1] += atemp2 * A1[0] + atemp4 * A1[1];

      yy += 2;
      A1 += 2;
    }
    
    xsum1 += atemp1 * A1[0] + atemp3 * A1[1];
    xsum2 += atemp2 * A1[0] + atemp4 * A1[1];
    
    Y[is * 2 + 0] += xsum1;
    Y[is * 2 + 1] += xsum2;
  }

#else

  is = 0;

  if (is + 2 <= m) {
    do {
      A1 = a + 0 * lda;
      A2 = a + 1 * lda;
      a += 4 + 2 * lda;
      
      xx = X + is * 4;
      yy = Y + is * 2 + 4;
      
      atemp1 = xx[0];
      atemp2 = xx[1];
      atemp3 = xx[2];
      atemp4 = xx[3];
      atemp5 = xx[4];
      atemp6 = xx[5];
      atemp7 = xx[6];
      atemp8 = xx[7];
      xx += 8;
      
      xsum1 = atemp1 * A1[0] + atemp3 * A1[1] + atemp5 * A1[2] + atemp7 * A1[3];
      xsum2 = atemp2 * A1[0] + atemp4 * A1[1] + atemp6 * A1[2] + atemp8 * A1[3];
      xsum3 = atemp1 * A1[2] + atemp3 * A1[3] + atemp5 * A2[2] + atemp7 * A2[3];
      xsum4 = atemp2 * A1[2] + atemp4 * A1[3] + atemp6 * A2[2] + atemp8 * A2[3];
      
      A1 += 4;
      A2 += 4;

      i = ((m - is - 2) >> 1);
      if (i > 0) {
	do {
	  xtemp1 = xx[0];
	  xtemp2 = xx[1];
	  xtemp3 = xx[2];
	  xtemp4 = xx[3];
	  xtemp5 = xx[4];
	  xtemp6 = xx[5];
	  xtemp7 = xx[6];
	  xtemp8 = xx[7];
	  xx += 8;
	  
	  xsum1 += xtemp1 * A1[0] + xtemp3 * A1[1] + xtemp5 * A1[2] + xtemp7 * A1[3];
	  xsum2 += xtemp2 * A1[0] + xtemp4 * A1[1] + xtemp6 * A1[2] + xtemp8 * A1[3];
	  xsum3 += xtemp1 * A2[0] + xtemp3 * A2[1] + xtemp5 * A2[2] + xtemp7 * A2[3];
	  xsum4 += xtemp2 * A2[0] + xtemp4 * A2[1] + xtemp6 * A2[2] + xtemp8 * A2[3];
	  
	  yy[0] += atemp1 * A1[0] + atemp3 * A1[1] + atemp5 * A2[0] + atemp7 * A2[1];
	  yy[1] += atemp2 * A1[0] + atemp4 * A1[1] + atemp6 * A2[0] + atemp8 * A2[1];
	  yy[2] += atemp1 * A1[2] + atemp3 * A1[3] + atemp5 * A2[2] + atemp7 * A2[3];
	  yy[3] += atemp2 * A1[2] + atemp4 * A1[3] + atemp6 * A2[2] + atemp8 * A2[3];
	  
	  yy += 4;
	  
	  A1 += 4;
	  A2 += 4;
	  i --;
	} while (i > 0);
      }
      
      if  (m & 1) {
	xtemp1 = xx[0];
	xtemp2 = xx[1];
	xtemp3 = xx[2];
	xtemp4 = xx[3];
	xx += 4;
	
	xsum1 += xtemp1 * A1[0] + xtemp3 * A1[1];
	xsum2 += xtemp2 * A1[0] + xtemp4 * A1[1];
	xsum3 += xtemp1 * A2[0] + xtemp3 * A2[1];
	xsum4 += xtemp2 * A2[0] + xtemp4 * A2[1];
	
	yy[0] += atemp1 * A1[0] + atemp3 * A1[1] + atemp5 * A2[0] + atemp7 * A2[1];
	yy[1] += atemp2 * A1[0] + atemp4 * A1[1] + atemp6 * A2[0] + atemp8 * A2[1];
	yy += 2;
	
	A1 += 2;
	A2 += 2;
      }

      Y[is * 2 + 0] += xsum1;
      Y[is * 2 + 1] += xsum2;
      Y[is * 2 + 2] += xsum3;
      Y[is * 2 + 3] += xsum4;
      
      is += 2;
    } while (is + 2 <= m);
  }

  if (m & 1) {
    A1 = a;

    xx = X + is * 4;

    atemp1 = xx[0];
    atemp2 = xx[1];
    atemp3 = xx[2];
    atemp4 = xx[3];
      
    xsum1 = atemp1 * A1[0] + atemp3 * A1[1];
    xsum2 = atemp2 * A1[0] + atemp4 * A1[1];
      
    Y[is * 2 + 0] += xsum1;
    Y[is * 2 + 1] += xsum2;
  }
#endif

  if (incy != 1) {
    ZCOPY_K(m, Y, 1, y, incy);
  }

  return 0;
}

