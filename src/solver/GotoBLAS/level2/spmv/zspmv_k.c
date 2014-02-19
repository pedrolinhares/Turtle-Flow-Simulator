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
	  FLOAT *a, FLOAT *x, BLASLONG incx, FLOAT *y, BLASLONG incy, void *buffer){

  BLASLONG i;
  FLOAT *X = x;
  FLOAT *Y = y;
  FLOAT *gemvbuffer = (FLOAT *)buffer;
  FLOAT *bufferY    = gemvbuffer;
  FLOAT *bufferX    = gemvbuffer;
  FLOAT temp[2];

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

  for (i = 0; i < m; i++) {
#ifndef LOWER

    if (i > 0) {
      temp[0] = ZDOTU_K(i, a, 1, X, 1);
      GET_IMAGE(temp[1]);
      
      Y[i * 2 + 0] += alpha_r * temp[0] - alpha_i * temp[1];
      Y[i * 2 + 1] += alpha_r * temp[1] + alpha_i * temp[0];
    }

    ZAXPY_K(i + 1, 0, 0,
	   alpha_r * X[i * 2 + 0] - alpha_i * X[i * 2 + 1], 
	   alpha_r * X[i * 2 + 1] + alpha_i * X[i * 2 + 0], 
	   a, 1, Y, 1, NULL, 0);

    a += (i + 1) * 2;
  
#else

    temp[0] = ZDOTU_K(m - i, a + i * 2, 1, X + i * 2, 1);
    GET_IMAGE(temp[1]);
    
    Y[i * 2 + 0] += alpha_r * temp[0] - alpha_i * temp[1];
    Y[i * 2 + 1] += alpha_r * temp[1] + alpha_i * temp[0];

    if (m - i > 1)
      ZAXPY_K(m - i - 1, 0, 0,
	      alpha_r * X[i * 2 + 0] - alpha_i * X[i * 2 + 1], 
	      alpha_r * X[i * 2 + 1] + alpha_i * X[i * 2 + 0], 
	      a + (i + 1) * 2, 1, Y + (i + 1) * 2, 1, NULL, 0);

    a += (m - i - 1) * 2;

#endif
  }

  if (incy != 1) {
    ZCOPY_K(m, Y, 1, y, incy);
  }

  return 0;
}

